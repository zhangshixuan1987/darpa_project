#!/bin/csh
set OBS       = "NOAA_AVHRR"
set data_dir  = "/compyfs/zhan391/acme_init/Observations/${OBS}"
set out_dir   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/${OBS}"

set yy1 = 2009
set yy2 = 2011

####process daily data########
set FREQ = "daily"
set files = 
set year = $yy1
while ( $year <= $yy2 )
 set datfil = $data_dir/${OBS}_${FREQ}_${year}_1x1.nc
 set files = ($files $datfil)
 @ year++
end 

if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
#cdo selmon,$mm1 $data_file1 tmp01.nc
#cdo selmon,$mm2 $data_file2 tmp11.nc
#ncrcat -d time,0, tmp01.nc tmp11.nc tmp.nc
#cdo seltimestep,$day1/$day2 tmp.nc tmp3.nc
cdo mergetime $files tmp.nc
set outfil = ${out_dir}/$FREQ/$yy1-$yy2.nc
rm -rvf ${outfil}
cdo chname,olr,OLR tmp.nc ${outfil}
rm -rvf tmp*.nc

####process monthly data########
set FREQ = "monthly"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif

set datafile = "$data_dir/${OBS}_${FREQ}_1974-2018_1x1.nc"
cdo selyear,$yy1/$yy2 $datafile tmp.nc
#cdo selmon,$mm2 $data_file2 tmp11.nc
#ncra tmp11.nc tmp.nc
set outfil = ${out_dir}/$FREQ/$yy1-$yy2.nc
rm -rvf ${outfil}
cdo chname,olr,OLR tmp.nc ${outfil}
rm -rvf tmp*.nc
