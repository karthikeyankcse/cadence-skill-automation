axlCmdRegister("DiffPairMinDistChkATE4" 'DiffPairMinDistChkATE4)
(setq DPMDC_form_file "DiffPairMinDistChkATE4.form") 
procedure(DiffPairMinDistChkATE4()
	CreateDPMDC_form()
	RunDPMDC_form()
)

procedure(RunDPMDC_form() 
	let((DPMDC_form)
		(DPMDC_form = axlFormCreate(gensym() DPMDC_form_file nil 'DPMDC_Action t))
		axlFormDisplay(DPMDC_form)
	)
)

procedure(CreateDPMDC_form()
	let((DPMDC_form)
		(DPMDC_form = outfile(DPMDC_form_file "w")) 
		fprintf(DPMDC_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(DPMDC_form "FORM\n") 
		fprintf(DPMDC_form "FIXED\n") 
		fprintf(DPMDC_form "PORT 60 50\n") 
		fprintf(DPMDC_form "HEADER \"DiffPair Minimum Distance Check\"\n") 
		fprintf(DPMDC_form "\n")
		fprintf(DPMDC_form "TILE\n")
		
		
		fprintf(DPMDC_form "TEXT \" ENTER THE UNCOUPLED TRACE WIDTH          >>> \"\n")
		fprintf(DPMDC_form "TLOC 1 2\n")
		fprintf(DPMDC_form "ENDTEXT\n")
		
		fprintf(DPMDC_form "FIELD %s\n" "WID1") 
		fprintf(DPMDC_form "FLOC 45 2\n")
		fprintf(DPMDC_form "STRFILLIN 10 5\n")
		fprintf(DPMDC_form "ENDFIELD\n") 
		fprintf(DPMDC_form "\n") 

        fprintf(DPMDC_form "TEXT \" ENTER THE DIFFERENTIAL TRACE WIDTH       >>> \"\n")
		fprintf(DPMDC_form "TLOC 1 5\n")
		fprintf(DPMDC_form "ENDTEXT\n")
		
		fprintf(DPMDC_form "FIELD %s\n" "WID2") 
		fprintf(DPMDC_form "FLOC 45 5\n")
		fprintf(DPMDC_form "STRFILLIN 10 5\n")
		fprintf(DPMDC_form "ENDFIELD\n") 
		fprintf(DPMDC_form "\n")

        fprintf(DPMDC_form "TEXT \" ENTER THE DIFFERENTIAL AIRGAP                   >>> \"\n")
		fprintf(DPMDC_form "TLOC 1 8\n")
		fprintf(DPMDC_form "ENDTEXT\n")
		
		fprintf(DPMDC_form "FIELD %s\n" "DIST") 
		fprintf(DPMDC_form "FLOC 45 8\n")
		fprintf(DPMDC_form "STRFILLIN 10 5\n")
		fprintf(DPMDC_form "ENDFIELD\n") 
		fprintf(DPMDC_form "\n")
		
		
		fprintf(DPMDC_form "FIELD PROC\n") 
		fprintf(DPMDC_form "FLOC 20 12\n") 
		fprintf(DPMDC_form "MENUBUTTON \"CLICK HERE TO CHECK..!\" 20 4\n") 
		fprintf(DPMDC_form "ENDFIELD\n")
		fprintf(DPMDC_form "\n")

		fprintf(DPMDC_form "\n") 
		fprintf(DPMDC_form "\n") 
		fprintf(DPMDC_form "ENDTILE\n")
		
		fprintf(DPMDC_form "\n") 
		fprintf(DPMDC_form "ENDFORM\n")
		
		drain() 
		close(DPMDC_form)
	)
)

procedure(DPMDC_Action(DPMDC_form) 
	case((DPMDC_form->curField)
		("PROC"
			(Wid1_getval = (axlFormGetField DPMDC_form "WID1"))
			(Wid2_getval = (axlFormGetField DPMDC_form "WID2"))
			(Dist_getval = (axlFormGetField DPMDC_form "DIST"))

			axlMsgPut("You Entered - %s", Wid1_getval)
			axlMsgPut("You Entered - %s", Wid2_getval)
			axlMsgPut("You Entered - %s", Dist_getval)


            if(Wid1_getval != "" && Wid1_getval != nil  && Wid2_getval != "" && Wid2_getval != nil && Dist_getval != "" && Dist_getval != nil then

                TopBotWid = sprintf(nil "%.2f", atof(Wid1_getval))
                MidWid = sprintf(nil "%.2f", atof(Wid2_getval))
                MinAir = sprintf(nil "%.2f", atof(Dist_getval))

                originalVisible = axlVisibleGet()

                ErrorList = nil
                DiffNetList = nil

                axlUIConfirm("Please Select The Nets...!")
                axlClearSelSet()
                axlSetFindFilter(?enabled '("NOALL", "CLINES"), ?onButtons "CLINES")
                axlShell("Done")
                NetDt = axlGetSelSet(axlSelect( ))

                foreach(NetDtlp NetDt
                    Net_Name = NetDtlp->net->name
                    Net_Layer = NetDtlp->layer
                    Net_Diff_Name = NetDtlp ->net ->diffpair ->name
                    if(Net_Diff_Name != nil then
                        when(Net_Diff_Name push(Net_Diff_Name DiffNetList))
                    else
                        ErrorListDt = sprintf(nil "%s - This Net Doesn't Have Diff Pair..", Net_Name)
                        when(ErrorListDt push(ErrorListDt ErrorList))
                    )
                )

                if(DiffNetList != nil then
                    foreach(DiffNetListlp DiffNetList
                        PassList = nil
                        PassNetName = nil
                        foreach(BrdNetlp axlDBGetDesign()->nets
                            foreach(BranchLp BrdNetlp->branches
                                foreach(ChildLp BranchLp->children
                                    NetObjType = ChildLp->objType
                                    if(NetObjType == "path" then
                                        Brd_Layer = ChildLp->layer
                                        if(Brd_Layer == Net_Layer then 
                                            BrdDiffPair = BrdNetlp ->diffpair ->name
                                            BrdNetName = BrdNetlp ->name
                                            if(BrdDiffPair == DiffNetListlp then 
                                                when(ChildLp push(ChildLp PassList))
                                                when(BrdNetName push(BrdNetName PassNetName))
                                            )
                                        )
                                    )
                                )
                            )
                        )
                        
                        LenPassList = length(PassList)

                        if(LenPassList >= 2 then
                            PassNetName = unique(PassNetName)

                            PassNetNameFirst = car(PassNetName)
                            PassNetNameSec = cadr(PassNetName)

                            FirstClineIdList = nil
                            foreach(PassListlp PassList
                                GotNetName = PassListlp->net->name
                                if(GotNetName == PassNetNameFirst then 
                                    when(PassListlp push(PassListlp FirstClineIdList))
                                )
                            )

                            SecClineIdList = nil
                            foreach(PassListlp PassList
                                GotNetName = PassListlp->net->name
                                if(GotNetName == PassNetNameSec then 
                                    when(PassListlp push(PassListlp SecClineIdList))
                                )
                            )
                            
                            FirstDummyWidFound1 = "No"
                            FirstDummyWidFound2 = "No"

                            FirstCsegFirstWid = nil
                            FirstCsegSecWid = nil
                            foreach(FirstClineIdListlp FirstClineIdList
                                foreach(FirstSeglp FirstClineIdListlp->segments
                                    FirstBrdWid = sprintf(nil "%.2f", FirstSeglp->width)
                                    if(FirstBrdWid == TopBotWid then
                                        when(FirstSeglp push(FirstSeglp FirstCsegFirstWid))
                                        FirstDummyWidFound1 = "Yes"
                                    )
                                    
                                    if(FirstBrdWid == MidWid then
                                        when(FirstSeglp push(FirstSeglp FirstCsegSecWid))
                                        FirstDummyWidFound2 = "Yes"
                                    )
                                    
                                )
                            )
                            
                            if(FirstDummyWidFound1 == "No" then                        
                                ErrorListDt = sprintf(nil "%s - (%s) Width Not Found..", PassNetNameFirst, TopBotWid)
                                when(ErrorListDt push(ErrorListDt ErrorList))
                            )

                            if(FirstDummyWidFound2 == "No" then                        
                                ErrorListDt = sprintf(nil "%s - (%s) Width Not Found..", PassNetNameFirst, MidWid)
                                when(ErrorListDt push(ErrorListDt ErrorList))
                            )


                            SecDummyWidFound1 = "No"
                            SecDummyWidFound2 = "No"

                            SecCsegFirstWid = nil
                            SecCsegSecWid = nil
                            foreach(SecClineIdListlp SecClineIdList
                                foreach(SecSeglp SecClineIdListlp->segments
                                    SecBrdWid = sprintf(nil "%.2f", SecSeglp->width)
                                    if(SecBrdWid == TopBotWid then
                                        when(SecSeglp push(SecSeglp SecCsegFirstWid))
                                        SecDummyWidFound1 = "Yes"
                                    )
                                    
                                    if(SecBrdWid == MidWid then
                                        when(SecSeglp push(SecSeglp SecCsegSecWid))
                                        SecDummyWidFound2 = "Yes"
                                    )
                                    
                                )
                            )

                            if(SecDummyWidFound1 == "No" then                        
                                ErrorListDt = sprintf(nil "%s - (%s) Width Not Found..", PassNetNameSec, TopBotWid)
                                when(ErrorListDt push(ErrorListDt ErrorList))
                            )

                            if(SecDummyWidFound2 == "No" then                        
                                ErrorListDt = sprintf(nil "%s - (%s) Width Not Found..", PassNetNameSec, MidWid)
                                when(ErrorListDt push(ErrorListDt ErrorList))
                            )


                            if(SecDummyWidFound1 == "Yes" &&  FirstDummyWidFound1 == "Yes" then
                                foreach(FirstCsegFirstWidlp FirstCsegFirstWid
                                    Fnetname = FirstCsegFirstWidlp->net->name
                                    FWid = sprintf(nil "%.2f", FirstCsegFirstWidlp->width)
                                    foreach(SecCsegFirstWidlp SecCsegFirstWid
                                        Snetname = SecCsegFirstWidlp->net->name
                                        when(equal(FirstCsegFirstWidlp->layer SecCsegFirstWidlp->layer)
                                        (data = (axlAirGap FirstCsegFirstWidlp SecCsegFirstWidlp (SecCsegFirstWidlp->layer)))
                                            when(data
                                                AirGapVal = (lastelem data)
                                                AirGapValStr = sprintf(nil "%.2f", AirGapVal)
                                                val1 = atof(MinAir)
                                                val2 = atof(AirGapValStr)
                                                if(val1 >= val2 then
                                                    FirstPoint = car(data)
                                                    SecPoint = cadr(data)
                                                    ErrorListDt = sprintf(nil "%s - %s - Width - %s AirGap - %s Location %L And %L", Fnetname, Snetname, FWid, AirGapValStr, FirstPoint, SecPoint)
                                                    when(ErrorListDt push(ErrorListDt ErrorList))
                                                    axlHighlightObject(FirstCsegFirstWidlp)
                                                    axlHighlightObject(SecCsegFirstWidlp)
                                                )
                                            )
                                        )
                                    )
                                )
                            )


                            if(FirstDummyWidFound2 == "Yes" &&  SecDummyWidFound2 == "Yes" then
                                foreach(FirstCsegSecWidlp FirstCsegSecWid
                                    FoundPass = "No"
                                    ErrorPassList = nil
                                    ErrorPasNum = nil
                                    Fnetname = FirstCsegSecWidlp->net->name
                                    Fwidval = sprintf(nil "%.2f", FirstCsegSecWidlp->width)
                                    foreach(SecCsegSecWidlp SecCsegSecWid
                                        Snetname = SecCsegSecWidlp->net->name
                                        when(equal(FirstCsegSecWidlp->layer SecCsegSecWidlp->layer)
                                        (data = (axlAirGap FirstCsegSecWidlp SecCsegSecWidlp (SecCsegSecWidlp->layer)))
                                            when(data
                                                AirGapVal = (lastelem data)
                                                AirGapValStr = sprintf(nil "%.2f", AirGapVal)
                                                val1 = atof(MinAir)
                                                val2 = atof(AirGapValStr)
                                                if(val1 == val2 then
                                                    FoundPass = "Yes"
                                                else
                                                    FirstPoint = car(data)
                                                    SecPoint = cadr(data)
                                                    ErrorPassListDt = sprintf(nil "%s,%s - %s Width - %s AirGap - %s Location %L And %L,%s,%s", AirGapValStr, Fnetname, Snetname, Fwidval, AirGapValStr, FirstPoint, SecPoint, FirstCsegSecWidlp, SecCsegSecWidlp)
                                                    when(ErrorPassListDt push(ErrorPassListDt ErrorPassList))
                                                    when(val2 push(val2 ErrorPasNum))
                                                )
                                            )
                                        )
                                    )

                                    if(FoundPass == "No" then
                                        ErrorPasNum = sort(ErrorPasNum 'lessp)
                                        FirstValInList = sprintf(nil "%.2f", car(ErrorPasNum))
                                        foreach(ErrorPassListlp ErrorPassList
                                            ErrorPassPrse = nth(1 parseString(ErrorPassListlp ","))
                                            ErrorPassChk = nth(0 parseString(ErrorPassListlp ","))
                                            ErrorPassId1 = nth(2 parseString(ErrorPassListlp ","))
                                            ErrorPassId2 = nth(3 parseString(ErrorPassListlp ","))
                                            if(ErrorPassChk == FirstValInList then
                                                foreach(HighNetId axlDBGetDesign()->nets
                                                    foreach(BranchLp HighNetId->branches
                                                        foreach(ChildLp BranchLp->children
                                                            NetObjType = ChildLp->objType
                                                            if(NetObjType == "path" then
                                                                foreach(ChildLpSeg ChildLp->segments
                                                                    BrdIdStr = sprintf(nil "%s", ChildLpSeg)
                                                                    if(BrdIdStr == ErrorPassId1 then 
                                                                        axlHighlightObject(ChildLpSeg)
                                                                    )

                                                                    if(BrdIdStr == ErrorPassId2 then 
                                                                        axlHighlightObject(ChildLpSeg)
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                )
                                                when(ErrorPassPrse push(ErrorPassPrse ErrorList))
                                            )
                                        )  
                                    )
                                )
                            )


                        else
                            ErrorListDt = sprintf(nil "%s This Diffpair Doesn't Have Cline..", car(DiffNetList))
                            when(ErrorListDt push(ErrorListDt ErrorList))
                        )
                    )
                )
                
                ErrorList = unique(ErrorList)

                if(ErrorList != nil then
                    logfile = "DiffPairMinDistChkATE4.log"
                    designName = axlCurrentDesign()
                    design_path = axlGetDrawingName()
                    design_unit = car(axlDBGetDesignUnits())
                    port = axlDMOpenLog(logfile)
                    fprintf(port, "Design name: %s\n", design_path)
                    fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                    fprintf(port, "%s\n\n", "ERROR :")
                    foreach(FinalListSlp ErrorList 
                        fprintf(port, "%s\n", FinalListSlp)
                    )
                    fprintf(port, "\n\n")
                    fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
                    axlDMClose(port)
                    axlUIViewFileCreate(logfile, "DiffPair Minimum Distance Check", nil, '(30 25), '(CENTER))
                else
                    axlUIConfirm("No Error Found...!")
                )

                axlVisibleSet(originalVisible)
                axlClearSelSet()
                axlShell("Done")
            else
                axlUIConfirm("Error : Required Input Is Empty...!")
                    
            )
        )
	)
	axlFormDisplay(DPMDC_form)
)
