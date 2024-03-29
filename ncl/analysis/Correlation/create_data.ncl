load "./area_rectlinear_grid.ncl"

begin

  model   		= (/"CLIM","NDGQ","NDGT","NDGUV", \
                            "NDGUVT","NDGUVQ", "NDGUVTQ", \
                            "NDGUVT_tau1h", "NDGUVT_tau3h", "NDGUVT", \
                            "NDGUVT_tau12h", "NDGUVT_tau24h"/)
 ;model                 = model(::-1)
  dim0    		= dimsizes(model)

  var                   = (/"U100","U200","U500","U700","U850",   \
                            "T100","T200","T500","T700","T850",   \
                            "Q100","Q200","Q500","Q700","Q850",   \
                            "OMEGA100","OMEGA200","OMEGA500","OMEGA700","OMEGA850", \ 
                            "OLR_NOAA_AVHRR","OLR_NOAA_HIRS",\
                            "PRECT_GPCP","PRECT_PERSIANN_CDR","PRECT_TRMM"/)
  dim1    		= dimsizes(var)

  type    		= (/"tac","sac_3regions"/)
  dim2            	= dimsizes(type)

  region_lobnd 		= (/-90, -60, -20, -90/)
  region_hibnd 		= (/ 90,  60,  20,  90/)
  region_name 		= (/1, 2, 3, 4/)
  region_name@long_name = "1 - Polar region, 90S-60S, 60N-90N; " + \
                          "2 - Mid-latitude, 60S-30S, 30N-60N; " + \
                          "3 - Tropical zone, 20S-20N; " + \
                          "4 - Global"
  regid 		= (/0,1,2,3/)
  regions               = (/"Polar","MidLat","Tropics","Global"/)
  dim3			= dimsizes(regid)

  ;;;;;;;;;;;;;
  ; READ DATA ;
  ;;;;;;;;;;;;;
  BASE_Dir              = "/compyfs/zhan391/darpa_scratch/post_process/generate_corr/output/"
  outtable 		= new((/dim0,dim1/), double)
  outtable              = 0.
  outtable!0 		= "nmodel"
  outtable!1 		= "nvar"
  models 		= ispan(0,dim0-1,1)
  models!0 		= "nmodel"
  exp_string            = ""
  do im = 0,dim0-1
    tmp_string          = im + " - " + model(im)
    exp_string          = exp_string+ str_insert(tmp_string, ";", 20)
  end do
  models@long_name 	= exp_string
  vars 			= ispan(0,dim1-1,1)
  vars!0 		= "nvar"
  long_string           = ""
  do iv = 0,dim1-1
    tmp_string          = iv + " - " + var(iv)
    long_string         = long_string + str_insert(tmp_string, ";", 25)
  end do 
  vars@long_name 	= long_string
  outtable&nmodel 	= models
  outtable&nvar   	= vars

  ;;;;;;;;;;;;;;;
  ; NDG_ERA ANC ;
  ;;;;;;;;;;;;;;;
  do k = 0, dim2-1

     if  (type(k) .eq. "tac") then
         fname                                  = "./"+type(k)+"_3regions_data.nc"
     else
         fname                                  = "./"+type(k)+"_data.nc"
     end if

     system("rm -rvf " + fname)
     f                                          = addfile(fname, "cw")
     delete(fname)

     do n = 0, dim3-1

        do i = 0, dim1-1

            if (isStrSubset(var(i), "OLR")) then 

              varnam = "OLR"                
              obs0   = str_sub_str(var(i),"OLR_","")

            else if (isStrSubset(var(i), "PRECT")) then

              varnam = "PRECT"
              obs0   = str_sub_str(var(i),"PRECT_","")
       
            else
              varnam = var(i)
              obs0   = "ERA5"
            end if 
            end if 

           print("working on observations: " + obs0 + " " + varnam)

           do j = 0, dim0-1

              obs                           = obs0
              fname                         = BASE_Dir+"/"+model(j)+"-"+obs+"/"+type(k)+"_"+varnam+".nc"
              file1                         = addfile(fname, "r")
              corr                          = file1->corr

	      if  (type(k) .eq. "sac_3regions") then
                  outtable(j,i)                 = (/avg(corr(:,regid(n)))/)
                  delete([/file1,fname,corr/])
              else
                  lat      	                = file1->lat
                  lon      	                = file1->lon
                  gridarea 	                = area_global_rectilinear_grid(lat, lon, False)
                  gridarea@_FillValue           = corr@_FillValue
                  gridarea                      = where(ismissing(corr), gridarea@_FillValue, gridarea)
	          if  (n .eq. 0) then
                      a                         = closest_val(-90.,lat)
                      b                         = closest_val(-60.,lat)
                      c                         = closest_val(60.,lat)
                      d                         = closest_val(90.,lat)
                      if ( all(ismissing(gridarea(a:b,:))) .and. all(ismissing(gridarea(c:d,:))) ) then
                         outtable(j,i)          = corr@_FillValue
                      else                        
                         avgarea                = (sum(gridarea(a:b,:)) + sum(gridarea(c:d,:))) / \
                                                  ((num(.not. ismissing(gridarea(a:b,:))) + \
                                                  num(.not. ismissing(gridarea(c:d,:)))) * 1.0)
                         outtable(j,i)          = (/(sum(corr(a:b,:) * gridarea(a:b,:) / avgarea) + \
                                                     sum(corr(c:d,:) * gridarea(c:d,:) / avgarea)) / \
                                                     ((num(.not. ismissing(gridarea(a:b,:))) + \
                                                       num(.not. ismissing(gridarea(c:d,:)))) * 1.0) /)
                      end if 
	              delete([/lat,lon,gridarea/])
                  else if (n .eq. 1) then
                      a                         = closest_val(-60.,lat)
                      b                         = closest_val(-30.,lat)
                      c                         = closest_val(30.,lat)
                      d                         = closest_val(60.,lat)
                      if ( all(ismissing(gridarea(a:b,:))) .and. all(ismissing(gridarea(c:d,:))) ) then
                         outtable(j,i)          = corr@_FillValue
                      else
                         avgarea                = (sum(gridarea(a:b,:)) + sum(gridarea(c:d,:))) / \
                                                  ((num(.not. ismissing(gridarea(a:b,:))) + \
                                                  num(.not. ismissing(gridarea(c:d,:)))) * 1.0)
                         outtable(j,i)          = (/(sum(corr(a:b,:) * gridarea(a:b,:) / avgarea) + \
                                                     sum(corr(c:d,:) * gridarea(c:d,:) / avgarea)) / \
                                                     ((num(.not. ismissing(gridarea(a:b,:))) + \
                                                       num(.not. ismissing(gridarea(c:d,:)))) * 1.0) /)
                      end if
	              delete([/lat,lon,gridarea/])
                  else
                      a 	   	        = closest_val(region_lobnd(regid(n)),lat)
                      b 	   	        = closest_val(region_hibnd(regid(n)),lat)
                      if (num(.not. ismissing(gridarea(a:b,:))) .eq. 0) then
                          outtable(j,i)         = gridarea@_FillValue
                      else
                          avgarea 	        = sum(gridarea(a:b,:)) / (num(.not. ismissing(gridarea(a:b,:))) * 1.0)
                          outtable(j,i)         = (/avg(corr(a:b,:) * gridarea(a:b,:) / avgarea)/)
                      end if
	              delete([/lat,lon,gridarea/])
                  end if
                  end if
                  delete([/file1,fname,corr/])
              end if
           end do
	end do
        f->$regions(n)$ 	                = outtable
     end do
     delete(f)
  end do

end
