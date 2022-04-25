load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  FREQ    = "monthly"
  yy1     = 2009
  yy2     = 2011
  year    = yy1+"-"+yy2

  model_name = "CERES_EBAF"
  model_path = "/compyfs/zhan391/acme_init/Observations/"+model_name
  yymm       = "monthly_2001-2018" 
  resolution = "1x1"
  obsfile    = addfile(model_path + "/"+model_name+"_Ed4.1_"+yymm+"_"+resolution+".nc","r")
  
  setfileoption("nc","Format","NetCDF4Classic")
  out_path   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/"+model_name+"/"+FREQ

  system("/bin/mkdir -p " + out_path)
  out_name   = year+".nc" 
  system("/bin/rm -f " + out_path+"/"+out_name)
  outfile    = addfile(out_path+"/"+out_name,"cw")

  utc_date = cd_calendar(obsfile->time, 0)
  obsyr    =  tointeger(utc_date(:,0)) 
  indsel   = ind(obsyr.ge.yy1.and.obsyr.le.yy2) 
 ;print (obsyr(indsel))
 ;delete([/utc_date,obsyr/])

  varlist    = (/"CLDTOT","SOLIN","FLUT","FLUTC","FSUTOA","FSUTOAC", \
                 "FLNTOA","FLNTOAC","FSNTOA","FSNTOAC","FSNS","FSNSC", \
                 "FLNS","FLNSC","FSUS","FSUSC","FSDS","FSDSC", \
                 "FLUS","FLUSC","FLDS","FLDSC", \
                 "SWCF","LWCF","SWCF_SRF", "LWCF_SRF",\
                 "RESTOA","ALBEDO","ALBEDOC","ALBEDO_SRF", \
                 "NETCF", "NETCF_SRF", "NET_RAD_FLUX_SRF"   \
                /) 
  nvars      = dimsizes(varlist) 

  outfile->time  = obsfile->time(indsel)
  outfile->lat   = obsfile->lat
  outfile->lon   = obsfile->lon
  outfile->gw    = obsfile->gw
  outfile->area  = obsfile->area
  outfile->lat_bnds = obsfile->lat_bnds
  outfile->lon_bnds = obsfile->lon_bnds

  do iv = 0,nvars-1,1

    varnam = varlist(iv)

    if(varnam.eq."CLDTOT")then
       var   = obsfile->cldarea_total_daynight_mon(indsel,:,:)
       outfile->$varnam$ = var 
       delete(var)
    end if
 
    ;incoming solar radiation
    if(varnam.eq."SOLIN")then
       var   = obsfile->solar_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

    ;;TOA upward LW flux
    if(varnam.eq."FLUT")then
       var   = obsfile->toa_lw_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if
    
   ;TOA upward LW flux (clear sky)
    if(varnam.eq."FLUTC")then
       var   = obsfile->toa_lw_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;TOA upward SW flux 
    if(varnam.eq."FSUTOA")then
       var   = obsfile->toa_sw_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;TOA upward SW flux (clear sky)
    if(varnam.eq."FSUTOAC")then
       var   = obsfile->toa_sw_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if
    
   ;TOA net SW flux	
    if(varnam.eq."FSNTOA")then
       var   = obsfile->solar_mon(indsel,:,:)
       var   = obsfile->solar_mon(indsel,:,:) -   \ 
               obsfile->toa_sw_all_mon(indsel,:,:)
       var@comment = "TOA net SW flux (all-sky)"
       outfile->$varnam$ = var
       delete(var)
    end if

   ;TOA net SW flux (clear-sky)
    if(varnam.eq."FSNTOAC")then
       var    = obsfile->solar_mon(indsel,:,:)
       var    = obsfile->solar_mon(indsel,:,:) -   \
                obsfile->toa_sw_clr_t_mon(indsel,:,:)
       var@comment = "TOA net SW flux (clear-sky)"
       outfile->$varnam$ = var
       delete([/var/])
    end if

   ;TOA Net LW Flux
    if(varnam.eq."FLNTOA")then
       var   = obsfile->toa_lw_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if    

   ;TOA Net LW Flux (clear sky)
    if(varnam.eq."FLNTOAC")then
       var   = obsfile->toa_lw_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Longwave Heat Flux (surface)
    if(varnam.eq."FLNS")then
       var   = obsfile->sfc_net_lw_all_mon(indsel,:,:)
       var   = var*-1.0 
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Longwave Heat Flux (surface, clear sky)
    if(varnam.eq."FLNSC")then
       var   = obsfile->sfc_net_lw_clr_t_mon(indsel,:,:)
       var   = var*-1.0
       outfile->$varnam$ = var
       delete(var)
    end if

    ;Shortwave Heat Flux (surface) 
    if(varnam.eq."FSNS")then
       var   = obsfile->sfc_net_sw_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

    ;Shortwave Heat Flux (surface, clear sky)
    if(varnam.eq."FSNSC")then
       var   = obsfile->sfc_net_sw_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if
 
   ;TOA shortwave cloud forcing
    if(varnam.eq."SWCF")then
       var   = obsfile->toa_cre_sw_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface longwave cloud forcing
    if(varnam.eq."LWCF")then
       var   = obsfile->toa_cre_lw_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface shortwave cloud forcing
    if(varnam.eq."SWCF_SRF")then
       var   = obsfile->sfc_cre_net_sw_mon(indsel,:,:)
       var@standard_name = "Short-wave cloud forcing"
       var@comment       = "Calculated as all-sky flux minus clear-sky (for total region) flux."
       outfile->$varnam$ = var
       delete(var)
    end if

   ;TOA longwave cloud forcing
    if(varnam.eq."LWCF_SRF")then
       var   = obsfile->sfc_cre_net_lw_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

    ;Surface net radiative forcing 
    if(varnam.eq."NETCF_SRF")then
       var   = obsfile->sfc_net_sw_all_mon(indsel,:,:)
       var   = obsfile->sfc_net_sw_all_mon(indsel,:,:) -   \
               obsfile->sfc_net_sw_clr_t_mon(indsel,:,:) + \
               obsfile->sfc_net_lw_all_mon(indsel,:,:) -   \
               obsfile->sfc_net_lw_clr_t_mon(indsel,:,:)  
       var@standard_name = "NETCF_SRF"
       var@comment       = "Net cloud forcing at surface"
       outfile->$varnam$ = var
       delete(var)
    end if

    ;TOA net radiative forcing 
    if(varnam.eq."NETCF")then
       var   = obsfile->toa_cre_sw_mon(indsel,:,:)
       var   = obsfile->toa_cre_sw_mon(indsel,:,:) +   \
               obsfile->toa_cre_lw_mon(indsel,:,:)
       var@standard_name = "NETCF"
       var@comment       = "Net cloud forcing at TOA"
       outfile->$varnam$ = var
       delete(var)
    end if

    ;TOA net radiative flux 
    if(varnam.eq."RESTOA")then
       var   = obsfile->toa_net_all_mon(indsel,:,:)
       var@standard_name = "RESTOA"
       var@comment       = "The net radiative flux at top of atmosphere"
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface upwelling SW radiation
    if(varnam.eq."FSUS")then
       var   = obsfile->sfc_sw_up_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface upwelling SW radiation (clear sky)
    if(varnam.eq."FSUSC")then
       var   = obsfile->sfc_sw_up_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface downwelling SW radiation 
    if(varnam.eq."FSDS")then
       var   = obsfile->sfc_sw_down_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if
   
   ;Surface downwelling SW radiation (clear sky)
    if(varnam.eq."FSDSC")then
       var   = obsfile->sfc_sw_down_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface upwelling LW radiation
    if(varnam.eq."FLUS")then
       var   = obsfile->sfc_lw_up_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface upwelling LW radiation (clear sky)
    if(varnam.eq."FLUSC")then
       var   = obsfile->sfc_lw_up_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface downwelling LW radiation
    if(varnam.eq."FLDS")then
       var   = obsfile->sfc_lw_down_all_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if

   ;Surface downwelling LW radiation (clear sky)
    if(varnam.eq."FLDSC")then
       var   = obsfile->sfc_lw_down_clr_t_mon(indsel,:,:)
       outfile->$varnam$ = var
       delete(var)
    end if
    
   ;NET radiation flux at surface 
    if(varnam.eq."NET_RAD_FLUX_SRF")then
       var   = obsfile->sfc_sw_down_all_mon(indsel,:,:)
       var   = obsfile->sfc_sw_down_all_mon(indsel,:,:) - \
               obsfile->sfc_sw_up_all_mon(indsel,:,:) + \
               obsfile->sfc_lw_down_all_mon(indsel,:,:) - \
               obsfile->sfc_lw_up_all_mon(indsel,:,:) 
       var@standard_name = "Net radiative fluxes at surface"
       var@comment       = "Calculaed as sfc_sw_down_all_mon - sfc_sw_up_all_mon + sfc_lw_down_all_mon - sfc_lw_up_all_mon"
       outfile->$varnam$ = var
       delete(var)
    end if
       
    ;TOA (top-of-atmosphere) albedo 
    if(varnam.eq."ALBEDO")then
       tmp   = obsfile->solar_mon(indsel,:,:)
       tmp   = where(obsfile->solar_mon(indsel,:,:).eq.0,tmp@_FillValue,tmp)
       var   = obsfile->solar_mon(indsel,:,:)
       var   = obsfile->toa_sw_all_mon(indsel,:,:)/tmp
       var@units = "dimensionless"
       var@standard_name = "TOA (top-of-atmosphere) albedo"
       var@comment       = "Calculated as toa_sw_all_mon /solar_mon" 
       outfile->$varnam$ = var
       delete([/var,tmp/])
    end if

    ;TOA (top-of-atmosphere) albedo (clear sky)
    if(varnam.eq."ALBEDOC")then
       tmp   = obsfile->solar_mon(indsel,:,:)
       tmp   = where(obsfile->solar_mon(indsel,:,:).eq.0,tmp@_FillValue,tmp)
       var   = obsfile->solar_mon(indsel,:,:)
       var   = obsfile->toa_sw_clr_t_mon(indsel,:,:)/tmp
       var@units = "dimensionless"
       var@standard_name = "TOA (top-of-atmosphere) albedo for clear-sky "
       var@comment       = "Calculated as toa_sw_clr_t_mon /solar_mon"
       outfile->$varnam$ = var
       delete([/var,tmp/])
    end if

    ;Surface albedo 
    if(varnam.eq."ALBEDO_SRF")then
       tmp   = obsfile->solar_mon(indsel,:,:)
       tmp   = where(obsfile->solar_mon(indsel,:,:).eq.0,tmp@_FillValue,tmp)
       var   = obsfile->solar_mon(indsel,:,:)
       var   = obsfile->sfc_sw_up_all_mon(indsel,:,:)/tmp
       var@units = "dimensionless"
       var@standard_name = "Surface albedo"
       var@comment       = "Calculated as sfc_sw_up_all_mon / solar_mon" 
       outfile->$varnam$ = var
       delete([/var,tmp/])
    end if

  end do 
  delete([/indsel/])
  delete(obsfile)
  delete(outfile)

end
exit
