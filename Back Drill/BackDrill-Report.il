axlCmdRegister("backdrill_report_QC_kar" 'backdrill_report_QC_kar)
(defun backdrill_report_QC_kar ()
	BD_rep_inp()
)
(defun BD_rep_inp ()
	originalVisible=axlVisibleGet()
	axlVisibleDesign(t)
	BrdNetList = nil
	foreach(NetDtLp axlDBGetDesign() ->nets
		NetpropDt = axlDBGetProperties(NetDtLp)
		foreach(NetpropDtlp NetpropDt
			NetpropDtlp_str = car(NetpropDtlp)
			NetpropDtlp_Flit = sprintf(nil, "%s", NetpropDtlp_str)
			if(NetpropDtlp_Flit == "BACKDRILL_MAX_PTH_STUB" then
				BrdNetName = NetDtLp->name
				when(BrdNetName push(BrdNetName BrdNetList))
			)
		)
	)
	BrdNetList = unique(BrdNetList)
	ListNetList = nil
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
	pinTop = axlGetSelSet(axlAddSelectAll())
	PinTopList = nil
		foreach(pinrpts pinTop
			result_pin = axlBackDrill(pinrpts, 'top)
				if(result_pin ->toLayer != nil then 
					if(result_pin ->toLayer != 0 then
						List_NetDt = pinrpts->net->name
						drill_pin = sprintf(nil "%L" pinrpts->definition->drillDiameter )
						drill_str_pin = sprintf(nil strcat(drill_pin))
						pinListstr = sprintf(nil, "%L,%s,(%.1f %.1f),%s,%s%s%s,%s,%s", result_pin ->toLayer, drill_str_pin, car(pinrpts->xy), cadr(pinrpts->xy), pinrpts->net->name, pinrpts->parent->refdes, ".", pinrpts->number, pinrpts->parent->refdes, pinrpts->parent->name)
						when(pinListstr push(pinListstr PinTopList))
						when(List_NetDt push(List_NetDt ListNetList))
					)
				)
		)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	viaTop = axlGetSelSet(axlAddSelectAll())
	ViaTopList = nil
		foreach(viarpts viaTop
			result_via = axlBackDrill(viarpts, 'top)
				if(result_via ->toLayer != nil then 
					if(result_via ->toLayer != 0 then
						List_NetDt = viarpts->net->name
						drill_via = sprintf(nil "%L" viarpts->definition->drillDiameter )
						dril_str_via = sprintf(nil strcat(drill_via))
						viaListstr = sprintf(nil, "%L,%s,(%.1f %.1f),%s,%s", result_via ->toLayer, dril_str_via, car(viarpts->xy), cadr(viarpts->xy), viarpts->net->name, "Via")
						when(viaListstr push(viaListstr ViaTopList))
						when(List_NetDt push(List_NetDt ListNetList))
					)
				)
		)
		
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
	pinBot = axlGetSelSet(axlAddSelectAll())
	PinBotList = nil
		foreach(pinrpts_bot pinBot
			result_pin_bot = axlBackDrill(pinrpts_bot, 'bottom)
				if(result_pin_bot ->toLayer != nil then
					if(result_pin_bot ->toLayer != 0 then
						List_NetDt = pinrpts_bot->net->name
						drill_pin_bot = sprintf(nil "%L" pinrpts_bot->definition->drillDiameter )
						drill_str_pin_bot = sprintf(nil strcat(drill_pin_bot))
						pinListstr_bot = sprintf(nil, "%L,%s,(%.1f %.1f),%s,%s%s%s,%s,%s", result_pin_bot ->toLayer, drill_str_pin_bot, car(pinrpts_bot->xy), cadr(pinrpts_bot->xy), pinrpts_bot->net->name, pinrpts_bot->parent->refdes, ".", pinrpts_bot->number, pinrpts_bot->parent->refdes, pinrpts_bot->parent->refdes)
						when(pinListstr_bot push(pinListstr_bot PinBotList))
						when(List_NetDt push(List_NetDt ListNetList))
					)
				)
		)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	viaBot = axlGetSelSet(axlAddSelectAll())
	ViaBotList = nil
		foreach(viarpts_bot viaBot
			result_via_bot = axlBackDrill(viarpts_bot, 'bottom)
				if(result_via_bot ->toLayer != nil then
					if(result_via_bot ->toLayer != 0 then
						List_NetDt = viarpts_bot->net->name
						drill_via_bot = sprintf(nil "%L" viarpts_bot->definition->drillDiameter )
						dril_str_via_bot = sprintf(nil strcat(drill_via_bot))
						viaListstr_bot = sprintf(nil, "%L,%s,(%.1f %.1f),%s,%s", result_via_bot ->toLayer, dril_str_via_bot, car(viarpts_bot->xy), cadr(viarpts_bot->xy), viarpts_bot->net->name, "Via")
						when(viaListstr_bot push(viaListstr_bot ViaBotList))
						when(List_NetDt push(List_NetDt ListNetList))
					)
				)			
			)
			
	Toplist_Via_Pin = nil
	Toplist_Via_Pin = append(PinTopList ViaTopList)
	
	Botlist_Via_Pin = nil
	Botlist_Via_Pin = append(PinBotList ViaBotList)
	
	Input_drill_Top_Bot = nil 
	Input_drill_Top_Bot = append(Toplist_Via_Pin Botlist_Via_Pin)
	
	Pin_Top_Bot = nil
	Pin_Top_Bot = append(PinTopList PinBotList)
	
	
	MissNetList = nil
	MissNetList = setof(item, BrdNetList, !member(item, ListNetList))
	
	AddList = nil
	if(MissNetList != nil then
		axlClearSelSet()
		axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
		MissPin = axlGetSelSet(axlAddSelectAll())
		foreach(MissPinlp MissPin
			GetPinNetName = MissPinlp->net->name
			foreach(MissNetListlp MissNetList
				if(MissNetListlp == GetPinNetName then
					PinPar = MissPinlp->parent
					PinParMir = PinPar->mirrorType 
					if(PinParMir == "YES" then
						PinPassDt = sprintf(nil "%s,BOTTOM,(%.1f %.1f),%s%s%s", GetPinNetName, car(MissPinlp->xy), cadr(MissPinlp->xy), MissPinlp->parent->refdes, ".", MissPinlp->number)  
						when(PinPassDt push(PinPassDt AddList))
					else
						PinPassDt = sprintf(nil "%s,TOP,(%.1f %.1f),%s%s%s", GetPinNetName, car(MissPinlp->xy), cadr(MissPinlp->xy), MissPinlp->parent->refdes, ".", MissPinlp->number)  
						when(PinPassDt push(PinPassDt AddList))
					)
				)
			)
		)
		
		axlClearSelSet()
		axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
		MissVia = axlGetSelSet(axlAddSelectAll())
		foreach(MissVialp MissVia
			GetViaNetName = MissVialp->net->name
			foreach(MissNetListlp MissNetList
				if(MissNetListlp == GetViaNetName then
					ViaPassDt = sprintf(nil "%s,%s,(%.1f %.1f),VIA", GetViaNetName, car(MissVialp->startEnd), car(MissVialp->xy), cadr(MissVialp->xy)) 
					when(ViaPassDt push(ViaPassDt AddList))
				)
			)
		)
		AddList = unique(AddList)
		AddList = sort(AddList 'alphalessp)
	)
	
	if(Input_drill_Top_Bot == nil then
		axlUIConfirm( "This BackDrill Automation works only on Designer, GXL, XL Or Higherend Licence..." )
	)
	
	ShapeLoc = nil
	ShapeRad = nil
	foreach(item axlDBGetShapes("ROUTE KEEPOUT")
		if(item->prop->COMMENT == "custom_keepout" then
			shp1 = car(axlDBAltOrigin('center item))
			shp2 = cadr(axlDBAltOrigin('center item))
				foreach(el setof(element item->segments element->xy != nil)
					radval = el->radius
				)
				shpdata = sprintf(nil "(%.1f %.1f)", shp1, shp2)
				shpdata_rad = sprintf(nil "(%.1f %.1f),%.1f", shp1, shp2, radval) 
				when(shpdata push(shpdata ShapeLoc))
				when(shpdata_rad push(shpdata_rad ShapeRad))
		)
	)
	shpunique = nil
	shpunique = unique(ShapeLoc)
	
	shpvector = listToVector(ShapeLoc)
	shplength = length(ShapeLoc)
	
	shp_output = nil
	shp_val = 0
	foreach(a shpunique
		for(shplp 0 shplength - 1
			if(a == shpvector[shplp] then
				shp_val = shp_val + 1
			)
		)
		shp_out = sprintf(nil, "%s,%d", a, shp_val)
		when(shp_out push(shp_out shp_output))
		shp_val = 0
	)
	dupdata = nil
	foreach(outdata shp_output
		outdata_prse = nth(0 parseString(outdata ","))
		foreach(outdatanxt ShapeRad 
			outdatanxt_prse = nth(0 parseString(outdatanxt ","))
			outdatanxt_prse_out = nth(1 parseString(outdatanxt ","))
			if(outdatanxt_prse == outdata_prse then
				dup = sprintf(nil, "%s,%s", outdata, outdatanxt_prse_out)
				when(dup push(dup dupdata))
			)
		)
	)
	dupdata_unq = nil
	dupdata_unq = unique(dupdata)
	
	etchparam = axlGetParam("paramLayerGroup:ETCH")
	layers = etchparam->groupMembers
	layers_count = length(layers)
	
	layer_name = listToVector(layers) 
	
	final_list_Top = nil
	foreach(Input_drill_Top_lp Toplist_Via_Pin
		Input_drill_Top_prse = parseString(Input_drill_Top_lp ",")
			foreach(dupdata_unq_Top_lp dupdata_unq
				dupdata_unq_prse_Top = parseString(dupdata_unq_Top_lp ",")
					if(nth(2 Input_drill_Top_prse) == nth(0 dupdata_unq_prse_Top) then
						stub_top = round(atof(nth(0 Input_drill_Top_prse)))  					
						stub_val_a = atof(nth(0 Input_drill_Top_prse))  
						stub_val_b = atof(nth(1 dupdata_unq_prse_Top)) 
						stub_val = stub_val_a - stub_val_b
						Layer_dest = stub_top - stub_val
						Val_frst_Top = atof(nth(2 dupdata_unq_prse_Top)) * 2
						Val_sec_Top = atof(nth(1 Input_drill_Top_prse))
						Val_Diff_Top = Val_frst_Top - Val_sec_Top  
						final = sprintf(nil, "%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L", nth(3 Input_drill_Top_prse), layer_name[stub_top], stub_top + 1, nth(1 Input_drill_Top_prse), nth(0 dupdata_unq_prse_Top), atof(nth(2 dupdata_unq_prse_Top)) * 2, Val_Diff_Top, "Top", "1", Layer_dest, stub_val, nth(4 Input_drill_Top_prse), nth(6 Input_drill_Top_prse))  
						when(final push(final final_list_Top))
					)
					
			)
	)
	
	final_list_Bot = nil
	foreach(Input_drill_Bot_lp Botlist_Via_Pin
		Input_drill_Bot_prse = parseString(Input_drill_Bot_lp ",")
			foreach(dupdata_unq_lp_Bot dupdata_unq
				dupdata_unq_prse_Bot = parseString(dupdata_unq_lp_Bot ",")
					if(nth(2 Input_drill_Bot_prse) == nth(0 dupdata_unq_prse_Bot) then
						stub_bot = round(atof(nth(0 Input_drill_Bot_prse)) - 2)
						stub_val_Bot_a_val = atof(nth(0 Input_drill_Bot_prse)) - 1 
						stub_val_Bot_a = layers_count - stub_val_Bot_a_val    
						stub_val_Bot_b = atof(nth(1 dupdata_unq_prse_Bot)) 
						stub_val_Bot = stub_val_Bot_a - stub_val_Bot_b
						Layer_dest_Bot = stub_bot + stub_val_Bot 
						Val_frst = atof(nth(2 dupdata_unq_prse_Bot)) * 2
						Val_sec = atof(nth(1 Input_drill_Bot_prse))
						Val_Diff = Val_frst - Val_sec  
						final_Bot = sprintf(nil, "%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L", nth(3 Input_drill_Bot_prse), layer_name[stub_bot], stub_bot + 1, nth(1 Input_drill_Bot_prse), nth(0 dupdata_unq_prse_Bot), atof(nth(2 dupdata_unq_prse_Bot)) * 2, Val_Diff, "Bottom", layers_count, Layer_dest_Bot + 2, stub_val_Bot, nth(4 Input_drill_Bot_prse), nth(6 Input_drill_Bot_prse))  
						when(final_Bot push(final_Bot final_list_Bot))
					)
					
			)
	)

final_list = nil
final_list = append(final_list_Top final_list_Bot)

	
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "SYMBOLS"), ?onButtons "SYMBOLS")
	Sym_list = axlGetSelSet(axlAddSelectAll())
	
	
	sym_ex = nil
	foreach(BrdPinDt setof(comps axlDBGetDesign() ->components comps->symbol)
		foreach(BrdPinDtlp BrdPinDt->pins
			BrdPinNum = sprintf(nil "%s%s%s" BrdPinDtlp->parent->refdes, ".", BrdPinDtlp->number)
			SymId = BrdPinDtlp->parent
			Sym_list_prse = axlDBGetProperties(SymId)
			foreach(Sym_list_prse_lp Sym_list_prse
				Sym_list_prse_lp_f = car(Sym_list_prse_lp)
				Sym_liststr = sprintf(nil, "%s", Sym_list_prse_lp_f)
				if(Sym_liststr == "BACKDRILL_EXCLUDE" then
					sym_name = sprintf(nil, "%s,%s", BrdPinNum, BrdPinDtlp->net->name)
					when(sym_name push(sym_name sym_ex))
				)
			)
		)
	)
	sym_ex_unq = nil
	sym_ex_unq = unique(sym_ex)
	
	RepList = nil
	RepListUp = nil
	RepList = append(final_list AddList)
	RepListUp = append(RepList sym_ex_unq)
	
	if(RepListUp == nil then
		axlUIConfirm( "No Data Found..!" )
	else
		out = outfile("BackDrill-Report-QC.csv")
		if(final_list != nil then
			fprintf(out, "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", "Net Name", "Routed Layer", "Routed Layer #", "Pin/Via-Drill Size", "Pin/Via-XY Location", "Route Keepout - Diameter", "Diff-Drill VS Keepout", "Back Drill Direction", "Back Drill Keepout Start Layer #", "Back Drill Keepout End Layer #", "No of Stub Layer", "Pin-Details", "Symbol_Name")
			foreach(dup_lp final_list
				fprintf(out, "%s\n", dup_lp) 
			)
		)
		
		if(AddList != nil then
			fprintf(out, "\n")
			fprintf(out, "\n")
			fprintf(out, "-------------------------------------------------------------------------------------------------------------------\n")
			fprintf(out, "BackDrill Net Connected Outer Layers...\n")
			fprintf(out, "%s,%s,%s,%s\n", "NET NAME", "LAYER", "XY LOCATION", "TYPE")
			foreach(AddList_lp AddList
				fprintf(out, "%s\n", AddList_lp) 
			)
		)
		
		if(sym_ex_unq != nil then
			fprintf(out, "\n")
			fprintf(out, "\n")
			fprintf(out, "-------------------------------------------------------------------------------------------------------------------\n")
			fprintf(out, "Backdrill Nets Exclude Property Added In Nets...\n")
			fprintf(out, "%s,%s\n", "PIN NUMBER", "NETNAME")
			foreach(sym_ex_unq_lp sym_ex_unq
				fprintf(out, "%s\n", sym_ex_unq_lp) 
			)
		)
		close(out)
		axlUIConfirm( "BackDrill-Report-QC.csv Report Generated Successfully..!" )
	)
	sym_in = nil
	foreach(Pin_Top_Bot_lp Pin_Top_Bot
		Pin_Top_Bot_prse = nth(5 parseString(Pin_Top_Bot_lp ","))
		foreach(Sym_list_sec Sym_list
			Sym_list_prse = Sym_list_sec->refdes 
			Sym_list_prse_name = Sym_list_sec->name 
			if(Sym_list_prse == Pin_Top_Bot_prse then
				sym_data = sprintf(nil "%s,%s", Sym_list_prse, Sym_list_prse_name)  
				when(sym_data push(sym_data sym_in))
			)
		)
	)
	sym_in_unq = nil
	sym_in_unq = unique(sym_in)
	
	if(sym_in_unq != nil then
		out2 = outfile("BackDrill-Report(Include)-QC.rpt")
			foreach(sym_in_unq_lp sym_in_unq
				fprintf(out2, "%s\n", sym_in_unq_lp) 
			)
		close(out2)
	else
		axlUIConfirm( "No Records found to Create Report(BackDrill-Report(Include)-QC)..!" )
	)
	
	
	axlVisibleSet(originalVisible)
)