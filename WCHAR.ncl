debug = True

;;==============================================================================
undef("encode")
function encode(charArr, Table)
local fTable, charArr
begin
;;--Retrieve GB2312 encode table
    if(Table.eq."GB2312")then
        fTable = asciiread(Table, -1, "string")
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
    sizeDM = res@fontPixelSize
    lenDM = sizeDM/8*sizeDM
    font = "HZK"+sizeDM+res@fontName
;;--Get ID from Table
    charArr = str_split_by_length(wchar, 3)
    ArrLen = dimsizes(charArr)
    id = encode(charArr, "GB2312")
    offset = ( (id(:, 0)-1) * 94 + id(:, 1)-1) * lenDM
;--DEBUG MODEL
    if(debug)then
        print("WCHAR: "+charArr+" ZConal-Code: "+id(:, 0)+\
                    "   Bit-Code: "+id(:, 0)+"   offset: "+offset)
    end if
;;--Setup plotting
    plres = True                            ; Setup the WCHAR resource
    plres@gsMarkerColor = res@fontColor     ; Read the font color setting
    plres@gsMarkerIndex = 1                 ; little dot
    plres@gsMarkerSizeF = 0.0001            ; I want fine the dot
    plres@gsMarkerThicknessF = 0.3          ; More finer dot
    plres@tfPolyDrawOrder = "Draw"          ; Weird!!! It have no effect!!!
    fh = res@fontHeightF                    ; Read the font height setting
    fspace = res@fontHeightF*35*sizeDM/32.  ; space between adjacent WCHAR 
    xoffset = sizeDM*fh+ArrLen*fspace/4.    ; font offset to Just the WCHAR 
    yoffset = sizeDM*fh/4.                  ; font offset to Just the WCHAR
    print("Dotting")

    xloc = onedtond(fspan(x-xoffset, x+sizeDM*fh-xoffset, sizeDM), (/sizeDM, sizeDM/))
    yloc = transpose(onedtond(fspan(y+yoffset, y-sizeDM*fh+yoffset, sizeDM), (/sizeDM, sizeDM/)))
;;--Read dot data
    f = "/home/SVane/Data/FontLib/HZK"+sizeDM+"/"+font
    dat = cbinread(f, -1, "byte")
    fdot = new((/sizeDM, sizeDM/), byte)
    do i = 0, ArrLen-1
        buffer = getbitsone(dat(offset(i):offset(i)+lenDM-1))
        fdot = reshape(buffer, (/sizeDM,sizeDM/))
        maXDM =  mask(xloc, fdot, 1) 
        maYDM = mask(yloc, fdot, 1)
        gsn_polymarker(wks, plot, maXDM+i*fspace, maYDM, plres)        
    end do

end