load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "WCHAR.ncl" ; All related function tar into this lib 
begin
;;--Plot a blank figure
; if you want look the dotting process, use X11 (very slowly)
; Generally a postscripts is a good choice
    type = "pdf" 
    wks = gsn_open_wks(type, "wchar_test")
   ; plot = new(4, graphic)
    res = True
    res@gsnDraw = False
    res@gsnFrame = False
;    res@gsnMaximize = True
    res@tiMainString = "主标题"
    res@gsnLeftString = "左字符串"         ;; 未找到其所在的图形对象的类别
    res@gsnRightString = "右字符串"        ;; 未找到其所在的图形对象的类别
    res@tiXAxisString = "横坐标标题"
    res@tiYAxisString = "纵坐标标题"

    res@tmXBMode = "Explicit"
    res@tmXBValues = fspan(0, 1, 6)
    res@tmXBLabels = (/"一月", "二月", "三月", "四月", "五月", "六月"/)

    res@tmYLMode = "Explicit"
    res@tmYLValues = fspan(0, 1, 10)
    res@tmYLLabels = (/"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"/)

    plot = gsn_csm_blank_plot(wks, res)

;;--Dot wide-character
;;-----------------------------------------------
;; The possible wide character attribute setting
;;     res@fontQuality = "High"  ; XLow, Low, Medium, High, ExtraHigh
;;     res@fontSize = 12         ; Any integer value
;;     res@fontColor = "black"   ; Any NCL Name Color or RGB
;;     res@fontName = "S"        ; Current Only S(SongTi)
;;     res@fontEncoding = "utf8" ; utf8 or GBK
;;     res@fontXoffsetF = 0.     ; x-direction char move on the NDC coord.
;;     res@fontYoffsetF = 0.     ; y-direction char move on the NDC coord.
;;     res@fontJust = "CenterCenter" ; (/"topLeft", "CenterLeft", "BottomLeft",\
;;                                       "TopCenter", "CenterCenter", "BottomCenter",\
;;                                       "TopRight", "CenterRight", "BottomRight"/)
;;     res@fontAngleF = 0.       ; Char rotate angle
;;     res@fontNDC = False       ; Attach to plot or NDC
;;-----------------------------------------------
    ftres = True
    ftres@fontQuality = "High"
    ftres@fontSize = 10
    fontX(wks, plot, "１０号——宋体", 0.5, 0.9, ftres)
    ftres@fontSize = 12
    fontX(wks, plot, "１２号——宋体", 0.5, 0.8, ftres)
    ftres@fontSize = 14
    fontX(wks, plot, "１４号——宋体", 0.5, 0.7, ftres)
    ftres@fontSize = 16
    fontX(wks, plot, "１６号——宋体", 0.5, 0.6, ftres)
    ftres@fontSize = 18
    fontX(wks, plot, "１８号——宋体", 0.5, 0.5, ftres)
    ftres@fontSize = 20
    fontX(wks, plot, "２０号——宋体", 0.5, 0.4, ftres)
    ftres@fontSize = 22
    fontX(wks, plot, "２２号——宋体", 0.5, 0.3, ftres)
    ftres@fontSize = 24
    fontX(wks, plot, "２４号——宋体", 0.5, 0.2, ftres)
    ftres@fontSize = 26
    fontX(wks, plot, "２６号——宋体", 0.5, 0.1, ftres)

    drawNDCGrid(wks)
    
    fontTitle(wks, plot, res)
    draw(plot)
    frame(wks)

end 
