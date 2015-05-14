load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "WCHAR.ncl" ; All related function tar into this lib 
begin
;;--Plot a blank figure
; if you want look the dotting process, use X11 (very slowly)
; Generally a postscripts is a good choice
    type = "pdf" 
    wks = gsn_open_wks(type, "wchar_test")
    plot = gsn_csm_blank_plot(wks, False)
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
    ftres@fontSize = 12
    fontX(wks, plot, "１２号——宋体", 0.5, 0.85, ftres)
    ftres@fontSize = 14
    fontX(wks, plot, "１４号——宋体", 0.5, 0.75, ftres)
    ftres@fontSize = 16
    fontX(wks, plot, "１６号——宋体", 0.5, 0.65, ftres)
    ftres@fontSize = 18
    fontX(wks, plot, "１８号——宋体", 0.5, 0.55, ftres)
    ftres@fontSize = 20
    fontX(wks, plot, "２０号——宋体", 0.5, 0.45, ftres)
    ftres@fontSize = 22
    fontX(wks, plot, "２２号——宋体", 0.5, 0.35, ftres)
    ftres@fontSize = 24
    fontX(wks, plot, "２４号——宋体", 0.5, 0.25, ftres)
    ftres@fontSize = 26
    fontX(wks, plot, "２６号——宋体", 0.5, 0.15, ftres)
end
