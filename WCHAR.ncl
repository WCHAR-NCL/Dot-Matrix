;;******************************************************************************
;;-------------Developers-------------
;;      SHEN Wenqiang  (沈文强)    NJU
;;      HE Yongli      (何永利)    LZU 
;;      FANG Huan      (方欢)    　IAP
;;      ZHAO Yang      (赵阳)    　CAMS
;;      FU Zhipeng     (付志鹏)    NJU
;;-----------Copyright Clarify--------
;; Copyright©2015 [SHEN Wenqiang, HE Yongli, FANG Huan, ZHAO Yang, FU Zhipeng]
;; email: wchar_ncl@163.com
;; latest revise at 2015-5
;;******************************************************************************
;;==============================================================================
;;--Global variables list
debug = False
;;--Load useful lib file
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;;==============================================================================


;;==============================================================================
;; Check input string, if it include chinese font, return False
undef("fontCheck")
function fontCheck(wchar)
begin

    intChar = toint(tochar(wchar))
    if(max(intChar).lt.128)then
        return False
    else
        return True
    end if
end


;;==============================================================================
undef("fontX")
procedure fontX(wks, plot, wchar, x, y, ftres)
local wks, plot, wchar, x, y, dum, sizeDM, lenDM, id, offset, charArr, ArrLen
begin
;;--Define Default Attribute
    res = True
    res@fontQuality = "High"
    res@fontSize = 14
    res@fontColor = "black"
    res@fontName = "S"
    res@fontEncoding = "utf8"
    res@fontXoffsetF = 0.
    res@fontYoffsetF = 0.
    res@fontJust = "CenterCenter"
    res@fontAngleF = 0.
    res@fontNDC = False
    res = ftres
;;--Setup some const value
    ; fontS = (/12, 17, 25, 30, 35, 48, 60, 73, 97/)    ; Related font Size
    fontL = ispan(16, 128, 8)                           ; all possible font lib
    Quality = (/"XLow", "Low", "Medium", "High", "ExtraHigh"/) ; font Quality
    DpiArr = (/96., 120., 160., 180., 320./)  ; DPI related to font Quality
    ThickArr = (/1, 0.9, 0.85, 0.5, 0.4/)     ; MarkerThicknessF related to font Quality
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;--Choose a proper Dot Font lib
    DPI = DpiArr(ind(Quality.eq.res@fontQuality))  ; Get DPI base on the font Quality
    Require = ceil(res@fontSize/72.*DPI)           ; Require dot matrix size 
    Get = ind(fontL.ge.Require)                    ; Possible dot matrix size
    if(.not.all(ismissing(Get)))then
        sizeDM = fontL(Get(2))                     ; index the minimum possible dot matrix 
    else
        print("Warnning: Required Dot Matrix excess all possible value, Use 128 Dot Font")
        sizeDM = 128
    end if
;;--Setup plotting
    plres = True                                   ; Setup the WCHAR resource
    plres@gsMarkerColor = res@fontColor            ; Read the font color setting
    plres@gsMarkerIndex = 1                        ; little dot
    plres@gsMarkerSizeF = 1./DPI/8.5               ; DPI dependent 
    plres@gsMarkerThicknessF = ThickArr(ind(Quality.eq.res@fontQuality))
;;--Calculate font width in NDC coordinate
    fontW = res@fontSize/72./8.5    ; default paper size ("letter")
    fspace = fontW                  ; space between adjacent WCHAR, set to Zero
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DotDir = "./"
    dimDM = (/sizeDM, sizeDM/)
    lenDM = sizeDM/8*sizeDM
    font = "HZK"+sizeDM+res@fontName
