load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  FREQ       = "monthly"
  month      = 1

  FREQ       = "annual"

  model_name = "ERA5"
  resolution = "f1.9x2.5"
  model_path = "/pic/projects/E3SM_DA/zhan391/e3sm_dart_FV19/acme_init/Observations/"+model_name+"/monthly_mean_5yr/"

  do year = 2011,2015,1

   if(FREQ.eq."monthly") then 
     file_in    = model_path +str_lower(model_name)+"_prelev_analysis_"+resolution+"_"+sprinti("%04d",year)+sprinti("%02d",month)+".nc"
   else if (FREQ.eq."annual")then
     file_in    = model_path +str_lower(model_name)+"_prelev_analysis_"+resolution+"_"+sprinti("%04d",year)+".nc" 
   else
     print("file frequency not supported, please check")
     exit
   end if
   end if 
    
   obsfile    = addfile(file_in,"r")

   setfileoption("nc","Format","NetCDF4Classic")
   out_path   = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/"+model_name+"_ANL_ENS01/"+FREQ
   system("/bin/mkdir -p " + out_path)
   out_name   = sprinti("%04d",year)+"_0001_plev.nc" 
   system("/bin/rm -f " + out_path+"/"+out_name)
   outfile    = addfile(out_path+"/"+out_name,"cw")

   varlist    = (/"CLOUD","U","V","T","Q","CLDLIQ","CLDICE", "VOR", "DIV", \
                 "RELHUM", "Z3","OMEGA"\
                /)

   nvars      = dimsizes(varlist) 

   time     = obsfile->time
   lat      = obsfile->lat
   lon      = obsfile->lon
   lev      = obsfile->lev
   lat_bnds = obsfile->lat_bnds
   lon_bnds = obsfile->lon_bnds
   gw       = obsfile->gw
   area     = obsfile->area

   time!0   = "time"
   time&time= time 
   lat!0    = "lat"
   lat&lat  = lat
   lon!0    = "lon"
   lon&lon  = lon 
   lev!0    = "lev"
   lev&lev  = lev

   lat_bnds!0    = "lat"
   lat_bnds&lat  = lat
   lon_bnds!0    = "lon"
   lon_bnds&lon  = lon

   area!0        = "lat"
   area!1        = "lon"
   area&lat      = lat
   area&lon      = lon
   gw!0          = "lat"
   gw&lat        = lat
 
   outfile->time     = time
   outfile->lat      = lat
   outfile->lon      = lon
   outfile->lev      = lev
   outfile->gw       = gw
   outfile->area     = area
   outfile->lat_bnds = lat_bnds
   outfile->lon_bnds = lon_bnds

   do iv = 0,nvars-1,1

    varnam = varlist(iv)

    if(varnam.eq."CLOUD") then
       var   = obsfile->cc
    end if

    if(varnam.eq."CLDLIQ")then
       var   = obsfile->clwc
    end if
 
    if(varnam.eq."CLDICE")then
       var   = obsfile->ciwc
    end if

    if(varnam.eq."CRWC")then
       var   = obsfile->crwc
    end if

    if(varnam.eq."CSWC")then
       var   = obsfile->cswc
    end if

    if(varnam.eq."U")then
       var   = obsfile->u
    end if

    if(varnam.eq."V")then
       var   = obsfile->v
    end if

    if(varnam.eq."T")then
       var   = obsfile->t
    end if

    if(varnam.eq."Q")then
       var   = obsfile->q
    end if

    if(varnam.eq."OMEGA")then
       var   = obsfile->w
    end if

    if(varnam.eq."RELHUM")then
       var   = obsfile->r
    end if

    if(varnam.eq."DIV")then
       var   = obsfile->d
    end if

    if(varnam.eq."VOR")then
       var   = obsfile->vo
    end if

    if(varnam.eq."PVOR")then
       var   = obsfile->pv
    end if

    if(varnam.eq."Z3")then
       var   = obsfile->z
    end if

    if(varnam.eq."O3")then
       var   = obsfile->o3
    end if

    var!0 = "time"
    var!1 = "lev"
    var!2 = "lat"
    var!3 = "lon"
    var&time = time
    var&lev  = lev
    var&lat  = lat
    var&lon  = lon
    outfile->$varnam$ = var
    delete(var)

  end do 

  delete(outfile)
  delete(obsfile)

 end do 

end
exit
