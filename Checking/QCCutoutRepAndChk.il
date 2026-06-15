axlCmdRegister("QCCutoutRepAndChk" 'QCCutoutRepAndChk)
(setq CRCform_file "QCCutoutRepAndChk.form") 
procedure(QCCutoutRepAndChk()
	axlShell("Done")
	CreateCRCform()
	RunCRCform()
)

procedure(RunCRCform() 
	let((CRCform)
		(CRCform = axlFormCreate(gensym() CRCform_file nil 'CRCAction t)) 
		axlFormDisplay(CRCform)
	)
)

procedure(CreateCRCform()
	let((CRCform)
		(CRCform = outfile(CRCform_file "w")) 
		fprintf(CRCform "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(CRCform "FORM\n") 
		fprintf(CRCform "FIXED\n") 
		fprintf(CRCform "PORT 37 50\n") 
		fprintf(CRCform "HEADER \"QC CUTOUT CHECK AND REPORT\"\n") 
		fprintf(CRCform "\n")
		fprintf(CRCform "TILE\n")
		
	
		fprintf(CRCform "TEXT \"    -- CUTOUT CHECK AND REPORT -- \"\n")
		fprintf(CRCform "TLOC 5 2\n")
		fprintf(CRCform "ENDTEXT\n")
		
		fprintf(CRCform "TEXT \"   --------------------------------------------------------------------------\"\n")
		fprintf(CRCform "TLOC 2 4\n")
		fprintf(CRCform "ENDTEXT\n")

        fprintf(CRCform "TEXT \"ENTER GND REGION VALUE :\"\n")
		fprintf(CRCform "TLOC 2 7\n")
		fprintf(CRCform "ENDTEXT\n")
		
		
		fprintf(CRCform "FIELD %s\n" "GNDVAL") 
		fprintf(CRCform "FLOC 25 7\n")
		fprintf(CRCform "STRFILLIN 5 5\n")
		fprintf(CRCform "ENDFIELD\n") 
		fprintf(CRCform "\n")
		
		fprintf(CRCform "FIELD BGA\n")	
	    fprintf(CRCform "FLOC 10 11\n")
	    fprintf(CRCform "CHECKLIST \"BGA - CUTOUT\" \"crc\"\n")
	    fprintf(CRCform "ENDFIELD\n")
		
		fprintf(CRCform "FIELD IC\n")	
	    fprintf(CRCform "FLOC 10 15\n")
	    fprintf(CRCform "CHECKLIST \"PASSIVE - IC - POGO\" \"crc\"\n")
	    fprintf(CRCform "ENDFIELD\n")
		
		
		fprintf(CRCform "FIELD PROC\n") 
		fprintf(CRCform "FLOC 7 20\n") 
		fprintf(CRCform "MENUBUTTON \"CLICK HERE TO PROCEED....!\" 20 4\n") 
		fprintf(CRCform "ENDFIELD\n")
		fprintf(CRCform "\n")
		

		fprintf(CRCform "\n") 
		fprintf(CRCform "\n") 
		fprintf(CRCform "ENDTILE\n")
		
		fprintf(CRCform "\n") 
		fprintf(CRCform "ENDFORM\n")
		
		drain() 
		close(CRCform)
	)
)

procedure(CRCAction(CRCform) 
	case((CRCform->curField)
		("PROC"
			(Get_BGA = (axlFormGetField CRCform "BGA"))	
	        (Get_IC = (axlFormGetField CRCform "IC"))
            (Get_Gnd = (axlFormGetField CRCform "GNDVAL"))

            if(Get_BGA == "" then 
                Gnd_Val = 0
            else
                Gnd_Val = atof(Get_Gnd)
            )

            if(Get_BGA == nil && Get_IC == nil then 
                axlUIConfirm( "Oops : Required Input Is Not Selected..!" )
            else
                if(Get_BGA then
                    axlMsgPut("---BGA Cutout Check and Report---")
                    axlUIConfirm("Please Select the Pin Details List...!")

                    PinNameList = nil
					CRC_Brow = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
					CRC_OpenFile = axlDMFileParts(CRC_Brow)
					CRC_DataInFile = axlDMOpenFile("ALLEGRO_TEXT" cadr(CRC_OpenFile) "r") 
						while(gets(CRC_Inp_Val CRC_DataInFile)
							CRC_Inp_Val = car(parseString(CRC_Inp_Val "\n"))
								when(CRC_Inp_Val push(CRC_Inp_Val PinNameList))
							)
					axlDMClose(CRC_DataInFile)

                    if(PinNameList == nil then
                        axlUIConfirm("Oops : Selected Input File Is Empty...!")
                    else
                        ErrorListMissing = nil
                        ErrorList = nil
                        ReportList = nil
                        foreach(PinNameListlp PinNameList
                            InpRefName = nth(0 parseString(PinNameListlp "."))
                            InpPinNum = nth(1 parseString(PinNameListlp "."))
                            SymId = axlDBFindByName('refdes InpRefName)

                            DummyVar1 = "No"
                            foreach(PinIdlp SymId->pins
                                PinNum = PinIdlp->number
                                if(PinNum == InpPinNum then 
                                    DummyVar1 = "Yes"

                                    PinXYpoint = PinIdlp->xy
                                    PinXpoint = car(PinIdlp->xy)
                                    PinYpoint = cadr(PinIdlp->xy)
                                    PinXYPointPass = sprintf(nil "(%.3f %.3f)", PinXpoint, PinYpoint)

                                    DiffPairName1 = PinIdlp->net->diffpair->name

                                    ConDt = axlDBGetConnect(PinIdlp t)
                                    
                                    DummyVar2 = "No"
                                    foreach(ConDtlp ConDt
                                        if(ConDtlp->objType == "via" then
                                            DummyVar2 = "Yes"
                                            ViaPadName = ConDtlp->name
                                            ViaDrill = sprintf(nil "%.3f" ConDtlp->definition->drillDiameter)
                                            ViaXYPointPass = sprintf(nil "(%.3f %.3f)", car(ConDtlp->xy), cadr(ConDtlp->xy))
                                            ViaPlated = ConDtlp->isThrough
                                        )
                                    )

                                    if(DummyVar2 == "No" then
                                        ErrorMissingVia = sprintf(nil "%s - Error : Via Not Found..", PinNameListlp)
                                        when(ErrorMissingVia push(ErrorMissingVia ErrorListMissing))
                                    else

                                        C_BoxTopX = PinXpoint - Gnd_Val 
                                        C_BoxTopY = PinYpoint + Gnd_Val
                                        C_BoxBotX = PinXpoint + Gnd_Val
                                        C_BoxBotY = PinYpoint - Gnd_Val

                                        GndSort = nil

                                        axlClearSelSet()
                                        axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
                                        BoxViaInp = axlGetSelSet(axlSingleSelectBox( list(C_BoxTopX:C_BoxTopY C_BoxBotX:C_BoxBotY)))

                                        DummyVar3 = "No"
                                        DummyVar4 = "No"

                                        if(BoxViaInp != nil then
                                            foreach(BoxViaInplp BoxViaInp
                                                ViaNetName = BoxViaInplp->net->name
                                                ViaXYPoint = sprintf(nil "(%.3f %.3f)", car(BoxViaInplp->xy), cadr(BoxViaInplp->xy))
                                                if(ViaXYPoint != PinXYPointPass then
                                                    pcre1 = pcreCompile("GND")
                                                    when(pcreExecute(pcre1 ViaNetName)
                                                        DummyVar3 = "Yes"
                                                        GndXYPoint = BoxViaInplp->xy
                                                        DistVal = axlDistance(GndXYPoint PinXYpoint)
                                                        GndViaDrill = sprintf(nil "%.3f" BoxViaInplp->definition->drillDiameter)
                                                        GndDtPass = sprintf(nil "%.3f,%s,%s", DistVal, BoxViaInplp->name, GndViaDrill)
                                                        when(GndDtPass push(GndDtPass GndSort))
                                                    )


                                                    DiffPairName2 = BoxViaInplp->net->diffpair->name
                                                    if(DiffPairName2 != nil then
                                                        if(DiffPairName2 == DiffPairName1 && PinIdlp->net->name != BoxViaInplp->net->name then
                                                            ;FirstXpoint = sprintf(nil "%.3f", car(PinIdlp->xy))
                                                            ;FirstYpoint = sprintf(nil "%.3f", cadr(PinIdlp->xy))
                                                            ;SecXpoint = sprintf(nil "%.3f", car(BoxViaInplp->xy))
                                                            ;SecYpoint = sprintf(nil "%.3f", cadr(BoxViaInplp->xy))

                                                            ;FirstXpoint = atof(FirstXpoint)
                                                            ;FirstYpoint = atof(FirstYpoint)
                                                            ;SecXpoint = atof(SecXpoint)
                                                            ;SecYpoint = atof(SecYpoint)

                                                            ;MidXpointCal1 = FirstXpoint + SecXpoint
                                                            ;MidXpoint = MidXpointCal1 / 2

                                                            ;MidYpointCal1 = FirstYpoint + SecYpoint
                                                            ;MidYpoint = MidYpointCal1 / 2

                                                            midXY = axlMidPointLine(list(PinIdlp->xy BoxViaInplp->xy))
                                                            midXYPass = sprintf(nil "(%.3f %.3f)", car(midXY), cadr(midXY))
                                                            println(midXYPass)

                                                            DummyVar4 = "Yes"
                                                        ) 
                                                    )
                                                )
                                            )
                                        )

                                        if(DummyVar3 == "No" then
                                            GndValue = "-----,GND VIA IS FAR,-----"
                                        else
                                            GndSort = unique(GndSort)
                                            GndSort = sort(GndSort 'alphalessp)
                                            GndValue = car(GndSort)
                                        )

                                        if(DummyVar4 == "No" then
                                            midXYPass = PinXYPointPass
                                        )
                                        
                                        DummyVar5 = "No"
                                        foreach(SymDtLp axlDBGetDesign() ->symbols
                                            SymXYPoint = sprintf(nil "(%.3f %.3f)", car(SymDtLp->xy), cadr(SymDtLp->xy))
                                            if(SymXYPoint == midXYPass then
                                                SymName = SymDtLp->name
                                                SymXYPointPass = sprintf(nil "(%.3f %.3f)", car(SymDtLp->xy), cadr(SymDtLp->xy))
                                                DummyVar5 = "Yes"
                                            )
                                        )

                                        if(DummyVar5 == "No" then
                                            SymXYPointPass = "NIL"
                                            SymName = "NIL"
                                        )
                                        

                                        GndValuePrse = parseString(GndValue ",")
                                        FinalDt = sprintf(nil "%s,%s,%s,CIRCLE_DRILL  : %s,CIRCLE_DRILL  : %s,%s,%s,SYMBOL NAME : %s,%s", PinNameListlp, ViaPadName, nth(1 GndValuePrse), ViaDrill, nth(2 GndValuePrse), PinXYPointPass, ViaXYPointPass, SymName, SymXYPointPass)
                                        when(FinalDt push(FinalDt ReportList))

                                        if(SymName == "NIL" then
                                            ErrFinalDt1 = sprintf(nil "%s,%s,%s,CIRCLE_DRILL  : %s,CIRCLE_DRILL  : %s,%s,%s,SYMBOL NAME : %s,%s, Error : Symbol Mismatched or Not Found", PinNameListlp, ViaPadName, nth(1 GndValuePrse), ViaDrill, nth(2 GndValuePrse), PinXYPointPass, ViaXYPointPass, SymName, SymXYPointPass)
                                            when(ErrFinalDt1 push(ErrFinalDt1 ErrorList))
                                        )

                                        if(GndValue == "-----,GND VIA IS FAR,-----" then
                                            ErrFinalDt2 = sprintf(nil "%s,%s,%s,CIRCLE_DRILL  : %s,CIRCLE_DRILL  : %s,%s,%s,SYMBOL NAME : %s,%s, Error : GND Net Is Too Far", PinNameListlp, ViaPadName, nth(1 GndValuePrse), ViaDrill, nth(2 GndValuePrse), PinXYPointPass, ViaXYPointPass, SymName, SymXYPointPass)
                                            when(ErrFinalDt2 push(ErrFinalDt2 ErrorList))
                                        )

                                        if(PinXYPointPass != ViaXYPointPass then
                                            ErrFinalDt3 = sprintf(nil "%s,%s,%s,CIRCLE_DRILL  : %s,CIRCLE_DRILL  : %s,%s,%s,SYMBOL NAME : %s,%s, Error : BGA Pin and Sig Via Location Mismatched", PinNameListlp, ViaPadName, nth(1 GndValuePrse), ViaDrill, nth(2 GndValuePrse), PinXYPointPass, ViaXYPointPass, SymName, SymXYPointPass)
                                            when(ErrFinalDt3 push(ErrFinalDt3 ErrorList))
                                        )

                                    )

                                )
                            )
                            
                            if(DummyVar1 == "No" then
                                ErrorMissingPin = sprintf(nil "%s - Error : Pin Not Found Check The Input..", PinNameListlp)
                                when(ErrorMissingPin push(ErrorMissingPin ErrorListMissing))
                            )
                        )
                    )


                    ErrorList = unique(ErrorList)
                    ErrorList = sort(ErrorList 'alphalessp)

                    ErrorListMissing = unique(ErrorListMissing)
                    ErrorListMissing = sort(ErrorListMissing 'alphalessp)

                    ReportList = unique(ReportList)
                    ReportList = sort(ReportList 'alphalessp)

                    if(ReportList != nil then
                        out = outfile("QC_BGA-CutoutReport.CSV")
                        fprintf(out, "%s,%s,%s,%s,%s,%s,%s,%s,%s \n\n", "BGA-PIN-NUM", "SIG-VIA-PADSTACK-NAME", "GND-VIA-PADSTACK-NAME", "SIG-VIA-SIZE", "GND-VIA-SIZE", "BGA-PIN-XY LOCATION", "PAD-ON-SIG VIA-XY LOCATION", "BGA-CUTOUT-FOOTPRINT-NAME", "BGA-CUTOUT-FOOTPRINT-XY LOCATION")
                        
                        foreach(ReportListlp ReportList
                            fprintf(out, "%s \n", ReportListlp) 
                        )
                        close(out)	

                        axlUIConfirm( "QC_BGA-CutoutReport.csv Report Generated Successfully..!" )
                    else
                        axlUIConfirm( "No Records Found To Generate Report..!" ) 
                    )

                    
                    if(ErrorList != nil || ErrorListMissing != nil then
                        logfile = "QC_BGA_CutoutReport.log"
                        designName = axlCurrentDesign()
                        design_path = axlGetDrawingName()
                        design_unit = car(axlDBGetDesignUnits())
                        port = axlDMOpenLog(logfile)
                        fprintf(port, "Design name: %s\n", design_path)
                        fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                        
                        if(ErrorList != nil then
                            fprintf(port, "%s\n\n", "MISSMATCH :")
                            fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s %-35s %-35s %-35s\n\n", "BGA-PIN-NUM", "SIG-VIA-PADSTACK-NAME", "GND-VIA-PADSTACK-NAME", "SIG-VIA-SIZE", "GND-VIA-SIZE", "BGA-PIN-XY LOCATION", "PAD-ON-SIG VIA-XY LOCATION", "BGA-CUTOUT-FOOTPRINT-NAME", "BGA-CUTOUT-FOOTPRINT-XY LOCATION", "ERROR")
                            foreach(FinalListSlp ErrorList
                                FinalListS_filt = parseString(FinalListSlp ",") 
                                fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s %-25s %-35s %-35s %-35s\n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt) , nth(3 FinalListS_filt), nth(4 FinalListS_filt), nth(5 FinalListS_filt), nth(6 FinalListS_filt), nth(7 FinalListS_filt), nth(8 FinalListS_filt), nth(9 FinalListS_filt))
                            )
                            fprintf(port, "\n\n")
                            fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                        else
                            fprintf(port, "%s\n", "NO ERROR - FOUND..!")
                            fprintf(port, "\n\n")
                            fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                        )
                        
                        if(ErrorListMissing != nil then
                            fprintf(port, "%s\n\n", "MISSING :")
                            fprintf(port, "%-25s \n\n", "ERROR")
                            foreach(FinalListlp ErrorListMissing
                                fprintf(port, "%-25s \n", FinalListlp)
                            )
                            fprintf(port, "\n\n")
                            fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                        else
                            fprintf(port, "%s\n", "NO ERROR - FOUND..!")
                            fprintf(port, "\n\n")
                            fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                        )
                        axlDMClose(port)
                        axlUIViewFileCreate(logfile, "Cutout Error", nil, '(30 25), '(CENTER))
                    else
                        axlUIConfirm("No Error Found...!")
                    )
                    axlShell("Done")
                    axlClearSelSet()
                )

                
                if(Get_IC then
                    axlMsgPut("---IC-POGO-PASSIVE Cutout Check and Report---")
                    axlUIConfirm("Please Select the Pin Details List...!")

                    PinNameList = nil
					CRC_Brow = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
					CRC_OpenFile = axlDMFileParts(CRC_Brow)
					CRC_DataInFile = axlDMOpenFile("ALLEGRO_TEXT" cadr(CRC_OpenFile) "r") 
						while(gets(CRC_Inp_Val CRC_DataInFile)
							CRC_Inp_Val = car(parseString(CRC_Inp_Val "\n"))
								when(CRC_Inp_Val push(CRC_Inp_Val PinNameList))
							)
					axlDMClose(CRC_DataInFile)

                    if(PinNameList == nil then
                        axlUIConfirm("Oops : Selected Input File Is Empty...!")
                    else
                        ErrorListMissingPass = nil
                        ErrorListPass = nil
                        ICListPass = nil
                        foreach(PinNameListlp PinNameList
                            InpRefName = nth(0 parseString(PinNameListlp "."))
                            InpPinNum = nth(1 parseString(PinNameListlp "."))
                            SymId = axlDBFindByName('refdes InpRefName)

                            DummyVar6 = "No"
                            foreach(PinIdlp SymId->pins
                                PinNum = PinIdlp->number
                                if(PinNum == InpPinNum then 
                                    DummyVar6 = "Yes"

                                    PinName = PinIdlp->name
                                    PinXpoint = car(PinIdlp->xy)
                                    PinYpoint = cadr(PinIdlp->xy)
                                    PinXYPointPass = sprintf(nil "(%.3f %.3f)", PinXpoint, PinYpoint)

                                    DummyVar7 = "No"
                                    foreach(SymDtLp axlDBGetDesign() ->symbols
                                        SymXYPoint = sprintf(nil "(%.3f %.3f)", car(SymDtLp->xy), cadr(SymDtLp->xy))
                                        if(SymXYPoint == PinXYPointPass then
                                            SymName = SymDtLp->name
                                            SymXYPointPass = sprintf(nil "(%.3f %.3f)", car(SymDtLp->xy), cadr(SymDtLp->xy))

                                            PassSym = sprintf(nil "%s,%s,%s,%s,%s", PinNameListlp, PinName, PinXYPointPass, SymName, SymXYPointPass)
                                            when(PassSym push(PassSym ICListPass))
                                            DummyVar7 = "Yes"
                                        )
                                    )

                                    if(DummyVar7 == "No" then
                                        ErrorMissingSym = sprintf(nil "%s,%s,%s,NIL,NIL,Error : Symbol Missing Or Location Mismatched..", PinNameListlp, PinName, PinXYPointPass)
                                        when(ErrorMissingSym push(ErrorMissingSym ErrorListPass)) 
                                        when(ErrorMissingSym push(ErrorMissingSym ICListPass))
                                    )
                                )
                            )

                            if(DummyVar6 == "No" then
                                ErrorMissingPin = sprintf(nil "%s - Error : Pin Not Found Check The Input..", PinNameListlp)
                                when(ErrorMissingPin push(ErrorMissingPin ErrorListMissingPass))
                            )
                        )

                        ICListPass = unique(ICListPass)
                        ICListPass = sort(ICListPass 'alphalessp)

                        ErrorListPass = unique(ErrorListPass)
                        ErrorListPass = sort(ErrorListPass 'alphalessp)

                        ErrorListMissingPass = unique(ErrorListMissingPass)
                        ErrorListMissingPass = sort(ErrorListMissingPass 'alphalessp)

                        if(ICListPass != nil then
                            out = outfile("QC_IC-POGO-PASSIVE-CutoutReport.CSV")
                            fprintf(out, "%s,%s,%s,%s,%s \n\n", "PIN-NUM", "PADSTACK-NAME", "PADSTACK-XY LOCATION", "CUTOUT-SYMBOL-NAME", "CUTOUT-SYMBOL-XY LOCATION")
                            
                            foreach(ICListPasslp ICListPass
                                fprintf(out, "%s \n", ICListPasslp) 
                            )
                            close(out)	

                            axlUIConfirm( "QC_IC-POGO-PASSIVE-CutoutReport.csv Report Generated Successfully..!" )
                        else
                            axlUIConfirm( "No Records Found To Generate Report..!" ) 
                        )


                        if(ErrorListPass != nil || ErrorListMissingPass != nil then
                            logfile = "QC_IC-POGO-PASSIVE-CutoutReport.log"
                            designName = axlCurrentDesign()
                            design_path = axlGetDrawingName()
                            design_unit = car(axlDBGetDesignUnits())
                            port = axlDMOpenLog(logfile)
                            fprintf(port, "Design name: %s\n", design_path)
                            fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                            
                            if(ErrorListPass != nil then
                                fprintf(port, "%s\n\n", "MISSMATCH :")
                                fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s\n\n", "PIN-NUM", "PADSTACK-NAME", "PADSTACK-XY LOCATION", "CUTOUT-SYMBOL-NAME", "CUTOUT-SYMBOL-XY LOCATION", "ERROR")
                                foreach(FinalListSlp1 ErrorListPass
                                    FinalListS_filt = parseString(FinalListSlp1 ",") 
                                    fprintf(port, "%-25s %-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt) , nth(3 FinalListS_filt), nth(4 FinalListS_filt), nth(5 FinalListS_filt))
                                )
                                fprintf(port, "\n\n")
                                fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                            else
                                fprintf(port, "%s\n", "NO ERROR - FOUND..!")
                                fprintf(port, "\n\n")
                                fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                            )
                            
                            if(ErrorListMissingPass != nil then
                                fprintf(port, "%s\n\n", "MISSING :")
                                fprintf(port, "%-25s \n\n", "ERROR")
                                foreach(FinalListlp1 ErrorListMissingPass
                                    fprintf(port, "%-25s \n", FinalListlp1)
                                )
                                fprintf(port, "\n\n")
                                fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                            else
                                fprintf(port, "%s\n", "NO ERROR - FOUND..!")
                                fprintf(port, "\n\n")
                                fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                            )
                            axlDMClose(port)
                            axlUIViewFileCreate(logfile, "Cutout Error", nil, '(30 25), '(CENTER))
                        else
                            axlUIConfirm("No Error Found...!")
                    )
                    axlShell("Done")
                    axlClearSelSet()


                    )
                )

            )
		)
	)
	axlFormDisplay(CRCform)
)