;;--charecter check method is proposed by FANG Huan (IAP, 11 May)
;;--split algorithm of half wide and wide char is designed by SHEN Wenqiang (NJU, 11 May)
    charLen = 3
    if(res@fontEncoding.eq."GBK")then
        charLen = 2
    end if
    intChar = toint(tochar(wchar))
    if(min(intChar).gt.127)then
        charArr = str_split_by_length(wchar, charLen)
        fID = ispan(0, dimsizes(charArr)-1, 1)
    else
        halfID = ind(intChar.le.126)  ; half width char index in raw char
        fullID = ind(intChar.gt.126)  ; full width char index in raw char
        charID = array_append_record(halfID, fullID(::charLen), 0)
        qsort(charID)
        hID = get1Dindex(charID, halfID)            ; half width char index in true char
        fID = get1Dindex(charID, fullID(::charLen)) ; full width char index in true char
        charMap = where(intChar(charID).gt.126, charLen, 1)
        charArr = str_split_by_length(wchar, charMap)
;;------Mixed wchar and half char is finished by FANG Huan (IAP, 12 May) 
;;------Setup plotting for half char
        txres = True                         ; Setup the half text resource
        txres@txFontColor = res@fontColor    ; Read the font color setting
        txres@txFontHeightF = fontW*0.9     ; the fontheight will be  modified later
        if(isatt(res, "fontAngle"))then
            txres@txAngleF = res@fontAngleF
        end if
    end if
    ArrLen = dimsizes(charArr)
;;--Get ID from Table or Calculation
    if(res@fontEncoding.eq."utf8")then
;;------Retrieve GB2312 encode table and calculate wchar offset in font file
        fTable = asciiread(DotDir+"FontLib/CodeTable/GB2312", -1, "string")
        fcsv = str_split_csv(fTable, " ", 0)
        locChar = get1Dindex(ndtooned(fcsv), charArr(fID))
        offset = (locChar-(locChar/119+1)*18-locChar/17) * lenDM 
    else if(res@fontEncoding.eq."GBK")
;;------Calculate the Zone-Bit Code of WCHAR and then offset in font file 
        id = toint(tochar(charArr(fID)))-160
        offset = ( (id(:, 0)-1) * 94 + id(:, 1)-1) * lenDM
    end if
    end if
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;--Get @fontJust attribute and calulate offset at x and y direction 
    Just = (/"topLeft", "CenterLeft", "BottomLeft", "TopCenter", "CenterCenter", \
             "BottomCenter", "TopRight", "CenterRight", "BottomRight"/)
    centerx = (dimsizes(fID)*0.1+ArrLen*0.9)*fontW
    offsetx = (/0., 0, 0, centerx/2., centerx/2., centerx/2., centerx, centerx, centerx/)
    offsety = (/0., fontW/2., fontW, 0., fontW/2., fontW, 0., fontW/2., fontW/)
    xoffset = offsetx(ind(Just.eq.res@fontJust))  ; font offset to Just the WCHAR
    yoffset = offsety(ind(Just.eq.res@fontJust))  ; font offset to Just the WCHAR
;;--Check @fondNDC attribute and transform the data coord. to NDC coord.
    if(.not.res@fontNDC)then
        datatondc(plot, x, y, x, y)
    end if
;;--Get @fontXoffset and @fontYoffset attribute and add offsets to x, y
    x = x+res@fontXoffsetF
    y = y+res@fontYoffsetF
;;--Calculate Dot-Matrix location in NDC coordinate
    xloc = onedtond(fspan(x-xoffset, x-xoffset+fontW, sizeDM), dimDM)
    yloc = transpose(onedtond(fspan(y+yoffset, y+yoffset-fontW, sizeDM), dimDM))
;;--Get @fontAngle attribute and do coordinate transform
;;--Finished by HE Yongli (May 11 2015)
    DEGTORAD = 0.017453292519943
    angle = tofloat(res@fontAngleF)*DEGTORAD
    if (tofloat(res@fontAngleF).ne.0.) then
        ;;center xy
        cx = x-xoffset+ArrLen*fontW/2.
        cy = y+yoffset-fontW/2.
        ;;recalculate the xloc and yloc to rotate angle
        xloc_R = cx+(xloc-cx)*cos(angle)-(yloc-cy)*sin(angle)
        yloc_R = cy+(xloc-cx)*sin(angle)+(yloc-cy)*cos(angle)
        delete([/xloc, yloc/])
        xloc = xloc_R
        yloc = yloc_R
    end if
