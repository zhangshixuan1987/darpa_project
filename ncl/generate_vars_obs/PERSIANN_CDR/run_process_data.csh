#!/bin/csh
set OBS       = "PERSIANN_CDR"
set data_dir  = "/compyfs/zhan391/acme_init/Observations/${OBS}"
set out_dir   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/${OBS}"

set yy1 = 2009
set yy2 = 2011

####process daily data########
set FREQ = "daily"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
#cdo selmon,$mm1 $data_file1 tmp01.nc
#cdo selmon,$mm2 $data_file2 tmp11.nc
#ncrcat -d time,0, tmp01.nc tmp11.nc tmp.nc
#@ day1 = $dd1
#@ day2 = $dd1 + $dd2 - 1
#rm -rvf ${out_dir}/$FREQ/$yy2.nc
#cdo seltimestep,$day1/$day2 tmp.nc tmp3.nc
set files =
set year = $yy1
while ( $year <= $yy2 )
 set datfil = $data_dir/${OBS}_${FREQ}_${year}_1x1.nc
 set files = ($files $datfil)
 @ year++
end
cdo mergetime $files tmp.nc
set outfil = ${out_dir}/$FREQ/$yy1-$yy2.nc
rm -rvf ${outfil}
cdo chname,precipitation,PRECT tmp.nc ${outfil}
rm -rvf tmp*.nc
