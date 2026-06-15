axlCmdRegister("BackDrillModule" 'BackDrillModule)
(setq BDM_form_file "BackDrillModule.form") 
procedure(BackDrillModule()
	CreateBDM_form()
	RunBDM_form()
)

procedure(RunBDM_form() 
	let((BDM_form)
		(BDM_form = axlFormCreate(gensym() BDM_form_file nil 'BDM_Action t)) 
		axlFormDisplay(BDM_form)
	)
)

procedure(CreateBDM_form()
	let((BDM_form)
		(BDM_form = outfile(BDM_form_file "w")) 
		fprintf(BDM_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(BDM_form "FORM\n") 
		fprintf(BDM_form "FIXED\n") 
		fprintf(BDM_form "PORT 45 50\n") 
		fprintf(BDM_form "HEADER \"Backdrill Module\"\n") 
		fprintf(BDM_form "\n")
		fprintf(BDM_form "TILE\n")
		
		fprintf(BDM_form "FIELD CRT\n") 
		fprintf(BDM_form "FLOC 12 2\n") 
		fprintf(BDM_form "MENUBUTTON \"TO CREATE\" 20 4\n") 
		fprintf(BDM_form "ENDFIELD\n")
		fprintf(BDM_form "\n")
		
		fprintf(BDM_form "FIELD CHK\n") 
		fprintf(BDM_form "FLOC 12 7\n") 
		fprintf(BDM_form "MENUBUTTON \"TO CHECK\" 20 4\n") 
		fprintf(BDM_form "ENDFIELD\n")
		fprintf(BDM_form "\n")

		fprintf(BDM_form "\n") 
		fprintf(BDM_form "\n") 
		fprintf(BDM_form "ENDTILE\n")
		
		fprintf(BDM_form "\n") 
		fprintf(BDM_form "ENDFORM\n")
		
		drain() 
		close(BDM_form)
	)
)

procedure(BDM_Action(BDM_form) 
	case((BDM_form->curField)

		("CRT"
            axlShell("Done")
            originalVisible=axlVisibleGet()
            axlVisibleDesign(t)

            axlClearSelSet()
            axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
            DelClineDt = axlGetSelSet(axlAddSelectAll())
            foreach(DelClineDtlp DelClineDt
                if(DelClineDtlp->prop->COMMENT=="BACKDRILL_MODULE" then
                    axlDBDeleteProp(DelClineDtlp '(FIXED))
                    axlDeleteObject(DelClineDtlp)
                    axlDBRefreshId(nil)
                )
            )


            axlClearSelSet()
            axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
            DelShpDt = axlGetSelSet(axlAddSelectAll())
            foreach(DelShpDtlp DelShpDt
                if(DelShpDtlp->prop->COMMENT=="BACKDRILL_MODULE" then
                    axlDBDeleteProp(DelShpDtlp '(FIXED))
                    axlDeleteObject(DelShpDtlp)
                    axlDBRefreshId(nil)
                )
            )



            etchparam = axlGetParam("paramLayerGroup:ETCH")
		    l_layers = etchparam->groupMembers
            LayerLen = length(l_layers) - 1
            LayersArr = listToVector(l_layers)
            UpdatedList = nil
            axlClearSelSet()
            axlSetFindFilter(?enabled `("NOALL" "SYMBOLS") ?onButtons `("SYMBOLS"))
            SymDt = axlGetSelSet(axlAddSelectAll())
            ;SymDt = axlGetSelSet(axlSelect( ))
            foreach(SymDtlp SymDt
                axlVisibleDesign(t)
                SymName = SymDtlp ->name
                SymName = upperCase(SymName)
                pcre = pcreCompile("BACKDRILL_TEST")
                when(pcreExecute(pcre SymName)
                    foreach(PinDtlp SymDtlp ->pins 
                        if(PinDtlp->number == "1" then
                            Pin1NetName = PinDtlp->net->name
                            PinLyrName = "None"

							Pin1NetNameFlt = nth(1 parseString(Pin1NetName "_")) 
							PinLyrName1 = Pin1NetNameFlt 
							
							Pin1NetName1 = nth(0 parseString(Pin1NetName "_")) 
							Pin1NetName2 = nth(1 parseString(Pin1NetName "_")) 
							StrValNum = nil
							StrValAlp = nil
							StrValLen = strlen(Pin1NetName2)
							for(i 1 StrValLen
								TxtPrse = substring(Pin1NetName2 i 1)
								pcre1 = pcreCompile("([0-9]+)")
								when(pcreExecute(pcre1 TxtPrse)
									when(TxtPrse push(TxtPrse StrValNum))
								)
								
								pcre2 = pcreCompile("([A-Z]+)")
								when(pcreExecute(pcre2 TxtPrse)
									when(TxtPrse push(TxtPrse StrValAlp))
								)
							)
							StrValNum = reverse(StrValNum)
							StrValNumStr = buildString(StrValNum "")
							StrValAlp = reverse(StrValAlp)
							StrValAlpStr = buildString(StrValAlp "")
							PinLyrName2 = sprintf(nil "%s-%s", StrValAlpStr, StrValNumStr)

                            if(Pin1NetName != nil && Pin1NetName != "" then
                                for(i 0 LayerLen
                                    LyrName = LayersArr[i]  
                                    LyrNameFlt = nth(1 parseString(LyrName "_")) 
                                    if(LyrNameFlt == PinLyrName1 || LyrNameFlt == PinLyrName2  then
                                        Pin1XYpoint = PinDtlp->xy
                                        Pin1Xpoint = car(PinDtlp->xy)
                                        Pin1Ypoint = cadr(PinDtlp->xy)
                                        Pin1NetName = PinDtlp->net->name
                                        UpDateData = sprintf(nil "%s,%s,(%.2f %.2f), Back Drill Module Updated SuccessFully", SymDtlp->refdes, SymDtlp->name, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                        when(UpDateData push(UpDateData UpdatedList))
                                        foreach(PinDtlp1 SymDtlp ->pins
                                            if(PinDtlp1->number == "2" then
                                                LyrNamePin2 = sprintf(nil "ETCH/%s", LyrName)
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin2 t ) 
                                                axlUIWUpdate(nil)
                                                Pin2XYpoint = PinDtlp1->xy
                                                Pin2Xpoint = car(PinDtlp1->xy)
                                                Pin2Ypoint = cadr(PinDtlp1->xy)
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxShpP3Inp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                BoxShpP3InpList = nil
                                                if(length(BoxShpP3Inp) != 0 then
                                                    foreach(BoxShpP3Inplp BoxShpP3Inp
                                                        SP3NetName = BoxShpP3Inplp->net->name
                                                        if(SP3NetName == "" || SP3NetName == nil  then 
                                                            axlDBDeleteProp(BoxShpP3Inplp '(FIXED))
                                                            axlDeleteObject(BoxShpP3Inplp)
                                                        ) 

                                                    )
                                                )
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxClineInp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxClineInp) != 0 then
                                                    foreach(BoxClineInplp BoxClineInp
                                                        CNetName = BoxClineInplp->net->name
                                                        if(CNetName == Pin1NetName then 
                                                            axlDBDeleteProp(BoxClineInplp '(FIXED))
			                                                axlDeleteObject(BoxClineInplp)
                                                        ) 

                                                    )
                                                )
                                                
                                                CLineCrctPoint = list(Pin1XYpoint Pin2XYpoint)
                                                createdline = axlDBCreateLine(CLineCrctPoint 6 LyrNamePin2 Pin1NetName nil)
                                                axlDBAddProp(car(createdline) list('FIXED))
                                                axlDBAddProp(car(createdline) list('COMMENT "BACKDRILL_MODULE"))
                                                
                                            )

                                            if(PinDtlp1->number == "3" then
                                                LyrNamePin3 = sprintf(nil "ETCH/%s", LayersArr[i + 1])
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin3 t ) 
                                                axlUIWUpdate(nil)
                                                Pin3XYpoint = PinDtlp1->xy
                                                Pin3Xpoint = car(PinDtlp1->xy)
                                                Pin3Ypoint = cadr(PinDtlp1->xy)
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxClineInp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxClineInp) != 0 then
                                                    foreach(BoxClineInplp BoxClineInp
                                                        CNetName = BoxClineInplp->net->name
                                                        if(CNetName == Pin1NetName then 
                                                            axlDBDeleteProp(BoxClineInplp '(FIXED))
			                                                axlDeleteObject(BoxClineInplp)
                                                        ) 

                                                    )
                                                )
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxShpP3Inp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                BoxShpP3InpList = nil
                                                if(length(BoxShpP3Inp) != 0 then
                                                    foreach(BoxShpP3Inplp BoxShpP3Inp
                                                        SP3NetName = BoxShpP3Inplp->net->name
                                                        if(SP3NetName == "" || SP3NetName == nil  then 
                                                            axlDBDeleteProp(BoxShpP3Inplp '(FIXED))
                                                            axlDeleteObject(BoxShpP3Inplp)
                                                        ) 

                                                    )
                                                )
                                                    if(Pin3Xpoint == Pin1Xpoint then                                                       
                                                        if(Pin1Ypoint > Pin3Ypoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin3bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = cadr(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin3StartPoint = car(Pin3bBox)
                                                            Pin3StartPointX = car(Pin3StartPoint) 
                                                            Pin3StartPointY = cadr(Pin3StartPoint)

                                                            P3Point1 = list(Pin3StartPointX + 2 Pin1StartPointY - 2) 
                                                            P3Point2 = list(Pin1StartPointX - 2 Pin1StartPointY - 2) 
                                                            P3Point3 = list(Pin1StartPointX - 2 Pin3StartPointY + 2) 
                                                            P3Point4 = list(Pin3StartPointX + 2 Pin3StartPointY + 2)

                                                            path = axlPathStart(list(P3Point1 P3Point2 P3Point3 P3Point4 P3Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin3 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))

                                                        )

                                                        if(Pin1Ypoint < Pin3Ypoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin3bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = car(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin3StartPoint = cadr(Pin3bBox)
                                                            Pin3StartPointX = car(Pin3StartPoint) 
                                                            Pin3StartPointY = cadr(Pin3StartPoint)

                                                            P3Point1 = list(Pin1StartPointX + 2 Pin3StartPointY - 2) 
                                                            P3Point2 = list(Pin3StartPointX - 2 Pin3StartPointY - 2) 
                                                            P3Point3 = list(Pin3StartPointX - 2 Pin1StartPointY + 2) 
                                                            P3Point4 = list(Pin1StartPointX + 2 Pin1StartPointY + 2)

                                                            path = axlPathStart(list(P3Point1 P3Point2 P3Point3 P3Point4 P3Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin3 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )
                                                    )
                                                    

                                                    if(Pin3Ypoint == Pin1Ypoint then
                                                        if(Pin1Xpoint > Pin3Xpoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin3bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = cadr(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin3StartPoint = car(Pin3bBox)
                                                            Pin3StartPointX = car(Pin3StartPoint) 
                                                            Pin3StartPointY = cadr(Pin3StartPoint)

                                                            P3Point1 = list(Pin3StartPointX + 2 Pin1StartPointY - 2) 
                                                            P3Point2 = list(Pin1StartPointX - 2 Pin1StartPointY - 2) 
                                                            P3Point3 = list(Pin1StartPointX - 2 Pin3StartPointY + 2) 
                                                            P3Point4 = list(Pin3StartPointX + 2 Pin3StartPointY + 2)

                                                            path = axlPathStart(list(P3Point1 P3Point2 P3Point3 P3Point4 P3Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin3 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )

                                                        if(Pin1Xpoint < Pin3Xpoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin3bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = car(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin3StartPoint = cadr(Pin3bBox)
                                                            Pin3StartPointX = car(Pin3StartPoint) 
                                                            Pin3StartPointY = cadr(Pin3StartPoint)

                                                            P3Point1 = list(Pin1StartPointX + 2 Pin3StartPointY - 2) 
                                                            P3Point2 = list(Pin3StartPointX - 2 Pin3StartPointY - 2) 
                                                            P3Point3 = list(Pin3StartPointX - 2 Pin1StartPointY + 2) 
                                                            P3Point4 = list(Pin1StartPointX + 2 Pin1StartPointY + 2)

                                                            path = axlPathStart(list(P3Point1 P3Point2 P3Point3 P3Point4 P3Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin3 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )


                                                    )

                                            )


                                            if(PinDtlp1->number == "4" then
                                                LyrNamePin4 = sprintf(nil "ETCH/%s", LayersArr[i + 2])
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin4 t ) 
                                                axlUIWUpdate(nil)
                                                Pin4XYpoint = PinDtlp1->xy
                                                Pin4Xpoint = car(PinDtlp1->xy)
                                                Pin4Ypoint = cadr(PinDtlp1->xy)

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxClineInp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxClineInp) != 0 then
                                                    foreach(BoxClineInplp BoxClineInp
                                                        CNetName = BoxClineInplp->net->name
                                                        if(CNetName == Pin1NetName then 
                                                            axlDBDeleteProp(BoxClineInplp '(FIXED))
			                                                axlDeleteObject(BoxClineInplp)
                                                        ) 

                                                    )
                                                )
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxShpP4Inp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxShpP4Inp) != 0 then
                                                    foreach(BoxShpP4Inplp BoxShpP4Inp
                                                        SP4NetName = BoxShpP4Inplp->net->name
                                                        if(SP4NetName == "" || SP4NetName == nil  then 
                                                            axlDBDeleteProp(BoxShpP4Inplp '(FIXED))
                                                            axlDeleteObject(BoxShpP4Inplp)
                                                        ) 

                                                    )
                                                )
                                                    if(Pin4Xpoint == Pin1Xpoint then                                                       
                                                        if(Pin1Ypoint > Pin4Ypoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin4bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = cadr(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin4StartPoint = car(Pin4bBox)
                                                            Pin4StartPointX = car(Pin4StartPoint) 
                                                            Pin4StartPointY = cadr(Pin4StartPoint)

                                                            P4Point1 = list(Pin4StartPointX + 2 Pin1StartPointY - 2) 
                                                            P4Point2 = list(Pin1StartPointX - 2 Pin1StartPointY - 2) 
                                                            P4Point3 = list(Pin1StartPointX - 2 Pin4StartPointY + 2) 
                                                            P4Point4 = list(Pin4StartPointX + 2 Pin4StartPointY + 2)

                                                            path = axlPathStart(list(P4Point1 P4Point2 P4Point3 P4Point4 P4Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin4 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )

                                                        if(Pin1Ypoint < Pin4Ypoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin4bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = car(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin4StartPoint = cadr(Pin4bBox)
                                                            Pin4StartPointX = car(Pin4StartPoint) 
                                                            Pin4StartPointY = cadr(Pin4StartPoint)

                                                            P4Point1 = list(Pin1StartPointX + 2 Pin4StartPointY - 2) 
                                                            P4Point2 = list(Pin4StartPointX - 2 Pin4StartPointY - 2) 
                                                            P4Point3 = list(Pin4StartPointX - 2 Pin1StartPointY + 2) 
                                                            P4Point4 = list(Pin1StartPointX + 2 Pin1StartPointY + 2)

                                                            path = axlPathStart(list(P4Point1 P4Point2 P4Point3 P4Point4 P4Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin4 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )
                                                    )
                                                    

                                                    if(Pin4Ypoint == Pin1Ypoint then
                                                        if(Pin1Xpoint > Pin4Xpoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin4bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = cadr(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin4StartPoint = car(Pin4bBox)
                                                            Pin4StartPointX = car(Pin4StartPoint) 
                                                            Pin4StartPointY = cadr(Pin4StartPoint)

                                                            P4Point1 = list(Pin4StartPointX + 2 Pin1StartPointY - 2) 
                                                            P4Point2 = list(Pin1StartPointX - 2 Pin1StartPointY - 2) 
                                                            P4Point3 = list(Pin1StartPointX - 2 Pin4StartPointY + 2) 
                                                            P4Point4 = list(Pin4StartPointX + 2 Pin4StartPointY + 2)

                                                            path = axlPathStart(list(P4Point1 P4Point2 P4Point3 P4Point4 P4Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin4 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )

                                                        if(Pin1Xpoint < Pin4Xpoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin4bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = car(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin4StartPoint = cadr(Pin4bBox)
                                                            Pin4StartPointX = car(Pin4StartPoint) 
                                                            Pin4StartPointY = cadr(Pin4StartPoint)

                                                            P4Point1 = list(Pin1StartPointX + 2 Pin4StartPointY - 2) 
                                                            P4Point2 = list(Pin4StartPointX - 2 Pin4StartPointY - 2) 
                                                            P4Point3 = list(Pin4StartPointX - 2 Pin1StartPointY + 2) 
                                                            P4Point4 = list(Pin1StartPointX + 2 Pin1StartPointY + 2)

                                                            path = axlPathStart(list(P4Point1 P4Point2 P4Point3 P4Point4 P4Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin4 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )


                                                    )

                                            )



                                            if(PinDtlp1->number == "5" then
                                                LyrNamePin5 = sprintf(nil "ETCH/%s", LayersArr[i + 3])
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin5 t ) 
                                                axlUIWUpdate(nil)
                                                Pin5XYpoint = PinDtlp1->xy
                                                Pin5Xpoint = car(PinDtlp1->xy)
                                                Pin5Ypoint = cadr(PinDtlp1->xy)
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxClineInp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxClineInp) != 0 then
                                                    foreach(BoxClineInplp BoxClineInp
                                                        CNetName = BoxClineInplp->net->name
                                                        if(CNetName == Pin1NetName then 
                                                            axlDBDeleteProp(BoxClineInplp '(FIXED))
			                                                axlDeleteObject(BoxClineInplp)
                                                        ) 

                                                    )
                                                )
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxShpP5Inp = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxShpP5Inp) != 0 then
                                                    foreach(BoxShpP5Inplp BoxShpP5Inp
                                                        SP5NetName = BoxShpP5Inplp->net->name
                                                        if(SP5NetName == "" || SP5NetName == nil  then 
                                                            axlDBDeleteProp(BoxShpP5Inplp '(FIXED))
                                                            axlDeleteObject(BoxShpP5Inplp)
                                                        ) 

                                                    )
                                                )
                                                    if(Pin5Xpoint == Pin1Xpoint then                                                       
                                                        if(Pin1Ypoint > Pin5Ypoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin5bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = cadr(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin5StartPoint = car(Pin5bBox)
                                                            Pin5StartPointX = car(Pin5StartPoint) 
                                                            Pin5StartPointY = cadr(Pin5StartPoint)

                                                            P5Point1 = list(Pin5StartPointX + 2 Pin1StartPointY - 2) 
                                                            P5Point2 = list(Pin1StartPointX - 2 Pin1StartPointY - 2) 
                                                            P5Point3 = list(Pin1StartPointX - 2 Pin5StartPointY + 2) 
                                                            P5Point4 = list(Pin5StartPointX + 2 Pin5StartPointY + 2)

                                                            path = axlPathStart(list(P5Point1 P5Point2 P5Point3 P5Point4 P5Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin5 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )

                                                        if(Pin1Ypoint < Pin5Ypoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin5bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = car(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin5StartPoint = cadr(Pin5bBox)
                                                            Pin5StartPointX = car(Pin5StartPoint) 
                                                            Pin5StartPointY = cadr(Pin5StartPoint)

                                                            P5Point1 = list(Pin1StartPointX + 2 Pin5StartPointY - 2) 
                                                            P5Point2 = list(Pin5StartPointX - 2 Pin5StartPointY - 2) 
                                                            P5Point3 = list(Pin5StartPointX - 2 Pin1StartPointY + 2) 
                                                            P5Point4 = list(Pin1StartPointX + 2 Pin1StartPointY + 2)

                                                            path = axlPathStart(list(P5Point1 P5Point2 P5Point3 P5Point4 P5Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin5 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )
                                                    )
                                                    

                                                    if(Pin5Ypoint == Pin1Ypoint then
                                                        if(Pin1Xpoint > Pin5Xpoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin5bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = cadr(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin5StartPoint = car(Pin5bBox)
                                                            Pin5StartPointX = car(Pin5StartPoint) 
                                                            Pin5StartPointY = cadr(Pin5StartPoint)

                                                            P5Point1 = list(Pin5StartPointX + 2 Pin1StartPointY - 2) 
                                                            P5Point2 = list(Pin1StartPointX - 2 Pin1StartPointY - 2) 
                                                            P5Point3 = list(Pin1StartPointX - 2 Pin5StartPointY + 2) 
                                                            P5Point4 = list(Pin5StartPointX + 2 Pin5StartPointY + 2)

                                                            path = axlPathStart(list(P5Point1 P5Point2 P5Point3 P5Point4 P5Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin5 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                        )

                                                        if(Pin1Xpoint < Pin5Xpoint then
                                                            Pin1bBox = PinDtlp->bBox
                                                            Pin5bBox = PinDtlp1->bBox

                                                            Pin1StartPoint = car(Pin1bBox)
                                                            Pin1StartPointX = car(Pin1StartPoint) 
                                                            Pin1StartPointY = cadr(Pin1StartPoint) 

                                                            Pin5StartPoint = cadr(Pin5bBox)
                                                            Pin5StartPointX = car(Pin5StartPoint) 
                                                            Pin5StartPointY = cadr(Pin5StartPoint)

                                                            P5Point1 = list(Pin1StartPointX + 2 Pin5StartPointY - 2) 
                                                            P5Point2 = list(Pin5StartPointX - 2 Pin5StartPointY - 2) 
                                                            P5Point3 = list(Pin5StartPointX - 2 Pin1StartPointY + 2) 
                                                            P5Point4 = list(Pin1StartPointX + 2 Pin1StartPointY + 2)

                                                            path = axlPathStart(list(P5Point1 P5Point2 P5Point3 P5Point4 P5Point1))
                                                            shape = axlDBCreateShape(path t LyrNamePin5 nil nil)
                                                            axlDBAddProp(car(shape) list('FIXED))
                                                            axlDBAddProp(car(shape) list('OK_UNASSIGNED_SHAPE))
                                                            axlDBAddProp(car(shape) list('COMMENT "BACKDRILL_MODULE"))
                                                            
                                                        )


                                                    )
                                            )



                                        )
                                    ) 
                                )
                            )

                        )
                    )
                )
            )
            axlVisibleSet(originalVisible)
            axlClearSelSet()
            axlShell("Done")

            if(UpdatedList != nil then
                UpdatedList = unique(UpdatedList)
                UpdatedListLen = length(UpdatedList)
                logfile1 = "BackDrillModule.log"
                designName = axlCurrentDesign()
                design_path = axlGetDrawingName()
                design_unit = car(axlDBGetDesignUnits())
                port1 = axlDMOpenLog(logfile1)
                fprintf(port1, "Design name: %s\n", design_path)
                fprintf(port1, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                fprintf(port1, "%s\n\n", "BackDrill Module : Updated List")
                fprintf(port1, "\n")
                fprintf(port1, "%s%d\n\n", "Total No of Updates - ", UpdatedListLen)
                fprintf(port1, "%-25s %-25s %-25s\n\n", "REFDES", "SYM NAME", "XY LOCATION")
                foreach(UpdatedListlp UpdatedList
                    UpdatedListlpprse = parseString(UpdatedListlp ",")
                    fprintf(port1, "%-25s %-25s %-25s %-25s\n", nth(0 UpdatedListlpprse), nth(1 UpdatedListlpprse), nth(2 UpdatedListlpprse), nth(3 UpdatedListlpprse))
                )
                fprintf(port1, "\n\n")
                fprintf(port1, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                axlDMClose(port1)
                axlUIViewFileCreate(logfile1, "BackDrill Module Update", nil, '(30 25), '(CENTER))
            else
                axlUIConfirm("No Updates Found...!")
            )
		)
		
		
		("CHK"
            ErrorList = nil
            originalVisible=axlVisibleGet()
            CWidVal = axlEnterString(?prompts list("Enter the Cline Width Value.."))
            CWidValFlt = atof(CWidVal)
            CWidValFltStr = sprintf(nil "%.2f", CWidValFlt)
            CwidValStr = sprintf(nil "Entered Cline Width Value : %s" CWidVal)
            axlVisibleDesign(t)
            etchparam = axlGetParam("paramLayerGroup:ETCH")
            l_layers = etchparam->groupMembers
            LayerLen = length(l_layers) - 1
            LayersArr = listToVector(l_layers)
            axlClearSelSet()
            axlSetFindFilter(?enabled `("NOALL" "SYMBOLS") ?onButtons `("SYMBOLS"))
            SymDt = axlGetSelSet(axlAddSelectAll())
            ;SymDt = axlGetSelSet(axlSelect( ))
            foreach(SymDtlp SymDt
                axlVisibleDesign(t)
                SymName = SymDtlp ->name
                SymName = upperCase(SymName)
                pcre = pcreCompile("BACKDRILL_TEST")
                when(pcreExecute(pcre SymName)
                    foreach(PinDtlp SymDtlp ->pins 
                        if(PinDtlp->number == "1" then
                            Pin1NetName = PinDtlp->net->name
                            PinLyrName = "None"

							Pin1NetNameFlt = nth(1 parseString(Pin1NetName "_")) 
							PinLyrName1 = Pin1NetNameFlt 

							Pin1NetName1 = nth(0 parseString(Pin1NetName "_")) 
							Pin1NetName2 = nth(1 parseString(Pin1NetName "_")) 
							StrValNum = nil
							StrValAlp = nil
							StrValLen = strlen(Pin1NetName2)
							for(i 1 StrValLen
								TxtPrse = substring(Pin1NetName2 i 1)
								pcre1 = pcreCompile("([0-9]+)")
								when(pcreExecute(pcre1 TxtPrse)
									when(TxtPrse push(TxtPrse StrValNum))
								)
								
								pcre2 = pcreCompile("([A-Z]+)")
								when(pcreExecute(pcre2 TxtPrse)
									when(TxtPrse push(TxtPrse StrValAlp))
								)
							)
							StrValNum = reverse(StrValNum)
							StrValNumStr = buildString(StrValNum "")
							StrValAlp = reverse(StrValAlp)
							StrValAlpStr = buildString(StrValAlp "")
							PinLyrName2 = sprintf(nil "%s-%s", StrValAlpStr, StrValNumStr)
                            

                            if(Pin1NetName != nil && Pin1NetName != "" then
                                for(i 0 LayerLen
                                    LyrName = LayersArr[i]  
                                    LyrNameFlt = nth(1 parseString(LyrName "_")) 
                                    if(LyrNameFlt == PinLyrName1 || LyrNameFlt == PinLyrName2 then
                                        Pin1XYpoint = PinDtlp->xy
                                        Pin1Xpoint = car(PinDtlp->xy)
                                        Pin1Ypoint = cadr(PinDtlp->xy)
                                        Pin1NetName = PinDtlp->net->name
                                        foreach(PinDtlp1 SymDtlp ->pins
                                            if(PinDtlp1->number == "2" then
                                                LyrNamePin2 = sprintf(nil "ETCH/%s", LyrName)
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin2 t ) 
                                                axlUIWUpdate(nil)
                                                Pin2XYpoint = PinDtlp1->xy
                                                Pin2Xpoint = car(PinDtlp1->xy)
                                                Pin2Ypoint = cadr(PinDtlp1->xy)
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxP2Chk = axlGetSelSet(axlSingleSelectBox( list(Pin2Xpoint:Pin2Ypoint Pin2Xpoint:Pin2Ypoint)))
                                                if(length(BoxP2Chk) == 0 then
                                                    ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: CLine Not Found In this 2nd Pin..", SymDtlp->refdes, SymDtlp->name, LyrNamePin2, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                    when(ErrorData push(ErrorData ErrorList))
                                                else
                                                    foreach(BoxP2Chklp BoxP2Chk
                                                        CSegWid = car(BoxP2Chklp->segments)
                                                        CwidValInp = sprintf(nil "%.2f", CSegWid->width) 
                                                        if(CWidValFltStr != CwidValInp then 
                                                            ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: CLine Width Missmatched..", SymDtlp->refdes, SymDtlp->name, LyrNamePin2, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                            when(ErrorData push(ErrorData ErrorList))
                                                        )
                                                    )

                                                )

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxP1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                
                                                if(length(BoxP1Chk) > 1 then
                                                    ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Multiple Clines Found..", SymDtlp->refdes, SymDtlp->name, LyrNamePin2, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                    when(ErrorData push(ErrorData ErrorList)) 
                                                )

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxS1Chk) > 0 then
                                                    foreach(BoxS1Chklp BoxS1Chk
                                                        BoxS1ChklpNetNAme = BoxS1Chklp->net->name
                                                        if(BoxS1ChklpNetNAme == "" || BoxS1ChklpNetNAme == nil  then 
                                                            ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Found in 2nd Pin Layer..", SymDtlp->refdes, SymDtlp->name, LyrNamePin2, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                            when(ErrorData push(ErrorData ErrorList)) 
                                                        )
                                                    )
                                                )
                                                
                                            )

                                            if(PinDtlp1->number == "3" then
                                                LyrNamePin3 = sprintf(nil "ETCH/%s", LayersArr[i + 1])
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin3 t ) 
                                                axlUIWUpdate(nil)
                                                Pin3XYpoint = PinDtlp1->xy
                                                Pin3Xpoint = car(PinDtlp1->xy)
                                                Pin3Ypoint = cadr(PinDtlp1->xy)

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS3Chk = axlGetSelSet(axlSingleSelectBox( list(Pin3Xpoint:Pin3Ypoint Pin3Xpoint:Pin3Ypoint)))
                                                
                                                if(length(BoxS3Chk) > 0 then
                                                    DummyVar = "False"
                                                    foreach(BoxS3Chklp BoxS3Chk
                                                        BoxS3ChklpNetNAme = BoxS3Chklp->net->name
                                                        if(BoxS3ChklpNetNAme == "" || BoxS3ChklpNetNAme == nil  then
                                                            DummyVar = "True"
                                                        )
                                                    )

                                                    if(DummyVar == "False" then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Missing..", SymDtlp->refdes, SymDtlp->name, LyrNamePin3, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    )
                                                
                                                else
                                                    ;if(length(BoxS4Chk) == 0 then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Missing..", SymDtlp->refdes, SymDtlp->name, LyrNamePin3, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    ;)
                                                )


                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS3P1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxS3P1Chk) > 1 then
                                                    Count = 0
                                                    foreach(BoxS3P1Chklp BoxS3P1Chk
                                                        BoxS3P1ChkNetName = BoxS3P1Chklp->net->name 
                                                        if(BoxS3P1ChkNetName == "" || BoxS3P1ChkNetName == nil  then
                                                            Count = Count + 1
                                                        )
                                                    )

                                                    if(Count > 1 then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Multiple Shapes Found..", SymDtlp->refdes, SymDtlp->name, LyrNamePin3, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    )

                                                )

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxC3P1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxC3P1Chk) != 0 then
                                                    ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Cline Found In this 3rd Pin layer..", SymDtlp->refdes, SymDtlp->name, LyrNamePin3, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                    when(ErrorData push(ErrorData ErrorList))
                                                )

                                            )


                                            if(PinDtlp1->number == "4" then
                                                LyrNamePin4 = sprintf(nil "ETCH/%s", LayersArr[i + 2])
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin4 t ) 
                                                axlUIWUpdate(nil)
                                                Pin4XYpoint = PinDtlp1->xy
                                                Pin4Xpoint = car(PinDtlp1->xy)
                                                Pin4Ypoint = cadr(PinDtlp1->xy)
                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS4Chk = axlGetSelSet(axlSingleSelectBox( list(Pin4Xpoint:Pin4Ypoint Pin4Xpoint:Pin4Ypoint)))
                                                
                                                if(length(BoxS4Chk) > 0 then
                                                    DummyVar = "False"
                                                    foreach(BoxS4Chklp BoxS4Chk
                                                        BoxS4ChklpNetNAme = BoxS4Chklp->net->name
                                                        if(BoxS4ChklpNetNAme == "" || BoxS4ChklpNetNAme == nil  then
                                                            DummyVar = "True"
                                                        )
                                                    )
                                                    if(DummyVar == "False" then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Missing..", SymDtlp->refdes, SymDtlp->name, LyrNamePin4, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    )
                                                
                                                else
                                                    ;if(length(BoxS4Chk) == 0 then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Missing..", SymDtlp->refdes, SymDtlp->name, LyrNamePin4, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    ;)
                                                )

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS4P1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxS4P1Chk) > 1 then
                                                    Count = 0
                                                    foreach(BoxS4P1Chklp BoxS4P1Chk
                                                        BoxS4P1ChkNetName = BoxS4P1Chklp->net->name 
                                                        if(BoxS4P1ChkNetName == "" || BoxS4P1ChkNetName == nil  then
                                                            Count = Count + 1
                                                        )
                                                    )

                                                    if(Count > 1 then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Multiple Shapes Found..", SymDtlp->refdes, SymDtlp->name, LyrNamePin4, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    )

                                                )

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxC4P1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxC4P1Chk) != 0 then
                                                    ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Cline Found In this 4th Pin layer..", SymDtlp->refdes, SymDtlp->name, LyrNamePin4, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                    when(ErrorData push(ErrorData ErrorList))
                                                )

                                            )


                                            if(PinDtlp1->number == "5" then
                                                LyrNamePin5 = sprintf(nil "ETCH/%s", LayersArr[i + 3])
                                                axlVisibleDesign(nil)
                                                axlVisibleLayer(LyrNamePin5 t ) 
                                                axlUIWUpdate(nil)
                                                Pin5XYpoint = PinDtlp1->xy
                                                Pin5Xpoint = car(PinDtlp1->xy)
                                                Pin5Ypoint = cadr(PinDtlp1->xy)


                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS5Chk = axlGetSelSet(axlSingleSelectBox( list(Pin5Xpoint:Pin5Ypoint Pin5Xpoint:Pin5Ypoint)))
                                                
                                                if(length(BoxS5Chk) > 0 then
                                                    DummyVar = "False"
                                                    foreach(BoxS5Chklp BoxS5Chk
                                                        BoxS5ChklpNetNAme = BoxS5Chklp->net->name
                                                        if(BoxS5ChklpNetNAme == "" || BoxS5ChklpNetNAme == nil  then
                                                            DummyVar = "True"
                                                        )
                                                    )

                                                    if(DummyVar == "False" then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Missing..", SymDtlp->refdes, SymDtlp->name, LyrNamePin5, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    )
                                                
                                                else
                                                    ;if(length(BoxS4Chk) == 0 then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Shape Missing..", SymDtlp->refdes, SymDtlp->name, LyrNamePin5, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    ;)
                                                )


                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
                                                BoxS5P1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxS5P1Chk) > 1 then
                                                    Count = 0
                                                    foreach(BoxS5P1Chklp BoxS5P1Chk
                                                        BoxS5P1ChkNetName = BoxS5P1Chklp->net->name 
                                                        if(BoxS5P1ChkNetName == "" || BoxS5P1ChkNetName == nil  then
                                                            Count = Count + 1
                                                        )
                                                    )

                                                    if(Count > 1 then
                                                        ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Multiple Shapes Found..", SymDtlp->refdes, SymDtlp->name, LyrNamePin5, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                        when(ErrorData push(ErrorData ErrorList))
                                                    )

                                                )

                                                axlClearSelSet()
                                                axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
                                                BoxC5P1Chk = axlGetSelSet(axlSingleSelectBox( list(Pin1Xpoint:Pin1Ypoint Pin1Xpoint:Pin1Ypoint)))
                                                if(length(BoxC5P1Chk) != 0 then
                                                    ErrorData = sprintf(nil "%s,%s,%s,(%.2f %.2f),Error: Cline Found In this 5th Pin layer..", SymDtlp->refdes, SymDtlp->name, LyrNamePin5, car(SymDtlp->xy), cadr(SymDtlp->xy))
                                                    when(ErrorData push(ErrorData ErrorList))
                                                )
                                            )
                                        )
                                    ) 
                                )
                            )

                        )
                    )
                )
            )
            axlVisibleSet(originalVisible)
            axlClearSelSet()
            axlShell("Done")

            if(ErrorList != nil then
                ErrorList = unique(ErrorList)
                ErrorListLen = length(ErrorList)
                logfile2 = "BackDrillModuleError.log"
                designName = axlCurrentDesign()
                design_path = axlGetDrawingName()
                design_unit = car(axlDBGetDesignUnits())
                port2 = axlDMOpenLog(logfile2)
                fprintf(port2, "Design name: %s\n", design_path)
                fprintf(port2, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                fprintf(port2, "%s\n\n", "BackDrill Module : Error List")
                fprintf(port2, "\n")
                fprintf(port2, "%s%d\n\n", "Total No of Errors - ", ErrorListLen)
                fprintf(port2, "%-25s %-25s %-25s %-25s %-25s\n\n", "REFDES", "SYM NAME", "LAYER", "XY LOCATION", "ERROR")
                foreach(ErrorListlp ErrorList
                    ErrorListlpPrse = parseString(ErrorListlp ",")
                    fprintf(port2, "%-25s %-25s %-25s %-25s %-25s\n", nth(0 ErrorListlpPrse), nth(1 ErrorListlpPrse), nth(2 ErrorListlpPrse), nth(3 ErrorListlpPrse), nth(4 ErrorListlpPrse))
                )
                fprintf(port2, "\n\n")
                fprintf(port2, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                axlDMClose(port2)
                axlUIViewFileCreate(logfile2, "BackDrill Module Error", nil, '(30 25), '(CENTER))
            else
                axlUIConfirm("No Error Found...!")
            )

		)
	)
	axlFormDisplay(BDM_form)
)

