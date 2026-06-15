axlCmdRegister("TemplateCompareQC" 'TemplateCompareQC)
procedure(TemplateCompareQC()
axlShell("Done")
SymList = nil
foreach(SymDtlp axlDBGetDesign() ->symbols
    SymRef = SymDtlp->refdes
    if(SymRef == nil then
        SymRef = "Dummy Symbol"
    )
        SymXY = sprintf(nil "(%.2f %.2f)", car(SymDtlp->xy), cadr(SymDtlp->xy))
        SymName = SymDtlp->name
        SymPinCount = length(SymDtlp->pins)
        SymRot = sprintf(nil "%.2f", SymDtlp->rotation)
        SymMir = SymDtlp->mirrorType
        if(SymMir == "YES" then
            SymMirVal = "Mirrored"
        else
            SymMirVal = "Not Mirrored"
        )
        SymData = sprintf(nil "%s,%s,%s,%d,%s,%s",SymRef, SymXY, SymName, SymPinCount, SymRot, SymMirVal)
        when(SymData push(SymData SymList))
    
)
SymList = unique(SymList)

PinList = nil
PadStackNameList = nil
foreach(SymDtlp1 axlDBGetDesign() ->symbols
    foreach(PinDtlp SymDtlp1->pins
        PinSymRefDt = PinDtlp->parent->refdes  
        if(PinSymRefDt == nil then
            PinSymRefDt = "Dummy Symbol"
        )
            PinXY = sprintf(nil "(%.2f %.2f)", car(PinDtlp->xy), cadr(PinDtlp->xy))
            PinRefNum = sprintf(nil "%s.%s", PinSymRefDt, PinDtlp->number)
            PinRot = sprintf(nil "%.2f", PinDtlp->rotation)
            PinName = PinDtlp->name
            PinSymMir = PinDtlp->mirrorType
            if(PinSymMir == "YES" then
                PinSymMirVal = "Mirrored"
            else
                PinSymMirVal = "Not Mirrored"
            )
            PinData = sprintf(nil "%s,%s,%s,%s,%s",PinRefNum, PinXY, PinName, PinRot, PinSymMirVal)
            when(PinData push(PinData PinList))
            when(PinName push(PinName PadStackNameList))
    )
)

PinList = unique(PinList)

originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlClearSelSet()
axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
Vias = axlGetSelSet(axlAddSelectAll())
ViaList = nil
foreach(ViaDtlp Vias
    ViaXY = sprintf(nil "(%.2f %.2f)", car(ViaDtlp->xy), cadr(ViaDtlp->xy))
    ViaName = ViaDtlp->name
    ViaData = sprintf(nil "%s,%s", ViaXY, ViaName)
    when(ViaData push(ViaData ViaList))
    when(ViaName push(ViaName PadStackNameList))
)
axlVisibleSet(originalVisible)

ViaList = unique(ViaList)

PadStackNameList = unique(PadStackNameList)

PadBrd1List = nil
PadParaBrd1List = nil
foreach(PadStackNameListlp PadStackNameList
    PadId = axlLoadPadstack(PadStackNameListlp)

    MainPad_PadSupp = PadId->padSuppresion
    if(MainPad_PadSupp == nil then
        MainPad_PadSupp = "NOT ALLOWED"
    else
        MainPad_PadSupp = "ALLOWED"
    )

    MainPad_Fix = PadId->fixed
    if(MainPad_Fix == nil then
        MainPad_Fix = "NOT FIXED"
    else
        MainPad_Fix = "FIXED"
    )

    MainPad_UVia = PadId->uvia
    if(MainPad_UVia == nil then
        MainPad_UVia = "U VIA IS NIL"
    else
        MainPad_UVia = "U VIA FOUND"
    )

    MainPad_KO = PadId->keepout
    if(MainPad_KO == nil then
        MainPad_KO = "KEEPOUT IS NIL"
    else
        MainPad_KO = "KEEPOUT FOUND"
    )

    MainPad_DrillDia = PadId->drillDiameter
    MainPad_DrillDia = sprintf(nil "%.1f", MainPad_DrillDia)

    MainPad_FigName = upperCase(PadId->drillFigureName)

    MainPad_WH = list(PadId->drillFigureWidth PadId->drillFigureHeight)
    MainPad_WH = sprintf(nil "(%.1f %.1f)", car(MainPad_WH), cadr(MainPad_WH))

    MainPad_DrillOff = PadId->drillOffset
    MainPad_DrillOff = sprintf(nil "(%.1f %.1f)", car(MainPad_DrillOff), cadr(MainPad_DrillOff))

    MainPad_Plating = upperCase(PadId->plating)

    MainPad_DrillChar = PadId->drillChar
    if(MainPad_DrillChar == nil then
        MainPad_DrillChar = "NIL"
    else
        MainPad_DrillChar = upperCase(MainPad_DrillChar)
    )

    MainPad_MulDrillDt = PadId->multiDrillData
    if(MainPad_MulDrillDt == nil then
        MainPad_MulDrillDt = "MULTI DRILL NOT ENABLED"
    else
        MainPad_MulDrillDt = "MULTI DRILL ENABLED"
    )

    MainPad_Type = upperCase(PadId->holeType)

    MainPad_SWSH = list(PadId->drillSizeWidth PadId->drillSizeHeight)
    MainPad_SWSH = sprintf(nil "(%.1f %.1f)", car(MainPad_SWSH), cadr(MainPad_SWSH))

    MainPad_Tol = PadId->holeTolerance
    MainPad_Tol = sprintf(nil "(%.1f %.1f)", car(MainPad_Tol), cadr(MainPad_Tol))

    MainPad_DrillNS = PadId->drillNonStandard
    if(MainPad_DrillNS == nil then
        MainPad_DrillNS = "NIL"
    else
        MainPad_DrillNS = upperCase(MainPad_DrillNS)
    )

    PadParaDt = sprintf(nil "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", upperCase(PadStackNameListlp), MainPad_PadSupp, MainPad_Fix, MainPad_UVia, MainPad_KO, MainPad_DrillDia, MainPad_FigName, MainPad_WH, MainPad_DrillOff, MainPad_Plating, MainPad_DrillChar, MainPad_MulDrillDt, MainPad_Type, MainPad_SWSH, MainPad_Tol, MainPad_DrillNS)
    when(PadParaDt push(PadParaDt PadParaBrd1List))

    PadData = PadId ->pads
    foreach(PadDatalp PadData
        Pad_Layer = cadr(parseString(PadDatalp ->layer, "/"))
        Pad_DrillDia = PadDatalp->bBox
        Pad_Type = PadDatalp->type
        Pad_Geo = PadDatalp->figureName
        ValA = car(Pad_DrillDia)
        ValB = cadr(Pad_DrillDia)
        xLen = car(ValB) - car(ValA)
        Pad_Width = sprintf(nil "%.1f", xLen) 
        yLen = cadr(ValB) - cadr(ValA)
        Pad_Height = sprintf(nil "%.1f", yLen) 
        PadDataPass = sprintf(nil "%s,%s,%s,%s,%s,%s", PadStackNameListlp, Pad_Layer, Pad_Type, Pad_Geo, Pad_Width, Pad_Height)
        when(PadDataPass push(PadDataPass PadBrd1List))
    )
)
PadBrd1List = unique(PadBrd1List)

PadParaBrd1List = unique(PadParaBrd1List)

ShapeBrd1List = nil
ShapeVoidBrd1List = nil
foreach(Shp_SymDtlp axlDBGetDesign()->symbols
    Shp_SymRef = Shp_SymDtlp->refdes
    if(Shp_SymRef == nil then
        Shp_SymRef = "Dummy Symbol"
    )
    SymChildList = Shp_SymDtlp->children
    SymEtchChildList = Shp_SymDtlp->etchChildren
    SymChildListFinal = append(SymChildList SymEtchChildList)

    if(neq(SymChildListFinal nil) then
        foreach(SymChildListlp SymChildListFinal
            isShape = SymChildListlp->objType
            if(equal(isShape "shape") then
                ShpLyr = SymChildListlp->layer
                ShpXYPoint = SymChildListlp->bBox
                ShpSeg = SymChildListlp->segments
                ShpSegLen = length(ShpSeg)

                Shp_Void = SymChildListlp->voids
                Shp_VoidLen = length(Shp_Void)
                if(Shp_Void !=  nil then
                    foreach(Shp_Voidlp Shp_Void
                        Shp_VoidlpXY = Shp_Voidlp->bBox
                        Shp_VoidlpLyr = Shp_Voidlp->layer
                        Shp_VoidlpSeg = Shp_Voidlp->segments
                        Shp_VoidlpSegCount = length(Shp_VoidlpSeg)
                        ShpVoidLenCount = 0
                        foreach(Shp_VoidlpSeglp Shp_VoidlpSeg
                            Shp_VoidlpSegLen = axlDBGetLength(Shp_VoidlpSeglp)
                            ShpVoidLenCount = ShpVoidLenCount + Shp_VoidlpSegLen
                        )
                        ShpVoidDt = sprintf(nil "%s,%s,%d,%.2f,%L", Shp_SymRef, Shp_VoidlpLyr, Shp_VoidlpSegCount, ShpVoidLenCount, Shp_VoidlpXY)
                        when(ShpVoidDt push(ShpVoidDt ShapeVoidBrd1List))
                    )
                )


                ShpRect = SymChildListlp->isRect
                ShpLenAdd = 0

                proplistGet=axlDBGetProperties(SymChildListlp)

                PropList = nil
                foreach(proplistlp proplistGet
                    StrVal = buildString(proplistlp " : ")
                    when(StrVal push(StrVal PropList))
                )
                PropList = unique(PropList)
                PropListSort = sort(PropList 'alphalessp)

                if(ShpRect == nil then
                    foreach(ShpSeglp ShpSeg
                        ShpSegLenDt = axlDBGetLength(ShpSeglp)
                        ShpLenAdd = ShpLenAdd + ShpSegLenDt
                    )
                    
                    ShpData = sprintf(nil "%s,%s,%d,%d,%.2f,%L,%L", Shp_SymRef, ShpLyr, ShpSegLen, Shp_VoidLen, ShpLenAdd, ShpXYPoint, PropListSort)
                    when(ShpData push(ShpData ShapeBrd1List))
                else
                    foreach(ShpSegLp1 ShpSeg
                        Point1Xpoint = xCoord(car(ShpSegLp1->startEnd))
                        Point1Ypoint = yCoord(car(ShpSegLp1->startEnd))
                        Point2Xpoint = xCoord(cadr(ShpSegLp1->startEnd))
                        Point2Ypoint = yCoord(cadr(ShpSegLp1->startEnd))

                        dx = Point2Xpoint - Point1Xpoint
                        dy = Point2Ypoint - Point1Ypoint

                        dx1 = dx * dx
                        dy1 = dy * dy

                        dxy = dx1 + dy1
                        LenVal = sqrt(dxy)
                        ShpLenAdd = ShpLenAdd + LenVal
                    )

                    ShpData = sprintf(nil "%s,%s,%d,%d,%.2f,%L,%L", Shp_SymRef, ShpLyr, ShpSegLen, Shp_VoidLen, ShpLenAdd, ShpXYPoint, PropListSort)
                    when(ShpData push(ShpData ShapeBrd1List))
                )
            )
        )
    )
)

ShapeBrd1List = unique(ShapeBrd1List)
ShapeVoidBrd1List = unique(ShapeVoidBrd1List)

currentDesign = axlGetDrawingName()
axlUIConfirm("Please Select The Template Brd File..")
file=axlDMFileBrowse(nil nil ?optFilters "BRD Files|*.brd|")
if(file then
when(axlOpenDesignForBatch(file "wf")
    TempSymList = nil
    foreach(SymDtlp axlDBGetDesign() ->symbols
        SymRef = SymDtlp->refdes
        if(SymRef == nil then
            SymRef = "Dummy Symbol"
        )
            SymXY = sprintf(nil "(%.2f %.2f)", car(SymDtlp->xy), cadr(SymDtlp->xy))
            SymName = SymDtlp->name
            SymPinCount = length(SymDtlp->pins)
            SymRot = sprintf(nil "%.2f", SymDtlp->rotation)
            SymMir = SymDtlp->mirrorType
            if(SymMir == "YES" then
                SymMirVal = "Mirrored"
            else
                SymMirVal = "Not Mirrored"
            )
            SymData = sprintf(nil "%s,%s,%s,%d,%s,%s",SymRef, SymXY, SymName, SymPinCount, SymRot, SymMirVal)
            when(SymData push(SymData TempSymList))
    )
    TempSymList = unique(TempSymList)

    TempPinList = nil
    TempPadStackNameList = nil
    foreach(SymDtlp1 axlDBGetDesign() ->symbols
        foreach(PinDtlp SymDtlp1->pins
            PinSymRefDt = PinDtlp->parent->refdes 
            if(PinSymRefDt == nil then
                PinSymRefDt = "Dummy Symbol"
            )
                PinXY = sprintf(nil "(%.2f %.2f)", car(PinDtlp->xy), cadr(PinDtlp->xy))
                PinRefNum = sprintf(nil "%s.%s", PinSymRefDt, PinDtlp->number)
                PinRot = sprintf(nil "%.2f", PinDtlp->rotation)
                PinName = PinDtlp->name
                PinSymMir = PinDtlp->mirrorType
                if(PinSymMir == "YES" then
                    PinSymMirVal = "Mirrored"
                else
                    PinSymMirVal = "Not Mirrored"
                )
                PinData = sprintf(nil "%s,%s,%s,%s,%s",PinRefNum, PinXY, PinName, PinRot, PinSymMirVal)
                when(PinData push(PinData TempPinList))
                when(PinName push(PinName TempPadStackNameList))
        )
    )
    TempPinList = unique(TempPinList)
    
    TemporiginalVisible = axlVisibleGet()
    axlVisibleDesign(t)
    axlClearSelSet()
    axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
    Vias = axlGetSelSet(axlAddSelectAll())
    TempViaList = nil
    foreach(ViaDtlp Vias
        ViaXY = sprintf(nil "(%.2f %.2f)", car(ViaDtlp->xy), cadr(ViaDtlp->xy))
        ViaName = ViaDtlp->name
        ViaData = sprintf(nil "%s,%s", ViaXY, ViaName)
        when(ViaData push(ViaData TempViaList))
        when(ViaName push(ViaName TempPadStackNameList))
    )
    axlVisibleSet(TemporiginalVisible)
    TempViaList = unique(TempViaList)

    TempPadStackNameList = unique(TempPadStackNameList)

    PadBrd2List = nil
    PadParaBrd2List = nil
    foreach(TempPadStackNameListlp TempPadStackNameList
        TempPadId = axlLoadPadstack(TempPadStackNameListlp)

        MainPad_PadSupp = TempPadId->padSuppresion
        if(MainPad_PadSupp == nil then
            MainPad_PadSupp = "NOT ALLOWED"
        else
            MainPad_PadSupp = "ALLOWED"
        )

        MainPad_Fix = TempPadId->fixed
        if(MainPad_Fix == nil then
            MainPad_Fix = "NOT FIXED"
        else
            MainPad_Fix = "FIXED"
        )

        MainPad_UVia = TempPadId->uvia
        if(MainPad_UVia == nil then
            MainPad_UVia = "U VIA IS NIL"
        else
            MainPad_UVia = "U VIA FOUND"
        )

        MainPad_KO = TempPadId->keepout
        if(MainPad_KO == nil then
            MainPad_KO = "KEEPOUT IS NIL"
        else
            MainPad_KO = "KEEPOUT FOUND"
        )

        MainPad_DrillDia = TempPadId->drillDiameter
        MainPad_DrillDia = sprintf(nil "%.1f", MainPad_DrillDia)

        MainPad_FigName = upperCase(TempPadId->drillFigureName)

        MainPad_WH = list(TempPadId->drillFigureWidth TempPadId->drillFigureHeight)
        MainPad_WH = sprintf(nil "(%.1f %.1f)", car(MainPad_WH), cadr(MainPad_WH))

        MainPad_DrillOff = TempPadId->drillOffset
        MainPad_DrillOff = sprintf(nil "(%.1f %.1f)", car(MainPad_DrillOff), cadr(MainPad_DrillOff))

        MainPad_Plating = upperCase(TempPadId->plating)

        MainPad_DrillChar = TempPadId->drillChar
        if(MainPad_DrillChar == nil then
            MainPad_DrillChar = "NIL"
        else
            MainPad_DrillChar = upperCase(MainPad_DrillChar)
        )

        MainPad_MulDrillDt = TempPadId->multiDrillData
        if(MainPad_MulDrillDt == nil then
            MainPad_MulDrillDt = "MULTI DRILL NOT ENABLED"
        else
            MainPad_MulDrillDt = "MULTI DRILL ENABLED"
        )

        MainPad_Type = upperCase(TempPadId->holeType)

        MainPad_SWSH = list(TempPadId->drillSizeWidth TempPadId->drillSizeHeight)
        MainPad_SWSH = sprintf(nil "(%.1f %.1f)", car(MainPad_SWSH), cadr(MainPad_SWSH))

        MainPad_Tol = TempPadId->holeTolerance
        MainPad_Tol = sprintf(nil "(%.1f %.1f)", car(MainPad_Tol), cadr(MainPad_Tol))

        MainPad_DrillNS = TempPadId->drillNonStandard
        if(MainPad_DrillNS == nil then
            MainPad_DrillNS = "NIL"
        else
            MainPad_DrillNS = upperCase(MainPad_DrillNS)
        )

        PadParaDt = sprintf(nil "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", upperCase(TempPadStackNameListlp), MainPad_PadSupp, MainPad_Fix, MainPad_UVia, MainPad_KO, MainPad_DrillDia, MainPad_FigName, MainPad_WH, MainPad_DrillOff, MainPad_Plating, MainPad_DrillChar, MainPad_MulDrillDt, MainPad_Type, MainPad_SWSH, MainPad_Tol, MainPad_DrillNS)
        when(PadParaDt push(PadParaDt PadParaBrd2List))

        TempPadData = TempPadId ->pads
        foreach(TempPadDatalp TempPadData
            TempPad_Layer = cadr(parseString(TempPadDatalp ->layer, "/"))
            TempPad_DrillDia = TempPadDatalp->bBox
            TempPad_Type = TempPadDatalp->type
            TempPad_Geo = TempPadDatalp->figureName
            TempValA = car(TempPad_DrillDia)
            TempValB = cadr(TempPad_DrillDia)
            TempxLen = car(TempValB) - car(TempValA)
            TempPad_Width = sprintf(nil "%.1f", TempxLen) 
            TempyLen = cadr(TempValB) - cadr(TempValA)
            TempPad_Height = sprintf(nil "%.1f", TempyLen) 
            TempPadDataPass = sprintf(nil "%s,%s,%s,%s,%s,%s", TempPadStackNameListlp, TempPad_Layer, TempPad_Type, TempPad_Geo, TempPad_Width, TempPad_Height)
            when(TempPadDataPass push(TempPadDataPass PadBrd2List))
        )
    )
    PadBrd2List = unique(PadBrd2List)

    ShapeBrd2List = nil
    ShapeVoidBrd2List = nil
    foreach(Shp_SymDtlp axlDBGetDesign()->symbols
        Shp_SymRef = Shp_SymDtlp->refdes
        if(Shp_SymRef == nil then
            Shp_SymRef = "Dummy Symbol"
        )
        SymChildList = Shp_SymDtlp->children
        SymEtchChildList = Shp_SymDtlp->etchChildren
        SymChildListFinal = append(SymChildList SymEtchChildList)
        if(neq(SymChildListFinal nil) then
            foreach(SymChildListlp SymChildListFinal
                isShape = SymChildListlp->objType
                if(equal(isShape "shape") then
                    ShpLyr = SymChildListlp->layer
                    ShpXYPoint = SymChildListlp->bBox
                    ShpSeg = SymChildListlp->segments
                    ShpSegLen = length(ShpSeg)


                    Shp_Void = SymChildListlp->voids
                    Shp_VoidLen = length(Shp_Void)
                    if(Shp_Void !=  nil then
                        foreach(Shp_Voidlp Shp_Void
                            Shp_VoidlpXY = Shp_Voidlp->bBox
                            Shp_VoidlpLyr = Shp_Voidlp->layer
                            Shp_VoidlpSeg = Shp_Voidlp->segments
                            Shp_VoidlpSegCount = length(Shp_VoidlpSeg)
                            ShpVoidLenCount = 0
                            foreach(Shp_VoidlpSeglp Shp_VoidlpSeg
                                Shp_VoidlpSegLen = axlDBGetLength(Shp_VoidlpSeglp)
                                ShpVoidLenCount = ShpVoidLenCount + Shp_VoidlpSegLen
                            )
                            ShpVoidDt = sprintf(nil "%s,%s,%d,%.2f,%L", Shp_SymRef, Shp_VoidlpLyr, Shp_VoidlpSegCount, ShpVoidLenCount, Shp_VoidlpXY)
                            when(ShpVoidDt push(ShpVoidDt ShapeVoidBrd2List))
                        )
                    )

                    ShpRect = SymChildListlp->isRect
                    ShpLenAdd = 0

                    proplistGet=axlDBGetProperties(SymChildListlp)

                    PropList = nil
                    foreach(proplistlp proplistGet
                        StrVal = buildString(proplistlp " : ")
                        when(StrVal push(StrVal PropList))
                    )
                    PropList = unique(PropList)
                    PropListSort = sort(PropList 'alphalessp)


                    if(ShpRect == nil then
                        foreach(ShpSeglp ShpSeg
                            ShpSegLenDt = axlDBGetLength(ShpSeglp)
                            ShpLenAdd = ShpLenAdd + ShpSegLenDt
                        )
                        
                        ShpData = sprintf(nil "%s,%s,%d,%d,%.2f,%L,%L", Shp_SymRef, ShpLyr, ShpSegLen, Shp_VoidLen, ShpLenAdd, ShpXYPoint, PropListSort)          
                        when(ShpData push(ShpData ShapeBrd2List))
                    else
                        foreach(ShpSegLp1 ShpSeg
                            Point1Xpoint = xCoord(car(ShpSegLp1->startEnd))
                            Point1Ypoint = yCoord(car(ShpSegLp1->startEnd))
                            Point2Xpoint = xCoord(cadr(ShpSegLp1->startEnd))
                            Point2Ypoint = yCoord(cadr(ShpSegLp1->startEnd))

                            dx = Point2Xpoint - Point1Xpoint
                            dy = Point2Ypoint - Point1Ypoint

                            dx1 = dx * dx
                            dy1 = dy * dy

                            dxy = dx1 + dy1
                            LenVal = sqrt(dxy)
                            ShpLenAdd = ShpLenAdd + LenVal
                        )

                        ShpData = sprintf(nil "%s,%s,%d,%d,%.2f,%L,%L", Shp_SymRef, ShpLyr, ShpSegLen, Shp_VoidLen, ShpLenAdd, ShpXYPoint, PropListSort)
                        when(ShpData push(ShpData ShapeBrd2List))
                    )
                )
            )
        )
    )

    ShapeBrd2List = unique(ShapeBrd2List)
    ShapeVoidBrd2List = unique(ShapeVoidBrd2List)
)

;Symbol MissMatch

SymMissingInTemp = nil
SymMissingInTemp = setof(item1, SymList, !member(item1, TempSymList))

SymMissingInMain = nil
SymMissingInMain = setof(item2, TempSymList, !member(item2, SymList))


;Pin MissMatch

PinMissingInTemp = nil
PinMissingInTemp = setof(item3, PinList, !member(item3, TempPinList))

PinMissingInMain = nil
PinMissingInMain = setof(item4, TempPinList, !member(item4, PinList))

;Pad MissMatch

PadMissingInTemp = nil
PadMissingInTemp = setof(item5, PadBrd1List, !member(item5, PadBrd2List))

PadMissingInMain = nil
PadMissingInMain = setof(item6, PadBrd2List, !member(item6, PadBrd1List))

;Pad Para MissMatch

PadParaMissingInTemp = nil
PadParaMissingInTemp = setof(item7, PadParaBrd1List, !member(item7, PadParaBrd2List))

PadParaMissingInMain = nil
PadParaMissingInMain = setof(item8, PadParaBrd2List, !member(item8, PadParaBrd1List))


;Shape MissMatch

ShpMissingInTemp = nil
ShpMissingInTemp = setof(item7, ShapeBrd1List, !member(item7, ShapeBrd2List))

ShpMissingInMain = nil
ShpMissingInMain = setof(item8, ShapeBrd2List, !member(item8, ShapeBrd1List))


;Via MissMatch

ViaMissingInTemp = nil
ViaMissingInTemp = setof(item9, ViaList, !member(item9, TempViaList))

ViaMissingInMain = nil
ViaMissingInMain = setof(item10, TempViaList, !member(item10, ViaList))


;Shape VoidMissMatch

ShpVoidMissingInTemp = nil
ShpVoidMissingInTemp = setof(item11, ShapeVoidBrd1List, !member(item11, ShapeVoidBrd2List))

ShpVoidMissingInMain = nil
ShpVoidMissingInMain = setof(item12, ShapeVoidBrd2List, !member(item12, ShapeVoidBrd1List))


TempdesignName = axlCurrentDesign()

axlOpenDesignForBatch(currentDesign "wf")

axlShell("Done")

MainError1 = append(PadMissingInTemp PinMissingInTemp)
MainError = append(SymMissingInTemp MainError1)
MainErrorUp = append(PadParaMissingInTemp MainError)
MainErrorUp1 = append(ShpMissingInTemp MainErrorUp)
MainErrorUp2 = append(ViaMissingInTemp MainErrorUp1)
MainErrorUp3 = append(ShpVoidMissingInTemp MainErrorUp2)

if(MainErrorUp3 != nil then
	logfile = "MissingInTemp.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", designName)
	fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    if(SymMissingInTemp != nil then
        fprintf(port, "%s\n\n", "SYMBOL - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-25s %-25s %-25s %-25s %-25s  %-25s \n\n", "REFDES", "XY LOCATION", "SYM NAME", "PIN COUNT", "ROTATION", "MIRROR")
        foreach(SymMissingInTemplp SymMissingInTemp
            SymMissingInTemp_filt = parseString(SymMissingInTemplp ",")
            fprintf(port, "%-25s %-25s %-25s %-25s %-25s  %-25s \n", nth(0 SymMissingInTemp_filt), nth(1 SymMissingInTemp_filt), nth(2 SymMissingInTemp_filt), nth(3 SymMissingInTemp_filt), nth(4 SymMissingInTemp_filt), nth(5 SymMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "SYMBOL - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )
    
    if(PinMissingInTemp != nil then
        fprintf(port, "%s\n\n", "PIN - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n\n", "PIN", "XY LOCATION", "NAME", "ROTATION", "MIRROR")
        foreach(PinMissingInTemplp PinMissingInTemp
            PinMissingInTemp_filt = parseString(PinMissingInTemplp ",")
            fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 PinMissingInTemp_filt), nth(1 PinMissingInTemp_filt), nth(2 PinMissingInTemp_filt), nth(3 PinMissingInTemp_filt), nth(4 PinMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "PIN - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )
    
    if(PadMissingInTemp != nil then
        fprintf(port, "%s\n\n", "PAD - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s \n\n", "PAD NAME", "LAYER", "TYPE", "GEOMETRY", "WIDTH", "HEIGHT")
        foreach(PadMissingInTemplp PadMissingInTemp
            PadMissingInTemp_filt = parseString(PadMissingInTemplp ",")
            fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s\n", nth(0 PadMissingInTemp_filt), nth(1 PadMissingInTemp_filt), nth(2 PadMissingInTemp_filt), nth(3 PadMissingInTemp_filt), nth(4 PadMissingInTemp_filt), nth(5 PadMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "PAD - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(PadParaMissingInTemp != nil then
        fprintf(port, "%s\n\n", "PAD PARAMETERS - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s \n\n", "PAD NAME", "SUPPERSION", "FIXED", "U VIA", "KEEPOUT", "DIAMETER", "FIGURE NAME", "WIDTH AND HEIGHT", "OFFSET", "PLATING", "DRILL CHARACTER", "MULTI DRILL DATA", "HOLE TYPE", "DRILL(WIDTH AND HEIGHT)", "HOLE TOLERENCE", "DRILL NON STANDARD")
        foreach(PadParaMissingInTemplp PadParaMissingInTemp
            PadParaMissingInTemp_filt = parseString(PadParaMissingInTemplp ",")
            fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s\n", nth(0 PadParaMissingInTemp_filt), nth(1 PadParaMissingInTemp_filt), nth(2 PadParaMissingInTemp_filt), nth(3 PadParaMissingInTemp_filt), nth(4 PadParaMissingInTemp_filt), nth(5 PadParaMissingInTemp_filt), nth(6 PadParaMissingInTemp_filt), nth(7 PadParaMissingInTemp_filt), nth(8 PadParaMissingInTemp_filt), nth(9 PadParaMissingInTemp_filt), nth(10 PadParaMissingInTemp_filt), nth(11 PadParaMissingInTemp_filt), nth(12 PadParaMissingInTemp_filt), nth(13 PadParaMissingInTemp_filt), nth(14 PadParaMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "PAD PARAMETERS - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(ShpMissingInTemp != nil then
        fprintf(port, "%s\n\n", "SHAPE - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-35s %-35s %-35s %-35s %-35s %-35s %-35s\n\n", "REFDES", "LAYER", "SEG COUNT", "VOID COUNT", "SHAPE LENGTH", "XY POINT", "PROPERTIES")
        foreach(ShpMissingInTemplp ShpMissingInTemp
            ShpMissingInTemp_filt = parseString(ShpMissingInTemplp ",")
            fprintf(port, "%-35s %-35s %-35s %-35s %-35s %-35s %-35s\n", nth(0 ShpMissingInTemp_filt), nth(1 ShpMissingInTemp_filt), nth(2 ShpMissingInTemp_filt), nth(3 ShpMissingInTemp_filt), nth(4 ShpMissingInTemp_filt), nth(5 ShpMissingInTemp_filt), nth(6 ShpMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "SHAPE - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(ShpVoidMissingInTemp != nil then
        fprintf(port, "%s\n\n", "VOID - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-35s %-35s %-35s %-35s %-35s\n\n", "REFDES", "LAYER", "VOID SEG COUNT", "VOID LENGTH", "XY POINT")
        foreach(ShpVoidMissingInTemplp ShpVoidMissingInTemp
            ShpVoidMissingInTemp_filt = parseString(ShpVoidMissingInTemplp ",")
            fprintf(port, "%-35s %-35s %-35s %-35s %-35s \n", nth(0 ShpVoidMissingInTemp_filt), nth(1 ShpVoidMissingInTemp_filt), nth(2 ShpVoidMissingInTemp_filt), nth(3 ShpVoidMissingInTemp_filt), nth(4 ShpVoidMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "VOID - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(ViaMissingInTemp != nil then
        fprintf(port, "%s\n\n", "VIA - DIFFERENCE IN TEMPLATE BRD FILE :")
        fprintf(port, "%-25s %-25s  \n\n", "XY LOCATION", "VIA NAME")
        foreach(ViaMissingInTemplp ViaMissingInTemp
            ViaMissingInTemp_filt = parseString(ViaMissingInTemplp ",")
            fprintf(port, "%-25s %-25s  \n", nth(0 ViaMissingInTemp_filt), nth(1 ViaMissingInTemp_filt))
        )
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port, "%s\n", "VIA - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port, "\n\n")
        fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

		
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Found In Work Brd And Missing In Template Brd", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Difference found in work Brd File..")
)



TempError1 = append(PadMissingInMain PinMissingInMain)
TempError = append(SymMissingInMain TempError1)
TempErrorUp = append(PadParaMissingInMain TempError)
TempErrorUp1 = append(ShpMissingInMain TempErrorUp)
TempErrorUp2 = append(ViaMissingInMain TempErrorUp1)

if(TempErrorUp2 != nil then
	logfile1 = "MissingInWork.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port1 = axlDMOpenLog(logfile1)
	fprintf(port1, "Design name: %s\n", TempdesignName)
	fprintf(port1, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    if(SymMissingInMain != nil then
        fprintf(port1, "%s\n\n", "SYMBOL - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-25s %-25s %-25s %-25s %-25s  %-25s \n\n", "REFDES", "XY LOCATION", "SYM NAME", "PIN COUNT", "ROTATION", "MIRROR")
        foreach(SymMissingInMainlp SymMissingInMain
            SymMissingInMain_filt = parseString(SymMissingInMainlp ",")
            fprintf(port1, "%-25s %-25s %-25s %-25s %-25s  %-25s \n", nth(0 SymMissingInMain_filt), nth(1 SymMissingInMain_filt), nth(2 SymMissingInMain_filt), nth(3 SymMissingInMain_filt), nth(4 SymMissingInMain_filt), nth(5 SymMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "SYMBOL - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )
    
    if(PinMissingInMain != nil then
        fprintf(port1, "%s\n\n", "PIN - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-25s %-25s %-25s %-25s %-25s \n\n", "PIN", "XY LOCATION", "NAME", "ROTATION", "MIRROR")
        foreach(PinMissingInMainlp PinMissingInMain
            PinMissingInMain_filt = parseString(PinMissingInMainlp ",")
            fprintf(port1, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 PinMissingInMain_filt), nth(1 PinMissingInMain_filt), nth(2 PinMissingInMain_filt), nth(3 PinMissingInMain_filt), nth(4 PinMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "PIN - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )
    
    if(PadMissingInMain != nil then
        fprintf(port1, "%s\n\n", "PAD - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-25s %-25s %-25s %-25s %-25s %-25s  \n\n", "PAD NAME", "LAYER", "TYPE", "GEOMETRY", "WIDTH", "HEIGHT")
        foreach(PadMissingInMainlp PadMissingInMain
            PadMissingInMain_filt = parseString(PadMissingInMainlp ",")
            fprintf(port1, "%-25s %-25s %-25s %-25s %-25s %-25s \n", nth(0 PadMissingInMain_filt), nth(1 PadMissingInMain_filt), nth(2 PadMissingInMain_filt), nth(3 PadMissingInMain_filt), nth(4 PadMissingInMain_filt), nth(5 PadMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "PAD - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(PadParaMissingInMain != nil then
        fprintf(port1, "%s\n\n", "PAD PARAMETERS - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s \n\n", "PAD NAME", "SUPPERSION", "FIXED", "U VIA", "KEEPOUT", "DIAMETER", "FIGURE NAME", "WIDTH AND HEIGHT", "OFFSET", "PLATING", "DRILL CHARACTER", "MULTI DRILL DATA", "HOLE TYPE", "DRILL(WIDTH AND HEIGHT)", "HOLE TOLERENCE", "DRILL NON STANDARD")
        foreach(PadParaMissingInMainlp PadParaMissingInMain
            PadParaMissingInMain_filt = parseString(PadParaMissingInMainlp ",")
            fprintf(port1, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s %-25s\n", nth(0 PadParaMissingInMain_filt), nth(1 PadParaMissingInMain_filt), nth(2 PadParaMissingInMain_filt), nth(3 PadParaMissingInMain_filt), nth(4 PadParaMissingInMain_filt), nth(5 PadParaMissingInMain_filt), nth(6 PadParaMissingInMain_filt), nth(7 PadParaMissingInMain_filt), nth(8 PadParaMissingInMain_filt), nth(9 PadParaMissingInMain_filt), nth(10 PadParaMissingInMain_filt), nth(11 PadParaMissingInMain_filt), nth(12 PadParaMissingInMain_filt), nth(13 PadParaMissingInMain_filt), nth(14 PadParaMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "PAD PARAMETERS- NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(ShpMissingInMain != nil then
        fprintf(port1, "%s\n\n", "SHAPE - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-35s %-35s %-35s %-35s %-35s %-35s %-35s\n\n", "REFDES", "LAYER", "SEG COUNT", "VOID COUNT", "SHAPE LENGTH", "XY POINT", "PROPERTIES")
        foreach(ShpMissingInMainlp ShpMissingInMain
            ShpMissingInMain_filt = parseString(ShpMissingInMainlp ",")
            fprintf(port1, "%-35s %-35s %-35s %-35s %-35s %-35s %-35s\n", nth(0 ShpMissingInMain_filt), nth(1 ShpMissingInMain_filt), nth(2 ShpMissingInMain_filt), nth(3 ShpMissingInMain_filt), nth(4 ShpMissingInMain_filt), nth(5 ShpMissingInMain_filt), nth(6 ShpMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "SHAPE - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(ShpVoidMissingInMain != nil then
        fprintf(port1, "%s\n\n", "VOID - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-35s %-35s %-35s %-35s %-35s\n\n", "REFDES", "LAYER", "VOID SEG COUNT", "VOID LENGTH", "XY POINT")
        foreach(ShpVoidMissingInMainlp ShpVoidMissingInMain
            ShpVoidMissingInMain_filt = parseString(ShpVoidMissingInMainlp ",")
            fprintf(port1, "%-35s %-35s %-35s %-35s %-35s \n", nth(0 ShpVoidMissingInMain_filt), nth(1 ShpVoidMissingInMain_filt), nth(2 ShpVoidMissingInMain_filt), nth(3 ShpVoidMissingInMain_filt), nth(4 ShpVoidMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "VOID - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )

    if(ViaMissingInMain != nil then
        fprintf(port1, "%s\n\n", "VIA - DIFFERENCE IN WORK BRD FILE :")
        fprintf(port1, "%-25s %-25s  \n\n", "XY LOCATION", "VIA NAME")
        foreach(ViaMissingInMainlp ViaMissingInMain
            ViaMissingInMain_filt = parseString(ViaMissingInMainlp ",")
            fprintf(port1, "%-25s %-25s  \n", nth(0 ViaMissingInMain_filt), nth(1 ViaMissingInMain_filt))
        )
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    else
        fprintf(port1, "%s\n", "VIA - NO ERROR : NO DIFFERENCE FOUND")
        fprintf(port1, "\n\n")
        fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
    )
		
	axlDMClose(port1)
	axlUIViewFileCreate(logfile1, "Found In Template Brd And Missing In Work Brd", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Difference found in Template Brd File..")
)

else
    axlShell("Done")
    axlUIConfirm("Cancelled..!")
)
)