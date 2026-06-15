axlCmdRegister("DiffPairPosAndNegPinAssChk" 'DiffPairPosAndNegPinAssChk)
(setq PN_form_file "DiffPairPosAndNegPinAssChk.form") 
procedure(DiffPairPosAndNegPinAssChk()
	CreatePN_form()
	RunPN_form()
)

procedure(RunPN_form() 
	let((PN_form)
		(PN_form = axlFormCreate(gensym() PN_form_file nil 'PN_Action t)) 
		axlFormDisplay(PN_form)
	)
)

procedure(CreatePN_form()
	let((PN_form)
		(PN_form = outfile(PN_form_file "w")) 
		fprintf(PN_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(PN_form "FORM\n") 
		fprintf(PN_form "FIXED\n") 
		fprintf(PN_form "PORT 45 50\n") 
		fprintf(PN_form "HEADER \"DiffPair Positive And Negative Pin Assingment Check\"\n") 
		fprintf(PN_form "\n")
		fprintf(PN_form "TILE\n")
		
		fprintf(PN_form "POPUP <BRD>\"93K\"\"93K\",\"ULTRA-FLEX\"\"ULTRA-FLEX\",\"J750\"\"J750\".\n")
		fprintf(PN_form "FIELD BRDFLD\n") 
		fprintf(PN_form "FLOC 13 2\n") 
		fprintf(PN_form "ENUMSET 17\n")
		fprintf(PN_form "POP \"BRD\"\n")
		fprintf(PN_form "ENDFIELD\n")
		fprintf(PN_form "\n")
		
		fprintf(PN_form "FIELD PROC\n") 
		fprintf(PN_form "FLOC 11 6\n") 
		fprintf(PN_form "MENUBUTTON \"CLICK HERE TO PROCEED....!\" 20 4\n") 
		fprintf(PN_form "ENDFIELD\n")
		fprintf(PN_form "\n")
		

		fprintf(PN_form "\n") 
		fprintf(PN_form "\n") 
		fprintf(PN_form "ENDTILE\n")
		
		fprintf(PN_form "\n") 
		fprintf(PN_form "ENDFORM\n")
		
		drain() 
		close(PN_form)
	)
)

procedure(PN_Action(PN_form) 
	case((PN_form->curField)
		("PROC"
			(Brd_getval = (axlFormGetField PN_form "BRDFLD"))
			axlUIConfirm("Please Select the TXT Doc PIN NUMBER List...")
			NetList_Inp = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
			fileparts = axlDMFileParts(NetList_Inp)
			NetList_Inp_Pass = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts) "r")
			NetList_List_UI = nil
			if(NetList_Inp_Pass != nil then
				while(gets(NetList_Inp_loop NetList_Inp_Pass)
					NetList_Inp_loop_prse = car(parseString(NetList_Inp_loop "\n"))
					when(NetList_Inp_loop_prse push(NetList_Inp_loop_prse NetList_List_UI))
				)
				axlDMClose(NetList_Inp_Pass)
			)
			if(NetList_List_UI != nil then
				DRCList = nil
				DRCPinList = nil
				foreach(drc_id axlDBGetDesign()->drcs
					foreach(item drc_id->violations
						if(item->objType == "pin" then  
							PinDt = sprintf(nil, "%s%s%s",item->parent->refdes, ".", item->number)
							if(item->net->name == "" then
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
										when(PinDt push(PinDt DRCPinList))
									) 
								)
							)
						)
					)
				)
				;println(DRCList)
				if(Brd_getval == "93K" then
					S93kErrorList = nil
					OrderErrorList = nil
					PosList = '("01" "02" "05" "06" "09" "10" "13" "14")
					PosListVec = listToVector(PosList)
					NegList = '("03" "04" "07" "08" "11" "12" "15" "16")
					NegListVec = listToVector(NegList)
					foreach(DRCListlp DRCList
						DrcPinDt = nth(0 parseString(DRCListlp ","))
						DrcONDt = nth(1 parseString(DRCListlp ","))
						DrcNNDt = nth(2 parseString(DRCListlp ","))
						foreach(NetList_List_UIlp NetList_List_UI
							if(NetList_List_UIlp == DrcPinDt then
								PinVal = "None"
								DrcPinDtPrse = nth(1 parseString(DrcPinDt ".")) 
								StrValNumS93k = nil
								StrValLenS93k = strlen(DrcPinDtPrse)
								for(i 1 StrValLenS93k
									TxtPrseS93k = substring(DrcPinDtPrse i 1)
									pcre1 = pcreCompile("([0-9]+)")
									when(pcreExecute(pcre1 TxtPrseS93k)
										when(TxtPrseS93k push(TxtPrseS93k StrValNumS93k))
									)
								)
								StrValNumS93k = reverse(StrValNumS93k)
								PinNumPrse = buildString(StrValNumS93k "")
								if(strlen(PinNumPrse) == 1 then
									PinNumPrse = sprintf(nil "0%s", PinNumPrse) 
								)
								foreach(PosListlp PosList
									if(PosListlp == PinNumPrse then
										PinVal = "Positive"
									)
								)
								foreach(NegListlp NegList
									if(NegListlp == PinNumPrse then
										PinVal = "Negative"
									)
								)
								PinVal1 = "None"
								NetDiffName = "Nope"
								foreach(BrdPinDt setof(comps axlDBGetDesign() ->components comps->symbol)
									foreach(BrdPinDtlp BrdPinDt->pins
										BrdPinNum = sprintf(nil "%s%s%s" BrdPinDtlp->parent->refdes, ".", BrdPinDtlp->number)
											if(BrdPinNum == DrcPinDt then
												PinXYPoint = sprintf(nil "(%.2f %.2f)", car(BrdPinDtlp->xy), cadr(BrdPinDtlp->xy))
											)
										BrdNN = BrdPinDtlp ->net->name
										foreach(NetList_List_UI1lp NetList_List_UI
											if(NetList_List_UI1lp == BrdPinNum then 
												if(BrdNN == DrcNNDt then
													NetDiffName = BrdPinDtlp ->net ->diffpair ->name
													DrcPinDtPrse1 = nth(1 parseString(BrdPinNum ".")) 
													StrValNumS93k1 = nil
													StrValLenS93k1 = strlen(DrcPinDtPrse1)
													for(i 1 StrValLenS93k1
														TxtPrseS93k1 = substring(DrcPinDtPrse1 i 1)
														pcre1 = pcreCompile("([0-9]+)")
														when(pcreExecute(pcre1 TxtPrseS93k1)
															when(TxtPrseS93k1 push(TxtPrseS93k1 StrValNumS93k1))
														)
													)
													StrValNumS93k1 = reverse(StrValNumS93k1)
													PinNumPrse1 = buildString(StrValNumS93k1 "")
													if(strlen(PinNumPrse1) == 1 then
														PinNumPrse1 = sprintf(nil "0%s", PinNumPrse1) 
													)
													foreach(PosListlp1 PosList
														if(PosListlp1 == PinNumPrse1 then
															PinVal1 = "Positive"
														)
													)
													foreach(NegListlp1 NegList
														if(NegListlp1 == PinNumPrse1 then
															PinVal1 = "Negative"
														)
													)
												)
											)
										)
									)
								)
								if(PinVal1 != "None" then
									if(PinVal != "None" then
										if(PinVal != PinVal1 then
											ErrorDt = sprintf(nil "%s,%s,%s,- Pin Is (%s) Net Is (%s)", DrcPinDt, DrcNNDt, PinXYPoint, PinVal, PinVal1)
											when(ErrorDt push(ErrorDt S93kErrorList))
										)
									)
								)
								
								DummyNetPass = nil
								foreach(NetVallp axlDBGetDesign() ->nets
									if(NetVallp ->diffpair ->name == NetDiffName then
										DiffNetName = NetVallp->name
										when(DiffNetName push(DiffNetName DummyNetPass))
									)
								)
								
								DummyPinPass = nil
								foreach(DRCListlp1 DRCList
									DrcPinDt1 = nth(0 parseString(DRCListlp1 ","))
									DrcONDt1 = nth(1 parseString(DRCListlp1 ","))
									DrcNNDt1 = nth(2 parseString(DRCListlp1 ","))
									foreach(DummyNetPasslp DummyNetPass
										if(DrcNNDt1 == DummyNetPasslp then
											when(DrcPinDt1 push(DrcPinDt1 DummyPinPass))
										)
									)
								)

								if(DummyPinPass != nil then
									Pin1Dt = car(DummyPinPass)
									Pin2Dt = cadr(DummyPinPass)
									
									FirstVal = nth(1 parseString(Pin1Dt "."))
									if(strlen(FirstVal) == 1 then
										FirstVal = sprintf(nil "0%s", FirstVal)
									)
									SecVal = nth(1 parseString(Pin2Dt "."))
									if(strlen(SecVal) == 1 then
										SecVal = sprintf(nil "0%s", SecVal)
									)
									for(i 0 7
										if(FirstVal == PosListVec[i] then
											if(SecVal != NegListVec[i] then
												ErrorDt = sprintf(nil "%s,%s", Pin1Dt, Pin2Dt)  
												when(ErrorDt push(ErrorDt OrderErrorList))
											)
										else
											if(SecVal == PosListVec[i] then
												if(FirstVal != NegListVec[i] then
													ErrorDt = sprintf(nil "%s,%s", Pin1Dt, Pin2Dt)  
													when(ErrorDt push(ErrorDt OrderErrorList))
												)
											)
										)
										
										if(FirstVal == NegListVec[i] then
											if(SecVal != PosListVec[i] then
												ErrorDt = sprintf(nil "%s,%s", Pin1Dt, Pin2Dt)  
												when(ErrorDt push(ErrorDt OrderErrorList))
											)
										else
											if(SecVal == NegListVec[i] then
												if(FirstVal != PosListVec[i] then
													ErrorDt = sprintf(nil "%s,%s", Pin1Dt, Pin2Dt)  
													when(ErrorDt push(ErrorDt OrderErrorList))
												)
											)
										)
									)
								)
							)
						)
					)
				OrderErrorList = unique(OrderErrorList)
				FinalOrderErrorList = nil
				foreach(BrdPinDt1 setof(comps axlDBGetDesign() ->components comps->symbol)
					foreach(BrdPinDtlp1 BrdPinDt1->pins
						BrdPinNum1 = sprintf(nil "%s%s%s" BrdPinDtlp1->parent->refdes, ".", BrdPinDtlp1->number)
						foreach(OrderErrorListlp OrderErrorList
							PinOnedt = nth(0 parseString(OrderErrorListlp ",")) 
							PinSecdt = nth(1 parseString(OrderErrorListlp ",")) 
							if(BrdPinNum1 == PinOnedt then
								foreach(BrdPinDtlp2 BrdPinDt1->pins
									BrdPinNum2 = sprintf(nil "%s%s%s" BrdPinDtlp2->parent->refdes, ".", BrdPinDtlp2->number)
									if(PinSecdt == BrdPinNum2 then
										ErrorDtOrd = sprintf(nil "%s,(%.2f %.2f),%s,(%.2f %.2f), - Error --> Pin Order Wrong", PinOnedt, car(BrdPinDtlp1->xy), cadr(BrdPinDtlp1->xy), PinSecdt, car(BrdPinDtlp2->xy), cadr(BrdPinDtlp2->xy))
										when(ErrorDtOrd push(ErrorDtOrd FinalOrderErrorList))
									)
								)
							)
						)
					)
				)
				FinalOrderErrorList = unique(FinalOrderErrorList)
				S93kErrorList = unique(S93kErrorList)
				ErrorList = nil
				ErrorList = append(FinalOrderErrorList S93kErrorList)
				
				else
					if(Brd_getval == "ULTRA-FLEX" then
						UFErrorList = nil
						OrderErrorListUF = nil
						PosListUF = '("0" "2" "4" "6" "8" "10" "12" "14" "16" "18" "20" "22" "24" "26" "28" "30" "32" "34" "36" "38" "40" "42" "44" "46" "48" "50" "52" "54" "56" "58" "60" "62" "64" "66" "68" "70" "72" "74" "76" "78" "80" "82" "84" "86" "88" "90" "92" "94" "96" "98" "100" "102" "104" "106" "108" "110" "112" "114" "116" "118" "120" "122" "124" "126" "128" "130" "132" "134" "136" "138" "140" "142" "144" "146" "148" "150" "152" "154" "156" "158" "160" "162" "164" "166" "168" "170" "172" "174" "176" "178" "180" "182" "184" "186" "188" "190" "192" "194" "196" "198" "200" "202" "204" "206" "208" "210" "212" "214" "216" "218" "220" "222" "224" "226" "228" "230" "232" "234" "236" "238" "240" "242" "244" "246" "248" "250" "252" "254")
						PosListUFVec = listToVector(PosListUF)
						NegListUF = '("1" "3" "5" "7" "9" "11" "13" "15" "17" "19" "21" "23" "25" "27" "29" "31" "33" "35" "37" "39" "41" "43" "45" "47" "49" "51" "53" "55" "57" "59" "61" "63" "65" "67" "69" "71" "73" "75" "77" "79" "81" "83" "85" "87" "89" "91" "93" "95" "97" "99" "101" "103" "105" "107" "109" "111" "113" "115" "117" "119" "121" "123" "125" "127" "129" "131" "133" "135" "137" "139" "141" "143" "145" "147" "149" "151" "153" "155" "157" "159" "161" "163" "165" "167" "169" "171" "173" "175" "177" "179" "181" "183" "185" "187" "189" "191" "193" "195" "197" "199" "201" "203" "205" "207" "209" "211" "213" "215" "217" "219" "221" "223" "225" "227" "229" "231" "233" "235" "237" "239" "241" "243" "245" "247" "249" "251" "253" "255")
						NegListUFVec = listToVector(NegListUF)
						foreach(DRCListlpUF DRCList
							DrcPinDtUF = nth(0 parseString(DRCListlpUF ","))
							DrcONDtUF = nth(1 parseString(DRCListlpUF ","))
							DrcNNDtUF = nth(2 parseString(DRCListlpUF ","))
							foreach(NetList_List_UIlpUF NetList_List_UI
								if(NetList_List_UIlpUF == DrcPinDtUF then
									PinValUF = "None"
									DrcPinDtUFPrse = nth(1 parseString(DrcPinDtUF ".")) 
									StrValNum = nil
									StrValLen = strlen(DrcPinDtUFPrse)
									for(i 1 StrValLen
										TxtPrse = substring(DrcPinDtUFPrse i 1)
										pcre1 = pcreCompile("([0-9]+)")
										when(pcreExecute(pcre1 TxtPrse)
											when(TxtPrse push(TxtPrse StrValNum))
										)
									)
									StrValNum = reverse(StrValNum)
									PinNumPrseUF = buildString(StrValNum "")
									foreach(PosListlpUF PosListUF
										if(PosListlpUF == PinNumPrseUF then
											PinValUF = "Positive"
										)
									)
									foreach(NegListlpUF NegListUF
										if(NegListlpUF == PinNumPrseUF then
											PinValUF = "Negative"
										)
									)
									PinVal1UF = "None"
									NetDiffNameUF = "Nope"
									foreach(BrdPinDtUF setof(comps axlDBGetDesign() ->components comps->symbol)
										foreach(BrdPinDtlpUF BrdPinDtUF->pins
											BrdPinNumUF = sprintf(nil "%s%s%s" BrdPinDtlpUF->parent->refdes, ".", BrdPinDtlpUF->number)
												if(BrdPinNumUF == DrcPinDtUF then
													PinXYPointUF = sprintf(nil "(%.2f %.2f)", car(BrdPinDtlpUF->xy), cadr(BrdPinDtlpUF->xy))
												)
											BrdNNUF = BrdPinDtlpUF ->net->name
											foreach(NetList_List_UI1lpUF NetList_List_UI
												if(NetList_List_UI1lpUF == BrdPinNumUF then 
													if(BrdNNUF == DrcNNDtUF then
														NetDiffNameUF = BrdPinDtlpUF ->net ->diffpair ->name
														BrdPinNumUFPrse = nth(1 parseString(BrdPinNumUF ".")) 
														StrValNum1 = nil
														StrValLen1 = strlen(BrdPinNumUFPrse)
														for(i 1 StrValLen1
															TxtPrse1 = substring(BrdPinNumUFPrse i 1)
															pcre11 = pcreCompile("([0-9]+)")
															when(pcreExecute(pcre11 TxtPrse1)
																when(TxtPrse1 push(TxtPrse1 StrValNum1))
															)
														)
														StrValNum1 = reverse(StrValNum1)
														PinNumPrse1UF = buildString(StrValNum1 "")
														foreach(PosListlp1UF PosListUF
															if(PosListlp1UF == PinNumPrse1UF then
																PinVal1UF = "Positive"
															)
														)
														foreach(NegListlp1UF NegListUF
															if(NegListlp1UF == PinNumPrse1UF then
																PinVal1UF = "Negative"
															)
														)
													)
												)
											)
										)
									)
									if(PinVal1UF != "None" then
										if(PinValUF != "None" then
											if(PinValUF != PinVal1UF then
												ErrorDtUF = sprintf(nil "%s,%s,%s,- Pin Is (%s) Net Is (%s)", DrcPinDtUF, DrcNNDtUF, PinXYPointUF, PinValUF, PinVal1UF)
												when(ErrorDtUF push(ErrorDtUF UFErrorList))
											)
										)
									)
									
									DummyNetPassUF = nil
									foreach(NetVallpUF axlDBGetDesign() ->nets
										if(NetVallpUF ->diffpair ->name == NetDiffNameUF then
											DiffNetNameUF = NetVallpUF->name
											when(DiffNetNameUF push(DiffNetNameUF DummyNetPassUF))
										)
									)
									
									DummyPinPassUF = nil
									foreach(DRCListlp1UF DRCList
										DrcPinDt1UF = nth(0 parseString(DRCListlp1UF ","))
										DrcONDt1UF = nth(1 parseString(DRCListlp1UF ","))
										DrcNNDt1UF = nth(2 parseString(DRCListlp1UF ","))
										foreach(DummyNetPasslpUF DummyNetPassUF
											if(DrcNNDt1UF == DummyNetPasslpUF then
												when(DrcPinDt1UF push(DrcPinDt1UF DummyPinPassUF))
											)
										)
									)
									
									if(DummyPinPassUF != nil then
										Pin1DtUF = car(DummyPinPassUF)
										Pin2DtUF = cadr(DummyPinPassUF)
										
										FirstValUF = nth(1 parseString(Pin1DtUF "."))
										if(strlen(FirstValUF) == 1 then
											FirstValUF = sprintf(nil "0%s", FirstValUF)
										)
										SecValUF = nth(1 parseString(Pin2DtUF "."))
										if(strlen(SecValUF) == 1 then
											SecValUF = sprintf(nil "0%s", SecValUF)
										)
										for(i 0 128
											if(FirstValUF == PosListUFVec[i] then
												if(SecValUF != NegListUFVec[i] then
													ErrorDtUF = sprintf(nil "%s,%s", Pin1DtUF, Pin2DtUF)  
													when(ErrorDtUF push(ErrorDtUF OrderErrorListUF))
												)
											else
												if(SecValUF == PosListUFVec[i] then
													if(FirstValUF != NegListUFVec[i] then
														ErrorDtUF = sprintf(nil "%s,%s", Pin1DtUF, Pin2DtUF)  
														when(ErrorDtUF push(ErrorDtUF OrderErrorListUF))
													)
												)
											)
											
											if(FirstValUF == NegListUFVec[i] then
												if(SecValUF != PosListUFVec[i] then
													ErrorDtUF = sprintf(nil "%s,%s", Pin1DtUF, Pin2DtUF)  
													when(ErrorDtUF push(ErrorDtUF OrderErrorListUF))
												)
											else
												if(SecValUF == NegListUFVec[i] then
													if(FirstValUF != PosListUFVec[i] then
														ErrorDtUF = sprintf(nil "%s,%s", Pin1DtUF, Pin2DtUF)  
														when(ErrorDtUF push(ErrorDtUF OrderErrorListUF))
													)
												)
											)
										)
									)	
								)
							)
						)
						OrderErrorListUF = unique(OrderErrorListUF)
						FinalOrderErrorListUF = nil
						foreach(BrdPinDt1UF setof(comps axlDBGetDesign() ->components comps->symbol)
							foreach(BrdPinDtlp1UF BrdPinDt1UF->pins
								BrdPinNum1UF = sprintf(nil "%s%s%s" BrdPinDtlp1UF->parent->refdes, ".", BrdPinDtlp1UF->number)
								foreach(OrderErrorListlpUF OrderErrorListUF
									PinOnedtUF = nth(0 parseString(OrderErrorListlpUF ",")) 
									PinSecdtUF = nth(1 parseString(OrderErrorListlpUF ",")) 
									if(BrdPinNum1UF == PinOnedtUF then
										foreach(BrdPinDtlp2UF BrdPinDt1UF->pins
											BrdPinNum2UF = sprintf(nil "%s%s%s" BrdPinDtlp2UF->parent->refdes, ".", BrdPinDtlp2UF->number)
											if(PinSecdtUF == BrdPinNum2UF then
												ErrorDtOrdUF = sprintf(nil "%s,(%.2f %.2f),%s,(%.2f %.2f), - Error --> Pin Order Wrong", PinOnedtUF, car(BrdPinDtlp1UF->xy), cadr(BrdPinDtlp1UF->xy), PinSecdtUF, car(BrdPinDtlp2UF->xy), cadr(BrdPinDtlp2UF->xy))
												when(ErrorDtOrdUF push(ErrorDtOrdUF FinalOrderErrorListUF))
											)
										)
									)
								)
							)
						)
						FinalOrderErrorListUF = unique(FinalOrderErrorListUF)
						UFErrorList = unique(UFErrorList)
						ErrorList = nil
						ErrorList = append(FinalOrderErrorListUF UFErrorList)
						
					else
						if(Brd_getval == "J750" then
							JErrorList = nil
							OrderErrorListJ = nil
							PosListJ = '("0" "2" "4" "6" "8" "10" "12" "14" "16" "18" "20" "22" "24" "26" "28" "30" "32" "34" "36" "38" "40" "42" "44" "46" "48" "50" "52" "54" "56" "58" "60" "62" "64" "66" "68" "70" "72" "74" "76" "78" "80" "82" "84" "86" "88" "90" "92" "94" "96" "98" "100" "102" "104" "106" "108" "110" "112" "114" "116" "118" "120" "122" "124" "126")
							PosListJVec = listToVector(PosListJ)
							NegListJ = '("1" "3" "5" "7" "9" "11" "13" "15" "17" "19" "21" "23" "25" "27" "29" "31" "33" "35" "37" "39" "41" "43" "45" "47" "49" "51" "53" "55" "57" "59" "61" "63" "65" "67" "69" "71" "73" "75" "77" "79" "81" "83" "85" "87" "89" "91" "93" "95" "97" "99" "101" "103" "105" "107" "109" "111" "113" "115" "117" "119" "121" "123" "125" "127")
							NegListJVec = listToVector(NegListJ)
							foreach(DRCListlpJ DRCList
								DrcPinDtJ = nth(0 parseString(DRCListlpJ ","))
								DrcONDtJ = nth(1 parseString(DRCListlpJ ","))
								DrcNNDtJ = nth(2 parseString(DRCListlpJ ","))
								foreach(NetList_List_UIlpJ NetList_List_UI
									if(NetList_List_UIlpJ == DrcPinDtJ then
										PinValJ = "None"
										DrcPinDtJPrse = nth(1 parseString(DrcPinDtJ ".")) 
										StrValNum = nil
										StrValLen = strlen(DrcPinDtJPrse)
										for(i 1 StrValLen
											TxtPrse = substring(DrcPinDtJPrse i 1)
											pcre1 = pcreCompile("([0-9]+)")
											when(pcreExecute(pcre1 TxtPrse)
												when(TxtPrse push(TxtPrse StrValNum))
											)
										)
										StrValNum = reverse(StrValNum)
										PinNumPrseJ = buildString(StrValNum "")
										foreach(PosListlpJ PosListJ
											if(PosListlpJ == PinNumPrseJ then
												PinValJ = "Positive"
											)
										)
										foreach(NegListlpJ NegListJ
											if(NegListlpJ == PinNumPrseJ then
												PinValJ = "Negative"
											)
										)
										PinVal1J = "None"
										NetDiffNameJ = "Nope"
										foreach(BrdPinDtJ setof(comps axlDBGetDesign() ->components comps->symbol)
											foreach(BrdPinDtlpJ BrdPinDtJ->pins
												BrdPinNumJ = sprintf(nil "%s%s%s" BrdPinDtlpJ->parent->refdes, ".", BrdPinDtlpJ->number)
													if(BrdPinNumJ == DrcPinDtJ then
														PinXYPointJ = sprintf(nil "(%.2f %.2f)", car(BrdPinDtlpJ->xy), cadr(BrdPinDtlpJ->xy))
													)
												BrdNNJ = BrdPinDtlpJ ->net->name
												foreach(NetList_List_UI1lpJ NetList_List_UI
													if(NetList_List_UI1lpJ == BrdPinNumJ then 
														if(BrdNNJ == DrcNNDtJ then
															NetDiffNameJ = BrdPinDtlpJ ->net ->diffpair ->name
															BrdPinNumJPrse = nth(1 parseString(BrdPinNumJ ".")) 
															StrValNum1 = nil
															StrValLen1 = strlen(BrdPinNumJPrse)
															for(i 1 StrValLen1
																TxtPrse1 = substring(BrdPinNumJPrse i 1)
																pcre11 = pcreCompile("([0-9]+)")
																when(pcreExecute(pcre11 TxtPrse1)
																	when(TxtPrse1 push(TxtPrse1 StrValNum1))
																)
															)
															StrValNum1 = reverse(StrValNum1)
															PinNumPrse1J = buildString(StrValNum1 "")
															foreach(PosListlp1J PosListJ
																if(PosListlp1J == PinNumPrse1J then
																	PinVal1J = "Positive"
																)
															)
															foreach(NegListlp1J NegListJ
																if(NegListlp1J == PinNumPrse1J then
																	PinVal1J = "Negative"
																)
															)
														)
													)
												)
											)
										)
										if(PinVal1J != "None" then
											if(PinValJ != "None" then
												if(PinValJ != PinVal1J then
													ErrorDtJ = sprintf(nil "%s,%s,%s,- Pin Is (%s) Net Is (%s)", DrcPinDtJ, DrcNNDtJ, PinXYPointJ, PinValJ, PinVal1J)
													when(ErrorDtJ push(ErrorDtJ JErrorList))
												)
											)
										)
										
										DummyNetPassJ = nil
										foreach(NetVallpJ axlDBGetDesign() ->nets
											if(NetVallpJ ->diffpair ->name == NetDiffNameJ then
												DiffNetNameJ = NetVallpJ->name
												when(DiffNetNameJ push(DiffNetNameJ DummyNetPassJ))
											)
										)
										
										DummyPinPassJ = nil
										foreach(DRCListlp1J DRCList
											DrcPinDt1J = nth(0 parseString(DRCListlp1J ","))
											DrcONDt1J = nth(1 parseString(DRCListlp1J ","))
											DrcNNDt1J = nth(2 parseString(DRCListlp1J ","))
											foreach(DummyNetPasslpJ DummyNetPassJ
												if(DrcNNDt1J == DummyNetPasslpJ then
													when(DrcPinDt1J push(DrcPinDt1J DummyPinPassJ))
												)
											)
										)
										
										if(DummyPinPassJ != nil then
											Pin1DtJ = car(DummyPinPassJ)
											Pin2DtJ = cadr(DummyPinPassJ)
											
											FirstValJ = nth(1 parseString(Pin1DtJ "."))
											if(strlen(FirstValJ) == 1 then
												FirstValJ = sprintf(nil "0%s", FirstValJ)
											)
											SecValJ = nth(1 parseString(Pin2DtJ "."))
											if(strlen(SecValJ) == 1 then
												SecValJ = sprintf(nil "0%s", SecValJ)
											)
											for(i 0 64
												if(FirstValJ == PosListJVec[i] then
													if(SecValJ != NegListJVec[i] then
														ErrorDtJ = sprintf(nil "%s,%s", Pin1DtJ, Pin2DtJ)  
														when(ErrorDtJ push(ErrorDtJ OrderErrorListJ))
													)
												else
													if(SecValJ == PosListJVec[i] then
														if(FirstValJ != NegListJVec[i] then
															ErrorDtJ = sprintf(nil "%s,%s", Pin1DtJ, Pin2DtJ)  
															when(ErrorDtJ push(ErrorDtJ OrderErrorListJ))
														)
													)
												)
												
												if(FirstValJ == NegListJVec[i] then
													if(SecValJ != PosListJVec[i] then
														ErrorDtJ = sprintf(nil "%s,%s", Pin1DtJ, Pin2DtJ)  
														when(ErrorDtJ push(ErrorDtJ OrderErrorListJ))
													)
												else
													if(SecValJ == NegListJVec[i] then
														if(FirstValJ != PosListJVec[i] then
															ErrorDtJ = sprintf(nil "%s,%s", Pin1DtJ, Pin2DtJ)  
															when(ErrorDtJ push(ErrorDtJ OrderErrorListJ))
														)
													)
												)
											)
										)	
									)
								)
							)
							OrderErrorListJ = unique(OrderErrorListJ)
							FinalOrderErrorListJ = nil
							foreach(BrdPinDt1J setof(comps axlDBGetDesign() ->components comps->symbol)
								foreach(BrdPinDtlp1J BrdPinDt1J->pins
									BrdPinNum1J = sprintf(nil "%s%s%s" BrdPinDtlp1J->parent->refdes, ".", BrdPinDtlp1J->number)
									foreach(OrderErrorListlpJ OrderErrorListJ
										PinOnedtJ = nth(0 parseString(OrderErrorListlpJ ",")) 
										PinSecdtJ = nth(1 parseString(OrderErrorListlpJ ",")) 
										if(BrdPinNum1J == PinOnedtJ then
											foreach(BrdPinDtlp2J BrdPinDt1J->pins
												BrdPinNum2J = sprintf(nil "%s%s%s" BrdPinDtlp2J->parent->refdes, ".", BrdPinDtlp2J->number)
												if(PinSecdtJ == BrdPinNum2J then
													ErrorDtOrdJ = sprintf(nil "%s,(%.2f %.2f),%s,(%.2f %.2f), - Error --> Pin Order Wrong", PinOnedtJ, car(BrdPinDtlp1J->xy), cadr(BrdPinDtlp1J->xy), PinSecdtJ, car(BrdPinDtlp2J->xy), cadr(BrdPinDtlp2J->xy))
													when(ErrorDtOrdJ push(ErrorDtOrdJ FinalOrderErrorListJ))
												)
											)
										)
									)
								)
							)
							FinalOrderErrorListJ = unique(FinalOrderErrorListJ)
							JErrorList = unique(JErrorList)
							ErrorList = nil
							ErrorList = append(FinalOrderErrorListJ JErrorList)
						)
					)
				)
				
				if(ErrorList != nil then
					logfile = "DiffPairPosAndNegPinAssChk.log"
					designName = axlCurrentDesign()
					design_path = axlGetDrawingName()
					design_unit = car(axlDBGetDesignUnits())
					port = axlDMOpenLog(logfile)
					fprintf(port, "Design name: %s\n", design_path)
					fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
					if(Brd_getval == "93K" then
						if(S93kErrorList != nil then
							fprintf(port, "%s\n\n", "ERROR : POSITIVE NEGATIVE ASSINGING")
							fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "PIN NUMBER", "NEW NET NAME", "XY LOCATION", "ERROR")
							foreach(S93kErrorListlp S93kErrorList
								S93kErrorListlp_filt = parseString(S93kErrorListlp ",")
								fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 S93kErrorListlp_filt), nth(1 S93kErrorListlp_filt), nth(2 S93kErrorListlp_filt), nth(3 S93kErrorListlp_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR IN POSITIVE NEGATIVE ASSINGING")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						)
						
						if(FinalOrderErrorList != nil then
							fprintf(port, "%s\n\n", "ERROR: PIN ASSINGMENT ORDER")
							fprintf(port, "%-25s %-25s %-25s %-25s %-25s\n\n", "PIN 1", "PIN 1 XY LOCATION", "PIN 2", "PIN 2 XY LOCATION", "ERROR")
							foreach(FinalOrderErrorListlp FinalOrderErrorList
								FinalOrderErrorListlp_filt = parseString(FinalOrderErrorListlp ",")
								fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalOrderErrorListlp_filt), nth(1 FinalOrderErrorListlp_filt), nth(2 FinalOrderErrorListlp_filt), nth(3 FinalOrderErrorListlp_filt), nth(4 FinalOrderErrorListlp_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR : PIN ASSINGMENT ORDER")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						)
					)
					if(Brd_getval == "ULTRA-FLEX" then
						if(UFErrorList != nil then
							fprintf(port, "%s\n\n", "ERROR : POSITIVE NEGATIVE ASSINGING")
							fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "PIN NUMBER", "NEW NET NAME", "XY LOCATION", "ERROR")
							foreach(UFErrorListlp UFErrorList
								UFErrorListlp_filt = parseString(UFErrorListlp ",")
								fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 UFErrorListlp_filt), nth(1 UFErrorListlp_filt), nth(2 UFErrorListlp_filt), nth(3 UFErrorListlp_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR IN POSITIVE NEGATIVE ASSINGING")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						)
						
						if(FinalOrderErrorListUF != nil then
							fprintf(port, "%s\n\n", "ERROR: PIN ASSINGMENT ORDER")
							fprintf(port, "%-25s %-25s %-25s %-25s %-25s\n\n", "PIN 1", "PIN 1 XY LOCATION", "PIN 2", "PIN 2 XY LOCATION", "ERROR")
							foreach(FinalOrderErrorListUFlp FinalOrderErrorListUF
								FinalOrderErrorListUFlp_filt = parseString(FinalOrderErrorListUFlp ",")
								fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalOrderErrorListUFlp_filt), nth(1 FinalOrderErrorListUFlp_filt), nth(2 FinalOrderErrorListUFlp_filt), nth(3 FinalOrderErrorListUFlp_filt), nth(4 FinalOrderErrorListUFlp_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR : PIN ASSINGMENT ORDER")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						)
					)
					if(Brd_getval == "J750" then
						if(JErrorList != nil then
							fprintf(port, "%s\n\n", "ERROR : POSITIVE NEGATIVE ASSINGING")
							fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "PIN NUMBER", "NEW NET NAME", "XY LOCATION", "ERROR")
							foreach(JErrorListlp JErrorList
								JErrorListlp_filt = parseString(JErrorListlp ",")
								fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 JErrorListlp_filt), nth(1 JErrorListlp_filt), nth(2 JErrorListlp_filt), nth(3 JErrorListlp_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR IN POSITIVE NEGATIVE ASSINGING")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						)
						
						if(FinalOrderErrorListJ != nil then
							fprintf(port, "%s\n\n", "ERROR: PIN ASSINGMENT ORDER")
							fprintf(port, "%-25s %-25s %-25s %-25s %-25s\n\n", "PIN 1", "PIN 1 XY LOCATION", "PIN 2", "PIN 2 XY LOCATION", "ERROR")
							foreach(FinalOrderErrorListJlp FinalOrderErrorListJ
								FinalOrderErrorListJlp_filt = parseString(FinalOrderErrorListJlp ",")
								fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalOrderErrorListJlp_filt), nth(1 FinalOrderErrorListJlp_filt), nth(2 FinalOrderErrorListJlp_filt), nth(3 FinalOrderErrorListJlp_filt), nth(4 FinalOrderErrorListJlp_filt))
							)
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						else
							fprintf(port, "%s\n", "NO ERROR : PIN ASSINGMENT ORDER")
							fprintf(port, "\n\n")
							fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						)
					)
					axlDMClose(port)
					axlUIViewFileCreate(logfile, "Pin Assingment Check", nil, '(30 25), '(CENTER))
				else
					axlUIConfirm("No Error Found...!")

				)
			else
				axlUIConfirm("Selected File is Empty...")
			)
		)
	)
	axlFormDisplay(PN_form)
)