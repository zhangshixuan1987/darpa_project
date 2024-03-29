;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This script is used to compare the correlation between climatology and nudged data ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./area_rectlinear_grid.ncl"

begin

  model     = getenv("MODEL_NAME")
  obs       = getenv("OBS_NAME")
  Input     = getenv("INPUT")
  var       = getenv("VAR")
  plev      = toint(getenv("PLEV"))
  yst       = toint(getenv("yst"))
  yed       = toint(getenv("yed"))
  ystchar   = stringtochar(getenv("yst"))
  yedchar   = stringtochar(getenv("yed"))

  if(var.ne."OLR".and.var.ne."PRECT") then 
    vnam1   = var+sprinti("%03d",plev) 
    vnam2   = var+sprinti("%03d",plev)
    vname   = var+sprinti("%03d",plev)
    freq    = "6hourly"
  else
    if(var.eq."OLR") then 
      vnam1 = "FLUT"
    else
      vnam1 = var
    end if 
    if(obs.eq."ERA5")
      vnam2 = "FLUT"
    else
      vnam2 = var
    end if
    vname   = var 
    freq    = "daily"
  end if 

  print("work on variable: " + vname)

  ;specify regions 
  region_lobnd = (/-90, -60, -20, 30, 60, -90/)
  region_hibnd = (/-60, -30, 20,  60, 90, 90/)
  region_name  = (/1, 2, 3, 4, 5, 6/)
  region_name@long_name = "1 - SH Polar, 90S-60S; " + \
                          "2 - SH Mid-lat, 60S-30S; " + \
                          "3 - Tropical zone, 20S-20N; " + \
                          "4 - NH Mid-lat, 30N-60N; " + \
                          "5 - NH Polar, 60N-90N; " + \
                          "6 - Global"
  dim0     = dimsizes(region_name)
  mon_days = (/31,28,31,30,31,30,31,31,30,31,30,31/)

  ;;;process model simulations
  if (freq.eq."daily") then 
    freqm     = "6hourly"
    modeldir  = Input+"/"+model+"/"+freqm+"/"
    flm       = systemfunc("ls "+modeldir+vnam1+"_*_h1.nc")
  else
    freqm     = "6hourly"
    modeldir  = Input+"/"+model+"/"+freqm+"/"
    flm       = systemfunc("ls "+modeldir+vnam1+"_*_h2.nc")
  end if 
  fm        = addfiles(flm, "r")

  modtime   = cd_calendar(fm[:]->time, -1)
  modind    = ind(modtime.ge.yst.and.modtime.le.yed)

  if(obs.eq."TRMM") then 
    freqo     = "3hourly"
    obsdir    = Input+"/OBS/"+obs+"/"+freqo+"/"
  else if(obs.eq."ERA5") then 
    freqo     = "3hourly"
    obsdir    = Input+"/OBS/"+obs+"/"+freqo+"/"
  else
    freqo     = "daily"
    obsdir    = Input+"/OBS/"+obs+"/"+freqo+"/" 
  end if 
  end if 

  if(obs.eq."ERA5") then
    flo     = systemfunc("ls "+obsdir+vnam2+"_*.nc")
  else
    flo     = systemfunc("ls "+obsdir+"*.nc")
  end if 
  fo        = addfiles(flo, "r")
  obstime   = cd_calendar(fo[:]->time, -1)
  obsind    = ind(obstime.ge.yst.and.obstime.le.yed)

 ;print(modtime(modind))
 ;print(obstime(obsind))

 ;print(flo)
 ;print(flm)

  ;output data directory 
  OUTDir    = "./output/"+model+"-"+obs
  ret 	    = systemfunc("test -d "+OUTDir+"; echo $?")
  if (ret .ne. 0) then
      ret   = systemfunc("mkdir -p "+OUTDir)
  end if

  lat  = fm[0]->lat
  lon  = fm[0]->lon

  vm1  = fm[:]->$vnam1$(modind,:,:)
  vo1  = fo[:]->$vnam2$(obsind,:,:)
  
  vm1@_FillValue = 9.e36
  vo1@_FillValue = 9.e36

  delete([/obstime,obsind,flo,flm,fm,fo/])

  if (freq.eq."daily") then 
 
   if(freqm.eq."daily")
     v1 = vm1
   else
     opt     = True
     opt@nval_crit = 4
     v1 = calculate_daily_values (vm1, "avg", 0, opt)
     v1!0 = "time"
   end if 

   if(freqo.eq."daily")
     v2 = vo1
   else 
     opt     = True
     opt@nval_crit = 4
     v2 = calculate_daily_values (vo1, "avg", 0, opt)
     v2!0 = "time"
   end if 

   delete([/vm1,vo1/])

  else

   tim1  = cd_calendar(vm1&time, -3)
   tim2  = cd_calendar(vo1&time, -3)
   ntim1 = dimsizes(tim1)
   ntim2 = dimsizes(tim2)
  ;print(ntim1 + " " +ntim2)

   if (ntim1 .lt. ntim2) then
     idate = get1Dindex(tim2, tim1) ; index for each desired data
     v1    = vm1
     v2    = vo1(idate,:,:)
   else
     idate = get1Dindex(tim1, tim2) ; index for each desired data
     v2    = vo1
     v1    = vm1(idate,:,:)
   end if
   delete([/tim1,tim2,vm1,vo1,ntim1,ntim2,idate/])

  end if 

  dim1 = dimsizes(v1(:,0,0))
  dim2 = dimsizes(lat)
  dim3 = dimsizes(lon)

  if (var.eq."OMEGA") then 
   ncase = 3   
  else
   ncase = 1
  end if 

  do i = 1 , ncase

    if  (i .eq. 1) then
      fname = OUTDir+"/sac_"+vname+".nc"
      system("rm -rvf "+fname)
      fout = addfile(fname,"cw")
      xv1  = v1
      xv2  = v2
    else if (i .eq. 2) then
      fname = OUTDir+"/sac_"+vname+"_NEGATIVE.nc"
      system("rm -rvf "+fname)
      fout = addfile(fname,"cw")
      xv1 = mask(v1, v1 .lt. 0., True)
      xv2 = mask(v2, v2 .lt. 0., True)
    else
      fname = OUTDir+"/sac_"+vname+"_POSITIVE.nc"
      system("rm -rvf "+fname)
      fout = addfile(fname,"cw")
      xv1 = mask(v1, v1 .gt. 0., True)
      xv2 = mask(v2, v2 .gt. 0., True)
    end if
    end if

    if (var .eq. "PRECT") then
       xv1 = mask(xv1, xv1 .gt. -1.e-20, True)
       xv2 = mask(xv2, xv2 .gt. -1.e-20, True)
    end if
    xv1 = where(ismissing(xv2),xv1@_FillValue,xv1)
    xv2 = where(ismissing(xv1),xv2@_FillValue,xv2)

    corr   = new((/dim1,dim0/), double)

   ;;;;;;;;;;;;;;;;;;;;;;;;
   ;; create the anomaly ;;
   ;;;;;;;;;;;;;;;;;;;;;;;;
    opt = True
    opt@nval_crit = 12  ; require at least 12 values for the "avg" is calculated.
    v1Mon = calculate_monthly_values (v1, "avg", 0,opt)
    v2Mon = calculate_monthly_values (v2, "avg", 0,opt)
    v1Mon!0 = "time"
    v2Mon!0 = "time"
   ;utc_date1 = cd_calendar(v2Mon&time, -2)
   ;utc_date2 = cd_calendar(v1Mon&time, -2)
   ;print(utc_date1+ " " +utc_date2)
   ;exit
    utc_date  = cd_calendar(v2Mon&time, 0)
    month     = tointeger(utc_date(:,1))
    ids = 0 
    do i = 1, dimsizes(month)
      if  (freq .eq. "daily") then
        ide = ids + mon_days(month(i-1)-1)  
      else if (freq .eq. "6hourly") then
        ide = ids + mon_days(month(i-1)-1)*4 
      else
        print("Unsupported FREQ for SAC = "+freq)
        exit
      end if 
      end if 
      print(ids +  " " +ide)
      xv1(ids:ide-1,:,:) = xv1(ids:ide-1,:,:) - conform(xv1(ids:ide-1,:,:),v1Mon(i-1,:,:),(/1,2/))
      xv2(ids:ide-1,:,:) = xv2(ids:ide-1,:,:) - conform(xv2(ids:ide-1,:,:),v2Mon(i-1,:,:),(/1,2/))
      ids = ide 
    end do 
    delete([/utc_date,month,v1Mon,v2Mon,opt/])
   ;printMinMax(xv1,False)
   ;printMinMax(xv2,False)

    ;;;calculate the correlation;;;;;;;; 
    do j = 0, dim0-1 

      ;;;calculate the correlation;;;;;;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; https://www.ncl.ucar.edu/Document/Functions/Contributed/pattern_cor.shtml ;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      gridarea = tofloat(area_global_rectilinear_grid(lat, lon, False))
      a = closest_val(region_lobnd(j),lat)
      b = closest_val(region_hibnd(j),lat)
      gridarea@_FillValue = 9.e36
      avgarea = sum(gridarea(a:b,:)) / (num(.not. ismissing(gridarea(a:b,:))) * 1.0)

      v11  = xv1(:,a:b,:)
      v21  = xv2(:,a:b,:)
      wgt  = gridarea(a:b,:)

      v11  = v11 * conform(v11,wgt,(/1,2/)) / avgarea
      v21  = v21 * conform(v21,wgt,(/1,2/)) / avgarea

      corr(:,j) = pattern_cor(v11, v21, 1.0, 1)
     ;print(corr(:,j))
 
      delete([/v11,v21,wgt,gridarea,a,b,avgarea/])
    end do 

    corr!0 = "time"
    corr!1 = "num_region"
    corr&num_region = region_name
    corr@long_name = "Spatial anomaly uncentered correlation"
    corr@units = "unitless"
    corr@_FillValue = 9.e+36
    fout->corr = corr
    delete([/xv1,xv2,corr/])

  end do
  delete([/fout,fname,v1,v2/])

end
exit

