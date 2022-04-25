#!/bin/csh
set OBS       = "TRMM"
set data_dir  = "/compyfs/zhan391/acme_init/Observations/${OBS}"
set out_dir   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/${OBS}"

set yy1 = 2009
set yy2 = 2011

####process 3hourly data########
set FREQ = "3hourly"
set files =
set year = $yy1
while ( $year <= $yy2 )
 set datfil = ${data_dir}/${FREQ}/${OBS}_3B42_${FREQ}_${year}_1x1.nc
 set files = ($files $datfil)
 @ year++
end
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
cdo mergetime $files tmp.nc
set outfil = ${out_dir}/$FREQ/$yy1-$yy2.nc
rm -rvf ${outfil}
cdo chname,precipitation,PRECT tmp.nc ${outfil}
rm -rvf tmp*.nc
