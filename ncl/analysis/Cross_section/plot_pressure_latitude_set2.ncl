;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;This script used to calculate and plot the zonal mean variables from CAM;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;The terms zonal and meridional are used to describe directions on a globe;;;;;;;
;;;;;;;Zonal means "along a latitudinal circle" or "in the west–east direction";;;;;;;;
;;;;;;;while meridional means "along a longitudinal circle" (a.k.a. meridian) ;;;;;;;;;
;;;;;;;or "in the north–south direction" [2];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  ldatalocal = True
  ldatalocal = True

  ModelOutRoot = "./"

 ;;;;;;;strings for the data directory;;;;;;;;
  Groups      = (/"ERA5","CLIM","NDGUVT_tau24h","NDGUVT","NDGUVT_tau1h"/) 
                ;,"NDGUVT_tau12h","NDGUVT","NDGUVT_tau3h","NDGUVT_tau1h"/)
  Expnams     = (/"ERA5","CLIM","NDG_tau (24h)","NDG_tau (6h)","NDG_tau (1h)"/) 
                 ;"NDG_tau (6h)","NDG_tau (3h)","NDG_tau (1h)"/)
  ngrps       = dimsizes(Groups)

  LabList         = new(ngrps,string)
  igp             = 0
  LabList(igp)    = Expnams(0)
  do igp  = 1,ngrps-1
    LabList(igp)  = Expnams(igp)+ " ~F19~:~N~~F~ " + Expnams(0)
  end do 
 
;;;;;;variables to be plotted;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  VarList      = (/"T","Q","RELHUM","CLOUD"/)
  VstList      = (/"T","Q","RH","f"/)
  VnmList      = (/"Temperature", "Specific humidity", "Relative humidity", "Cloud fraction"/)
  UnitList     = (/"K","g kg~S~-1~N~","unitless","fraction"/)
  PltNums      = (/"a", "b", "c", "c","d","e","f","g","h","i","j","k"/)
  nvars        = dimsizes(VarList)

 ;;; flags to control the plot style
  plotcntl          = True   ; if True, plot the CNTL origianl field on the leftmost panel
  plot_contour      = True   ; if True, plot the contour in the figure  
  plot_leftstr      = True   ; if True, the lefadd igure captions as left string 

  if (plotcntl) then
    npgrps = ngrps
  else
    npgrps = ngrps -1
  end if
  plot  = new (nvars*ngrps,graphic)

;;;;;;;open a wks for plot;;;;;;;;;;;;;;;;;;;
  OUTDir  = "./"
  wtype = "pdf"
 ;wtype@wkPaperSize     = "A4"
 ;wtype@wkOrientation   = "landscape"    ;;pictures displayed along the length
  plotFileLabel = "T_Q_RH_CLOUD_ndgtau"
  wks1 = gsn_open_wks(wtype,OUTDir+"Fig_pres_lat_"+plotFileLabel)

do iv = 0,nvars-1, 1

  Varname  = VarList(iv)
  Varunt   = UnitList(iv)
  Varstr   = VstList(iv)
  Vnmstr   = VnmList(iv)

  Figstr1  = "" ;"("+ PltNums(iv*3)   +")  "
  Figstr2  = "" ;"("+ PltNums(iv*3+1) +")  "
  Figstr3  = "" ;"("+ PltNums(iv*3+2) +")  "

 do igp = 1, ngrps-1,1

  outdir = "./data/"
  fna    = outdir+ VarList(iv) + "_" + Groups(igp) + ".nc"
  fla    = addfile(fna, "r")

  print(fna)

  vna = VarList(iv) + "_" + Groups(0)
  vnb = VarList(iv) + "_" + Groups(igp)
  vnc = "d" + VarList(iv)

  pncre0300 = fla->$vna$
  wncredf1  = fla->$vnb$
  wncredf2  = fla->$vnc$

  ;;;set up the plot information;;;;
  load "./var_share_colorbar_preshgt.ncl"

  v1mnts1   = wncredf1 ;smth9_Wrap(wncredf2, 0.50,  0.25, True)
  v1mnts1@_FillValue = 32766

  v1mnts2   = wncredf2 ; smth9_Wrap(wncredf2, 0.50,  0.25, True)a
  v1mnts2@_FillValue = 32766

  labels    = (/Varstr ,"~F33~D~N~~F~"+ "RH","~F33~D~N~~F~"+ "RH"/)
  nlabls    = dimsizes(labels)

