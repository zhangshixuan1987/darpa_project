#!/bin/csh
set OBS       = "ERA5"
set data_dir  = "/compyfs/zhan391/acme_init/Observations/${OBS}"
set out_dir   = "/compyfs/zhan391/cryosphere_scratch/post_process/data/OBS/${OBS}"

set yy1 = 2009
set yy2 = 2010

####process monthly data########
set FREQ = "monthly"
set files =
set year = $yy1
while ( $year <= $yy2 )
 set datfil = ${data_dir}/${FREQ}/${OBS}_prelev_${FREQ}_${year}_1x1.nc
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
