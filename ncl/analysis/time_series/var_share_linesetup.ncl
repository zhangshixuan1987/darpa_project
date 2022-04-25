;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;this script is used to difine the absolute difference levels (diffgrp1),;;; 
;;;;;;;;the relative difference levels (diffgrp2), then choose color bar for plot;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;set up line color, thickness, style etc ;;;;;;;;;;;;;;;;;;;;;;;
  gsn_define_colormap(wks1,"StepSeq25")
  gsn_merge_colormaps(wks1,"StepSeq25","cb_9step")
  colors  = (/55,17,2,96,45,59/)   
  gsn_define_colormap(wks1,"cb_9step")
  colors  = (/1,2,6,28,45,59/)

  markers = (/4,16,11,9,3/)       ;;line markers
  mkszf   = (/1.5,1.0,1.0,1.2,1.0/)/80.0   ;;line marker size
  lnthick = (/6,4,4,4/)   ;;line thichness
  mkthick = (/3,3,3,3/)
  opacity = (/0.8,1.0,1.0,1.0,1.0/)
  pattern = (/0,2,2,2,2,2/)

  ;;set up for fig size
  vpHeightF  = 0.4
  vpWidthF   = 0.7
  vpXF       = 0.25
  FontHeight = 0.025