;----------------------------------------------------------------------
; Plotting section
;---Resources to share between both plots
  res                      = True              ; Plot modes desired.
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@gsnMaximize          = False              ; Maximize plot
  res@gsnAddCyclic         = False

  res@cnFillOn              = True              ; color plot desired
 ;res@cnFillPalette         = "ViBlGrWhYeOrRe";"testcmap" ;"NCV_jaisnd";"temp_19lev"
  res@cnLinesOn             = False             ; turn off contour lines
  res@cnLineLabelsOn        = False             ; turn off contour labels
 ;res@cnFillMode            = "RasterFill"      ; turn raster on
  res@cnInfoLabelOn         = False
  res@cnMissingValFillColor = "White"


  res@lbLabelBarOn            = True      ; Will turn on in panel later
  res@lbAutoManage            = False             ; we control label bar
  res@lbLabelStride           = 1                 ; skip every other label
  res@lbLabelFontHeightF      = 0.028
  res@lbPerimOn               = False             ; default has box
  res@lbOrientation           = "vertical"        ; vertical label bar
  res@pmLabelBarHeightF       = 0.6
  res@pmLabelBarWidthF        = 0.12
; res@pmLabelBarParallelPosF  = 0.026
; res@pmLabelBarOrthogonalPosF= 0.15

  res@lbTitleString           = "" ;Varunt;Varstr+ " ("+Varunt+")";
  res@lbTitlePosition         = "Right"                           ; title location
  res@lbTitleDirection        = "Across"                          ; letter angle
  res@lbTitleAngleF           = 90.                               ; title angle

  res@tmXTOn                  = False
  res@tmYROn                  = False
  res@tmYRMode                = "Automatic"
  res@tiYAxisString           = "Pressure (hPa)"

  if(.not.plotcntl) then
   if(igp.gt.1)then
     res@tmYLOn                 = False
     res@tiYAxisString          = ""
   else
     res@tmYLOn                 = True
     res@tiYAxisString          = "Pressure (hPa)"
   end if
  else
   res@tmYLOn                 = False
   res@tiYAxisString          = ""
  end if 

  if(igp.eq.ngrps-1)then
   res@lbLabelBarOn            = True      ; Will turn on in panel later
  else
   res@lbLabelBarOn            = False      ; Will turn on in panel later
  end if 

 ;res@trYMinF                 = 100.0                   ; min value on y-axis
 ;res@trYMaxF                 = 1000.0                   ; max value on y-axis
  res@tmYLMode                = "Explicit"                ; explicit labels
  res@tmYLValues              = (/ 1000, 850, 700,500,400,300,200,100/)
  res@tmYLLabels              = ""+res@tmYLValues         ; make strings

  res@trYLog                  = False

  FontHeightF = 0.032
  res@tiMainFontThicknessF    = 1.0
  res@tiMainFontHeightF       = FontHeightF*1.4
  res@tmYLLabelFontHeightF    = FontHeightF
  res@tmXBLabelFontHeightF    = FontHeightF
  res@tiXAxisFontHeightF      = FontHeightF*1.1
  res@tiYAxisFontHeightF      = FontHeightF*1.1
  res@gsnStringFontHeightF    = FontHeightF*1.1
  res@cnLineLabelFontHeightF  = FontHeightF
  res@lbLabelFontHeightF      = FontHeightF
  res@lbTitleFontHeightF      = FontHeightF                             ; font height

   BorderThick = 1.0
   res@tmBorderThicknessF    = BorderThick
   res@tmXBMajorThicknessF   = BorderThick
   res@tmXBMinorThicknessF   = BorderThick*0.5
   res@tmYLMajorThicknessF   = BorderThick
   res@tmYLMinorThicknessF   = BorderThick*0.5
   res@tmXTMajorThicknessF   = BorderThick
   res@tmXTMinorThicknessF   = BorderThick*0.5
   res@tmYRMajorThicknessF   = BorderThick
   res@tmYRMinorThicknessF   = BorderThick*0.5

  leftstr                     = "" ;"Surface Temperature ("+ts@units+")"
  res@gsnLeftString           = Varstr+" ("+ Varunt +")" ; leftstr ;var_name0    ; long_name is too long!
  res@gsnRightString          = "" ;" ("+Varunt+")";""
 ;res@tiMaingString           = "Annual Mean Response to Present-day climate"

