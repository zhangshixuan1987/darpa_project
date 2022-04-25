#!/bin/csh

set OBS       = "OAFlux"
set data_dir  = "/compyfs/zhan391/acme_init/Observations/${OBS}"
set out_dir   = "/compyfs/zhan391/darpa_scratch/post_process/data/OBS/${OBS}"

set yy1 = 2009
set yy2 = 2011

set FREQ = "monthly"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif

set datafile = "${data_dir}/OAFlux_monthly_1979-2013_1x1.nc"
cdo selyear,$yy1/$yy2 ${datafile} tmp.nc

set outfil = "${out_dir}/$FREQ/$yy1-$yy2.nc"
rm -rvf $outfil
#cdo chname,precipitable_water,TMQ tmp.nc ${outfil}
mv tmp.nc ${outfil}
rm -rvf tmp*.nc
