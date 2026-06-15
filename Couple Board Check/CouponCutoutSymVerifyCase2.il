axlCmdRegister("CouponCutoutSymVerifyCase2" 'CouponCutoutSymVerifyCase2)
procedure(CouponCutoutSymVerifyCase2()
CP3_BrowC2 = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	CP3_OpenFileC2 = axlDMFileParts(CP3_BrowC2)
	CP3_DataInFileC2 = axlDMOpenFile("ALLEGRO_TEXT" cadr(CP3_OpenFileC2) "r") 
	CP3_UserInputC2 = nil
		while(gets(CP3_Inp_ValC2 CP3_DataInFileC2)
			CP3_Inp_ValC2 = car(parseString(CP3_Inp_ValC2 "\n"))
				when(CP3_Inp_ValC2 push(CP3_Inp_ValC2 CP3_UserInputC2))
			)
axlDMClose(CP3_DataInFileC2)
CP3_UserInputC2 = unique(CP3_UserInputC2)

originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")

MechSymList_C2 = nil
MechSymListXY_C2 = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
MainViaINP_C2 = axlGetSelSet(axlAddSelectAll()) 
foreach(MainViaINP_C2lp MainViaINP_C2
	MainViaNetNameC2 = MainViaINP_C2lp->net->name 
	MainViaXC2 = car(MainViaINP_C2lp ->xy)
	MainViaYC2 = cadr(MainViaINP_C2lp ->xy)
	foreach(CP3_UserInputC2lp CP3_UserInputC2
		CP3MainNetnameC2 = nth(0 parseString(CP3_UserInputC2lp ","))
		if(CP3MainNetnameC2 == MainViaNetNameC2 then 
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "SYMBOLS") ?onButtons `("SYMBOLS"))
			SymINPC2 = axlGetSelSet(axlSingleSelectBox(list(MainViaXC2:MainViaYC2 MainViaXC2:MainViaYC2)))
				if(SymINPC2 != nil then
					foreach(SymINPC2lp SymINPC2
						Sym_nameC2 = SymINPC2lp ->name
						Sym_TypeC2 = SymINPC2lp	->type
						Sym_XC2 = car(SymINPC2lp ->xy)
						Sym_YC2 = cadr(SymINPC2lp ->xy) 
						Sym_RefC2 = SymINPC2lp->refdes 
						if(Sym_TypeC2 == "MECHANICAL" then
							axlClearSelSet()
							axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
							PinINP = axlGetSelSet(axlAddSelectPoint(MainViaXC2:MainViaYC2))
							PinVal = car(PinINP)
							if(PinVal then
								MechSymDataC2 = sprintf(nil "%s,%s,%s", CP3_UserInputC2lp, car(PinVal->functionPins)->name, Sym_nameC2)
								MechSymDataXYC2 = sprintf(nil "%s,%s,%s,(%.2f %.2f)", CP3_UserInputC2lp, car(PinVal->functionPins)->name, Sym_nameC2, Sym_XC2, Sym_YC2)
								when(MechSymDataC2 push(MechSymDataC2 MechSymList_C2))
								when(MechSymDataXYC2 push(MechSymDataXYC2 MechSymListXY_C2))
							)
	
						)
					
					)
				)
		)
	)
)

DUPMechSymList_C2 = nil
myTableMain = makeTable("myTableMain" 0)
foreach(MechSymList_C2lp MechSymList_C2
	myTableMain[MechSymList_C2lp] = 1 + myTableMain[MechSymList_C2lp]
	MechCountData = myTableMain[MechSymList_C2lp]
	if(MechCountData == 1 then
		when(MechSymList_C2lp push(MechSymList_C2lp DUPMechSymList_C2))
	else
		CountDataUpdateMech = sprintf(nil "%s$%d", MechSymList_C2lp, MechCountData)
		when(CountDataUpdateMech push(CountDataUpdateMech DUPMechSymList_C2))	
	)
)
DUPMechSymList_C2 = unique(DUPMechSymList_C2)


COUPMechSymList = nil
COUPMechSymListXY = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
COUPViaINP = axlGetSelSet(axlAddSelectAll())   
axlClearSelSet()
foreach(COUPViaINPlp COUPViaINP
	COUPViaNetName = COUPViaINPlp->net->name 
	COUPViaX = car(COUPViaINPlp ->xy)
	COUPViaY = cadr(COUPViaINPlp ->xy)
	foreach(CP3_UserInputlpS CP3_UserInputC2
		CP3MainNetnameS = nth(1 parseString(CP3_UserInputlpS ","))
		if(CP3MainNetnameS == COUPViaNetName then 
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "SYMBOLS") ?onButtons `("SYMBOLS"))
			SymINPS = axlGetSelSet(axlSingleSelectBox(list(COUPViaX:COUPViaY COUPViaX:COUPViaY)))
				if(SymINPS != nil then
					foreach(SymINPlpS SymINPS
						Sym_nameS = SymINPlpS ->name
						Sym_TypeS = SymINPlpS ->type
						Sym_XS = car(SymINPlpS ->xy)
						Sym_YS = cadr(SymINPlpS ->xy)
						Sym_RefS = SymINPlpS ->refdes 
						if(Sym_TypeS == "MECHANICAL" then
							axlClearSelSet()
							axlSetFindFilter(?enabled `("NOALL" "SYMBOLS") ?onButtons `("SYMBOLS"))
							SymINP = axlGetSelSet(axlAddSelectPoint(COUPViaX:COUPViaY))
							SymVal = car(SymINP)
							if(SymVal then
								COUPSymData = sprintf(nil "%s,%s,%s", CP3_UserInputlpS, SymVal->refdes, Sym_nameS)
								COUPSymDataXY = sprintf(nil "%s,%s,%s,(%.2f %.2f)", CP3_UserInputlpS, SymVal->refdes, Sym_nameS, Sym_XS, Sym_YS)
								when(COUPSymData push(COUPSymData COUPMechSymList))
								when(COUPSymDataXY push(COUPSymDataXY COUPMechSymListXY))
							)	
						)
					)
				)
		)
	)
)