;---Resources for plotting original data
  if(plotcntl)then
    res1=res
    res1@tmYLOn                         = True
    res1@tiYAxisString                  = "Pressure (hPa)"
    res1@cnFillPalette                  = ocname
    res1@cnLevelSelectionMode           = "ExplicitLevels"  
    res1@cnLevels                       = orglev
    res1@cnFillColors                   = orgcolors
    res1@lbBoxLinesOn                   = True
   ;res1@lbBoxSeparatorLinesOn          = False  
   ;res1@lbLabelStride                  = 15
    res1@gsnLeftString                  = Varstr+" ("+ Varunt +")" 
    res1@gsnLeftStringOrthogonalPosF    = 0.02
   ;res1@gsnLeftStringParallelPosF      = 0.2
    res1@gsnRightString                 = "";Varstr ;Varunt
    res1@gsnRightStringOrthogonalPosF    = 0.02
    if(iv.eq.0)then
      res1@tiMainString                 = LabList(0)
    else
      res1@tiMainString                 = ""
    end if
    res1@cnLinesOn                      = plot_contour       
    res1@cnLineLabelsOn                 = False     
    res1@cnInfoLabelOn                  = False
    res1@cnLineLabelDensityF            = 2.0
    res1@cnLineLabelFontHeightF         = 0.018
    res1@cnLineLabelBackgroundColor     = -1
    res1@gsnContourLineThicknessesScale = 1.0
    res1@cnLineThicknessF               = 1.0
    res1@cnLineColor                    = "Black"
    res1@gsnContourZeroLineThicknessF   = 2.
   ;res1@gsnContourNegLineDashPattern   = 1
    res1@lbTitleString                  = "" ;"("+ Varunt+")" 
    plot(iv*ngrps)  = gsn_csm_pres_hgt(wks1,pncre0300,res1)
    delete([/res1/])
  end if 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    res2=res
    res2@cnLevelSelectionMode           = "ExplicitLevels"  
    res2@cnFillColors                   = colorgroup1
    res2@cnLevels                       = diffgrp1
    res2@cnLinesOn                      = False 
    res2@cnLineLabelsOn                 = False            ; turn off contour labels
    res2@cnInfoLabelOn                  = False
    res2@gsnContourZeroLineThicknessF   = 2.
    res2@gsnContourNegLineDashPattern   = 1
    if(iv.eq.0)then
      res2@tiMainString                 = LabList(igp);"CNTL (PD1800)"
    else
      res2@tiMainString                 = "";"CNTL (PD1800)"
    end if
    res2@gsnLeftString                  = "~F33~D~N~~F~"+Varstr+" ("+ Varunt +")"  
    res2@gsnLeftStringOrthogonalPosF    = 0.02
   ;res2@gsnLeftStringParallelPosF      = 0.2 
    res2@gsnRightString                 = "" ;Varstr ;"~F33~D~N~~F~"+ Varstr ;Varunt
    res2@gsnRightStringOrthogonalPosF    = 0.02
    res2@lbTitleString                  = "" ;"("+ Varunt +")"
     plot(iv*ngrps+igp)                  = gsn_csm_pres_hgt(wks1,v1mnts1,res2)

    if(plot_contour)
     res21 = res2
     res21@gsnLeftString                  = "" 
     res21@gsnRightString                 = ""
     res21@gsnCenterString                = ""
     res21@cnFillOn                       = False
     res21@cnLinesOn                      = True
     res21@cnLineLabelsOn                 = False            ; turn off contour labels
     res21@cnInfoLabelOn                  = False
     res21@cnLineLabelDensityF            = 2.0
     res21@cnLineLabelFontHeightF         = 0.018
     res21@cnLineLabelBackgroundColor     = -1
     res21@gsnContourLineThicknessesScale = 1.0
     res21@cnLineThicknessF               = 1.0
     res21@cnLineColor                    = "Black"
     res21@gsnContourZeroLineThicknessF   = 2.
     res21@gsnContourNegLineDashPattern   = 1
    ;plot_cont1                  = gsn_csm_contour(wks1,wncredf1,res21)
     plot_cont1                  = gsn_csm_pres_hgt(wks1,wncredf1,res21)
     overlay(plot(iv*ngrps+igp),plot_cont1)
     delete([/res21/])
    end if 

   delete([/res/])

 end do

 end do ;end of variable loop

