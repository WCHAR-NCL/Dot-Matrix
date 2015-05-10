; gid = 0
; DotMat = new(100, graphic)
debug = True
;;==============================================================================
undef("checkChar")
function checkChar(wchar)
local wchar
begin
    alpha = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    charArr = tochar(wchar)
    flag = True
    do i = 0, dimsizes(charArr)-1
        if (isStrSubset(alpha, tostring(charArr(i)))) then
            flag = False
            break
        end if
    end do
    return(flag)
end

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
    font = "HZK"+sizeDM+res@fontName
    alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
;;--Get ID from Table
    if(checkChar(wchar))then
        charArr = str_split_by_length(wchar, 3)
    else
        charX = tochar(wchar)
        charArr = new(dimsizes(charX), string)
        ix = 0
        i = 0
        do while(i.lt.dimsizes(charX))
            if(isStrSubset(alpha, tostring(charX(i))))then
                charArr(ix) = tostring(charX(i))
                i = i+1
            else
                charArr(ix) = tostring(charX(i:i+2))
                i = i+3
            end if
            ix = ix+1
        end do
        charArr := charArr(ind(.not.ismissing(charArr)))
    end if
    ArrLen = dimsizes(charArr)
    id = encode(charArr, DotDir+"FontLib/CodeTable/", "GB2312")
    offset = ( (id(:, 0)-1) * 94 + id(:, 1)-1) * lenDM
;--DEBUG MODEL
    if(debug)then
        print("WCHAR: "+charArr+" ZConal-Code: "+id(:, 0)+\
                    "   Bit-Code: "+id(:, 1)+"   offset: "+offset)
    end if
;;--Calculate Dot-Matrix location in NDC coordinate
    ; getvalues wks
    ;     wkPaperWidthF: PaperW
    ;     wkPaperHeightF: PaperH
    ;     wkPaperSize: 
    ; end getvalues
    ; print(PaperW+"  H= "+PaperH)
    fontW_NDC = res@fontSize*dpi/72.*19/1920./8.5
    fh = res@fontHeightF                                    ; Read the font height setting
    fspace = fontW_NDC                                      ; space between adjacent WCHAR 
    xoffset = (ArrLen*(fontW_NDC+fspace)-fspace)/2.         ; font offset to Just the WCHAR 
    yoffset = fontW_NDC/2.                                  ; font offset to Just the WCHAR
    if(.not.(isatt(res, "fontNDC")) .or. res@fontNDC.eq.False)then
        datatondc(plot, x, y, x, y)
    end if
    print("x= "+x+" y= "+y)
    xloc = onedtond(fspan(x-xoffset, x+fontW_NDC-xoffset, sizeDM), (/sizeDM, sizeDM/))
    yloc = transpose(onedtond(fspan(y+yoffset, y-fontW_NDC+yoffset, sizeDM), (/sizeDM, sizeDM/)))
;;;;;;;;;heyl ;;;;;;;;;;;;;;
	;if isatt((res,"FontAngle")) then 
	  ;;recalculate the xloc and yloc to rotate angle
	  rad=4.*atan(1.)/180.
	  angle=tofloat(res@fontAngle)*rad
	;;center xy
          cx=x-xoffset+fontW_NDC/2.
	  cy=y+yoffset+fontW_NDC/2.
          new_xloc=cx+(xloc-cx)*cos(angle)-(yloc-cy)*sin(angle)
          new_yloc=cy+(xloc-cx)*sin(angle)+(yloc-cy)*cos(angle)
;;;;;;;;;;heyl  ;;;;;;;;;;;;;; 

;;--Setup plotting
    plres = True                                            ; Setup the WCHAR resource
    plres@gsMarkerColor = res@fontColor                     ; Read the font color setting
    plres@gsMarkerIndex = 1                                 ; little dot
    plres@gsMarkerSizeF = 0.0001                            ; I want fine the dot
    plres@gsMarkerThicknessF = res@FontThicknessF           ; More finer dot
    plres@tfPolyDrawOrder = "PostDraw"                          ; Weird!!! It have no effect!!!
;;--Read dot data and Dotting
    print("Dotting")
    f = DotDir+"FontLib/HZK"+sizeDM+"/"+font
    dat = cbinread(f, -1, "byte")
    do i = 0, ArrLen-1
        buffer = getbitsone(dat(offset(i):offset(i)+lenDM-1))
        fdot = reshape(buffer, (/sizeDM,sizeDM/))
;        maXDM =  mask(xloc, fdot, 1) 
;        maYDM = mask(yloc, fdot, 1)
        maXDM =  mask(new_xloc, fdot, 1)    ;;heyl
        maYDM = mask(new_yloc, fdot, 1)     ;;heyl
        ; DotMat(gid) = gsn_add_polymarker(wks, plot, maXDM+i*fspace, maYDM, plres)
        ; gid = gid+1 
	  
        gsn_polymarker_ndc(wks, maXDM+i*fspace*cos(angle), maYDM+i*fspace*sin(angle), plres)  ;;heyl   
      ;  gsn_polymarker_ndc(wks, maXDM+i*fspace, maYDM, plres)     
    end do

end

;;==============================================================================
; undef("fontV")
; procedure fontV(str:string)
; begin
;     id = encode(str, "GB2312")
;     print(id)
; end 
