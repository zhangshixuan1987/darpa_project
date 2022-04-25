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
     ModelOutRoot = "/pic/projects/uq_climate/zhan391/Nudging_analysis/data_for_plot/5day_Jan/"
  end if
  
  Filename = "CLIM_FREE_5day_linear_interp.nc"
  TimeUnit = "Hours since 2010-01-01 00:00:00"

 ;;;;;;;;;;select the regions to calculate the rmse;;;;;;;;;;;;;
  Regions      = (/"SEP"/)
  nregs        = dimsizes(Regions)
  lats         = -25.    
  late         =  -5.     
  lons         = -95 + 360.0 
  lone         = -75 + 360.0
  plev         = 700

 ;;;;open netcdf file and save data for the pfigures;;;;;;;
 setfileoption("nc", "Format",  "NetCDF4")
 out_file_name = "./5day_variation_"+Regions+"_mean_U_T_Q_"+plev+"hPa.nc"
 system("rm " + out_file_name)
 fout = addfile(out_file_name,"c")

 ;;;;;;variables to be plotted;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  Varname      = (/"U","T","Q"/) 
  nvars        = dimsizes(Varname)  

 ;;;;;;;begin to work with the simulations;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  File0      = addfile(ModelOutRoot+Filename,"r")
  area       = File0->area
  lat        = File0->lat
  lon        = File0->lon
  hyai       = File0->hyai
  hybi       = File0->hybi
  p0         = File0->P0
  ps         = File0->PS
  lev        = File0->lev

 ;;;find the points for the regional mean;;;;;
  indcol     = ind(lat.ge.lats.and.lat.le.late .and. \
                   lon.ge.lons.and.lon.le.lone)

  time       = File0->time
  ;time_new   = cd_convert(time,TimeUnit)
  fout->time = time ;_new

 do iv = 0, nvars -1
  varName    = Varname(iv)+"_org"

  printVarSummary(File0->$varName$)
  varName    = Varname(iv)+"_org"
  var3d      = File0->$varName$(:,{plev},:)

  varName    = Varname(iv)+"_int_6h"
  var6h      = File0->$varName$(:,{plev},:)

  varName    = Varname(iv)+"_int_3h"
  var3h      = File0->$varName$(:,{plev},:)

  varName    = Varname(iv)+"_int_1h"
  var1h      = File0->$varName$(:,{plev},:)

  vnorm      = dim_avg_wgt( var3d(:,indcol), area(indcol), 0 )
  vnm6h      = dim_avg_wgt( var6h(:,indcol), area(indcol), 0 )
  vnm3h      = dim_avg_wgt( var3h(:,indcol), area(indcol), 0 )
  vnm1h      = dim_avg_wgt( var1h(:,indcol), area(indcol), 0 )
 
  vnorm!0         = "time"
  vnorm&time      = time
  outname         = varName+"_org"
  fout->$outname$ = vnorm

  vnm6h!0         = "time"
  vnm6h&time      = time
  outname         = varName+"_int_6h"
  fout->$outname$ = vnm6h

  vnm3h!0         = "time"
  vnm3h&time      = time
  outname         = varName+"_int_3h"
  fout->$outname$ = vnm3h

  vnm1h!0         = "time"
  vnm1h&time      = time
  outname         = varName+"_int_1h"
  fout->$outname$ = vnm1h

  delete([/var3d,var6h,var3h,var1h/])
  delete([/vnorm,vnm6h,vnm3h,vnm1h/])

end do 

end
