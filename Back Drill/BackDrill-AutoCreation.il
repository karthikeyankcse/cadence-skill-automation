;Prog: Karthi keyan.K
;Org:  Pactron Cbe
;Date: 7/OCT/2021
;This program used to Automate the Back Drill Keepout Creation Automatically.
;The Back Drill keepout wants to create after the routed layer.
;This code works by the Back Drill Analysis Report in tool.
;Here in this code from the UI Diameter Value and stub layer input will collect by the drill size then it creates a keepout.
;Below declared function is the main functions call out sub functions.
axlCmdRegister("backdrill_kar" 'backdrill_kar)
(defun backdrill_kar ()
	axlUIConfirm( "Before you run the code please make sure that all the Electrical Layers should want to be Enable...!" )
	inputlist()
	createbackform()
	backform()
)

;This function used to create a Form. Form file is used to Create a UI.
(defun backform () 
	backform=axlFormCreate( (gensym) backform_file nil 'back_Action t)
	axlFormDisplay(backform)
)

;Inputs of Via & Pin gathered by Brd file for TOP and BOTTOM Seperatly
;Gathered data are "Back drill layer", "Drill diameter", "XY Point" 
;For pin Top gathered and stored in list
(defun inputlist ()
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
	pinTop = axlGetSelSet(axlAddSelectAll())
	PinTopList = nil
		foreach(pinrpts pinTop
			result_pin = axlBackDrill(pinrpts, 'top)
				if(result_pin ->toLayer != nil then 
					if(result_pin ->toLayer != 0 then
						drill_pin = sprintf(nil "%L" pinrpts->definition->drillDiameter )
						drill_str_pin = sprintf(nil strcat(drill_pin))
						pinListstr = sprintf(nil, "%L,%s,%L,%L,%s,%s", result_pin ->toLayer, drill_str_pin, car(pinrpts->xy), cadr(pinrpts->xy), pinrpts->net->name, pinrpts->parent->refdes)
						when(pinListstr push(pinListstr PinTopList))
					)
				)
		)
	
	;For via Top gathered and stored in list
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	viaTop = axlGetSelSet(axlAddSelectAll())
	ViaTopList = nil
		foreach(viarpts viaTop
			result_via = axlBackDrill(viarpts, 'top)
				if(result_via ->toLayer != nil then 
					if(result_via ->toLayer != 0 then
						drill_via = sprintf(nil "%L" viarpts->definition->drillDiameter )
						dril_str_via = sprintf(nil strcat(drill_via))
						viaListstr = sprintf(nil, "%L,%s,%L,%L,%s", result_via ->toLayer, dril_str_via, car(viarpts->xy), cadr(viarpts->xy), viarpts->net->name)
						when(viaListstr push(viaListstr ViaTopList))
					)
				)
		)
		
	;Inputs of Via & Pin gathered by Brd file for TOP and BOTTOM Seperatly
	;Gathered data are "Back drill layer", "Drill diameter", "XY Point" 
	;For pin BOTTOM gathered and stored in list
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
	pinBot = axlGetSelSet(axlAddSelectAll())
	PinBotList = nil
		foreach(pinrpts_bot pinBot
			result_pin_bot = axlBackDrill(pinrpts_bot, 'bottom)
				if(result_pin_bot ->toLayer != nil then
					if(result_pin_bot ->toLayer != 0 then
						drill_pin_bot = sprintf(nil "%L" pinrpts_bot->definition->drillDiameter )
						drill_str_pin_bot = sprintf(nil strcat(drill_pin_bot))
						pinListstr_bot = sprintf(nil, "%L,%s,%L,%L,%s,%s", result_pin_bot ->toLayer, drill_str_pin_bot, car(pinrpts_bot->xy), cadr(pinrpts_bot->xy), pinrpts_bot->net->name, pinrpts_bot->parent->refdes)
						when(pinListstr_bot push(pinListstr_bot PinBotList))
					)
				)
		)
	
	;For via BOTTOM gathered and stored in list
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	viaBot = axlGetSelSet(axlAddSelectAll())
	ViaBotList = nil
		foreach(viarpts_bot viaBot
			result_via_bot = axlBackDrill(viarpts_bot, 'bottom)
				if(result_via_bot ->toLayer != nil then
					if(result_via_bot ->toLayer != 0 then
						drill_via_bot = sprintf(nil "%L" viarpts_bot->definition->drillDiameter )
						dril_str_via_bot = sprintf(nil strcat(drill_via_bot))
						viaListstr_bot = sprintf(nil, "%L,%s,%L,%L,%s", result_via_bot ->toLayer, dril_str_via_bot, car(viarpts_bot->xy), cadr(viarpts_bot->xy), viarpts_bot->net->name)
						when(viaListstr_bot push(viaListstr_bot ViaBotList))
					)
				)			
			)
	
	;Combined the PIN and VIA TOP list in single list.
	Toplist_Via_Pin = nil
	Toplist_Via_Pin = append(PinTopList ViaTopList)
	
	;Combined the PIN and VIA BOT list in single list.
	Botlist_Via_Pin = nil
	Botlist_Via_Pin = append(PinBotList ViaBotList)
	
	;Combined TOP list and BOTTOM LIST
	Input_drill_Top_Bot = nil 
	Input_drill_Top_Bot = append(Toplist_Via_Pin Botlist_Via_Pin)
	
	;Parsing drill diameter alone to check the list of diameter value found in brd file
	if(Input_drill_Top_Bot == nil then
		axlUIConfirm( "This BackDrill Automation works only on Designer, GXL, XL Or Higherend Licence.." )
		;axlFormClose(backform)
	)
	loopval = length(Input_drill_Top_Bot)
	
	
	Drill_Input_Top_Bot = nil
		foreach(Input_Loop Input_drill_Top_Bot
			Input_parse = nth(1 parseString(Input_Loop ","))
				when(Input_parse push(Input_parse Drill_Input_Top_Bot))
		)
	
	;Duplicated value removed
	Unq_Drill_Input_Top_Bot = unique(Drill_Input_Top_Bot)
	
	Net_Top_Bot = nil
		foreach(Input_drill_Top_Bot_net Input_drill_Top_Bot
			Input_drill_Top_Bot_net_prse = nth(4 parseString(Input_drill_Top_Bot_net ","))
			when(Input_drill_Top_Bot_net_prse push(Input_drill_Top_Bot_net_prse Net_Top_Bot))
		)
)


;Function used to create a UI for gathering inputs from user
;The inputs are Keepout Diameter and Stub Layers
;Two methods of creating one is everything in the brd file it will create another one by netname filtered filterd net it will create
(defun createbackform ()

	drain()
		backform_file = "back.form"
		backform = outfile(backform_file "w")

		fprintf(backform "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(backform "FORM\n")
		fprintf(backform "FIXED\n")
		fprintf(backform "PORT 39 10\n")

		fprintf(backform "HEADER \"Back Drill Automatic Creation\"\n")
		fprintf(backform "\n")
		fprintf(backform "TILE\n")

		;lendata = sprintf(nil, "TEXT \"%s%d\"\n", "Net - ",loopval)
		;fprintf(backform lendata)
		;fprintf(backform "TLOC 2 10\n")
		;fprintf(backform "ENDTEXT\n")

		;fprintf(backform "FIELD LenF\n")
		;fprintf(backform "FLOC 10 10\n")
		;fprintf(backform "INTSLIDEBAR 4 4\n MIN 0\n MAX 5000\n")
		;fprintf(backform "ENDFIELD\n")
		;fprintf(backform "\n")

		;fprintf(backform "TEXT \"TO\"\n")
		;fprintf(backform "TLOC 19 10\n")
		;fprintf(backform "ENDTEXT\n")

		;fprintf(backform "FIELD LenS\n")
		;fprintf(backform "FLOC 22 10\n")
		;fprintf(backform "INTSLIDEBAR 4 4\n MIN 0\n MAX 5000\n")
		;fprintf(backform "ENDFIELD\n")
		;fprintf(backform "\n")
		
		
		fprintf(backform "FIELD TOCREATESTBSEL\n")
		fprintf(backform "FLOC 5 20\n")
		fprintf(backform "MENUBUTTON \"ADD-STB-SEL\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TOCREATESTB\n")
		fprintf(backform "FLOC 22 20\n")
		fprintf(backform "MENUBUTTON \"ADD-STB-ALL\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TODELSTBALL\n")
		fprintf(backform "FLOC 5 25\n")
		fprintf(backform "MENUBUTTON \"DEL-STB(ALL)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TODELSTBSEL\n")
		fprintf(backform "FLOC 22 25\n")
		fprintf(backform "MENUBUTTON \"DEL-STB(SEL)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "TEXT \"Drill Size\"\n")
		fprintf(backform "TLOC 5 30\n")
		fprintf(backform "ENDTEXT\n")

		fprintf(backform "TEXT \"Keepout Dia\"\n")
		fprintf(backform "TLOC 15 30\n")
		fprintf(backform "ENDTEXT\n")

		fprintf(backform "TEXT \"Stub Layers\"\n")
		fprintf(backform "TLOC 25 30\n")
		fprintf(backform "ENDTEXT\n")
		
		
		datainp = 35
		foreach(listlp Unq_Drill_Input_Top_Bot 
			adata = sprintf(nil, "TEXT \"%s\"\n", listlp) 
			fprintf(backform adata)
			adt = sprintf(nil, "TLOC 5 %d\n", datainp)
			fprintf(backform adt)
			datainp = datainp + 5
			fprintf(backform "ENDTEXT\n")
		)

		datainp1 = 35
		foreach(listlp2 Unq_Drill_Input_Top_Bot
			fprintf(backform "FIELD %s\n", listlp2)
			adt1 = sprintf(nil, "FLOC 15 %d\n", datainp1)
			fprintf(backform adt1)
			fprintf(backform "REALFILLIN 5 5\n")
			fprintf(backform "REALMIN 1.0\n")
			fprintf(backform "REALMAX 1000.000000\n")
			fprintf(backform "ENDFIELD\n")
			fprintf(backform "\n")
			datainp1 = datainp1 + 5
		)

		datainp2 = 35
		foreach(listlp3 Unq_Drill_Input_Top_Bot
			fprintf(backform "FIELD %s%s\n", listlp3, "_STB")
			adt2 = sprintf(nil, "FLOC 25 %d\n", datainp2)
			fprintf(backform adt2)
			fprintf(backform "INTSLIDEBAR 3 3\n MIN 0\n MAX 5\n")
			fprintf(backform "ENDFIELD\n")
			fprintf(backform "\n")
			datainp2 = datainp2 + 5
		)

		fprintf(backform "FIELD TOCREATE\n")
		fprintf(backform "FLOC 20 1\n")
		fprintf(backform "MENUBUTTON \"Add-KO(Sel NET)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TOSELDELETE\n")
		fprintf(backform "FLOC 20 10\n")
		fprintf(backform "MENUBUTTON \"Del-KO(Sel NET)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TORECREATE\n")
		fprintf(backform "FLOC 5 1\n")
		fprintf(backform "MENUBUTTON \"Add-KO(All NET)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TORESELCREATE\n")
		fprintf(backform "FLOC 12 5\n")
		fprintf(backform "MENUBUTTON \"Add-KO(SEL DRILL)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")

		fprintf(backform "FIELD TODELETE\n")
		fprintf(backform "FLOC 5 10\n")
		fprintf(backform "MENUBUTTON \"Del-KO(All NET)\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TOADDPROP\n")
		fprintf(backform "FLOC 1 15\n")
		fprintf(backform "MENUBUTTON \"Add Prop\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")
		
		fprintf(backform "FIELD TOCLOSE\n")
		fprintf(backform "FLOC 15 15\n")
		fprintf(backform "MENUBUTTON \"Close\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")

		fprintf(backform "FIELD TOCHECK\n")
		fprintf(backform "FLOC 29 15\n")
		fprintf(backform "MENUBUTTON \"Checking\" 10 4\n")
		fprintf(backform "ENDFIELD\n")
		fprintf(backform "\n")

		fprintf(backform "\n")
		fprintf(backform "ENDTILE\n")
		fprintf(backform "\n")
		fprintf(backform "ENDFORM\n")
	close( backform)
)
DIA_STB = nil
;action performs after gathered the inputs from user.
(defun back_Action (backform)
	(case backform->curField	
		;This Add Property case is used to add the property to the list of nets collected by user.
		("TOADDPROP"
				;Initialy Deletes the every property added in the brd file.
				axlClearSelSet()
				axlSetFindFilter(?enabled '("NOALL", "NETS"), ?onButtons "NETS")
				Net_list = axlGetSelSet(axlAddSelectAll())
					foreach(Net_list_lp Net_list						
						axlDBDeleteProp(list(Net_list_lp) list('BACKDRILL_MAX_PTH_STUB))
					)
				
				;Program to collect the input from user.
				inp_prop_add = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
				prop_add = axlDMFileParts(inp_prop_add)
				propinp_add = axlDMOpenFile("ALLEGRO_TEXT" cadr(prop_add) "r") 
				propinp_netname_add = nil
					while(gets(p_inp_add propinp_add)
						p_inp_add = car(parseString(p_inp_add "\n"))
							when(p_inp_add push(p_inp_add propinp_netname_add))
						)
				axlDMClose(propinp_add)
				;Adding the property to given nets
				BackDrillPropVal = axlEnterString(?prompts list("Enter the Back drill stub value.."))
				BackDrillPropVal_int = atof(BackDrillPropVal)
				axlClearSelSet()
				axlSetFindFilter(?enabled '("NOALL", "NETS"), ?onButtons "NETS")
				Net_list = axlGetSelSet(axlAddSelectAll())
					foreach(Net_list_lp Net_list
						Net_list_lp_prse = Net_list_lp ->name
							foreach(a_lp propinp_netname_add
								if(a_lp == Net_list_lp_prse then
									axlDBAddProp(list(Net_list_lp) list('BACKDRILL_MAX_PTH_STUB BackDrillPropVal_int))
								)
							)
						)
					propinp_BDE_netname_unq = nil
					propinp_BDE_netname_unq = unique(propinp_netname_add)	
					backdrill_kar_BDE()	
		;axlFormClose(backform_BDE)	
		;shell("rm -f back_BDE.form")
		
		;axlFormClose(backform)	
		;shell("rm -f back.form")
		;nil
		;inputlist()
		;createbackform()
		;backform()
		)
		
		("TODELSTBSEL"
			inp_prop_STB = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
			fileparts_prop_STB = axlDMFileParts(inp_prop_STB)
			propinp_STB = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts_prop_STB) "r")
				if(propinp_STB != nil then
					propinp_STB_netname = nil
						while(gets(p_inp_STB propinp_STB)
							p_inp_STB = car(parseString(p_inp_STB "\n"))
							when(p_inp_STB push(p_inp_STB propinp_STB_netname))
						)
					axlDMClose(propinp_STB)
					propinp_STB_netname_unq = nil
					propinp_STB_netname_unq = unique(propinp_STB_netname)
				else
					print("nil")
				)
				foreach(propinp_STB_netname_unq_del propinp_STB_netname_unq
					foreach(item_std_del axlDBGetShapes("ETCH")
						if(item_std_del->prop->COMMENT=="custom_keepout_STB" then
							if(item_std_del->net->name == propinp_STB_netname_unq_del then 
								axlDBDeleteProp(item_std_del '(FIXED))
								axlDeleteObject(item_std_del)
								axlDBRefreshId(nil)
							)
						)
					)
				)
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		
		)
		
		
		("TOCREATESTB"
			backdrill_stub_kar()
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		
		)
		
		("TOCREATESTBSEL"
			backdrill_stub_SEL_kar()
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		
		)
		
		("TODELSTBALL"
			;foreach(propinp_STB_netname_unq_del propinp_STB_netname_unq
					foreach(item_std_del axlDBGetShapes("ETCH")
						if(item_std_del->prop->COMMENT=="custom_keepout_STB" then
							;if(item_std_del->net->name == propinp_STB_netname_unq_del then 
								axlDBDeleteProp(item_std_del '(FIXED))
								axlDeleteObject(item_std_del)
								axlDBRefreshId(nil)
							;)
						)
					)
				;)
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		
		)
		
		;This Case used to Create a keepout by the list of nets.
		("TOCREATE"
			
			create_inp()
			axlUIConfirm( "Keepouts Created Successfully..." )
			DIA_STB = nil
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		)
		
		;This case is used to create a another form for checking loop
		("TOCHECK"
			backdrill_chk()
			DIA_STB = nil
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		)
		
		
		
		("TORECREATE"	
			foreach(Unq_Drill_Loop Unq_Drill_Input_Top_Bot
			when((axlFormGetField backform Unq_Drill_Loop)
				(BD_getval = (axlFormGetField backform Unq_Drill_Loop))
					stb_val = sprintf(nil "%s%s", Unq_Drill_Loop, "_STB")
					when((axlFormGetField backform stb_val)
						(BD_getval_STB = (axlFormGetField backform stb_val))
						DIA_STB_Val = sprintf(nil, "%s,%L,%L", Unq_Drill_Loop, BD_getval, BD_getval_STB)
						when(DIA_STB_Val push(DIA_STB_Val DIA_STB))
					)
				
				)
			)
			
			DIA_STB_NZ = nil
			foreach(DIA_STB_NZ_LP DIA_STB
				DIA_STB_D = nth(1 parseString(DIA_STB_NZ_LP ",")) 
					if(DIA_STB_D != "0.0" then
						when(DIA_STB_NZ_LP push(DIA_STB_NZ_LP DIA_STB_NZ))
					)
			)
			
			RESEL_INP = length(DIA_STB_NZ)
			RESEL_INP_COL = length(Unq_Drill_Input_Top_Bot)
			
			if(RESEL_INP == RESEL_INP_COL then 
			foreach(Redel_item_delete axlDBGetShapes("ROUTE KEEPOUT")
					if(Redel_item_delete->prop->COMMENT == "custom_keepout" then		
						Redel_shp1 = car(axlDBAltOrigin('center Redel_item_delete))	
						Redel_shp2 = cadr(axlDBAltOrigin('center Redel_item_delete))
						Redel_shpdata = sprintf(nil "(%.1f %.1f)", Redel_shp1, Redel_shp2)				
							foreach(Redel_Input_Loop_del Input_drill_Top_Bot 
							foreach(DIA_STB_del DIA_STB_NZ
								DIA_STB_drill = nth(0 parseString(DIA_STB_del ","))
								Inp_drill = nth(1 parseString(Redel_Input_Loop_del ","))
								Redel_Input_Loop_del_x = atof(nth(2 parseString(Redel_Input_Loop_del ",")))
								Redel_Input_Loop_del_y = atof(nth(3 parseString(Redel_Input_Loop_del ",")))
								Redel_inpdata = sprintf(nil "(%.1f %.1f)", Redel_Input_Loop_del_x, Redel_Input_Loop_del_y)
								if(DIA_STB_drill == Inp_drill then 
									if(Redel_inpdata == Redel_shpdata then
											axlDBDeleteProp(Redel_item_delete '(FIXED))
											axlDeleteObject(Redel_item_delete)
											axlDBRefreshId(nil)
									)
								)
							)
							)
					)
				)
			 

			etchparam = axlGetParam("paramLayerGroup:ETCH")
			layers_RE = etchparam->groupMembers

			bot_layer_RE = nil
			bot_count_RE = 1
		
			foreach(botlyr_RE layers_RE
				bot_count_val_RE = bot_count_RE
					when(botlyr_RE push(botlyr_RE bot_layer_RE))
					bot_count_RE = bot_count_RE + 1
			)
		
			Dummy_dec_RE = 1
			foreach(unqCount_RE Unq_Drill_Input_Top_Bot
				Loop_dec_RE = Dummy_dec_RE
				Dummy_dec_RE = Dummy_dec_RE + 1
			)
			
			;This is the loop to create keepout for top and bottom individually
			Toplog = nil
			Botlog = nil
			foreach(DIA_STB_LOOP DIA_STB
			DIA_STB_PRSE = parseString(DIA_STB_LOOP ",")
				foreach(Top_chk_loopl_RE Toplist_Via_Pin
					Top_chk_loopl_RE_prse = nth(1 parseString(Top_chk_loopl_RE ","))
						if(Top_chk_loopl_RE_prse == nth(0 DIA_STB_PRSE) then
							xloc_RE = atof(nth(2 parseString(Top_chk_loopl_RE ",")))
							yloc_RE = atof(nth(3 parseString(Top_chk_loopl_RE ",")))	
							layer_crt_RE = atof(nth(0 parseString(Top_chk_loopl_RE ",")))
			
							Stublayer_RE = layer_crt_RE - atof(nth(2 DIA_STB_PRSE))
							countfinal_RE = 1												
							prog(()
								foreach(layer_loop_RE layers_RE
									if(countfinal_RE == Stublayer_RE + 1 then
										return()
									else
										countfinal_RE = countfinal_RE + 1
										rad_conv_RE = atof(nth(1 DIA_STB_PRSE)) / 2
										path_RE = axlPathStartCircle(list(xloc_RE:yloc_RE, rad_conv_RE) 0) 	
										c = sprintf(nil "%s%s", "Route Keepout/", layer_loop_RE)
										shape=axlDBCreateShape(path_RE t c)
										axlDBAddProp(car(shape) list('COMMENT "custom_keepout"))
										axlDBAddProp(car(shape) list('VIAS_ALLOWED))
										axlDBAddProp(car(shape) list('FIXED))
									)
								)
							)
						)
						TopLogdata = sprintf(nil "%L,%L,%L", nth(0 DIA_STB_PRSE), nth(1 DIA_STB_PRSE), nth(2 DIA_STB_PRSE))
						when(TopLogdata push(TopLogdata Toplog))
					)
	
				foreach(Bot_chk_loop_RE Botlist_Via_Pin
					Bot_chk_loop_RE_prse = nth(1 parseString(Bot_chk_loop_RE ","))
						if(Bot_chk_loop_RE_prse == nth(0 DIA_STB_PRSE) then
							xloc_RE = atof(nth(2 parseString(Bot_chk_loop_RE ",")))
							yloc_RE = atof(nth(3 parseString(Bot_chk_loop_RE ",")))	
							layer_crt_RE = atof(nth(0 parseString(Bot_chk_loop_RE ",")))
			
							Stublayercount_RE = bot_count_val_RE - layer_crt_RE 
							Stublayer_RE = Stublayercount_RE - atof(nth(2 DIA_STB_PRSE))
							countfinal_RE_bot = 1												
							prog(()
								foreach(layer_loop_bot_RE bot_layer_RE
									if(countfinal_RE_bot == Stublayer_RE + 2 then
										return()
									else
										countfinal_RE_bot = countfinal_RE_bot + 1
										rad_conv_bot_RE = atof(nth(1 DIA_STB_PRSE)) / 2
										path_bot_RE = axlPathStartCircle(list(xloc_RE:yloc_RE, rad_conv_bot_RE) 0) 	
										c_bot_RE = sprintf(nil "%s%s", "Route Keepout/", layer_loop_bot_RE)
										shape=axlDBCreateShape(path_bot_RE t c_bot_RE)
										axlDBAddProp(car(shape) list('COMMENT "custom_keepout"))
										axlDBAddProp(car(shape) list('VIAS_ALLOWED))
										axlDBAddProp(car(shape) list('FIXED))
									)
								)
							)
						)
						BopLogdata = sprintf(nil "%L,%L,%L", nth(0 DIA_STB_PRSE), nth(1 DIA_STB_PRSE), nth(2 DIA_STB_PRSE))
						when(BopLogdata push(BopLogdata Botlog))
				)

			)
			TopBotLog = nil
			TopBotLog = append(Toplog Botlog)
			TopBotLogUnq = nil
			TopBotLogUnq = unique(TopBotLog)
			
			loglistTB = outfile("Created-Keepout.txt")
			fprintf(loglistTB, "%s,%s,%s\n", "Drill-Value", "Diameter-Value", "Stub-value")
			foreach(TopBotLogUnq_lp TopBotLogUnq
				fprintf(loglistTB, "%s\n", TopBotLogUnq_lp) 
			)
			close(loglistTB)
			axlUIConfirm( "Keepouts Created Successfully..." )
			DIA_STB = nil
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
			
		else
			axlUIConfirm( "Please give the input some field is empty..." )
			DIA_STB = nil
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		)
		)
		
		
		
		;This case used to recreate every property added nets  
		("TORESELCREATE"
			foreach(Unq_Drill_Loop Unq_Drill_Input_Top_Bot
			when((axlFormGetField backform Unq_Drill_Loop)
				(BD_getval = (axlFormGetField backform Unq_Drill_Loop))
					stb_val = sprintf(nil "%s%s", Unq_Drill_Loop, "_STB")
					when((axlFormGetField backform stb_val)
						(BD_getval_STB = (axlFormGetField backform stb_val))
						DIA_STB_Val = sprintf(nil, "%s,%L,%L", Unq_Drill_Loop, BD_getval, BD_getval_STB)
						when(DIA_STB_Val push(DIA_STB_Val DIA_STB))
					)
				
				)
			)
			
			DIA_STB_NZ = nil
			foreach(DIA_STB_NZ_LP DIA_STB
				DIA_STB_D = nth(1 parseString(DIA_STB_NZ_LP ",")) 
					if(DIA_STB_D != "0.0" then
						when(DIA_STB_NZ_LP push(DIA_STB_NZ_LP DIA_STB_NZ))
					)
			)
			;print(DIA_STB_NZ)
			;This Loop is used to delete the keepout if already exists
			;foreach(item axlDBGetShapes("ROUTE KEEPOUT")
				;if(item->prop->COMMENT=="custom_keepout" then
					;axlDBDeleteProp(item '(FIXED))
					;axlDeleteObject(item)
					;axlDBRefreshId(nil)
				;)
			;)
			
			foreach(Redel_item_delete axlDBGetShapes("ROUTE KEEPOUT")
					if(Redel_item_delete->prop->COMMENT == "custom_keepout" then		
						Redel_shp1 = car(axlDBAltOrigin('center Redel_item_delete))	
						Redel_shp2 = cadr(axlDBAltOrigin('center Redel_item_delete))
						Redel_shpdata = sprintf(nil "(%.1f %.1f)", Redel_shp1, Redel_shp2)				
							foreach(Redel_Input_Loop_del Input_drill_Top_Bot 
							foreach(DIA_STB_del DIA_STB_NZ
								DIA_STB_drill = nth(0 parseString(DIA_STB_del ","))
								Inp_drill = nth(1 parseString(Redel_Input_Loop_del ","))
								Redel_Input_Loop_del_x = atof(nth(2 parseString(Redel_Input_Loop_del ",")))
								Redel_Input_Loop_del_y = atof(nth(3 parseString(Redel_Input_Loop_del ",")))
								Redel_inpdata = sprintf(nil "(%.1f %.1f)", Redel_Input_Loop_del_x, Redel_Input_Loop_del_y)
								if(DIA_STB_drill == Inp_drill then 
									if(Redel_inpdata == Redel_shpdata then
											axlDBDeleteProp(Redel_item_delete '(FIXED))
											axlDeleteObject(Redel_item_delete)
											axlDBRefreshId(nil)
									)
								)
							)
							)
					)
				)
			 

			etchparam = axlGetParam("paramLayerGroup:ETCH")
			layers_RE = etchparam->groupMembers

			bot_layer_RE = nil
			bot_count_RE = 1
		
			foreach(botlyr_RE layers_RE
				bot_count_val_RE = bot_count_RE
					when(botlyr_RE push(botlyr_RE bot_layer_RE))
					bot_count_RE = bot_count_RE + 1
			)
		
			Dummy_dec_RE = 1
			foreach(unqCount_RE Unq_Drill_Input_Top_Bot
				Loop_dec_RE = Dummy_dec_RE
				Dummy_dec_RE = Dummy_dec_RE + 1
			)
			
			;This is the loop to create keepout for top and bottom individually
			Toplog = nil
			Botlog = nil
			foreach(DIA_STB_LOOP DIA_STB
			DIA_STB_PRSE = parseString(DIA_STB_LOOP ",")
				foreach(Top_chk_loopl_RE Toplist_Via_Pin
					Top_chk_loopl_RE_prse = nth(1 parseString(Top_chk_loopl_RE ","))
						if(Top_chk_loopl_RE_prse == nth(0 DIA_STB_PRSE) then
							xloc_RE = atof(nth(2 parseString(Top_chk_loopl_RE ",")))
							yloc_RE = atof(nth(3 parseString(Top_chk_loopl_RE ",")))	
							layer_crt_RE = atof(nth(0 parseString(Top_chk_loopl_RE ",")))
			
							Stublayer_RE = layer_crt_RE - atof(nth(2 DIA_STB_PRSE))
							countfinal_RE = 1												
							prog(()
								foreach(layer_loop_RE layers_RE
									if(countfinal_RE == Stublayer_RE + 1 then
										return()
									else
										countfinal_RE = countfinal_RE + 1
										rad_conv_RE = atof(nth(1 DIA_STB_PRSE)) / 2
										path_RE = axlPathStartCircle(list(xloc_RE:yloc_RE, rad_conv_RE) 0) 	
										c = sprintf(nil "%s%s", "Route Keepout/", layer_loop_RE)
										shape=axlDBCreateShape(path_RE t c)
										axlDBAddProp(car(shape) list('COMMENT "custom_keepout"))
										axlDBAddProp(car(shape) list('VIAS_ALLOWED))
										axlDBAddProp(car(shape) list('FIXED))
									)
								)
							)
						)
						TopLogdata = sprintf(nil "%L,%L,%L", nth(0 DIA_STB_PRSE), nth(1 DIA_STB_PRSE), nth(2 DIA_STB_PRSE))
						when(TopLogdata push(TopLogdata Toplog))
					)
	
				foreach(Bot_chk_loop_RE Botlist_Via_Pin
					Bot_chk_loop_RE_prse = nth(1 parseString(Bot_chk_loop_RE ","))
						if(Bot_chk_loop_RE_prse == nth(0 DIA_STB_PRSE) then
							xloc_RE = atof(nth(2 parseString(Bot_chk_loop_RE ",")))
							yloc_RE = atof(nth(3 parseString(Bot_chk_loop_RE ",")))	
							layer_crt_RE = atof(nth(0 parseString(Bot_chk_loop_RE ",")))
			
							Stublayercount_RE = bot_count_val_RE - layer_crt_RE 
							Stublayer_RE = Stublayercount_RE - atof(nth(2 DIA_STB_PRSE))
							countfinal_RE_bot = 1												
							prog(()
								foreach(layer_loop_bot_RE bot_layer_RE
									if(countfinal_RE_bot == Stublayer_RE + 2 then
										return()
									else
										countfinal_RE_bot = countfinal_RE_bot + 1
										rad_conv_bot_RE = atof(nth(1 DIA_STB_PRSE)) / 2
										path_bot_RE = axlPathStartCircle(list(xloc_RE:yloc_RE, rad_conv_bot_RE) 0) 	
										c_bot_RE = sprintf(nil "%s%s", "Route Keepout/", layer_loop_bot_RE)
										shape=axlDBCreateShape(path_bot_RE t c_bot_RE)
										axlDBAddProp(car(shape) list('COMMENT "custom_keepout"))
										axlDBAddProp(car(shape) list('VIAS_ALLOWED))
										axlDBAddProp(car(shape) list('FIXED))
									)
								)
							)
						)
						BopLogdata = sprintf(nil "%L,%L,%L", nth(0 DIA_STB_PRSE), nth(1 DIA_STB_PRSE), nth(2 DIA_STB_PRSE))
						when(BopLogdata push(BopLogdata Botlog))
				)

			)
			TopBotLog = nil
			TopBotLog = append(Toplog Botlog)
			TopBotLogUnq = nil
			TopBotLogUnq = unique(TopBotLog)
			
			loglistTB = outfile("Created-Keepout.txt")
			fprintf(loglistTB, "%s,%s,%s\n", "Drill-Value", "Diameter-Value", "Stub-value")
			foreach(TopBotLogUnq_lp TopBotLogUnq
				fprintf(loglistTB, "%s\n", TopBotLogUnq_lp) 
			)
			close(loglistTB)
			axlUIConfirm( "Keepouts Created Successfully..." )
			DIA_STB = nil
			axlFormClose(backform)	
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		)
		
		;This is separate option to delete keepout
		("TODELETE"
			axlUIConfirm( "Please Confirm To Delete the Keepouts..." )
			foreach(item axlDBGetShapes("ROUTE KEEPOUT")
				if(item->prop->COMMENT=="custom_keepout" then
					axlDBDeleteProp(item '(FIXED))
					axlDeleteObject(item)
					axlDBRefreshId(nil)
				)
			)
			axlFormClose(backform)
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		)
		("TOSELDELETE"
				inp_delete = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
				fileparts_delete = axlDMFileParts(inp_delete)
				inpnetname_delete = nil
				Backdrill_inp_delete = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts_delete) "r")
				Backdrill_netname_delete = nil
					if(Backdrill_inp_delete != nil then
						while(gets(BD_inp_delete Backdrill_inp_delete)
							BD_inp_delete = car(parseString(BD_inp_delete "\n"))
							when(BD_inp_delete push(BD_inp_delete Backdrill_netname_delete))
						)
				axlDMClose(Backdrill_inp_delete)
		
				Backdrill_netname_delete_unq = nil
				Backdrill_netname_delete_unq = unique(Backdrill_netname_delete)
		
				Del_list_sel_delete = nil
				foreach(Input_drill_Top_Bot_delSel_delete Input_drill_Top_Bot
					Input_drill_Top_Bot_del_prse_delete = nth(4 parseString(Input_drill_Top_Bot_delSel_delete ","))
						foreach(Backdrill_netname_delete_unq_net Backdrill_netname_delete_unq
							if(Backdrill_netname_delete_unq_net == Input_drill_Top_Bot_del_prse_delete then
								when(Input_drill_Top_Bot_delSel_delete push(Input_drill_Top_Bot_delSel_delete Del_list_sel_delete))
							)
						)
				)
		
				foreach(Redel_item_delete axlDBGetShapes("ROUTE KEEPOUT")
					if(Redel_item_delete->prop->COMMENT == "custom_keepout" then		
						Redel_shp1 = car(axlDBAltOrigin('center Redel_item_delete))	
						Redel_shp2 = cadr(axlDBAltOrigin('center Redel_item_delete))
						Redel_shpdata = sprintf(nil "(%.1f %.1f)", Redel_shp1, Redel_shp2)				
							foreach(Redel_Input_Loop_del Del_list_sel_delete 
								Redel_Input_Loop_del_x = atof(nth(2 parseString(Redel_Input_Loop_del ",")))
								Redel_Input_Loop_del_y = atof(nth(3 parseString(Redel_Input_Loop_del ",")))
								Redel_inpdata = sprintf(nil "(%.1f %.1f)", Redel_Input_Loop_del_x, Redel_Input_Loop_del_y)
									if(Redel_inpdata == Redel_shpdata then
										axlDBDeleteProp(Redel_item_delete '(FIXED))
										axlDeleteObject(Redel_item_delete)
										axlDBRefreshId(nil)
									)
							)
					)
				)
			axlFormClose(backform)
			shell("rm -f back.form")
			nil
			inputlist()
			createbackform()
			backform()
		else 
			axlUIConfirm( "File is Empty..." )
		)
		)
		
		;Use to Close the UI
		("TOCLOSE"
			axlFormClose(backform)
			shell("rm -f back.form")
			nil
		)
	
	
	
	)
	axlFormDisplay(backform)
)

;This is same loop to create keepout by selected net names.
(defun create_inp ()

	foreach(Unq_Drill_Loop Unq_Drill_Input_Top_Bot
			when((axlFormGetField backform Unq_Drill_Loop)
				(BD_getval = (axlFormGetField backform Unq_Drill_Loop))
					stb_val = sprintf(nil "%s%s", Unq_Drill_Loop, "_STB")
					when((axlFormGetField backform stb_val)
						(BD_getval_STB = (axlFormGetField backform stb_val))
						DIA_STB_Val = sprintf(nil, "%s,%L,%L", Unq_Drill_Loop, BD_getval, BD_getval_STB)
						when(DIA_STB_Val push(DIA_STB_Val DIA_STB))
					)
				
				)
			)
			
		inp = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
		fileparts = axlDMFileParts(inp)
		inpnetname = nil
		Backdrill_inp = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts) "r")
		Backdrill_netname = nil
		if(Backdrill_inp != nil then
				while(gets(BD_inp Backdrill_inp)
					BD_inp = car(parseString(BD_inp "\n"))
					when(BD_inp push(BD_inp Backdrill_netname))
				)
		axlDMClose(Backdrill_inp)
		
		Backdrill_netname_unq = nil
		Backdrill_netname_unq = unique(Backdrill_netname)
		
		Del_list_sel = nil
		foreach(Input_drill_Top_Bot_delSel Input_drill_Top_Bot
			Input_drill_Top_Bot_del_prse = nth(4 parseString(Input_drill_Top_Bot_delSel ","))
			foreach(Backdrill_netname_unq_net Backdrill_netname_unq
				if(Backdrill_netname_unq_net == Input_drill_Top_Bot_del_prse then
					when(Input_drill_Top_Bot_delSel push(Input_drill_Top_Bot_delSel Del_list_sel))
				)
			)
		)
		
		foreach(Redel_item axlDBGetShapes("ROUTE KEEPOUT")
					if(Redel_item->prop->COMMENT == "custom_keepout" then		
						Redel_shp1 = car(axlDBAltOrigin('center Redel_item))	
						Redel_shp2 = cadr(axlDBAltOrigin('center Redel_item))
						Redel_shpdata = sprintf(nil "(%.1f %.1f)", Redel_shp1, Redel_shp2)				
							foreach(Redel_Input_Loop_del Del_list_sel 
								Redel_Input_Loop_del_x = atof(nth(2 parseString(Redel_Input_Loop_del ",")))
								Redel_Input_Loop_del_y = atof(nth(3 parseString(Redel_Input_Loop_del ",")))
								Redel_inpdata = sprintf(nil "(%.1f %.1f)", Redel_Input_Loop_del_x, Redel_Input_Loop_del_y)
									if(Redel_inpdata == Redel_shpdata then
										axlDBDeleteProp(Redel_item '(FIXED))
										axlDeleteObject(Redel_item)
										axlDBRefreshId(nil)
									)
							)
					)
				)
				
		
	    

		etchparam = axlGetParam("paramLayerGroup:ETCH")
		layers = etchparam->groupMembers

		bot_layer = nil
		bot_count = 1
		
		foreach(botlyr layers
			bot_count_val = bot_count
				when(botlyr push(botlyr bot_layer))
				bot_count = bot_count + 1
		)
		
		Dummy_dec = 1
		foreach(unqCount Unq_Drill_Input_Top_Bot
			Loop_dec = Dummy_dec
			Dummy_dec = Dummy_dec + 1
		)
		
		foreach(DIA_STB_LOOP_SEL DIA_STB
		DIA_STB_PRSE_SEL = parseString(DIA_STB_LOOP_SEL ",") 
			foreach(Top_chk_loop Toplist_Via_Pin
			Top_chk_loop_prse_net = nth(4 parseString(Top_chk_loop ","))
			foreach(Backdrill_netname_lp Backdrill_netname_unq
			if(Backdrill_netname_lp == Top_chk_loop_prse_net then
				Top_chk_loop_prse = nth(1 parseString(Top_chk_loop ","))
				if(Top_chk_loop_prse == nth(0 DIA_STB_PRSE_SEL) then
					xloc = atof(nth(2 parseString(Top_chk_loop ",")))
					yloc = atof(nth(3 parseString(Top_chk_loop ",")))	
					layer_crt = atof(nth(0 parseString(Top_chk_loop ",")))
			
					Stublayer = layer_crt - atof(nth(2 DIA_STB_PRSE_SEL))
					countfinal = 1												
					prog(()
						foreach(layer_loop layers
							if(countfinal == Stublayer + 1 then
								return()
							else
								countfinal = countfinal + 1
								rad_conv = atof(nth(1 DIA_STB_PRSE_SEL)) / 2
								path = axlPathStartCircle(list(xloc:yloc, rad_conv) 0) 	
								c = sprintf(nil "%s%s", "Route Keepout/", layer_loop)
								shape=axlDBCreateShape(path t c)
								axlDBAddProp(car(shape) list('COMMENT "custom_keepout"))
								axlDBAddProp(car(shape) list('VIAS_ALLOWED))
								axlDBAddProp(car(shape) list('FIXED))
							)
						)
					)
				)
				)))
	
		foreach(Bot_chk_loop Botlist_Via_Pin
		Bot_chk_loop_prse_net = nth(4 parseString(Bot_chk_loop ","))
		foreach(Backdrill_netname_lp_bot Backdrill_netname_unq
		if(Backdrill_netname_lp_bot == Bot_chk_loop_prse_net then 
			Bot_chk_loop_prse = nth(1 parseString(Bot_chk_loop ","))
			if(Bot_chk_loop_prse == nth(0 DIA_STB_PRSE_SEL) then
				xloc = atof(nth(2 parseString(Bot_chk_loop ",")))
				yloc = atof(nth(3 parseString(Bot_chk_loop ",")))	
				layer_crt = atof(nth(0 parseString(Bot_chk_loop ",")))
			
				Stublayercount = bot_count_val - layer_crt 
				Stublayer = Stublayercount - atof(nth(2 DIA_STB_PRSE_SEL))
				countfinal_bot = 1												
				prog(()
				foreach(layer_loop_bot bot_layer
					if(countfinal_bot == Stublayer + 2 then
						return()
					else
						countfinal_bot = countfinal_bot + 1
						rad_conv_bot = atof(nth(1 DIA_STB_PRSE_SEL)) / 2
						path_bot = axlPathStartCircle(list(xloc:yloc, rad_conv_bot) 0) 	
						c_bot = sprintf(nil "%s%s", "Route Keepout/", layer_loop_bot)
						shape=axlDBCreateShape(path_bot t c_bot)
						axlDBAddProp(car(shape) list('COMMENT "custom_keepout"))
						axlDBAddProp(car(shape) list('VIAS_ALLOWED))
						axlDBAddProp(car(shape) list('FIXED))
					)
				)
				)
			)
		)))

	)
	;else
		;axlUIConfirm( "backdrill.lst Input file Missing...!" )
	)

)

;This is another UI form file for checking
(defun backdrill_chk ()
	axlUIConfirm( "Before you run the code please make sure that all the Electrical Layers and Route keepout should want to be Enable..!" )
	inputlist()
	createbackform_chk()
	backform_chk()
)

(defun backform_chk () 
	backform_chk=axlFormCreate( (gensym) backform_chk_file nil 'back_Action_chk t)
	axlFormDisplay(backform_chk)
)

(defun createbackform_chk ()

drain()
backform_chk_file = "back_chk.form"
backform_chk = outfile(backform_chk_file "w")

fprintf(backform_chk "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(backform_chk "FORM\n")
fprintf(backform_chk "FIXED\n")
fprintf(backform_chk "PORT 42 10\n")

fprintf(backform_chk "HEADER \"Back Drill Checking\"\n")
fprintf(backform_chk "\n")
fprintf(backform_chk "TILE\n")


fprintf(backform_chk "FIELD CHKPROP\n")
fprintf(backform_chk "FLOC 1 1\n")
fprintf(backform_chk "MENUBUTTON \"Prop Check\" 10 4\n")
fprintf(backform_chk "ENDFIELD\n")
fprintf(backform_chk "\n")

fprintf(backform_chk "FIELD LOCCHK\n")
fprintf(backform_chk "FLOC 15 1\n")
fprintf(backform_chk "MENUBUTTON \"KO-Check\" 10 4\n")
fprintf(backform_chk "ENDFIELD\n")
fprintf(backform_chk "\n")

fprintf(backform_chk "FIELD SYMCHK\n")
fprintf(backform_chk "FLOC 30 1\n")
fprintf(backform_chk "MENUBUTTON \"Sym-Report\" 10 4\n")
fprintf(backform_chk "ENDFIELD\n")
fprintf(backform_chk "\n")

fprintf(backform_chk "FIELD TOCLOSE\n")
fprintf(backform_chk "FLOC 15 5\n")
fprintf(backform_chk "MENUBUTTON \"Close\" 10 4\n")
fprintf(backform_chk "ENDFIELD\n")
fprintf(backform_chk "\n")

fprintf(backform_chk "TEXT \"Drill Size\"\n")
fprintf(backform_chk "TLOC 5 10\n")
fprintf(backform_chk "ENDTEXT\n")

fprintf(backform_chk "TEXT \"Keepout Dia\"\n")
fprintf(backform_chk "TLOC 15 10\n")
fprintf(backform_chk "ENDTEXT\n")

fprintf(backform_chk "TEXT \"Stub Layers\"\n")
fprintf(backform_chk "TLOC 25 10\n")
fprintf(backform_chk "ENDTEXT\n")

datainp_chk = 15
foreach(listlp_chk Unq_Drill_Input_Top_Bot 
adata_chk = sprintf(nil, "TEXT \"%s\"\n", listlp_chk) 
fprintf(backform_chk adata_chk)
adt_chk = sprintf(nil, "TLOC 5 %d\n", datainp_chk)
fprintf(backform_chk adt_chk)
datainp_chk = datainp_chk + 5
fprintf(backform_chk "ENDTEXT\n")
)

datainp_chk1 = 15
foreach(listlp_chk2 Unq_Drill_Input_Top_Bot
fprintf(backform_chk "FIELD %s\n", listlp_chk2)
adt1_chk = sprintf(nil, "FLOC 15 %d\n", datainp_chk1)
fprintf(backform_chk adt1_chk)
fprintf(backform_chk "REALFILLIN 5 5\n")
fprintf(backform_chk "REALMIN 1.0\n")
fprintf(backform_chk "REALMAX 1000.000000\n")
fprintf(backform_chk "ENDFIELD\n")
fprintf(backform_chk "\n")
datainp_chk1 = datainp_chk1 + 5
)

datainp_chk2 = 15
foreach(listlp_chk3 Unq_Drill_Input_Top_Bot
fprintf(backform_chk "FIELD %s%s\n", listlp_chk3, "_STB")
adt2_chk = sprintf(nil, "FLOC 25 %d\n", datainp_chk2)
fprintf(backform_chk adt2_chk)
fprintf(backform_chk "INTSLIDEBAR 3 3\n MIN 0\n MAX 5\n")
fprintf(backform_chk "ENDFIELD\n")
fprintf(backform_chk "\n")
datainp_chk2 = datainp_chk2 + 5
)

fprintf(backform_chk "\n")
fprintf(backform_chk "ENDTILE\n")
fprintf(backform_chk "\n")
fprintf(backform_chk "ENDFORM\n")
close(backform_chk)
)
;DiaData_chk = nil
;StubData_chk = nil
DIA_STB_CHK = nil
(defun back_Action_chk (backform_chk)
	(case backform_chk->curField
	
		;("DIA_chk" DiaVal_chk = backform_chk->curValue
			;when(DiaVal_chk push(DiaVal_chk DiaData_chk))
		;)
	
		;("STUB_chk" StubVal_chk = backform_chk->curValue
			;when(StubVal_chk push(StubVal_chk StubData_chk))
		;)
		;This Is used to check the property added in the given net list and error Shown in log file
		("CHKPROP"
			inp_prop = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
			fileparts_prop = axlDMFileParts(inp_prop)
			propinp = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts_prop) "r")
			if(propinp != nil then
				propinp_netname = nil
					while(gets(p_inp propinp)
						p_inp = car(parseString(p_inp "\n"))
						when(p_inp push(p_inp propinp_netname))
					)
			axlDMClose(propinp)
			propinp_netname_unq = nil
			propinp_netname_unq = unique(propinp_netname)
		
			proplist = nil
			proplistNet = nil
				foreach(proplp axlDBGetDesign() ->nets
					proplpname = proplp ->name 
						;foreach(propinp_netname_unq_lp propinp_netname_unq  
							;if(propinp_netname_unq_lp == proplpname then 
								proplist=axlDBGetProperties(proplp)
									foreach(proplistlp_chk proplist
										proplistlp_chkprse = car(proplistlp_chk)
											propliststr = sprintf(nil, "%s", proplistlp_chkprse)
												if(propliststr == "BACKDRILL_MAX_PTH_STUB" then
													when(proplpname push(proplpname proplistNet))
												)
									)
							;)
						;)
				)

			NonPropNet = nil
			NonPropNet = setof(item, propinp_netname_unq, !member(item, proplistNet))
			
			AddPropNet = nil
			AddPropNet = setof(item1, proplistNet, !member(item1, propinp_netname_unq)) 
			
			NonPropNetError = nil
			foreach(NonPropNetlp NonPropNet
				NonPropNetlp_data = sprintf(nil "%s,%s", NonPropNetlp, "Property - Missing")
					when(NonPropNetlp_data push(NonPropNetlp_data NonPropNetError))
			)
			
			AddPropNetError = nil
			foreach(AddPropNetlp AddPropNet
				AddPropNetlp_data = sprintf(nil "%s,%s", AddPropNetlp, "Addional Property Added")
					when(AddPropNetlp_data push(AddPropNetlp_data AddPropNetError))
			)
			
			PropNetError = nil
			PropNetError = append(NonPropNetError AddPropNetError)
			
			if(PropNetError !=  nil then
				logfileprop = "Prop-Missing.log"
				originalVisible=axlVisibleGet()
				designName = axlCurrentDesign()
				design_path = axlGetDrawingName()
				design_unit = car(axlDBGetDesignUnits())
				axlVisibleDesign(t)
				port = axlDMOpenLog(logfileprop)
				fprintf(port, "Design name: %s\n", design_path)
				fprintf(port, "%s\n", "------------------------------------------------")
				fprintf(port, "%-32s %-32s \n", "NET NAME", "ERROR MESSAGE")
				foreach(finalphaselp PropNetError
					finalphaselpprse = parseString(finalphaselp ",") 
					fprintf(port, "%-32s %-32s\n", nth(0 finalphaselpprse), nth(1 finalphaselpprse)) 
				)
				axlDMClose(port)
				axlVisibleSet(originalVisible)
				axlUIViewFileCreate(logfileprop, "Prop-Missing", nil, '(30 25), '(CENTER))
			else
				axlUIConfirm( "No error.. Back drill property added for all nets..." )
			)
		else
			axlUIConfirm( "Selected file is empty please add the Netname to check the Property..." )
		)
		axlFormClose(backform_chk)
		shell("rm -f back_chk.form")
		nil
		inputlist()
		createbackform_chk()
		backform_chk()
		)
		
		;This is used to check the Location of keepout and Radius Value is correct or not
		;From the user in UI Collects the inputs and checks the brd file 
		("LOCCHK"
		
			
			foreach(Unq_Drill_Loop_chk Unq_Drill_Input_Top_Bot
			when((axlFormGetField backform_chk Unq_Drill_Loop_chk)
				(BD_getval_chk = (axlFormGetField backform_chk Unq_Drill_Loop_chk))
					stb_vall_chk = sprintf(nil "%s%s", Unq_Drill_Loop_chk, "_STB")
					when((axlFormGetField backform_chk stb_vall_chk)
						(BD_getval_chk_STB = (axlFormGetField backform_chk stb_vall_chk))
						DIA_stb_vall_chk = sprintf(nil, "%s,%L,%L", Unq_Drill_Loop_chk, BD_getval_chk, BD_getval_chk_STB)
						when(DIA_stb_vall_chk push(DIA_stb_vall_chk DIA_STB_CHK))
					)
				
				)
			)
			
			Run_List = nil
			foreach(DIA_STB_CHK_nonZ DIA_STB_CHK
				DIA_STB_CHK_PRSE = nth(1 parseString(DIA_STB_CHK_nonZ ","))
				if(DIA_STB_CHK_PRSE == "0.0" then 
					axlUIConfirm( "Field is Empty please fill the keepout value..." )
				)
			)
			
			inputlist()
			ShapeLoc = nil
			ShapeFrst = nil
				foreach(item axlDBGetShapes("ROUTE KEEPOUT")
					if(item->prop->COMMENT == "custom_keepout" then
						shp1 = car(axlDBAltOrigin('center item))
						shp2 = cadr(axlDBAltOrigin('center item))
							foreach(el setof(element item->segments element->xy != nil)
								radval = el->radius
							)
							shpdata = sprintf(nil "%s(%.1f %.1f),%.1f", item->layer, shp1, shp2, radval)
							shp_frst = sprintf(nil "%s(%.1f %.1f)", item->layer, shp1, shp2)
								when(shp_frst push(shp_frst ShapeFrst))
								when(shpdata push(shpdata ShapeLoc))		
					)
				)
	
			;dia_chkv_chk = nil	
			;foreach(Loop_dia_chkv_chk DiaData_chk
				;when(Loop_dia_chkv_chk push(Loop_dia_chkv_chk dia_chkv_chk))
			;)

			;stub_chkv_chk = nil 
			;foreach(Loop_stub_chkv_chk StubData_chk
				;when(Loop_stub_chkv_chk push(Loop_stub_chkv_chk stub_chkv_chk))
			;)
		
			;Collected_input_chk = listToVector(Unq_Drill_Input_Top_Bot) 
			;User_input_chk = listToVector(dia_chkv_chk)
			;Stub_input_chk = listToVector(stub_chkv_chk) 

			etchparam = axlGetParam("paramLayerGroup:ETCH")
			layers_chk = etchparam->groupMembers

			bot_layer_chk = nil
			bot_count_chk = 1
		
			foreach(botlyr_chk layers_chk
				bot_count_val_chk = bot_count_chk
					when(botlyr_chk push(botlyr_chk bot_layer_chk))
					bot_count_chk = bot_count_chk + 1
			)
		
			;Dummy_dec_chk = 1
			;foreach(unqCount_chk Unq_Drill_Input_Top_Bot
				;Loop_dec_chk = Dummy_dec_chk
				;Dummy_dec_chk = Dummy_dec_chk + 1
			;)
		
			Loc_Data_Top = nil
			Loc_Data_Bottom = nil
				foreach(pass_val_chk DIA_STB_CHK
					foreach(Top_chk_loopl_chk Toplist_Via_Pin
						Top_chk_loopl_chk_prse = nth(1 parseString(Top_chk_loopl_chk ","))
						
							if(Top_chk_loopl_chk_prse == nth(0 parseString(pass_val_chk ",")) then
								xloc_chk = atof(nth(2 parseString(Top_chk_loopl_chk ",")))
								yloc_chk = atof(nth(3 parseString(Top_chk_loopl_chk ",")))	
								layer_crt_chk = atof(nth(0 parseString(Top_chk_loopl_chk ",")))
								Top_chk_loopl_chk_net = nth(4 parseString(Top_chk_loopl_chk ","))
								Stublayer_chk = layer_crt_chk - atof(nth(2 parseString(pass_val_chk ",")))
								countfinal_chk = 1
								
								prog(()
									foreach(layer_loop_chk layers_chk
										if(countfinal_chk == Stublayer_chk + 1 then
											return()
										else
											countfinal_chk = countfinal_chk + 1
											rad_conv_chk = atof(nth(1 parseString(pass_val_chk ","))) / 2
											Loc_Data_Top_str = sprintf(nil "%s%s(%.1f %.1f),%.1f,%s", "ROUTE KEEPOUT/", layer_loop_chk, xloc_chk, yloc_chk, rad_conv_chk, Top_chk_loopl_chk_net)
											when(Loc_Data_Top_str push(Loc_Data_Top_str Loc_Data_Top))
										)
									)
								)
							)
						)
	
					foreach(Bot_chk_loop_chk Botlist_Via_Pin
						Bot_chk_loop_chk_prse = nth(1 parseString(Bot_chk_loop_chk ","))
							if(Bot_chk_loop_chk_prse == nth(0 parseString(pass_val_chk ",")) then
								xloc_chk_bot = atof(nth(2 parseString(Bot_chk_loop_chk ",")))
								yloc_chk_bot = atof(nth(3 parseString(Bot_chk_loop_chk ",")))	
								layer_crt_chk_bot = atof(nth(0 parseString(Bot_chk_loop_chk ",")))
								Bot_chk_loop_chk_net = nth(4 parseString(Bot_chk_loop_chk ","))
								Stublayercount_chk = bot_count_val_chk - layer_crt_chk_bot 
								Stublayer_chk = Stublayercount_chk - atof(nth(2 parseString(pass_val_chk ",")))
								countfinal_chk_bot = 1		
								
								prog(()
									foreach(layer_loop_bot_chk bot_layer_chk
										if(countfinal_chk_bot == Stublayer_chk + 2 then
											return()
										else
											countfinal_chk_bot = countfinal_chk_bot + 1
											rad_conv_bot_chk = atof(nth(1 parseString(pass_val_chk ","))) / 2
											Loc_Data_Bot_str = sprintf(nil "%s%s(%.1f %.1f),%.1f,%s", "ROUTE KEEPOUT/", layer_loop_bot_chk, xloc_chk_bot, yloc_chk_bot, rad_conv_bot_chk, Bot_chk_loop_chk_net)
											when(Loc_Data_Bot_str push(Loc_Data_Bot_str Loc_Data_Bottom))
										)
									)
								)
							)
					)

				)
		
				Loc_Data_Top_Bottom = nil
				Loc_Data_Top_Bottom = append(Loc_Data_Top Loc_Data_Bottom)
	
				localone = nil
				foreach(Loc_Data_Top_Bottom_0th Loc_Data_Top_Bottom
					Loc_Data_Top_Bottom_0th_prse = nth(0 parseString(Loc_Data_Top_Bottom_0th ","))
					when(Loc_Data_Top_Bottom_0th_prse push(Loc_Data_Top_Bottom_0th_prse localone))
				)
	
				Loc_data_list = nil
				Loc_Data_Top_Bottom_Rad = nil
				foreach(Loc_Data_Top_Bottom_Rad_lp Loc_Data_Top_Bottom
					Loc_Data_Top_Bottom_Rad_prse = parseString(Loc_Data_Top_Bottom_Rad_lp ",")
						foreach(ShapeLoc_Rad ShapeLoc
							ShapeLoc_Rad_prse = parseString(ShapeLoc_Rad ",")
								if(nth(0 ShapeLoc_Rad_prse) == nth(0 Loc_Data_Top_Bottom_Rad_prse) then 
									when(nth(0 Loc_Data_Top_Bottom_Rad_prse) push(nth(0 Loc_Data_Top_Bottom_Rad_prse) Loc_data_list))
										if(nth(1 ShapeLoc_Rad_prse) == nth(1 Loc_Data_Top_Bottom_Rad_prse) then
											when(nth(0 Loc_Data_Top_Bottom_Rad_prse) push(nth(0 Loc_Data_Top_Bottom_Rad_prse) Loc_Data_Top_Bottom_Rad))
										)
								)
						)
				)
	
				RadMissing = nil
				RadMissing = setof(Rad, localone, !member(Rad, Loc_Data_Top_Bottom_Rad))
	
				LocMissing = nil
				LocMissing = setof(Loc, localone, !member(Loc, Loc_data_list))
				
				LocMissing_shp = nil
				LocMissing_shp = setof(Loc1, ShapeFrst, !member(Loc1, Loc_data_list))
				
				RadMissing_alone = nil
				RadMissing_alone = setof(Rad_a, RadMissing, !member(Rad_a, LocMissing))
	
				Rad_list = nil
	
				foreach(RadMissinglp RadMissing_alone
					foreach(Loc_Data_Top_Bottom_Radlp Loc_Data_Top_Bottom
						Loc_Data_Top_Bottom_Radprse = parseString(Loc_Data_Top_Bottom_Radlp ",")
							if(RadMissinglp == nth(0 Loc_Data_Top_Bottom_Radprse) then
								foreach(ShapeLoc_lp ShapeLoc
									ShapeLoc_Radprse = parseString(ShapeLoc_lp ",")
										if(RadMissinglp == nth(0 ShapeLoc_Radprse) then
											Rad_data = sprintf(nil, "%s,%s,%s,%s", nth(0 Loc_Data_Top_Bottom_Radprse), nth(1 Loc_Data_Top_Bottom_Radprse), nth(1 ShapeLoc_Radprse), nth(2 Loc_Data_Top_Bottom_Radprse))											
											when(Rad_data push(Rad_data Rad_list))
											
										)
								)
							)
						)
				)
				
				Net_Rad = nil
				FinalErrorRad = nil
				foreach(RadMissinglp Rad_list
					finalphaselpprse = parseString(RadMissinglp ",")
					Frst_dt = atof(nth(1 finalphaselpprse)) * 2
					Frst_dt_str = sprintf(nil "%L", Frst_dt) 
					Sec_dt = atof(nth(2 finalphaselpprse)) * 2
					Sec_dt_str = sprintf(nil "%L", Sec_dt) 
					RadMissinglp_str = sprintf(nil "%-40s %-40s %-16s %-16s %-16s", nth(0 finalphaselpprse), , "Error - Radius Mismatch", Frst_dt_str, Sec_dt_str, nth(3 finalphaselpprse))
					Rad_Missing_Frst = sprintf(nil "%s", nth(3 finalphaselpprse))
					when(Rad_Missing_Frst push(Rad_Missing_Frst Net_Rad))
					when(RadMissinglp_str push(RadMissinglp_str FinalErrorRad))	
				)
				
				Net_Loc = nil
				FinalErrorLoc = nil
				foreach(LocMissing_lp LocMissing
					foreach(Loc_Data_Top_Bottom_LocMissing Loc_Data_Top_Bottom
						Loc_Data_Top_Bottom_LCprse = parseString(Loc_Data_Top_Bottom_LocMissing ",")
							if(nth(0 Loc_Data_Top_Bottom_LCprse) == LocMissing_lp then 
								LocMissing_str = sprintf(nil "%-40s %-40s %-16s %-16s %-16s", LocMissing_lp, "Error - Shape Offset or Missing", "Nil", "Nil", nth(2 Loc_Data_Top_Bottom_LCprse))
								Loc_Missing_Frst = sprintf(nil "%s", nth(2 Loc_Data_Top_Bottom_LCprse)) 
								when(LocMissing_str push(LocMissing_str FinalErrorLoc))
								when(Loc_Missing_Frst push(Loc_Missing_Frst Net_Loc))
							)
					)
				)
				
				LocMissing_shp_ex = nil
				foreach(LocMissing_shp_lp LocMissing_shp
					LocMissing_shp_str = sprintf(nil "%-40s %-40s %-16s %-16s %-16s", LocMissing_shp_lp, "Error - Additonal Shape Added", "Nil", "Nil", "Nil")
					when(LocMissing_shp_str push(LocMissing_shp_str LocMissing_shp_ex))
				)
	
				FinalError_app = nil
				FinalError_app = append(FinalErrorLoc FinalErrorRad) 
				
				FinalError_app_shp = nil
				FinalError_app_shp = append(LocMissing_shp_ex FinalError_app) 
				
				FinalErrorLocunq = nil
				FinalErrorLocunq = unique(FinalError_app_shp)
				
				outFinalErrorLoc = nil
				outFinalErrorLoc = append(Net_Loc Net_Rad) 
				
				outFinalErrorLoc_unq = nil
				outFinalErrorLoc_unq = unique(outFinalErrorLoc)
				
				out = outfile("Error-Net_List.txt")
				foreach(outFinalErrorLoc_unq_loop outFinalErrorLoc_unq
					fprintf(out, "%s\n", outFinalErrorLoc_unq_loop) 
				)
				close(out)
				
				if(FinalErrorLocunq !=  nil then
					logfileLoc = "Loc-Missing.log"
					originalVisible_loc=axlVisibleGet()
					designName_loc = axlCurrentDesign()
					design_path_loc = axlGetDrawingName()
					design_unit_loc = car(axlDBGetDesignUnits())
					axlVisibleDesign(t)
					portLoc = axlDMOpenLog(logfileLoc)
					fprintf(portLoc, "Design name: %s\n", design_path_loc)
					fprintf(portLoc, "%s\n", "------------------------------------------------")
					fprintf(portLoc, "%-40s %-40s %-16s %-16s %-16s\n", "LAYER/LOCATION", "ERROR MESSAGE", "REQURIED VALUE", "ACTUAL VALUE", "NET NAME")
						foreach(finalphaselp FinalErrorLocunq
							;finalphaselpprse = parseString(finalphaselp ",") 
							fprintf(portLoc, "%s\n", finalphaselp) 
						)
					axlDMClose(portLoc)
					axlVisibleSet(originalVisible_loc)
					axlUIViewFileCreate(logfileLoc, "Loc-Missing", nil, '(30 25), '(CENTER))
				else
					axlUIConfirm( "No Error -- Shape Created Perfectly.." )
				)
	
				;DiaData_chk = nil
				;StubData_chk = nil
				DIA_STB_CHK = nil
				axlFormClose(backform_chk)
				shell("rm -f back_chk.form")
				nil
				inputlist()
				createbackform_chk()
				backform_chk()
		)
		
		;This case is used to shown the Non property of BACKDRILL_EXCLUDE symbol list 
		("SYMCHK"
			inputlist()
			Pin_Input_list = nil
			Pin_Input_list = append(PinTopList PinBotList)
			
			Pin_Input_list_pinData = nil
			
			foreach(Pin_Input_list_loop Pin_Input_list
				Pin_Input_list_loop_prse = nth(5 parseString(Pin_Input_list_loop ","))
				when(Pin_Input_list_loop_prse push(Pin_Input_list_loop_prse Pin_Input_list_pinData))
			)
			
			Pin_Input_list_unq = nil
			Pin_Input_list_unq = unique(Pin_Input_list_pinData)
			
			axlClearSelSet()
			axlSetFindFilter(?enabled '("NOALL", "SYMBOLS"), ?onButtons "SYMBOLS")
			Sym_list = axlGetSelSet(axlAddSelectAll())
			
			Sym_Error_List = nil
			foreach(Pin_Input_list_unq_loop Pin_Input_list_unq
				foreach(Sym_list_loop Sym_list
					Sym_list_refdes = Sym_list_loop->refdes
						if(Sym_list_refdes == Pin_Input_list_unq_loop then
							Sym_Error_Str = sprintf(nil "%-32s %-32s %-40s", Sym_list_refdes, Sym_list_loop->name, "BACKDRILL_EXCLUDE - Property is Not Added for this Symbol" ) 
							when(Sym_Error_Str push(Sym_Error_Str Sym_Error_List))
						)
				)
			
			)
			Sym_Error_List_unq = nil
			Sym_Error_List_unq = unique(Sym_Error_List)
			
			if(Sym_Error_List_unq !=  nil then
					logfileSYM = "SYM-Missing.log"
					originalVisible_SYM=axlVisibleGet()
					designName_SYM = axlCurrentDesign()
					design_path_SYM = axlGetDrawingName()
					design_unit_SYM = car(axlDBGetDesignUnits())
					axlVisibleDesign(t)
					portSYM = axlDMOpenLog(logfileSYM)
					fprintf(portSYM, "Design name: %s\n", design_path_SYM)
					fprintf(portSYM, "%s\n", "------------------------------------------------")
					fprintf(portSYM, "%-32s %-32s %-40s\n","REFDES", "SYMBOL NAME", "ERROR MESSAGE")
						foreach(Sym_Error_List_unq_loop Sym_Error_List_unq 
							fprintf(portSYM, "%s\n", Sym_Error_List_unq_loop) 
						)
					axlDMClose(portSYM)
					axlVisibleSet(originalVisible_SYM)
					axlUIViewFileCreate(logfileSYM, "SYM-Missing", nil, '(30 25), '(CENTER))
				else
					axlUIConfirm( "No Error ...!" )
				)
		;DiaData_chk = nil
		;StubData_chk = nil
		DIA_STB_CHK = nil
		axlFormClose(backform_chk)
		shell("rm -f back_chk.form")
		nil
		inputlist()
		createbackform_chk()
		backform_chk()	
		)
	
		("TOCLOSE"
			axlFormClose(backform_chk)
			shell("rm -f back_chk.form")
			nil
		)
	
	)
axlFormDisplay(backform_chk)
)


(defun backdrill_stub_kar ()
	inputlist_STB()
	createbackform_STB()
	backform_STB()
)
(defun backform_STB () 
	backform_STB=axlFormCreate( (gensym) backform_STB_file nil 'back_Action_STB t)
	axlFormDisplay(backform_STB)
)

(defun inputlist_STB ()

	inp_prop_STB = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	fileparts_prop_STB = axlDMFileParts(inp_prop_STB)
	propinp_STB = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts_prop_STB) "r")
		if(propinp_STB != nil then
			propinp_STB_netname = nil
				while(gets(p_inp_STB propinp_STB)
					p_inp_STB = car(parseString(p_inp_STB "\n"))
						when(p_inp_STB push(p_inp_STB propinp_STB_netname))
				)
			axlDMClose(propinp_STB)
			propinp_STB_netname_unq = nil
			propinp_STB_netname_unq = unique(propinp_STB_netname)
		else
			print("nil")
		)
	foreach(propinp_STB_netname_unq_del propinp_STB_netname_unq
		foreach(item_std_del axlDBGetShapes("ETCH")
			if(item_std_del->prop->COMMENT=="custom_keepout_STB" then
				if(item_std_del->net->name == propinp_STB_netname_unq_del then 
					axlDBDeleteProp(item_std_del '(FIXED))
					axlDeleteObject(item_std_del)
					axlDBRefreshId(nil)
				)
			)
		)
	)
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
	pinTop = axlGetSelSet(axlAddSelectAll())
	PinTopList = nil
	foreach(propinp_STB_netname_unq_lp propinp_STB_netname_unq
		foreach(pinrpts pinTop
		if(propinp_STB_netname_unq_lp == pinrpts ->net->name then 
			result_pin = axlBackDrill(pinrpts, 'top)
				if(result_pin ->toLayer != nil then 
					if(result_pin ->toLayer != 0 then
						drill_pin = sprintf(nil "%L" pinrpts->definition->drillDiameter )
						drill_str_pin = sprintf(nil strcat(drill_pin))
						pinListstr = sprintf(nil, "%L,%s,%L,%L,%s,%s", result_pin ->toLayer, drill_str_pin, car(pinrpts->xy), cadr(pinrpts->xy), pinrpts->net->name, pinrpts->parent->refdes)
						when(pinListstr push(pinListstr PinTopList))
					)
				)
		))
	)
	;For via Top gathered and stored in list
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	viaTop = axlGetSelSet(axlAddSelectAll())
	ViaTopList = nil
	foreach(propinp_STB_netname_unq_lp propinp_STB_netname_unq
		foreach(viarpts viaTop
		if(propinp_STB_netname_unq_lp == viarpts ->net->name then
			result_via = axlBackDrill(viarpts, 'top)
				if(result_via ->toLayer != nil then 
					if(result_via ->toLayer != 0 then
						drill_via = sprintf(nil "%L" viarpts->definition->drillDiameter )
						dril_str_via = sprintf(nil strcat(drill_via))
						viaListstr = sprintf(nil, "%L,%s,%L,%L,%s", result_via ->toLayer, dril_str_via, car(viarpts->xy), cadr(viarpts->xy), viarpts->net->name)
						when(viaListstr push(viaListstr ViaTopList))
					)
				)
		))
	)	
	;Inputs of Via & Pin gathered by Brd file for TOP and BOTTOM Seperatly
	;Gathered data are "Back drill layer", "Drill diameter", "XY Point" 
	;For pin BOTTOM gathered and stored in list
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
	pinBot = axlGetSelSet(axlAddSelectAll())
	PinBotList = nil
	foreach(propinp_STB_netname_unq_lp propinp_STB_netname_unq
		foreach(pinrpts_bot pinBot
		if(propinp_STB_netname_unq_lp == pinrpts_bot ->net->name then
			result_pin_bot = axlBackDrill(pinrpts_bot, 'bottom)
				if(result_pin_bot ->toLayer != nil then
					if(result_pin_bot ->toLayer != 0 then
						drill_pin_bot = sprintf(nil "%L" pinrpts_bot->definition->drillDiameter )
						drill_str_pin_bot = sprintf(nil strcat(drill_pin_bot))
						pinListstr_bot = sprintf(nil, "%L,%s,%L,%L,%s,%s", result_pin_bot ->toLayer, drill_str_pin_bot, car(pinrpts_bot->xy), cadr(pinrpts_bot->xy), pinrpts_bot->net->name, pinrpts_bot->parent->refdes)
						when(pinListstr_bot push(pinListstr_bot PinBotList))
					)
				)
		))
	)
	;For via BOTTOM gathered and stored in list
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	viaBot = axlGetSelSet(axlAddSelectAll())
	ViaBotList = nil
	foreach(propinp_STB_netname_unq_lp propinp_STB_netname_unq
		foreach(viarpts_bot viaBot
		if(propinp_STB_netname_unq_lp == viarpts_bot ->net->name then
			result_via_bot = axlBackDrill(viarpts_bot, 'bottom)
				if(result_via_bot ->toLayer != nil then
					if(result_via_bot ->toLayer != 0 then
						drill_via_bot = sprintf(nil "%L" viarpts_bot->definition->drillDiameter )
						dril_str_via_bot = sprintf(nil strcat(drill_via_bot))
						viaListstr_bot = sprintf(nil, "%L,%s,%L,%L,%s", result_via_bot ->toLayer, dril_str_via_bot, car(viarpts_bot->xy), cadr(viarpts_bot->xy), viarpts_bot->net->name)
						when(viaListstr_bot push(viaListstr_bot ViaBotList))
					)
				)			
		)	)
	)
	;Combined the PIN and VIA TOP list in single list.
	Toplist_Via_Pin = nil
	Toplist_Via_Pin = append(PinTopList ViaTopList)
	
	;Combined the PIN and VIA BOT list in single list.
	Botlist_Via_Pin = nil
	Botlist_Via_Pin = append(PinBotList ViaBotList)
	
	;Combined TOP list and BOTTOM LIST
	Input_drill_Top_Bot = nil 
	Input_drill_Top_Bot = append(Toplist_Via_Pin Botlist_Via_Pin)
	
	;Parsing drill diameter alone to check the list of diameter value found in brd file
	if(Input_drill_Top_Bot == nil then
		axlUIConfirm( "This BackDrill Automation works only on Designer, GXL, XL Or Higherend Licence.." )
		;axlFormClose(backform)
	)
	loopval = length(Input_drill_Top_Bot)
	
	
	Drill_Input_Top_Bot = nil
		foreach(Input_Loop Input_drill_Top_Bot
			Input_parse = nth(1 parseString(Input_Loop ","))
				when(Input_parse push(Input_parse Drill_Input_Top_Bot))
		)
	
	;Duplicated value removed
	Unq_Drill_Input_Top_Bot = nil
	Unq_Drill_Input_Top_Bot = unique(Drill_Input_Top_Bot)
)

(defun createbackform_STB ()
	drain()
		backform_STB_file = "back_STB.form"
		backform_STB = outfile(backform_STB_file "w")

		fprintf(backform_STB "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(backform_STB "FORM\n")
		fprintf(backform_STB "FIXED\n")
		fprintf(backform_STB "PORT 42 10\n")

		fprintf(backform_STB "HEADER \"Back Drill stud\"\n")
		fprintf(backform_STB "\n")
		fprintf(backform_STB "TILE\n")
		
		fprintf(backform_STB "FIELD TOSTBADD\n")
		fprintf(backform_STB "FLOC 15 1\n")
		fprintf(backform_STB "MENUBUTTON \"BD STUB ADD\" 10 4\n")
		fprintf(backform_STB "ENDFIELD\n")
		fprintf(backform_STB "\n")
		
		fprintf(backform_STB "TEXT \"Drill Size\"\n")
		fprintf(backform_STB "TLOC 5 5\n")
		fprintf(backform_STB "ENDTEXT\n")

		fprintf(backform_STB "TEXT \"Stub Val\"\n")
		fprintf(backform_STB "TLOC 25 5\n")
		fprintf(backform_STB "ENDTEXT\n")
		
		datainp_STB = 10
		foreach(PinList_STB_lp Unq_Drill_Input_Top_Bot 
			adata_STB = sprintf(nil, "TEXT \"%s\"\n", PinList_STB_lp) 
			fprintf(backform_STB adata_STB)
			adt_STB = sprintf(nil, "TLOC 5 %d\n", datainp_STB)
			fprintf(backform_STB adt_STB)
			datainp_STB = datainp_STB + 5
			fprintf(backform_STB "ENDTEXT\n")
		)
		
		datainp2 = 10
		foreach(listlp3 Unq_Drill_Input_Top_Bot
			fprintf(backform_STB "FIELD %s%s\n",listlp3,"_STB_FIELD")
			adt2 = sprintf(nil, "FLOC 25 %d\n", datainp2)
			fprintf(backform_STB adt2)
			fprintf(backform_STB "INTSLIDEBAR 3 3\n MIN 0\n MAX 5\n")
			fprintf(backform_STB "ENDFIELD\n")
			fprintf(backform_STB "\n")
			datainp2 = datainp2 + 5
		)
	
		fprintf(backform_STB "\n")
		fprintf(backform_STB "ENDTILE\n")
		fprintf(backform_STB "\n")
		fprintf(backform_STB "ENDFORM\n")
		
	close(backform_STB)
)

STB_FIELD_VAL_LIST = nil
(defun back_Action_STB (backform_STB)
	(case backform_STB->curField
		;("STB_FIELD" STB_FIELD_VAL = backform_STB->curValue
			;when(STB_FIELD_VAL push(STB_FIELD_VAL STB_FIELD_VAL_LIST))
		;)
		
		("TOSTBADD"
		
			;STB_VAL = reverse(STB_FIELD_VAL_LIST)
			;STB_LEN = length(Unq_Drill_Input_Top_Bot)
			
			;STB_input = listToVector(Unq_Drill_Input_Top_Bot)
			;STB_VALUE = listToVector(STB_VAL)
			
			foreach(Unq_Drill_Loop_STB Unq_Drill_Input_Top_Bot
				STB_FIELD_INP = sprintf(nil "%s%s", Unq_Drill_Loop_STB, "_STB_FIELD")
				(STB_FIELD_VALUE = (axlFormGetField backform_STB STB_FIELD_INP))
				if(STB_FIELD_VALUE != nil then
					if(STB_FIELD_VALUE != 0 then
						STB_FIELD_STORE = sprintf(nil "%s,%L",Unq_Drill_Loop_STB ,STB_FIELD_VALUE)
						when(STB_FIELD_STORE push(STB_FIELD_STORE STB_FIELD_VAL_LIST))
					)
				)
			)
			
			layers_STB = nil
			etchparam = axlGetParam("paramLayerGroup:ETCH")
			layers_STB = etchparam->groupMembers
			
			layers_STB_Vec = nil
			layers_STB_Vec = listToVector(layers_STB)
			
		if(STB_FIELD_VAL_LIST != nil then
			foreach(STB_loop_val STB_FIELD_VAL_LIST
					STB_FIELD_Drill = nth(0 parseString(STB_loop_val ","))
					STB_FIELD_stub = nth(1 parseString(STB_loop_val ","))
					foreach(Top_STB_lp Toplist_Via_Pin
						foreach(propinp_STB_netname_unq_loop propinp_STB_netname_unq
						Top_STB_lp_netname = nth(4 parseString(Top_STB_lp ","))
						if(propinp_STB_netname_unq_loop == Top_STB_lp_netname then 
						Top_STB_Drill = nth(1 parseString(Top_STB_lp ","))
							if(Top_STB_Drill == STB_FIELD_Drill then
								xloc_STB = atof(nth(2 parseString(Top_STB_lp ",")))
								yloc_STB = atof(nth(3 parseString(Top_STB_lp ",")))	
								layer_crt_STB = atof(nth(0 parseString(Top_STB_lp ",")))
								
								STB_FIELD_Drill_Num = atof(STB_FIELD_stub)
								Stublayer_STB = layer_crt_STB - STB_FIELD_Drill_Num
								Stublayer_STBLYR = round(Stublayer_STB)
								Rad_Top = atof(STB_FIELD_Drill)
								path_STB = axlPathStartCircle(list(xloc_STB:yloc_STB, Rad_Top) 0)
								d = sprintf(nil "%s%s", "Etch/", layers_STB_Vec[Stublayer_STBLYR])
								shape=axlDBCreateShape(path_STB t d nth(4 parseString(Top_STB_lp ",")))
								axlDBAddProp(car(shape) list('COMMENT "custom_keepout_STB"))
							
							
							)
						)
						)
					)
					
					foreach(Bot_STB_lp Botlist_Via_Pin
					foreach(propinp_STB_netname_unq_loop_bot propinp_STB_netname_unq
					Bot_STB_lp_netname = nth(4 parseString(Bot_STB_lp ","))
					if(propinp_STB_netname_unq_loop_bot == Bot_STB_lp_netname then
						Bot_STB_Drill = nth(1 parseString(Bot_STB_lp ","))
							if(Bot_STB_Drill == STB_FIELD_Drill then
								xloc_STB = atof(nth(2 parseString(Bot_STB_lp ",")))
								yloc_STB = atof(nth(3 parseString(Bot_STB_lp ",")))	
								layer_crt_STB = atof(nth(0 parseString(Bot_STB_lp ",")))
								
								STB_FIELD_Drill_Num_Bot = atof(STB_FIELD_stub)
								Stublayer_STB = layer_crt_STB + STB_FIELD_Drill_Num_Bot
								Stublayer_STBLYR = round(Stublayer_STB) - 2 
								Rad_Bot = atof(STB_FIELD_Drill)
								path_STB = axlPathStartCircle(list(xloc_STB:yloc_STB, Rad_Bot) 0)
								d = sprintf(nil "%s%s", "Etch/", layers_STB_Vec[Stublayer_STBLYR])
								shape=axlDBCreateShape(path_STB t d nth(4 parseString(Bot_STB_lp ",")))
								axlDBAddProp(car(shape) list('COMMENT "custom_keepout_STB"))		
							
							)
					)
					)
				)
			)
			else
				axlUIConfirm("Please give the input..")
				axlFormClose(backform_STB)	
				shell("rm -f back_STB.form")
				nil	
				backdrill_stub_kar ()
			)
			axlFormClose(backform_STB)	
			shell("rm -f back_STB.form")
			nil	
		)
	
	)
	axlFormDisplay(backform_STB)
)


(defun backdrill_kar_BDE ()
	inputlist_BDE()
	createbackform_BDE()
	backform_BDE()
)

(defun backform_BDE () 
	backform_BDE=axlFormCreate( (gensym) backform_BDE_file nil 'back_Action_BDE t)
	axlFormDisplay(backform_BDE)
)

(defun inputlist_BDE ()
;inp_prop_BDE = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
;fileparts_prop_BDE = axlDMFileParts(inp_prop_BDE)
;propinp_BDE = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts_prop_BDE) "r")
	;if(propinp_BDE != nil then
		;propinp_BDE_netname = nil
			;while(gets(p_inp_BDE propinp_BDE)
				;p_inp_BDE = car(parseString(p_inp_BDE "\n"))
					;when(p_inp_BDE push(p_inp_BDE propinp_BDE_netname))
			;)
			;axlDMClose(propinp_BDE)
			
			PinList_BDE = nil
			axlClearSelSet()
			axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
			BDE_Prop = axlGetSelSet(axlAddSelectAll())
			foreach(propinp_BDE_netname_unq_lp propinp_BDE_netname_unq
				foreach(BDE_Prop_lp BDE_Prop
					BDE_Prop_refdes = BDE_Prop_lp ->net ->name 
						if(propinp_BDE_netname_unq_lp == BDE_Prop_refdes then
							;drill_pin_BDE = sprintf(nil "%L" BDE_Prop_lp->definition->drillDiameter )
							;drill_str_pin_BDE = sprintf(nil strcat(drill_pin_BDE))
							data_BDE = sprintf(nil, "%s", BDE_Prop_lp->parent->name) 
							when(data_BDE push(data_BDE PinList_BDE))
						)
				)
			)
	;else
		;print("nil")
	;)
	PinList_BDE_unq = nil
	PinList_BDE_unq = unique(PinList_BDE)
)
(defun createbackform_BDE ()
	drain()
		backform_BDE_file = "back_BDE.form"
		backform_BDE = outfile(backform_BDE_file "w")

		fprintf(backform_BDE "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(backform_BDE "FORM\n")
		fprintf(backform_BDE "FIXED\n")
		fprintf(backform_BDE "PORT 42 10\n")

		fprintf(backform_BDE "HEADER \"Back Drill Exclude\"\n")
		fprintf(backform_BDE "\n")
		fprintf(backform_BDE "TILE\n")
		
		fprintf(backform_BDE "FIELD TOSTBPROP\n")
		fprintf(backform_BDE "FLOC 15 1\n")
		fprintf(backform_BDE "MENUBUTTON \"BD Exclude\" 10 4\n")
		fprintf(backform_BDE "ENDFIELD\n")
		fprintf(backform_BDE "\n")
		
		fprintf(backform_BDE "TEXT \"Symbol Name\"\n")
		fprintf(backform_BDE "TLOC 5 5\n")
		fprintf(backform_BDE "ENDTEXT\n")

		fprintf(backform_BDE "TEXT \"EXCLUDE/NO\"\n")
		fprintf(backform_BDE "TLOC 25 5\n")
		fprintf(backform_BDE "ENDTEXT\n")
		
		datainp_BDE = 10
		foreach(PinList_BDE_lp PinList_BDE_unq 
			adata_BDE = sprintf(nil, "TEXT \"%s\"\n", PinList_BDE_lp) 
			fprintf(backform_BDE adata_BDE)
			adt_BDE = sprintf(nil, "TLOC 5 %d\n", datainp_BDE)
			fprintf(backform_BDE adt_BDE)
			datainp_BDE = datainp_BDE + 5
			fprintf(backform_BDE "ENDTEXT\n")
		)
		
		fprintf(backform_BDE "POPUP <BDEDD>\"EXCLUDE\"\"EXCLUDE\",\"NO\"\"NO\".\n")
		datainp1 = 10
		foreach(listlp2 PinList_BDE_unq
			fprintf(backform_BDE "FIELD BDE_FIELD\n")
			adt1 = sprintf(nil, "FLOC 25 %d\n", datainp1)
			fprintf(backform_BDE adt1)
			fprintf(backform_BDE "ENUMSET 8\n")
			fprintf(backform_BDE "POP \"BDEDD\"\n")
			fprintf(backform_BDE "ENDFIELD\n")
			fprintf(backform_BDE "\n")
			datainp1 = datainp1 + 5
		)
	
		fprintf(backform_BDE "\n")
		fprintf(backform_BDE "ENDTILE\n")
		fprintf(backform_BDE "\n")
		fprintf(backform_BDE "ENDFORM\n")
		
	close(backform_BDE)
)

BDE_FIELD_VAL_LIST = nil
(defun back_Action_BDE (backform_BDE)
	(case backform_BDE->curField
		("BDE_FIELD" BDE_FIELD_VAL = backform_BDE->curValue
			when(BDE_FIELD_VAL push(BDE_FIELD_VAL BDE_FIELD_VAL_LIST))
		)
		
		("TOSTBPROP"
			BDE_VAL = reverse(BDE_FIELD_VAL_LIST)
			BDE_LEN = length(PinList_BDE_unq)
			
			BDE_input = listToVector(PinList_BDE_unq)
			BDE_VALUE = listToVector(BDE_VAL)
			
			axlClearSelSet()
			axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
			BDE_PinData = axlGetSelSet(axlAddSelectAll())
			
			for(BDE_loop_val 0 BDE_LEN - 1
				foreach(BDE_Prop_input_loop propinp_BDE_netname_unq
					foreach(BDE_PinData_loop BDE_PinData
						if(BDE_Prop_input_loop == BDE_PinData_loop ->net->name then 
							;BDE_PinData_dt = sprintf(nil "%L" BDE_PinData_loop->definition->drillDiameter )
							;BDE_PinData_drill = sprintf(nil strcat(BDE_PinData_dt))
							if(BDE_PinData_loop ->parent->name == BDE_input[BDE_loop_val] then
								if(BDE_VALUE[BDE_loop_val] == "EXCLUDE" then
									axlDBAddProp(list(BDE_PinData_loop ->parent) list('BACKDRILL_EXCLUDE))
								)
							)
						)					
					)
				)
			)
		axlFormDisplay(backform_BDE)
		axlFormClose(backform_BDE)	
		shell("rm -f back_BDE.form")
		axlFormClose(backform)
		shell("rm -f back.form")
		inputlist()
		createbackform()
		backform()
		)
	)
)

(defun backdrill_stub_SEL_kar ()
	axlUIConfirm( "This Static Shape for Selected vias it creates alone.." )
	inputlist_STB_SEL()
	createbackform_STB_SEL()
	backform_STB_SEL()
)
(defun backform_STB_SEL () 
	backform_STB_SEL=axlFormCreate( (gensym) backform_STB_SEL_file nil 'back_Action_STB_SEL t)
	axlFormDisplay(backform_STB_SEL)
)

(defun inputlist_STB_SEL ()
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	axlUIConfirm("Please Select the via..")
	via_inp = axlGetSelSet(axlSelect( ))
	axlClearSelSet()
	Inp_Data_Sel = nil
	Inp_Drill_Sel = nil
	if(via_inp != nil then
		inputlist()
		foreach(via_inp_loop via_inp
			Via_NName = sprintf(nil, "%s", via_inp_loop->net->name)
			Via_Loc1 = sprintf(nil, "%L", car(via_inp_loop->xy)) 
			Via_Loc2 = sprintf(nil, "%L", cadr(via_inp_loop->xy))
			foreach(Input_drill_Top_Bot_SEL_loop Input_drill_Top_Bot
				Inp_LOC1 = nth(2 parseString(Input_drill_Top_Bot_SEL_loop ","))
				Inp_LOC2 = nth(3 parseString(Input_drill_Top_Bot_SEL_loop ",")) 
				Inp_NName = nth(4 parseString(Input_drill_Top_Bot_SEL_loop ","))
				Inp_Drill = nth(1 parseString(Input_drill_Top_Bot_SEL_loop ","))
					if(Inp_NName == Via_NName then
						if(Inp_LOC1 == Via_Loc1 then
							if(Inp_LOC2 == Via_Loc2 then
								when(Input_drill_Top_Bot_SEL_loop push(Input_drill_Top_Bot_SEL_loop Inp_Data_Sel))
								when(Inp_Drill push(Inp_Drill Inp_Drill_Sel))
							)
						)
					)
			)
		)
	)
	Inp_Drill_Sel_unq = nil
	Inp_Drill_Sel_unq = unique(Inp_Drill_Sel)
)

(defun createbackform_STB_SEL ()
	drain()
		backform_STB_SEL_file = "back_STB_SEL.form"
		backform_STB_SEL = outfile(backform_STB_SEL_file "w")

		fprintf(backform_STB_SEL "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(backform_STB_SEL "FORM\n")
		fprintf(backform_STB_SEL "FIXED\n")
		fprintf(backform_STB_SEL "PORT 45 15\n")

		fprintf(backform_STB_SEL "HEADER \"Back Drill stub\"\n")
		fprintf(backform_STB_SEL "\n")
		fprintf(backform_STB_SEL "TILE\n")
		
		fprintf(backform_STB_SEL "FIELD TOSTBADDSEL\n")
		fprintf(backform_STB_SEL "FLOC 15 1\n")
		fprintf(backform_STB_SEL "MENUBUTTON \"BD STUB ADD\" 10 4\n")
		fprintf(backform_STB_SEL "ENDFIELD\n")
		fprintf(backform_STB_SEL "\n")
		
		fprintf(backform_STB_SEL "TEXT \"Drill Size\"\n")
		fprintf(backform_STB_SEL "TLOC 5 5\n")
		fprintf(backform_STB_SEL "ENDTEXT\n")

		fprintf(backform_STB_SEL "TEXT \"Stub Val\"\n")
		fprintf(backform_STB_SEL "TLOC 25 5\n")
		fprintf(backform_STB_SEL "ENDTEXT\n")
		
		fprintf(backform_STB_SEL "TEXT \"Layer\"\n")
		fprintf(backform_STB_SEL "TLOC 35 5\n")
		fprintf(backform_STB_SEL "ENDTEXT\n")
		
		datainp_STB_SEL = 10
		foreach(DRILL_Frst Inp_Drill_Sel_unq 
			adata_STB_SEL = sprintf(nil, "TEXT \"%s\"\n", DRILL_Frst) 
			fprintf(backform_STB_SEL adata_STB_SEL)
			adt_STB_SEL = sprintf(nil, "TLOC 5 %d\n", datainp_STB_SEL)
			fprintf(backform_STB_SEL adt_STB_SEL)
			datainp_STB_SEL = datainp_STB_SEL + 5
			fprintf(backform_STB_SEL "ENDTEXT\n")
		)
		
		datainp2_STB_SEL = 10
		foreach(SB_Frst Inp_Drill_Sel_unq
			fprintf(backform_STB_SEL "FIELD %s%s\n",SB_Frst,"_STB_SEL")
			adt2 = sprintf(nil, "FLOC 25 %d\n", datainp2_STB_SEL)
			fprintf(backform_STB_SEL adt2)
			fprintf(backform_STB_SEL "INTSLIDEBAR 3 3\n MIN 0\n MAX 5\n")
			fprintf(backform_STB_SEL "ENDFIELD\n")
			fprintf(backform_STB_SEL "\n")
			datainp2_STB_SEL = datainp2_STB_SEL + 5
		)
		
		fprintf(backform_STB_SEL "POPUP <STBSELINP>\"Both\"\"Both\",\"Top\"\"Top\",\"Bottom\"\"Bottom\".\n")
		datainp3_STB_SEL = 10
		foreach(DD_Frst Inp_Drill_Sel_unq
			fprintf(backform_STB_SEL "FIELD %s%s\n",DD_Frst,"_STB_SEL_DD")
			adt1 = sprintf(nil, "FLOC 33 %d\n", datainp3_STB_SEL)
			fprintf(backform_STB_SEL adt1)
			fprintf(backform_STB_SEL "ENUMSET 8\n")
			fprintf(backform_STB_SEL "POP \"STBSELINP\"\n")
			fprintf(backform_STB_SEL "ENDFIELD\n")
			fprintf(backform_STB_SEL "\n")
			datainp3_STB_SEL = datainp3_STB_SEL + 5
		)
		
	
		fprintf(backform_STB_SEL "\n")
		fprintf(backform_STB_SEL "ENDTILE\n")
		fprintf(backform_STB_SEL "\n")
		fprintf(backform_STB_SEL "ENDFORM\n")
		
	close(backform_STB_SEL)
)

STB_SEL_LIST = nil
(defun back_Action_STB_SEL (backform_STB_SEL)
	(case backform_STB_SEL->curField
		("TOSTBADDSEL"
			foreach(Inp_Drill_STB_SEL_Loop Inp_Drill_Sel_unq
				STB_FIELD_SEC = sprintf(nil "%s%s", Inp_Drill_STB_SEL_Loop, "_STB_SEL")
				(STB_FIELD_SEC_VAL = (axlFormGetField backform_STB_SEL STB_FIELD_SEC))
					STB_FIELD_TRD = sprintf(nil "%s%s",Inp_Drill_STB_SEL_Loop ,"_STB_SEL_DD")
				(STB_FIELD_TRD_VAL = (axlFormGetField backform_STB_SEL STB_FIELD_TRD))	
					STB_FIELD_Final = sprintf(nil, "%s,%L,%s",Inp_Drill_STB_SEL_Loop, STB_FIELD_SEC_VAL, STB_FIELD_TRD_VAL)   
					when(STB_FIELD_Final push(STB_FIELD_Final STB_SEL_LIST))								
			)
			
			layers_STB = nil
			etchparam = axlGetParam("paramLayerGroup:ETCH")
			layers_STB = etchparam->groupMembers
			
			layers_STB_rev = nil
			layers_STB_rev = reverse(layers_STB)
			
			layers_STB_Vec = nil
			layers_STB_Vec = listToVector(layers_STB)
			
			layers_STB_rev_vec = nil
			layers_STB_rev_vec = listToVector(layers_STB_rev) 
			
			foreach(STB_SEL_LIST_Loop STB_SEL_LIST
				STB_SEL_FIRST_Drill = nth(0 parseString(STB_SEL_LIST_Loop ","))
				STB_SEL_SECOND_Stub = nth(1 parseString(STB_SEL_LIST_Loop ","))
				STB_SEL_THIRD_Layer = nth(2 parseString(STB_SEL_LIST_Loop ","))
				foreach(Inp_Data_Sel_loop Inp_Data_Sel
					INP_FIRST_Drill = nth(1 parseString(Inp_Data_Sel_loop ","))
					INP_FIRST_NNAME = nth(4 parseString(Inp_Data_Sel_loop ","))
					INP_FIRST_XLOC = nth(2 parseString(Inp_Data_Sel_loop ","))
					INP_FIRST_YLOC = nth(3 parseString(Inp_Data_Sel_loop ","))
						if(INP_FIRST_Drill == STB_SEL_FIRST_Drill then
							foreach(Toplist_Via_Pin_LOOP Toplist_Via_Pin
							if(STB_SEL_THIRD_Layer == "Top" || STB_SEL_THIRD_Layer == "Both" then
								Old_INP_FIRST_DRILL = nth(1 parseString(Toplist_Via_Pin_LOOP ","))
								Old_INP_FIRST_NNAME = nth(4 parseString(Toplist_Via_Pin_LOOP ","))
								Old_INP_FIRST_XLOC = nth(2 parseString(Toplist_Via_Pin_LOOP ","))
								Old_INP_FIRST_YLOC = nth(3 parseString(Toplist_Via_Pin_LOOP ","))
								
								if(Old_INP_FIRST_DRILL == INP_FIRST_Drill then
									if(INP_FIRST_NNAME == Old_INP_FIRST_NNAME then
										if(INP_FIRST_XLOC == Old_INP_FIRST_XLOC then
											if(INP_FIRST_YLOC == Old_INP_FIRST_YLOC then 
												D_Old_INP_FIRST_XLOC = atof(nth(2 parseString(Toplist_Via_Pin_LOOP ",")))
												D_Old_INP_FIRST_YLOC = atof(nth(3 parseString(Toplist_Via_Pin_LOOP ",")))
												D_Old_INP_FIRST_LN = atof(nth(0 parseString(Toplist_Via_Pin_LOOP ",")))
												
												INP_STUB_Val = atof(STB_SEL_SECOND_Stub)
												Stublayer_STB = D_Old_INP_FIRST_LN - INP_STUB_Val
												Stublayer_STBLYR = round(Stublayer_STB)
												Rad_Top = atof(STB_SEL_FIRST_Drill)
												path_STB = axlPathStartCircle(list(D_Old_INP_FIRST_XLOC:D_Old_INP_FIRST_YLOC, Rad_Top) 0)
												d = sprintf(nil "%s%s", "Etch/", layers_STB_Vec[Stublayer_STBLYR])
												shape=axlDBCreateShape(path_STB t d Old_INP_FIRST_NNAME)
												axlDBAddProp(car(shape) list('COMMENT "custom_keepout_STB"))
											)										
								)))))
							
							foreach(Botlist_Via_Pin_LOOP Botlist_Via_Pin
							if(STB_SEL_THIRD_Layer == "Bottom" || STB_SEL_THIRD_Layer == "Both" then
								Bot_Old_INP_FIRST_DRILL = nth(1 parseString(Botlist_Via_Pin_LOOP ","))
								Bot_Old_INP_FIRST_NNAME = nth(4 parseString(Botlist_Via_Pin_LOOP ","))
								Bot_Old_INP_FIRST_XLOC = nth(2 parseString(Botlist_Via_Pin_LOOP ","))
								Bot_Old_INP_FIRST_YLOC = nth(3 parseString(Botlist_Via_Pin_LOOP ","))
								
								if(Bot_Old_INP_FIRST_DRILL == INP_FIRST_Drill then
									if(INP_FIRST_NNAME == Bot_Old_INP_FIRST_NNAME then
										if(INP_FIRST_XLOC == Bot_Old_INP_FIRST_XLOC then
											if(INP_FIRST_YLOC == Bot_Old_INP_FIRST_YLOC then
												Bot_D_Old_INP_FIRST_XLOC = atof(nth(2 parseString(Botlist_Via_Pin_LOOP ",")))
												Bot_D_Old_INP_FIRST_YLOC = atof(nth(3 parseString(Botlist_Via_Pin_LOOP ",")))
												Bot_D_Old_INP_FIRST_LN = atof(nth(0 parseString(Botlist_Via_Pin_LOOP ",")))
											
												Bot_INP_STUB_Val = atof(STB_SEL_SECOND_Stub)
												Stublayer_STB = Bot_D_Old_INP_FIRST_LN + Bot_INP_STUB_Val
												Stublayer_STBLYR = round(Stublayer_STB) - 2 
												Rad_Bot = atof(STB_SEL_FIRST_Drill)
												path_STB = axlPathStartCircle(list(Bot_D_Old_INP_FIRST_XLOC:Bot_D_Old_INP_FIRST_YLOC, Rad_Bot) 0)
												d = sprintf(nil "%s%s", "Etch/", layers_STB_Vec[Stublayer_STBLYR])
												shape=axlDBCreateShape(path_STB t d Bot_Old_INP_FIRST_NNAME)
												axlDBAddProp(car(shape) list('COMMENT "custom_keepout_STB"))
								
											)
								)))))
							
							
						)	
				)
			)
			
			axlFormClose(backform_STB_SEL)	
			shell("rm -f back_STB_SEL.form")
			nil	
		)
	)
	axlFormDisplay(backform_STB_SEL)
)

