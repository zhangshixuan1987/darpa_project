#!/bin/csh
set OBS       = "NCEP_Reanalysis"
set data_dir  = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/${OBS}/org_dat"
set out_dir   = "/pic/projects/E3SM_DA/zhan391/dart_paper_materials/DATA/${OBS}"
set MAP_FILE  = $data_dir/NCEP_DOE_to_1.9x2.5_Rect_bilinear.nc

set yy1 = 2010 #2011
set mm1 = 1
set dd1 = 1
set yy2 = 2010 #2011
set mm2 = 1
set dd2 = 31

###append all to one####
set all_file = $data_dir/3d/*.nc
set outfile = ${out_dir}/NCEP_DOE_Reanalysis.nc
rm -rvf ${outfile}
cdo merge $all_file $outfile

set data_file  = ${out_dir}/NCEP_DOE_Reanalysis_1.9x2.5.nc
ncremap -m $MAP_FILE -i $outfile  -o $data_file
