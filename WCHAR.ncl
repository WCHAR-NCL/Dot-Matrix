;;==============================================================================
;;--Global variables list
debug = True
;;--Load useful lib file
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;;==============================================================================

;;==============================================================================
undef("encode")
function encode(charArr, TableDir, Table)
local fTable, charArr
begin
;;--Retrieve GB2312 encode table
    if(Table.eq."GB2312")then
        fTable = asciiread(TableDir+Table, -1, "string")
    end if
    fcsv = str_split_csv(fTable, " ", 0)
    ArrLen = dimsizes(charArr)
    id = new((/ArrLen,2/), integer)
    do i = 0, ArrLen-1
        x = ind(ndtooned(fcsv).eq.charArr(i))
        id(i, 0) = x/(19*7)+1
        row = x%(19*7)/19
        if(row.ne.1)then
            id(i, 1) = x%(19*7)-17-3*row
        else
            id(i, 1) = x%(19*7)-22
        end if
    end do
;;--Return acquired zone-bit-code (ZBC) of wide-character    
    return(id)
end

;;==============================================================================
undef("fontX")
procedure fontX(wks, plot, wchar, x, y, res)
local wks, plot, wchar, x, y, dum, sizeDM, lenDM, id, offset, charArr, ArrLen
begin
;;--Get @fontQuality attribute or set a default value
    if(.not.isatt(res, "fontQuality"))then
        res@fontQuality = "Medium"
    end if
;;--Get @fontSize attribute or set a default value
    if(.not.isatt(res, "fontSize"))then
        res@fontSize = 10
    end if
;;--Get @fontColor attribute or set a default value
    if(.not.isatt(res, "fontColor"))then
        res@fontColor = "black"
    end if
;;--Choose a proper Dot Font lib
    ; flib = (/12, 16, 24, 32, 40, 48, 64, 96, 128/)
    ; (/8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34/)
    if(res@fontSize.le.8)then
        sizeDM = 32
    else if(res@fontSize.le.10)then
        sizeDM = 40
    else if(res@fontSize.le.12)then
        sizeDM = 40
    else if(res@fontSize.le.14)then
        sizeDM = 64
    else if(res@fontSize.le.18)then
        sizeDM = 64
    else if(res@fontSize.le.24)then
        sizeDM = 96
    else 
        sizeDM = 128
    end if
    end if
    end if
    end if
    end if
    end if
    ; if(res@fontQuality.eq."High")then
    ;     sizeDM = 96
    ; else if (res@fontQuality.eq."Medium")then
    ;     sizeDM = 96
    ; else
    ;     sizeDM = 64
    ; end if
    ; end if
;;--Set a default fontName
    if(.not.isatt(res, "fontName"))then
        res@fontName = "S"
    end if
;;--
    DotDir = "./"
    lenDM = sizeDM/8*sizeDM
    dimDM = (/sizeDM, sizeDM/)
    font = "HZK"+sizeDM+res@fontName
<<<<<<< HEAD
;;--charecter check method is proposed by FANG Huan (IAP, 11 May)
;;--split algorithm of half wide and wide char is designed by SHEN Wenqiang (NJU, 11 May)
    charLen = 3
    if(isatt(res, "fontEncoding"))then
        charLen = 2
    end if
    print(charLen)
    charWC = toint(tochar(wchar))
    if(min(charWC).gt.127)then
        charArr = str_split_by_length(wchar, charLen)
        fID = ispan(0, dimsizes(charArr)-1, 1)
    else
        halfID = ind(charWC.le.126)  ; half width char index in raw char
        fullID = ind(charWC.gt.126)  ; full width char index in raw char
        charID = array_append_record(halfID, fullID(::charLen), 0)
=======
    txres = True                                  ; Setup the half text resource
    
;;--Get ID from Table
;;--charecter check method is improved by FANG Huan (IAP)
    charWC = tochar(wchar)
    if(min(toint(charWC)).gt.127)then
        charArr = str_split_by_length(wchar, 3)
        fullID  = ind(toint(charWC).gt.127)  ; full width char index in raw char
        fID     = fullID(::3)/3 ; full width char index in true char
        id      = encode(charArr, DotDir+"FontLib/CodeTable/", "GB2312")
        isMixed = False
    else
        halfID = ind(toint(charWC).le.127)  ; half width char index in raw char
        fullID = ind(toint(charWC).gt.127)  ; full width char index in raw char
        charNum = dimsizes(halfID)+dimsizes(fullID)/3
        charID = array_append_record (halfID, fullID(::3), 0)
>>>>>>> origin/master
        qsort(charID)
        hID = get1Dindex(charID, halfID)      ; half width char index in true char
        fID = get1Dindex(charID, fullID(::charLen)) ; full width char index in true char
        charMap = where(charWC(charID).gt.126, charLen, 1)
        charArr = str_split_by_length(wchar, charMap)
        print("half char: "+charArr(hID)+"  index: "+hID)
        print("full char: "+charArr(fID)+"  index: "+fID)
