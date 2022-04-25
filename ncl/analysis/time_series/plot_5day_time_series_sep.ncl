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

  if (ldatalocal) then
     ModelOutRoot = "./"
  else
     ModelOutRoot = "/pic/projects/uq_climate/zhan391/Nudging_analysis/data_for_plot/5day_Jan/"
  end if
  
 ;;;;;;;;;;select the regions to calculate the rmse;;;;;;;;;;;;;
  Regions  = (/"SEP"/)
  Regnams  = (/"Peruvian stratocumulus region"/)
  nregs    = dimsizes(Regions)
  
 ;;;range of hour for plot
  stime      = 0
  etime      = 24
  utctolocal = 0 ;-5
  plev       = 700
  TimeUnit   = "hours since 2010-01-02 00:00"
  xstring    = "Hours since 00Z 02 January 2010"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  labels       = (/"X~B~p~N~ (0.5-hr)","X~B~p~N~ (6-hr)", "X~B~p~N~ (3-hr)","X~B~p~N~ (1-hr)"/)
  nlabls       = dimsizes(labels)

 ;;;;;;variables to be plotted;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  Varname      = (/"U_int_1h","T_int_1h"/) 
  Varstr       = (/"(a) zonal wind","(b) temperature"/)
  Varunt       = (/"m s~S~-1~N~","~S~o~N~C","g kg~S~-1~N~"/)
  nvars        = dimsizes(Varname)  

  plotFileLabel = "Fig03"

 ;;;;;;;open a wks for plot;;;;;;;;;;;;;;;;;;;
  OUTDir  = "./"
  wtype = "pdf"
 ;wtype@wkPaperSize     = "A4"
 ;wtype@wkOrientation   = "landscape"    ;;pictures displayed along the length
  wks1 = gsn_open_wks(wtype,OUTDir+plotFileLabel)
  load "./var_share_linesetup.ncl"

  plot = new(nregs*nvars,graphic)
 ;;;;;;;begin to work with the simulations;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 do irg = 0,nregs-1,1

  region     = Regions(irg)
  Filename   = "5day_variation_"+region+"_mean_U_T_Q_"+plev+"hPa.nc"
  File0      = addfile(ModelOutRoot+Filename,"r")
  time       = cd_convert(File0->time, TimeUnit)
  time       = time + utctolocal ;convert UTC to local time 
  indplt     = ind((time.ge.stime).and.(time.le.etime))
  timeplt    = time(indplt)

 do iv = 0, nvars -1
 
  leftstring   = Varstr(iv)
  rightstring  = Regnams(irg) ;"Variations of "+Varstr(iv)+" averaged over the "+ Regnams(irg)
  plotdat      = new((/4,dimsizes(timeplt)/),double)

  varUnit      = Varunt(iv)

  varName      = Varname(iv)+"_org"
  plotdat(0,:) = File0->$varName$(indplt)

  varName      = Varname(iv)+"_int_6h"
  plotdat(1,:) = File0->$varName$(indplt)

  varName      = Varname(iv)+"_int_3h"
  plotdat(2,:) = File0->$varName$(indplt)

  varName      = Varname(iv)+"_int_1h"
  plotdat(3,:) = File0->$varName$(indplt)
 
  if(Varname(iv).eq."Q_int_1h")then
   plotdat = plotdat*1000.0
  end if 

  if(Varname(iv).eq."T_int_1h")then
   plotdat = plotdat-273.15
  end if

