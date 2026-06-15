axlCmdRegister("GndViaPlacedNearSigViaChk_TI" 'GndViaPlacedNearSigViaChk_TI)
(setq HS_form_file "GndViaPlacedNearSigViaChk_TI.form") 
procedure(GndViaPlacedNearSigViaChk_TI()
	axlShell("Done")
	CreateHS_form()
	RunHS_form()
)

procedure(RunHS_form() 
	let((HS_form)
		(HS_form = axlFormCreate(gensym() HS_form_file nil 'HS_Action t)) 
		axlFormDisplay(HS_form)
	)
)

procedure(CreateHS_form()
	let((HS_form)
		(HS_form = outfile(HS_form_file "w")) 
		fprintf(HS_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(HS_form "FORM\n") 
		fprintf(HS_form "FIXED\n") 
		fprintf(HS_form "PORT 50 55\n") 
		fprintf(HS_form "HEADER \"GND Via Placed Near SIG Via Check\"\n") 
		fprintf(HS_form "\n")
		fprintf(HS_form "TILE\n")
		
		fprintf(HS_form "POPUP <BRD>\"SELECT BY TRACE\"\"SELECT BY TRACE\",\"SELECT BY LIST\"\"SELECT BY LIST\".\n")
		fprintf(HS_form "FIELD BRDFLD\n") 
		fprintf(HS_form "FLOC 12 2\n") 
		fprintf(HS_form "ENUMSET 17\n")
		fprintf(HS_form "POP \"BRD\"\n")
		fprintf(HS_form "ENDFIELD\n")
		fprintf(HS_form "\n")
		
		fprintf(HS_form "TEXT \"DISTANCE BETWEEN SIG AND GND VIA : \"\n")
		fprintf(HS_form "TLOC 2 6\n")
		fprintf(HS_form "ENDTEXT\n")
		
		
		fprintf(HS_form "FIELD %s\n" "DISTVAL") 
		fprintf(HS_form "FLOC 30 6\n")
		fprintf(HS_form "STRFILLIN 7 5\n")
		fprintf(HS_form "ENDFIELD\n") 
		fprintf(HS_form "\n")
		
		fprintf(HS_form "FIELD PROC\n") 
		fprintf(HS_form "FLOC 11 10\n") 
		fprintf(HS_form "MENUBUTTON \"CLICK HERE TO PROCEED....!\" 20 4\n") 
		fprintf(HS_form "ENDFIELD\n")
		fprintf(HS_form "\n")
		

		fprintf(HS_form "\n") 
		fprintf(HS_form "\n") 
		fprintf(HS_form "ENDTILE\n")
		
		fprintf(HS_form "\n") 
		fprintf(HS_form "ENDFORM\n")
		
		drain() 
		close(HS_form)
	)
)

procedure(HS_Action(HS_form) 
	case((HS_form->curField)
		("PROC"
			(Brd_getval = (axlFormGetField HS_form "BRDFLD"))
			(Dist_getval = (axlFormGetField HS_form "DISTVAL"))
			Dist_getval = atof(Dist_getval)
			
			if(Brd_getval != "" && Dist_getval != nil then
			
				NetNameList = nil
				if(Brd_getval == "SELECT BY TRACE" then
					axlUIConfirm("Please Select The CLine...!")
					axlClearSelSet()
					axlSetFindFilter(?enabled '("NOALL", "CLINES"), ?onButtons "CLINES")
					axlShell("Done")
					ClineDt = axlGetSelSet(axlSelect( ))
					foreach(ClineDtlp ClineDt
						CLineNetName = ClineDtlp->net->name
						when(CLineNetName push(CLineNetName NetNameList))
					)
				else
					axlUIConfirm("Please Select the NetName List...!")
					HS_Brow = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
					HS_OpenFile = axlDMFileParts(HS_Brow)
					HS_DataInFile = axlDMOpenFile("ALLEGRO_TEXT" cadr(HS_OpenFile) "r") 
						while(gets(HS_Inp_Val HS_DataInFile)
							HS_Inp_Val = car(parseString(HS_Inp_Val "\n"))
								when(HS_Inp_Val push(HS_Inp_Val NetNameList))
							)
					axlDMClose(HS_DataInFile)
				)
				NetNameList = unique(NetNameList)
				
				if(NetNameList != nil then
					println("Please Wait..!")
					ErrorList = nil
					FoundNetList = nil
					originalVisible = axlVisibleGet()
					axlVisibleDesign(t)
					axlShell("redisplay")
					axlClearSelSet()
					axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
					ViaDt = axlGetSelSet(axlAddSelectAll())
					foreach(ViaDtlp ViaDt
						ViaNetName = ViaDtlp->net->name
						foreach(NetNameListlp NetNameList
							if(ViaNetName == NetNameListlp then 
							
								when(NetNameListlp push(NetNameListlp FoundNetList))
								
								ViaXpoint = car(ViaDtlp->xy)
								ViaYpoint = cadr(ViaDtlp->xy)
								SkipVia1 = sprintf(nil "(%.2f %.2f)", ViaXpoint, ViaYpoint)
								BoxTopX = ViaXpoint - Dist_getval 
								BoxTopY = ViaYpoint + Dist_getval
								BoxBotX = ViaXpoint + Dist_getval
								BoxBotY = ViaYpoint - Dist_getval
								
								axlClearSelSet()
								axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
								BoxViaInp = axlGetSelSet(axlSingleSelectBox( list(BoxTopX:BoxTopY BoxBotX:BoxBotY)))
								if(BoxViaInp != nil then
									DummyPass = "NO"
									foreach(BoxViaInplp BoxViaInp
										BoxNetName = BoxViaInplp->net->name
										if(BoxNetName == "" || BoxNetName == nil then
												BoxNetName = "Dummy Net"
										)
										BoxViaXpoint = car(BoxViaInplp->xy)
										BoxViaYpoint = cadr(BoxViaInplp->xy)
										SkipVia2 = sprintf(nil "(%.2f %.2f)", BoxViaXpoint, BoxViaYpoint)
										if(SkipVia2 != SkipVia1 then 
											if(BoxNetName == "GND" || BoxNetName == "DGND" || BoxNetName == "AGND" || BoxNetName == "SGND" then
												if(BoxViaXpoint == ViaXpoint || BoxViaYpoint == ViaYpoint then
													DummyPass = "YES"
												)
											else
												if(BoxViaXpoint == ViaXpoint || BoxViaYpoint == ViaYpoint then
													ErrorDtMiss2 = sprintf(nil "%s,(%.2f %.2f), Error : Non Ground Net Found ", BoxNetName, BoxViaXpoint, BoxViaYpoint)
													when(ErrorDtMiss2 push(ErrorDtMiss2 ErrorList))
												)							
											)
										)
									)
									
									if(DummyPass == "NO" then
										ErrorDtMiss1 = sprintf(nil "%s,(%.2f %.2f), Error : GND VIA NOT FOUND OR MISSPLACED", ViaNetName, ViaXpoint, ViaYpoint)
										when(ErrorDtMiss1 push(ErrorDtMiss1 ErrorList))
									)
								
								else
									ErrorDtMiss = sprintf(nil "%s,(%.2f %.2f), Error : GND VIA NOT FOUND OR MISSPLACED", ViaNetName, ViaXpoint, ViaYpoint)
									when(ErrorDtMiss push(ErrorDtMiss ErrorList))
								)
							)
						)
					)
				
					
					NetMissing = nil
					NetMissing = setof(Item1, NetNameList, !member(Item1, FoundNetList))
					
					ErrorListNetMiss = nil
					foreach(NetMissinglp NetMissing
						ErrorNetMiss = sprintf(nil "%s, Error : THERE IS NO VIA FOUND IN THIS NET NAME", NetMissinglp)
						when(ErrorNetMiss push(ErrorNetMiss ErrorListNetMiss))
					)
					
					FullError = append(ErrorList ErrorListNetMiss)
					
					if(FullError != nil then
						logfile = "GndViaPlacedNearSigViaChk_TI.log"
						designName = axlCurrentDesign()
						design_path = axlGetDrawingName()
						design_unit = car(axlDBGetDesignUnits())
						port = axlDMOpenLog(logfile)
						fprintf(port, "Design name: %s\n", design_path)
						fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
						
						if(ErrorList != nil then
							fprintf(port, "%s\n\n", "ERROR : GNA VIA NEAR SIG VIA")
							fprintf(port, "%-35s %-35s %-35s \n\n", "NET NAME", "XY LOCATION", "ERROR")
							foreach(ErrorListlp ErrorList
								FinalListS_filt = parseString(ErrorListlp ",")
								fprintf(port, "%-35s %-35s %-35s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR - GNA VIA NEAR SIG VIA..!")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
						)
						
						if(ErrorListNetMiss != nil then
							fprintf(port, "%s\n\n", "NET MISSING :")
							fprintf(port, "%-35s %-35s \n\n", "NET NAMES", "ERROR")
							foreach(FinalListlp ErrorListNetMiss 
								FinalListS_filt1 = parseString(FinalListlp ",")
								fprintf(port, "%-35s %-35s \n", nth(0 FinalListS_filt1), nth(1 FinalListS_filt1))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR - EVERY NET FOUND..!")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
						)
						
						axlDMClose(port)
						axlUIViewFileCreate(logfile, "GND VIA NEAR SIG VIA CHECK", nil, '(30 25), '(CENTER))
					else
						axlUIConfirm("Good To Go No Error Found...!")
					)

					axlClearSelSet()
					axlVisibleSet(originalVisible)
					axlShell("redisplay")
					axlShell("Done")
				else
					axlUIConfirm("Error : NetName List Is Empty...!")
				)
				
			else
				axlUIConfirm("Error : Required Input Is Empty Please Check...!")
				
			)
			
		)
	)
	axlFormDisplay(HS_form)
)