DUPCOUPMechSymList = nil
myTableCoup = makeTable("myTableCoup" 0)
foreach(COUPMechSymListlp COUPMechSymList
	myTableCoup[COUPMechSymListlp] = 1 + myTableCoup[COUPMechSymListlp]
	CountDataCoup = myTableCoup[COUPMechSymListlp]
	if(CountDataCoup == 1 then
		when(COUPMechSymListlp push(COUPMechSymListlp DUPCOUPMechSymList))
	else
		CountDataUpdateCoup = sprintf(nil "%s$%d", COUPMechSymListlp, CountDataCoup)
		when(CountDataUpdateCoup push(CountDataUpdateCoup DUPCOUPMechSymList))	
	)
)
DUPCOUPMechSymList = unique(DUPCOUPMechSymList)

MainFoundList = nil
CoupFoundList = nil
foreach(MechSymList_C2lp DUPMechSymList_C2
	MainNetnameC2 = nth(0 parseString(MechSymList_C2lp ","))
	PackNetnameC2 = nth(1 parseString(MechSymList_C2lp ","))
	PinNameC2 = nth(2 parseString(MechSymList_C2lp ","))
	SymNameC2 = nth(3 parseString(MechSymList_C2lp ","))
	foreach(COUPMechSymListlp DUPCOUPMechSymList
		COUPMainNetnameC2 = nth(0 parseString(COUPMechSymListlp ","))
		COUPPackNetnameC2 = nth(1 parseString(COUPMechSymListlp ","))
		COUPPinNameC2 = nth(2 parseString(COUPMechSymListlp ","))
		COUPSymNameC2 = nth(3 parseString(COUPMechSymListlp ","))
		if(MainNetnameC2 == COUPMainNetnameC2 && PackNetnameC2 == COUPPackNetnameC2 && SymNameC2 == COUPSymNameC2 then
			pcre_SMA = pcreCompile(PinNameC2)
			when(pcreExecute(pcre_SMA COUPPinNameC2)
				when(MechSymList_C2lp push(MechSymList_C2lp MainFoundList))
				when(COUPMechSymListlp push(COUPMechSymListlp CoupFoundList))
			)
		)
	)
)

