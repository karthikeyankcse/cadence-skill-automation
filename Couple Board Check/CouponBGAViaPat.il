axlCmdRegister("CouponBGAViaPattern" 'CouponBGAViaPattern)
procedure(CouponBGAViaPattern()
CP_Brow = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	CP_OpenFile = axlDMFileParts(CP_Brow)
	CP_DataInFile = axlDMOpenFile("ALLEGRO_TEXT" cadr(CP_OpenFile) "r") 
	CP_UserInput = nil
		while(gets(CP_Inp_Val CP_DataInFile)
			CP_Inp_Val = car(parseString(CP_Inp_Val "\n"))
				when(CP_Inp_Val push(CP_Inp_Val CP_UserInput))
			)
axlDMClose(CP_DataInFile)
CP_UserInput = unique(CP_UserInput)
Inp_Distance = axlEnterString(?prompts list("Enter the Distance Value...!"))
Inp_Distance = atof(Inp_Distance)
originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")
MainBrdList = nil
MainCountList = nil
MainBrdXYList = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
MainViaINP = axlGetSelSet(axlAddSelectAll())   
axlClearSelSet()
foreach(MainViaINPlp MainViaINP
	MainInpViaNetName = MainViaINPlp->net->name
	MainInpViaX = car(MainViaINPlp->xy)
	MainInpViaY = cadr(MainViaINPlp->xy)
	foreach(CP_UserInputlp CP_UserInput
	UserMainNetname = nth(0 parseString(CP_UserInputlp ",")) 
		if(UserMainNetname == MainInpViaNetName then
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
			PinINP = axlGetSelSet(axlAddSelectPoint(MainInpViaX:MainInpViaY))
			PinVal = car(PinINP)
			if(PinVal != nil then
				BoxTopX = MainInpViaX - Inp_Distance 
				BoxTopY = MainInpViaY + Inp_Distance
				BoxBotX = MainInpViaX + Inp_Distance
				BoxBotY = MainInpViaY - Inp_Distance
				axlClearSelSet()
				axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
				BoxViaInp = axlGetSelSet(axlSingleSelectBox( list(BoxTopX:BoxTopY BoxBotX:BoxBotY)))
				count = 0
				foreach(BoxViaInplp BoxViaInp
					BoxViaInpNetName = BoxViaInplp->net->name
					BoxViaInpX = car(BoxViaInplp->xy)
					BoxViaInpY = cadr(BoxViaInplp->xy)
					pcre_GND = pcreCompile("GND")
					if(pcreExecute(pcre_GND BoxViaInpNetName) then
						CalDisVal = axlDistance(MainInpViaX:MainInpViaY BoxViaInpX:BoxViaInpY)
						MainBrdData = sprintf(nil "%s,%.2f,(%.2f %.2f)", CP_UserInputlp, CalDisVal, MainInpViaX, MainInpViaY)
						MainBrdDataChk = sprintf(nil "%s,%.2f", CP_UserInputlp, CalDisVal) 
						when(MainBrdDataChk push(MainBrdDataChk MainBrdList))
						when(MainBrdData push(MainBrdData MainBrdXYList))
						count = count + 1
					)
				)
				if(count != 0 then
					CountVal = sprintf(nil "%s,%d", CP_UserInputlp, count) 
					when(CountVal push(CountVal MainCountList))
				)
			)
		)
	)
)
MainBrdXYList = unique(MainBrdXYList)

CouponBrdList = nil
CouponBrdListChk = nil
CouponBrdCountList = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
CouponViaINP = axlGetSelSet(axlAddSelectAll())   
axlClearSelSet()
foreach(CouponViaINPlp CouponViaINP
	CouponInpViaNetName = CouponViaINPlp->net->name
	CouponInpViaX = car(CouponViaINPlp->xy)
	CouponInpViaY = cadr(CouponViaINPlp->xy)
	foreach(C_CP_UserInputlp CP_UserInput
	UserCouponNetname = nth(1 parseString(C_CP_UserInputlp ",")) 
		if(UserCouponNetname == CouponInpViaNetName then
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
			C_PinINP = axlGetSelSet(axlAddSelectPoint(CouponInpViaX:CouponInpViaY))
			C_PinVal = car(C_PinINP)
			if(C_PinVal != nil then
				C_BoxTopX = CouponInpViaX - Inp_Distance 
				C_BoxTopY = CouponInpViaY + Inp_Distance
				C_BoxBotX = CouponInpViaX + Inp_Distance
				C_BoxBotY = CouponInpViaY - Inp_Distance
				axlClearSelSet()
				axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
				C_BoxViaInp = axlGetSelSet(axlSingleSelectBox( list(C_BoxTopX:C_BoxTopY C_BoxBotX:C_BoxBotY)))
				C_Count = 0
				foreach(C_BoxViaInplp C_BoxViaInp
					C_BoxViaInpNetName = C_BoxViaInplp->net->name
					C_BoxViaInpX = car(C_BoxViaInplp->xy)
					C_BoxViaInpY = cadr(C_BoxViaInplp->xy)
					C_pcre_GND = pcreCompile("GND")
					if(pcreExecute(C_pcre_GND C_BoxViaInpNetName) then
						C_CalDisVal = axlDistance(CouponInpViaX:CouponInpViaY C_BoxViaInpX:C_BoxViaInpY)
						CouponBrdData = sprintf(nil "%s,%.2f,(%.2f %.2f),(%.2f %.2f)", C_CP_UserInputlp, C_CalDisVal, C_BoxViaInpX, C_BoxViaInpY, CouponInpViaX, CouponInpViaY)
						CouponBrdDataChk = sprintf(nil "%s,%.2f", C_CP_UserInputlp, C_CalDisVal) 
						when(CouponBrdDataChk push(CouponBrdDataChk CouponBrdListChk))
						when(CouponBrdData push(CouponBrdData CouponBrdList))
						C_Count = C_Count + 1
					)
				)
				if(C_Count != 0 then
					C_CountVal = sprintf(nil "%s,%d", C_CP_UserInputlp, C_Count)
					when(C_CountVal push(C_CountVal CouponBrdCountList))
				)
			)
		)
	)
)
NonMemList = nil
NonMemList = setof(item, CouponBrdListChk, !member(item, MainBrdList))
NonMemList = unique(NonMemList)

CouponBrdList = unique(CouponBrdList)
FinalList = nil
foreach(NonMemListlp NonMemList
	NMValNN1 = nth(0 parseString(NonMemListlp ","))
	NMValNN2 = nth(1 parseString(NonMemListlp ",")) 	
	NMValDst = nth(2 parseString(NonMemListlp ","))
		foreach(CouponBrdDatalp CouponBrdList
			ValNN1 = nth(0 parseString(CouponBrdDatalp ","))
			ValNN2 = nth(1 parseString(CouponBrdDatalp ",")) 
			ValDst = nth(2 parseString(CouponBrdDatalp ","))
		if(ValNN1 == NMValNN1 && ValNN2 == NMValNN2 && ValDst == NMValDst then
			when(CouponBrdDatalp push(CouponBrdDatalp FinalList))
		)
	)
)
FinalList = unique(FinalList)

FinalListUpdate = nil
foreach(FinalListUplp FinalList
	FinalMainNetname = nth(0 parseString(FinalListUplp ","))
	FinalCoupNetname = nth(1 parseString(FinalListUplp ","))
	foreach(MainBrdXYListuplp MainBrdXYList
		MainFinalMainNetname = nth(0 parseString(MainBrdXYListuplp ","))
		MainFinalCoupNetname = nth(1 parseString(MainBrdXYListuplp ","))
		MainFinalCoupXY = nth(3 parseString(MainBrdXYListuplp ","))
		if(FinalMainNetname == MainFinalMainNetname && FinalCoupNetname == MainFinalCoupNetname then
			FinalDataUpdate = sprintf(nil "%s,%s", FinalListUplp, MainFinalCoupXY)
			when(FinalDataUpdate push(FinalDataUpdate FinalListUpdate))
		)
	)
)
FinalListUpdate = unique(FinalListUpdate)


CountMissList = nil
CountMissList = setof(item1, CouponBrdCountList, !member(item1, MainCountList))
CountMissList = unique(CountMissList)

FinalCountList = nil
if(CountMissList != nil then
	foreach(CountMissListlp CountMissList
		CountNetNameM = nth(0 parseString(CountMissListlp ","))
		CountNetNameC = nth(1 parseString(CountMissListlp ","))
		foreach(CouponBrdListlpC CouponBrdList
			CouponNetNameM = nth(0 parseString(CouponBrdListlpC ",")) 
			CouponNetNameC = nth(1 parseString(CouponBrdListlpC ","))
			CouponXYC = nth(4 parseString(CouponBrdListlpC ","))
			if(CountNetNameM == CouponNetNameM && CountNetNameC == CouponNetNameC then
				foreach(MainBrdDataChklpC MainCountList
					MainNetNameM = nth(0 parseString(MainBrdDataChklpC ",")) 
					MainNetNameC = nth(1 parseString(MainBrdDataChklpC ","))
					MainCount = nth(2 parseString(MainBrdDataChklpC ","))
					if(CountNetNameM == MainNetNameM && CountNetNameC == MainNetNameC then
						FinalCountVal = sprintf(nil "%s,%s,%s", CountMissListlp, MainCount, CouponXYC) 
						when(FinalCountVal push(FinalCountVal FinalCountList))
					)
				)
			)
		)
	)
)
FinalCountList = unique(FinalCountList)


FinalCountUpdateList = nil
foreach(FinalCountListxylp FinalCountList
	FinalCountMainNetName = nth(0 parseString(FinalCountListxylp ",")) 
	FinalCountCoupNetName = nth(1 parseString(FinalCountListxylp ","))
	foreach(MainBrdXYListlp MainBrdXYList
		MainCountMainNetName = nth(0 parseString(MainBrdXYListlp ",")) 
		MainCountCoupNetName = nth(1 parseString(MainBrdXYListlp ","))
		MainCountXY = nth(3 parseString(MainBrdXYListlp ","))
		if(MainCountMainNetName == FinalCountMainNetName && FinalCountCoupNetName == MainCountCoupNetName then
			FinalCountUpdatedata = sprintf(nil "%s,%s", FinalCountListxylp, MainCountXY)  
			when(FinalCountUpdatedata push(FinalCountUpdatedata FinalCountUpdateList))
		)
	)
)
FinalCountUpdateList = unique(FinalCountUpdateList)

axlVisibleSet(originalVisible)
axlShell("redisplay")

Result = nil
Result = append(FinalList FinalCountUpdateList) 

if(Result != nil then
	logfile = "CouponBrdBGAViaPattern.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "--------------------------------------------------------------------------------------------------------------------------------------------------------")
	
	if(FinalListUpdate != nil then
		fprintf(port, "%s\n\n", "ERROR LIST :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "DISTANCE", "MAIN XY LOCATION", "COUPON XY LOCATION")
		foreach(FinalListlp FinalListUpdate
			FinalList_filt = parseString(FinalListlp ",")
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalList_filt), nth(1 FinalList_filt), nth(2 FinalList_filt), nth(5 FinalList_filt), nth(4 FinalList_filt))
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(FinalCountUpdateList != nil then
		fprintf(port, "%s\n\n", "MISS MATCHING COUNT :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "COUPON COUNT", "MAIN COUNT", "MAIN XY LOCATION", "COUPON XY LOCATION")
		foreach(FinalCountListlp FinalCountUpdateList
			COUNT_filt = parseString(FinalCountListlp ",")
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s \n", nth(0 COUNT_filt), nth(1 COUNT_filt), nth(2 COUNT_filt), nth(3 COUNT_filt), nth(5 COUNT_filt), nth(4 COUNT_filt)) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO MISS MATCHING COUNT")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------")
	)
	
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Coupon Board Length", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Error Found...!")
)
)