;--DEBUG MODEL
    if(debug)then
        print("Size of one pixel: "+1./DPI+" inch")
        print("Font Size: "+res@fontSize/72.+" inch")
        print("Need: "+res@fontSize/72.*DPI+" pixel dot matrix")
        print("Use:  "+sizeDM+" pixel dot matrix")
    end if
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;--Read dot data and Dotting
    print("~~~~~~~~~~~~~Dotting~~~~~~~~~~~~~~~")
    dat = cbinread(DotDir+"FontLib/"+res@fontName+"/"+font, -1, "byte")
    fspace = 0.0   ; count space for WCHAR
    fNum = 0       ; count full Char number
    do i = 0, ArrLen-1
        if(any(fID.eq.i))then
;;----------Dotting the full width character
            fdot  = reshape(getbitsone(dat(offset(fNum):offset(fNum)+lenDM-1)), dimDM)
            maXDM =  mask(xloc, fdot, 1)
            maYDM = mask(yloc, fdot, 1)
            gsn_polymarker_ndc(wks, maXDM+fspace*cos(angle), maYDM+fspace*sin(angle), plres)  ;;heyl   
            fspace = fspace+fontW
            fNum = fNum+1
        else if(any(hID.eq.i))then
;;--------------text the half width character
                gsn_text_ndc(wks, charArr(i), max(xloc)*2/5.0+min(xloc)*3/5.0+\
                fspace*cos(angle), max(yloc)*1/2.0+min(yloc)*1/2.0+\
                fspace*sin(angle), txres)  ;; FANG Huan   
                fspace = fspace+fontW*0.90 
            end if
        end if
    end do
end


;;==============================================================================
;; loop to write 1-d wide-char array 
undef("fontArray")
procedure fontArray(wks, plot, wchar, xarr, yarr, ftres)
begin
    do i = 0, dimsizes(wchar)-1
        if (dimsizes(yarr).eq.1) then
            fontX(wks, plot, wchar(i), xarr(i), yarr, ftres)
        else if (dimsizes(xarr).eq.1) then
            fontX(wks, plot, wchar(i), xarr, yarr(i), ftres)
        else
            fontX(wks, plot, wchar(i), xarr(i), yarr(i), ftres)
        end if
        end if
    end do
end


;;==============================================================================
;; fontTitle retrive tiMainString, gsnLeftString, gsnRightString, tiXAxisString,
;; tiYAxisString and check if it includes chinese font, then attach it to plot
undef("fontTitle")
procedure fontTitle(wks, plot, res)
begin
hasMainString = isatt(res,"tiMainString").and.fontCheck(res@tiMainString)
hasLeftString = isatt(res,"tiXAxisString").and.fontCheck(res@gsnLeftString)
hasRightString = isatt(res,"tiYAxisString").and.fontCheck(res@gsnRightString)
hasXAxisString = isatt(res,"tiXAxisString").and.fontCheck(res@tiXAxisString)
hasYAxisString = isatt(res,"tiYAxisString").and.fontCheck(res@tiYAxisString)
hasXBLabels = isatt(res,"tmXBLabels").and.fontCheck(res@tmXBLabels)
hasYLLabels = isatt(res,"tmYLLabels").and.fontCheck(res@tmYLLabels)
print(hasXBLabels)
;;--Reset    
    if(hasMainString)then
        setvalues plot
            "tiMainString": ""
        end setvalues
    end if
    if(hasLeftString)then
        setvalues plot
            "gsnLeftString" : ""
        end setvalues
    end if
    if(hasRightString)then
        setvalues plot
            "gsnRightString" : ""
        end setvalues
    end if
    if(hasXAxisString)then
        setvalues plot
            "tiXAxisString"  : ""
        end setvalues
    end if
    if(hasYAxisString)then
        setvalues plot
            "tiYAxisString"  : ""
        end setvalues
    end if
    if(hasXBLabels)then
        setvalues plot
            "tmXBLabels"  : onedtond("", dimsizes(res@tmXBLabels))
        end setvalues
    end if
    if(hasYLLabels)then
        setvalues plot
            "tmYLLabels"  : onedtond("", dimsizes(res@tmYLLabels))
        end setvalues
    end if
