axlCmdRegister("DecapsUI" 'DecapsUI)
(setq DC_form_file "DeCaps.form") 
procedure(DecapsUI()
	CreateDC_form()
	RunDC_form()
)

procedure(RunDC_form() 
	let((DC_form colorList)
		(DC_form = axlFormCreate(gensym() DC_form_file nil 'DC_Action t)) 
			CusVal = 100
			colorList = '("YES" "NO")
			axlFormBuildPopup(DC_form "COLOR_LIST" colorList)
		axlFormDisplay(DC_form)
	)
)


procedure(CreateDC_form()
	let((DC_form)
		(DC_form = outfile(DC_form_file "w")) 
		fprintf(DC_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(DC_form "FORM\n") 
		fprintf(DC_form "FIXED\n") 
		fprintf(DC_form "PORT 120 150\n") 
		fprintf(DC_form "HEADER \"DeCaps\"\n") 
		fprintf(DC_form "\n")
		fprintf(DC_form "TILE\n")
		
		fprintf(DC_form "FIELD DeCap\n") 
		fprintf(DC_form "FLOC 2 1\n") 
		fprintf(DC_form "MENUBUTTON \"RUN\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
		
		fprintf(DC_form "FIELD DeCapDeClr\n") 
		fprintf(DC_form "FLOC 14 1\n") 
		fprintf(DC_form "MENUBUTTON \"DEHIGHLIGHT\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
		
		fprintf(DC_form "FIELD DeCapDeClrgray\n") 
		fprintf(DC_form "FLOC 14 5\n") 
		fprintf(DC_form "MENUBUTTON \"GRAYCOLOUR\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
			
		fprintf(DC_form "FIELD DeCapClrAutoALL\n") 
		fprintf(DC_form "FLOC 32 1\n") 
		fprintf(DC_form "MENUBUTTON \"AUTO(ALL)\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		fprintf(DC_form "FIELD DeCapClrAutoSEL\n") 
		fprintf(DC_form "FLOC 44 1\n") 
		fprintf(DC_form "MENUBUTTON \"AUTO(SEL)\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		fprintf(DC_form "FIELD DeCapClrAutoALLCAP\n") 
		fprintf(DC_form "FLOC 56 1\n") 
		fprintf(DC_form "MENUBUTTON \"CAP(ALL)\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		fprintf(DC_form "FIELD DeCapClrAutoSELCAP\n") 
		fprintf(DC_form "FLOC 68 1\n") 
		fprintf(DC_form "MENUBUTTON \"CAP(SEL)\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		fprintf(DC_form "FIELD DeCapClr\n") 
		fprintf(DC_form "FLOC 80 1\n") 
		fprintf(DC_form "MENUBUTTON \"SELECTED\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
		
		fprintf(DC_form "FIELD DeCapRep\n") 
		fprintf(DC_form "FLOC 92 1\n") 
		fprintf(DC_form "MENUBUTTON \"CAP(REP)\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		fprintf(DC_form "FIELD DeCapRepSel\n") 
		fprintf(DC_form "FLOC 104 1\n") 
		fprintf(DC_form "MENUBUTTON \"CAP(REP-SEL)\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		;fprintf(DC_form "FIELD color_box\n") 
		;fprintf(DC_form "FLOC 20 1\n") 
		;fprintf(DC_form "COLOR 2 1\n") 
		;fprintf(DC_form "ENDFIELD\n")
		;fprintf(DC_form "\n") 
	
		fprintf(DC_form "GROUP \"DeCaps Net Selection\"\n")
        fprintf(DC_form "GLOC 2 8\n")
        fprintf(DC_form "GSIZE 31 26\n")
        fprintf(DC_form "ENDGROUP\n")
        fprintf(DC_form "\n")
		
		fprintf(DC_form "FIELD DeCap_All\n") 
		fprintf(DC_form "FLOC 6 10\n") 
		fprintf(DC_form "MENUBUTTON \"All NET\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
		
		fprintf(DC_form "FIELD DeCap_List\n") 
		fprintf(DC_form "FLOC 19 10\n") 
		fprintf(DC_form "MENUBUTTON \"LIST NET\" 10 4\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
		
		;fprintf(DC_form "FIELD DeCap_Bus\n") 
		;fprintf(DC_form "FLOC 27 10\n") 
		;fprintf(DC_form "MENUBUTTON \"BUS NET\" 10 4\n") 
		;fprintf(DC_form "ENDFIELD\n")
		;fprintf(DC_form "\n") 
		
		fprintf(DC_form "FIELD DeCap_Net_Filt\n") 
		fprintf(DC_form "FLOC 5 14\n") 
		fprintf(DC_form "STRFILLIN 18 50\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n") 
		
		fprintf(DC_form "FIELD DeCap_Net_Filt_but\n") 
		fprintf(DC_form "FLOC 25 14\n") 
		fprintf(DC_form "MENUBUTTON \">>Filter\" 5 3\n") 
		fprintf(DC_form "ENDFIELD\n")
		fprintf(DC_form "\n")
		
		
		fprintf(DC_form "FIELD NetList_UI\n")
		fprintf(DC_form "FLOC 5 18\n")
		fprintf(DC_form "LIST \"\" 25 8\n")
		fprintf(DC_form "OPTIONS multiselect prettyprint 12 5\n")
		fprintf(DC_form "ENDFIELD\n")
		
		fprintf(DC_form "GROUP \"DeCaps Colouring\"\n")
        fprintf(DC_form "GLOC 35 8\n")
        fprintf(DC_form "GSIZE 85 26\n")
        fprintf(DC_form "ENDGROUP\n")
        fprintf(DC_form "\n")
				
		fprintf(DC_form "GRID gridtable\n")
		fprintf(DC_form "FLOC 38 12\n") 	
		fprintf(DC_form "FSIZE 80 20\n") 	
		fprintf(DC_form "OPTIONS HLINES VLINES USERSIZE\n")
		fprintf(DC_form "ENDGRID\n")
		
		fprintf(DC_form "FIELD \"CBOX\"\n")
		fprintf(DC_form "FLOC 40 5 \n")
		fprintf(DC_form "CHECKLIST \"SORT BY CAP VAL\" \n")
		fprintf(DC_form "ENDFIELD\n")
		
		fprintf(DC_form "POPUP <colorList>\"Yes\"\"Yes\",\"No\"\"No\".\n")
		fprintf(DC_form "FIELD COLOR_LIST\n")
		fprintf(DC_form "FLOC 115 5\n")
		fprintf(DC_form "ENUMSET 3\n")
		;fprintf(DC_form "OPTIONS prettyprint ownerdrawn\n")
		fprintf(DC_form "POP \"colorList\"\n")
		fprintf(DC_form "ENDFIELD\n")

		fprintf(DC_form "\n") 
		fprintf(DC_form "\n") 
		fprintf(DC_form "ENDTILE\n")
		
		fprintf(DC_form "\n") 
		fprintf(DC_form "ENDFORM\n")
		
		drain() 
		close(DC_form)
	)
)

procedure(DC_Action(DC_form) 
	case((DC_form->curField)
		
		("CBOX"
			CboxVal = DC_form->curValue
			if(CboxVal then
				Sel_Net_list = axlFormListGetSelItems(DC_form "NetList_UI")
				axlFormSetField(DC_form "NetList_SelName" Sel_Net_list) 
				NetVal_List = nil
				NetVal_List_Val = nil
				foreach(Sel_Net_list_name Sel_Net_list
					foreach(cmp setof(comps axlDBGetDesign() ->components comps->symbol)
						foreach(pin_data cmp ->pins
							if(Sel_Net_list_name == pin_data->net->name then
								Net_Val = sprintf(nil "%s", cmp->compdef->deviceType)
								Net_Val_Sort = sprintf(nil "%s", cmp->compdef->prop->VALUE) 
								Ref_Filt_3 = sprintf(nil "%s", cmp->name)
								Ref_Filt_Sub_3 = substring(Ref_Filt_3 1 1)
								if(Ref_Filt_Sub_3 == "C" || Ref_Filt_Sub_3 == "c" then
									Net_val_str = sprintf(out, "%s,%s,%s", Sel_Net_list_name, Net_Val, Net_Val_Sort)
									when(Net_val_str push(Net_val_str NetVal_List))
									when(Net_Val_Sort push(Net_Val_Sort NetVal_List_Val))
										;fprintf(out, "%s,%s\n", Sel_Net_list_name, Net_Val)
								)
							)
						)
					)
				)
				NetVal_List_unq_OLD = nil
				NetVal_List_unq_OLD = unique(NetVal_List)
				;println(NetVal_List_unq)
				
				NetVal_List_Val_unq = nil
				NetVal_List_Val_unq = unique(NetVal_List_Val)
				NetVal_List_Val_unq = sort(NetVal_List_Val_unq 'alphalessp)
				;println(NetVal_List_Val_unq)
				
				NetVal_List_u = nil
				foreach(NetVal_List_Val_unqlp NetVal_List_Val_unq
					foreach(NetVal_List_unqlp NetVal_List_unq_OLD
						NetVal_List_unqPrse1 = nth(0 parseString(NetVal_List_unqlp ","))
						NetVal_List_unqPrse2 = nth(1 parseString(NetVal_List_unqlp ","))
						NetVal_List_unqPrse3 = nth(2 parseString(NetVal_List_unqlp ","))
						if(NetVal_List_Val_unqlp == NetVal_List_unqPrse3 then
							NetVal_List_unqPrse = sprintf(nil "%s,%s", NetVal_List_unqPrse1, NetVal_List_unqPrse2)
							when(NetVal_List_unqPrse push(NetVal_List_unqPrse NetVal_List_u))
						)						
					)
				)
				NetVal_List_unq = nil
				NetVal_List_unq = unique(NetVal_List_u)
				NetVal_List_unq = reverse(NetVal_List_unq)
		
				DC_ColCreater()
				axlFormGridInsertRows(DC_form "gridtable" 0 200)
				axlFormGridSetBatch(DC_form "gridtable" 'DC_Inster_Val_Row nil)
				axlFormGridUpdate(DC_form "gridtable")
			else
				Sel_Net_list = axlFormListGetSelItems(DC_form "NetList_UI")
			axlFormSetField(DC_form "NetList_SelName" Sel_Net_list) 
			
			;out = outfile("valfile.csv")
			NetVal_List = nil
			foreach(Sel_Net_list_name Sel_Net_list
				foreach(cmp setof(comps axlDBGetDesign() ->components comps->symbol)
					foreach(pin_data cmp ->pins
						if(Sel_Net_list_name == pin_data->net->name then
							Net_Val = sprintf(nil "%s", cmp->compdef->deviceType)
							Ref_Filt_3 = sprintf(nil "%s", cmp->name)
							Ref_Filt_Sub_3 = substring(Ref_Filt_3 1 1)
							if(Ref_Filt_Sub_3 == "C" || Ref_Filt_Sub_3 == "c" then
								Net_val_str = sprintf(out, "%s,%s", Sel_Net_list_name, Net_Val)
								when(Net_val_str push(Net_val_str NetVal_List))
								;fprintf(out, "%s,%s\n", Sel_Net_list_name, Net_Val)
							)
						)
					)
				)
			)
			;close(out)
			NetVal_List_unq = nil
			NetVal_List_unq = unique(NetVal_List)
			NetVal_List_unq = sort(NetVal_List_unq 'alphalessp)	
			DC_ColCreater()
			axlFormGridInsertRows(DC_form "gridtable" 0 200)
			axlFormGridSetBatch(DC_form "gridtable" 'DC_Inster_Val_Row nil)
			axlFormGridUpdate(DC_form "gridtable")
			)
		)
		
		("gridtable"
			axlFormGridSetBatch(DC_form "gridtable" 'DC_FormCapClr nil)
			axlFormGridUpdate(DC_form "gridtable")
		)
		;("color_box"
			;print("yes")
			;axlUIColorDialog(nil nil)
		;)
		
		("COLOR_LIST"
			name = DC_form->curValue
			;print(name)
			axlFormSetField(TemChkform "CHK" "")
			;formupdate()
		)
		
		("DeCapClrAutoALLCAP"
			CAP_clr = nil
			foreach(cmpCAPAuto setof(compsCAPAuto axlDBGetDesign() ->components compsCAPAuto->symbol)
				foreach(pin_data_cmpCAPAuto cmpCAPAuto ->pins
					Net_Val_CAPAuto = sprintf(nil "%s", cmpCAPAuto->compdef->deviceType)
					Ref_Filt = sprintf(nil "%s", cmpCAPAuto->name)
					Ref_Filt_Sub = substring(Ref_Filt 1 1)
					if(Ref_Filt_Sub == "C" || Ref_Filt_Sub == "c" then
						Net_val_str_CAPauto = sprintf(out, "%s", Net_Val_CAPAuto)
						when(Net_val_str_CAPauto push(Net_val_str_CAPauto CAP_clr))
					)
				)
			)
		CAP_clr_unq = nil
		CAP_clr_unq = unique(CAP_clr)
		
		CAP_clr_val = 1
		CAP_clr_updt = nil
		
		foreach(CAP_clr_unq_loop CAP_clr_unq
			if(CAP_clr_val == 4 || CAP_clr_val == 8 || CAP_clr_val == 17 || CAP_clr_val == 34 || CAP_clr_val == 50 || CAP_clr_val == 55 || CAP_clr_val == 66 || CAP_clr_val == 71 || CAP_clr_val == 87 || CAP_clr_val == 101 || CAP_clr_val == 149 || CAP_clr_val == 165 || CAP_clr_val == 181 then
				CAP_clr_val++
				CAP_update_clr = sprintf(nil "%s,%d", CAP_clr_unq_loop, CAP_clr_val)
				when(CAP_update_clr push(CAP_update_clr CAP_clr_updt))
				CAP_clr_val++
			else
				CAP_update_clr = sprintf(nil "%s,%d", CAP_clr_unq_loop, CAP_clr_val)
				when(CAP_update_clr push(CAP_update_clr CAP_clr_updt))
				CAP_clr_val++
			)

		)
		foreach(CAPAutoClr setof(CAPAutocmp axlDBGetDesign() ->components CAPAutocmp->symbol)
			CAPAutoClr_Cap_Val = sprintf(nil "%s", CAPAutoClr->compdef->deviceType)
			foreach(CAP_clr_updt_loop CAP_clr_updt
				CAP_clr_updt_CAPVAL = nth(0 parseString(CAP_clr_updt_loop ",")) 
				CAP_clr_updt_CLR = nth(1 parseString(CAP_clr_updt_loop ",")) 
					if(CAP_clr_updt_CAPVAL == CAPAutoClr_Cap_Val then
						CAP_clr_updt_CLR_intg = atof(CAP_clr_updt_CLR)
						CAP_clr_updt_CLR_rd = round(CAP_clr_updt_CLR_intg)
						axlCustomColorObject(CAPAutoClr, CAP_clr_updt_CLR_rd)
					)	
			)	
		)
		axlUIConfirm( "Auto Colour CAP Wise has been updated Successfully...!" )	
			
		)
		("DeCapDeClrgray"
			CAP_clr = nil
			foreach(cmpCAPAuto setof(compsCAPAuto axlDBGetDesign() ->components compsCAPAuto->symbol)
				foreach(pin_data_cmpCAPAuto cmpCAPAuto ->pins
					Net_Val_CAPAuto = sprintf(nil "%s", cmpCAPAuto->compdef->deviceType)
						Ref_Filt_1 = sprintf(nil "%s", cmpCAPAuto->name)
						Ref_Filt_Sub_1 = substring(Ref_Filt_1 1 1)
						if(Ref_Filt_Sub_1 == "C" || Ref_Filt_Sub_1 == "c" then
							Net_val_str_CAPauto = sprintf(out, "%s", Net_Val_CAPAuto)
							when(Net_val_str_CAPauto push(Net_val_str_CAPauto CAP_clr))
						)
				)
			)
		CAP_clr_unq = nil
		CAP_clr_unq = unique(CAP_clr)
		
		CAP_clr_val = 8
		CAP_clr_updt = nil
		
		foreach(CAP_clr_unq_loop CAP_clr_unq
			CAP_update_clr = sprintf(nil "%s,%d", CAP_clr_unq_loop, CAP_clr_val)
			when(CAP_update_clr push(CAP_update_clr CAP_clr_updt))
		)
		foreach(CAPAutoClr setof(CAPAutocmp axlDBGetDesign() ->components CAPAutocmp->symbol)
			CAPAutoClr_Cap_Val = sprintf(nil "%s", CAPAutoClr->compdef->deviceType)
			foreach(CAP_clr_updt_loop CAP_clr_updt
				CAP_clr_updt_CAPVAL = nth(0 parseString(CAP_clr_updt_loop ",")) 
				CAP_clr_updt_CLR = nth(1 parseString(CAP_clr_updt_loop ",")) 
					if(CAP_clr_updt_CAPVAL == CAPAutoClr_Cap_Val then
						CAP_clr_updt_CLR_intg = atof(CAP_clr_updt_CLR)
						CAP_clr_updt_CLR_rd = round(CAP_clr_updt_CLR_intg)
						axlCustomColorObject(CAPAutoClr, CAP_clr_updt_CLR_rd)
					)	
			)	
		)
		axlUIConfirm( "Gray Color has been updated Successfully...!" )
			
		)
		
		("DeCapRepSel"
			DC_Rep_Sel()
		)
		
		("DeCapDeClr"
			axlClearObjectCustomColor(axlDBGetDesign() ->symbols)
			axlUIConfirm( "Dehighlighted Successfully...!" )
		)
		
		("DeCap_Net_Filt_but"
			axlFormListDeleteAll(DC_form "NetList_UI")
			(Single_net_filt = (axlFormGetField DC_form "DeCap_Net_Filt"))		
			NetList_filt_UI = nil
			foreach(Netlist_All_filt axlDBGetDesign() ->nets
				Netlist_name_filt = Netlist_All_filt->name 				
				pcre_filt = pcreCompile(Single_net_filt)
				when(pcreExecute(pcre_filt Netlist_name_filt)
					if(strlen(Single_net_filt) == strlen(Netlist_name_filt) then
						when(Netlist_name_filt push(Netlist_name_filt NetList_filt_UI))
					)
				)
			)
			axlFormSetField(DC_form "NetList_UI" NetList_filt_UI) 
			foreach(NetList_filt_loop NetList_filt_UI 
				axlFormListSelect(DC_form "NetList_UI" NetList_filt_loop)
			)
			
		)
		("DeCapClrAutoALL"
			Auto_clr = nil 
			foreach(cmpAuto setof(compsAuto axlDBGetDesign() ->components compsAuto->symbol)
				foreach(pin_data_cmpAuto cmpAuto ->pins
					Net_Val_Auto = sprintf(nil "%s", cmpAuto->compdef->deviceType)
						Ref_Filt_2 = sprintf(nil "%s", cmpAuto->name)
						Ref_Filt_Sub_2 = substring(Ref_Filt_2 1 1)
						if(Ref_Filt_Sub_2 == "C" || Ref_Filt_Sub_2 == "c" then
							Net_val_str_auto = sprintf(out, "%s,%s", pin_data_cmpAuto->net->name, Net_Val_Auto)
							when(Net_val_str_auto push(Net_val_str_auto Auto_clr))
						)
					)
				)
				Auto_clr_unq = nil
				Auto_clr_unq = unique(Auto_clr)
				
				clr_auto = 1
				clr_updated_list = nil
				foreach(Auto_clr_unq_loop Auto_clr_unq
					if(clr_auto == 4 || clr_auto == 8 || clr_auto == 17 || clr_auto == 34 || clr_auto == 50 || clr_auto == 55 || clr_auto == 66 || clr_auto == 71 || clr_auto == 87 || clr_auto == 101 || clr_auto == 149 || clr_auto == 165 || clr_auto == 181 then
						clr_auto++
						clr_update_auto = sprintf(out, "%s,%d", Auto_clr_unq_loop, clr_auto) 
						when(clr_update_auto push(clr_update_auto clr_updated_list))
						clr_auto++
					else
						clr_update_auto = sprintf(out, "%s,%d", Auto_clr_unq_loop, clr_auto) 
						when(clr_update_auto push(clr_update_auto clr_updated_list))
						clr_auto++
					)

				)
				
				foreach(AutoSel_updt setof(compsAutoSel_updt axlDBGetDesign() ->components compsAutoSel_updt->symbol)
					foreach(AutoSel_updt_pin AutoSel_updt ->pins
						AutoSel_updt_net_name = AutoSel_updt_pin->net->name 
						AutoSel_updt_Cap_Val = sprintf(nil "%s", AutoSel_updt->compdef->deviceType)
							foreach(NetVal_List_unq_AutoSel_updt clr_updated_list
								AutoSel_updt_inp_Net_name = nth(0 parseString(NetVal_List_unq_AutoSel_updt ","))
								AutoSel_updt_inp_Cap = nth(1 parseString(NetVal_List_unq_AutoSel_updt ","))
								AutoSel_updt_inp_Clr = nth(2 parseString(NetVal_List_unq_AutoSel_updt ","))
									if(AutoSel_updt_inp_Net_name == AutoSel_updt_net_name then
										if(AutoSel_updt_Cap_Val == AutoSel_updt_inp_Cap then
											clr_val_auto = atof(AutoSel_updt_inp_Clr)
											clr_val_auto_round = round(clr_val_auto)
											axlCustomColorObject(AutoSel_updt, clr_val_auto_round)
										)
									)
							)
					)
				)
			axlUIConfirm( "Auto Colour has been updated Successfully...!" )	
				
		)
		("DeCap_All"
			;axlFormClose(DC_form)	
			;shell("rm -f DeCaps.form")
			;nil	
			;DecapsUI()
			axlFormListDeleteAll(DC_form "NetList_UI")
			NetList_All_UI = nil
			foreach(Netlist_All axlDBGetDesign() ->nets
				Netlist_name = Netlist_All->name 
				when(Netlist_name push(Netlist_name NetList_All_UI))
			)
			NetList_All_UI_sort = copy(NetList_All_UI)
			NetList_All_UI_sort = sort(NetList_All_UI_sort 'alphalessp)
			axlFormSetField(DC_form "NetList_UI" NetList_All_UI_sort) 
			foreach(NetList_All_loop NetList_All_UI_sort 
				axlFormListSelect(DC_form "NetList_UI" NetList_All_loop)
			)
		)
		
		("DeCap_List"
			axlFormListDeleteAll(DC_form "NetList_UI")
			NetList_Inp = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
				fileparts = axlDMFileParts(NetList_Inp)
				NetList_Inp_Pass = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts) "r")
				NetList_List_UI = nil
					if(NetList_Inp_Pass != nil then
						while(gets(NetList_Inp_loop NetList_Inp_Pass)
							NetList_Inp_loop_prse = car(parseString(NetList_Inp_loop "\n"))
							when(NetList_Inp_loop_prse push(NetList_Inp_loop_prse NetList_List_UI))
						)
						axlDMClose(NetList_Inp_Pass)											
				NetList_List_UI_Star_List = nil
				foreach(NetList_List_UI_star NetList_List_UI
					foreach(NetList_List_UI_star_inp axlDBGetDesign() ->nets
						NetList_List_UI_star_inp_name = NetList_List_UI_star_inp->name
						pcre_filt_star = pcreCompile(NetList_List_UI_star)
						when(pcreExecute(pcre_filt_star NetList_List_UI_star_inp_name)
							if(strlen(NetList_List_UI_star) == strlen(NetList_List_UI_star_inp_name) then
								when(NetList_List_UI_star_inp_name push(NetList_List_UI_star_inp_name NetList_List_UI_Star_List))
							)
						)
					)
				)
				
				NetList_List_UI_sort = copy(NetList_List_UI_Star_List)
				NetList_List_UI_sort = sort(NetList_List_UI_sort 'alphalessp)		
				axlFormSetField(DC_form "NetList_UI" NetList_List_UI_sort) 
					foreach(NetList_List_loop NetList_List_UI_sort 
						axlFormListSelect(DC_form "NetList_UI" NetList_List_loop)
					)
				)
				
		)
		
		("DeCap"
			Sel_Net_list = axlFormListGetSelItems(DC_form "NetList_UI")
			axlFormSetField(DC_form "NetList_SelName" Sel_Net_list) 
			
			;out = outfile("valfile.csv")
			NetVal_List = nil
			foreach(Sel_Net_list_name Sel_Net_list
				foreach(cmp setof(comps axlDBGetDesign() ->components comps->symbol)
					foreach(pin_data cmp ->pins
						if(Sel_Net_list_name == pin_data->net->name then
							Net_Val = sprintf(nil "%s", cmp->compdef->deviceType)
							Ref_Filt_3 = sprintf(nil "%s", cmp->name)
							Ref_Filt_Sub_3 = substring(Ref_Filt_3 1 1)
							if(Ref_Filt_Sub_3 == "C" || Ref_Filt_Sub_3 == "c" then
								Net_val_str = sprintf(out, "%s,%s", Sel_Net_list_name, Net_Val)
								when(Net_val_str push(Net_val_str NetVal_List))
								;fprintf(out, "%s,%s\n", Sel_Net_list_name, Net_Val)
							)
						)
					)
				)
			)
			;close(out)
			NetVal_List_unq = nil
			NetVal_List_unq = unique(NetVal_List)
			NetVal_List_unq = sort(NetVal_List_unq 'alphalessp)	
			DC_ColCreater()
			axlFormGridInsertRows(DC_form "gridtable" 0 200)
			axlFormGridSetBatch(DC_form "gridtable" 'DC_Inster_Val_Row nil)
			axlFormGridUpdate(DC_form "gridtable")
		)
		
		("DeCapClrAutoSELCAP"
			axlFormGridSetBatch(DC_form "gridtable" 'DC_AutoColCAPSel nil)
			axlFormGridUpdate(DC_form "gridtable")
		)
		
		("DeCapClrAutoSEL"
			axlFormGridSetBatch(DC_form "gridtable" 'DC_AutoColSel nil)
			axlFormGridUpdate(DC_form "gridtable")
		)
		("DeCapClr"
			axlFormGridSetBatch(DC_form "gridtable" 'DC_CapClr nil)
			axlFormGridUpdate(DC_form "gridtable")
		)
		
		("DeCapRep"
			Report_list = nil
			Report_list_gnd = nil
			foreach(DC_Rep setof(comps_rep axlDBGetDesign() ->components comps_rep->symbol)
				foreach(pin_data_rep DC_Rep ->pins
					Net_Val_Rep = sprintf(nil "%s", DC_Rep->compdef->deviceType)
					Ref_Filt_4 = sprintf(nil "%s", DC_Rep->name)
					Ref_Filt_Sub_4 = substring(Ref_Filt_4 1 1)
						if(Ref_Filt_Sub_4 == "C" || Ref_Filt_Sub_4 == "c" then
						Net_val_mir = DC_Rep ->symbol->mirrorType
						if(Net_val_mir == "YES" then
							Rep_mir = "Bottom"
						else
							Rep_mir = "Top"
						)
						Net_val_str = sprintf(nil, "%s,%s,%s,%L,%s", DC_Rep->name, pin_data_rep->net->name, Net_Val_Rep, DC_Rep->symbol->xy, Rep_mir)
						Net_val_str_gnd = sprintf(nil, "%s", pin_data_rep->net->name)
						when(Net_val_str push(Net_val_str Report_list))
						when(Net_val_str_gnd push(Net_val_str_gnd Report_list_gnd))
					)
						
				)
			)
			Report_list_unq = nil
			Report_list_unq = unique(Report_list)
			
			Dc_GND_List = nil
			Dc_GND_List = '("UVSS" "AGND" "DGND" "PGND" "RGND" "UGND" "GND" "GND_D1" "GND_D2" "GND_D3" "GND_D4" "GND_D5" "GND_D6" "GND_D7" "GND_D8" "GND_D9" "GND_D10" "GND_D11" "GND_D12" "GND_D13" "GND_D14" "GND_D15" "GND_D16" "SGND" "USS" "GND_S1" "GND_S2" "GND_S3" "GND_S4" "GND_S5" "GND_S6" "GND_S7" "GND_S8" "GND_S9" "GND_S10" "GND_S11" "GND_S12" "GND_S13" "GND_S14" "GND_S15" "GND_S16" "UGND_1" "UGND_2" "UGND_3" "UGND_4" "UGND_5" "UGND_6" "UGND_7" "UGND_8" "UVSS_1" "UVSS_2" "UVSS_3" "UVSS_4" "UVSS_5" "UVSS_6" "UVSS_7" "UVSS_8" "RFGND_S1" "RFGND_S2" "RFGND_S3" "RFGND_S4" "RFGND_S5" "RFGND_S6" "RFGND_S7" "RFGND_S8" "GND_DDC" "DGND_S1" "DGND_S2" "DGND_S3" "DGND_S4" "DGND_S5" "DGND_S6" "DGND_S7" "DGND_S8" "DGND_S9" "DGND_S10" "DGND_S11" "DGND_S12" "DGND_S13" "DGND_S14" "DGND_S15" "DGND_S16" "HDVS_J18_GND" "GND_DDC_S1" "GND_DDC_S2" "GND_DDC_S3" "GND_DDC_S4" "GND_DDC_S5" "GND_DDC_S6" "GND_DDC_S7" "GND_DDC_S8" "PGND_LVT" "DGND_D1" "DGND_D2" "DGND_D3" "DGND_D4" "DGND_D5" "DGND_D6" "DGND_D7" "DGND_D8" "DGND_D9" "DGND_D10" "DGND_D11" "DGND_D12" "DGND_D13" "DGND_D14" "DGND_D15" "DGND_D16" "AGND_S1" "AGND_S2" "AGND_S3" "AGND_S4" "AGND_S5" "AGND_S6" "AGND_S7" "AGND_S8" "AGND_S9" "AGND_S10" "AGND_S11" "AGND_S12" "AGND_S13" "AGND_S14" "AGND_S15" "AGND_S16" "AGND_D1" "AGND_D2" "AGND_D3" "AGND_D4" "AGND_D5" "AGND_D6" "AGND_D7" "AGND_D8" "AGND_D9" "AGND_D10" "AGND_D11" "AGND_D12" "AGND_D13" "AGND_D14" "AGND_D15" "AGND_D16")
			
			Gnd_del_list = nil
			Gnd_del_list = setof(item, Report_list_gnd, !member(item, Dc_GND_List))
			;print(Gnd_del_list)
			
			logfile = "CapValue.log"
			designName = axlCurrentDesign()
			design_path = axlGetDrawingName()
			timeperform = fileTimeModified("CapValue.log")
			port = axlDMOpenLog(logfile)
			fprintf(port, "Design name: %s\n", design_path)
			fprintf(port, "%s\n", "------------------------------------------------")
			fprintf(port, "%-32s %-32s %-32s %-32s %-32s\n\n", "NAME" "NET NAME","CAP VALUE", "XY LOCATION", "PLACEMENT LOCATION")
			
			final_rep_out = nil
			foreach(Report_list_unq_loop Report_list_unq
				prse_Report_list_unq = parseString(Report_list_unq_loop ",") 
				foreach(Gnd_del_list_loop Gnd_del_list
					if(Gnd_del_list_loop == nth(1 prse_Report_list_unq) then
						final_val = sprintf(nil "%s,%s,%s,%s,%s",nth(0 prse_Report_list_unq), nth(1 prse_Report_list_unq), nth(2 prse_Report_list_unq), nth(3 prse_Report_list_unq), nth(4 prse_Report_list_unq))
						when(final_val push(final_val final_rep_out))
					)					
				)	
			)
			final_rep_out_unq = nil
			final_rep_out = unique(final_rep_out)
			
			foreach(final_rep_out_loop final_rep_out
				final_rep_out_loop_prse = parseString(final_rep_out_loop ",") 
				fprintf(port "%-32s %-32s %-32s %-32s %-32s \n",nth(0 final_rep_out_loop_prse), nth(1 final_rep_out_loop_prse), nth(2 final_rep_out_loop_prse), nth(3 final_rep_out_loop_prse), nth(4 final_rep_out_loop_prse))
			)
			
			axlDMClose(port)
			axlUIViewFileCreate(logfile, "Capacitance value find", nil, '(30 25), '(CENTER))
		)
	
	)
	axlFormDisplay(DC_form)
)

;procedure(formupdate()
	;when((axlFormGetField DC_form "COLOR_LIST")
		;(UserInpMin = (axlFormGetField DC_form "COLOR_LIST"))
	;)
	;println(UserInpMin)
;)

procedure(DC_ColCreater()
  let((default_header)
    default_header=list(                         
      list("Name" 'STRING 30 45)                
      list("Value" 'STRING 25 40)    
      list("Colour" 'ENUMSET 25 30)           
    )
	val = 0
    foreach(it default_header
		val = val + 1
		if(val == 3 then
			col = make_formGridCol()
			col->headText = "DropDown"
			col->fieldType = 'ENUMSET
			col->colWidth = 8               
			col->fieldLength = 32
			col->popup = "colorList"
			axlFormGridInsertCol(DC_form "gridtable" col)
		else
			col = make_formGridCol()
			col->headText = car(it)
			col->fieldType = cadr(it)
			col->colWidth = caddr(it)               
			col->fieldLength = cadddr(it)     
			axlFormGridInsertCol(DC_form "gridtable" col)
		)
	)  
	)
)


procedure(DC_Inster_Val_Row(trash)
  let((cell nRows nField)
    cell = axlFormGridNewCell()
    nRows=0    
	foreach(NetVal_List_unq_loop NetVal_List_unq
		nRows++
		cell->row=nRows
		NetVal_List_unq_prse = parseString(NetVal_List_unq_loop ",")
		colinc = 0
		for(nField 1 2
			cell->col = nField
			cell->value=nth(colinc NetVal_List_unq_prse)
			axlFormGridBatch(cell)
			colinc++
		)
		cell->col = 3
		cell->value = "Colour"
		cell->popup = "colorList"
		axlFormGridBatch(cell)
	)
  )
)

procedure(DC_FormCapClr(trash)
	cellthree = "Nil"
	cell = axlFormGridNewCell()
	nRows=0
	foreach(NetVal_List_unq_loop NetVal_List_unq
	nRows++
    cell->row = nRows
		cell->col = 1
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		cellone = cell->value
		
		cell->col = 2
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		celltwo = cell->value
		
		cell->col = 3
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		cellthree = cell->value
		cond(
              (cell->col = 3
					if(cellthree == "YES" then
						rgb = axlUIColorDialog(nil nil)
						axlColorSet(CusVal rgb)
						cell->value = CusVal
						axlVisibleUpdate(t)
						cell->backColor = CusVal
						CusVal = CusVal + 1
					else
						if(cellthree == "NO" then
							cell->backColor = nil
							axlVisibleUpdate(t)
						)
					)
              )
			)
		axlFormGridBatch(cell)	
	)
)

procedure(DC_CapClr(trash)
	Clr_list_1 = nil
	Clr_list_2 = nil
	cell = axlFormGridNewCell()
	nRows=0
	foreach(NetVal_List_unq_loop NetVal_List_unq
	nRows++
    cell->row = nRows
		cell->col = 1
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		cellone = cell->value
		
		cell->col = 2
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		celltwo = cell->value
		
		cell->col = 3
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		cellthree = cell->value
		cond(
              (cell->col = 3
					if(cellthree != "Colour" then
						cellthreeval = atof(cellthree)
						cellthreerou = round(cellthreeval)
						;cell->backColor = cellthreerou
					)
              )
			)
		axlFormGridBatch(cell)
		
		finalval = sprintf(nil "%s,%s", celltwo, cellthree)   
		when(finalval push(finalval Clr_list_1))
		
		finalval1 = sprintf(nil "%s", cellone)   
		when(finalval1 push(finalval1 Clr_list_2))
		
	)
	

	foreach(Clr_data setof(comps axlDBGetDesign() ->components comps->symbol)
		foreach(Clr_data_pin Clr_data ->pins
			Clr_data_pin_net_name = Clr_data_pin->net->name
			Cap_Val = sprintf(nil "%s", Clr_data->compdef->deviceType)
			foreach(Net_list_loop Clr_list_2
				if(Net_list_loop == Clr_data_pin_net_name 
					foreach(Clr_list_loop Clr_list_1
						form_inp_Cap = nth(0 parseString(Clr_list_loop ","))
						form_inp_Clr_val = nth(1 parseString(Clr_list_loop ","))
							if(form_inp_Cap == Cap_Val then	
								if(form_inp_Clr_val != "Colour" then
									clr_val_int = atof(form_inp_Clr_val)
									clr_val_int_round = round(clr_val_int)
									axlCustomColorObject(Clr_data, clr_val_int_round)
								)
							)	
					)				
				)
			)
		)
	)
	axlUIConfirm( "Manual Selected Colour has been updated Successfully...!" )
)


procedure(DC_AutoColSel(trash)

NetVal_List_unq_auto_sel_final = nil
clr_val_sel_auto = 1
foreach(NetVal_List_unq_loop_sel NetVal_List_unq
			if(clr_val_sel_auto == 4 || clr_val_sel_auto == 8 || clr_val_sel_auto == 17 || clr_val_sel_auto == 34 || clr_val_sel_auto == 50 || clr_val_sel_auto == 55 || clr_val_sel_auto == 66 || clr_val_sel_auto == 71 || clr_val_sel_auto == 87 || clr_val_sel_auto == 101 || clr_val_sel_auto == 149 || clr_val_sel_auto == 165 || clr_val_sel_auto == 181 then
				clr_val_sel_auto++
				NetVal_List_unq_auto_sel = sprintf(nil "%s,%d", NetVal_List_unq_loop_sel, clr_val_sel_auto)
				when(NetVal_List_unq_auto_sel push(NetVal_List_unq_auto_sel NetVal_List_unq_auto_sel_final))
				clr_val_sel_auto++
			else
				NetVal_List_unq_auto_sel = sprintf(nil "%s,%d", NetVal_List_unq_loop_sel, clr_val_sel_auto)
				when(NetVal_List_unq_auto_sel push(NetVal_List_unq_auto_sel NetVal_List_unq_auto_sel_final))
				clr_val_sel_auto++
			)

		)

cell = axlFormGridNewCell()
foreach(Final_Clr_up_AutoSelCap_UI NetVal_List_unq_auto_sel_final
	NET_UI = nth(0 parseString(Final_Clr_up_AutoSelCap_UI ","))
	CAP_UI = nth(1 parseString(Final_Clr_up_AutoSelCap_UI ","))
	CLR_UI = nth(2 parseString(Final_Clr_up_AutoSelCap_UI ","))
	nRows=0
	foreach(NetVal_List_unq_loop NetVal_List_unq
	nRows++
    cell->row = nRows
		cell->col = 1
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		cellone = cell->value
		
		cell->col = 2
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		celltwo = cell->value
		if(NET_UI == cellone then 
		if(celltwo == CAP_UI then
			cond(
					(cell->col = 3
						CAPP = atof(CLR_UI)
						CAP1rou = round(CAPP)
						axlVisibleUpdate(t)
						cell->backColor = CAP1rou
					)
				)
				
			)
		)
		
		axlFormGridBatch(cell)
		
	)
)

	foreach(AutoSel setof(compsAutoSel axlDBGetDesign() ->components compsAutoSel->symbol)
		foreach(AutoSel_pin AutoSel ->pins
		AutoSel_net_name = AutoSel_pin->net->name 
		AutoSel_Cap_Val = sprintf(nil "%s", AutoSel->compdef->deviceType)
			foreach(NetVal_List_unq_Autosel NetVal_List_unq_auto_sel_final
				AutoSel_inp_Net_name = nth(0 parseString(NetVal_List_unq_Autosel ","))
				AutoSel_inp_Cap = nth(1 parseString(NetVal_List_unq_Autosel ","))
				AutoSel_inp_Clr = nth(2 parseString(NetVal_List_unq_Autosel ","))
				if(AutoSel_inp_Net_name == AutoSel_net_name then
					if(AutoSel_Cap_Val == AutoSel_inp_Cap then
						AutoSel_inp_Clr_str = atof(AutoSel_inp_Clr)
						AutoSel_inp_Clr_round = round(AutoSel_inp_Clr_str)
						axlCustomColorObject(AutoSel, AutoSel_inp_Clr_round)
					)
				)
			)
		)
	)
	axlUIConfirm( "Selected NET Auto Colour has been updated Successfully...!" )
)

procedure(DC_AutoColCAPSel(trash)

AutoSel_CapVal = nil
AutoSel_NetNme = nil
clr_val_CAP_sel_auto = 1

foreach(NetVal_loop_CAPSel NetVal_List_unq
	NetVal_loop_CAPSel_val = nth(1 parseString(NetVal_loop_CAPSel ","))
	NetVal_loop_NetNme_val = nth(0 parseString(NetVal_loop_CAPSel ","))
	NetVal_loop_CAPSel_clr = sprintf(nil "%s", NetVal_loop_CAPSel_val) 
	NetVal_loop_CAPSel_NetNme = sprintf(nil "%s", NetVal_loop_NetNme_val)
	when(NetVal_loop_CAPSel_NetNme push(NetVal_loop_CAPSel_NetNme AutoSel_NetNme))
	when(NetVal_loop_CAPSel_clr push(NetVal_loop_CAPSel_clr AutoSel_CapVal))
)
AutoSel_CapVal_unq = nil
AutoSel_CapVal_unq = unique(AutoSel_CapVal)

AutoSel_NetNme_unq = nil
AutoSel_NetNme_unq = unique(AutoSel_NetNme)

Final_Clr_up_AutoSelCap = nil


foreach(AutoSel_CapVal_unq_loop AutoSel_CapVal_unq
			if(clr_val_CAP_sel_auto == 4 || clr_val_CAP_sel_auto == 8 || clr_val_CAP_sel_auto == 17 || clr_val_CAP_sel_auto == 34 || clr_val_CAP_sel_auto == 50 || clr_val_CAP_sel_auto == 55 || clr_val_CAP_sel_auto == 66 || clr_val_CAP_sel_auto == 71 || clr_val_CAP_sel_auto == 87 || clr_val_CAP_sel_auto == 101 || clr_val_CAP_sel_auto == 149 || clr_val_CAP_sel_auto == 165 || clr_val_CAP_sel_auto == 181 then
				clr_val_CAP_sel_auto++
				AutoSel_CapVal_unq_loop_clr = sprintf(nil "%s,%d", AutoSel_CapVal_unq_loop, clr_val_CAP_sel_auto)
				when(AutoSel_CapVal_unq_loop_clr push(AutoSel_CapVal_unq_loop_clr Final_Clr_up_AutoSelCap))
				clr_val_CAP_sel_auto++
			else
				AutoSel_CapVal_unq_loop_clr = sprintf(nil "%s,%d", AutoSel_CapVal_unq_loop, clr_val_CAP_sel_auto)
				when(AutoSel_CapVal_unq_loop_clr push(AutoSel_CapVal_unq_loop_clr Final_Clr_up_AutoSelCap))
				clr_val_CAP_sel_auto++
			)

		)

cell = axlFormGridNewCell()
foreach(Final_Clr_up_AutoSelCap_UI Final_Clr_up_AutoSelCap
	CAP_UI = nth(0 parseString(Final_Clr_up_AutoSelCap_UI ","))
	CLR_UI = nth(1 parseString(Final_Clr_up_AutoSelCap_UI ","))
	nRows=0
	foreach(NetVal_List_unq_loop NetVal_List_unq
	nRows++
    cell->row = nRows
		cell->col = 1
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		cellone = cell->value
		
		cell->col = 2
		cell = axlFormGridGetCell(DC_form "gridtable" cell)
		celltwo = cell->value
		CELL_CAP_STR = sprintf(nil "%s", celltwo)
		
		if(CELL_CAP_STR == CAP_UI then
			cond(
					(cell->col = 3
						CAPP = atof(CLR_UI)
						CAP1rou = round(CAPP)
						axlVisibleUpdate(t)
						cell->backColor = CAP1rou
					)
				)
				
			)
		
		axlFormGridBatch(cell)
		
	)
)

foreach(AutoSel_CLRSEL setof(compsAutoCAPCLRSel axlDBGetDesign() ->components compsAutoCAPCLRSel->symbol)
	foreach(AutoSel_CLRSEL_pinloop AutoSel_CLRSEL ->pins
		AutoSel_CLRSEL_pin_netnme = AutoSel_CLRSEL_pinloop->net->name  
		AutoSel_CapCLR_Val = sprintf(nil "%s", AutoSel_CLRSEL->compdef->deviceType)
		foreach(AutoSel_NetNme_unq_loop AutoSel_NetNme_unq
			if(AutoSel_NetNme_unq_loop == AutoSel_CLRSEL_pin_netnme then 
				foreach(Final_Clr_up_AutoSelCap_loop Final_Clr_up_AutoSelCap
					AutoSelCAP_inp_CAPVAL = nth(0 parseString(Final_Clr_up_AutoSelCap_loop ","))
					AutoSelCAP_inp_CAPCLR = nth(1 parseString(Final_Clr_up_AutoSelCap_loop ","))
						if(AutoSel_CapCLR_Val == AutoSelCAP_inp_CAPVAL then
							AutoSelCAP_inp_CAPCLR_at = atof(AutoSelCAP_inp_CAPCLR)
							AutoSelCAP_inp_CAPCLR_rd = round(AutoSelCAP_inp_CAPCLR_at)
							axlCustomColorObject(AutoSel_CLRSEL, AutoSelCAP_inp_CAPCLR_rd)
						)		
				)
			)
		)
	)
)
axlUIConfirm( "Selected NET Auto Colour CAP Wise has been updated Successfully...!" )

)

procedure(DC_Rep_Sel()
	sel_rep_sym_add = nil
	sel_rep_gnd = nil
	foreach(sel_rep setof(compsAutoSel axlDBGetDesign() ->components compsAutoSel->symbol)
		foreach(sel_rep_pin sel_rep ->pins
			sel_rep_net_name = sel_rep_pin->net->name 
			sel_rep_Cap_Val = sprintf(nil "%s", sel_rep->compdef->deviceType)
			foreach(NetVal_List_unq_selrep NetVal_List_unq
				sel_rep_inp_Net_name = nth(0 parseString(NetVal_List_unq_selrep ","))
				sel_rep_inp_Cap = nth(1 parseString(NetVal_List_unq_selrep ","))
				if(sel_rep_inp_Net_name == sel_rep_net_name then
					if(sel_rep_Cap_Val == sel_rep_inp_Cap then
						sel_rep_mir = sel_rep ->symbol->mirrorType
						if(sel_rep_mir == "YES" then
							sel_mir = "Bottom"
						else
							sel_mir = "Top"
						)
						sel_rep_val = sprintf(nil "%s,%s,%L,%s", NetVal_List_unq_selrep, sel_rep->name, sel_rep->symbol->xy, sel_mir)
						when(sel_rep_val push(sel_rep_val sel_rep_sym_add))
						when(sel_rep_inp_Net_name push(sel_rep_inp_Net_name sel_rep_gnd))
					)
				)
				
			)
		)
	)
	sel_rep_sym_add_unq = nil
	sel_rep_sym_add_unq = unique(sel_rep_sym_add)
	
	sel_rep_gnd_unq = nil
	sel_rep_gnd_unq = unique(sel_rep_gnd)
	
	Dc_GND_Rep_Sel = nil
	Dc_GND_Rep_Sel = '("UVSS" "AGND" "DGND" "PGND" "RGND" "UGND" "GND" "GND_D1" "GND_D2" "GND_D3" "GND_D4" "GND_D5" "GND_D6" "GND_D7" "GND_D8" "GND_D9" "GND_D10" "GND_D11" "GND_D12" "GND_D13" "GND_D14" "GND_D15" "GND_D16" "SGND" "USS" "GND_S1" "GND_S2" "GND_S3" "GND_S4" "GND_S5" "GND_S6" "GND_S7" "GND_S8" "GND_S9" "GND_S10" "GND_S11" "GND_S12" "GND_S13" "GND_S14" "GND_S15" "GND_S16" "UGND_1" "UGND_2" "UGND_3" "UGND_4" "UGND_5" "UGND_6" "UGND_7" "UGND_8" "UVSS_1" "UVSS_2" "UVSS_3" "UVSS_4" "UVSS_5" "UVSS_6" "UVSS_7" "UVSS_8" "RFGND_S1" "RFGND_S2" "RFGND_S3" "RFGND_S4" "RFGND_S5" "RFGND_S6" "RFGND_S7" "RFGND_S8" "GND_DDC" "DGND_S1" "DGND_S2" "DGND_S3" "DGND_S4" "DGND_S5" "DGND_S6" "DGND_S7" "DGND_S8" "DGND_S9" "DGND_S10" "DGND_S11" "DGND_S12" "DGND_S13" "DGND_S14" "DGND_S15" "DGND_S16" "HDVS_J18_GND" "GND_DDC_S1" "GND_DDC_S2" "GND_DDC_S3" "GND_DDC_S4" "GND_DDC_S5" "GND_DDC_S6" "GND_DDC_S7" "GND_DDC_S8" "PGND_LVT" "DGND_D1" "DGND_D2" "DGND_D3" "DGND_D4" "DGND_D5" "DGND_D6" "DGND_D7" "DGND_D8" "DGND_D9" "DGND_D10" "DGND_D11" "DGND_D12" "DGND_D13" "DGND_D14" "DGND_D15" "DGND_D16" "AGND_S1" "AGND_S2" "AGND_S3" "AGND_S4" "AGND_S5" "AGND_S6" "AGND_S7" "AGND_S8" "AGND_S9" "AGND_S10" "AGND_S11" "AGND_S12" "AGND_S13" "AGND_S14" "AGND_S15" "AGND_S16" "AGND_D1" "AGND_D2" "AGND_D3" "AGND_D4" "AGND_D5" "AGND_D6" "AGND_D7" "AGND_D8" "AGND_D9" "AGND_D10" "AGND_D11" "AGND_D12" "AGND_D13" "AGND_D14" "AGND_D15" "AGND_D16")
	
	Gnd_del_Rep_Sel = nil
	Gnd_del_Rep_Sel = setof(item, sel_rep_gnd_unq, !member(item, Dc_GND_Rep_Sel))
	
	Gnd_filt_Rep_Sel = nil
	Net_Name_filt = nil
	foreach(sel_rep_sym_add_unq_loop sel_rep_sym_add_unq
		sel_rep_sym_add_unq_net_name = nth(0 parseString(sel_rep_sym_add_unq_loop ",")) 
		foreach(Gnd_del_Rep_Sel_loop Gnd_del_Rep_Sel
			if(Gnd_del_Rep_Sel_loop == sel_rep_sym_add_unq_net_name then
				when(sel_rep_sym_add_unq_loop push(sel_rep_sym_add_unq_loop Gnd_filt_Rep_Sel))
				when(sel_rep_sym_add_unq_net_name push(sel_rep_sym_add_unq_net_name Net_Name_filt))
			)
		)
	)
	
	Gnd_filt_Rep_Sel_unq = nil
	Gnd_filt_Rep_Sel_unq = unique(Gnd_filt_Rep_Sel)
	
	Net_Name_filt_unq = nil
	Net_Name_filt_unq = unique(Net_Name_filt)
	
	logfile_Sel = "CapValue_Sel.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	timeperform = fileTimeModified("CapValue_Sel.log")
	port_sel_rep = axlDMOpenLog(logfile_Sel)
	fprintf(port_sel_rep, "Design name: %s\n", design_path)
			
		foreach(Gnd_filt_Rep_Sel_unq_net Net_Name_filt_unq
		input_lst = nil
			fprintf(port_sel_rep, "%s\n", "---------------------------------------------------------------------------------------")
			fprintf(port_sel_rep, "\n")
			fprintf(port_sel_rep, "\n")
			fprintf(port_sel_rep, "%s %s\n", "Net-Name -" Gnd_filt_Rep_Sel_unq_net)
			fprintf(port_sel_rep, "\n")
			fprintf(port_sel_rep, "%-32s %-32s %-32s %-32s\n", "Value" "Symbol Name" "XY Location" "PLACEMENT LOCATION")
			fprintf(port_sel_rep, "\n")
			foreach(Gnd_filt_Rep_Sel_unq_loop Gnd_filt_Rep_Sel_unq
				Sel_Rep_Inp_Net = nth(0 parseString(Gnd_filt_Rep_Sel_unq_loop ","))
				Sel_Rep_Inp_Cap = nth(1 parseString(Gnd_filt_Rep_Sel_unq_loop ","))
				Sel_Rep_Inp_Sym = nth(2 parseString(Gnd_filt_Rep_Sel_unq_loop ","))
				Sel_Rep_Inp_XY = nth(3 parseString(Gnd_filt_Rep_Sel_unq_loop ","))
				Sel_Rep_Inp_plc = nth(4 parseString(Gnd_filt_Rep_Sel_unq_loop ","))
					if(Gnd_filt_Rep_Sel_unq_net == Sel_Rep_Inp_Net then 
						fprintf(port_sel_rep "%-32s %-32s %-32s %-32s\n",Sel_Rep_Inp_Cap, Sel_Rep_Inp_Sym, Sel_Rep_Inp_XY, Sel_Rep_Inp_plc)
						when(Sel_Rep_Inp_Cap push(Sel_Rep_Inp_Cap input_lst))
					)
			)
			fprintf(port_sel_rep, "\n")
			fprintf(port_sel_rep, "\n")
			fprintf(port_sel_rep, "%s\n", "COUNT :")
			fprintf(port_sel_rep, "\n")
			input_lst_unq = nil
			input_lst_unq = unique(input_lst)
			checked_lst =nil
			foreach(item input_lst_unq
				if(member(item checked_lst) == nil then
					fprintf(port_sel_rep "%L - %d\n", item, length(setof(el input_lst el == item)))
					chekked_lst = cons(item checked_lst)
				)
			)
			
		)
			
			
	axlDMClose(port_sel_rep)
	axlUIViewFileCreate(logfile_Sel, "Capacitance value find", nil, '(30 25), '(CENTER))
	
	
)



