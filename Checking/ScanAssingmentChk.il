axlCmdRegister("ScanAssingmentChk" 'ScanAssingmentChk)
(setq SN_form_file "ScanAssingmentChk.form") 
procedure(ScanAssingmentChk()
	CreateSN_form()
	RunSN_form()
)

procedure(RunSN_form() 
	let((SN_form)
		(SN_form = axlFormCreate(gensym() SN_form_file nil 'SN_Action t)) 
		axlFormDisplay(SN_form)
	)
)

procedure(CreateSN_form()
	let((SN_form)
		(SN_form = outfile(SN_form_file "w")) 
		fprintf(SN_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(SN_form "FORM\n") 
		fprintf(SN_form "FIXED\n") 
		fprintf(SN_form "PORT 45 50\n") 
		fprintf(SN_form "HEADER \"Scan Net Assingment Check\"\n") 
		fprintf(SN_form "\n")
		fprintf(SN_form "TILE\n")
		
		fprintf(SN_form "POPUP <BRD>\"93K\"\"93K\",\"J750\"\"J750\".\n")
		fprintf(SN_form "FIELD BRDFLD\n") 
		fprintf(SN_form "FLOC 13 2\n") 
		fprintf(SN_form "ENUMSET 17\n")
		fprintf(SN_form "POP \"BRD\"\n")
		fprintf(SN_form "ENDFIELD\n")
		fprintf(SN_form "\n")
		
		fprintf(SN_form "TEXT \"MINIMUM NO OF SCAN NET IN GROUP -->\"\n")
		fprintf(SN_form "TLOC 2 6\n")
		fprintf(SN_form "ENDTEXT\n")
		
		
		fprintf(SN_form "FIELD %s\n" "SCNVAL") 
		fprintf(SN_form "FLOC 33 6\n")
		fprintf(SN_form "STRFILLIN 5 5\n")
		fprintf(SN_form "ENDFIELD\n") 
		fprintf(SN_form "\n")
		
		fprintf(SN_form "FIELD PROC\n") 
		fprintf(SN_form "FLOC 11 10\n") 
		fprintf(SN_form "MENUBUTTON \"CLICK HERE TO PROCEED....!\" 20 4\n") 
		fprintf(SN_form "ENDFIELD\n")
		fprintf(SN_form "\n")
		

		fprintf(SN_form "\n") 
		fprintf(SN_form "\n") 
		fprintf(SN_form "ENDTILE\n")
		
		fprintf(SN_form "\n") 
		fprintf(SN_form "ENDFORM\n")
		
		drain() 
		close(SN_form)
	)
)

procedure(SN_Action(SN_form) 
	case((SN_form->curField)
		("PROC"
			(Brd_getval = (axlFormGetField SN_form "BRDFLD"))
			(SCN_getval = (axlFormGetField SN_form "SCNVAL"))
			SCN_getval = atoi(SCN_getval)
				DRCList = nil
				DRCRef = nil
				DRCPinNum = nil
				foreach(drc_id axlDBGetDesign()->drcs
					foreach(item drc_id->violations
						if(item->objType == "pin" then  
							PinDt = sprintf(nil, "%s%s%s",item->parent->refdes, ".", item->number)
							PinRef = item->parent->refdes
							PinNum = item->number
							if(item->net->name == "" || item->net->name == nil then
								OldNN = sprintf(nil, "%s", "Dummy Net")
							else
								OldNN = sprintf(nil, "%s", item->net->name)
							)
							foreach(itemm drc_id->violations
								if(itemm->objType == "line" || itemm->objType == "path"|| itemm->objType == "shape" || itemm->objType == "arc" then
									if(itemm->net->name != nil then 
										NewNN = sprintf(nil, "%s", itemm->net->name)
										DRCListDt = sprintf(nil "%s,%s,%s", PinDt, OldNN, NewNN) 
										when(DRCListDt push(DRCListDt DRCList))
										when(PinRef push(PinRef DRCRef))
										when(PinNum push(PinNum DRCPinNum))
									) 
								)
							)
						)
					)
				)
				DRCRef = unique(DRCRef)
				DRCRef = sort(DRCRef 'alphalessp)
				DRCPinNum = unique(DRCPinNum)
				DRCPinNum = sort(DRCPinNum 'alphalessp)
				ErrorList = nil
				if(Brd_getval == "93K" then
					foreach(DRCReflp DRCRef
						StoreList = nil
						StoreNumList = nil
						StoreAlpList = nil
						foreach(DRCListlp DRCList
							PinDt = nth(0 parseString(DRCListlp ","))
							PinRefDt = nth(0 parseString(PinDt "."))
							PinNumDt = nth(1 parseString(PinDt ".")) 
							PinOldNN = nth(1 parseString(DRCListlp ","))
							PinNewNN = nth(2 parseString(DRCListlp ","))
							if(PinRefDt == DRCReflp then
								PinValPass = sprintf(nil "%s,%s", PinDt, PinNewNN)
								when(PinValPass push(PinValPass StoreList))
								StrValNum = nil
								StrValAlp = nil
								StrValLen = strlen(PinNumDt)
								for(i 1 StrValLen
									TxtPrse = substring(PinNumDt i 1)
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
								when(StrValNumStr push(StrValNumStr StoreNumList))
								when(StrValAlpStr push(StrValAlpStr StoreAlpList))
							)
						)
						StoreList = unique(StoreList)
						StoreList = sort(StoreList 'alphalessp)
						
						StoreNumList = unique(StoreNumList)
						StoreNumList = sort(StoreNumList 'alphalessp)
						
						StoreAlpList = unique(StoreAlpList)
						StoreAlpList = sort(StoreAlpList 'alphalessp)
						
						MultScnChkB1 = "NO"
						MultScnChkB2 = "NO"
						MultScnChkO1 = "NO"
						MultScnChkO2 = "NO"
						foreach(StoreAlpListlp StoreAlpList
								ErrorListB8 = nil
								ErrorListO8 = nil
								foreach(StoreListlp StoreList
									StrValRef = nth(0 parseString(StoreListlp ","))
									StrValRefVal = nth(0 parseString(StrValRef "."))
									StrValRefNumVal = nth(1 parseString(StrValRef "."))
									StrValNetName = nth(1 parseString(StoreListlp ","))
									StrValNum1 = nil
									StrValAlp1 = nil
									StrValLen1 = strlen(StrValRefNumVal)
									for(k 1 StrValLen1
										TxtPrse1 = substring(StrValRefNumVal k 1)
										pcre3 = pcreCompile("([0-9]+)")
										when(pcreExecute(pcre3 TxtPrse1)
											when(TxtPrse1 push(TxtPrse1 StrValNum1))
										)
										
										pcreA = pcreCompile("([A-Z]+)")
										when(pcreExecute(pcreA TxtPrse1)
											when(TxtPrse1 push(TxtPrse1 StrValAlp1))
										)
									)
									StrValNum1 = reverse(StrValNum1)
									StrValNum1Str = buildString(StrValNum1 "")
									
									StrValAlp1 = reverse(StrValAlp1)
									StrValAlpStr1 = buildString(StrValAlp1 "")
									
									StrValNum1Int = atoi(StrValNum1Str)
									
									if(StoreAlpListlp == "" || StoreAlpListlp == StrValAlpStr1 then
										pcre4 = pcreCompile("_SCN_")
										pcre5 = pcreCompile("_SI_")
										pcre6 = pcreCompile("_SO_")
										pcre7 = pcreCompile("_SC_")
										pcre8 = pcreCompile("_JTAG_")
										pcre9 = pcreCompile("_JTAG_SCN_")
										
										if(pcreExecute(pcre4 StrValNetName) then
											if(StrValNum1Int <= 8 then
												MultScnChkB1 = "YES"
												when(StoreListlp push(StoreListlp ErrorListB8))
											else
												if(StrValNum1Int <= 16 && StrValNum1Int > 8 then
													MultScnChkO1 = "YES"
													when(StoreListlp push(StoreListlp ErrorListO8))
												)
											)
										)
										
										if(pcreExecute(pcre5 StrValNetName) then
											if(StrValNum1Int <= 8 then
												MultScnChkB1 = "YES"
												when(StoreListlp push(StoreListlp ErrorListB8))
											else
												if(StrValNum1Int <= 16 && StrValNum1Int > 8 then
													MultScnChkO1 = "YES"
													when(StoreListlp push(StoreListlp ErrorListO8))
												)
											)
										)
										
										if(pcreExecute(pcre6 StrValNetName) then
											if(StrValNum1Int <= 8 then
												MultScnChkB1 = "YES"
												when(StoreListlp push(StoreListlp ErrorListB8))
											else
												if(StrValNum1Int <= 16 && StrValNum1Int > 8 then
													MultScnChkO1 = "YES"
													when(StoreListlp push(StoreListlp ErrorListO8))
												)
											)
										)
										
										if(pcreExecute(pcre7 StrValNetName) then
											if(StrValNum1Int <= 8 then
												MultScnChkB1 = "YES"
												when(StoreListlp push(StoreListlp ErrorListB8))
											else
												if(StrValNum1Int <= 16 && StrValNum1Int > 8 then
													MultScnChkO1 = "YES"
													when(StoreListlp push(StoreListlp ErrorListO8))
												)
											)
										)
										
										if(pcreExecute(pcre8 StrValNetName) then
											if(StrValNum1Int <= 8 then
												MultScnChkB2 = "YES"
												when(StoreListlp push(StoreListlp ErrorListB8))
											else
												if(StrValNum1Int <= 16 && StrValNum1Int > 8 then
													MultScnChkO2 = "YES"
													when(StoreListlp push(StoreListlp ErrorListO8)) 
												)
											)
										)
									)
								)
								ErrorListB8 = unique(ErrorListB8)
								ErrorListO8 = unique(ErrorListO8)

								if(MultScnChkB1 == "YES" && MultScnChkB2 == "YES" then
									ErrorDt1 = buildString(ErrorListB8 " ")
									if(pcreExecute(pcre9 ErrorDt1) then
										t
									else
										ErrorDtStr1 = sprintf(nil "Error: Multiple Scan Net Found In This Group --> %s", ErrorDt1)
										when(ErrorDtStr1 push(ErrorDtStr1 ErrorList))
									)									
								)
								
								if(MultScnChkO1 == "YES" && MultScnChkO2 == "YES" then
									ErrorDt2 = buildString(ErrorListO8 " ")
									if(pcreExecute(pcre9 ErrorDt2) then
										t
									else
										ErrorDtStr2 = sprintf(nil "Error: Multiple Scan Net Found In This Group --> %s", ErrorDt2)
										when(ErrorDtStr2 push(ErrorDtStr2 ErrorList))	
									)
								)
								
								if(length(ErrorListB8) > SCN_getval then
									ErrorDt3 = buildString(ErrorListB8 " ")
									ErrorDtStr3 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt3)
									when(ErrorDtStr3 push(ErrorDtStr3 ErrorList))
								)
								
								if(length(ErrorListO8) > SCN_getval then
									ErrorDt4 = buildString(ErrorListO8 " ")
									ErrorDtStr4 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt4)
									when(ErrorDtStr4 push(ErrorDtStr4 ErrorList))
								)
						)
					)
					ErrorList = unique(ErrorList)
				else
					if(Brd_getval == "J750" then
						foreach(DRCReflp DRCRef
							StoreList = nil
							StoreNumList = nil
							StoreAlpList = nil
							foreach(DRCListlp DRCList
								PinDt = nth(0 parseString(DRCListlp ","))
								PinRefDt = nth(0 parseString(PinDt "."))
								PinNumDt = nth(1 parseString(PinDt ".")) 
								PinOldNN = nth(1 parseString(DRCListlp ","))
								PinNewNN = nth(2 parseString(DRCListlp ","))
								if(PinRefDt == DRCReflp then
									PinValPass = sprintf(nil "%s,%s", PinDt, PinNewNN)
									when(PinValPass push(PinValPass StoreList))
									StrValNum = nil
									StrValAlp = nil
									StrValLen = strlen(PinNumDt)
									for(i 1 StrValLen
										TxtPrse = substring(PinNumDt i 1)
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
									when(StrValNumStr push(StrValNumStr StoreNumList))
									when(StrValAlpStr push(StrValAlpStr StoreAlpList))
								)
							)
							StoreList = unique(StoreList)
							StoreList = sort(StoreList 'alphalessp)
							
							StoreNumList = unique(StoreNumList)
							StoreNumList = sort(StoreNumList 'alphalessp)
							
							StoreAlpList = unique(StoreAlpList)
							StoreAlpList = sort(StoreAlpList 'alphalessp)
							
							MultScnChk = "NO"
							MultJTAKChk = "NO"
							foreach(StoreAlpListlp StoreAlpList
									ErrorList11 = nil
									ErrorList12 = nil
									ErrorList13 = nil
									ErrorList14 = nil
									ErrorList15 = nil
									ErrorList16 = nil
									ErrorList17 = nil
									ErrorList18 = nil
									foreach(StoreListlp StoreList
										StrValRef = nth(0 parseString(StoreListlp ","))
										StrValRefVal = nth(0 parseString(StrValRef "."))
										StrValRefNumVal = nth(1 parseString(StrValRef "."))
										StrValNetName = nth(1 parseString(StoreListlp ","))
										StrValNum1 = nil
										StrValAlp1 = nil
										StrValLen1 = strlen(StrValRefNumVal)
										for(k 1 StrValLen1
											TxtPrse1 = substring(StrValRefNumVal k 1)
											pcre3 = pcreCompile("([0-9]+)")
											when(pcreExecute(pcre3 TxtPrse1)
												when(TxtPrse1 push(TxtPrse1 StrValNum1))
											)
											
											pcreA = pcreCompile("([A-Z]+)")
											when(pcreExecute(pcreA TxtPrse1)
												when(TxtPrse1 push(TxtPrse1 StrValAlp1))
											)
										)
										StrValNum1 = reverse(StrValNum1)
										StrValNum1Str = buildString(StrValNum1 "")
										
										StrValAlp1 = reverse(StrValAlp1)
										StrValAlpStr1 = buildString(StrValAlp1 "")
										
										StrValNum1Int = atoi(StrValNum1Str)
										
										if(StoreAlpListlp == "" || StoreAlpListlp == StrValAlpStr1 then
											pcre4 = pcreCompile("_SCN_")
											pcre5 = pcreCompile("_SI_")
											pcre6 = pcreCompile("_SO_")
											pcre7 = pcreCompile("_SC_")
											pcre8 = pcreCompile("_JTAG_")
											
											if(pcreExecute(pcre4 StrValNetName) then
												MultScnChk = "YES"
												if(StrValNum1Int < 16 then
													when(StoreListlp push(StoreListlp ErrorList11))
												else
													if(StrValNum1Int > 15 && StrValNum1Int < 32 then
														when(StoreListlp push(StoreListlp ErrorList12))
													else
														if(StrValNum1Int > 31 && StrValNum1Int < 48 then
															when(StoreListlp push(StoreListlp ErrorList13))
														else
															if(StrValNum1Int > 47 && StrValNum1Int < 64 then
																when(StoreListlp push(StoreListlp ErrorList14))
															else
																if(StrValNum1Int > 63 && StrValNum1Int < 80 then
																	when(StoreListlp push(StoreListlp ErrorList15))
																else
																	if(StrValNum1Int > 79 && StrValNum1Int < 96 then
																		when(StoreListlp push(StoreListlp ErrorList16))
																	else
																		if(StrValNum1Int > 95 && StrValNum1Int < 112 then
																			when(StoreListlp push(StoreListlp ErrorList17))
																		else
																			if(StrValNum1Int > 111 && StrValNum1Int < 128 then
																				when(StoreListlp push(StoreListlp ErrorList18))
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
											
											if(pcreExecute(pcre5 StrValNetName) then
												MultScnChk = "YES"
												if(StrValNum1Int < 16 then
													when(StoreListlp push(StoreListlp ErrorList11))
												else
													if(StrValNum1Int > 15 && StrValNum1Int < 32 then
														when(StoreListlp push(StoreListlp ErrorList12))
													else
														if(StrValNum1Int > 31 && StrValNum1Int < 48 then
															when(StoreListlp push(StoreListlp ErrorList13))
														else
															if(StrValNum1Int > 47 && StrValNum1Int < 64 then
																when(StoreListlp push(StoreListlp ErrorList14))
															else
																if(StrValNum1Int > 63 && StrValNum1Int < 80 then
																	when(StoreListlp push(StoreListlp ErrorList15))
																else
																	if(StrValNum1Int > 79 && StrValNum1Int < 96 then
																		when(StoreListlp push(StoreListlp ErrorList16))
																	else
																		if(StrValNum1Int > 95 && StrValNum1Int < 112 then
																			when(StoreListlp push(StoreListlp ErrorList17))
																		else
																			if(StrValNum1Int > 111 && StrValNum1Int < 128 then
																				when(StoreListlp push(StoreListlp ErrorList18))
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
											
											if(pcreExecute(pcre6 StrValNetName) then
												MultScnChk = "YES"
												if(StrValNum1Int < 16 then
													when(StoreListlp push(StoreListlp ErrorList11))
												else
													if(StrValNum1Int > 15 && StrValNum1Int < 32 then
														when(StoreListlp push(StoreListlp ErrorList12))
													else
														if(StrValNum1Int > 31 && StrValNum1Int < 48 then
															when(StoreListlp push(StoreListlp ErrorList13))
														else
															if(StrValNum1Int > 47 && StrValNum1Int < 64 then
																when(StoreListlp push(StoreListlp ErrorList14))
															else
																if(StrValNum1Int > 63 && StrValNum1Int < 80 then
																	when(StoreListlp push(StoreListlp ErrorList15))
																else
																	if(StrValNum1Int > 79 && StrValNum1Int < 96 then
																		when(StoreListlp push(StoreListlp ErrorList16))
																	else
																		if(StrValNum1Int > 95 && StrValNum1Int < 112 then
																			when(StoreListlp push(StoreListlp ErrorList17))
																		else
																			if(StrValNum1Int > 111 && StrValNum1Int < 128 then
																				when(StoreListlp push(StoreListlp ErrorList18))
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
											
											if(pcreExecute(pcre7 StrValNetName) then
												MultScnChk = "YES"
												if(StrValNum1Int < 16 then
													when(StoreListlp push(StoreListlp ErrorList11))
												else
													if(StrValNum1Int > 15 && StrValNum1Int < 32 then
														when(StoreListlp push(StoreListlp ErrorList12))
													else
														if(StrValNum1Int > 31 && StrValNum1Int < 48 then
															when(StoreListlp push(StoreListlp ErrorList13))
														else
															if(StrValNum1Int > 47 && StrValNum1Int < 64 then
																when(StoreListlp push(StoreListlp ErrorList14))
															else
																if(StrValNum1Int > 63 && StrValNum1Int < 80 then
																	when(StoreListlp push(StoreListlp ErrorList15))
																else
																	if(StrValNum1Int > 79 && StrValNum1Int < 96 then
																		when(StoreListlp push(StoreListlp ErrorList16))
																	else
																		if(StrValNum1Int > 95 && StrValNum1Int < 112 then
																			when(StoreListlp push(StoreListlp ErrorList17))
																		else
																			if(StrValNum1Int > 111 && StrValNum1Int < 128 then
																				when(StoreListlp push(StoreListlp ErrorList18))
																			)
																		)
																	)
																)
															)
														)
													)
												)
											)
											
											if(pcreExecute(pcre8 StrValNetName) then
												MultJTAKChk = "YES"
												if(StrValNum1Int < 16 then
													when(StoreListlp push(StoreListlp ErrorList11))
												else
													if(StrValNum1Int > 15 && StrValNum1Int < 32 then
														when(StoreListlp push(StoreListlp ErrorList12))
													else
														if(StrValNum1Int > 31 && StrValNum1Int < 48 then
															when(StoreListlp push(StoreListlp ErrorList13))
														else
															if(StrValNum1Int > 47 && StrValNum1Int < 64 then
																when(StoreListlp push(StoreListlp ErrorList14))
															else
																if(StrValNum1Int > 63 && StrValNum1Int < 80 then
																	when(StoreListlp push(StoreListlp ErrorList15))
																else
																	if(StrValNum1Int > 79 && StrValNum1Int < 96 then
																		when(StoreListlp push(StoreListlp ErrorList16))
																	else
																		if(StrValNum1Int > 95 && StrValNum1Int < 112 then
																			when(StoreListlp push(StoreListlp ErrorList17))
																		else
																			if(StrValNum1Int > 111 && StrValNum1Int < 128 then
																				when(StoreListlp push(StoreListlp ErrorList18))
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
									if(MultScnChk == "YES" && MultJTAKChk == "YES" then
										ErrorDt1 = buildString(StoreList " ")
										ErrorDtStr1 = sprintf(nil "Error: Multiple Scan Net Found In This Group --> %s", ErrorDt1)
										when(ErrorDtStr1 push(ErrorDtStr1 ErrorList))									
									)
									
									if(length(ErrorList11) > SCN_getval then
										ErrorDt2 = buildString(ErrorList11 " ")
										ErrorDtStr2 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt2)
										when(ErrorDtStr2 push(ErrorDtStr2 ErrorList))
									)
									
									if(length(ErrorList12) > SCN_getval then
										ErrorDt3 = buildString(ErrorList12 " ")
										ErrorDtStr3 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt3)
										when(ErrorDtStr3 push(ErrorDtStr3 ErrorList))
									)
									
									if(length(ErrorList13) > SCN_getval then
										ErrorDt4 = buildString(ErrorList13 " ")
										ErrorDtStr4 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt4)
										when(ErrorDtStr4 push(ErrorDtStr4 ErrorList))
									)
									
									if(length(ErrorList14) > SCN_getval then
										ErrorDt5 = buildString(ErrorList14 " ")
										ErrorDtStr5 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt5)
										when(ErrorDtStr5 push(ErrorDtStr5 ErrorList))
									)
									
									if(length(ErrorList15) > SCN_getval then
										ErrorDt6 = buildString(ErrorList15 " ")
										ErrorDtStr6 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt6)
										when(ErrorDtStr6 push(ErrorDtStr6 ErrorList))
									)
									
									if(length(ErrorList16) > SCN_getval then
										ErrorDt7 = buildString(ErrorList16 " ")
										ErrorDtStr7 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt7)
										when(ErrorDtStr7 push(ErrorDtStr7 ErrorList))
									)
									
									if(length(ErrorList17) > SCN_getval then
										ErrorDt8 = buildString(ErrorList17 " ")
										ErrorDtStr8 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt8)
										when(ErrorDtStr8 push(ErrorDtStr8 ErrorList))
									)
									
									if(length(ErrorList18) > SCN_getval then
										ErrorDt9 = buildString(ErrorList18 " ")
										ErrorDtStr9 = sprintf(nil "Error: Scan Net Count is Higher In This Group --> %s", ErrorDt9)
										when(ErrorDtStr9 push(ErrorDtStr9 ErrorList))
									)
							)
						)
					)
				)
				ErrorList = unique(ErrorList)
					if(ErrorList != nil then
						logfile = "ScanNetAssgChk.log"
						designName = axlCurrentDesign()
						design_path = axlGetDrawingName()
						design_unit = car(axlDBGetDesignUnits())
						port = axlDMOpenLog(logfile)
						fprintf(port, "Design name: %s\n", design_path)
						fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						fprintf(port, "%s\n\n", "ERROR : SCAN NET ASSINGMENT - S93K")
						fprintf(port, "%-25s %-25s \n\n", "LIST", "ERROR")
						foreach(ErrorListlp ErrorList
							fprintf(port, "%-25s\n", ErrorListlp)
						)
						fprintf(port, "\n\n")
						fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						axlDMClose(port)
						axlUIViewFileCreate(logfile, "Scan Net Assingment Check", nil, '(30 25), '(CENTER))
					else
						axlUIConfirm("No Error Found...!")

					)
		)
	)
	axlFormDisplay(SN_form)
)