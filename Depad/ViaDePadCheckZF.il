axlCmdRegister("ViaDePadCheckZF" 'ViaDePadCheckZF)
procedure(ViaDePadCheckZF()
ErrorListDMM = nil
ErrorListNU = nil
ErrorListWU = nil
originalVisible = axlVisibleGet()
axlUIConfirm("Please Select the Soldermask Shape...!")
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
ShpDt = axlGetSelSet(axlSelect( ))
ShpDtlp = car(ShpDt)
ShpLyr = ShpDtlp ->layer
DummyVal = "YES"
ChkLyr = "NO"
if(ShpLyr == "PACKAGE GEOMETRY/SOLDERMASK_TOP" then
	;axlVisibleDesign(t)
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("VIA CLASS/", "TOP") t)
	axlVisibleUpdate(t)
	ChkLyr = "TOP"
	DePadName = "_TOP_DEPAD"
else
	if(ShpLyr == "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" || ShpLyr == "BOARD GEOMETRY/SOLDERMASK_BOTTOM" then
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
							pcre_Comp1 = pcreCompile(DePadName)
							VnameVal1 = ViaDtlp->name 
							if(pcreExecute(pcre_Comp1 VnameVal1) then
								WrongUpData = sprintf(nil, "%s,(%.2f %.2f), ERROR - _TOP_DEPAD is Updated in Top Connected Via", VnameVal1, car(ViaDtlp ->xy), cadr(ViaDtlp ->xy))
								when(WrongUpData push(WrongUpData ErrorListWU))
							else
								SkipVia = "YES"
							)
						)
					else
						if(ChkLyr == "BOTTOM" then
							if(ViaLyrData == "ETCH/BOTTOM" then
								pcre_Comp2 = pcreCompile(DePadName)
								VnameVal2 = ViaDtlp->name 
								if(pcreExecute(pcre_Comp2 VnameVal2) then
									WrongUpData1 = sprintf(nil, "%s,(%.2f %.2f), ERROR - _BOT_DEPAD is Updated in Bottom Connected Via", VnameVal2, car(ViaDtlp ->xy), cadr(ViaDtlp ->xy))
									when(WrongUpData1 push(WrongUpData1 ErrorListWU))
								else
									SkipVia = "YES"
								)
							)
						)
					)
				)
				if(SkipVia == "NO" then
					VnameVal = ViaDtlp->name 
					VDrillDia = ViaDtlp->definition->drillDiameter
					VDrillDiaStr = sprintf(nil "%.3f", VDrillDia)
					pcre_Comp = pcreCompile(DePadName)
					if(pcreExecute(pcre_Comp VnameVal) then
						psid = axlLoadPadstack(VnameVal)
						pads = psid ->pads
						padList = nil
						foreach(pad, pads
							PadLyr = cadr(parseString(pad ->layer, "/"))
							Pad_DrillDia = pad->bBox
							Pad_Type = pad->type
							ValA = car(Pad_DrillDia)
							ValB = cadr(Pad_DrillDia)
							xLen = car(ValB) - car(ValA)
							xlenStr = sprintf(nil "%.1f", xLen) 
							yLen = cadr(ValB) - cadr(ValA)
							yLenStr = sprintf(nil "%.1f", yLen) 
							if(ChkLyr == "TOP" then
								if(PadLyr == "TOP" then
									;if(xlenStr != VDrillDiaStr && yLenStr != VDrillDiaStr then
										if(xlenStr != "1.0" && yLenStr != "1.0" then
											if(Pad_Type == "REGULAR" then
												DrillMissData = sprintf(nil, "%s,(%.2f %.2f), ERROR - Drill Size is Not 1 Mil, Pad Drill --> %s", VnameVal, car(ViaDtlp ->xy), cadr(ViaDtlp ->xy), xlenStr)
												when(DrillMissData push(DrillMissData ErrorListDMM))
											)
										)
									;)	
								)
							else
								if(ChkLyr == "BOTTOM" then
									if(PadLyr == "BOTTOM" then
									;if(xlenStr != VDrillDiaStr && yLenStr != VDrillDiaStr then
										if(xlenStr != "1.0" && yLenStr != "1.0" then
											if(Pad_Type == "REGULAR" then
												DrillMissData = sprintf(nil, "%s,(%.2f %.2f), ERROR - Drill Size is Not 1 Mil, Pad Drill --> %s", VnameVal, car(ViaDtlp ->xy), cadr(ViaDtlp ->xy), xlenStr)
												when(DrillMissData push(DrillMissData ErrorListDMM))
											)
										)
									;)	
								)
								
								)
							)
						)
					else
						NameMissData = sprintf(nil, "%s,(%.2f %.2f), ERROR - %s is Not Updated", VnameVal, car(ViaDtlp ->xy), cadr(ViaDtlp ->xy), DePadName)
						when(NameMissData push(NameMissData ErrorListNU))
					)
				)
			
		)
	)
)