;----------------------------------------------------------------------
; Plotting section
;---Resources to share between both plots
    res                      = True              ; Plot modes desired.
    res@gsnDraw              = False
    res@gsnFrame             = False
    res@vpWidthF             = 0.8
    res@vpHeightF            = 0.3 

    res@gsnMaximize          = True              ; Maximize plot

   ; add a legend
    if(iv.eq.1)then
      res@pmLegendDisplayMode    = "Always"              ; turn on legend
    else
      res@pmLegendDisplayMode    = "Never"
    end if 
    res@pmLegendSide           = "Top"                 ; Change location of 
    res@pmLegendParallelPosF   = .20                   ; move units right
    res@pmLegendOrthogonalPosF = -0.85                  ; more neg = down
    res@pmLegendWidthF         = 0.14                  ; Change width and
    res@pmLegendHeightF        = 0.16                  ; height of legend.
    res@lgLabelFontHeightF     = .020                   ; change font height
    res@lgPerimOn              = False                 ; no box around
    res@xyExplicitLegendLabels = "  "+labels

    res@tmXTOn                 = False
    res@tmYROn                 = False
    res@tiMainFontHeightF      = 0.022
    res@tmYLLabelFontHeightF   = 0.022
    res@tmXBLabelFontHeightF   = 0.022
    res@gsnStringFontHeightF   = 0.022

    res@gsnLeftString                 = "";leftstring ;var_name0    ; long_name is too long!
    res@gsnRightString                = "";rightstring
    res@gsnCenterString               = "" 
    res@gsnRightStringOrthogonalPosF  = 0.04
    res@gsnLeftStringOrthogonalPosF   = 0.04
    res@gsnCenterStringOrthogonalPosF = 0.04

    res@tiMainString           = "" ;"Jan "+Varname+" (%)" 

    res@trXMaxF               = etime                    ; axis max
    res@trXMinF               = stime                   ; axis min
    res@tmXBMode              = "Explicit"                ; explicit labels
    res@tmXBValues            = fspan(stime,etime,9)
    res@tmXBMinorValues       = fspan(stime,etime,25)
    res@tmXBLabels            = ""+res@tmXBValues

    if(iv.eq.0)then
     res@trYMaxF              = -2.                    ; axis max
     res@trYMinF              = -3.                    ; axis min
     res@tmYLMode             = "Explicit"                ; explicit labels
     res@tmYLValues           = fspan(res@trYMinF,res@trYMaxF,6)
     res@tmYLMinorValues      = fspan(res@trYMinF,res@trYMaxF,16)
     res@tmYLLabels           = ""+sprintf("%5.1f",res@tmYLValues)
    end if

    if(iv.eq.1)then
     res@trYMaxF              = 11.6                  ; axis max
     res@trYMinF              =  9.6                  ; axis min
     res@tmYLMode             = "Explicit"                ; explicit labels
     res@tmYLValues           = fspan(res@trYMinF,res@trYMaxF,6)
     res@tmYLMinorValues      = fspan(res@trYMinF,res@trYMaxF,16)
     res@tmYLLabels           = ""+sprintf("%5.1f",res@tmYLValues)
    end if

    res0 = res
    res0@xyMarkLineMode         = "Lines"               ; Markers *and* lines
    res0@xyLineColors           = colors
    res0@xyDashPatterns         = pattern
    res0@xyLineThicknesses      = lnthick
    res0@xyLineOpacities        = opacity
    if(iv.eq.1)then
      res0@tiXAxisString        = xstring
    else
      res0@tiXAxisString        = ""
    end if 
    res0@tiYAxisString          = varUnit

    res0@gsnLeftString          = leftstring ;var_name0    ; long_name is too long!
    res0@gsnRightString         = rightstring
    res0@gsnCenterString        = ""

    plot(iv)                    = gsn_csm_xy(wks1,timeplt,plotdat,res0)

    res1 = res
    res1@xyMarkLineMode         = "Markers"               ; Markers *and* lines
    res1@xyMarkerColors         = colors
    res1@xyMarkers              = markers
    res1@xyMarkerSizes          = mkszf
    res1@xyMarkerThicknesses    = mkthick
    res1@xyMarkerOpacities      = 1.0
    res1@tiXAxisString          = ""
    res1@tiYAxisString          = ""
    res1@gsnLeftString          = ""
    res1@gsnRightString         = "";rightstring
    res1@gsnCenterString        = ""
    plot1                       = gsn_csm_xy(wks1,timeplt(::12),plotdat(:,::12),res1)
    overlay(plot(iv),plot1)

 end do
 
;---Draw both plots in a panel
    pnres                         = True
    pnres@gsnMaximize             = True
    pnres@gsnPanelMainString      = " "; "Surface Temperature ("+ts@units+")"
    pnres@gsnPanelMainFontColor   = "Black"
    pnres@gsnPanelMainFontHeightF = 0.025
    pnres@lbLabelFontHeightF      = 0.018               ; make labels smaller
    pnres@gsnPanelBottom          = 0.05
    gsn_panel(wks1,(/plot/),(/nvars,1/),pnres)

 end do

end