;;--
    getvalues plot
        "vpXF"          : vpx
        "vpYF"          : vpy
        "vpWidthF"      : vpw
        "vpHeightF"     : vph
        "tmXBValues"    : XBV
        "tmYLValues"    : YLV
        "tmXBMajorLengthF": tXBML
        "tmYLMajorLengthF": tYLML
        "tmXTMajorOutwardLengthF" : tXTMOL
    end getvalues
;;~~~~~~~~~~~~~~~~~~~~Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasMainString)then
        ftres = True
        ftres@fontJust = "BottomCenter"
        ftres@fontSize = 20
        ftres@fontNDC = True
        fontX(wks, plot, res@tiMainString, vpx+vpw/2., vpy+4*tXTMOL, ftres)
    end if
    if(hasLeftString)then
        ftres = True
        ftres@fontJust = "BottomLeft"
        ftres@fontSize = 16
        ftres@fontNDC = True
        fontX(wks, plot, res@gsnLeftString, vpx, vpy+tXTMOL, ftres)
    end if
    if(hasRightString)then
        ftres = True
        ftres@fontJust = "BottomRight"
        ftres@fontSize = 16
        ftres@fontNDC = True
        fontX(wks, plot, res@gsnRightString, vpx+vpw, vpy+tXTMOL, ftres)
    end if

;;~~~~~~~~~~~~~~~X Axis String and Labels~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasXAxisString)then
        ftres = True
        ftres@fontJust = "CenterCenter"
        ftres@fontSize = 16
        ftres@fontNDC = True
        XBV_NDC := XBV
        YLV_NDC := XBV
        datatondc(plot, XBV, onedtond(YLV(0), dimsizes(XBV)), XBV_NDC, YLV_NDC)
        fontX(wks, plot, res@tiXAxisString, vpx+vpw/2., YLV_NDC(0)-6*tXBML, ftres)
    end if 
    if(hasXBLabels)then
        print("Font XBLabels")
        ftres = True
        ftres@fontJust = "TopCenter"
        ftres@fontSize = 12
        ftres@fontNDC = True
        ftres@fontAngleF = 0
        XBV_NDC := XBV
        YLV_NDC := XBV
        datatondc(plot, XBV, onedtond(YLV(0), dimsizes(XBV)), XBV_NDC, YLV_NDC)
        fontArray(wks, plot, res@tmXBLabels, XBV_NDC, YLV_NDC(0)-2*tXBML, ftres)
    end if
;;~~~~~~~~~~~~~~~Y Axis String and Labels~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if(hasYAxisString)then
        ftres = True
        ftres@fontJust = "CenterCenter"
        ftres@fontSize = 16
        ftres@fontNDC = True
        ftres@fontAngleF = 90
        XBV_NDC := YLV
        YLV_NDC := YLV
        datatondc(plot, onedtond(XBV(0), dimsizes(YLV)), YLV, XBV_NDC, YLV_NDC)
        fontX(wks, plot, res@tiYAxisString, XBV_NDC(0)-6*tYLML, vpy-vph/2., ftres)
    end if
    if(hasYLLabels)then
        print("Font YLLabels")
        ftres = True
        ftres@fontJust = "CenterRight"
        ftres@fontSize = 12
        ftres@fontNDC = True
        ftres@fontAngleF = 0
        XBV_NDC := YLV
        YLV_NDC := YLV
        datatondc(plot, onedtond(XBV(0), dimsizes(YLV)), YLV, XBV_NDC, YLV_NDC)
        fontArray(wks, plot, res@tmYLLabels, XBV_NDC(0)-2*tYLML, YLV_NDC, ftres)
    end if 
end