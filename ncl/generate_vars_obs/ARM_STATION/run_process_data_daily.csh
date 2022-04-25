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

set data_file  = $data_dir/sgparmdiagsdayC1.c1.nc

####process daily data########
set FREQ = "daily"
if ( ! -d ${out_dir}/$FREQ ) then
 mkdir -p ${out_dir}/$FREQ
endif
cdo selyear,$yy1 $data_file tmp0.nc
cdo selyear,$yy2 $data_file tmp1.nc
cdo selmon,$mm1 tmp0.nc tmp01.nc
cdo selmon,$mm2 tmp1.nc tmp11.nc
ncrcat -d time,0, tmp01.nc tmp11.nc tmp.nc
@ day1 = $dd1
@ day2 = $dd1 + $dd2 - 1
rm -rvf ${out_dir}/$FREQ/$yy2.nc
cdo seltimestep,$day1/$day2 tmp.nc ${out_dir}/$FREQ/SGP_C1_$yy2.nc
#cdo chname,olr,OLR tmp3.nc ${out_dir}/$FREQ/SGP_C1_$yy2.nc
rm -rvf tmp*.nc
