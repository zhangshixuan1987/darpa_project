load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  FREQ       = "3hourly"
  model_name = "ERA5"
  resolution = "1x1"
  yy1 = 2009
  yy2 = 2009

  model_path = "/compyfs/zhan391/acme_init/Observations/"+model_name
  out_path   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/"+model_name+"/"+FREQ
  system("/bin/mkdir -p " + out_path)

  varlist  = (/"PBLH","PRECC","PRECL","PRECT","PRECST","TREFHT","TS", "SST", \
               "PS", "LHFLX", "SHFLX", "TGCLDLWP","TGCLDIWP", \ ; "LANDFRAC","CIN", \
               "TAUX", "TAUY", "U10", "V10", \
               "CLDHGH", "CLDLOW", "CLDTOT", "PHIS", \ 
               "SOLIN","FLUT","FLUTC","FSUTOA","FSUTOAC", \
               "FLNTOA","FLNTOAC","FSNTOA","FSNTOAC","FSNS","FSNSC", \
               "FLNS","FLNSC","FSUS","FSUSC","FSDS","FSDSC", \
               "FLUS","FLUSC","FLDS","FLDSC", \
               "SWCF","LWCF","SWCF_SRF", "LWCF_SRF",\
               "RESTOA","ALBEDO","ALBEDOC","ALBEDO_SRF", \
               "NETCF", "NETCF_SRF", "NET_RAD_FLUX_SRF","NET_FLUX_SRF" \
              /) 
  nvars    = dimsizes(varlist) 

  do yy = yy1,yy2

   file_in = model_path+"/"+model_name+ "_siglev_"+FREQ+"_" + resolution+ "_" + yy+".nc"
   obsfile = addfiles(file_in,"r")
  
   fcord   = model_path+"/"+"coord.nc"
   ff      = addfile(fcord,"r") 

   time     = obsfile[:]->time
   lat      = ff->lat
   lon      = ff->lon
   lat_bnds = ff->lat_bnds
   lon_bnds = ff->lon_bnds
   gw       = ff->gw

   time!0   = "time"
   time&time= time
   lat!0    = "lat"
   lat&lat  = lat
   lon!0    = "lon"
   lon&lon  = lon

   lat_bnds!0    = "lat"
   lat_bnds&lat  = lat
   lon_bnds!0    = "lon"
   lon_bnds&lon  = lon

   gw!0     = "lat"
   gw&lat   = lat

   do iv = 0,nvars-1,1

    varnam = varlist(iv)

    setfileoption("nc","Format","NetCDF4Classic")
    out_name   = varnam+"_"+yy+".nc"
    system("/bin/rm -f " + out_path+"/"+out_name)
    outfile    = addfile(out_path+"/"+out_name,"cw")

    outfile->time     = time
    outfile->lat      = lat
    outfile->lon      = lon
    outfile->gw       = gw

    if(varnam.eq."LANDFRAC") then
       var   = obsfile[:]->lsm
    end if

    if(varnam.eq."CLDTOT")then
       var   = obsfile[:]->tcc
    end if
 
    if(varnam.eq."CLDLOW")then
       var   = obsfile[:]->lcc
    end if

    if(varnam.eq."CLDHGH")then
       var   = obsfile[:]->hcc
    end if

    if(varnam.eq."CLDMED")then
       var   = obsfile[:]->mcc
    end if

    if(varnam.eq."U10")then
       var   = obsfile[:]->u10
    end if

    if(varnam.eq."V10")then
       var   = obsfile[:]->v10
    end if

    if(varnam.eq."S10")then
       var   = obsfile[:]->si10
    end if

    if(varnam.eq."TS")then
       var   = obsfile[:]->skt
    end if

    if(varnam.eq."SST")then
       var   = obsfile[:]->sst
    end if

    if(varnam.eq."PSL")then
       var   = obsfile[:]->msl
    end if

    if(varnam.eq."PS")then
       var   = obsfile[:]->sp
    end if

    if(varnam.eq."PHIS")then
       var   = obsfile[:]->z
    end if

    if(varnam.eq."TAUX")then
       var   = obsfile[:]->mntss
       var   = var*-1.0
    end if

    if(varnam.eq."TAUY")then
       var   = obsfile[:]->metss
       var   = var*-1.0
    end if

    if(varnam.eq."PRECC")then
       var   = obsfile[:]->mcpr
       var   = var / 1000.0
       var@units = "m/s"
    end if

    if(varnam.eq."PRECL")then
       var   = obsfile[:]->mlspr
       var   = var / 1000.0
       var@units = "m/s"
    end if

    if(varnam.eq."PRECT")then
       var   = obsfile[:]->mtpr
       var   = var / 1000.0
       var@units = "m/s"
    end if

    if(varnam.eq."PRECST")then
       var   = obsfile[:]->msr
       var   = var / 1000.0
       var@units = "m/s"
    end if

    if(varnam.eq."SHFLX")then
       var   = obsfile[:]->sshf
       var   = var / 86400.0
       var@units = "W/m2"
    end if

    if(varnam.eq."LHFLX")then
       var   = obsfile[:]->slhf
       var   = var / 86400.0
       var@units = "W/m2"
    end if

    if(varnam.eq."PBLH")then
       var   = obsfile[:]->blh
    end if

    if(varnam.eq."CAPE")then
       var   = obsfile[:]->cape
    end if

    if(varnam.eq."CIN")then
       var   = obsfile[:]->cin
    end if

    if(varnam.eq."TREFHT")then
       var   = obsfile[:]->t2m
    end if

    if(varnam.eq."TMQ")then
       var   = obsfile[:]->tcwv
    end if

    if(varnam.eq."TGCLDLWP")then
       var   = obsfile[:]->tclw
    end if

    if(varnam.eq."TGCLDIWP")then
       var   = obsfile[:]->tciw
    end if

    ;incoming solar radiation
    if(varnam.eq."SOLIN")then
       var   = obsfile[:]->tisr
       var   = var / 86400.0
       var@units = "W/m2"
    end if

    ;;TOA upward LW flux
    if(varnam.eq."FLUT")then
       var   = obsfile[:]->ttr
       var   = -var / 86400.0
       var@units = "W/m2"
    end if
    
   ;TOA upward LW flux (clear sky)
    if(varnam.eq."FLUTC")then
       var   = obsfile[:]->ttrc 
       var   = -var / 86400.0
       var@units = "W/m2"
    end if

   ;TOA upward SW flux 
    if(varnam.eq."FSUTOA")then
       var   = obsfile[:]->tisr
       var   = obsfile[:]->tisr - obsfile[:]->tsr
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;TOA upward SW flux (clear sky)
    if(varnam.eq."FSUTOAC")then
       var   = obsfile[:]->tisr
       var   = obsfile[:]->tisr - obsfile[:]->tsrc
       var   = var / 86400.0
       var@units = "W/m2"
    end if
    
   ;TOA net SW flux	
    if(varnam.eq."FSNTOA")then
       var   = obsfile[:]->tsr
       var   = var / 86400.0
       var@units = "W/m2"
       var@comment = "TOA net SW flux (all-sky)"
    end if

   ;TOA net SW flux (clear-sky)
    if(varnam.eq."FSNTOAC")then
       var    = obsfile[:]->tsrc
       var   = var / 86400.0
       var@units = "W/m2"
       var@comment = "TOA net SW flux (clear-sky)"
    end if

   ;TOA Net LW Flux
    if(varnam.eq."FLNTOA")then
       var   = obsfile[:]->ttr
       var   = - var / 86400.0
       var@units = "W/m2"
    end if    

   ;TOA Net LW Flux (clear sky)
    if(varnam.eq."FLNTOAC")then
       var   = obsfile[:]->ttrc
       var   = - var / 86400.0
       var@units = "W/m2"
    end if

   ;Longwave Heat Flux (surface)
    if(varnam.eq."FLNS")then
       var   = obsfile[:]->str
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Longwave Heat Flux (surface, clear sky)
    if(varnam.eq."FLNSC")then
       var   = obsfile[:]->strc
       var   = var / 86400.0
       var@units = "W/m2"
    end if

    ;Shortwave Heat Flux (surface) 
    if(varnam.eq."FSNS")then
       var   = obsfile[:]->ssr
       var   = var / 86400.0
       var@units = "W/m2"
    end if

    ;Shortwave Heat Flux (surface, clear sky)
    if(varnam.eq."FSNSC")then
       var   = obsfile[:]->ssrc
       var   = var / 86400.0
       var@units = "W/m2"
    end if
 
   ;TOA shortwave cloud forcing
    if(varnam.eq."SWCF")then
       var   = obsfile[:]->tsr
       var   = obsfile[:]->tsr - \ 
               obsfile[:]->tsrc
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface longwave cloud forcing
    if(varnam.eq."LWCF")then
       var   = obsfile[:]->ttr
       var   = - obsfile[:]->ttr + \
                 obsfile[:]->ttrc
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface shortwave cloud forcing
    if(varnam.eq."SWCF_SRF")then
       var   = obsfile[:]->ssr
       var   = obsfile[:]->ssr - obsfile[:]->ssrc
       var   = var / 86400.0 
       var@units = "W/m2"
       var@standard_name = "Short-wave cloud forcing"
       var@comment       = "Calculated as (ssr - ssrc)/86400.0"
    end if

   ;TOA longwave cloud forcing
    if(varnam.eq."LWCF_SRF")then
       var   = obsfile[:]->str
       var   = - obsfile[:]->str + obsfile[:]->strc
       var   = var / 86400.0
       var@units = "W/m2"
    end if

    ;Surface net radiative forcing 
    if(varnam.eq."NETCF_SRF")then
       var   = obsfile[:]->ssr
       var   = obsfile[:]->ssr  - \
               obsfile[:]->ssrc - \
               obsfile[:]->str  + \
               obsfile[:]->strc
       var   = var / 86400.0
       var@units = "W/m2"
       var@standard_name = "NETCF_SRF"
       var@comment       = "Net cloud forcing at surface"
    end if

    ;TOA net radiative forcing 
    if(varnam.eq."NETCF")then
       var   = obsfile[:]->ttr
       var   = obsfile[:]->ttr  - \ 
               obsfile[:]->ttrc + \
               obsfile[:]->tsr - \
               obsfile[:]->tsrc
       var   = var / 86400.0
       var@units = "W/m2"
       var@standard_name = "NETCF"
       var@comment       = "Net cloud forcing at TOA"
    end if

    ;TOA net radiative flux 
    if(varnam.eq."RESTOA")then
       var   = obsfile[:]->ttr
       var   = obsfile[:]->ttr + obsfile[:]->tsr
       var   = var / 86400.0
       var@units = "W/m2"
       var@standard_name = "RESTOA"
       var@comment       = "The net radiative flux at top of atmosphere"
    end if

   ;Surface upwelling SW radiation
    if(varnam.eq."FSUS")then
       var   = obsfile[:]->ssrd
       var   = obsfile[:]->ssrd - obsfile[:]->ssr
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface upwelling SW radiation (clear sky)
    if(varnam.eq."FSUSC")then
       var   = obsfile[:]->ssrd
       var   = obsfile[:]->ssrd - obsfile[:]->ssr
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface downwelling SW radiation 
    if(varnam.eq."FSDS")then
       var   = obsfile[:]->ssrd
       var   = var / 86400.0
       var@units = "W/m2"
    end if
   
   ;Surface downwelling SW radiation (clear sky)
    if(varnam.eq."FSDSC")then
       var   = obsfile[:]->ssrdc
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface upwelling LW radiation
    if(varnam.eq."FLUS")then
       var   = obsfile[:]->strd
       var   = obsfile[:]->strd -  obsfile[:]->str
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface upwelling LW radiation (clear sky)
    if(varnam.eq."FLUSC")then
       var   = obsfile[:]->strdc
       var   = obsfile[:]->strdc -  obsfile[:]->strc
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface downwelling LW radiation
    if(varnam.eq."FLDS")then
       var   = obsfile[:]->strd
       var   = var / 86400.0
       var@units = "W/m2"
    end if

   ;Surface downwelling LW radiation (clear sky)
    if(varnam.eq."FLDSC")then
       var   = obsfile[:]->strdc
       var   = var / 86400.0
       var@units = "W/m2"
    end if
    
   ;NET radiation flux at surface 
    if(varnam.eq."NET_RAD_FLUX_SRF")then
       var   = obsfile[:]->ssr
       var   = obsfile[:]->ssr + obsfile[:]->str
       var   = var / 86400.0
       var@units = "W/m2"
       var@standard_name = "Net radiative fluxes at surface"
       var@comment       = "Calculaed as ( ssr + str ) / 86400.0"
    end if
 
   ;NET flux at surface
    if(varnam.eq."NET_FLUX_SRF")then
       var   = obsfile[:]->ssr
       var   = obsfile[:]->ssr + \
               obsfile[:]->str + \
               obsfile[:]->slhf + \
               obsfile[:]->sshf 
       var   = var / 86400.0
       var@units = "W/m2"
       var@standard_name = "Net radiative fluxes at surface"
       var@comment       = "Calculaed as ( ssr + str + slhf + sshf ) / 86400.0"
    end if

    ;TOA (top-of-atmosphere) albedo 
    if(varnam.eq."ALBEDO")then
       tmp   = obsfile[:]->tisr
       tmp   = where(obsfile[:]->tisr.eq.0,tmp@_FillValue,tmp)
       var   = obsfile[:]->tisr
       var   = (tmp - obsfile[:]->tsr)/tmp
       var@units = "dimensionless"
       var@standard_name = "TOA (top-of-atmosphere) albedo"
       var@comment       = "Calculated as (tisr - tsr) /tisr" 
    end if

    ;TOA (top-of-atmosphere) albedo (clear sky)
    if(varnam.eq."ALBEDOC")then
       tmp   = obsfile[:]->tisr
       tmp   = where(obsfile[:]->tisr.eq.0,tmp@_FillValue,tmp)
       var   = obsfile[:]->tisr
       var   = (tmp - obsfile[:]->tsrc)/tmp
       var@units = "dimensionless"
       var@standard_name = "TOA (top-of-atmosphere) albedo for clear-sky "
       var@comment       = "Calculated as (tisr - tsrc) /tisr"       
    end if

    ;Surface albedo 
    if(varnam.eq."ALBEDO_SRF")then
       tmp   = obsfile[:]->ssrd
       tmp   = where(obsfile[:]->ssrd.eq.0,tmp@_FillValue,tmp)
       var   = obsfile[:]->ssrd
       var   = (tmp - obsfile[:]->ssr)/tmp
       var@units = "dimensionless"
       var@standard_name = "Surface albedo"
       var@comment       = "Calculated as (ssrd - ssr) /ssrd"       
    end if

    print(varnam)
    var!0 = "time"
    var!1 = "lat"
    var!2 = "lon"
    var&time = time
    var&lat  = lat
    var&lon  = lon
    outfile->$varnam$ = var
    delete(var)

    delete(outfile)

  end do 
 
  delete(obsfile)
  delete([/time, lat, lon, lat_bnds, lon_bnds, gw/])

end do 

end
exit
