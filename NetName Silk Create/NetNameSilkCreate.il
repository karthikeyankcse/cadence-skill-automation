axlCmdRegister("NetNameSilkCreate" 'NetNameSilkCreate)
(setq SilkTxt_form_file "NetNameSilkCreate.form") 
procedure(NetNameSilkCreate()
	CreateSilkTxt_form()
	RunSilkTxt_form()
)

procedure(RunSilkTxt_form() 
	let((SilkTxt_form)
		(SilkTxt_form = axlFormCreate(gensym() SilkTxt_form_file nil 'SilkTxt_Action t))
		axlFormDisplay(SilkTxt_form)
	)
)

procedure(CreateSilkTxt_form()
	let((SilkTxt_form)
		(SilkTxt_form = outfile(SilkTxt_form_file "w")) 
		fprintf(SilkTxt_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(SilkTxt_form "FORM\n") 
		fprintf(SilkTxt_form "FIXED\n") 
		fprintf(SilkTxt_form "PORT 50 50\n") 
		fprintf(SilkTxt_form "HEADER \"Pin Or Via Netname Text Create\"\n") 
		fprintf(SilkTxt_form "\n")
		fprintf(SilkTxt_form "TILE\n")
		
		fprintf(SilkTxt_form "TEXT \" CHOOSE PIN OR VIA           >>> \"\n")
		fprintf(SilkTxt_form "TLOC 1 2\n")
		fprintf(SilkTxt_form "ENDTEXT\n")
		
		fprintf(SilkTxt_form "POPUP <OBJ>\"PIN\"\"PIN\",\"VIA\"\"VIA\".\n")
		fprintf(SilkTxt_form "FIELD OBJFLD\n") 
		fprintf(SilkTxt_form "FLOC 25 2\n") 
		fprintf(SilkTxt_form "ENUMSET 20\n")
		fprintf(SilkTxt_form "POP \"OBJ\"\n")
		fprintf(SilkTxt_form "ENDFIELD\n")
		fprintf(SilkTxt_form "\n")
		
		
		fprintf(SilkTxt_form "TEXT \" CHOOSE THE CLASS          >>> \"\n")
		fprintf(SilkTxt_form "TLOC 1 5\n")
		fprintf(SilkTxt_form "ENDTEXT\n")
		
		fprintf(SilkTxt_form "POPUP <GEO>\"BOARD GEOMETRY\"\"BOARD GEOMETRY\",\"PACKAGE GEOMETRY\"\"PACKAGE GEOMETRY\".\n")
		fprintf(SilkTxt_form "FIELD GEOFLD\n") 
		fprintf(SilkTxt_form "FLOC 25 5\n") 
		fprintf(SilkTxt_form "ENUMSET 20\n")
		fprintf(SilkTxt_form "POP \"GEO\"\n")
		fprintf(SilkTxt_form "ENDFIELD\n")
		fprintf(SilkTxt_form "\n")
		
		fprintf(SilkTxt_form "TEXT \" CHOOSE THE LAYER          >>> \"\n")
		fprintf(SilkTxt_form "TLOC 1 8\n")
		fprintf(SilkTxt_form "ENDTEXT\n")
		
		fprintf(SilkTxt_form "POPUP <LYR>\"BOTH TOP AND BOT SILKSCREEN\"\"BOTH TOP AND BOT SILKSCREEN\",\"TOP SILKSCREEN\"\"TOP SILKSCREEN\",\"BOTTOM SILKSCREEN\"\"BOTTOM SILKSCREEN\".\n")
		fprintf(SilkTxt_form "FIELD LYRFLD\n") 
		fprintf(SilkTxt_form "FLOC 25 8\n") 
		fprintf(SilkTxt_form "ENUMSET 20\n")
		fprintf(SilkTxt_form "POP \"LYR\"\n")
		fprintf(SilkTxt_form "ENDFIELD\n")
		fprintf(SilkTxt_form "\n")
		
		fprintf(SilkTxt_form "TEXT \" NAME OR NETNAME           >>> \"\n")
		fprintf(SilkTxt_form "TLOC 1 11\n")
		fprintf(SilkTxt_form "ENDTEXT\n")
		
		
		fprintf(SilkTxt_form "POPUP <NNN>\"PIN NAME\"\"PIN NAME\",\"NET NAME\"\"NET NAME\".\n")
		fprintf(SilkTxt_form "FIELD NNNFLD\n") 
		fprintf(SilkTxt_form "FLOC 25 11\n") 
		fprintf(SilkTxt_form "ENUMSET 20\n")
		fprintf(SilkTxt_form "POP \"NNN\"\n")
		fprintf(SilkTxt_form "ENDFIELD\n")
		fprintf(SilkTxt_form "\n")
		
		fprintf(SilkTxt_form "TEXT \" ENTER TEXT BLK SIZE       >>> \"\n")
		fprintf(SilkTxt_form "TLOC 1 14\n")
		fprintf(SilkTxt_form "ENDTEXT\n")
		
		fprintf(SilkTxt_form "FIELD %s\n" "TXTSIZE") 
		fprintf(SilkTxt_form "FLOC 25 14\n")
		fprintf(SilkTxt_form "STRFILLIN 10 5\n")
		fprintf(SilkTxt_form "ENDFIELD\n") 
		fprintf(SilkTxt_form "\n") 
		
		
		fprintf(SilkTxt_form "FIELD PROC\n") 
		fprintf(SilkTxt_form "FLOC 15 18\n") 
		fprintf(SilkTxt_form "MENUBUTTON \"CLICK HERE TO PROCEED..!\" 20 4\n") 
		fprintf(SilkTxt_form "ENDFIELD\n")
		fprintf(SilkTxt_form "\n")

		fprintf(SilkTxt_form "\n") 
		fprintf(SilkTxt_form "\n") 
		fprintf(SilkTxt_form "ENDTILE\n")
		
		fprintf(SilkTxt_form "\n") 
		fprintf(SilkTxt_form "ENDFORM\n")
		
		drain() 
		close(SilkTxt_form)
	)
)

procedure(SilkTxt_Action(SilkTxt_form) 
	case((SilkTxt_form->curField)
		("PROC"
			(Obj_getval = (axlFormGetField SilkTxt_form "OBJFLD"))
			(Geo_getval = (axlFormGetField SilkTxt_form "GEOFLD"))
			(Lyr_getval = (axlFormGetField SilkTxt_form "LYRFLD"))
			(Txt_getval = (axlFormGetField SilkTxt_form "TXTSIZE"))
			(NNN_getval = (axlFormGetField SilkTxt_form "NNNFLD"))
			Txt_getval = atoi(Txt_getval)
			Val1 = sprintf(nil, "You Selected - %s", Obj_getval)
			Val2 = sprintf(nil, "You Selected - %s",Geo_getval)
			Val3 = sprintf(nil, "You Selected - %s",Lyr_getval)
			Val4 = sprintf(nil, "You Selected - %d",Txt_getval)
			Val6 = sprintf(nil, "You Selected - %s",NNN_getval)
			println(Val1)
			println(Val2)
			println(Val3)
			println(Val4)
			println(Val6)
			Val5 = sprintf(nil, "PLEASE SELECT THE - %s TO CREATE TEXT IN - %s", Obj_getval, Lyr_getval)
			axlUIConfirm(Val5)
			
			SelDt = nil
			if(Obj_getval == "PIN" then
				axlClearSelSet()
				axlSetFindFilter(?enabled '("NOALL", "PINS"), ?onButtons "PINS")
				SelDt = axlGetSelSet(axlSelect( ))
			else
				axlClearSelSet()
				axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
				SelDt = axlGetSelSet(axlSelect( ))
			)
			if(SelDt != nil then
				foreach(SelDtlp SelDt
					if(NNN_getval == "NET NAME" then
						ObjNetName = SelDtlp->net->name
					else
						ObjNetName = car(SelDtlp->functionPins)->name
					)
					if(ObjNetName != nil && ObjNetName != "" then 
						ObjXPoint = car(SelDtlp->xy)
						ObjYPoint = cadr(SelDtlp->xy)
						ObjEdgePoint = SelDtlp->bBox
						ObjEdgeEPoint = cadr(ObjEdgePoint)
						ObjEdgeEXPoint = car(ObjEdgeEPoint)
						XPassPoint = ObjEdgeEXPoint + 10
						YPassPoint = ObjYPoint
						myorientT = make_axlTextOrientation(?textBlock Txt_getval, ?rotation 0.0, ?mirrored nil, ?justify "left")
						myorientB = make_axlTextOrientation(?textBlock Txt_getval, ?rotation 0.0, ?mirrored t, ?justify "left")
						if(Lyr_getval == "BOTH TOP AND BOT SILKSCREEN" then
							GeoPassStrT = sprintf(nil "%s/SILKSCREEN_TOP", Geo_getval) 
							GeoPassStrB = sprintf(nil "%s/SILKSCREEN_BOTTOM", Geo_getval)
							Up1 = axlDBCreateText(ObjNetName, XPassPoint:YPassPoint, myorientT, GeoPassStrT, nil)
							Up2 = axlDBCreateText(ObjNetName, XPassPoint:YPassPoint, myorientB, GeoPassStrB, nil)
						else
							if(Lyr_getval == "TOP SILKSCREEN" then
								GeoPassStrTS = sprintf(nil "%s/SILKSCREEN_TOP", Geo_getval)
								Up3 = axlDBCreateText(ObjNetName, XPassPoint:YPassPoint, myorientT, GeoPassStrTS, nil)
							else
								GeoPassStrBS = sprintf(nil "%s/SILKSCREEN_BOTTOM", Geo_getval)
								Up4 = axlDBCreateText(ObjNetName, XPassPoint:YPassPoint, myorientB, GeoPassStrBS, nil)
							)
						)
					)
				)
				axlUIConfirm("Created Successfully...!")
				
				ViewStr = sprintf(nil "%s/", Geo_getval)
				
				if(Lyr_getval == "BOTH TOP AND BOT SILKSCREEN" then
					;axlVisibleDesign(nil)
					axlVisibleLayer(strcat(ViewStr, "SILKSCREEN_TOP") t)
					axlVisibleLayer(strcat(ViewStr, "SILKSCREEN_BOTTOM") t)
					axlVisibleUpdate(t)
				else
					if(Lyr_getval == "TOP SILKSCREEN" then
						;axlVisibleDesign(nil)
						axlVisibleLayer(strcat(ViewStr, "SILKSCREEN_TOP") t)
						axlVisibleUpdate(t)
					else
						;axlVisibleDesign(nil)
						axlVisibleLayer(strcat(ViewStr, "SILKSCREEN_BOTTOM") t)
						axlVisibleUpdate(t)
					)
				)
				axlClearSelSet()
			else
				axlUIConfirm("Please Select again...!")
			)
			
		)
	)
	axlFormDisplay(SilkTxt_form)
)
