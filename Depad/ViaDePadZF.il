axlCmdRegister("ViaDePadZF" 'ViaDePadZF)
procedure(ViaDePadZF()
ViaNameList = nil
ViaDBIDList = nil
originalVisible = axlVisibleGet()
axlPurgePadstacks('via t)
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
axlUIConfirm("Please Select the Soldermask Shape...!")
ShpDt = axlGetSelSet(axlSelect( )) 
ShpDtlp = car(ShpDt)
DummyVal = "YES"
ChkLyr = "NO"
ShpLyr = ShpDtlp ->layer
if(ShpLyr == "PACKAGE GEOMETRY/SOLDERMASK_TOP" then
	;axlVisibleDesign(t)
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("VIA CLASS/", "TOP") t)
	axlVisibleUpdate(t)
	ChkLyr = "TOP"
	DePadName = "_TOP_DEPAD"
else
	if(ShpLyr == "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" ||  ShpLyr == "BOARD GEOMETRY/SOLDERMASK_BOTTOM" then
		;axlVisibleDesign(t)
		axlVisibleDesign(nil)
		axlVisibleLayer(strcat("VIA CLASS/", "BOTTOM") t)
		axlVisibleUpdate(t)
		ChkLyr = "BOTTOM"
		DePadName = "_BOT_DEPAD"
	else
		axlUIConfirm("Selected Shape is Not from Top Or Bottom Soldermask Shape...!")
		DummyVal = "NO"
	)

)
if(DummyVal == "YES" then
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
	ViaDt = axlGetSelSet(axlAddSelectAll())
	foreach(ViaDtlp ViaDt
		(AirGapVal = (axlAirGap ShpDtlp ViaDtlp nil 'anyLayer))
		AirGapValStr = sprintf(nil "%.1f" AirGapVal)
		if(AirGapValStr == "0.0" then
			ViaConLyr = axlDBGetConnect(ViaDtlp t)
			SkipVia = "NO"
			
				foreach(ViaConLyrlp ViaConLyr
					if(ViaConLyrlp->objType == "pin" then
						ViaLyrData = car(ViaConLyrlp->startEnd)
					else
						ViaLyrData = ViaConLyrlp->layer
					)
					
					if(ChkLyr == "TOP" then
						if(ViaLyrData == "ETCH/TOP" then
							SkipVia = "YES"
						)
					else
						if(ChkLyr == "BOTTOM" then
							if(ViaLyrData == "ETCH/BOTTOM" then
								SkipVia = "YES"
							)
						)
					)
				)
				if(SkipVia == "NO" then
					ViaNameVal = ViaDtlp->name 
					ViaDrillDia = ViaDtlp->definition->drillDiameter
					Viadata = sprintf(nil "%s,%.2f", ViaNameVal, ViaDrillDia)  
					when(Viadata push(Viadata ViaNameList))
					when(ViaDtlp push(ViaDtlp ViaDBIDList))
				)
			
		)
	)
)
ViaNameList = unique(ViaNameList)
ViaDBIDList = unique(ViaDBIDList)

FoundData = "NONFOUND"
FoundList = nil

if(ViaNameList != nil then
	foreach(ViaNameListlp ViaNameList
		ViaNameDt = nth(0 parseString(ViaNameListlp ","))
		ViaDrillDt = atof(nth(1 parseString(ViaNameListlp ",")))
		pcre_VN = pcreCompile(DePadName)
		if(pcreExecute(pcre_VN ViaNameListlp) then
			FoundData = "FOUND"
			FData = sprintf(nil "%s-%s", "IGNORED DEPAD", ViaNameListlp)
			when(FData push(FData FoundList))
		else
			val = sprintf(nil "%s%s", ViaNameDt, DePadName)
			psid = axlLoadPadstack(ViaNameDt)
			drill_data = make_axlPadStackDrill(
				?fixed                 psid->fixed
				?uvia                  psid->uvia
				?keepout              psid->keepout
				?drillDiameter         psid->drillDiameter
				?figure             psid->drillFigureName
				?figureSize         list(psid->drillFigureWidth psid->drillFigureHeight)
				?offset             psid->drillOffset
				?plating             psid->plating
				?drillChar            psid->drillChar
				?multiDrillData        psid->multiDrillData
				?holeType             psid->holeType
				?slotSize             list(psid->drillSizeWidth psid->drillSizeHeight)
				?holeTolerance         psid->holeTolerance
				?drillNonStandard    psid->drillNonStandard
			)
			pads = psid ->pads
			padList = nil
			foreach(pad, pads
				exts = pad ->bBox
				ValA = car(exts)
				ValB = cadr(exts)
				xLen = car(ValB) - car(ValA)
				yLen = cadr(ValB) - cadr(ValA)
				figureSizeA = round(xLen)
				figureSizeB = round(yLen)
				layer = cadr(parseString(pad ->layer, "/"))
				flash = unless(pad ->flash == "", pad ->flash)
				if(pad->figureName == "CIRCLE" then
					if(xLen != 0.0 && yLen != 0.0 then 
						if(ChkLyr == "TOP" then
							if(layer == "TOP" then
								newPad = make_axlPadStackPad(?layer layer, ?type pad->type, ?figure pad->figureName, ?flash flash, ?figureSize 1.0:1.0 , ?offset pad->offset)
							else
								newPad = make_axlPadStackPad(?layer layer, ?type pad->type, ?figure pad->figureName, ?flash flash, ?figureSize xLen:yLen , ?offset pad->offset)
							)
							newPadDI = make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type pad->type, ?figure pad->figureName, ?flash flash, ?figureSize xLen:yLen , ?offset pad->offset)
							padList = cons(newPad, padList)
							padList = cons(newPadDI, padList)
						else
							if(ChkLyr == "BOTTOM" then
								if(layer == "BOTTOM" then
									newPad = make_axlPadStackPad(?layer layer, ?type pad->type, ?figure pad->figureName, ?flash flash, ?figureSize 1.0:1.0 , ?offset pad->offset)
								else
									newPad = make_axlPadStackPad(?layer layer, ?type pad->type, ?figure pad->figureName, ?flash flash, ?figureSize xLen:yLen , ?offset pad->offset)
								)
								newPadDI = make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type pad->type, ?figure pad->figureName, ?flash flash, ?figureSize xLen:yLen , ?offset pad->offset)
								padList = cons(newPad, padList)
								padList = cons(newPadDI, padList)
							)
						)
						
					)
				)
			)
			UpDB = axlDBCreatePadStack(val, drill_data, padList t)
		)
	)
	a = 0
	foreach(VDBListlp ViaDBIDList
		a = a + 1
		valData = sprintf(nil, "%d - out of %d", a, length(ViaDBIDList))
		println(valData)
		UpVal = sprintf(nil "%s%s", VDBListlp->name, DePadName) 
		ViaMirType = VDBListlp->mirrorType
		if(ViaMirType == "YES" then
			axlTransformObject(VDBListlp ?mirror t)
			via = axlReplacePadstack(VDBListlp, UpVal)
		else
			via = axlReplacePadstack(VDBListlp, UpVal)
		)
	)
	axlUIConfirm("Updated...!")
else
	axlUIConfirm("No Updates found...!")
)
FoundList = unique(FoundList)
if(FoundData == "FOUND" then
	axlUIConfirm("Renamed Depad Already Found...!")
	foreach(FoundListlp FoundList
		println(FoundListlp)
	)
)

axlVisibleSet(originalVisible)
axlClearSelSet()
)