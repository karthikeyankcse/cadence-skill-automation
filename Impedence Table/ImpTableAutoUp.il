axlCmdRegister("ImpTableAutoUp" 'ImpTableAutoUp)
procedure(ImpTableAutoUp()
LyrSigName = nil
etchparam = axlGetParam("paramLayerGroup:ETCH")
Lyr_Names = etchparam->groupMembers
BotLen = length(Lyr_Names)
foreach(Lyr_Nameslp Lyr_Names
	LyrNameCaps = upperCase(Lyr_Nameslp)
	LyrFilt = pcreCompile("SIG")
	if(LyrNameCaps == "TOP" || LyrNameCaps == "BOTTOM" then
		when(LyrNameCaps push(LyrNameCaps LyrSigName))
	else
		when(pcreExecute(LyrFilt LyrNameCaps)
			when(LyrNameCaps push(LyrNameCaps LyrSigName))
		)
	)
)

CnsValListCOP = nil
BusNameListCOP = nil
CnsValList = nil
BusNameList = nil
CsetPhyName = axlCnsList('physical)
foreach(CsetPhyNamelp CsetPhyName
	pcre_BUS = pcreCompile("OHM")
	when(pcreExecute(pcre_BUS CsetPhyNamelp)
		pcre_BUS = pcreCompile("COPLANAR")
		pcre_COPNC = pcreCompile("COPLANER")
		if(pcreExecute(pcre_COPNC CsetPhyNamelp) then
			axlUIConfirm("Please Change the name COPLANER to COPLANAR....")
		)
		if(pcreExecute(pcre_BUS CsetPhyNamelp) then
			foreach(LyrSigNamelpCOP LyrSigName
				WidValCOP = axlCNSGetPhysical(CsetPhyNamelp LyrSigNamelpCOP 'width_min)
				SpaceValCOP = axlCNSGetPhysical(CsetPhyNamelp LyrSigNamelpCOP 'dp_primary_gap) 
				CsetPhyNamelpSpace = sprintf(nil "%s%s", CsetPhyNamelp, "_SPACING") 
				ShpValCOP = axlCNSGetSpacing(CsetPhyNamelpSpace LyrSigNamelpCOP 'line_shape)
				if(ShpValCOP == nil then
					val = sprintf(nil "%s - Not Found in Spacing Constraint Manager..", CsetPhyNamelpSpace) 
					axlUIConfirm(val)
				)
				CnsValDataCOP = sprintf(nil "%s,%s,%.2f,%.2f,%.2f \n", CsetPhyNamelp, LyrSigNamelpCOP, WidValCOP, SpaceValCOP, ShpValCOP)
				when(CsetPhyNamelp push(CsetPhyNamelp BusNameListCOP))
				when(CnsValDataCOP push(CnsValDataCOP CnsValListCOP))
			)
		else
			foreach(LyrSigNamelp LyrSigName
				WidVal = axlCNSGetPhysical(CsetPhyNamelp LyrSigNamelp 'width_min)
				SpaceVal = axlCNSGetPhysical(CsetPhyNamelp LyrSigNamelp 'dp_primary_gap)  
				CnsValData = sprintf(nil "%s,%s,%.2f,%.2f \n", CsetPhyNamelp, LyrSigNamelp, WidVal, SpaceVal)
				when(CsetPhyNamelp push(CsetPhyNamelp BusNameList))
				when(CnsValData push(CnsValData CnsValList))
			)
		)
	)
)


WidFoundList = nil
WidFoundListCOP = nil
originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
ClineSegINP = axlGetSelSet(axlAddSelectAll())   
axlClearSelSet()
foreach(ClineSegINPlp ClineSegINP
	CLBusName = ClineSegINPlp->net->bus->name
	CLLyr = ClineSegINPlp->layer
	CLWidth = ClineSegINPlp->width
	if(CLBusName != nil && CLLyr != nil && CLWidth != nil then
		CLBusName = upperCase(CLBusName) 
		CLLyr = upperCase(CLLyr) 
		LyrNamefilt = nth(1 parseString(CLLyr "/"))
		CLWidthStr = sprintf(nil "%.2f", CLWidth) 
		ConVal = ClineSegINPlp->net->parentGroups
		foreach(ConVallp ConVal
			ConValOP = axlDBGetProperties(ConVallp)
				foreach(ConValOPlp ConValOP
					ValFiltPHY = symbolToString(car(ConValOPlp))
					if(ValFiltPHY == "PHYSICAL_CONSTRAINT_SET" then
						ConValFilt = sprintf(nil "%s", cadr(ConValOPlp))
					)
				)
		)
		if(ConValFilt then
			foreach(CnsValListlp CnsValList
				CnsBusName = nth(0 parseString(CnsValListlp ","))
				CnsLyrName = nth(1 parseString(CnsValListlp ","))
				CnsWidVal = nth(2 parseString(CnsValListlp ","))
					if(ConValFilt == CnsBusName then 
						if(CnsLyrName == LyrNamefilt && CnsWidVal == CLWidthStr then
							when(CnsValListlp push(CnsValListlp WidFoundList))
						)
					)
				
			)
			
			foreach(CnsValListCOPlp CnsValListCOP
				CnsBusNameCOP = nth(0 parseString(CnsValListCOPlp ","))
				CnsLyrNameCOP = nth(1 parseString(CnsValListCOPlp ","))
				CnsWidValCOP = nth(2 parseString(CnsValListCOPlp ","))
					if(ConValFilt == CnsBusNameCOP then 
						if(CnsLyrNameCOP == LyrNamefilt && CnsWidValCOP == CLWidthStr then
							when(CnsValListCOPlp push(CnsValListCOPlp WidFoundListCOP))
						)
					)
				
			)
			
		)
	)
)
axlVisibleSet(originalVisible)
axlShell("redisplay")

WidFoundList = unique(WidFoundList)
NonMemList = nil
NonMemList = setof(item, CnsValList, !member(item, WidFoundList))

WidFoundListCOP = unique(WidFoundListCOP)
NonMemListCOP = nil
NonMemListCOP = setof(itemCOP, CnsValListCOP, !member(itemCOP, WidFoundListCOP))

NonMemListUp = nil
foreach(NonMemListlp NonMemList
	NonBusName = nth(0 parseString(NonMemListlp ","))
	NonLyrName = nth(1 parseString(NonMemListlp ","))
	NonFiltData = sprintf(nil "%s,%s,%s,%s", NonBusName, NonLyrName, "- - -", "- - -") 
	when(NonFiltData push(NonFiltData NonMemListUp))
)
NonMemListUp = unique(NonMemListUp)
FinalUpList = nil
FinalUpList = append(WidFoundList NonMemListUp) 
FinalUpList = sort(FinalUpList 'alphalessp)

NonMemListUpCOP = nil
foreach(NonMemListCOPlp NonMemListCOP
	NonBusNameCOP = nth(0 parseString(NonMemListCOPlp ","))
	NonLyrNameCOP = nth(1 parseString(NonMemListCOPlp ","))
	NonFiltDataCOP = sprintf(nil "%s,%s,%s,%s,%s", NonBusNameCOP, NonLyrNameCOP, "- - -", "- - -", "- - -") 
	when(NonFiltDataCOP push(NonFiltDataCOP NonMemListUpCOP))
)
NonMemListUpCOP = unique(NonMemListUpCOP)
FinalUpListCOP = nil
FinalUpListCOP = append(WidFoundListCOP NonMemListUpCOP) 
FinalUpListCOP = sort(FinalUpListCOP 'alphalessp)
FinalUpListCOP = unique(FinalUpListCOP)


BusNameListSort = nil
foreach(BusNameListlp BusNameList
	SortList = atoi(nth(0 parseString(BusNameListlp "_")))
	when(SortList push(SortList BusNameListSort))	
)
BusNameListSort = sort(BusNameListSort 'lessp) 
BusNameListSort = unique(BusNameListSort)

BusNameListSortCOP = nil
foreach(BusNameListCOPlp BusNameListCOP
	SortListCOP = atoi(nth(0 parseString(BusNameListCOPlp "_")))
	when(SortListCOP push(SortListCOP BusNameListSortCOP))	
)
BusNameListSortCOP = sort(BusNameListSortCOP 'lessp) 
BusNameListSortCOP = unique(BusNameListSortCOP)

BusNameList = unique(BusNameList)
LyrSigName = unique(LyrSigName)
LyrSigName = reverse(LyrSigName)
FinalUpList = unique(FinalUpList)


axlUIConfirm( "Please Pick the location to create Impedance table...!" )
PlacePoint = axlEnterPoint(?prompts list("Pick origin point") ?gridSnap t)
Xpoint = car(PlacePoint)
Ypoint = cadr(PlacePoint)

XPlacePoint = Xpoint
YPlacePoint = Ypoint 

XPlacePointH = Xpoint
YPlacePointH = Ypoint

layerPass = "MANUFACTURING/STACKUP_FIGURE"
Display = axlVisibleGet() 
axlVisibleDesign(nil) 
axlVisibleLayer(layerPass t) 
axlDBRefreshId(axlDBGetDesign())
DummyValLyrPass = 1
foreach(LyrSigNamelp LyrSigName
	YPlacePoint = YPlacePoint - 500
	XPlacePoint = Xpoint
	myorient = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "left")
	if(LyrSigNamelp == "TOP" || LyrSigNamelp == "BOTTOM" then
		if(LyrSigNamelp == "TOP" then
			TName = axlDBCreateText("L01_TOP", XPlacePoint - 1000 :YPlacePoint + 250, myorient, layerPass, nil)
			TNameC = axlDBCreateText("COATED", XPlacePoint + 150:YPlacePoint + 500, myorient, layerPass, nil)
			TNameUC = axlDBCreateText("UNCOATED", XPlacePoint + 150:YPlacePoint, myorient, layerPass, nil)
			axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint + 800 XPlacePoint + 1150:YPlacePoint + 800), 100, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint - 200 XPlacePoint + 1150:YPlacePoint - 200), 30, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint + 800 XPlacePoint - 1100:YPlacePoint - 200), 100, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint + 1150:YPlacePoint + 800 XPlacePoint + 1150:YPlacePoint - 200), 100, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint + 100:YPlacePoint + 300 XPlacePoint + 1150:YPlacePoint + 300), 30, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint + 100:YPlacePoint + 800 XPlacePoint + 100:YPlacePoint - 200), 30, layerPass, 'line, nil)
		else
			BotName = sprintf(nil "L%d_BOTTOM", BotLen)
			BName = axlDBCreateText(BotName, XPlacePoint - 1000 :YPlacePoint - 250, myorient, layerPass, nil)
			BNameC = axlDBCreateText("COATED", XPlacePoint + 150:YPlacePoint, myorient, layerPass, nil)
			BNameUC = axlDBCreateText("UNCOATED", XPlacePoint + 150:YPlacePoint - 500, myorient, layerPass, nil)
			axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint - 700 XPlacePoint + 1150:YPlacePoint - 700), 100, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint + 300 XPlacePoint - 1100:YPlacePoint - 700), 100, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint + 1150:YPlacePoint + 300 XPlacePoint + 1150:YPlacePoint - 700), 100, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint + 125:YPlacePoint - 200 XPlacePoint + 1150:YPlacePoint - 200), 30, layerPass, 'line, nil)
			axlDBCreateLine(list(XPlacePoint + 125:YPlacePoint + 300 XPlacePoint + 125:YPlacePoint - 700), 30, layerPass, 'line, nil)
		)
	else
		LName = axlDBCreateText(LyrSigNamelp, XPlacePoint - 1000:YPlacePoint, myorient, layerPass, nil)
		axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint - 200 XPlacePoint + 1150:YPlacePoint - 200), 30, layerPass, 'line, nil)
		axlDBCreateLine(list(XPlacePoint - 1100:YPlacePoint + 300 XPlacePoint - 1100:YPlacePoint - 200), 100, layerPass, 'line, nil)
		axlDBCreateLine(list(XPlacePoint + 1150:YPlacePoint + 300 XPlacePoint + 1150:YPlacePoint - 200), 100, layerPass, 'line, nil)
	)
	foreach(BusNameListSortlp BusNameListSort
		foreach(FinalUpListlp FinalUpList
			ValBusName = nth(0 parseString(FinalUpListlp ","))
			ValBusNameFilt = atoi(nth(0 parseString(ValBusName "_")))
			ValLyr = nth(1 parseString(FinalUpListlp ",")) 
			ValWid = nth(2 parseString(FinalUpListlp ","))
			ValSpace = nth(3 parseString(FinalUpListlp ","))
			
			
			if(BusNameListSortlp > 50 then
				if(BusNameListSortlp == ValBusNameFilt && LyrSigNamelp == ValLyr then
				if(DummyValLyrPass == 1 then
					XPlacePoint = XPlacePoint + 1800
					DummyValLyrPass = DummyValLyrPass + 1
				else
					XPlacePoint = XPlacePoint + 1200
				)
				myorientDt = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
				if(LyrSigNamelp == "TOP" || LyrSigNamelp == "BOTTOM" then
						if(LyrSigNamelp == "TOP" then
							WidTxtC = axlDBCreateText(ValWid, XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
							WidTxtUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 800), 30, layerPass, 'line, nil)
								
							XPlacePoint = XPlacePoint + 1200
							SpaceTxtC = axlDBCreateText(ValSpace, XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
							SpaceTxtUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 800), 30, layerPass, 'line, nil)
							
							XPlacePoint = XPlacePoint + 1200
							if(ValWid == "- - -" then
								SpaceTxtTC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
									axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
							else
								SpaceTxtTC = axlDBCreateText("+/-8%", XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
									axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
							)
							if(ValWid == "- - -" then
								SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
									axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
							else
								SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
									axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
							)
							axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 800), 30, layerPass, 'line, nil)
						else
							
							WidTxtC = axlDBCreateText(ValWid, XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
							WidTxtUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint - 700), 100, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
							
							XPlacePoint = XPlacePoint + 1200
							SpaceTxtC = axlDBCreateText(ValSpace, XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
							SpaceTxtUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
							
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint - 700), 100, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
							
							XPlacePoint = XPlacePoint + 1200
							if(ValWid == "- - -" then
								SpaceTxtTC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
							else
								SpaceTxtTC = axlDBCreateText("+/-8%", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
							)
							if(ValWid == "- - -" then
								SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
							else
								SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
							)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint - 700), 100, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
						)
						
				else
					WidTxt = axlDBCreateText(ValWid, XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
					axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					XPlacePoint = XPlacePoint + 1200
					SpaceTxt = axlDBCreateText(ValSpace, XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
					axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					XPlacePoint = XPlacePoint + 1200
					if(ValWid == "- - -" then
						SpaceTxtTC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					else
						SpaceTxtTC = axlDBCreateText("+/-8%", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					)
				
				)
				
				
				)
			else
				if(BusNameListSortlp == ValBusNameFilt && LyrSigNamelp == ValLyr then
				if(DummyValLyrPass == 1 then
						XPlacePoint = XPlacePoint + 1800
						DummyValLyrPass = DummyValLyrPass + 1
					else
						XPlacePoint = XPlacePoint + 1200
					)
					
				myorientDt = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
				if(LyrSigNamelp == "TOP" || LyrSigNamelp == "BOTTOM" then
					if(LyrSigNamelp == "TOP" then
						WidTxtC = axlDBCreateText(ValWid, XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
						WidTxtUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
							axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 800), 30, layerPass, 'line, nil)
						XPlacePoint = XPlacePoint + 1200
						if(ValWid == "- - -" then
							SpaceTxtTC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
						else
							SpaceTxtTC = axlDBCreateText("+/-5%", XPlacePoint:YPlacePoint + 500, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 800 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint + 300  XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
						)
						if(ValWid == "- - -" then
							SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						else
							SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
								axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 800), 30, layerPass, 'line, nil)	
					else
						WidTxtC = axlDBCreateText(ValWid, XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						WidTxtUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint - 700), 100, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
						
						XPlacePoint = XPlacePoint + 1200
						if(ValWid == "- - -" then
							SpaceTxtTC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						else
							SpaceTxtTC = axlDBCreateText("+/-5%", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						)
						if(ValWid == "- - -" then
							SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
						else
							SpaceTxtTUC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint - 500, myorientDt, layerPass, nil)
						)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint - 700), 100, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					)
				else
					WidTxt = axlDBCreateText(ValWid, XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
					axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					XPlacePoint = XPlacePoint + 1200
					if(ValWid == "- - -" then
						SpaceTxtTC = axlDBCreateText("- - -", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					else
						SpaceTxtTC = axlDBCreateText("+/-5%", XPlacePoint:YPlacePoint, myorientDt, layerPass, nil)
						axlDBCreateLine(list(XPlacePoint - 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint - 200), 30, layerPass, 'line, nil)
						axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 30, layerPass, 'line, nil)
					)
				)
				)
			)
			
		)
		if(LyrSigNamelp == "TOP" || LyrSigNamelp == "BOTTOM" then
			if(LyrSigNamelp == "TOP" then
				axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 800), 100, layerPass, 'line, nil)
			else
				axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 700 XPlacePoint + 600:YPlacePoint + 300), 100, layerPass, 'line, nil)
			)
		else
			axlDBCreateLine(list(XPlacePoint + 600:YPlacePoint - 200 XPlacePoint + 600:YPlacePoint + 300), 100, layerPass, 'line, nil)
		)
	)
DummyValLyrPass = 1
)

DummyValHead = 1
DummyValLine = 1
foreach(BusNameListSortlpSec BusNameListSort
	foreach(BusNameListPrtlp BusNameList
		SortListPrt = atoi(nth(0 parseString(BusNameListPrtlp "_")))
		if(SortListPrt == BusNameListSortlpSec then
			if(DummyValHead == 1 then
				XPlacePointH = XPlacePointH + 1800
				DummyValHead = DummyValHead + 1
			else
				XPlacePointH = XPlacePointH + 1200
			)
			
			if(BusNameListSortlpSec > 50 then
				HeadVal = sprintf(nil "%d %s", BusNameListSortlpSec, "OHM")
				HeadOrient = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
				HeadTxt1 = axlDBCreateText(HeadVal, XPlacePointH + 1200:YPlacePointH + 1400, HeadOrient, layerPass, nil)
				HeadTxt2 = axlDBCreateText("DIFFERENTIAL", XPlacePointH + 1200:YPlacePointH + 1200, HeadOrient, layerPass, nil)
				HeadTxt3 = axlDBCreateText("TRACE", XPlacePointH:YPlacePointH + 900, HeadOrient, layerPass, nil)
				HeadTxt4 = axlDBCreateText("WIDTH", XPlacePointH:YPlacePointH + 700, HeadOrient, layerPass, nil)
				HeadTxt5 = axlDBCreateText("(MIL)", XPlacePointH:YPlacePointH + 500, HeadOrient, layerPass, nil)
				HeadTxt6 = axlDBCreateText("SPACING", XPlacePointH + 1200:YPlacePointH + 700, HeadOrient, layerPass, nil)
				HeadTxt7 = axlDBCreateText("(MIL)", XPlacePointH + 1200:YPlacePointH + 500, HeadOrient, layerPass, nil)
				HeadTxt8 = axlDBCreateText("TOLERANCE", XPlacePointH + 2400:YPlacePointH + 700, HeadOrient, layerPass, nil)
				if(DummyValLine == 1 then
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 300 XPlacePointH - 650:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH + 600:YPlacePointH + 300 XPlacePointH + 600:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH + 1800:YPlacePointH + 300 XPlacePointH + 1800:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 1700 XPlacePointH + 3000:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 1100 XPlacePointH + 3000:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 1700 XPlacePointH - 2900:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 2900:YPlacePointH + 1700 XPlacePointH - 2900:YPlacePointH + 300), 100, layerPass, 'line, nil)
					
					DummyValLine = DummyValLine + 1
				else
					axlDBCreateLine(list(XPlacePointH - 600:YPlacePointH + 300 XPlacePointH - 600:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH + 600:YPlacePointH + 300 XPlacePointH + 600:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH + 1800:YPlacePointH + 300 XPlacePointH + 1800:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 600:YPlacePointH + 1700 XPlacePointH + 3000:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 600:YPlacePointH + 1100 XPlacePointH + 3000:YPlacePointH + 1100), 30, layerPass, 'line, nil)
				)
				XPlacePointH = XPlacePointH + 2400
			else
				HeadVal = sprintf(nil "%d %s", BusNameListSortlpSec, "OHM")
				HeadOrient = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
				HeadTxt1 = axlDBCreateText(HeadVal, XPlacePointH + 600:YPlacePointH + 1400, HeadOrient, layerPass, nil)
				HeadTxt2 = axlDBCreateText("SINGLE ENDED", XPlacePointH + 600:YPlacePointH + 1200, HeadOrient, layerPass, nil)
				HeadTxt3 = axlDBCreateText("TRACE", XPlacePointH:YPlacePointH + 900, HeadOrient, layerPass, nil)
				HeadTxt4 = axlDBCreateText("WIDTH", XPlacePointH:YPlacePointH + 700, HeadOrient, layerPass, nil)
				HeadTxt5 = axlDBCreateText("(MIL)", XPlacePointH:YPlacePointH + 500, HeadOrient, layerPass, nil)
				HeadTxt6 = axlDBCreateText("TOLERANCE", XPlacePointH + 1200:YPlacePointH + 700, HeadOrient, layerPass, nil)
				
				if(DummyValLine == 1 then
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 300 XPlacePointH - 650:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH + 600:YPlacePointH + 300 XPlacePointH + 600:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 1700 XPlacePointH + 1800:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 1100 XPlacePointH + 1800:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					
					axlDBCreateLine(list(XPlacePointH - 650:YPlacePointH + 1700 XPlacePointH - 2900:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 2900:YPlacePointH + 1700 XPlacePointH - 2900:YPlacePointH + 300), 100, layerPass, 'line, nil)
					
					DummyValLine = DummyValLine + 1
				else
					axlDBCreateLine(list(XPlacePointH - 600:YPlacePointH + 300 XPlacePointH - 600:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH + 600:YPlacePointH + 300 XPlacePointH + 600:YPlacePointH + 1100), 30, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 600:YPlacePointH + 1700 XPlacePointH + 1800:YPlacePointH + 1700), 100, layerPass, 'line, nil)
					axlDBCreateLine(list(XPlacePointH - 600:YPlacePointH + 1100 XPlacePointH + 1800:YPlacePointH + 1100), 30, layerPass, 'line, nil)
				)
			XPlacePointH = XPlacePointH + 1200
			)
		)	
	)
)
axlDBCreateLine(list(XPlacePointH + 600:YPlacePointH + 300 XPlacePointH + 600:YPlacePointH + 1700), 100, layerPass, 'line, nil)
XPlacePointCOPFIX = XPlacePoint
YPlacePointCOP = Ypoint 
foreach(LyrSigNameCOPlp LyrSigName
	YPlacePointCOP = YPlacePointCOP - 500
	XPlacePointCOP = XPlacePointCOPFIX
	foreach(BusNameListSortCOPlp BusNameListSortCOP
		foreach(FinalUpListCOPlp FinalUpListCOP
			ValBusNameCOP = nth(0 parseString(FinalUpListCOPlp ","))
			ValBusNameCOPFilt = atoi(nth(0 parseString(ValBusNameCOP "_")))
			ValLyrCOP = nth(1 parseString(FinalUpListCOPlp ",")) 
			ValWidCOP = nth(2 parseString(FinalUpListCOPlp ","))
			ValSpaceCOP = nth(3 parseString(FinalUpListCOPlp ","))
			ValShpCOP = nth(4 parseString(FinalUpListCOPlp ","))
			if(BusNameListSortCOPlp > 50 then
				if(BusNameListSortCOPlp == ValBusNameCOPFilt && LyrSigNameCOPlp == ValLyrCOP then
					XPlacePointCOP = XPlacePointCOP + 1200
					myorientDtCOP = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
						if(LyrSigNameCOPlp == "TOP" || LyrSigNameCOPlp == "BOTTOM" then
							if(LyrSigNameCOPlp == "TOP" then
								WidTxtCOPC = axlDBCreateText(ValWidCOP, XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								WidTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
									
								XPlacePointCOP = XPlacePointCOP + 1200
								SpaceTxtCOPC = axlDBCreateText(ValSpaceCOP, XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								SpaceTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								ShpTxtCOPC = axlDBCreateText(ValShpCOP, XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								ShpTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								if(ValWidCOP == "- - -" then
									SpaceTxtTCOPC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								else
									SpaceTxtTCOPC = axlDBCreateText("+/-8%", XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								)
								if(ValWidCOP == "- - -" then
									SpaceTxtCOPTUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								else
									SpaceTxtCOPTUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
							
							else
								WidTxtCOPC = axlDBCreateText(ValWidCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								WidTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								SpaceTxtCOPC = axlDBCreateText(ValSpaceCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								SpaceTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								ShpTxtCOPC = axlDBCreateText(ValShpCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								ShpTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								if(ValWidCOP == "- - -" then
									SpaceTxtTCOPC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								else
									SpaceTxtTCOPC = axlDBCreateText("+/-8%", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								)
								if(ValWid == "- - -" then
									SpaceTxtTCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								else
									SpaceTxtTCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							)
						else
							WidTxtCOP = axlDBCreateText(ValWidCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
							axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							XPlacePointCOP = XPlacePointCOP + 1200
							SpaceTxtCOP = axlDBCreateText(ValSpaceCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
							axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							XPlacePointCOP = XPlacePointCOP + 1200
							ShpTxtCOP = axlDBCreateText(ValShpCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
							axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							XPlacePointCOP = XPlacePointCOP + 1200
							if(ValWidCOP == "- - -" then
								SpaceTxtTCOPC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							else
								SpaceTxtTCOPC = axlDBCreateText("+/-8%", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							)
							
						
						)
				)
				
			else
				if(BusNameListSortCOPlp == ValBusNameCOPFilt && LyrSigNameCOPlp == ValLyrCOP then
					XPlacePointCOP = XPlacePointCOP + 1200
					myorientDtCOP = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
						if(LyrSigNameCOPlp == "TOP" || LyrSigNameCOPlp == "BOTTOM" then
							if(LyrSigNameCOPlp == "TOP" then
								WidTxtCOPC = axlDBCreateText(ValWidCOP, XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								WidTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
									
								XPlacePointCOP = XPlacePointCOP + 1200
								ShpTxtCOPC = axlDBCreateText(ValShpCOP, XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								ShpTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
									axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
									axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								if(ValWidCOP == "- - -" then
									SpaceTxtTCOPC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								else
									SpaceTxtTCOPC = axlDBCreateText("+/-5%", XPlacePointCOP:YPlacePointCOP + 500, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 800 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP + 300  XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								)
								if(ValWidCOP == "- - -" then
									SpaceTxtCOPTUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								else
									SpaceTxtCOPTUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
										axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 30, layerPass, 'line, nil)
							
							else
								WidTxtCOPC = axlDBCreateText(ValWidCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								WidTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								ShpTxtCOPC = axlDBCreateText(ValShpCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								ShpTxtCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
								
								XPlacePointCOP = XPlacePointCOP + 1200
								if(ValWidCOP == "- - -" then
									SpaceTxtTCOPC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								else
									SpaceTxtTCOPC = axlDBCreateText("+/-5%", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								)
								if(ValWid == "- - -" then
									SpaceTxtTCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								else
									SpaceTxtTCOPUC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP - 500, myorientDtCOP, layerPass, nil)
								)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP - 700), 100, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							)
						else
							WidTxtCOP = axlDBCreateText(ValWidCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
							axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							
							XPlacePointCOP = XPlacePointCOP + 1200
							ShpTxtCOP = axlDBCreateText(ValShpCOP, XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
							axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
							axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							XPlacePointCOP = XPlacePointCOP + 1200
							if(ValWidCOP == "- - -" then
								SpaceTxtTCOPC = axlDBCreateText("- - -", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							else
								SpaceTxtTCOPC = axlDBCreateText("+/-5%", XPlacePointCOP:YPlacePointCOP, myorientDtCOP, layerPass, nil)
								axlDBCreateLine(list(XPlacePointCOP - 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP - 200), 30, layerPass, 'line, nil)
								axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 30, layerPass, 'line, nil)
							)
							
						
						)
				
				)
			)
		)
		
		if(LyrSigNameCOPlp == "TOP" || LyrSigNameCOPlp == "BOTTOM" then
			if(LyrSigNameCOPlp == "TOP" then
				axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 800), 100, layerPass, 'line, nil)
			else
				axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 700 XPlacePointCOP + 600:YPlacePointCOP + 300), 100, layerPass, 'line, nil)
			)
		else
			axlDBCreateLine(list(XPlacePointCOP + 600:YPlacePointCOP - 200 XPlacePointCOP + 600:YPlacePointCOP + 300), 100, layerPass, 'line, nil)
		)
		
	)
)
XPlacePointHCOP = XPlacePoint
YPlacePointHCOP = Ypoint 
BusNameListSortCOP = unique(BusNameListSortCOP)
BusNameListCOP = unique(BusNameListCOP)
foreach(BusNameListSortlpSecCOP BusNameListSortCOP
	foreach(BusNameListPrtlpCOP BusNameListCOP
		SortListPrtCOP = atoi(nth(0 parseString(BusNameListPrtlpCOP "_")))
		if(SortListPrtCOP == BusNameListSortlpSecCOP then
			XPlacePointHCOP = XPlacePointHCOP + 1200
			if(BusNameListSortlpSecCOP > 50 then
				HeadValCOP = sprintf(nil "%d %s", BusNameListSortlpSecCOP, "OHM")
				HeadOrientCOP = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
				HeadTxtCOP1 = axlDBCreateText(HeadValCOP, XPlacePointHCOP + 1800:YPlacePointHCOP + 1400, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP2 = axlDBCreateText("DIFFERENTIAL COPLANAR", XPlacePointHCOP + 1800:YPlacePointHCOP + 1200, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP3 = axlDBCreateText("TRACE", XPlacePointHCOP:YPlacePointHCOP + 900, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP4 = axlDBCreateText("WIDTH", XPlacePointHCOP:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP5 = axlDBCreateText("(MIL)", XPlacePointHCOP:YPlacePointHCOP + 500, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP6 = axlDBCreateText("SPACING", XPlacePointHCOP + 1200:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP7 = axlDBCreateText("(MIL)", XPlacePointHCOP + 1200:YPlacePointHCOP + 500, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP8 = axlDBCreateText("COPLANAR", XPlacePointHCOP + 2400:YPlacePointHCOP + 900, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP9 = axlDBCreateText("SPACING", XPlacePointHCOP + 2400:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP9A = axlDBCreateText("(MIL)", XPlacePointHCOP + 2400:YPlacePointHCOP + 500, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP10 = axlDBCreateText("TOLERANCE", XPlacePointHCOP + 3600:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				axlDBCreateLine(list(XPlacePointHCOP - 600:YPlacePointHCOP + 300 XPlacePointHCOP - 600:YPlacePointHCOP + 1700), 100, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP + 600:YPlacePointHCOP + 300 XPlacePointHCOP + 600:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP + 1800:YPlacePointHCOP + 300 XPlacePointHCOP + 1800:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP + 3000:YPlacePointHCOP + 300 XPlacePointHCOP + 3000:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP - 600:YPlacePointHCOP + 1700 XPlacePointHCOP + 4200:YPlacePointHCOP + 1700), 100, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP - 600:YPlacePointHCOP + 1100 XPlacePointHCOP + 4200:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				XPlacePointHCOP = XPlacePointHCOP + 3600
			else
				HeadValCOP = sprintf(nil "%d %s", BusNameListSortlpSecCOP, "OHM")
				HeadOrientCOP = make_axlTextOrientation(?textBlock "8", ?rotation 0.0, ?mirrored nil, ?justify "center")
				HeadTxtCOP1 = axlDBCreateText(HeadValCOP, XPlacePointHCOP + 1200:YPlacePointHCOP + 1400, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP2 = axlDBCreateText("SINGLE ENDED COPLANAR", XPlacePointHCOP + 1200:YPlacePointHCOP + 1200, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP3 = axlDBCreateText("TRACE", XPlacePointHCOP:YPlacePointHCOP + 900, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP4 = axlDBCreateText("WIDTH", XPlacePointHCOP:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP5 = axlDBCreateText("(MIL)", XPlacePointHCOP:YPlacePointHCOP + 500, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP6 = axlDBCreateText("COPLANAR", XPlacePointHCOP + 1200:YPlacePointHCOP + 900, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP7 = axlDBCreateText("SPACING", XPlacePointHCOP + 1200:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP7A = axlDBCreateText("(MIL)", XPlacePointHCOP + 1200:YPlacePointHCOP + 500, HeadOrientCOP, layerPass, nil)
				HeadTxtCOP8 = axlDBCreateText("TOLERANCE", XPlacePointHCOP + 2400:YPlacePointHCOP + 700, HeadOrientCOP, layerPass, nil)
				axlDBCreateLine(list(XPlacePointHCOP - 600:YPlacePointHCOP + 300 XPlacePointHCOP - 600:YPlacePointHCOP + 1700), 100, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP + 600:YPlacePointHCOP + 300 XPlacePointHCOP + 600:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP - 600:YPlacePointHCOP + 1700 XPlacePointHCOP + 3000:YPlacePointHCOP + 1700), 100, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP - 600:YPlacePointHCOP + 1100 XPlacePointHCOP + 3000:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				axlDBCreateLine(list(XPlacePointHCOP + 1800:YPlacePointHCOP + 300 XPlacePointHCOP + 1800:YPlacePointHCOP + 1100), 30, layerPass, 'line, nil)
				XPlacePointHCOP = XPlacePointHCOP + 2400
			)
		)	
	)
)
axlDBCreateLine(list(XPlacePointHCOP + 600:YPlacePointHCOP + 300 XPlacePointHCOP + 600:YPlacePointHCOP + 1700), 100, layerPass, 'line, nil)
axlVisibleSet(Display)
)