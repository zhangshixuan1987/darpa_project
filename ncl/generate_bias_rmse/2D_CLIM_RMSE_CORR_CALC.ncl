load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

undef("nice_string")
  
function nice_string(var)

begin

  string_len = sizeof(stringtochar(var)) - 1

  if (string_len .lt. 25) then
      ilen = 16
      do it = 0, ilen - string_len
         var = var + " "
      end do
  end if

  return(var)

end

;;;;;;;;;;;;;;;;
; main program ;
;;;;;;;;;;;;;;;;

begin

  model     = getenv("MODEL_NAME")
  obs       = getenv("OBS_NAME")
  Input     = getenv("INPUT")
  var       = getenv("VAR")
  vname     = var

  yst       = toint(getenv("yst"))
  yed       = toint(getenv("yed"))

  modeldir  = Input+"/"+model+"/monthly/"
  flm       = systemfunc("ls "+modeldir+"*_h0.nc")
  fm        = addfile(flm, "r")
  modtime   = cd_calendar(fm->time, -1)
  modind    = ind(modtime.ge.yst.and.modtime.le.yed)

  obsdir    = Input+"/OBS/"+obs+"/monthly/"
  flo       = systemfunc("ls "+obsdir+"*.nc")
  fo        = addfile(flo, "r")
  obstime   = cd_calendar(fo->time, -1)
  obsind    = ind(obstime.ge.yst.and.obstime.le.yed)

 ;print (modtime(modind) + " " + obstime(obsind))
  if (var .eq. "NETCF") then
      vmod  = fm->LWCF(modind,:,:)
      vmod  = vmod + fm->SWCF(modind,:,:)
      if(isfilevar(fo,"LWCF")) then
        vobs  = fo->LWCF(obsind,:,:)
        vobs  = vobs + fo->SWCF(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
  else if (var .eq. "FNET") then
      vmod  = fm->FSNT(modind,:,:)
      vmod  = vmod - fm->FLNT(modind,:,:)
      if(isfilevar(fo,"FLNTOA")) then 
        vobs  = fo->FSNTOA(obsind,:,:)
        vobs  = vobs - fo->FLNTOA(obsind,:,:)
      else 
        vobs  = vmod
        vobs  = -99999
      end if 
  else if (var .eq. "FLNTC") then
      vmod  = fm->FLNTC(modind,:,:)
      if(isfilevar(fo,"FLNTOAC")) then
        vobs  = fo->FLNTOAC(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
  else if (var .eq. "FLNT") then
      vmod  = fm->FLNT(modind,:,:)
      if(isfilevar(fo,"FLNTOA")) then
        vobs  = fo->FLNTOA(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
  else if (var .eq. "FSNT") then
      vmod  = fm->FSNT(modind,:,:)
      if(isfilevar(fo,"FSNTOA")) then
        vobs  = fo->FSNTOA(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
  else if (var .eq. "PRECT") then
      vmod  = fm->PRECL(modind,:,:) 
      vmod  = vmod + fm->PRECC(modind,:,:) 
      vmod  = vmod * 24.0 * 3600.0 * 1000.0 
      if(isfilevar(fo,var)) then
        vobs  = fo->$var$(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
      vmod@units = "mm/day"
      vobs@units = "mm/day"
  else if (var .eq. "STRESS_MAG") then
      vmod  = fm->TAUX(modind,:,:)
      vmod  = sqrt(vmod^2 + (fm->TAUY(modind,:,:))^2)
      if(isfilevar(fo,"TAUX")) then
        vobs  = fo->TAUX(obsind,:,:)
        vobs  = sqrt(vobs^2 + (fo->TAUY(obsind,:,:))^2)
      else
        vobs  = vmod
        vobs  = -99999
      end if
  else if (var .eq. "U200")  then 
      xtmp  = vinth2p(fm->U,fm->hyam,fm->hybm,200.0,fm->PS,1,fm->P0/100.0,1,False)
      vmod  = xtmp(modind,0,:,:)  
      if(isfilevar(fo,"U")) then
        vobs  = fo->U(obsind,{200},:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
      vmod@units = "m/s"
      vobs@units = "m/s"
     ;printMinMax(vmod,False)
     ;printMinMax(vobs,False)
      delete([/xtmp/])
 
  else if (var .eq. "U500")  then
      xtmp  = vinth2p(fm->U,fm->hyam,fm->hybm,500.0,fm->PS,1,fm->P0/100.0,1,False)
      vmod  = xtmp(modind,0,:,:)
      if(isfilevar(fo,"U")) then
        vobs  = fo->U(obsind,{500},:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
      vmod@units = "m/s"
      vobs@units = "m/s"
     ;printMinMax(vmod,False)
     ;printMinMax(vobs,False)
      delete([/xtmp/])

  else if (var .eq. "U850")  then
      xtmp  = vinth2p(fm->U,fm->hyam,fm->hybm,850.0,fm->PS,1,fm->P0/100.0,1,False)
      vmod  = xtmp(modind,0,:,:)
      if(isfilevar(fo,"U")) then
        vobs  = fo->U(obsind,{850},:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
     ;printMinMax(vmod,False)
     ;printMinMax(vobs,False)
      delete([/xtmp/])
      vmod@units = "m/s"
      vobs@units = "m/s"
  else if (var .eq. "Z500")  then
      xtmp  = vinth2p(fm->Z3,fm->hyam,fm->hybm,500.0,fm->PS,1,fm->P0/100.0,1,False)
      vmod  = xtmp(modind,0,:,:)
      if(isfilevar(fo,"Z3")) then
        vobs  = fo->Z3(obsind,{500},:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
      vobs = vobs / 9.8 
      vobs@units = "gpm"
      vmod@units = "gpm"
     ;printMinMax(vmod,False)
     ;printMinMax(vobs,False)
      delete([/xtmp/])

  else if (var .eq. "LWP")  then
      vmod  = fm->TGCLDLWP(modind,:,:)
      if(isfilevar(fo,"TGCLDLWP")) then
        vobs  = fo->TGCLDLWP(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
      vmod = vmod * 1000.0
      vobs = vobs * 1000.0
      vmod@units = "g/m2"
      vobs@units = "g/m2"
     ;printMinMax(vmod,False)
     ;printMinMax(vobs,False)

  else if (var .eq. "IWP")  then
      vmod  = fm->TGCLDIWP(modind,:,:)
      if(isfilevar(fo,"TGCLDIWP")) then
        vobs  = fo->TGCLDIWP(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
      vmod = vmod * 1000.0
      vobs = vobs * 1000.0
      vmod@units = "g/m2"
      vobs@units = "g/m2"
     ;printMinMax(vmod,False)
     ;printMinMax(vobs,False)

  else
      vmod  = fm->$var$(modind,:,:)
      if(isfilevar(fo,var)) then
        vobs  = fo->$var$(obsind,:,:)
      else
        vobs  = vmod
        vobs  = -99999
      end if
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 
  end if 

  vmod@_FillValue = -99999
  vobs@_FillValue = -99999

  if (var .eq. "PRECC" .or. var .eq. "PRECL") then
    vmod = vmod * 24.0 * 3600.0 * 1000.0
    vobs = vobs * 24.0 * 3600.0 * 1000.0
    vmod@units = "mm/day"
    vobs@units = "mm/day"
  end if 

  if (var .eq. "SHFLX" .or. var .eq. "LHFLX") then
    if (obs.eq."ERA5") then 
      vobs = vobs * -1.0 
    end if 
  end if 

  if(var.eq."AODVIS") then 
    vmod@units = "1"
    vobs@units = "1"
  end if 

  if (var .eq. "PSL") then
    vmod = vmod / 100.0
    vobs = vobs / 100.0
    vmod@units = "hPa"
    vobs@units = "hPa"
  end if

 ;printMinMax(vmod,False)
 ;printMinMax(vobs,False)

 ;mask fill values 
  if (.not.all(ismissing(vobs))) then 
    vmod = where (ismissing(vobs), vmod@_FillValue, vmod)
    vobs = where (ismissing(vmod), vobs@_FillValue, vobs)
  end if 

 ;calculate time average
  vmmod = dim_avg_n_Wrap(vmod,0)
  vmobs = dim_avg_n_Wrap(vobs,0)
  vmdif = vmmod
  vmdif = vmmod - vmobs
  vm1d  = ndtooned(vmmod)
  vo1d  = ndtooned(vmobs)
  vm1d@_FillValue = vmod@_FillValue
  vo1d@_FillValue = vobs@_FillValue
  varunt = vmod@units

 ;process metrics
  metrics    = (/"Variable", "Observation", "Mean(obs)", "RMS(obs)", "Mean(model)", "RMS(model)", \
                 "Bias(m-o)", "RMSE(m-o)", "PCORR(m-o)"/)

  nmetric    = dimsizes(metrics)
  vmetric    = new(nmetric-2,double) 

  lat        = fm->lat
  rad        = 4.0*atan(1.0)/180.0
  clat       = cos(lat*rad)

  vmetric(0) = wgt_areaave(vmobs, clat, 1.0, 0)
  vmetric(1) = dim_stddev(vo1d)
  vmetric(2) = wgt_areaave(vmmod, clat, 1.0, 0)
  vmetric(3) = dim_stddev(vm1d)
  vmetric(4) = wgt_areaave(vmdif, clat, 1.0, 0)
  vmetric(5) = wgt_arearmse(vmmod, vmobs, clat, 1.0, 0)
  vmetric(6) = pattern_cor(vmmod, vmobs,clat, 1)

  if (all(ismissing(vmobs)))then 
    vmetric(0) = -999.0
    vmetric(1) = -999.0
    vmetric(4) = -999.0
    vmetric(5) = -999.0
    vmetric(6) = -999.0
  end if 

  delete([/modtime,modind,flm,fm/])

  delete([/vmod,vobs,vmmod,vmobs,vmdif,vm1d,vo1d/])

;;;;;;;;;;
; Output ;
;;;;;;;;;;
  header = ""
  str    = ""
  do i = 0, nmetric-1
   header = header + str_insert(metrics(i)," ", 12)
   if(i.eq.0)then 
     tmp    = var + "("+varunt+")"
     str    = str + str_insert(tmp," ",18)
   else if (i.eq.1)then
     str    = str + str_insert(obs," ",10)
   else
     str    = str + sprintf("%10.3f",vmetric(i-2))
   end if 
   end if 
  end do 

  fname   = "./output/"+model+"_clim_output.txt"
  if (fileexists(fname)) then
    write_table(fname, "a", [/str/], "%s")
  else
    asciiwrite(fname, header)
    write_table(fname, "a", [/str/], "%s")
  end if 

end
