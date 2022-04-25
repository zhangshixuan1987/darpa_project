;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;This script used to calculate and plot the zonal mean variables from CAM;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;The terms zonal and meridional are used to describe directions on a globe;;;;;;;
;;;;;;;Zonal means "along a latitudinal circle" or "in the west–east direction";;;;;;;;
;;;;;;;while meridional means "along a longitudinal circle" (a.k.a. meridian) ;;;;;;;;;
;;;;;;;or "in the north–south direction" [2];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  Obsnam       = "ERA5"
  ModelOutRoot = "/compyfs/zhan391/darpa_scratch/post_process/data/"
  ObsOutRoot   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/" + Obsnam+ "/"

  year         = 2010
  season       = "DJF"
  istr         = 200912
  iend         = 201002
  freq         = "monthly"

  ;;;;;;;;;;select the regions to calculate the rmse;;;;;;;;;;;;;
  Casdir      = (/"CLIM","NDGUV","NDGT","NDGQ","NDGUVT","NDGUVQ","NDGUVTQ",\
                  "NDGUVT_tau1h","NDGUVT_tau3h","NDGUVT_tau12h","NDGUVT_tau24h"/)
  Groups      = Casdir
  ngrps       = dimsizes(Groups)

  ;;;;;;variables to be plotted;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  VarList      = (/"U","V","T","Q","RELHUM","CLOUD"/)
  VnmList      = (/"Zonal wind","Meridional wind", "Temperature", \
                   "Specific humidity", "Relative humidity", "Cloud fraction"/)
  UnitList     = (/"m s~S~-1~N~","m s~S~-1~N~","K","g kg~S~-1~N~","unitless","fraction"/)
  nvars        = dimsizes(VarList)

do iv = 0,nvars-1, 1

 Varname  = VarList(iv)
 Varunt   = UnitList(iv)
 Vnmstr   = VnmList(iv)

 do jj = 0,ngrps-1,1

  ;;;;;;;begin to work with the simulations;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  fl0 = ObsOutRoot + freq + "/" + "2009-2010.nc"
  f0  = addfiles(fl0,"r")
  fl1 = ModelOutRoot+ Casdir(jj)+"/"+freq+"/" + "2010_h0.nc"
  f1  = addfiles(fl1,"r")
 ;print(fl0)
 ;print(fl1)

 ;calculate the global/regional mean values
  latrg    = f1[0]->lat
  rad      = 4.*atan(1.)/180.    ;
  cost     = cos(latrg*rad)       ; cosine weights

  obstim = cd_calendar(f0[:]->time,-1)
  modtim = cd_calendar(f1[:]->time,-1)
  indobs = ind(obstim.ge.istr.and.obstim.le.iend)
  indmod = ind(modtim.ge.istr.and.modtim.le.iend)
  print(obstim(indobs) + "  "+modtim(indmod))

  
  lat    = f0[0]->lat
  lon    = f1[0]->lon
  lev    = f0[0]->lev
  P0mb   = 1000.0
  xtmp   = f0[:]->$Varname$
  ytmp   = vinth2p(f1[:]->$Varname$,f1[0]->hyam,f1[0]->hybm,lev,f1[:]->PS,1,P0mb,1,False)

  x11    = xtmp(indobs,:,:,:)
  y11    = ytmp(indmod,:,:,:)

  y11    = where(ismissing(x11),y11@_FillValue,y11)
  x11    = where(ismissing(y11),x11@_FillValue,x11)

  delete([/obstim,modtim,indobs,indmod,xtmp,ytmp/])

  x11&lev@units = "hPa"
  y11&lev@units = "hPa"

  if(Varname.eq."RELHUM") then
   x11 = x11/100.0
   y11 = y11/100.0
  end if

  if(Varname.eq."Q") then
   x11 = x11*1000.0
   y11 = y11*1000.0
  end if

  printVarSummary(x11)
  printVarSummary(y11)
  pncre0300 = dim_avg_n_Wrap(dim_avg_n_Wrap(x11,0),2)
  wncre0300 = dim_avg_n_Wrap(dim_avg_n_Wrap(y11,0),2)
 ;printVarSummary(pncre0300)

  wncredf1  = wncre0300
  wncredf1  = wncre0300 - pncre0300
  wncredf2  = wncre0300

  pncre0300@long_name = VnmList(0)
  pncre0300@units     = UnitList(0)

  wncredf1@long_name = VnmList(iv)
  wncredf1@units     = UnitList(iv)

  wncredf2@long_name = VarList(iv) + "   " + Groups(jj) + " - " + Groups(0)
  wncredf2@units     = UnitList(iv)

  mskxx     = pncre0300
  mskxx     = where(pncre0300.ne.0.0,pncre0300,32766)
  mskxx@_FillValue = 32766
  wncredf2  = (wncre0300 - mskxx)*100/mskxx
  wncredf2  = where(ismissing(wncredf2),0.0,wncredf2)
  delete(mskxx)

  ;rad     = 4.*atan(1.)/180.    ;
  ;cost    = cos(lat*rad)       ; cosine weights
  ;mean1x  = wgt_areaave(pncre0300,cost,1.0,0)
  ;mean2x  = wgt_areaave(wncredf1,cost,1.0,0)
  ;mean3x  = wgt_areaave(wncredf2,cost,1.0,0)
  ;mean1   = sprintf("%5.2f", mean1x)
  ;mean2   = sprintf("%5.2f", mean2x)
  ;mean3   = sprintf("%5.2f", mean3x) ;+ "%"



  outdir = "./data/"
  system("if ! test -d " + outdir +" ; then mkdir -p " + outdir + " ; fi")
  fno    = outdir+ VarList(iv) + "_" + Groups(jj) + ".nc"
  system("rm -f " + fno)

  print(" ")
  print("output : " + fno)
  print(" ")

  flo = addfile(fno,"c")

  vna = VarList(iv) + "_" + Obsnam
  vnb = VarList(iv) + "_" + Groups(jj)
  vnc = "d" + VarList(iv)

  flo->$vna$=pncre0300
  flo->$vnb$=wncredf1
  flo->$vnc$=wncredf2

  delete(flo)
  delete([/x11,y11,wncre0300/])

 end do 

end do 

end