; Top
axlVisibleDesign(nil)
axlVisibleLayer(strcat("PACKAGE GEOMETRY/", "SOLDERMASK_TOP") t)
axlVisibleUpdate(t)

axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
ShpDtT = axlGetSelSet(axlAddSelectAll())

axlVisibleDesign(nil)
axlVisibleLayer(strcat("VIA CLASS/", "TOP") t)
axlVisibleUpdate(t)

axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
ViaDtT = axlGetSelSet(axlAddSelectAll())

ViaFoundListT = nil

foreach(ViaDtTlp ViaDtT
    foreach(ShpDtTlp ShpDtT
        (AirGapValT = (axlAirGap ShpDtTlp ViaDtTlp nil 'anyLayer))
		AirGapValStrT = sprintf(nil "%.1f" AirGapValT)
		if(AirGapValStrT == "0.0" then
            when(ViaDtTlp push(ViaDtTlp ViaFoundListT))
        )
    )

)

ViaFoundListT = unique(ViaFoundListT)
TopList = setof(item, ViaDtT, !member(item, ViaFoundListT))

; Bottom
axlVisibleDesign(nil)
axlVisibleLayer(strcat("PACKAGE GEOMETRY/", "SOLDERMASK_BOTTOM") t)
axlVisibleUpdate(t)

axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
ShpDtB = axlGetSelSet(axlAddSelectAll())

axlVisibleDesign(nil)
axlVisibleLayer(strcat("VIA CLASS/", "BOTTOM") t)
axlVisibleUpdate(t)

axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
ViaDtB = axlGetSelSet(axlAddSelectAll())

ViaFoundListB = nil

foreach(ViaDtBlp ViaDtB
    foreach(ShpDtBlp ShpDtB
        (AirGapValB = (axlAirGap ShpDtBlp ViaDtBlp nil 'anyLayer))
		AirGapValStrB = sprintf(nil "%.1f" AirGapValB)
		if(AirGapValStrB == "0.0" then
            when(ViaDtBlp push(ViaDtBlp ViaFoundListB))
        )
    )

)

ViaFoundListB = unique(ViaFoundListB)
BotList = setof(item1, ViaDtB, !member(item1, ViaFoundListB))
;FinalChkList = append(TopList BotList)

ErrorListNonShp = nil
foreach(TopListlp TopList
    ChkVia = axlDBGetPad(TopListlp "VIA CLASS/TOP" "REGULAR")
    TopXY = ChkVia ->bBox
    TopValA = car(TopXY)
    TopValB = cadr(TopXY)
    TopxLen = car(TopValB) - car(TopValA)
    TopyLen = cadr(TopValB) - cadr(TopValA)
    TopxLenStr = sprintf(nil "%.1f" TopxLen)
    if(TopxLen == TopyLen then
        if(TopxLenStr == "1.0" then
            ErrorDtT = sprintf(nil, "%s,(%.2f %.2f), ERROR - Drill Size is 1 Mil -- Depad Updated In This Via - SOLDERMASK TOP ", TopListlp->name, car(TopListlp ->xy), cadr(TopListlp ->xy))
            when(ErrorDtT push(ErrorDtT ErrorListNonShp))
        )
    )
)

foreach(BotListlp BotList
    ChkVia1 = axlDBGetPad(BotListlp "VIA CLASS/BOTTOM" "REGULAR")
    BotXY = ChkVia1 ->bBox
    BotValA = car(BotXY)
    BotValB = cadr(BotXY)
    BotxLen = car(BotValB) - car(BotValA)
    BotyLen = cadr(BotValB) - cadr(BotValA)
    BotxLenStr = sprintf(nil "%.1f" BotxLen)
    if(BotxLen == BotyLen then
        if(BotxLenStr == "1.0" then
            ErrorDtB = sprintf(nil, "%s,(%.2f %.2f), ERROR - Drill Size is 1 Mil -- Depad Updated In This Via - SOLDERMASK BOTTOM", BotListlp->name, car(BotListlp ->xy), cadr(BotListlp ->xy))
            when(ErrorDtB push(ErrorDtB ErrorListNonShp))
        )
    )
)

ErrorListNonShp = unique(ErrorListNonShp)
ErrorListDMM = unique(ErrorListDMM)
ErrorListNU = unique(ErrorListNU)
ErrorListWU = unique(ErrorListWU)

ErrorList = append(ErrorListDMM ErrorListNU)
ErrorListUp = append(ErrorList ErrorListWU)
ErrorListUp1 = append(ErrorListUp ErrorListNonShp)
if(ErrorListUp1 == nil then
	axlUIConfirm("No Error Found...")
else
	logfile = "ViaDepadCheck.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	timeperform = fileTimeModified("ViaDepadCheck.log")
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n", "------------------------------------------------")
		if(ErrorListDMM != nil then
			fprintf(port, "%s\n\n", "ERROR LIST : DRILL SIZE MISSMATCH")
			fprintf(port, "%-18s %-18s %-38s %-38s \n\n", "NAME", "XY LOCATION", "ERROR", "PAD DRILL SIZE")
			foreach(ErrorListURlp ErrorListDMM
				PrseOutputUR = parseString(ErrorListURlp ",")
				fprintf(port, "%-18s %-18s %-38s %-38s  \n",nth(0 PrseOutputUR),nth(1 PrseOutputUR),nth(2 PrseOutputUR),nth(3 PrseOutputUR))
			)
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		else
			fprintf(port, "%s\n", "NO ERROR IN DRILL SIZE")
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		)
		
		if(ErrorListNU != nil then
			fprintf(port, "ERROR LIST : %s NAME NOT UPDATED \n\n", DePadName)
			fprintf(port, "%-18s %-18s %-18s\n\n", "NAME", "XY LOCATION", "ERROR")
			foreach(ErrorListMMlp ErrorListNU
				PrseOutputMM = parseString(ErrorListMMlp ",")
				fprintf(port, "%-18s %-18s %-18s\n",nth(0 PrseOutputMM),nth(1 PrseOutputMM),nth(2 PrseOutputMM))
			)
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		else
			fprintf(port, "NO ERROR IN %s NAMING\n", DePadName)
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		)
		
		if(ErrorListWU != nil then
			fprintf(port, "ERROR LIST : %s  UPDATED IN %s CONNECTED VIA \n\n", DePadName, ChkLyr)
			fprintf(port, "%-18s %-18s %-18s\n\n", "NAME", "XY LOCATION", "ERROR")
			foreach(ErrorListWUlp ErrorListWU
				PrseOutputWU = parseString(ErrorListWUlp ",")
				fprintf(port, "%-18s %-18s %-18s\n",nth(0 PrseOutputWU),nth(1 PrseOutputWU),nth(2 PrseOutputWU))
			)
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		else
			fprintf(port, "NO ERROR - DEPAD NOT UPDATED IN %s CONNECTED VIA\n", ChkLyr)
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		)

		if(ErrorListNonShp != nil then
			fprintf(port, "ERROR LIST : DEPAD UPDATED VIA FOUND IN OUTSIDE SOLDERMASK \n\n")
			fprintf(port, "%-18s %-18s %-18s\n\n", "NAME", "XY LOCATION", "ERROR")
			foreach(ErrorListNonShplp ErrorListNonShp
				PrseOutputNS = parseString(ErrorListNonShplp ",")
				fprintf(port, "%-18s %-18s %-18s\n",nth(0 PrseOutputNS),nth(1 PrseOutputNS),nth(2 PrseOutputNS))
			)
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		else
			fprintf(port, "NO ERROR - NO DEPAD FOUND IN OUTSIDE SOLDERMASK SHAPE\n")
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
		)
	
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Via Depad Checking", nil, '(30 25), '(CENTER))
)
axlVisibleSet(originalVisible)
axlClearSelSet()
)