MainFoundList = unique(MainFoundList)
CoupFoundList = unique(CoupFoundList)

MainMissList = nil
MainMissList = setof(item1, DUPMechSymList_C2, !member(item1, MainFoundList))
MainMissList = unique(MainMissList)

upMainMissList = nil
foreach(MechSymListXY_C2lp MechSymListXY_C2
	XYMNetname = nth(0 parseString(MechSymListXY_C2lp ","))
	XYCNetname = nth(1 parseString(MechSymListXY_C2lp ","))
	XYRefdes = nth(2 parseString(MechSymListXY_C2lp ","))
	XYSymName = nth(3 parseString(MechSymListXY_C2lp ","))
	XYMain = nth(4 parseString(MechSymListXY_C2lp ","))
	foreach(MainMissListXYlp MainMissList
		MainDataMNetnameXY = nth(0 parseString(MainMissListXYlp ","))
		MainDataCNetnameXY = nth(1 parseString(MainMissListXYlp ","))
		MainDataRefdesXY = nth(2 parseString(MainMissListXYlp ","))
		MainDataSymNameXY = nth(3 parseString(MainMissListXYlp ","))
		if(XYMNetname == MainDataMNetnameXY && XYCNetname == MainDataCNetnameXY && XYRefdes == MainDataRefdesXY then
			XYData = sprintf(nil "%s,%s", MainMissListXYlp, XYMain)  
			when(XYData push(XYData upMainMissList))
		)	
	)
)
upMainMissList = unique(upMainMissList)


CoupMissList = nil
CoupMissList = setof(item2, DUPCOUPMechSymList, !member(item2, CoupFoundList))
CoupMissList = unique(CoupMissList)

upCoupMissList = nil
foreach(COUPMechSymListXYlp COUPMechSymListXY
	CXYMNetname = nth(0 parseString(COUPMechSymListXYlp ","))
	CXYCNetname = nth(1 parseString(COUPMechSymListXYlp ","))
	CXYRefdes = nth(2 parseString(COUPMechSymListXYlp ","))
	CXYSymName = nth(3 parseString(COUPMechSymListXYlp ","))
	CXYMain = nth(4 parseString(COUPMechSymListXYlp ","))
	foreach(CoupMissListXYlp CoupMissList
		CMainDataMNetnameXY = nth(0 parseString(CoupMissListXYlp ","))
		CMainDataCNetnameXY = nth(1 parseString(CoupMissListXYlp ","))
		CMainDataRefdesXY = nth(2 parseString(CoupMissListXYlp ","))
		CMainDataSymNameXY = nth(3 parseString(CoupMissListXYlp ","))
		if(CXYMNetname == CMainDataMNetnameXY && CXYCNetname == CMainDataCNetnameXY && CXYRefdes == CMainDataRefdesXY then
			CXYData = sprintf(nil "%s,%s", CoupMissListXYlp, CXYMain)  
			when(CXYData push(CXYData upCoupMissList))
		)	
	)
)
upCoupMissList = unique(upCoupMissList)


MissMatchList = nil
MainMissMatch = nil
CoupMissMatch = nil
foreach(MainMissListlp upMainMissList
	MainDataMNetname = nth(0 parseString(MainMissListlp ","))
	MainDataCNetname = nth(1 parseString(MainMissListlp ","))
	MainDataRefdes = nth(2 parseString(MainMissListlp ","))
	MainDataSymName = nth(3 parseString(MainMissListlp ","))
	MainDataXY = nth(4 parseString(MainMissListlp ","))	
	foreach(CoupMissListlp upCoupMissList
		CoupDataMNetname = nth(0 parseString(CoupMissListlp ","))
		CoupDataCNetname = nth(1 parseString(CoupMissListlp ","))
		CoupDataRefdes = nth(2 parseString(CoupMissListlp ","))
		CoupDataSymName = nth(3 parseString(CoupMissListlp ","))
		CoupDataXY = nth(4 parseString(CoupMissListlp ","))
			if(MainDataMNetname == CoupDataMNetname && MainDataCNetname == CoupDataCNetname then
				pcre_data = pcreCompile(MainDataRefdes)
				when(pcreExecute(pcre_data CoupDataRefdes)
					MissMatchData = sprintf(nil "%s,%s,%s,%s,%s,%s", MainDataMNetname, MainDataCNetname, MainDataSymName, CoupDataSymName, MainDataXY, CoupDataXY)
					;MainMissMatchData = sprintf(nil "%s,%s,%s,%s", MainDataMNetname, MainDataCNetname, MainDataRefdes, MainDataSymName)
					;CoupMissMatchData = sprintf(nil "%s,%s,%s,%s", CoupDataMNetname, CoupDataCNetname, CoupDataRefdes, CoupDataSymName) 
					when(MissMatchData push(MissMatchData MissMatchList))
					when(MainMissListlp push(MainMissListlp MainMissMatch))
					when(CoupMissListlp push(CoupMissListlp CoupMissMatch))
				)
			
			)
	)
)

