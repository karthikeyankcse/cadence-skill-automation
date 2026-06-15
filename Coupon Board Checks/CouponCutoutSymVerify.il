axlCmdRegister("CouponCutoutSymVerify" 'CouponCutoutSymVerify)
procedure(CouponCutoutSymVerify()
CP3_Brow = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	CP3_OpenFile = axlDMFileParts(CP3_Brow)
	CP3_DataInFile = axlDMOpenFile("ALLEGRO_TEXT" cadr(CP3_OpenFile) "r") 
	CP3_UserInput = nil
		while(gets(CP3_Inp_Val CP3_DataInFile)
			CP3_Inp_Val = car(parseString(CP3_Inp_Val "\n"))
				when(CP3_Inp_Val push(CP3_Inp_Val CP3_UserInput))
			)
axlDMClose(CP3_DataInFile)
CP3_UserInput = unique(CP3_UserInput)
originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")
MechSymList = nil
PackSymList = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
MainViaINP = axlGetSelSet(axlAddSelectAll())   
axlClearSelSet()
foreach(MainViaINPlp MainViaINP
	MainViaNetName = MainViaINPlp->net->name 
	MainViaX = car(MainViaINPlp ->xy)
	MainViaY = cadr(MainViaINPlp ->xy) 
	foreach(CP3_UserInputlp CP3_UserInput
		CP3MainNetname = nth(0 parseString(CP3_UserInputlp ","))
		if(CP3MainNetname == MainViaNetName then 
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "SYMBOLS") ?onButtons `("SYMBOLS"))
			SymINP = axlGetSelSet(axlSingleSelectBox(list(MainViaX:MainViaY MainViaX:MainViaY)))
				if(SymINP != nil then
					foreach(SymINPlp SymINP
						Sym_name = SymINPlp ->name
						Sym_Type = SymINPlp	->type
						Sym_X = car(SymINPlp ->xy)
						Sym_Y = cadr(SymINPlp ->xy) 
						Sym_Ref = SymINPlp->refdes 
						if(Sym_Type == "MECHANICAL" then
							MechSymData = sprintf(nil "%s,%s", CP3_UserInputlp, Sym_name)
							when(MechSymData push(MechSymData MechSymList))
						else
							Sym_Ref = upperCase(Sym_Ref)
							Sym_RefSub = substring(Sym_Ref 1 1)
							if(Sym_RefSub == "V" then
								PackSymData = sprintf(nil "%s,%s", CP3_UserInputlp, Sym_name)
								when(PackSymData push(PackSymData PackSymList))
							)
	
						)
					)
				)
		)
	)
)

MDUPRemoveListPack = nil
myTable2 = makeTable("myTable2" 0)
foreach(PackSymListlp PackSymList
	myTable2[PackSymListlp] = 1 + myTable2[PackSymListlp]
	GetData2 = PackSymListlp
	CountData2 = myTable2[PackSymListlp]
	if(CountData2 == 1 then
		when(PackSymListlp push(PackSymListlp MDUPRemoveListPack))
	else
		CountDataUpdate1 = sprintf(nil "%s$%d", PackSymListlp, CountData2)
		when(CountDataUpdate1 push(CountDataUpdate1 MDUPRemoveListPack))	
	)
)
MDUPRemoveListPack = unique(MDUPRemoveListPack)


MDUPRemoveListMech = nil
myTable3 = makeTable("myTable3" 0)
foreach(MechSymListlp MechSymList
	myTable3[MechSymListlp] = 1 + myTable3[MechSymListlp]
	GetData3 = MechSymListlp
	CountData3 = myTable3[MechSymListlp]
	if(CountData3 == 1 then
		when(MechSymListlp push(MechSymListlp MDUPRemoveListMech))
	else
		CountDataUpdate2 = sprintf(nil "%s$%d", MechSymListlp, CountData3)
		when(CountDataUpdate2 push(CountDataUpdate2 MDUPRemoveListMech))	
	)
)
MDUPRemoveListMech = unique(MDUPRemoveListMech)

MainSymList = nil
MainSymList = append(MDUPRemoveListMech MDUPRemoveListPack)
MainSymList = unique(MainSymList)


COUPMechSymList = nil
COUPPackSymList = nil

axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
COUPViaINP = axlGetSelSet(axlAddSelectAll())   
axlClearSelSet()
foreach(COUPViaINPlp COUPViaINP
	COUPViaNetName = COUPViaINPlp->net->name 
	COUPViaX = car(COUPViaINPlp ->xy)
	COUPViaY = cadr(COUPViaINPlp ->xy)
	foreach(CP3_UserInputlpS CP3_UserInput
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
							COUPSymData = sprintf(nil "%s,%s", CP3_UserInputlpS, Sym_nameS)
							when(COUPSymData push(COUPSymData COUPMechSymList))
						else
							Sym_RefS = upperCase(Sym_RefS)
							Sym_RefSubS = substring(Sym_RefS 3 1)
							if(Sym_RefSubS == "V" then
								PackSymDataS = sprintf(nil "%s,%s", CP3_UserInputlpS, Sym_nameS)
								when(PackSymDataS push(PackSymDataS COUPPackSymList))
							)	
						)
					)
				)
		)
	)
)

DUPRemoveListMech = nil
myTable = makeTable("myTable" 0)
foreach(COUPMechSymListlp COUPMechSymList
	myTable[COUPMechSymListlp] = 1 + myTable[COUPMechSymListlp]
	GetData = COUPMechSymListlp
	CountData = myTable[COUPMechSymListlp]
	if(CountData == 1 then
		when(COUPMechSymListlp push(COUPMechSymListlp DUPRemoveListMech))
	else
		CountDataUpdate = sprintf(nil "%s-%d", COUPMechSymListlp, CountData)
		when(CountDataUpdate push(CountDataUpdate DUPRemoveListMech))	
	)
)

DUPRemoveListMech = unique(DUPRemoveListMech)

DUPRemoveListPack = nil
myTable1 = makeTable("myTable1" 0)
foreach(COUPPackSymListlp COUPPackSymList
	myTable1[COUPPackSymListlp] = 1 + myTable1[COUPPackSymListlp]
	GetData1 = COUPPackSymListlp
	CountData1 = myTable1[COUPPackSymListlp]
	if(CountData1 == 1 then
		when(COUPPackSymListlp push(COUPPackSymListlp DUPRemoveListPack))
	else
		CountDataUpdate1 = sprintf(nil "%s-%d", COUPPackSymListlp, CountData1)
		when(CountDataUpdate1 push(CountDataUpdate1 DUPRemoveListPack))	
	)
)

DUPRemoveListPack = unique(DUPRemoveListPack)

COUPSymList = nil
COUPSymList = append(DUPRemoveListMech DUPRemoveListPack)

MMSymListFilt = nil
MMSymListFilt = setof(item1, COUPSymList, !member(item1, MainSymList))
CMSymListFilt = nil
CMSymListFilt = setof(item2, MainSymList, !member(item2, COUPSymList))

SymMissMatchList = nil
MainMissListFilt = nil
CouponMissListFilt = nil
foreach(CMSymListFiltlp CMSymListFilt
C_MainNetName = nth(0 parseString(CMSymListFiltlp ",")) 
C_CouponNetName = nth(1 parseString(CMSymListFiltlp ","))
C_SymName = nth(2 parseString(CMSymListFiltlp ","))  
	foreach(MMSymListFiltlp MMSymListFilt
		MainNetName = nth(0 parseString(MMSymListFiltlp ",")) 
		CouponNetName = nth(1 parseString(MMSymListFiltlp ","))
		SymName = nth(2 parseString(MMSymListFiltlp ",")) 
		if(C_MainNetName == MainNetName && C_CouponNetName == CouponNetName then 
			SymMissMatchData = sprintf(nil "%s,%s,%s,%s", MainNetName, C_CouponNetName, C_SymName, SymName)
			MainMissData = sprintf(nil "%s,%s,%s", MainNetName, CouponNetName, SymName)
			COUPMissData = sprintf(nil "%s,%s,%s", C_MainNetName, C_CouponNetName, C_SymName) 
			when(SymMissMatchData push(SymMissMatchData SymMissMatchList))
			when(MainMissData push(MainMissData MainMissListFilt))
			when(COUPMissData push(COUPMissData CouponMissListFilt))
		)
	)
)
SymMissMatchList = unique(SymMissMatchList)
MainMissListFilt = unique(MainMissListFilt)
CouponMissListFilt = unique(CouponMissListFilt)

MainMissList = nil
MainMissList = setof(item3, MMSymListFilt, !member(item3, MainMissListFilt))
MainMissList = unique(MainMissList)

CouponMissList = nil
CouponMissList = setof(item4, CMSymListFilt, !member(item4, CouponMissListFilt))
CouponMissList = unique(CouponMissList)

axlVisibleSet(originalVisible)
axlShell("redisplay")

FinalErrorList = nil
FinalErrorList = append(SymMissMatchList MainMissList)

FinalErrorList1 = nil
FinalErrorList1 = append(FinalErrorList CouponMissList)

if(FinalErrorList1 != nil then
	logfile = "CouponBrdCutOutSym.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	
	if(SymMissMatchList != nil then
		fprintf(port, "%s\n\n", "SYMBOL MISSMATCH :")
		fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "MAIN SYMBOL NAME", "COUPON SYMBOL NAME")
		foreach(FinalListSlp SymMissMatchList
			FinalListS_filt = parseString(FinalListSlp ",")
			MainSymFilt = nth(2 FinalListS_filt) 
			MainSymFilt1 = nth(0 parseString(MainSymFilt "$")) 
			COUPSymFilt = nth(3 FinalListS_filt) 
			COUPSymFilt1 = nth(0 parseString(COUPSymFilt "$")) 
			fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), MainSymFilt1, COUPSymFilt1)
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR - EVERY VALUE FOUND..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(MainMissList != nil then
		fprintf(port, "%s\n\n", "SYMBOL MISSING IN MAIN BOARD :")
		fprintf(port, "%-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "SYMBOL NAME")
		foreach(FinalListlp MainMissList
			FinalList_filt = parseString(FinalListlp ",")
			SymNameFinal = nth(2 FinalList_filt)
			SymNameFinal1 = nth(0 parseString(SymNameFinal "$")) 
			fprintf(port, "%-25s %-25s %-25s \n", nth(0 FinalList_filt), nth(1 FinalList_filt), SymNameFinal1)
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR - EVERY VALUE FOUND..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(CouponMissList != nil then
		fprintf(port, "%s\n\n", "SYMBOL MISSING IN COUPON BOARD :")
		fprintf(port, "%-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "SYMBOL NAME")
		foreach(FinalCountListlp CouponMissList 
			COUNT_filt = parseString(FinalCountListlp ",")
			SymNameFinalC = nth(2 COUNT_filt)
			SymNameFinalC1 = nth(0 parseString(SymNameFinalC "$"))
			fprintf(port, "%-25s %-25s %-25s \n", nth(0 COUNT_filt), nth(1 COUNT_filt), SymNameFinalC1) 
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