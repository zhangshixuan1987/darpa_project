#!/bin/csh
set OBS       = "NCEP_Reanalysis"
set data_dir  = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/${OBS}/org_dat"
set out_dir   = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/${OBS}"
set data_file  = ${data_dir}/NCEP_DOE_Reanalysis_1.9x2.5.nc

set yy1 = 2015 #2011

set mm1 = 1
set dd1 = 1
set dd2 = 31

####process monthly data########
set FREQ = "monthly"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
rm -rvf ${out_dir}/$FREQ/$yy1.nc
cdo selyear,$yy1 $data_file tmp1.nc
cdo selmon,$mm1 tmp1.nc ${out_dir}/$FREQ/$yy1.nc
rm -rvf tmp*.nc
