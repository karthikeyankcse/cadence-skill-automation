axlCmdRegister("CouponGNDVia" 'CouponGNDVia)
procedure(CouponGNDVia()
GV_BrowC2 = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	GV_OpenFileC2 = axlDMFileParts(GV_BrowC2)
	GV_DataInFileC2 = axlDMOpenFile("ALLEGRO_TEXT" cadr(GV_OpenFileC2) "r") 
	GV_UserInputC2 = nil
		while(gets(GV_Inp_ValC2 GV_DataInFileC2)
			GV_Inp_ValC2 = car(parseString(GV_Inp_ValC2 "\n"))
				when(GV_Inp_ValC2 push(GV_Inp_ValC2 GV_UserInputC2))
			)
axlDMClose(GV_DataInFileC2)
GV_UserInputC2 = unique(GV_UserInputC2)

Inp_Distance = axlEnterString(?prompts list("Enter the DUT Region AirGap...!"))
Inp_Distance = atof(Inp_Distance)

Inp_DistanceOut = axlEnterString(?prompts list("Enter the OUTSIDE DUT AirGap...!"))
Inp_DistanceOut = atof(Inp_DistanceOut)

etchparam = axlGetParam("paramLayerGroup:ETCH")
l_layers = etchparam->groupMembers


originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")

MainDutList = nil
MainDutList1 = nil
MainOutList = nil
MainOutList1 = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
viadata = axlGetSelSet(axlAddSelectAll()) 
axlVisibleSet(originalVisible)
axlShell("redisplay")
foreach(viadatalp viadata
	Via_NetName = viadatalp->net->name
	MainInpViaX = car(viadatalp ->xy)
	MainInpViaY = cadr(viadatalp ->xy) 
	if(Via_NetName != nil then
		foreach(GV_UserInputC2lp GV_UserInputC2
			Main_Inp_NetName = nth(0 parseString(GV_UserInputC2lp ","))
			ViaLyrList = nil
			ViaLyrListOD = nil
			ViaLyrList1 = nil
			ViaLyrList1OD = nil
			if(Main_Inp_NetName == Via_NetName then
				BoxTopX = MainInpViaX - Inp_Distance 
				BoxTopY = MainInpViaY + Inp_Distance
				BoxBotX = MainInpViaX + Inp_Distance
				BoxBotY = MainInpViaY - Inp_Distance 
				
				BoxTopXO = MainInpViaX - Inp_DistanceOut 
				BoxTopYO = MainInpViaY + Inp_DistanceOut
				BoxBotXO = MainInpViaX + Inp_DistanceOut
				BoxBotYO = MainInpViaY - Inp_DistanceOut
				
				PassVal = "NO WE CANT"
				axlVisibleDesign(nil)
				axlVisibleLayer(strcat("CONSTRAINT REGION/", "ALL") t)
				axlVisibleUpdate(t)
				axlClearSelSet()
				axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
				Shpdata = axlGetSelSet(axlAddSelectAll())
				prog(()
					foreach(Shpdatalp Shpdata
						ShpLyr = Shpdatalp ->layer
						if(ShpLyr == "CONSTRAINT REGION/ALL" then
							AirGapSV = (axlAirGap Shpdatalp viadatalp nil 'anyLayer)
							if(AirGapSV == 0.0 then
								PassVal = "YES WE CAN GO"
								return()
							)
						)
					)
				)
						if(PassVal == "YES WE CAN GO" then
							ConLyr = axlDBGetConnect(viadatalp t)
							foreach(ConLyrlp ConLyr
								if(ConLyrlp->objType == "path" then
									ClineLyrData = ConLyrlp->layer
									when(ClineLyrData push(ClineLyrData ViaLyrList))
								)
							)
							if(length(ViaLyrList) == 1 then
								foreach(ConLyrPlp ConLyr  
									if(ConLyrPlp->objType == "pin" then
										PinLyrData = car(ConLyrPlp->startEnd)
										when(PinLyrData push(PinLyrData ViaLyrList))
									)
								)
							)
							
							if(length(ViaLyrList) == 0 then
								ViaLyrList = '("BOTTOM" "TOP")
							)
							foreach(l_layerslpod3 l_layers
								foreach(ViaLyrListlp3 ViaLyrList
									ViaLyrListFilt3 = nth(1 parseString(ViaLyrListlp3 "/"))
									if(ViaLyrListFilt3 == l_layerslpod3 then
										when(ViaLyrListlp3 push(ViaLyrListlp3 ViaLyrListOD))
									)
								)
							)
							ViaLyrListOD = reverse(ViaLyrListOD)
							if(length(ViaLyrListOD) == 2 then
								FirstVal = nth(1 parseString(car(ViaLyrListOD) "/"))
								SecondVal = nth(1 parseString(cadr(ViaLyrListOD) "/"))
								DummyVal = 0
								foreach(layerlp l_layers
									if(layerlp == FirstVal then
										prog(()
											foreach(layerlpS l_layers
												if(layerlpS == FirstVal then
													DummyVal = 1
												)
												if(layerlpS == SecondVal then
													axlVisibleDesign(nil)
													axlVisibleLayer(strcat("ETCH/", layerlpS) t)
													axlVisibleUpdate(t)
													axlClearSelSet()
													axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
													BoxshpInp = axlGetSelSet(axlSingleSelectBox( list(BoxTopX:BoxTopY BoxBotX:BoxBotY)))
													if(BoxshpInp != nil
														foreach(BoxshpInplp BoxshpInp
															ShapeNetName = BoxshpInplp->net->name
															ShapeLyr = nth(1 parseString(BoxshpInplp -> layer "/"))
															if(ShapeLyr == layerlpS then
																pcre_GND = pcreCompile("GND")
																when(pcreExecute(pcre_GND ShapeNetName)
																	AirGapVal = (axlAirGap BoxshpInplp viadatalp nil 'anyLayer)
																	when(AirGapVal
																		MechData = sprintf(nil "%s,%s,%.2f", GV_UserInputC2lp, ShapeLyr, AirGapVal)
																		MechData1 = sprintf(nil "%s,%s", GV_UserInputC2lp, ShapeLyr)
																		when(MechData1 push(MechData1 MainDutList1))
																		when(MechData push(MechData MainDutList))
																	)
																)
															)												
														)
													)
													return()
												else
													if(DummyVal == 1 then
														axlVisibleDesign(nil)
														axlVisibleLayer(strcat("ETCH/", layerlpS) t)
														axlVisibleUpdate(t)
														axlClearSelSet()
														axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
														BoxshpInp = axlGetSelSet(axlSingleSelectBox( list(BoxTopX:BoxTopY BoxBotX:BoxBotY)))
														if(BoxshpInp != nil
															foreach(BoxshpInplp BoxshpInp
																ShapeNetName = BoxshpInplp->net->name
																ShapeLyr = nth(1 parseString(BoxshpInplp -> layer "/"))
																if(ShapeLyr == layerlpS then
																	pcre_GND = pcreCompile("GND")
																	when(pcreExecute(pcre_GND ShapeNetName)
																		AirGapVal = (axlAirGap BoxshpInplp viadatalp nil 'anyLayer)
																		when(AirGapVal
																			MechData = sprintf(nil "%s,%s,%.2f", GV_UserInputC2lp, ShapeLyr, AirGapVal)
																			MechData1 = sprintf(nil "%s,%s", GV_UserInputC2lp, ShapeLyr)
																			when(MechData1 push(MechData1 MainDutList1))
																			when(MechData push(MechData MainDutList))
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
							)						
						
						else
							ConLyr1 = axlDBGetConnect(viadatalp t)
							foreach(ConLyrlp1 ConLyr1
								if(ConLyrlp1->objType == "path" then
									ClineLyrData1 = ConLyrlp1->layer
									when(ClineLyrData1 push(ClineLyrData1 ViaLyrList1))
								)
							)
							if(length(ViaLyrList1) == 1 then
								foreach(ConLyrPlp1 ConLyr1  
									if(ConLyrPlp1->objType == "pin" then
										PinLyrData1 = car(ConLyrPlp1->startEnd)
										when(PinLyrData1 push(PinLyrData1 ViaLyrList1))
									)
								)
							)
							
							if(length(ViaLyrList1) == 0 then
								ViaLyrList1 = '("BOTTOM" "TOP")
							)
							foreach(l_layerslpod2 l_layers
								foreach(ViaLyrListlp2 ViaLyrList1
									ViaLyrListFilt2 = nth(1 parseString(ViaLyrListlp2 "/"))
									if(ViaLyrListFilt2 == l_layerslpod2 then
										when(ViaLyrListlp2 push(ViaLyrListlp2 ViaLyrList1OD))
									)
								)
							)
							ViaLyrList1OD = reverse(ViaLyrList1OD)
							if(length(ViaLyrList1OD) == 2 then
								FirstVal1 = nth(1 parseString(car(ViaLyrList1OD) "/"))
								SecondVal1 = nth(1 parseString(cadr(ViaLyrList1OD) "/"))
								DummyVal1 = 0
								foreach(layerlp1 l_layers
									if(layerlp1 == FirstVal1 then
										prog(()
											foreach(layerlpS1 l_layers
												if(layerlpS1 == FirstVal1 then
													DummyVal1 = 1
												)
												if(layerlpS1 == SecondVal1 then
													axlVisibleDesign(nil)
													axlVisibleLayer(strcat("ETCH/", layerlpS1) t)
													axlVisibleUpdate(t)
													axlClearSelSet()
													axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
													BoxshpInp1 = axlGetSelSet(axlSingleSelectBox( list(BoxTopXO:BoxTopYO BoxBotXO:BoxBotYO)))
													if(BoxshpInp1 != nil
														foreach(BoxshpInplp1 BoxshpInp1
															ShapeNetName1 = BoxshpInplp1->net->name
															ShapeLyr1 = nth(1 parseString(BoxshpInplp1 -> layer "/"))
															if(ShapeLyr1 == layerlpS1 then
																pcre_GND1 = pcreCompile("GND")
																when(pcreExecute(pcre_GND1 ShapeNetName1)
																	AirGapVal1 = (axlAirGap BoxshpInplp1 viadatalp nil 'anyLayer)
																	when(AirGapVal1
																		MechData1 = sprintf(nil "%s,%s,%.2f", GV_UserInputC2lp, ShapeLyr1, AirGapVal1)
																		MechData2 = sprintf(nil "%s,%s", GV_UserInputC2lp, ShapeLyr1)
																		when(MechData2 push(MechData2 MainOutList1))
																		when(MechData1 push(MechData1 MainOutList))
																	)
																)
															)												
														)
													)
													return()
												else
													if(DummyVal1 == 1 then
														axlVisibleDesign(nil)
														axlVisibleLayer(strcat("ETCH/", layerlpS1) t)
														axlVisibleUpdate(t)
														axlClearSelSet()
														axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
														BoxshpInp1 = axlGetSelSet(axlSingleSelectBox( list(BoxTopXO:BoxTopYO BoxBotXO:BoxBotYO)))
														if(BoxshpInp1 != nil
															foreach(BoxshpInplp1 BoxshpInp1
																ShapeNetName1 = BoxshpInplp1->net->name
																ShapeLyr1 = nth(1 parseString(BoxshpInplp1 -> layer "/"))
																if(ShapeLyr1 == layerlpS1 then
																	pcre_GND1 = pcreCompile("GND")
																	when(pcreExecute(pcre_GND1 ShapeNetName1)
																		AirGapVal1 = (axlAirGap BoxshpInplp1 viadatalp nil 'anyLayer)
																		when(AirGapVal1
																			MechData1 = sprintf(nil "%s,%s,%.2f", GV_UserInputC2lp, ShapeLyr1, AirGapVal1)
																			MechData2 = sprintf(nil "%s,%s", GV_UserInputC2lp, ShapeLyr1)
																			when(MechData2 push(MechData2 MainOutList1))
																			when(MechData1 push(MechData1 MainOutList))
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
							)
						)
			)
		)
	)
)

MainDutList = unique(MainDutList)
MainOutList = unique(MainOutList)
MainDutList1 = unique(MainDutList1)
MainOutList1 = unique(MainOutList1)

axlVisibleDesign(t)
axlShell("redisplay")
CoupDutList = nil
CoupDutList1 = nil
CoupOutList = nil
CoupOutList1 = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
C_viadata = axlGetSelSet(axlAddSelectAll()) 
axlVisibleSet(originalVisible)
axlShell("redisplay")
foreach(C_viadatalp C_viadata
	C_Via_NetName = C_viadatalp->net->name
	C_MainInpViaX = car(C_viadatalp ->xy)
	C_MainInpViaY = cadr(C_viadatalp ->xy) 
	if(C_Via_NetName != nil then
		foreach(C_GV_UserInputC2lp GV_UserInputC2
			C_Main_Inp_NetName = nth(1 parseString(C_GV_UserInputC2lp ","))
			C_ViaLyrList = nil
			C_ViaLyrListOD = nil
			C_ViaLyrList1 = nil
			C_ViaLyrList1OD = nil
			if(C_Main_Inp_NetName == C_Via_NetName then
				C_BoxTopX = C_MainInpViaX - Inp_Distance 
				C_BoxTopY = C_MainInpViaY + Inp_Distance
				C_BoxBotX = C_MainInpViaX + Inp_Distance
				C_BoxBotY = C_MainInpViaY - Inp_Distance

				C_BoxTopXO = C_MainInpViaX - Inp_DistanceOut 
				C_BoxTopYO = C_MainInpViaY + Inp_DistanceOut
				C_BoxBotXO = C_MainInpViaX + Inp_DistanceOut
				C_BoxBotYO = C_MainInpViaY - Inp_DistanceOut
				
				axlVisibleDesign(nil)
				axlVisibleLayer(strcat("CONSTRAINT REGION/", "ALL") t)
				axlVisibleUpdate(t)
				C_PassVal = "NO WE CANT"
				axlClearSelSet()
				axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
				C_Shpdata = axlGetSelSet(axlAddSelectAll())
				
				prog(()
					foreach(C_Shpdatalp C_Shpdata
						C_ShpLyr = C_Shpdatalp ->layer
						if(C_ShpLyr == "CONSTRAINT REGION/ALL" then
							C_AirGapSV = (axlAirGap C_Shpdatalp C_viadatalp nil 'anyLayer)
							if(C_AirGapSV == 0.0 then
								C_PassVal = "YES WE CAN GO"
								return()
							)
						)
					)
				)
						
						if(C_PassVal == "YES WE CAN GO" then
							C_ConLyr = axlDBGetConnect(C_viadatalp t)
							foreach(C_ConLyrlp C_ConLyr
								if(C_ConLyrlp->objType == "path" then
									C_ClineLyrData = C_ConLyrlp->layer
									when(C_ClineLyrData push(C_ClineLyrData C_ViaLyrList))
								)
							)
							if(length(C_ViaLyrList) == 1 then
								foreach(C_ConLyrPlp C_ConLyr  
									if(C_ConLyrPlp->objType == "pin" then
										C_PinLyrData = car(C_ConLyrPlp->startEnd)
										when(C_PinLyrData push(C_PinLyrData C_ViaLyrList))
									)
								)
							)
							
							if(length(C_ViaLyrList) == 0 then
								C_ViaLyrList = '("BOTTOM" "TOP")
							)
							foreach(l_layerslpod l_layers
								foreach(C_ViaLyrListlp C_ViaLyrList
									C_ViaLyrListFilt = nth(1 parseString(C_ViaLyrListlp "/"))
									if(C_ViaLyrListFilt == l_layerslpod then
										when(C_ViaLyrListlp push(C_ViaLyrListlp C_ViaLyrListOD))
									)
								)
							)
							C_ViaLyrListOD = reverse(C_ViaLyrListOD)
							if(length(C_ViaLyrListOD) == 2 then
								C_FirstVal = nth(1 parseString(car(C_ViaLyrListOD) "/"))
								C_SecondVal = nth(1 parseString(cadr(C_ViaLyrListOD) "/"))
								C_DummyVal = 0
								foreach(C_layerlp l_layers
									if(C_layerlp == C_FirstVal then
										prog(()
											foreach(C_layerlpS l_layers
												if(C_layerlpS == C_FirstVal then
													C_DummyVal = 1
												)
												if(C_layerlpS == C_SecondVal then
													axlVisibleDesign(nil)
													axlVisibleLayer(strcat("ETCH/", C_layerlpS) t)
													axlVisibleUpdate(t)
													axlClearSelSet()
													axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
													C_BoxshpInp = axlGetSelSet(axlSingleSelectBox( list(C_BoxTopX:C_BoxTopY C_BoxBotX:C_BoxBotY)))
													if(C_BoxshpInp != nil
														foreach(C_BoxshpInplp C_BoxshpInp
															C_ShapeNetName = C_BoxshpInplp->net->name
															C_ShapeLyr = nth(1 parseString(C_BoxshpInplp -> layer "/"))
															if(C_ShapeLyr == C_layerlpS then
																C_pcre_GND = pcreCompile("GND")
																when(pcreExecute(C_pcre_GND C_ShapeNetName)
																	C_AirGapVal = (axlAirGap C_BoxshpInplp C_viadatalp nil 'anyLayer)
																	when(C_AirGapVal
																		C_MechData = sprintf(nil "%s,%s,%.2f", C_GV_UserInputC2lp, C_ShapeLyr, C_AirGapVal)
																		C_MechData1 = sprintf(nil "%s,%s", C_GV_UserInputC2lp, C_ShapeLyr)
																		when(C_MechData1 push(C_MechData1 CoupDutList1))
																		when(C_MechData push(C_MechData CoupDutList))
																	)
																)
															)												
														)
													)
													return()
												else
													if(C_DummyVal == 1 then
														axlVisibleDesign(nil)
														axlVisibleLayer(strcat("ETCH/", C_layerlpS) t)
														axlVisibleUpdate(t)
														axlClearSelSet()
														axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
														C_BoxshpInp = axlGetSelSet(axlSingleSelectBox( list(C_BoxTopX:C_BoxTopY C_BoxBotX:C_BoxBotY)))
														if(C_BoxshpInp != nil
															foreach(C_BoxshpInplp C_BoxshpInp
																C_ShapeNetName = C_BoxshpInplp->net->name
																C_ShapeLyr = nth(1 parseString(C_BoxshpInplp -> layer "/"))
																if(C_ShapeLyr == C_layerlpS then
																	C_pcre_GND = pcreCompile("GND")
																	when(pcreExecute(C_pcre_GND C_ShapeNetName)
																		C_AirGapVal = (axlAirGap C_BoxshpInplp C_viadatalp nil 'anyLayer)
																		when(C_AirGapVal
																			C_MechData = sprintf(nil "%s,%s,%.2f", C_GV_UserInputC2lp, C_ShapeLyr, C_AirGapVal)
																			C_MechData1 = sprintf(nil "%s,%s", C_GV_UserInputC2lp, C_ShapeLyr)
																			when(C_MechData1 push(C_MechData1 CoupDutList1))
																			when(C_MechData push(C_MechData CoupDutList))
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
							)
						
						
						else
							C_ConLyr1 = axlDBGetConnect(C_viadatalp t)
							foreach(C_ConLyrlp1 C_ConLyr1
								if(C_ConLyrlp1->objType == "path" then
									C_ClineLyrData1 = C_ConLyrlp1->layer
									when(C_ClineLyrData1 push(C_ClineLyrData1 C_ViaLyrList1))
								)
							)
							if(length(C_ViaLyrList1) == 1 then
								foreach(C_ConLyrPlp1 C_ConLyr1  
									if(C_ConLyrPlp1->objType == "pin" then
										C_PinLyrData1 = car(C_ConLyrPlp1->startEnd)
										when(C_PinLyrData1 push(C_PinLyrData1 C_ViaLyrList1))
									)
								)
							)
							
							if(length(C_ViaLyrList1) == 0 then
								C_ViaLyrList1 = '("BOTTOM" "TOP")
							)
							foreach(l_layerslpod1 l_layers
								foreach(C_ViaLyrListlp1 C_ViaLyrList1
									C_ViaLyrListFilt1 = nth(1 parseString(C_ViaLyrListlp1 "/"))
									if(C_ViaLyrListFilt1 == l_layerslpod1 then
										when(C_ViaLyrListlp1 push(C_ViaLyrListlp1 C_ViaLyrList1OD))
									)
								)
							)
							C_ViaLyrList1OD = reverse(C_ViaLyrList1OD)
							if(length(C_ViaLyrList1OD) == 2 then
								C_FirstVal1 = nth(1 parseString(car(C_ViaLyrList1OD) "/"))
								C_SecondVal1 = nth(1 parseString(cadr(C_ViaLyrList1OD) "/"))
								C_DummyVal1 = 0
								foreach(C_layerlp1 l_layers
									if(C_layerlp1 == C_FirstVal1 then
										prog(()
											foreach(C_layerlpS1 l_layers
												if(C_layerlpS1 == C_FirstVal1 then
													C_DummyVal1 = 1
												)
												if(C_layerlpS1 == C_SecondVal1 then
													axlVisibleDesign(nil)
													axlVisibleLayer(strcat("ETCH/", C_layerlpS1) t)
													axlVisibleUpdate(t)
													axlClearSelSet()
													axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
													C_BoxshpInp1 = axlGetSelSet(axlSingleSelectBox( list(C_BoxTopXO:C_BoxTopYO C_BoxBotXO:C_BoxBotYO)))
													if(C_BoxshpInp1 != nil
														foreach(C_BoxshpInplp1 C_BoxshpInp1
															C_ShapeNetName1 = C_BoxshpInplp1->net->name
															C_ShapeLyr1 = nth(1 parseString(C_BoxshpInplp1 -> layer "/"))
															if(C_ShapeLyr1 == C_layerlpS1 then
																C_pcre_GND1 = pcreCompile("GND")
																when(pcreExecute(C_pcre_GND1 C_ShapeNetName1)
																	C_AirGapVal1 = (axlAirGap C_BoxshpInplp1 C_viadatalp nil 'anyLayer)
																	when(C_AirGapVal1
																		C_MechData1 = sprintf(nil "%s,%s,%.2f", C_GV_UserInputC2lp, C_ShapeLyr1, C_AirGapVal1)
																		C_MechData2 = sprintf(nil "%s,%s", C_GV_UserInputC2lp, C_ShapeLyr1)
																		when(C_MechData2 push(C_MechData2 CoupOutList1))
																		when(C_MechData1 push(C_MechData1 CoupOutList))
																	)
																)
															)												
														)
													)
													return()
												else
													if(C_DummyVal1 == 1 then
														axlVisibleDesign(nil)
														axlVisibleLayer(strcat("ETCH/", C_layerlpS1) t)
														axlVisibleUpdate(t)
														axlClearSelSet()
														axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
														C_BoxshpInp1 = axlGetSelSet(axlSingleSelectBox( list(C_BoxTopXO:C_BoxTopYO C_BoxBotXO:C_BoxBotYO)))
														if(C_BoxshpInp1 != nil
															foreach(C_BoxshpInplp1 C_BoxshpInp1
																C_ShapeNetName1 = C_BoxshpInplp1->net->name
																C_ShapeLyr1 = nth(1 parseString(C_BoxshpInplp1 -> layer "/"))
																if(C_ShapeLyr1 == C_layerlpS1 then
																	C_pcre_GND1 = pcreCompile("GND")
																	when(pcreExecute(C_pcre_GND1 C_ShapeNetName1)
																		C_AirGapVal1 = (axlAirGap C_BoxshpInplp1 C_viadatalp nil 'anyLayer)
																		when(C_AirGapVal1
																			C_MechData1 = sprintf(nil "%s,%s,%.2f", C_GV_UserInputC2lp, C_ShapeLyr1, C_AirGapVal1)
																			C_MechData2 = sprintf(nil "%s,%s", C_GV_UserInputC2lp, C_ShapeLyr1)
																			when(C_MechData2 push(C_MechData2 CoupOutList1))
																			when(C_MechData1 push(C_MechData1 CoupOutList))
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
							)
						)
			)
		)
	)
)

CoupDutList = unique(CoupDutList)
CoupOutList = unique(CoupOutList)
CoupDutList1 = unique(CoupDutList1)
CoupOutList1 = unique(CoupOutList1)


MainDutNFList = nil
MainDutNFList = setof(item3, MainDutList1, !member(item3, CoupDutList1))

NonMemListMain = nil
foreach(MainDutNFListlp MainDutNFList
	MainDutNFMNetname = nth(0 parseString(MainDutNFListlp ",")) 
	MainDutNFCNetname = nth(1 parseString(MainDutNFListlp ","))
	MainDutNFLyr = nth(2 parseString(MainDutNFListlp ","))
	foreach(MainDutListSlp MainDutList
		MainDutMNetname = nth(0 parseString(MainDutListSlp ",")) 
		MainDutCNetname = nth(1 parseString(MainDutListSlp ","))
		MainDutLyr = nth(2 parseString(MainDutListSlp ","))
		if(MainDutNFMNetname == MainDutMNetname && MainDutNFCNetname == MainDutCNetname && MainDutNFLyr == MainDutLyr then
			when(MainDutListSlp push(MainDutListSlp NonMemListMain))
		)
	)
)
NonMemListMain = unique(NonMemListMain)

CoupDutNFList = nil
CoupDutNFList = setof(item4, CoupDutList1, !member(item4, MainDutList1))

NonMemListCoup = nil
foreach(CoupDutNFListlp CoupDutNFList
	CoupDutNFMNetname = nth(0 parseString(CoupDutNFListlp ",")) 
	CoupDutNFCNetname = nth(1 parseString(CoupDutNFListlp ","))
	CoupDutNFLyr = nth(2 parseString(CoupDutNFListlp ","))
	foreach(CoupDutListSlp CoupDutList
		CoupDutMNetname = nth(0 parseString(CoupDutListSlp ",")) 
		CoupDutCNetname = nth(1 parseString(CoupDutListSlp ","))
		CoupDutLyr = nth(2 parseString(CoupDutListSlp ","))
		if(CoupDutNFMNetname == CoupDutMNetname && CoupDutNFCNetname == CoupDutCNetname && CoupDutNFLyr == CoupDutLyr then
			when(CoupDutListSlp push(CoupDutListSlp NonMemListCoup))
		)
	)
)
NonMemListCoup = unique(NonMemListCoup)

MemDutList = nil
foreach(MainDutListlp MainDutList
	MemDutMainNetName = nth(0 parseString(MainDutListlp ",")) 
	MemDutCoupNetName = nth(1 parseString(MainDutListlp ","))
	MemDutMainLyr = nth(2 parseString(MainDutListlp ","))
	MemDutMainAG = nth(3 parseString(MainDutListlp ","))
	foreach(CoupDutListlp CoupDutList
		MemDutCMainNetName = nth(0 parseString(CoupDutListlp ",")) 
		MemDutCCoupNetName = nth(1 parseString(CoupDutListlp ","))
		MemDutCoupLyr = nth(2 parseString(CoupDutListlp ","))
		MemDutCoupAG = nth(3 parseString(CoupDutListlp ","))
		if(MemDutMainNetName == MemDutCMainNetName && MemDutCoupNetName == MemDutCCoupNetName && MemDutMainLyr == MemDutCoupLyr && MemDutMainAG != MemDutCoupAG then
			val1 = atof(MemDutMainAG)
			val2 = atof(MemDutCoupAG)
			val = val1 - val2
			valstr = sprintf(nil "%.2f", val) 
			valPrse = nth(0 parseString(valstr "-"))		
			valPrseF = atof(valPrse)
			if(valPrseF > 0.01 then
				MissMatchData = sprintf(nil "%s,%s,%s,%s,%s,%.2f", MemDutMainNetName, MemDutCoupNetName, MemDutMainLyr, MemDutMainAG, MemDutCoupAG, valPrseF) 
				when(MissMatchData push(MissMatchData MemDutList))
			)
		)
	)

)
MemDutList = unique(MemDutList)




MainOutNFList = nil
MainOutNFList = setof(item5, MainOutList1, !member(item5, CoupOutList1))

NonMemListMainOut = nil
foreach(MainOutNFListlp MainOutNFList
	MainOutNFMNetname = nth(0 parseString(MainOutNFListlp ",")) 
	MainOutNFCNetname = nth(1 parseString(MainOutNFListlp ","))
	MainOutNFLyr = nth(2 parseString(MainOutNFListlp ","))
	foreach(MainOutListSlp MainOutList
		MainOutMNetname = nth(0 parseString(MainOutListSlp ",")) 
		MainOutCNetname = nth(1 parseString(MainOutListSlp ","))
		MainOutLyr = nth(2 parseString(MainOutListSlp ","))
		if(MainOutNFMNetname == MainOutMNetname && MainOutNFCNetname == MainOutCNetname && MainOutNFLyr == MainOutLyr then
			when(MainOutListSlp push(MainOutListSlp NonMemListMainOut))
		)
	)
)
NonMemListMainOut = unique(NonMemListMainOut)

CoupOutNFList = nil
CoupOutNFList = setof(item6, CoupOutList1, !member(item6, MainOutList1))

NonMemListCoupOut = nil
foreach(CoupOutNFListlp CoupOutNFList
	CoupOutNFMNetname = nth(0 parseString(CoupOutNFListlp ",")) 
	CoupOutNFCNetname = nth(1 parseString(CoupOutNFListlp ","))
	CoupOutNFLyr = nth(2 parseString(CoupOutNFListlp ","))
	foreach(CoupOutListSlp CoupOutList
		CoupOutMNetname = nth(0 parseString(CoupOutListSlp ",")) 
		CoupOutCNetname = nth(1 parseString(CoupOutListSlp ","))
		CoupOutLyr = nth(2 parseString(CoupOutListSlp ","))
		if(CoupOutNFMNetname == CoupOutMNetname && CoupOutNFCNetname == CoupOutCNetname && CoupOutNFLyr == CoupOutLyr then
			when(CoupOutListSlp push(CoupOutListSlp NonMemListCoupOut))
		)
	)
)
NonMemListCoupOut = unique(NonMemListCoupOut)


MemOutList = nil
foreach(MainOutListlp MainOutList
	MemOutMainNetName = nth(0 parseString(MainOutListlp ",")) 
	MemOutCoupNetName = nth(1 parseString(MainOutListlp ","))
	MemOutMainLyr = nth(2 parseString(MainOutListlp ","))
	MemOutMainAG = nth(3 parseString(MainOutListlp ","))
	foreach(CoupOutListlp CoupOutList
		MemOutCMainNetName = nth(0 parseString(CoupOutListlp ",")) 
		MemOutCCoupNetName = nth(1 parseString(CoupOutListlp ","))
		MemOutCoupLyr = nth(2 parseString(CoupOutListlp ","))
		MemOutCoupAG = nth(3 parseString(CoupOutListlp ","))
		if(MemOutMainNetName == MemOutCMainNetName && MemOutCoupNetName == MemOutCCoupNetName && MemOutMainLyr == MemOutCoupLyr && MemOutMainAG != MemOutCoupAG then
			Sval1 = atof(MemOutMainAG)
			Sval2 = atof(MemOutCoupAG)
			Sval = Sval1 - Sval2
			Svalstr = sprintf(nil "%.2f", Sval) 
			SvalPrse = nth(0 parseString(Svalstr "-"))		
			SvalPrseF = atof(SvalPrse)
			if(SvalPrseF > 0.01 then
				SMissMatchData = sprintf(nil "%s,%s,%s,%s,%s,%.2f", MemOutMainNetName, MemOutCoupNetName, MemOutMainLyr, MemOutMainAG, MemOutCoupAG, SvalPrseF) 
				when(SMissMatchData push(SMissMatchData MemOutList))
			)
		)
	)

)
MemOutList = unique(MemOutList)

DutRegionError = nil
DutRegionError = append(NonMemListMain NonMemListCoup)
DutRegionErrorF = nil
DutRegionErrorF = append(DutRegionError MemDutList)

OutRegionError = nil
OutRegionError = append(NonMemListMainOut NonMemListCoupOut)
OutRegionErrorF = nil
OutRegionErrorF = append(OutRegionError MemOutList)

FinalMissMatchList = nil
FinalMissMatchList = append(DutRegionErrorF OutRegionErrorF)

axlVisibleSet(originalVisible)
axlShell("redisplay")

FinalMissMatchList = unique(FinalMissMatchList)
if(FinalMissMatchList != nil then
	logfile = "CouponGNDNearVia.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
		if(DutRegionErrorF != nil then
			fprintf(port, "%s\n\n", "DUT REGION ERROR LIST :")
			if(MemDutList != nil then
				fprintf(port, "%s\n\n", "DUT REGION GND CLEARANCE MISSMATCH ERROR LIST :")
				fprintf(port, "%-25s %-25s %-25s %-25s %-25s  %-25s \n\n", "NET NAME MAIN", "NET NAME COUP", "LAYER", "MAIN AIRGAP", "COUP AIRGAP", "DIFFERENCE")
				foreach(MissMatchListlp MemDutList
					FinalListS_filt = parseString(MissMatchListlp ",")
					fprintf(port, "%-25s %-25s %-25s %-25s %-25s  %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt), nth(4 FinalListS_filt), nth(5 FinalListS_filt))
				)
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			else
				fprintf(port, "%s\n", "DUT REGION : NO MISS MATCH IN AIRGAP")
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			)
			
			if(NonMemListMain != nil then
				fprintf(port, "%s\n\n", "DUT REGION GND PLAIN MISSING IN COUPON :")
				fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUP", "LAYER", "COUP AIRGAP")
				foreach(MissMatchListlp NonMemListMain
					FinalListS_filt = parseString(MissMatchListlp ",")
					fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt))
				)
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			else
				fprintf(port, "%s\n", "DUT REGION : EVERY VALUE FOUND IN COUPON BOARD")
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			)
			
			if(NonMemListCoup != nil then
				fprintf(port, "%s\n\n", "DUT REGION GND PLAIN MISSING IN MAIN  :")
				fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUP", "LAYER", "MAIN AIRGAP")
				foreach(MissMatchListlp NonMemListCoup
					FinalListS_filt = parseString(MissMatchListlp ",")
					fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt))
				)
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			else
				fprintf(port, "%s\n", "DUT REGION : EVERY VALUE FOUND IN MAIN BOARD")
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			)
		else
			fprintf(port, "%s\n", "DUT REGION : NO ERROR")
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
				
		)
		
		
		
		
		if(OutRegionErrorF != nil then
			fprintf(port, "%s\n\n", "OUTSIDE DUT ERROR LIST :")
			if(MemOutList != nil then
				fprintf(port, "%s\n\n", "OUTSIDE DUT GND CLEARANCE MISSMATCH ERROR LIST :")
				fprintf(port, "%-25s %-25s %-25s %-25s %-25s  %-25s \n\n", "NET NAME MAIN", "NET NAME COUP", "LAYER", "MAIN AIRGAP", "COUP AIRGAP", "DIFFERENCE")
				foreach(MissMatchListlp MemOutList
					FinalListS_filt = parseString(MissMatchListlp ",")
					fprintf(port, "%-25s %-25s %-25s %-25s %-25s  %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt), nth(4 FinalListS_filt), nth(5 FinalListS_filt))
				)
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			else
				fprintf(port, "%s\n", "OUTSIDE DUT : NO MISS MATCHING AIRGAP")
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			)
			
			if(NonMemListMainOut != nil then
				fprintf(port, "%s\n\n", "OUTSIDE GND PLAIN MISSING IN COUPON :")
				fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUP", "LAYER", "COUP AIRGAP")
				foreach(MissMatchListlp NonMemListMainOut
					FinalListS_filt = parseString(MissMatchListlp ",")
					fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt))
				)
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			else
				fprintf(port, "%s\n", "OUTSIDE DUT : EVERY VALUE FOUND IN COUPON BOARD")
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			)
			
			if(NonMemListCoupOut != nil then
				fprintf(port, "%s\n\n", "OUTSIDE DUT GND PLAIN MISSING IN MAIN :")
				fprintf(port, "%-25s %-25s %-25s %-25s \n\n", "NET NAME MAIN", "NET NAME COUP", "LAYER", "MAIN AIRGAP")
				foreach(MissMatchListlp NonMemListCoupOut
					FinalListS_filt = parseString(MissMatchListlp ",")
					fprintf(port, "%-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt))
				)
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			else
				fprintf(port, "%s\n", "OUTSIDE DUT : EVERY VALUE FOUND IN MAIN BOARD")
				fprintf(port, "\n\n")
				fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
			)
		else
			fprintf(port, "%s\n", "OUTSIDE DUT : NO ERROR")
			fprintf(port, "\n\n")
			fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
				
		)
		
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Coupon GND Near Via Airgap", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Error Found...!")

)

)