<<<<<<< HEAD
;;------Mixed wchar and half char is finished by FANG Huan (IAP, 12 May) 
;;------Setup plotting for half char
        txres = True                               ; Setup the half text resource
        txres@txFontColor= res@fontColor           ; Read the font color setting
        txres@txFontHeightF=0.01200000  ; the fontheight will be  modified later
        if(isatt(res, "fontAngle"))then
            txres@txAngleF = res@fontAngle
        end if
    end if
;;--Get ID from Table or Calculation
    ArrLen = dimsizes(charArr)
    print(charArr)
    if(.not.isatt(res, "fontEncoding"))then
        id = encode(charArr(fID), DotDir+"FontLib/CodeTable/", "GB2312")
    else if(res@fontEncoding.eq."GBK")
        id = toint(tochar(charArr(fID)))-160
    end if
    end if
=======
        id = encode(charArr(fID), DotDir+"FontLib/CodeTable/", "GB2312")

        isMixed = True
    end if
    ArrLen = dimsizes(charArr)
>>>>>>> origin/master
    offset = ( (id(:, 0)-1) * 94 + id(:, 1)-1) * lenDM
;;--Set @fontSize attribute a default value if it's not exist
    if(.not.isatt(res, "fontSize"))then
        res@fontSize = 11
    end if
;;--Calculate font width in NDC coordinate
<<<<<<< HEAD
    fontW = res@fontSize/72./8.5    ; default paper size ("letter")
    fspace = fontW                  ; space between adjacent WCHAR, set to Zero
=======
    ; getvalues wks
    ;     wkPaperWidthF: PaperW
    ;     wkPaperHeightF: PaperH
    ;     wkPaperSize: 
    ; end getvalues
    ; print(PaperW+"  H= "+PaperH)
    fontW = res@fontSize*dpi/72.*19/1920./8.5
>>>>>>> origin/master
;;--Get @fontJust attribute and calulate offset at x and y direction 
    if(isatt(res, "fontJust").and.res@fontJust.ne."CenterCenter")then
        if(res@fontJust.eq."TopLeft")then
            xoffset = 0.
            yoffset = 0.
        else if(res@fontJust.eq."TopCenter")then
                xoffset = 0.
                yoffset = fontW/2.
            end if
        end if
    else
        xoffset = (dimsizes(fID)*0.1+ArrLen*0.9)*fontW/2.         ; font offset to Just the WCHAR 
        yoffset = fontW/2.                ; font offset to Just the WCHAR
    end if
;;--Check @fontDPI attribute
    if(isatt(res, "fontDPI"))then
        DPI = res@fontDPI
    else
        DPI = 200
    end if
;;--Check @fondNDC attribute and transform the data coord. to NDC coord.
    if(.not.(isatt(res, "fontNDC")) .or. res@fontNDC.eq.False)then
        datatondc(plot, x, y, x, y)
    end if
;;--Get @fontXoffset attribute and calulate some offsets
    if(isatt(res, "fontXoffset"))then
        x = x+res@fontXoffset
    end if
;;--Get @fontYoffset attribute and calulate some offsets
    if(isatt(res, "fontYoffset"))then
        y = y+res@fontYoffset
    end if
;;--Calculate Dot-Matrix location in NDC coordinate
    xloc = onedtond(fspan(x-xoffset, x-xoffset+fontW, sizeDM), dimDM)
    yloc = transpose(onedtond(fspan(y+yoffset, y+yoffset-fontW, sizeDM), dimDM))
;;--Get @fontAngle attribute and do coordinate transform
;;--Finished by HE Yongli (May 11 2015)
    if (isatt(res,"fontAngle")) then
        ;;recalculate the xloc and yloc to rotate angle
        txres@txAngleF=res@fontAngle*1.0
        DEGTORAD = 0.017453292519943
        angle = tofloat(res@fontAngle)*DEGTORAD
        ;;center xy
        cx = x-xoffset+ArrLen*fontW/2.
        cy = y+yoffset-fontW/2.
        xloc_R = cx+(xloc-cx)*cos(angle)-(yloc-cy)*sin(angle)
        yloc_R = cy+(xloc-cx)*sin(angle)+(yloc-cy)*cos(angle)
        delete([/xloc, yloc/])
        xloc = xloc_R
        yloc = yloc_R
    else 
        angle = 0.
        txres@txAngleF=0.0
    end if
;--DEBUG MODEL
    if(debug)then
<<<<<<< HEAD
        print("WCHAR: "+charArr(fID)+" ZConal-Code: "+id(:, 0)+\
                    "   Bit-Code: "+id(:, 1)+"   offset: "+offset)
