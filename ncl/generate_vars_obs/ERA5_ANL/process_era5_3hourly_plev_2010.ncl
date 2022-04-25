load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  FREQ       = "3hourly"
  model_name = "ERA5"
  resolution = "1x1"
  yy1 = 2010
  yy2 = 2010

  model_path = "/compyfs/zhan391/acme_init/Observations/"+model_name
  out_path   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/"+model_name+"/"+FREQ
  system("/bin/mkdir -p " + out_path)

  varlist    = (/"U","V","T","Q","RELHUM", "Z3","OMEGA"/)
  nvars      = dimsizes(varlist) 

  do yy = yy1,yy2

   fcord   = model_path+"/"+"coord.nc"
   ff      = addfile(fcord,"r")

   file_in = model_path+"/"+model_name+ "_prelev_"+FREQ+"_" + resolution+ "_" + yy+".nc"
   obsfile = addfiles(file_in,"r")

   time     = obsfile[:]->time
   lat      = ff->lat
   lon      = ff->lon
   lev      = ff->level
   lat_bnds = ff->lat_bnds
   lon_bnds = ff->lon_bnds
   gw       = ff->gw

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

   gw!0     = "lat"
   gw&lat   = lat

  do iv = 0,nvars-1,1

    varnam = varlist(iv)

    if(varnam.eq."CLOUD") then
       var   = obsfile[:]->cc
    end if

    if(varnam.eq."CLDLIQ")then
       var   = obsfile[:]->clwc
    end if
 
    if(varnam.eq."CLDICE")then
       var   = obsfile[:]->ciwc
    end if

    if(varnam.eq."CRWC")then
       var   = obsfile[:]->crwc
    end if

    if(varnam.eq."CSWC")then
       var   = obsfile[:]->cswc
    end if

    if(varnam.eq."U")then
       var   = obsfile[:]->u
    end if

    if(varnam.eq."V")then
       var   = obsfile[:]->v
    end if

    if(varnam.eq."T")then
       var   = obsfile[:]->t
    end if

    if(varnam.eq."Q")then
       var   = obsfile[:]->q
    end if

    if(varnam.eq."OMEGA")then
       var   = obsfile[:]->w
    end if

    if(varnam.eq."RELHUM")then
       var   = obsfile[:]->r
    end if

    if(varnam.eq."DIV")then
       var   = obsfile[:]->d
    end if

    if(varnam.eq."VOR")then
       var   = obsfile[:]->vo
    end if

    if(varnam.eq."PVOR")then
       var   = obsfile[:]->pv
    end if

    if(varnam.eq."Z3")then
       var   = obsfile[:]->z
    end if

    if(varnam.eq."O3")then
       var   = obsfile[:]->o3
    end if

    do il = 0,dimsizes(lev)-1,1

     strlev = str_squeeze(sprinti("%03d",toint(lev(il))))
     setfileoption("nc","Format","NetCDF4Classic")
     out_name   = varnam+strlev+"_"+yy+".nc"
     system("/bin/rm -f " + out_path+"/"+out_name)
     outfile    = addfile(out_path+"/"+out_name,"cw")
  
     outfile->time     = time
     outfile->lat      = lat
     outfile->lon      = lon
     outfile->gw       = gw

     var2   = var(:,il,:,:)
     var2!0 = "time"
     var2!1 = "lat"
     var2!2 = "lon"
     var2&time = time
     var2&lat  = lat
     var2&lon  = lon
     outnam    = varnam+strlev
     outfile->$outnam$ = var2
     delete(var2)
    end do 

    delete(var)

  end do 

  delete(outfile)
  delete(obsfile)

 end do 

end
exit
