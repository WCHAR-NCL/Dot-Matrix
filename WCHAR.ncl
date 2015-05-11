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
    alpha = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    alphaID = (/16,17,18,19,20,21,22,23,24,25,33,34,35,36,37,38,39,40,41,42,\
                43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,65,66,67,68,\
                69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90/)
;;--Retrieve GB2312 encode table
    if(Table.eq."GB2312")then
        fTable = asciiread(TableDir+Table, -1, "string")
    end if
    fcsv = str_split_csv(fTable, " ", 0)
    ArrLen = dimsizes(charArr)
    id = new((/ArrLen,2/), integer)
    do i = 0, ArrLen-1
        if(isStrSubset(alpha, charArr(i)))then
            id(i, 0) = 3
            ; id(i, 1) = alphaID(ind(tochar(alpha).eq. tochar(charArr(i))))
            id(i, 1) = alphaID(str_index_of_substr(alpha, charArr(i), -1))
        else
            x = ind(ndtooned(fcsv).eq.charArr(i))
            id(i, 0) = x/(19*7)+1
            row = x%(19*7)/19
            if(row.ne.1)then
                id(i, 1) = x%(19*7)-17-3*row
            else
                id(i, 1) = x%(19*7)-22
            end if
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
    DotDir = "./"
    dpi = 96 
    sizeDM = res@fontPixelSize
    lenDM = sizeDM/8*sizeDM
    dimDM = (/sizeDM, sizeDM/)
    font = "HZK"+sizeDM+res@fontName
;;--Get ID from Table
;;--charecter check method is improved by FANG Huan (IAP)
    charWC = tochar(wchar)
    if(min(toint(charWC)).gt.127)then
        charArr = str_split_by_length(wchar, 3)
    else
        halfID = ind(toint(charWC).le.126)  ; half width char index in raw char
        fullID = ind(toint(charWC).gt.126)  ; full width char index in raw char
        charNum = dimsizes(halfID)+dimsizes(fullID)/3
        charID = array_append_record (halfID, fullID(::3), 0)
        qsort(charID)
        hID = get1Dindex(charID, halfID)      ; half width char index in true char
        fID = get1Dindex(charID, fullID(::3)) ; full width char index in true char
        charMap = where(toint(charWC(charID)).gt.126, 3, 1)
        charArr = str_split_by_length(wchar, charMap)
        print("half char: "+charArr(hID)+"  index: "+hID)
        print("full char: "+charArr(fID)+"  index: "+fID)
    end if

    ArrLen = dimsizes(charArr)
    id = encode(charArr, DotDir+"FontLib/CodeTable/", "GB2312")
    offset = ( (id(:, 0)-1) * 94 + id(:, 1)-1) * lenDM
;;--Calculate font width in NDC coordinate
    ; getvalues wks
    ;     wkPaperWidthF: PaperW
    ;     wkPaperHeightF: PaperH
    ;     wkPaperSize: 
    ; end getvalues
    ; print(PaperW+"  H= "+PaperH)
    fontW = res@fontSize*dpi/72.*19/1920./8.5
    fspace = fontW                  ; space between adjacent WCHAR, set to Zero
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
        xoffset = ArrLen*fontW/2.         ; font offset to Just the WCHAR 
        yoffset = fontW/2.                ; font offset to Just the WCHAR
    end if
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
        DEGTORAD = 0.017453292519943
        angle = tofloat(res@fontAngle)*DEGTORAD
        ;;center xy
        cx = x-xoffset+ArrLen*fontW/2.
        cy = y+yoffset-fontW/2.
        xloc_R = cx+(xloc-cx)*cos(angle)-(yloc-cy)*sin(angle)
        yloc_R = cy+(xloc-cx)*sin(angle)+(yloc-cy)*cos(angle)
    else 
        angle = 0.
    end if
;--DEBUG MODEL
    if(debug)then
        print("WCHAR: "+charArr+" ZConal-Code: "+id(:, 0)+\
                    "   Bit-Code: "+id(:, 1)+"   offset: "+offset)
        print("x= "+x+" y= "+y)
    end if    
;;--Delete some variables
    delete([/xloc, yloc/])
;;--Setup plotting
    plres = True                                  ; Setup the WCHAR resource
    plres@gsMarkerColor = res@fontColor           ; Read the font color setting
    plres@gsMarkerIndex = 1                       ; little dot
    plres@gsMarkerSizeF = 0.0000001               ; I want the finest dots
    plres@gsMarkerThicknessF = 0.0000001          ; finest dots
    ; plres@tfPolyDrawOrder = "PostDraw"            
;;--Read dot data and Dotting
    print("Dotting")
    f = DotDir+"FontLib/HZK"+sizeDM+"/"+font
    dat = cbinread(f, -1, "byte")
    do i = 0, ArrLen-1
        fdot = reshape(getbitsone(dat(offset(i):offset(i)+lenDM-1)), dimDM)
        maXDM =  mask(xloc_R, fdot, 1)
        maYDM = mask(yloc_R, fdot, 1) 
        gsn_polymarker_ndc(wks, maXDM+i*fspace*cos(angle), maYDM+i*fspace*sin(angle), plres)  ;;heyl   
    end do

end

;;==============================================================================
; undef("fontV")
; procedure fontV(str:string)
; begin
;     id = encode(str, "GB2312")
;     print(id)
; end 
