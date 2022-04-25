#!/bin/csh
set OBS       = "ARM_STATION"
set data_dir  = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/${OBS}/org_data"
                #"/pic/projects/E3SM_DA/zhan391/e3sm_dart_FV19/acme_init/Observations/${OBS}/org_data"
set out_dir   = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/${OBS}"
set yy1 = 2010
set mm1 = 12
set dd1 = 31
set yy2 = 2011
set mm2 = 1
set dd2 = 31

####process monthly data########
set data_file  = $data_dir/sgparmdiagsmonC1.c1.nc
set FREQ = "monthly"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
rm -rvf ${out_dir}/$FREQ/SGP_C1_$yy2.nc
cdo selyear,$yy2 $data_file tmp1.nc
cdo selmon,$mm2 tmp1.nc ${out_dir}/$FREQ/SGP_C1_$yy2.nc
rm -rvf tmp*.nc

####process monthly data########
set data_file  = $data_dir/sgparmdiagsmondiurnalC1.c1.nc
set FREQ = "monthly"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
rm -rvf ${out_dir}/$FREQ/SGP_C1_diurnal_$yy2.nc
cdo selyear,$yy2 $data_file tmp1.nc
cdo selmon,$mm2 tmp1.nc ${out_dir}/$FREQ/SGP_C1_diurnal_$yy2.nc
rm -rvf tmp*.nc
