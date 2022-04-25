#!/bin/csh
set OBS       = "GPCP"
set data_dir  = "/compyfs/zhan391/acme_init/Observations/GPCP/monthly"
set out_dir   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/${OBS}"
set yy1       = 2009
set yy2       = 2011

set data_file = $data_dir/${OBS}_monthly_1979-2019_1x1.nc

####process monthly data########
set FREQ = "monthly"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
cdo selyear,$yy1/$yy2 $data_file tmp.nc 
set outfil = ${out_dir}/$FREQ/${yy1}-${yy2}.nc
rm -rvf ${outfil}
cdo chname,precip,PRECT tmp.nc ${outfil}
rm -rvf tmp.nc
