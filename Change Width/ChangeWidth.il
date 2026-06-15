axlCmdRegister("ChgWidthUI" 'ChgWidthUI)
(setq CHW_form_file "ChangeWidthFile.form") 
procedure(ChgWidthUI()
	CodeToRun = "DummyVar"
	lwidthpopup = list(list("0" "0"))
	etchparam = axlGetParam("paramLayerGroup:ETCH")
	Lyr_Names = etchparam->groupMembers
	CreateCHW_form()
	(CHW_form = axlFormCreate(gensym() CHW_form_file nil 'CHW_Action t))
	axlFormDisplay(CHW_form)
	axlFormBuildPopup(CHW_form "LYRDT" Lyr_Names)
	axlFormBuildPopup(CHW_form "WIDDT" lwidthpopup)
)

procedure(CreateCHW_form()
	let((CHW_form)
		(CHW_form = outfile(CHW_form_file "w")) 
		fprintf(CHW_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(CHW_form "FORM\n") 
		fprintf(CHW_form "FIXED\n") 
		fprintf(CHW_form "PORT 64 65\n") 
		fprintf(CHW_form "HEADER \"Change Width\"\n") 
		fprintf(CHW_form "\n")
		fprintf(CHW_form "TILE\n")
		
		fprintf(CHW_form "FIELD CNGWID\n") 
		fprintf(CHW_form "FLOC 22 1\n") 
		fprintf(CHW_form "MENUBUTTON \"CHANGE WIDTH\" 20 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD HIGWID\n") 
		fprintf(CHW_form "FLOC 2 5\n") 
		fprintf(CHW_form "MENUBUTTON \"HIGHLIGHT\" 20 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		
		fprintf(CHW_form "FIELD WIDREP\n") 
		fprintf(CHW_form "FLOC 22 5\n") 
		fprintf(CHW_form "MENUBUTTON \"REPORT\" 20 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD DEHIGWID\n") 
		fprintf(CHW_form "FLOC 42 5\n") 
		fprintf(CHW_form "MENUBUTTON \"DE-HIGHLIGHT\" 20 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "TEXT \" LAYERS >>\"\n")
		fprintf(CHW_form "TLOC 6 10\n")
		fprintf(CHW_form "ENDTEXT\n")
		
		fprintf(CHW_form "POPUP <LYR_LIST>\"\"\"\".\n")
		fprintf(CHW_form "FIELD LYRDT\n")
		fprintf(CHW_form "FLOC 16 10\n")
		fprintf(CHW_form "ENUMSET 10\n")
		fprintf(CHW_form "OPTIONS prettyprint ownerdrawn\n")
		fprintf(CHW_form "POP \"LYR_LIST\"\n")
		fprintf(CHW_form "ENDFIELD\n")
		
		fprintf(CHW_form "POPUP <WID_LIST>\"5\"\"5\",\"6\"\"6\".\n")
		fprintf(CHW_form "FIELD WIDDT\n")
		fprintf(CHW_form "FLOC 35 10\n")
		fprintf(CHW_form "ENUMSET 10\n")
		fprintf(CHW_form "OPTIONS prettyprint ownerdrawn\n")
		fprintf(CHW_form "POP \"WID_LIST\"\n")
		fprintf(CHW_form "ENDFIELD\n")
		
		fprintf(CHW_form "TEXT \" << CURRENT WIDTH\"\n")
		fprintf(CHW_form "TLOC 48 10\n")
		fprintf(CHW_form "ENDTEXT\n")
		
		
		fprintf(CHW_form "FIELD WVAL\n") 
		fprintf(CHW_form "FLOC 21 14\n") 
		fprintf(CHW_form "REALFILLIN 10 50\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "TEXT \"<< NEW WIDTH VALUE\"\n")
		fprintf(CHW_form "TLOC 34 14\n")
		fprintf(CHW_form "ENDTEXT\n")
		
		fprintf(CHW_form "FIELD GRPNAME\n") 
		fprintf(CHW_form "FLOC 2 17\n") 
		fprintf(CHW_form "MENUBUTTON \"BY-GROUP\" 8 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD BUSNAME\n") 
		fprintf(CHW_form "FLOC 13 17\n") 
		fprintf(CHW_form "MENUBUTTON \"BY-BUS\" 8 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD NETNAME\n") 
		fprintf(CHW_form "FLOC 22 17\n") 
		fprintf(CHW_form "MENUBUTTON \"BY-NET\" 8 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD LISTNAME\n") 
		fprintf(CHW_form "FLOC 31 17\n") 
		fprintf(CHW_form "MENUBUTTON \"BY-LIST\" 8 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD MANUAL\n") 
		fprintf(CHW_form "FLOC 40 17\n") 
		fprintf(CHW_form "MENUBUTTON \"BY-MANUAL\" 8 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD DEFAULT\n") 
		fprintf(CHW_form "FLOC 52 17\n") 
		fprintf(CHW_form "MENUBUTTON \"BY-DEFAULT\" 8 4\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD NETSTR\n") 
		fprintf(CHW_form "FLOC 19 21\n") 
		fprintf(CHW_form "STRFILLIN 18 50\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n") 
		
		fprintf(CHW_form "FIELD NETFILT\n") 
		fprintf(CHW_form "FLOC 39 21\n") 
		fprintf(CHW_form "MENUBUTTON \"<< Filter\" 5 3\n") 
		fprintf(CHW_form "ENDFIELD\n")
		fprintf(CHW_form "\n")
		
		fprintf(CHW_form "FIELD NetList_UI\n")
		fprintf(CHW_form "FLOC 13 25\n")
		fprintf(CHW_form "LIST \"\" 40 10\n")
		fprintf(CHW_form "OPTIONS multiselect 12 5\n")
		fprintf(CHW_form "ENDFIELD\n")


		fprintf(CHW_form "\n") 
		fprintf(CHW_form "\n") 
		fprintf(CHW_form "ENDTILE\n")
		
		fprintf(CHW_form "\n") 
		fprintf(CHW_form "ENDFORM\n")
		
		drain() 
		close(CHW_form)
	)
)

procedure(CHW_Action(CHW_form) 
	case((CHW_form->curField)

		("LYRDT"
			lwidthpopup = nil
			InpWidList = nil
			LyrNameUser = CHW_form->curValue
			axlFormSetField(CHW_form "WIDDT" "")
			axlVisibleDesign(nil)
			axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
			axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
			axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
			axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
			axlVisibleUpdate(t)
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
			ClineSegINP = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			foreach(ClineSegINPlp ClineSegINP
				CSegWidValstr = sprintf(nil "%.2f", ClineSegINPlp->width)
				when(CSegWidValstr push(CSegWidValstr InpWidList))
			)
			InpWidList = unique(InpWidList)
			if(InpWidList != nil then
				foreach(segw InpWidList
					lwidthpopup = append(lwidthpopup list(list(sprintf(w "%s" segw) sprintf(w "%s" segw))))
				)
				axlFormBuildPopup(CHW_form "WIDDT" lwidthpopup)
			else
				lwidthpopup = list(list("0" "0"))
				axlFormBuildPopup(CHW_form "WIDDT" lwidthpopup)
			)
		)
		

		("HIGWID"
			(OldWidVal = (axlFormGetField CHW_form "WIDDT"))	
			axlVisibleDesign(nil)
			axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
			axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
			axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
			axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
			axlVisibleUpdate(t)
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
			ClineSegINPS = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			foreach(ClineSegINPSlp ClineSegINPS
				CSegWidValstrS = sprintf(nil "%.2f", ClineSegINPSlp->width)
				if(CSegWidValstrS == OldWidVal then
					axlHighlightObject(ClineSegINPSlp)
				)
			)
		)
		
		("WIDREP"
			(OldWidVal = (axlFormGetField CHW_form "WIDDT"))
			RepList = nil
			axlVisibleDesign(nil)
			axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
			axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
			axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
			axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
			axlVisibleUpdate(t)
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
			ClineSegINPS = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			foreach(ClineSegINPSlp ClineSegINPS
				CSegWidValstrS = sprintf(nil "%.2f", ClineSegINPSlp->width)
				if(CSegWidValstrS == OldWidVal then
					ListOutput = sprintf(nil, "%s,%s,%s,(%.1f %.1f)(%.1f %.1f)" ClineSegINPSlp ->net ->name, ClineSegINPSlp ->layer, CSegWidValstrS, xCoord(car(ClineSegINPSlp->startEnd)), yCoord(car(ClineSegINPSlp->startEnd)), xCoord(cadr(ClineSegINPSlp->startEnd)), yCoord(cadr(ClineSegINPSlp->startEnd)))
					when(ListOutput push(ListOutput RepList))
				)
			)
			NetListOPUnq = nil
			NetListOPUnq = unique(RepList)
			if(NetListOPUnq == nil then
				axlUIConfirm("No Values Found...")
			else
			logfile = "WidthRep.log"
			originalVisible=axlVisibleGet()
			designName = axlCurrentDesign()
			design_path = axlGetDrawingName()
			design_unit = car(axlDBGetDesignUnits())
			axlVisibleDesign(t)
			timeperform = fileTimeModified("WidthRep.log")
			port = axlDMOpenLog(logfile)
			fprintf(port, "Design name: %s\n", design_path)
			fprintf(port, "%s\n", "------------------------------------------------")
			fprintf(port, "%-28s %-28s %-28s %-28s \n\n", "NET NAME", "LAYER", "WIDTH", "XY Location")
			
			foreach(NetListOPUnqlp NetListOPUnq
				PrseOutput = parseString(NetListOPUnqlp ",")
				fprintf(port, "%-28s %-28s %-28s %-28s \n",nth(0 PrseOutput),nth(1 PrseOutput),nth(2 PrseOutput),nth(3 PrseOutput))
			)
			axlDMClose(port)
			axlVisibleSet(originalVisible)
			axlUIViewFileCreate(logfile, "Check Width Report", nil, '(30 25), '(CENTER))
			)
		)
		
		("DEHIGWID"
			axlVisibleDesign(nil)
			axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
			axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
			axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
			axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
			axlVisibleUpdate(t)
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
			ClineSegINPS = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			foreach(ClineSegINPSlp ClineSegINPS
				axlDehighlightObject(ClineSegINPSlp)
			)
		)
		 
		("GRPNAME"
			CodeToRun = "GRPNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			NetList_All_UI = nil
			foreach(Netlist_All axlDBGetDesign() ->groups
				Netlist_name = upperCase(Netlist_All->name)
				when(Netlist_name push(Netlist_name NetList_All_UI))
			)
			axlFormSetField(CHW_form "NetList_UI" NetList_All_UI) 
			foreach(NetList_All_loop NetList_All_UI 
				axlFormListSelect(CHW_form "NetList_UI" NetList_All_loop)
			)
			
		)
		
		("BUSNAME"
			CodeToRun = "BUSNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			NetList_All_UI = nil
			foreach(Netlist_All axlDBGetDesign() ->bus
				Netlist_name = upperCase(Netlist_All->name)
				when(Netlist_name push(Netlist_name NetList_All_UI))
			)
			axlFormSetField(CHW_form "NetList_UI" NetList_All_UI) 
			foreach(NetList_All_loop NetList_All_UI 
				axlFormListSelect(CHW_form "NetList_UI" NetList_All_loop)
			)
			
		)
		
		("NETNAME"
			CodeToRun = "LISTNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			NetList_NET_UI = nil
			foreach(Netlist_All axlDBGetDesign() ->nets
				Netlist_name = upperCase(Netlist_All->name) 
				when(Netlist_name push(Netlist_name NetList_NET_UI))
			)
			NetList_NET_UI_sort = copy(NetList_NET_UI)
			NetList_NET_UI_sort = sort(NetList_NET_UI_sort 'alphalessp)
			axlFormSetField(CHW_form "NetList_UI" NetList_NET_UI_sort) 
			foreach(NetList_Net_loop NetList_NET_UI_sort 
				axlFormListSelect(CHW_form "NetList_UI" NetList_Net_loop)
			)
			
		)
		
		("LISTNAME"
			CodeToRun = "LISTNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			NetList_Inp = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
				fileparts = axlDMFileParts(NetList_Inp)
				NetList_Inp_Pass = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts) "r")
				NetList_List_UI = nil
					if(NetList_Inp_Pass != nil then
						while(gets(NetList_Inp_loop NetList_Inp_Pass)
							NetList_Inp_loop_prse = upperCase(car(parseString(NetList_Inp_loop "\n")))
							when(NetList_Inp_loop_prse push(NetList_Inp_loop_prse NetList_List_UI))
						)
						axlDMClose(NetList_Inp_Pass)
					
						
				axlFormSetField(CHW_form "NetList_UI" NetList_List_UI) 
					foreach(NetList_List_loop NetList_List_UI 
						axlFormListSelect(CHW_form "NetList_UI" NetList_List_loop)
					)
				)
				
		)
		
		("MANUAL"
			axlVisibleUpdate(t)
			CodeToRun = "LISTNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			NetList_Inp_UI = nil
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
			ClineINP = axlGetSelSet(axlSelect( ))
			axlClearSelSet()
			foreach(ClineINPlp ClineINP
				ClineINPNN = upperCase(ClineINPlp->net->name)
				when(ClineINPNN push(ClineINPNN NetList_Inp_UI))
			)
			NetList_Inp_UI = unique(NetList_Inp_UI)
			axlFormSetField(CHW_form "NetList_UI" NetList_Inp_UI) 
					foreach(NetList_Inp_UIloop NetList_Inp_UI 
						axlFormListSelect(CHW_form "NetList_UI" NetList_Inp_UIloop)
					)
		)
		
		("DEFAULT"
			CodeToRun = "LISTNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			NetList_NET_UI = nil
			foreach(Netlist_All axlDBGetDesign() ->nets
				Netlist_name = upperCase(Netlist_All->name) 
				when(Netlist_name push(Netlist_name NetList_NET_UI))
			)
			NetList_NET_UI_sort = copy(NetList_NET_UI)
			NetList_NET_UI_sort = sort(NetList_NET_UI_sort 'alphalessp)
			axlFormSetField(CHW_form "NetList_UI" NetList_NET_UI_sort) 
			foreach(NetList_Net_loop NetList_NET_UI_sort 
				axlFormListSelect(CHW_form "NetList_UI" NetList_Net_loop)
			)
		)
		
		("NETFILT"
			CodeToRun = "LISTNET"
			axlFormListDeleteAll(CHW_form "NetList_UI")
			(Single_net_filt = (axlFormGetField CHW_form "NETSTR"))
			Single_net_filt = upperCase(Single_net_filt)		
			NetList_filt_UI = nil
			foreach(Netlist_All_filt axlDBGetDesign() ->nets
				Netlist_name_filt = Netlist_All_filt->name 				
				pcre_filt = pcreCompile(Single_net_filt)
				when(pcreExecute(pcre_filt Netlist_name_filt)
					for(i 0 250
						val = sprintf(nil "%d", i)
						pcre1 = pcreCompile("[*]")
						Single_net_filtVal = pcreReplace(pcre1 Single_net_filt val 1)
						if(Single_net_filtVal == Netlist_name_filt then
							when(Netlist_name_filt push(Netlist_name_filt NetList_filt_UI))
						)
					)
				)
			)
			NetList_filt_UI = reverse(NetList_filt_UI)
			axlFormSetField(CHW_form "NetList_UI" NetList_filt_UI) 
			foreach(NetList_filt_loop NetList_filt_UI 
				axlFormListSelect(CHW_form "NetList_UI" NetList_filt_loop)
			)
			
		)
		
		("CNGWID"
			(LyrName = (axlFormGetField CHW_form "LYRDT"))	
			(OldWidVal = (axlFormGetField CHW_form "WIDDT"))	
			(NewWidVal = (axlFormGetField CHW_form "WVAL"))
			NewWidValStr = sprintf(nil "%.2f", NewWidVal)			
			NewWid = atof(NewWidValStr)
			if(CodeToRun == "LISTNET" then
				Sel_Net_list = axlFormListGetSelItems(CHW_form "NetList_UI")
				axlFormSetField(CHW_form "NetList_SelName" Sel_Net_list) 
				;INPNetID = axlSelectByName("NET", Sel_Net_list)
				if(Sel_Net_list != nil then
					axlVisibleDesign(nil)
					axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
					;axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
					;axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
					;axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
					axlVisibleUpdate(t)
					axlClearSelSet()
					axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
					ClineSegINP = axlGetSelSet(axlAddSelectAll())
					axlClearSelSet()
					foreach(ClineSegINPlp ClineSegINP
						CSegNetName = ClineSegINPlp->net->name
						foreach(INPNetIDlp Sel_Net_list
							;INPNetNAme = INPNetIDlp->net->name
							if(INPNetIDlp == CSegNetName then
								foreach(CSeglp ClineSegINPlp ->segments
									CSegWidValstr = CSeglp->width
									CSegLyrValstr = CSeglp->layer
									CSegLyrValstrprse = nth(1 parseString(CSegLyrValstr "/"))
									CSegWidVal = sprintf(nil "%.2f", CSegWidValstr) 
									if(CSegWidVal == OldWidVal && CSegLyrValstrprse == LyrName then
										axlChangeWidth(CSeglp, NewWid)
									)
								)
							)
						)
					)
					axlUIConfirm( "New Width Updated..." )
				else
					axlUIConfirm( "Input Is Empty Or Not Selected please check..." )
				)
			else
				if(CodeToRun = "GRPNET" then
					GrpNetNameList = nil
					Sel_Net_list = axlFormListGetSelItems(CHW_form "NetList_UI")
					axlFormSetField(CHW_form "NetList_SelName" Sel_Net_list) 
					foreach(Sel_Net_listloop Sel_Net_list
						foreach(NetInpData	axlDBGetDesign() ->groups
							if(NetInpData ->name == Sel_Net_listloop then
								GrpData = NetInpData->groupMembers
								foreach(GrpDatalp GrpData
									NetNameBus = sprintf(nil "%s" GrpDatalp->name)
									when(NetNameBus push(NetNameBus GrpNetNameList))
								)
							)							
						)
					)
					GrpNetNameListUnq = unique(GrpNetNameList)
					;GrpINPNetID = axlSelectByName("NET", GrpNetNameListUnq)
					if(GrpNetNameListUnq != nil then
					axlVisibleDesign(nil)
					axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
					;axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
					;axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
					;axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
					axlVisibleUpdate(t)
					axlClearSelSet()
					axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
					ClineSegINP = axlGetSelSet(axlAddSelectAll())
					axlClearSelSet()
					foreach(ClineSegINPlp ClineSegINP
						CSegNetName = ClineSegINPlp->net->name
						foreach(GrpINPNetIDlp GrpNetNameListUnq
							if(GrpINPNetIDlp == CSegNetName then
								foreach(CsegGrplp ClineSegINPlp ->segments 
									CSegWidValstr = CsegGrplp->width
									CSegLyrValstr = CsegGrplp->layer
									CSegLyrValstrprse = nth(1 parseString(CSegLyrValstr "/"))
									CSegWidVal = sprintf(nil "%.2f", CSegWidValstr) 
									if(CSegWidVal == OldWidVal && CSegLyrValstrprse == LyrName then
										axlChangeWidth(CsegGrplp, NewWid)
									)
								)
							)
							)
						)
						axlUIConfirm( "New Width Updated..." )
					else
						axlUIConfirm( "Input Is Empty Or Not Selected please check..." )
					)
				else
					if(CodeToRun = "BUSNET" then
						BusNetNameList = nil
						Sel_Net_list = axlFormListGetSelItems(CW_form "NetList_UI")
						axlFormSetField(CW_form "NetList_SelName" Sel_Net_list) 
						foreach(Sel_Net_listloop Sel_Net_list
								foreach(NetInpData	axlDBGetDesign() ->nets
									if(NetInpData->bus->name == Sel_Net_listloop then
										NetNameBus = sprintf(nil "%s" NetInpData->net->name)
										when(NetNameBus push(NetNameBus BusNetNameList))	
									)							
								)
							)
							;INPNetID = axlSelectByName("NET", BusNetNameList)
							if(INPNetID != nil then
								axlVisibleDesign(nil)
								axlVisibleLayer(strcat("ETCH/" LyrNameUser) t)
								;axlVisibleLayer(strcat("PIN/" LyrNameUser) t)
								;axlVisibleLayer(strcat("VIA CLASS/" LyrNameUser) t)
								;axlVisibleLayer(strcat("DRC ERROR CLASS/" LyrNameUser) t)
								axlVisibleUpdate(t)
								axlClearSelSet()
								axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
								ClineSegINP = axlGetSelSet(axlAddSelectAll())
								axlClearSelSet()
								foreach(ClineSegINPlp ClineSegINP
									CSegNetName = ClineSegINPlp->net->name 
									foreach(INPNetIDlp BusNetNameList
										;INPNetNAme = INPNetIDlp->net->name
										if(INPNetIDlp == CSegNetName then
											foreach(CsegBuslp ClineSegINPlp->segments 
												CSegWidValstr = CsegBuslp->width
												CSegLyrValstr = CsegBuslp->layer
												CSegLyrValstrprse = nth(1 parseString(CSegLyrValstr "/"))
												CSegWidVal = sprintf(nil "%.2f", CSegWidValstr)
												if(CSegWidVal == OldWidVal && CSegLyrValstrprse == LyrName then
													axlChangeWidth(CsegBuslp, NewWid)										
												)
											)
										)
									)
								)
							)
							axlUIConfirm( "New Width Updated..." )
						else
							axlUIConfirm( "Input Is Empty Or Not Selected please check..." )
						)
				)
			)
		)
		)
	axlFormDisplay(CHW_form)
)


