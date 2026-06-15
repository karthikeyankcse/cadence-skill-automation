axlCmdRegister("AirGapBetShpAndOLrTxt" 'AirGapBetShpAndOLrTxt)
(setq AGShpAndTxt_form_file "AirGapBetShpAndOLrTxt.form") 
procedure(AirGapBetShpAndOLrTxt()
	CreateAGShpAndTxt_form()
	RunAGShpAndTxt_form()
)

procedure(RunAGShpAndTxt_form() 
	let((AGShpAndTxt_form)
		(AGShpAndTxt_form = axlFormCreate(gensym() AGShpAndTxt_form_file nil 'AGShpAndTxt_Action t))
		axlFormDisplay(AGShpAndTxt_form)
	)
)

procedure(CreateAGShpAndTxt_form()
	let((AGShpAndTxt_form)
		(AGShpAndTxt_form = outfile(AGShpAndTxt_form_file "w")) 
		fprintf(AGShpAndTxt_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(AGShpAndTxt_form "FORM\n") 
		fprintf(AGShpAndTxt_form "FIXED\n") 
		fprintf(AGShpAndTxt_form "PORT 50 50\n") 
		fprintf(AGShpAndTxt_form "HEADER \"AirGap Between Place Bound Shape and OutLine\"\n") 
		fprintf(AGShpAndTxt_form "\n")
		fprintf(AGShpAndTxt_form "TILE\n")
		
		;fprintf(AGShpAndTxt_form "TEXT \" CHOOSE LINE OR TEXT     >>> \"\n")
		;fprintf(AGShpAndTxt_form "TLOC 1 2\n")
		;fprintf(AGShpAndTxt_form "ENDTEXT\n")
		
		;fprintf(AGShpAndTxt_form "POPUP <LTPOP>\"LINE\"\"LINE\",\"TEXT\"\"TEXT\".\n")
		;fprintf(AGShpAndTxt_form "FIELD LTFLD\n") 
		;fprintf(AGShpAndTxt_form "FLOC 25 2\n") 
		;fprintf(AGShpAndTxt_form "ENUMSET 20\n")
		;fprintf(AGShpAndTxt_form "POP \"LTPOP\"\n")
		;fprintf(AGShpAndTxt_form "ENDFIELD\n")
		;fprintf(AGShpAndTxt_form "\n")
		
		fprintf(AGShpAndTxt_form "TEXT \" CHOOSE THE CLASS          >>> \"\n")
		fprintf(AGShpAndTxt_form "TLOC 1 5\n")
		fprintf(AGShpAndTxt_form "ENDTEXT\n")
		
		fprintf(AGShpAndTxt_form "POPUP <CLSPOP>\"REF DES\"\"REF DES\",\"PACKAGE GEOMETRY\"\"PACKAGE GEOMETRY\".\n")
		fprintf(AGShpAndTxt_form "FIELD CLS\n") 
		fprintf(AGShpAndTxt_form "FLOC 25 5\n") 
		fprintf(AGShpAndTxt_form "ENUMSET 20\n")
		fprintf(AGShpAndTxt_form "POP \"CLSPOP\"\n")
		fprintf(AGShpAndTxt_form "ENDFIELD\n")
		fprintf(AGShpAndTxt_form "\n")
		
		fprintf(AGShpAndTxt_form "TEXT \" CHOOSE THE SUBCLASS   >>> \"\n")
		fprintf(AGShpAndTxt_form "TLOC 1 8\n")
		fprintf(AGShpAndTxt_form "ENDTEXT\n")
		
		fprintf(AGShpAndTxt_form "POPUP <SUBCLSPOP>\"BOTH\"\"BOTH\",\"TOP SILKSCREEN\"\"TOP SILKSCREEN\",\"BOTTOM SILKSCREEN\"\"BOTTOM SILKSCREEN\".\n")
		fprintf(AGShpAndTxt_form "FIELD SUBCLS\n") 
		fprintf(AGShpAndTxt_form "FLOC 25 8\n") 
		fprintf(AGShpAndTxt_form "ENUMSET 20\n")
		fprintf(AGShpAndTxt_form "POP \"SUBCLSPOP\"\n")
		fprintf(AGShpAndTxt_form "ENDFIELD\n")
		fprintf(AGShpAndTxt_form "\n")
		
		fprintf(AGShpAndTxt_form "FIELD PROCEED\n") 
		fprintf(AGShpAndTxt_form "FLOC 15 12\n") 
		fprintf(AGShpAndTxt_form "MENUBUTTON \"CLICK HERE TO PROCEED..!\" 20 4\n") 
		fprintf(AGShpAndTxt_form "ENDFIELD\n")
		fprintf(AGShpAndTxt_form "\n")

		fprintf(AGShpAndTxt_form "\n") 
		fprintf(AGShpAndTxt_form "\n") 
		fprintf(AGShpAndTxt_form "ENDTILE\n")
		
		fprintf(AGShpAndTxt_form "\n") 
		fprintf(AGShpAndTxt_form "ENDFORM\n")
		
		drain() 
		close(AGShpAndTxt_form)
	)
)

procedure(AGShpAndTxt_Action(AGShpAndTxt_form) 
	case((AGShpAndTxt_form->curField)
		("PROCEED"
			;(LT_getval = (axlFormGetField AGShpAndTxt_form "LTFLD"))
			(Cls_getval = (axlFormGetField AGShpAndTxt_form "CLS"))
			(SubCls_getval = (axlFormGetField AGShpAndTxt_form "SUBCLS"))
			
			;Val0 = sprintf(nil, "You Selected - %s", LT_getval)
			Val1 = sprintf(nil, "You Selected - %s", Cls_getval)
			Val2 = sprintf(nil, "You Selected - %s", SubCls_getval)
			println(Val1)
			println(Val2)
			Cls_getval = sprintf(nil "%s/", Cls_getval)
			originalVisible = axlVisibleGet()
			
			if(Cls_getval == "PACKAGE GEOMETRY/" then
				ErrorL_TopList = nil
				ErrorL_BotList = nil
				ErrorL_BothList = nil
				if(SubCls_getval == "TOP SILKSCREEN" then
					LineTopCheck()
				else
					if(SubCls_getval == "BOTTOM SILKSCREEN" then
						LineBotCheck()
					else
						LineTopCheck()
						LineBotCheck()
						ErrorL_BothList = append(ErrorL_TopList ErrorL_BotList)
					)
				)
				axlVisibleSet(originalVisible)
				ErrorListL = nil
				ErrorListL1 = nil
				ErrorListL1 = append(ErrorL_TopList ErrorL_BotList)
				ErrorListL = append(ErrorListL1 ErrorL_BothList)
				ErrorListL = unique(ErrorListL)
				axlClearSelSet()
				if(ErrorListL != nil then
					logfileL = "AirGapBetShpAndLine.log"
					designName = axlCurrentDesign()
					design_path = axlGetDrawingName()
					design_unit = car(axlDBGetDesignUnits())
					portL = axlDMOpenLog(logfileL)
					fprintf(portL, "Design name: %s\n", design_path)
					fprintf(portL, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						fprintf(portL, "%s\n\n", "ERROR LIST :")
						fprintf(portL, "%-25s %-25s %-25s \n\n", "XY LOCATION", "LAYER", "ERROR")
						foreach(ErrorListLlp ErrorListL
							ErrorListLlp_filt = parseString(ErrorListLlp ",")
							fprintf(portL, "%-25s %-25s %-25s \n", nth(0 ErrorListLlp_filt), nth(1 ErrorListLlp_filt), nth(2 ErrorListLlp_filt))
						)
						fprintf(portL, "\n\n")
						fprintf(portL, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
					axlDMClose(portL)
					axlUIViewFileCreate(logfileL, "AirGap Between Place Bound Shape and OutLine", nil, '(30 25), '(CENTER))
				else
					axlUIConfirm("No Error Found...!")

				)
			else
				if(Cls_getval == "REF DES/" then
					ErrorT_TopList = nil
					ErrorT_BotList = nil
					ErrorT_BothList = nil
					if(SubCls_getval == "TOP SILKSCREEN" then
						TextTopCheck()
					else
						if(SubCls_getval == "BOTTOM SILKSCREEN" then
							TextBotCheck()
						else
							TextTopCheck()
							TextBotCheck()
							ErrorT_BothList = append(ErrorT_TopList ErrorT_BotList)
						)
					)
					
					axlVisibleSet(originalVisible)
					ErrorListT = nil
					ErrorListT1 = nil
					ErrorListT1 = append(ErrorT_TopList ErrorT_BotList)
					ErrorListT = append(ErrorListT1 ErrorT_BothList)
					ErrorListT = unique(ErrorListT)
					axlClearSelSet()
					if(ErrorListT != nil then
						logfileT = "AirGapBetShpAndText.log"
						designName = axlCurrentDesign()
						design_path = axlGetDrawingName()
						design_unit = car(axlDBGetDesignUnits())
						portT = axlDMOpenLog(logfileT)
						fprintf(portT, "Design name: %s\n", design_path)
						fprintf(portT, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
							fprintf(portT, "%s\n\n", "ERROR LIST :")
							fprintf(portT, "%-25s %-25s %-25s %-25s \n\n", "TEXT", "XY LOCATION", "LAYER", "ERROR")
							foreach(ErrorListTlp ErrorListT
								ErrorListTlp_filt = parseString(ErrorListTlp ",")
								fprintf(portT, "%-25s %-25s %-25s %-25s \n", nth(0 ErrorListTlp_filt), nth(1 ErrorListTlp_filt), nth(2 ErrorListTlp_filt), nth(3 ErrorListTlp_filt))
							)
							fprintf(portT, "\n\n")
							fprintf(portT, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						axlDMClose(portT)
						axlUIViewFileCreate(logfileT, "AirGap Between Place Bound Shape and Text", nil, '(30 25), '(CENTER))
					else
						axlUIConfirm("No Error Found...!")

					)
				
				)
			)
			
			
					
		)
	)
	axlFormDisplay(AGShpAndTxt_form)
)

procedure(LineTopCheck()
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat(Cls_getval, "SILKSCREEN_TOP") t)
	axlVisibleUpdate(t)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "LINESEGS" "SHAPESEGS") ?onButtons `("LINESEGS" "SHAPESEGS"))
	LineDt1 = axlGetSelSet(axlAddSelectAll())
	
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/", "PLACE_BOUND_TOP") t)
	axlVisibleUpdate(t)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
	ShpDtL1 = axlGetSelSet(axlAddSelectAll())
	
	foreach(ShpDtL1lp ShpDtL1
		DummyVal = "YES"
		ShpRef = ShpDtL1lp->parent->refdes
		if(ShpRef == nil || ShpRef == "" then
			proplist = axlDBGetProperties(ShpDtL1lp)
			if(proplist != nil then
				foreach(prop proplist
					propS = symbolToString(car(prop))						
					if((propS == "PACKAGE_HEIGHT_MAX") then
						DummyVal = "NO"
					)	
										 
				)
			)
			if(DummyVal == "YES" then
				foreach(LineDt1lp LineDt1
					(AirGapL_Top = (axlAirGap ShpDtL1lp LineDt1lp nil 'anyLayer))
					if(AirGapL_Top == 0.0 then
						XYPointTDt = (axlAirGap ShpDtL1lp LineDt1lp nil 'enhanced)
						XYPointT = nth(8 chXYPointTDtk)
						XPointT = car(XYPointT)
						YPointT = cadr(XYPointT)
						XYPointStrT = sprintf(nil "(%.2f %.2f)", XPointT, YPointT)
						;LineSPoint1 = sprintf(nil "(%.2f %.2f)", xCoord(car(LineDt1lp->startEnd)), yCoord(car(LineDt1lp->startEnd)))
						;LineEPoint1 = sprintf(nil "(%.2f %.2f)", xCoord(cadr(LineDt1lp->startEnd)), yCoord(cadr(LineDt1lp->startEnd)))
						LineLyr1 = LineDt1lp ->layer 
						ErrorLDt_Top = sprintf(nil "%s,%s, --> This Line Segment Overlapped By PACKAGE GEOMETRY/PLACE_BOUND_TOP SHAPE", XYPointStrT, LineLyr1)
						when(ErrorLDt_Top push(ErrorLDt_Top ErrorL_TopList))
						axlHighlightObject(ShpDtL1lp)
						axlHighlightObject(LineDt1lp)
					)
				)
			)
		)
	)
)


procedure(LineBotCheck()
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat(Cls_getval, "SILKSCREEN_BOTTOM") t)
	axlVisibleUpdate(t)

	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "LINESEGS" "SHAPESEGS") ?onButtons `("LINESEGS" "SHAPESEGS"))
	LineDt2 = axlGetSelSet(axlAddSelectAll())

	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/", "PLACE_BOUND_BOTTOM") t)
	axlVisibleUpdate(t)

	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
	ShpDtL2 = axlGetSelSet(axlAddSelectAll())

	foreach(ShpDtL2lp ShpDtL2
		DummyVal = "YES"
		ShpRef1 = ShpDtL2lp->parent->refdes
		if(ShpRef1 == nil || ShpRef1 == "" then
			proplist=axlDBGetProperties(ShpDtL2lp)
			if(proplist != nil then
				foreach(prop proplist
					propS=symbolToString(car(prop))						
					if((propS == "PACKAGE_HEIGHT_MAX") then
						DummyVal = "NO"
					)	
										 
				)
			)
			if(DummyVal == "YES" then
				foreach(LineDt2lp LineDt2
					(AirGapL_Bot = (axlAirGap ShpDtL2lp LineDt2lp nil 'anyLayer))
					if(AirGapL_Bot == 0.0 then
						XYPointBDt = (axlAirGap ShpDtL2lp LineDt2lp nil 'enhanced)
						XYPointB = nth(8 XYPointBDt)
						XPointB = car(XYPointB)
						YPointB = cadr(XYPointB)
						XYPointStrB = sprintf(nil "(%.2f %.2f)", XPointB, YPointB)
						;LineSPoint = sprintf(nil "(%.2f %.2f)", xCoord(car(LineDt2lp->startEnd)), yCoord(car(LineDt2lp->startEnd)))
						;LineEPoint = sprintf(nil "(%.2f %.2f)", xCoord(cadr(LineDt2lp->startEnd)), yCoord(cadr(LineDt2lp->startEnd)))
						LineLyr = LineDt2lp ->layer 
						ErrorLDt_Bot = sprintf(nil "%s,%s, --> This Line Segment Overlapped By PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM SHAPE", XYPointStrB, LineLyr)
						when(ErrorLDt_Bot push(ErrorLDt_Bot ErrorL_BotList))
						axlHighlightObject(ShpDtL2lp)
						axlHighlightObject(LineDt2lp)
					)
				)
			)
		)
	)
)


procedure(TextTopCheck()
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat(Cls_getval, "SILKSCREEN_TOP") t)
	axlVisibleUpdate(t)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "TEXT") ?onButtons `("TEXT"))
	TextDt1 = axlGetSelSet(axlAddSelectAll())
	
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/", "PLACE_BOUND_TOP") t)
	axlVisibleUpdate(t)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
	ShpDtT1 = axlGetSelSet(axlAddSelectAll())
	
	foreach(ShpDtT1lp ShpDtT1
		DummyVal = "YES"
		ShpRefT1 = ShpDtT1lp->parent->refdes
		if(ShpRefT1 == nil || ShpRefT1 == "" then
			proplist=axlDBGetProperties(ShpDtT1lp)
			if(proplist != nil then
				foreach(prop proplist
					propS=symbolToString(car(prop))						
					if((propS == "PACKAGE_HEIGHT_MAX") then
						DummyVal = "NO"
					)	
										 
				)
			)
			
			if(DummyVal == "YES" then
				foreach(TextDt1lp TextDt1
					(AirGapT_Top = (axlAirGap ShpDtT1lp TextDt1lp nil 'anyLayer))
					if(AirGapT_Top == 0.0 then
						ErrorTDt_Top = sprintf(nil "%s,(%.2f %.2f),%s, --> This Text Overlapped By PACKAGE GEOMETRY/PLACE_BOUND_TOP SHAPE", TextDt1lp->text, car(TextDt1lp->xy), cadr(TextDt1lp->xy), TextDt1lp->layer) 
						when(ErrorTDt_Top push(ErrorTDt_Top ErrorT_TopList))
						axlHighlightObject(ShpDtT1lp)
						axlHighlightObject(TextDt1lp)
					)
				)
			)
			
		)
	)
	
)



procedure(TextBotCheck()
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat(Cls_getval, "SILKSCREEN_BOTTOM") t)
	axlVisibleUpdate(t)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "TEXT") ?onButtons `("TEXT"))
	TextDt2 = axlGetSelSet(axlAddSelectAll())
	
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/", "PLACE_BOUND_BOTTOM") t)
	axlVisibleUpdate(t)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
	ShpDtT2 = axlGetSelSet(axlAddSelectAll())
	
	foreach(ShpDtT2lp ShpDtT2
		DummyVal = "YES"
		ShpRefT2 = ShpDtT2lp->parent->refdes
		if(ShpRefT2 == nil || ShpRefT2 == "" then
			proplist=axlDBGetProperties(ShpDtT2lp)
			if(proplist != nil then
				foreach(prop proplist
					propS=symbolToString(car(prop))						
					if((propS == "PACKAGE_HEIGHT_MAX") then
						DummyVal = "NO"
					)	
										 
				)
			)
			
			if(DummyVal == "YES" then
				foreach(TextDt2lp TextDt2
					(AirGapT_Bot = (axlAirGap ShpDtT2lp TextDt2lp nil 'anyLayer))
					if(AirGapT_Bot == 0.0 then
						ErrorTDt_Bot = sprintf(nil "%s,(%.2f %.2f),%s, --> This Text Overlapped By PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM SHAPE", TextDt2lp->text, car(TextDt2lp->xy), cadr(TextDt2lp->xy), TextDt2lp->layer) 
						when(ErrorTDt_Bot push(ErrorTDt_Bot ErrorT_BotList))
						axlHighlightObject(ShpDtT2lp)
						axlHighlightObject(TextDt2lp)
					)
				)
			)
			
		)
	)
	
)
