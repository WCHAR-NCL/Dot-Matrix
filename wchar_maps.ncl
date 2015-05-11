load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "WCHAR.ncl"
begin

mapColor = (/ "(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
              "(/0.9254902,  0.9254902,  0.9254902]/)", \
              "(/0.62352941,  0.7372549 ,  0.89019608/)", \
              "(/0.54901961,  0.54901961,  0.54901961/)", \
              "(/0.4745098 ,  0.63529412,  0.85098039/)"/)


    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@vpXF = 0.1
    res@vpYF = 0.9
    res@vpWidthF = 0.8
    res@vpHeightF = 0.8

    ; res@mpMinLatF = 10
    ; res@mpMaxLatF = 65
    ; res@mpMinLonF = 85
    ; res@mpMaxLonF = 140

    res@mpProjection        = "LambertConformal"
    res@mpLambertParallel1F = 30.
    res@mpLambertParallel2F = 60.
    res@mpLambertMeridianF  = 110.
    res@mpLimitMode       = "Corners"            ; choose range of map
    res@mpLeftCornerLatF  = 10
    res@mpLeftCornerLonF  = 90
    res@mpRightCornerLatF = 45
    res@mpRightCornerLonF = 155
    ; res@pmTickMarkDisplayMode = "Always"

    res@mpGridSpacingF = 10
    ; res@mpGridLineDashPattern  = 1
    res@mpGridAndLimbOn = True
    ; res@mpGridLineColor = "grey"



    res@mpLandFillColor = "Transparent"
    res@mpLandFillColor = 2
    res@mpOceanFillColor = 3
    res@mpInlandWaterFillColor = 3

  ; res@mpDataSetName         = "Earth..4"   ; This new database contains
  ;                                         ; divisions for other countries.
  ; res@mpDataBaseVersion     = "Hi'''///;ghRes"  ; Medium resolution database
  ; res@mpOutlineOn           = True         ; Turn on map outlines
  ; res@mpOutlineSpecifiers   = (/"China:states","Taiwan"/)       ;China:states
  ; res@mpGeophysicalLineColor      = "grey60"
  ; res@mpGeophysicalLineThicknessF = 0.02
  ; res@mpNationalLineColor         = "grey0"
  ; res@mpNationalLineThicknessF    = 0.06
  ; res@mpProvincialLineColor       = 4
  ; res@mpProvincialLineThicknessF  = 0.02
  
  res@mpGridLineColor      = "grey40"
  res@mpGridLineThicknessF = 0.5
  res@mpFillDrawOrder = "PreDraw"

;----set tick mark
  res@tmXBMajorLengthF      = 0.
  res@tmYLMajorLengthF      = 0.
  res@tmXTMajorLengthF      = 0.
  res@tmYRMajorLengthF      = 0.
  res@tmBorderLineColor     = "white"
  res@tmXBLabelFontHeightF  = 0.01
  res@tmXTLabelFontHeightF  = 0.01
  res@tmYLLabelFontHeightF  = 0.01
  res@tmYRLabelFontHeightF  = 0.01
  res@tmXBOn = False
  res@tmXTOn = False
  res@tmYLOn = False
  res@tmYROn = False
  ; res@tmXBBorderOn = False
  ; res@tmXTBorderOn = False
  ; res@tmYLBorderOn = False
  ; res@tmYRBorderOn = False
  res@tmBorderThicknessF = 1



    wks = gsn_open_wks("ps", "mapMicapsWCHAR")
    gsn_define_colormap(wks, mapColor)  
    plot = gsn_csm_map(wks, res)
    ; drawNDCGrid(wks)

    ; river = addfile("/home/SVane/software/ncl-6.3.0/China/River4_polyline.shp", "r")
    stateL = "./ShapeFile/bou2_4l.shp"
    riverP = "./ShapeFile/hyd1_4p.shp"
    riverL = "./ShapeFile/hyd1_4l.shp"
    Prov = "./ShapeFile/res1_4m.shp"

    shpres = True
    shpres@gsLineColor = 4
    shpres@gsLineThicknessF = 0.06
    shpres@tfPolyDrawOrder = "Draw"

    shpS = gsn_add_shapefile_polylines(wks, plot, stateL, shpres)
    shpres@gsLineColor = 5
    shpres@gsLineThicknessF = 0.2
    shp = gsn_add_shapefile_polygons(wks, plot, riverP, shpres)
    shl = gsn_add_shapefile_polylines(wks, plot, riverL, shpres)

    txres = True
    txres@txFontHeightF = 0.008
    txres@txFontColor = "grey40"
    xpos = (/135, 135, 135/)
    ypos = (/30, 40, 50/)
    dum = gsn_add_text(wks, plot, tostring(ypos), xpos, ypos, txres)
;;--Dot the province location    
    f = addfile(Prov,"r")
    ; ProvCN = f->NAME      ; GBK encoding...
    ProvCX = tofloat(f->x)
    ProvCY = tofloat(f->y) 
    pmres = True
    pmres@gsMarkerIndex = 16
    pmres@gsMarkerSizeF = 0.005
    pmres@gsMarkerColor = "red"
    pmres@tfPolyDrawOrder = "PostDraw"
    provloc = gsn_add_polymarker(wks, plot, ProvCX, ProvCY, pmres)
;;--Must Do
    draw(plot)
;;--Draw province name
    ProvCN = (/"北京", "天津", "石家庄", "太原", "呼和浩特", "沈阳", "长春", \
               "哈尔滨", "上海", "南京", "杭州", "合肥", "福州", "南昌", \
                "济南", "郑州", "武汉", "长沙", "广州", "南宁", "海口", \
                "成都", "重庆", "贵阳", "昆明", "拉萨", "西安", "兰州", \
                "西宁", "银川", "乌鲁木齐", "台北", "澳门", "香港"/)
    ftres = True
    ftres@fontColor = "grey30"
    ftres@fontSize = 6
    ftres@fontThicknessF = 0.3
    ftres@fontPixelSize = 40
    ; ftres@fontJust = "CenterCenter"
    ftres@fontName = "S"
    ftres@fontAngle = 0.
    ftres@fontYoffset = 0.01
    do i = 0,33
      fontX(wks, plot, ProvCN(i), ProvCX(i), ProvCY(i), ftres)
    end do 
;;-- A title
    ftres@fontHeightF = 0.03
    ftres@fontThicknessF = 0.5
    ftres@fontPixelSize = 40
    ftres@fontSize = 12
    ftres@fontName = "H"
    ftres@fontNDC = True
    fontX(wks, plot, "NCL图形中文打印示例", 0.5, 0.8, ftres)
;;--Finally frame the workstation
    frame(wks)
end