MissMatchList = unique(MissMatchList)

MainMissMatchFilt = nil
MainMissMatchFilt = setof(item3, upMainMissList, !member(item3, MainMissMatch)) 
MainMissMatchFilt = unique(MainMissMatchFilt)

CoupMissMatchFilt = nil
CoupMissMatchFilt = setof(item4, upCoupMissList, !member(item4, CoupMissMatch)) 
CoupMissMatchFilt = unique(CoupMissMatchFilt)

FinalList = nil
FinalList = append(MissMatchList MainMissMatchFilt)

FinalListUP = nil
FinalListUP = append(FinalList CoupMissMatchFilt)

axlVisibleSet(originalVisible)
axlShell("redisplay")

if(FinalListUP != nil then
	logfile = "CouponBrdCutOutSymCase2.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	
	if(MissMatchList != nil then
		fprintf(port, "%s\n\n", "SYMBOL MISSMATCH :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "MAIN SYMBOL NAME", "COUPON SYMBOL NAME", "MAIN XY LOCATION", "COUPON XY LOCATION")
		foreach(MissMatchListlp MissMatchList
			FinalListS_filt = parseString(MissMatchListlp ",")
			MainSymFilt = nth(2 FinalListS_filt) 
			MainSymFilt1 = nth(0 parseString(MainSymFilt "$")) 
			COUPSymFilt = nth(3 FinalListS_filt) 
			COUPSymFilt1 = nth(0 parseString(COUPSymFilt "$")) 
			MainXY = nth(4 FinalListS_filt)
			COUPXY = nth(5 FinalListS_filt) 
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), MainSymFilt1, COUPSymFilt1, MainXY, COUPXY)
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR - EVERY VALUE FOUND..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(MainMissMatchFilt != nil then
		fprintf(port, "%s\n\n", "SYMBOL MISSING IN COUPON BOARD :")
		fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "SYMBOL NAME", "MAIN XY LOCATION")
		foreach(FinalListlp MainMissMatchFilt
			FinalList_filt = parseString(FinalListlp ",")
			SymNameFinal = nth(3 FinalList_filt)
			SymNameFinal1 = nth(0 parseString(SymNameFinal "$")) 
			fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 FinalList_filt), nth(1 FinalList_filt), SymNameFinal1, nth(4 FinalList_filt))
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR - EVERY VALUE FOUND..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(CoupMissMatchFilt != nil then
		fprintf(port, "%s\n\n", "SYMBOL MISSING IN MAIN BOARD :")
		fprintf(port, "%-25s %-25s %-25s  %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "SYMBOL NAME", "COUPON XY LOCATION")
		foreach(FinalCountListlp CoupMissMatchFilt 
			COUNT_filt = parseString(FinalCountListlp ",")
			SymNameFinalC = nth(3 COUNT_filt)
			SymNameFinalC1 = nth(0 parseString(SymNameFinalC "$"))
			fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 COUNT_filt), nth(1 COUNT_filt), SymNameFinalC1, nth(4 COUNT_filt)) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR - EVERY VALUE FOUND..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Coupon Cutout Symbol", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Error Found...!")
)
)