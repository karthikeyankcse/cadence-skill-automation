axlCmdRegister("CouponBrd_Routing" 'CouponBrd_Routing)
procedure(CouponBrd_Routing()
inp_prop_addEX = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	prop_addEX = axlDMFileParts(inp_prop_addEX)
	propinp_addEX = axlDMOpenFile("ALLEGRO_TEXT" cadr(prop_addEX) "r") 
	propinp_netname_addEX = nil
		while(gets(p_inp_addEX propinp_addEX)
			p_inp_addEX = car(parseString(p_inp_addEX "\n"))
				when(p_inp_addEX push(p_inp_addEX propinp_netname_addEX))
			)
axlDMClose(propinp_addEX)
propinp_netname_addEX = unique(propinp_netname_addEX)
originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")
ClineMainBrdList = nil
ClineMainMissList = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
;ClineINP = axlGetSelSet(axlSelect( ))
ClineINP = axlGetSelSet(axlAddSelectAll()) 
axlClearSelSet()
foreach(ClineINPlp ClineINP
	CLineSegList = nil
	CLineSegListWid = nil
	ClineINPNN = ClineINPlp->net->name
	foreach(propinp_netname_addEXlp propinp_netname_addEX
		UserInpMainBrd = nth(0 parseString(propinp_netname_addEXlp ",")) 
		UserInpCOPBrd = nth(1 parseString(propinp_netname_addEXlp ","))
		if(ClineINPNN == UserInpMainBrd then 
			when(ClineINPlp->objType == "path"
				foreach(ClineSeglp ClineINPlp ->segments
					ClineSegNetName = ClineSeglp->net->name
					ClineSegLayer = nth(1 parseString(ClineSeglp -> layer "/"))
					ClineSegWidth = ClineSeglp->width
					ClineSeglengt = axlDBGetLength(ClineSeglp)
					CLineSegData = sprintf(nil "%s$%s,%s,%.2f,%.2f", UserInpMainBrd, UserInpCOPBrd, ClineSegLayer, ClineSegWidth, ClineSeglengt)
					when(CLineSegData push(CLineSegData CLineSegList))
					when(ClineSegWidth push(ClineSegWidth CLineSegListWid))
				)
			)
		)
	)
	CLineSegListWid = unique(CLineSegListWid)
	foreach(CLineSegListWidlp CLineSegListWid
		DummyVal = 1
		 CLineSegListWidFlt = CLineSegListWidlp
		 foreach(CLineSegListlp CLineSegList
			CLineSegFListNN = nth(0 parseString(CLineSegListlp ","))
			CLineSegFListLyr = nth(1 parseString(CLineSegListlp ","))
			CLineSegFListwid = atof(nth(2 parseString(CLineSegListlp ",")))
			CLineSegFListlen = atof(nth(3 parseString(CLineSegListlp ",")))
			if(CLineSegFListwid == CLineSegListWidFlt then
				if(DummyVal == 1 then
					CalLenVal = CLineSegFListlen
					DummyVal = DummyVal + 1
					widVal = CLineSegListWidFlt 
				else
					CalLenVal = CalLenVal + CLineSegFListlen
				)
			)
		 )
		CalMainBrdList = sprintf(nil "%s,%s,%.2f,%.2f", CLineSegFListNN, CLineSegFListLyr, widVal, CalLenVal) 
		CalMainBrdListMiss = sprintf(nil "%s,%s,%.2f", CLineSegFListNN, CLineSegFListLyr, widVal) 
		when(CalMainBrdList push(CalMainBrdList ClineMainBrdList))
		when(CalMainBrdListMiss push(CalMainBrdListMiss ClineMainMissList))
		
	)
)
ClineMainBrdList = unique(ClineMainBrdList)
ClineMainMissList = unique(ClineMainMissList)

UpClineMainBrdList = nil
filtlist = nil
foreach(ClineMainBrdListlpAdd ClineMainBrdList
	val1 = nth(0 parseString(ClineMainBrdListlpAdd ",")) 
	val2 = nth(1 parseString(ClineMainBrdListlpAdd ","))
	val3 = nth(2 parseString(ClineMainBrdListlpAdd ","))
	val4 = nth(3 parseString(ClineMainBrdListlpAdd ","))
	foreach(ClineMainBrdListlpAddS ClineMainBrdList
		Sval1 = nth(0 parseString(ClineMainBrdListlpAddS ",")) 
		Sval2 = nth(1 parseString(ClineMainBrdListlpAddS ","))
		Sval3 = nth(2 parseString(ClineMainBrdListlpAddS ","))
		Sval4 = nth(3 parseString(ClineMainBrdListlpAddS ","))
		if(val1 == Sval1 && val2 == Sval2 && val3 == Sval3 && val4 != Sval4 then
			Upval4 = atof(val4)
			UpSval4 = atof(Sval4)
			UPVal = Upval4 + UpSval4
			UpdateData = sprintf(nil "%s,%s,%s,%.2f", val1, val2, val3, UPVal)
			when(UpdateData push(UpdateData UpClineMainBrdList))
			when(ClineMainBrdListlpAdd push(ClineMainBrdListlpAdd filtlist))
		)
	)
)
UpClineMainBrdList = unique(UpClineMainBrdList)

UpdateMainList = nil
UpdateMainList = setof(Loc3, ClineMainBrdList, !member(Loc3, filtlist))

UpdateMainFinalList = nil
UpdateMainFinalList = append(UpdateMainList UpClineMainBrdList)

ClineMainBrdListCOP = nil
ClineMainBrdListMissCOP = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
;ClineINPCOP = axlGetSelSet(axlSelect( ))
ClineINPCOP = axlGetSelSet(axlAddSelectAll()) 
axlClearSelSet()
foreach(ClineINPlpCOP ClineINPCOP
	CLineSegListCOP = nil
	CLineSegListWidCOP = nil
	ClineINPNNCOP = ClineINPlpCOP->net->name
	foreach(propinp_netname_addEXlpCOP propinp_netname_addEX
		UserInpMainBrdC = nth(0 parseString(propinp_netname_addEXlpCOP ","))
		UserInpCOPBrdC = nth(1 parseString(propinp_netname_addEXlpCOP ","))
		if(ClineINPNNCOP == UserInpCOPBrdC then 
			when(ClineINPlpCOP->objType == "path"
				foreach(ClineSeglpCOP ClineINPlpCOP ->segments
					ClineSegNetNameCOP = ClineSeglpCOP->net->name
					ClineSegLayerCOP = nth(1 parseString(ClineSeglpCOP -> layer "/"))
					ClineSegWidthCOP = ClineSeglpCOP->width
					ClineSeglengtCOP = axlDBGetLength(ClineSeglpCOP)
					CLineSegDataCOP = sprintf(nil "%s$%s,%s,%.2f,%.2f", UserInpMainBrdC, UserInpCOPBrdC, ClineSegLayerCOP, ClineSegWidthCOP, ClineSeglengtCOP)
					when(CLineSegDataCOP push(CLineSegDataCOP CLineSegListCOP))
					when(ClineSegWidthCOP push(ClineSegWidthCOP CLineSegListWidCOP))
				)
			)
		)
	)
	CLineSegListWidCOP = unique(CLineSegListWidCOP)
	foreach(CLineSegListWidlpCOP CLineSegListWidCOP
		DummyValCOP = 1
		 CLineSegListWidFltCOP = CLineSegListWidlpCOP
		 foreach(CLineSegListlpCOP CLineSegListCOP
			CLineSegFListNNCOP = nth(0 parseString(CLineSegListlpCOP ","))
			CLineSegFListLyrCOP = nth(1 parseString(CLineSegListlpCOP ","))
			CLineSegFListwidCOP = atof(nth(2 parseString(CLineSegListlpCOP ",")))
			CLineSegFListlenCOP = atof(nth(3 parseString(CLineSegListlpCOP ",")))
			if(CLineSegFListwidCOP == CLineSegListWidFltCOP then
				if(DummyValCOP == 1 then
					CalLenValCOP = CLineSegFListlenCOP
					DummyValCOP = DummyValCOP + 1
					widValCOP = CLineSegListWidFltCOP 
				else
					CalLenValCOP = CalLenValCOP + CLineSegFListlenCOP
				)
			)
		 )
		CalMainBrdListCOP = sprintf(nil "%s,%s,%.2f,%.2f", CLineSegFListNNCOP, CLineSegFListLyrCOP, widValCOP, CalLenValCOP)
		CalMainBrdListCOPMiss = sprintf(nil "%s,%s,%.2f", CLineSegFListNNCOP, CLineSegFListLyrCOP, widValCOP)		
		when(CalMainBrdListCOP push(CalMainBrdListCOP ClineMainBrdListCOP))
		when(CalMainBrdListCOPMiss push(CalMainBrdListCOPMiss ClineMainBrdListMissCOP))
	)
)
ClineMainBrdListCOP = unique(ClineMainBrdListCOP)
ClineMainBrdListMissCOP = unique(ClineMainBrdListMissCOP)


CUpClineMainBrdList = nil
Cfiltlist = nil
foreach(ClineMainBrdListlpAddCOP ClineMainBrdListCOP
	COPval1 = nth(0 parseString(ClineMainBrdListlpAddCOP ",")) 
	COPval2 = nth(1 parseString(ClineMainBrdListlpAddCOP ","))
	COPval3 = nth(2 parseString(ClineMainBrdListlpAddCOP ","))
	COPval4 = nth(3 parseString(ClineMainBrdListlpAddCOP ","))
	foreach(ClineMainBrdListlpAddSCOP ClineMainBrdListCOP
		COPSval1 = nth(0 parseString(ClineMainBrdListlpAddSCOP ",")) 
		COPSval2 = nth(1 parseString(ClineMainBrdListlpAddSCOP ","))
		COPSval3 = nth(2 parseString(ClineMainBrdListlpAddSCOP ","))
		COPSval4 = nth(3 parseString(ClineMainBrdListlpAddSCOP ","))
		if(COPval1 == COPSval1 && COPval2 == COPSval2 && COPval3 == COPSval3 && COPval4 != COPSval4 then
			COPUpval4 = atof(COPval4)
			COPUpSval4 = atof(COPSval4)
			COPUPVal = COPUpval4 + COPUpSval4
			COPUpdateData = sprintf(nil "%s,%s,%s,%.2f", COPval1, COPval2, COPval3, COPUPVal)
			when(COPUpdateData push(COPUpdateData CUpClineMainBrdList))	
			when(ClineMainBrdListlpAddCOP push(ClineMainBrdListlpAddCOP Cfiltlist))
		)
	)
)
CUpClineMainBrdList = unique(CUpClineMainBrdList)
Cfiltlist = unique(Cfiltlist)

CUpdateMainList = nil
CUpdateMainList = setof(Loc3, ClineMainBrdListCOP, !member(Loc3, Cfiltlist))

CUpdateMainFinalList = nil
CUpdateMainFinalList = append(CUpdateMainList CUpClineMainBrdList)

MainMiss = nil
MainMiss = setof(Loc1, ClineMainMissList, !member(Loc1, ClineMainBrdListMissCOP))
MainMiss = unique(MainMiss)


COPMiss = nil
COPMiss = setof(Loc2, ClineMainBrdListMissCOP, !member(Loc2, ClineMainMissList))
COPMiss = unique(COPMiss)


OutPutList = nil
foreach(ClineMainBrdListCOPlp CUpdateMainFinalList
	ClineCOPNN = nth(0 parseString(ClineMainBrdListCOPlp ","))
	ClineCOPLyr = nth(1 parseString(ClineMainBrdListCOPlp ","))
	ClineCOPWid = nth(2 parseString(ClineMainBrdListCOPlp ","))
	ClineCOPLen = atof(nth(3 parseString(ClineMainBrdListCOPlp ",")))
	foreach(ClineMainBrdListlp UpdateMainFinalList
		ClineMainNN = nth(0 parseString(ClineMainBrdListlp ","))
		ClineMainLyr = nth(1 parseString(ClineMainBrdListlp ","))
		ClineMainWid = nth(2 parseString(ClineMainBrdListlp ","))
		ClineMainLen = atof(nth(3 parseString(ClineMainBrdListlp ",")))
			if(ClineCOPLyr == ClineMainLyr && ClineCOPWid == ClineMainWid && ClineCOPNN == ClineMainNN then
				CalVal = ClineCOPLen - ClineMainLen
				CalValstr = sprintf(nil "%.2f", CalVal)
				CalValFilt = nth(0 parseString(CalValstr "$"))
				CalValFinal = atof(CalValFilt)
				if(CalValFinal > 1 then
					OutputVal = sprintf(nil "%s,%s,%s,%.2f,%.2f,%.2f", ClineCOPNN, ClineCOPLyr, ClineCOPWid, ClineCOPLen, ClineMainLen, CalValFinal)      
					when(OutputVal push(OutputVal OutPutList))
				)
			)
	)
)

OutPutList = unique(OutPutList)


PINCOPMiss = nil
PINCOPMisslenAdd = nil
if(COPMiss != nil then
	PinFiltCOPList = nil
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
	PinInp = axlGetSelSet(axlAddSelectAll()) 
	axlClearSelSet()
	foreach(PinInplp PinInp
		PinNetName = PinInplp->net->name 
		PinRef = PinInplp->parent->refdes 
		foreach(COPMisschklp COPMiss
			COPNNPrse = nth(0 parseString(COPMisschklp ","))
			COPLyrPrse = nth(1 parseString(COPMisschklp ","))
			COPNNPrseFilt = nth(1 parseString(COPNNPrse "$"))
			if(COPNNPrseFilt == PinNetName then
				if(COPLyrPrse == "TOP" || COPLyrPrse == "BOTTOM" then
					pcre_SMA = pcreCompile("SMA")
					when(pcreExecute(pcre_SMA PinRef)
						when(COPMisschklp push(COPMisschklp PinFiltCOPList))
					)
				)
			)
		)
	)
PINCOPMiss = setof(Loc3, COPMiss, !member(Loc3, PinFiltCOPList))
PINCOPMiss = unique(PINCOPMiss)

foreach(PINCOPMisslplen PINCOPMiss
	PINCOPMissNN = nth(0 parseString(PINCOPMisslplen ",")) 
	PINCOPMissLyr = nth(1 parseString(PINCOPMisslplen ","))
	PINCOPMissWid = nth(2 parseString(PINCOPMisslplen ","))
	foreach(ClineMainBrdListCOPlenlp CUpdateMainFinalList
		OldCOPMissNN = nth(0 parseString(ClineMainBrdListCOPlenlp ",")) 
		OldCOPMissLyr = nth(1 parseString(ClineMainBrdListCOPlenlp ","))
		OldCOPMissWid = nth(2 parseString(ClineMainBrdListCOPlenlp ","))
		if(PINCOPMissNN == OldCOPMissNN && PINCOPMissLyr == OldCOPMissLyr && PINCOPMissWid == OldCOPMissWid then
			when(ClineMainBrdListCOPlenlp push(ClineMainBrdListCOPlenlp PINCOPMisslenAdd))
		)
	)
)
PINCOPMisslenAdd = unique(PINCOPMisslenAdd)
)

MainLenAddList = nil
foreach(MainMisslenlp MainMiss
	MainMissNN = nth(0 parseString(MainMisslenlp ",")) 
	MainMissLyr = nth(1 parseString(MainMisslenlp ","))
	MainMissWid = nth(2 parseString(MainMisslenlp ","))
	foreach(ClineMainBrdListlenlp UpdateMainList
		OldMainMissNN = nth(0 parseString(ClineMainBrdListlenlp ",")) 
		OldMainMissLyr = nth(1 parseString(ClineMainBrdListlenlp ","))
		OldMainMissWid = nth(2 parseString(ClineMainBrdListlenlp ","))
		if(OldMainMissNN == MainMissNN && MainMissLyr == OldMainMissLyr && MainMissWid == OldMainMissWid then
			when(ClineMainBrdListlenlp push(ClineMainBrdListlenlp MainLenAddList))
		)
	)
)
MainLenAddList = unique(MainLenAddList)

MainFiltList = nil
CoupFiltList = nil
WidthMissMatchList = nil
foreach(MainLenAddListlp MainLenAddList
	WidMainMissNN = nth(0 parseString(MainLenAddListlp ",")) 
	WidMainMissLyr = nth(1 parseString(MainLenAddListlp ","))
	WidMainMissWid = nth(2 parseString(MainLenAddListlp ","))
	foreach(PINCOPMisslenAddlp PINCOPMisslenAdd
		WidCoupMissNN = nth(0 parseString(PINCOPMisslenAddlp ",")) 
		WidCoupMissLyr = nth(1 parseString(PINCOPMisslenAddlp ","))
		WidCoupMissWid = nth(2 parseString(PINCOPMisslenAddlp ","))
		WidCoupMisslen = nth(3 parseString(PINCOPMisslenAddlp ","))
		if(WidMainMissNN == WidCoupMissNN && WidMainMissLyr == WidCoupMissLyr && WidMainMissWid != WidCoupMissWid then
			UpdatedData = sprintf(nil "%s,%s,%s", MainLenAddListlp, WidCoupMissWid, WidCoupMisslen) 
			when(UpdatedData push(UpdatedData WidthMissMatchList))
			when(MainLenAddListlp push(MainLenAddListlp MainFiltList))
			when(PINCOPMisslenAddlp push(PINCOPMisslenAddlp CoupFiltList))
		)
	)
)
WidthMissMatchList = unique(WidthMissMatchList)

MainFiltList = unique(MainFiltList)
CoupFiltList = unique(CoupFiltList)

FinalMainFiltList = nil
FinalMainFiltList = setof(flt1, MainLenAddList, !member(flt1, MainFiltList))
FinalMainFiltList = unique(FinalMainFiltList)

FinalCoupFiltList = nil
FinalCoupFiltList = setof(flt2, PINCOPMisslenAdd, !member(flt2, CoupFiltList))
FinalCoupFiltList = unique(FinalCoupFiltList)

axlVisibleSet(originalVisible)
axlShell("redisplay")

FinalAPP = append(FinalMainFiltList FinalCoupFiltList)
FinalAPPNxt = append(OutPutList FinalAPP)  
FinalAPPNxt1 = append(FinalAPPNxt WidthMissMatchList)
if(FinalAPPNxt1 != nil then
	logfile = "CouponBrdLen.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	
	if(OutPutList != nil then
		fprintf(port, "%s\n\n", "LENGTH MISSMATCHING ERROR LIST :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "LAYER", "WIDTH", "MAIN LENGTH", "COUPON LENGTH", "CALCULATED LENGTH")
		foreach(Final_Listlp OutPutList
			port_filt_inp = parseString(Final_Listlp ",")
			NN = nth(0 port_filt_inp)
			NNM = nth(0 parseString(NN "$"))
			NNC = nth(1 parseString(NN "$")) 
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s \n",NNM, NNC, nth(1 port_filt_inp), nth(2 port_filt_inp), nth(4 port_filt_inp), nth(3 port_filt_inp), nth(5 port_filt_inp)) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO MISSMATCHING DATA")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(WidthMissMatchList != nil then
		fprintf(port, "%s\n\n", "NOTE : SMA Pin Connected Net Ignored...")
		fprintf(port, "%s\n\n", "Trace Width Incorrect Between Main Board and Coupon Board :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "LAYER", "MAIN WIDTH", "COUPON WIDTH", "MAIN LENGTH", "COUPON LENGTH")
		foreach(WidthMissMatchListlp WidthMissMatchList
			WidthMissMatchList_filt = parseString(WidthMissMatchListlp ",")
			NetNameFilt = nth(0 WidthMissMatchList_filt)
			NetNameMain = nth(0 parseString(NetNameFilt "$"))
			NetNameCoup = nth(1 parseString(NetNameFilt "$")) 
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s \n", NetNameMain, NetNameCoup, nth(1 WidthMissMatchList_filt), nth(2 WidthMissMatchList_filt), nth(4 WidthMissMatchList_filt), nth(3 WidthMissMatchList_filt), nth(5 WidthMissMatchList_filt)) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n\n", "NOTE : SMA Pin Connected Net Ignored...")
		fprintf(port, "%s\n", "NO MISSMATCHING WIDTH DATA")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(FinalMainFiltList != nil then
		fprintf(port, "%s\n\n", "Coupon Board Net (Un Routed / Layer Changed) :")
		fprintf(port, "%-25s %-25s %-25s %-25s  %-25s\n\n", "NET NAME MAIN", "NET NAME COUPON", "LAYER", "WIDTH", "LENGTH")
		foreach(MainMisslp FinalMainFiltList
			MainMisslp_filt = parseString(MainMisslp ",")
			NNMM = nth(0 MainMisslp_filt)
			NNM1 = nth(0 parseString(NNMM "$"))
			NNC1 = nth(1 parseString(NNMM "$")) 
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", NNM1, NNC1, nth(1 MainMisslp_filt), nth(2 MainMisslp_filt), nth(3 MainMisslp_filt)) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO MISSING DATA IN COUPON BOARD")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(FinalCoupFiltList != nil then
		fprintf(port, "%s\n\n", "NOTE : SMA Pin Connected Net Ignored...")
		fprintf(port, "%s\n\n", "Main Board Net (Un Routed / Layer Changed) :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUPON", "LAYER", "WIDTH", "LENGTH")
		foreach(PINCOPMisslp FinalCoupFiltList
			COPMisslp_filt = parseString(PINCOPMisslp ",")
			NNCM = nth(0 COPMisslp_filt)
			NNM2 = nth(0 parseString(NNCM "$"))
			NNC2 = nth(1 parseString(NNCM "$")) 
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", NNM2, NNC2, nth(1 COPMisslp_filt), nth(2 COPMisslp_filt), nth(3 COPMisslp_filt)) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n\n", "NOTE : SMA Pin Connected Net Ignored...")
		fprintf(port, "%s\n", "NO MISSING DATA IN MAIN BOARD")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------")
	)
	
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Coupon Board Length", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Error Found...!")
)
)

