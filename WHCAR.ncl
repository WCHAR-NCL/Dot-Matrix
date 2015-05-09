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
;--DEBUG MODEL
    if(debug)then
        ; print(fcsv(110:130,:))
        print("WCHAR: "+charArr+" ZConal-Code: "+id(:, 0)+"   Bit-Code: "+id(:, 0))
    end if
;;--Return acquired zone-bit-code (ZBC) of wide-character    
    return(id)
end

;;==============================================================================
undef("fontX")
procedure fontX(wks, plot, font, x, y, res)
local wks, plot, font, x, y
begin
;;--Get ID from Table
    charArr = str_split_by_length(font, 3)
    ArrLen = dimsizes(charArr)
    id = encode(charArr, "GB2312")
    offset = ( (id(:, 0)-1) * 94 + id(:, 1)-1) * 128
;--DEBUG MODEL
    if(debug)then
        print("WCHAR: "+charArr+"   offset: "+offset)
    end if
;;--Read dot data
    f = "/home/SVane/Data/HZK32"
    dat = cbinread(f, -1, "byte")
    fdot = new((/ArrLen, 32, 32/), byte)
    do i = 0, ArrLen-1
        buffer = getbitsone(dat(offset(i):offset(i)+127))
        fdot(i, :, :) = reshape(buffer, (/32,32/))
    end do
;;--Setup plotting
    plres = True
    plres@gsMarkerColor = res@fontColor
    plres@gsMarkerIndex = 1
    plres@gsMarkerSizeF = 0.005
    print("Dotting")
    do c = 0, ArrLen-1
        do i = 0, dimsizes(fdot(0, :, 0))-1
            do j = 0, dimsizes(fdot(0, 0,:))-1
                if(fdot(c, i, j).eq.1  )then
                    gsn_polymarker(wks, plot, x+j*0.002+c*0.1, y-i*0.002, plres)
                end if
            end do
        end do
    end do
end