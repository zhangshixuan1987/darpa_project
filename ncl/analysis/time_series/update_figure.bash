#! /bin/bash
   
  # linear interpolation for model output 
  # ncl 01_linear_interp_model_output.ncl
  # extract 700hPa data over SEP region 
   ncl 02_extract_data_on_sep_region.ncl
  # generate figure
   ncl plot_5day_time_series_sep.ncl
   sh run_crop_pdf.sh
