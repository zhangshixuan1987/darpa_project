load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  FREQ       = "monthly"
  model_name = "ERA5"
  resolution = "1x1"

  model_path = "/compyfs/zhan391/acme_init/Observations/"+model_name
  out_path   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/"+model_name+"/"+FREQ

  yy1 = 2009
  yy2 = 2010

  setfileoption("nc","Format","NetCDF4Classic")
  out_name   = yy1+"-"+yy2+".nc"
 ;system("/bin/mkdir -p " + out_path)
 ;system("/bin/rm -f " + out_path+"/"+out_name)
  outfile    = addfile(out_path+"/"+out_name,"w")

  varlist    = (/"CLOUD","U","V","T","Q","CLDLIQ","CLDICE","VOR","DIV","RELHUM", "Z3","OMEGA"\
                /)

  nvars      = dimsizes(varlist) 

  ;;process pressure level data
  file_in    = new(2,string)
  do yy = yy1,yy2
    file_in(yy-yy1) = model_path+"/"+model_name+ "_prelev_monthly_" + yy+"_"+resolution+".nc"
  end do
  obsfile  = addfiles(file_in,"r")

   time     = obsfile[:]->time
   lat      = obsfile[0]->lat
   lon      = obsfile[0]->lon
   lev      = obsfile[0]->lev
   lat_bnds = obsfile[0]->lat_bnds
   lon_bnds = obsfile[0]->lon_bnds
   gw       = obsfile[0]->gw

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

   gw!0          = "lat"
   gw&lat        = lat
 
   outfile->time     = time
   outfile->lat      = lat
   outfile->lon      = lon
   outfile->lev      = lev
   outfile->gw       = gw
   outfile->lat_bnds = lat_bnds
   outfile->lon_bnds = lon_bnds

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

end
exit