=======
        if(isMixed)then
            ; debug for Mix Full and Half Char
            print("WCHAR: "+charArr(fID)+" ZConal-Code: "+id(:, 0)+\
                        "   Bit-Code: "+id(:, 1)+"   offset: "+offset)
        else
            ; debug for Full Char
            print("WCHAR: "+charArr+" ZConal-Code: "+id(:, 0)+\
                        "   Bit-Code: "+id(:, 1)+"   offset: "+offset)
        end if
>>>>>>> origin/master
        print("x= "+x+" y= "+y)
    end if
;;--Setup plotting
<<<<<<< HEAD
    plres = True                                   ; Setup the WCHAR resource
    plres@gsMarkerColor = res@fontColor            ; Read the font color setting
    plres@gsMarkerIndex = 1                        ; little dot
    ; plres@gsMarkerSizeF = 0.001/DPI*res@fontSize^2           ; I want the finest dots
    ; plres@gsMarkerThicknessF = 0.001/DPI*res@fontSize^2      ; finest dots
    plres@gsMarkerSizeF = 0.0000001           ; I want the finest dots
    plres@gsMarkerThicknessF = 0.0000001      ; finest dots
;;--Read dot data and Dotting
    print("Dotting")
    dat = cbinread(DotDir+"FontLib/HZK"+sizeDM+"/"+font, -1, "byte")

    fspace = 0.0   ; count space for WCHAR
    fNum = 0       ; count full Char number
    maXDM = xloc   ; set for half Char in the begin of the string
    maYDM = yloc
    do i = 0, ArrLen-1
        if(any(fID.eq.i))then
            fdot  = reshape(getbitsone(dat(offset(fNum):offset(fNum)+lenDM-1)), dimDM)
            maXDM =  mask(xloc, fdot, 1)
            maYDM = mask(yloc, fdot, 1)
            gsn_polymarker_ndc(wks, maXDM+fspace*cos(angle), maYDM+fspace*sin(angle), plres)  ;;heyl   
            fspace = fspace+fontW
            fNum = fNum+1
        else 
            if(any(hID.eq.i))then
                gsn_text_ndc(wks, charArr(i), max(maXDM)*2/5.0+min(maXDM)*3/5.0+\
                fspace*cos(angle), max(maYDM)*1/2.0+min(maYDM)*1/2.0+\
                fspace*sin(angle), txres)  ;; FANG Huan   
                fspace = fspace+fontW*0.90 
=======
    plres = True                                  ; Setup the WCHAR resource
    plres@gsMarkerColor = res@fontColor           ; Read the font color setting
    plres@gsMarkerIndex = 1                       ; little dot
    plres@gsMarkerSizeF = 0.0000001               ; I want the finest dots
    plres@gsMarkerThicknessF = 0.0000001          ; finest dots
    ; plres@tfPolyDrawOrder = "PostDraw"            
;;--Setup plotting for half char
    txres@txFontColor= res@fontColor           ; Read the font color setting
    txres@txFontHeightF=0.01200000  ; the fontheight will be  modified later
    ;txres@gsMarkerIndex = 1                       ; little dot
    ;txres@gsMarkerSizeF = 0.0000001               ; I want the finest dots
    ;txres@gsMarkerThicknessF = 0.0000001          ; finest dots
;;--Read dot data and Dotting
    print("Dotting")
    f = DotDir+"FontLib/HZK"+sizeDM+"/"+font
    dat = cbinread(f, -1, "byte")

    fspace=0.0 ; count space for WCHAR
    fNum=0 ;count full Char number
    maXDM =xloc_R ; set for half Char in the begin of the string
    maYDM =yloc_R

    do i = 0, ArrLen-1
        if(.not.ismissing(ind(fID.eq.i)))then
            fdot  = reshape(getbitsone(dat(offset(fNum):offset(fNum)+lenDM-1)), dimDM)
            maXDM:= mask(xloc_R, fdot, 1)
            maYDM:= mask(yloc_R, fdot, 1)
            gsn_polymarker_ndc(wks, maXDM+fspace*cos(angle), maYDM+fspace*sin(angle), plres)  ;;heyl   
            fspace = fspace+fontW
            fNum   = fNum+1
        else 
            if(.not.ismissing(ind(hID.eq.i)))then
                gsn_text_ndc(wks,charArr(i), max(maXDM)*2/5.0+min(maXDM)*3/5.0+\
                fspace*cos(angle), max(maYDM)*1/2.0+min(maYDM)*1/2.0+\
                fspace*sin(angle), txres)  ;;heyl   
                fspace=fspace+fontW*0.90
>>>>>>> origin/master
            else
                ; not use for currently
            end if
        end if
<<<<<<< HEAD
=======
    end do
>>>>>>> origin/master


    end do

end
