axlCmdRegister("heightrptkar" 'heightrptkar)
procedure(heightrptkar()
;Height Report and finding height missing & place bound shape missing
;Getting input for top by place bound top layer 
axlClearSelSet()
vis_list = axlVisibleGet()
axlVisibleDesign(nil)
axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP" t)
axlSetFindFilter(?enabled list("noall" "SHAPES")
        ?onButtons list("noall" "SHAPES"))
axlAddSelectAll()
axlVisibleSet(vis_list)
text_db_list = axlGetSelSet()

;collecting the parent symbol of shape storing parent details
topdata = nil
logtopdata = nil
foreach( text_db text_db_list
	text_refdes = text_db->parent->refdes
	text_name = text_db->parent->name
	text_db_lyr = text_db->layer
	Locationx = sprintf(nil "%L" car(text_db->parent->xy))
	Locationy = sprintf(nil "%L" cadr(text_db->parent->xy))
	proplist=axlDBGetProperties(text_db)
	;It checks the height is missing or not by properties for top
	if(proplist != nil then
		foreach(prop proplist
			propS=symbolToString(car(prop))						
				if((propS=="PACKAGE_HEIGHT_MAX") then
					topd = sprintf(nil "%s,%L,%L,%L,%s,%s" upperCase(text_refdes), Locationx, Locationy, cadr(prop), text_name, "Top")
					when(topd push(topd topdata))
				);end if		
								 
		);end foreach
	else
		topde = sprintf(nil "%s,%L,%s,%s,%s" upperCase(text_db->parent->refdes), text_db->parent->xy, text_db->parent->name, "Top", "Symbol Height - Missing")
			when(topde push(topde logtopdata))
	)
	
)

;Getting input for bottom by place bound bottom layer 
axlClearSelSet()
vis_list_bot = axlVisibleGet()
axlVisibleDesign(nil)
axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" t)
axlSetFindFilter(?enabled list("noall" "SHAPES")
        ?onButtons list("noall" "SHAPES"))
axlAddSelectAll()
axlVisibleSet(vis_list_bot)
text_db_list_bot = axlGetSelSet()

;collecting the parent symbol of shape storing parent details
botdata = nil
logbotdata = nil
foreach( text_db_bot text_db_list_bot
	text_refdes_bot = text_db_bot->parent->refdes
	text_name_bot = text_db_bot->parent->name
	text_db_lyr_bot = text_db_bot->layer
	Locationxbot = sprintf(nil "%L" car(text_db_bot->parent->xy))
	Locationybot = sprintf(nil "%L" cadr(text_db_bot->parent->xy))
	proplist_bot = axlDBGetProperties(text_db_bot)
	;It checks the height is missing or not by properties for bottom
	if(proplist_bot != nil then
		foreach(prop_bot proplist_bot
			propS_bot=symbolToString(car(prop_bot))						
				if((propS_bot=="PACKAGE_HEIGHT_MAX") then
					botd = sprintf(nil "%s,%L,%L,%L,%s,%s" upperCase(text_refdes_bot), Locationxbot, Locationybot, cadr(prop_bot), text_name_bot, "Bottom")
					when(botd push(botd botdata))		
				);end if		
								 
		);end foreach
	else
		botde = sprintf(nil "%s,%L,%s,%s,%s" upperCase(text_db_bot->parent->refdes), text_db_bot->parent->xy, text_db_bot->parent->name, "Bottom", "Symbol Height - Missing")
			when(botde push(botde logbotdata))
	)
		
	
)

;output file for height report
out = outfile("Height-Report.rpt")
fprintf(out, "%s,%s,%s,%s,%s,%s\n", "REFDES", "X LOCATION", "Y LOCATION", "SYMBOL HEIGHT", "SYMBOL NAME", "SIDE")
finalhrpt = nil
finalhrpt = append(topdata botdata)
finalhrptunq = nil
finalhrptunq = unique(finalhrpt)
foreach(hrptlp finalhrptunq
	fprintf(out, "%s\n", hrptlp)  
)
close(out)


;finding place bound missing

logphase1 = nil
logphase1 = append(logtopdata logbotdata)

logphase1unq = nil
logphase1unq = unique(logphase1)

; combined the every generated data and error list of height missing to check placeboubd missing
finalphase = nil
finalphase = append(logphase1unq finalhrptunq)

;For finding TOP placebound missing enable the layer by pin of top
axlClearSelSet()
vis_list = axlVisibleGet() 
axlVisibleDesign(nil) 
axlVisibleLayer("PIN/TOP" t) 
axlSetFindFilter(?enabled list("noall" "pins") 
?onButtons list("noall" "pins")) 
axlAddSelectAll() 
pselect_list = axlGetSelSet()
axlClearSelSet() 
axlVisibleSet(vis_list)
top_missings = nil
;storing the pin data of top in list
foreach(pin_db pselect_list
unless(pin_db->isMech
	symbol_dbid = pin_db->parent
	symbol_name = axlDbidName(symbol_dbid )
	text_refdes_mtop = sprintf(nil "%s,%L,%s,%s,%s" upperCase(symbol_name), symbol_dbid ->xy, symbol_dbid ->name, "Top", "Shape - Missing")
	when(text_refdes_mtop push(text_refdes_mtop top_missings))
))
top_missing = nil
top_missing = unique(top_missings)

;To find placebound missing by comparing generated list with pin report of top
mtopprsed = nil
foreach(mtoplp top_missing
	mtopprsd = car(parseString(mtoplp ","))
	when(mtopprsd push(mtopprsd mtopprsed))
)

topinpfinaldata = nil
topinpfinaldata = append(topdata logtopdata)
 
mtopinpprsed = nil
foreach(mtopinplp topinpfinaldata
	mtopinplpprsd = car(parseString(mtopinplp ","))
	when(mtopinplpprsd push(mtopinplpprsd mtopinpprsed))
)

mtopmisslist = nil
mtopmisslist = setof(item, mtopprsed, !member(item, mtopinpprsed))

;compared the data and missed data stored in top error list of place bound

mtopfinaldata = nil
foreach(top_missinglp top_missing
	top_missinglpprse = car(parseString(top_missinglp ","))
	foreach(mtopmisslistlp mtopmisslist
		if(mtopmisslistlp == top_missinglpprse then
			when(top_missinglp push(top_missinglp mtopfinaldata))	
		)
	)
)
;removes duplicate error
mtopfinaldataunq = nil
mtopfinaldataunq = unique(mtopfinaldata)


;For finding BOTTOM placebound missing enable the layer by pin of BOTTOM
axlClearSelSet()
vis_list_bott = axlVisibleGet() 
axlVisibleDesign(nil) 
axlVisibleLayer("PIN/BOTTOM" t) 
axlSetFindFilter(?enabled list("noall" "pins") 
?onButtons list("noall" "pins")) 
axlAddSelectAll() 
pselect_list_bott = axlGetSelSet()
axlClearSelSet() 
axlVisibleSet(vis_list_bott)
bot_missing = nil
;storing the pin data of bottom in list
foreach(pin_db_bott pselect_list_bott
unless(pin_db_bott->isMech
	symbol_dbid_bott = pin_db_bott->parent
	symbol_name_bott = axlDbidName(symbol_dbid_bott )
	text_refdes_bott = sprintf(nil "%s,%L,%s,%s,%s" upperCase(symbol_name_bott), symbol_dbid_bott ->xy, symbol_dbid_bott ->name, "BOTTOM", "Shape - Missing")
	when(text_refdes_bott push(text_refdes_bott bot_missing))
))

;To find placebound missing by comparing generated list with pin report of bottom
mbotprsed = nil
foreach(mbotlp bot_missing
	mbotprsd = car(parseString(mbotlp ","))
	when(mbotprsd push(mbotprsd mbotprsed))
)

botinpfinaldata = nil
botinpfinaldata = append(botdata logbotdata)
 
mbotinpprsed = nil
foreach(mbotinplp botinpfinaldata
	mbotinplpprsd = car(parseString(mbotinplp ","))
	when(mbotinplpprsd push(mbotinplpprsd mbotinpprsed))
)



mbotmisslist = nil
mbotmisslist = setof(itemm, mbotprsed, !member(itemm, mbotinpprsed))

;compared the data and missed data stored in bottom error list of place bound
mbotfinaldata = nil
foreach(bot_missinglp bot_missing
	bot_missinglpprse = car(parseString(bot_missinglp ","))
	foreach(mbotmisslistlp mbotmisslist
		if(mbotmisslistlp == bot_missinglpprse then
			when(bot_missinglp push(bot_missinglp mbotfinaldata))	
		)
	)
)
mbotfinaldataunq = nil
mbotfinaldataunq = unique(mbotfinaldata)

;combined the error list height missing and place bound missing
mbothfinal = nil
mbothfinal = append(mtopfinaldataunq mbotfinaldataunq)

;final error log file.
finalerrorlist = nil
finalerrorlist = append(logphase1unq mbothfinal)

if(finalerrorlist != nil then
	logfile = "Height-Error.log"
	originalVisible=axlVisibleGet()
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	axlVisibleDesign(t)
	timeperform = fileTimeModified("Height-Error.log")
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n", "------------------------------------------------")
	fprintf(port, "%-16s %-32s %-32s %-16s %-16s \n\n", "REFDES", "XY LOCATION", "SYMBOL NAME", "LAYER", "ERROR - MESSEGE")
	foreach(finalphaseout finalerrorlist
		finalphaseoutprse = parseString(finalphaseout ",")
		fprintf(port, "%-16s %-32s %-32s %-16s %-16s \n", nth(0 finalphaseoutprse), nth(1 finalphaseoutprse), nth(2 finalphaseoutprse), nth(3 finalphaseoutprse), nth(4 finalphaseoutprse))
		)
		axlDMClose(port)
		axlVisibleSet(originalVisible) 
		axlUIViewFileCreate(logfile, "Height-Error", nil, '(30 25), '(CENTER))
	
	
else
	axlUIConfirm( "HeightReport Generated SuccessFully..." )
)


)

