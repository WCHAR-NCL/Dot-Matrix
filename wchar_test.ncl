load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "WHCAR.ncl" ; All related function tar into this lib 
begin
;;--Plot a blank figure
; if you want look the dotting process, use X11 (very slowly)
; Generally a postscripts is a good choice
    type = "ps" 
    wks = gsn_open_wks(type, "wchar_test")
    res = True
    res@gsnDraw = False
    plot = gsn_csm_blank_plot(wks, res)
;;--Dot wide-character
    ftres = True
    ftres@fontColor = "red"
    fontX(wks, plot, "谁说不能写中文", 0.3, 0.5, ftres) 
    fontX(wks, plot, "让我来告诉你们", 0.3, 0.4, ftres)
    draw(plot)
end
