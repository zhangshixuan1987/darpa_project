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

  ldatalocal = True
  ldatalocal = True

  if (ldatalocal) then
     ModelOutRoot = "../Model_DATA/"
  else
     ModelOutRoot = "/pic/projects/uq_climate/zhan391/Nudging_analysis/data_for_plot/5day_jan/"
  end if
  
  Filename = "CLIM_FREE_5day.nc"
  TimeUnit = "Hours since 2010-01-01 00:00:00"

 ;;;;open netcdf file and save data for the pfigures;;;;;;;
 setfileoption("nc", "Format",  "NetCDF4")
 out_file_name = ModelOutRoot+"CLIM_FREE_5day_linear_interp.nc"
 system("rm " + out_file_name)
 fout = addfile(out_file_name,"cw")

 ;;;;;;variables to be plotted;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  Varname      = (/"U","T","Q"/) 
  nvars        = dimsizes(Varname)  
 ;;;;;;;begin to work with the simulations;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  File        = addfile(ModelOutRoot+Filename,"r")
  time        = File->time
  timplt      = cd_convert(time, TimeUnit)
  timplt!0    = "time"
  timplt&time = timplt
  printVarSummary(timplt)
 ;print(timplt)

  ps          = File->PS
  ps!0        = "time"
  ps&time     = timplt

  fout->hyai  = File->hyai
  fout->hybi  = File->hybi
  fout->lat   = File->lat
  fout->lon   = File->lon
  fout->P0    = File->P0
  fout->area  = File->area 
  fout->time  = timplt
  fout->PS    = ps

 do iv = 0, nvars -1

  varName    = Varname(iv)
  var3d      = File->$varName$
  var6h      = linint1_n_Wrap (time(::12), var3d(::12,:,:), False, time, 0, 0)
  var3h      = linint1_n_Wrap (time(::6),  var3d(::6,:,:),  False, time, 0, 0)
  var1h      = linint1_n_Wrap (time(::2),  var3d(::2,:,:),  False, time, 0, 0)

  var3d!0    = "time"
  var3d&time = timplt

  copy_VarCoords(var3d,var6h)
  copy_VarCoords(var3d,var3h)
  copy_VarCoords(var3d,var1h)
  
  outname         = varName+"_org"
  fout->$outname$ = var3d

  outname         = varName+"_int_6h"
  fout->$outname$ = var6h
 
  outname         = varName+"_int_3h"
  fout->$outname$ = var3h

  outname         = varName+"_int_1h"
  fout->$outname$ = var1h

  delete([/var3d,var6h,var3h,var1h/])

 end do 

end