;---Draw both plots in a panel
 pnres                         = True
 pnres@gsnFrame                = False
 pnres@gsnMaximize             = False
 pnres@gsnPanelLabelBar        = True
 pnres@gsnPanelMainString      = " "; "Surface Temperature ("+ts@units+")"
 pnres@gsnPanelLabelBar        = False                ; add common colorbar
 pnres@gsnPanelMainFontColor   = "Black"
 pnres@gsnPanelMainFontHeightF = 0.030
;pnres@lbLabelFontHeightF      = 0.018               ; make labels smaller
;pnres@pmLabelBarParallelPosF  = 0.026
;pnres@pmLabelBarOrthogonalPosF= 0.015
;pnres@pmLabelBarHeightF       = 0.1
;pnres@pmLabelBarWidthF        = 0.57
;pnres@gsnPanelBottom          = 0.05
 pnres@gsnPanelYWhiteSpacePercent = 2
 pnres@gsnPanelXWhiteSpacePercent = 1
 pnres@gsnPanelXF = new(nvars*ngrps,float)
 xpos = fspan(0.1,0.75,ngrps)
 xpos(1:) = xpos(1:)+0.02
 do iv = 0,nvars-1
   pnres@gsnPanelXF(iv*ngrps:(iv+1)*ngrps-1) = xpos ; Adjust rightmost plots
 end do
 if(plotcntl)then
   gsn_panel(wks1,(/plot(:)/),(/nvars,ngrps/),pnres)
 else
   plot1 = new (nvars*(ngrps-1),graphic)
   do iv = 0,nvars-1
    plot1(iv*(ngrps-1):(iv+1)*(ngrps-1)-1) = plot((iv*ngrps+1):((iv+1)*ngrps-1))
   end do
   gsn_panel(wks1,(/plot1(:)/),(/nvars,ngrps-1/),pnres)
 end if

;************************************************
; Draw text on plot using plot coordinates.
;************************************************
; tres                      = True                ; text mods desired
; tres@txFontHeightF        = 0.011               ; make smaller
; do igp = 1,ngrps-1
;   if(igp.eq.ngrps-1)then
;    gsn_text_ndc(wks1,LabList(igp),0.18+(igp-1)*0.26,0.95,tres)
;   else
;    gsn_text_ndc(wks1,LabList(igp),0.18+(igp-1)*0.24,0.95,tres)
;   end if 
; end do 
;
 frame(wks1)                                     ; now advance frame

end
