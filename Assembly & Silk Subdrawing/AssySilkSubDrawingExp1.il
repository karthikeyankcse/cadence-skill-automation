axlCmdRegister("AssySilkSubDrawingExp1" 'AssySilkSubDrawingExp1)
(setq AS_form_file "AssySilkSubDrawingExp1.form") 
procedure(AssySilkSubDrawingExp1()
	axlDBTextBlockCompact(t)
	CreateAS_form()
	RunAS_form()
)

procedure(RunAS_form() 
	let((AS_form)
		(AS_form = axlFormCreate(gensym() AS_form_file nil 'AS_Action t)) 
		axlFormDisplay(AS_form)
	)
)

procedure(CreateAS_form()
	let((AS_form)
		(AS_form = outfile(AS_form_file "w")) 
		fprintf(AS_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(AS_form "FORM\n") 
		fprintf(AS_form "FIXED\n") 
		fprintf(AS_form "PORT 45 50\n") 
		fprintf(AS_form "HEADER \"Subdrawing\"\n") 
		fprintf(AS_form "\n")
		fprintf(AS_form "TILE\n")
		
		fprintf(AS_form "FIELD IMP\n") 
		fprintf(AS_form "FLOC 1 2\n") 
		fprintf(AS_form "MENUBUTTON \"IMPORT\" 20 4\n") 
		fprintf(AS_form "ENDFIELD\n")
		fprintf(AS_form "\n")
		
		fprintf(AS_form "FIELD EXP\n") 
		fprintf(AS_form "FLOC 25 2\n") 
		fprintf(AS_form "MENUBUTTON \"EXPORT\" 20 4\n") 
		fprintf(AS_form "ENDFIELD\n")
		fprintf(AS_form "\n")
		
		fprintf(AS_form "TEXT \"SELECT THE LAYER...!\"\n")
		fprintf(AS_form "TLOC 14 7\n")
		fprintf(AS_form "ENDTEXT\n")


        fprintf(AS_form "POPUP <DATA>\"ASSEMBLY\"\"ASSEMBLY\",\"SILKSCREEN\"\"SILKSCREEN\".\n")
		fprintf(AS_form "FIELD DATAFLD\n") 
		fprintf(AS_form "FLOC 13 10\n") 
		fprintf(AS_form "ENUMSET 17\n")
		fprintf(AS_form "POP \"DATA\"\n")
		fprintf(AS_form "ENDFIELD\n")
		fprintf(AS_form "\n")
		
		fprintf(AS_form "POPUP <LYR>\"BOTH\"\"BOTH\",\"TOP\"\"TOP\",\"BOTTOM\"\"BOTTOM\".\n")
		fprintf(AS_form "FIELD LYRFLD\n") 
		fprintf(AS_form "FLOC 13 13\n") 
		fprintf(AS_form "ENUMSET 17\n")
		fprintf(AS_form "POP \"LYR\"\n")
		fprintf(AS_form "ENDFIELD\n")
		fprintf(AS_form "\n")	

		fprintf(AS_form "\n") 
		fprintf(AS_form "\n") 
		fprintf(AS_form "ENDTILE\n")
		
		fprintf(AS_form "\n") 
		fprintf(AS_form "ENDFORM\n")
		
		drain() 
		close(AS_form)
	)
)

procedure(AS_Action(AS_form) 
	case((AS_form->curField)
		("EXP"
			(Lyr_getval = (axlFormGetField AS_form "LYRFLD"))
            (Data_getval = (axlFormGetField AS_form "DATAFLD"))
			if(Lyr_getval != "" && Data_getval != ""  then
				AssList = outfile("./SubDrawingImportList.txt")
				AssTBList = outfile("./SubDrawingTextBlockList.txt")
				CurrentView = axlVisibleGet()
				axlVisibleDesign(nil)
				if(Lyr_getval == "TOP" then
                    TopPass = sprintf(nil "REF DES/%s_TOP", Data_getval)
					axlVisibleLayer(TopPass t ) 
					axlUIWUpdate(nil)
				else
					if(Lyr_getval == "BOTTOM" then
                        BotPass = sprintf(nil "REF DES/%s_BOTTOM", Data_getval)
						axlVisibleLayer(BotPass t ) 
						axlUIWUpdate(nil)
					else
                        TopPass = sprintf(nil "REF DES/%s_TOP", Data_getval)
                        axlVisibleLayer(TopPass t )
						BotPass = sprintf(nil "REF DES/%s_BOTTOM", Data_getval)
						axlVisibleLayer(BotPass t )
						axlUIWUpdate(nil)						
					)
				
				)
				axlClearSelSet()
				axlSetFindFilter(?enabled `("NOALL" "TEXT") ?onButtons `("TEXT"))
				Txtinp = axlGetSelSet(axlAddSelectAll())
				TxtBlkList = nil
				foreach(Txtinplp Txtinp
					TxtPType = Txtinplp->parent->objType
					TxtPClass = car(parseString(Txtinplp->layer "/")) 
					if(TxtPType == "symbol" && TxtPClass == "REF DES" then 
						Txt_Ref = Txtinplp->text 
						Txt_Loc = Txtinplp->xy 
						Txt_Rot = Txtinplp->rotation 
						Txt_Mir = Txtinplp->isMirrored 
						Txt_Lyr = Txtinplp->layer 
						Txt_Blk = Txtinplp->textBlock 
						Txt_Jfy = Txtinplp->justify
						Txt_Param = axlGetParam(strcat("paramTextBlock:" Txtinplp ->textBlock))
						Txt_PhotoWidth = Txt_Param ->photoWidth
						Txt_Height = Txt_Param ->height
						Txt_Width = Txt_Param ->width
						Txt_ChrSpc = Txt_Param ->charSpace
						Txt_LineSpc = Txt_Param ->lineSpace
						TxtBlkDt = sprintf(nil "%s,%f,%f,%f,%f,%f", Txt_Blk, Txt_PhotoWidth, Txt_Height, Txt_Width, Txt_ChrSpc, Txt_LineSpc)
						when(TxtBlkDt push(TxtBlkDt TxtBlkList))						
						println(list(Txt_Ref Txt_Loc Txt_Lyr Txt_Rot Txt_Mir Txt_Blk Txt_Jfy) AssList)
					)
				)
				TxtBlkList = unique(TxtBlkList)
				foreach(TxtBlkListlp TxtBlkList
					fprintf(AssTBList "%s \n", TxtBlkListlp) 
				)
				close(AssTBList)
				close(AssList)
				axlVisibleSet(CurrentView) 
				axlUIWUpdate(nil) 
				axlUIConfirm("SubDrawing ImportList has been Generated Successfully...!")
			else
				axlUIConfirm("Error : Input Not Selected...!")
			)
		)
		
		
		("IMP"
			(Lyr_getval = (axlFormGetField AS_form "LYRFLD"))
            (Data_getval = (axlFormGetField AS_form "DATAFLD"))
			if(Lyr_getval != "" && Data_getval != "" then
				OldTxtBlkList = nil
				Txtparam = axlGetParam("paramTextGroup")
				TxtBlkTot = Txtparam->nChildren
				for(i 1 TxtBlkTot
					passVal = sprintf(nil "%d", i)
					Old_Txt_Param = axlGetParam(strcat("paramTextBlock:" passVal))
					Old_Txt_PhotoWidth = Old_Txt_Param ->photoWidth
					Old_Txt_Height = Old_Txt_Param ->height
					Old_Txt_Width = Old_Txt_Param ->width
					Old_Txt_ChrSpc = Old_Txt_Param ->charSpace
					Old_Txt_LineSpc = Old_Txt_Param ->lineSpace
					Old_TxtBlkDt = sprintf(nil "%s,%f,%f,%f,%f,%f", passVal, Old_Txt_PhotoWidth, Old_Txt_Height, Old_Txt_Width, Old_Txt_ChrSpc, Old_Txt_LineSpc)
					when(Old_TxtBlkDt push(Old_TxtBlkDt OldTxtBlkList))
				) 
				OldTxtBlkList = unique(OldTxtBlkList)
				InAssList = infile("./SubDrawingImportList.txt")
				InAssTBList = infile("./SubDrawingTextBlockList.txt")
				InTxtBlkList = nil
				while(gets(InTxtBlkDt InAssTBList) 
					InTxtBlkDt_Prse = nth(0 parseString(InTxtBlkDt " \n"))
					when(InTxtBlkDt_Prse push(InTxtBlkDt_Prse InTxtBlkList))
				)
				CurrentView = axlVisibleGet()
				axlVisibleDesign(nil)
				if(Lyr_getval == "TOP" then
                    TopPass = sprintf(nil "REF DES/%s_TOP", Data_getval)
                    axlVisibleLayer(TopPass t ) 
					axlUIWUpdate(nil)
				else
					if(Lyr_getval == "BOTTOM" then
                        BotPass = sprintf(nil "REF DES/%s_BOTTOM", Data_getval)
                        axlVisibleLayer(BotPass t ) 
						axlUIWUpdate(nil)
					else
                        TopPass = sprintf(nil "REF DES/%s_TOP", Data_getval)
                        axlVisibleLayer(TopPass t )
                        BotPass = sprintf(nil "REF DES/%s_BOTTOM", Data_getval)
                        axlVisibleLayer(BotPass t )
						axlUIWUpdate(nil)						
					)
				
				)
				while(InpListDt = car(lineread(InAssList))
					InpRef = nth(0 InpListDt) 
					InpLoc = nth(1 InpListDt) 
					InpLyr = nth(2 InpListDt) 
					InpRot = nth(3 InpListDt) 
					InpMir = nth(4 InpListDt) 
					InpBlk = nth(5 InpListDt) 
					InpJus = nth(6 InpListDt)
					OldTxtId = FuncFindId(InpRef InpLyr)
					OldLoc = nth(1 OldTxtId)					
					OldRot = nth(0 OldTxtId)->rotation	
					OldMir = nth(0 OldTxtId)->isMirrored	
					OldBlk = nth(0 OldTxtId)->textBlock	
					OldComp = nth(0 OldTxtId)->parent
					OldTxt_Param = axlGetParam(strcat("paramTextBlock:" OldBlk))
					OldTxt_PhotoWidth = OldTxt_Param ->photoWidth
					OldTxt_Height = OldTxt_Param ->height
					OldTxt_Width = OldTxt_Param ->width
					OldTxt_ChrSpc = OldTxt_Param ->charSpace
					OldTxt_LineSpc = OldTxt_Param ->lineSpace
					OldTxtBlkDt = sprintf(nil "%f,%f,%f,%f,%f", OldTxt_PhotoWidth, OldTxt_Height, OldTxt_Width, OldTxt_ChrSpc, OldTxt_LineSpc)
					DummyVal = "False"
					foreach(InTxtBlkListlp InTxtBlkList
						TxtBlkVal = nth(0 parseString(InTxtBlkListlp ","))
						TxtBlkValRest = cdr(parseString(InTxtBlkListlp ","))
						TxtBlkValRestUp = buildString(TxtBlkValRest ",")
						if(InpBlk == TxtBlkVal then 
							if(TxtBlkValRestUp == OldTxtBlkDt then
								DummyVal = "True"
							)
						)
					)
					if(DummyVal == "TrueEE" then
						delta_x = xCoord(InpLoc) - xCoord(OldLoc)	
						delta_y = yCoord(InpLoc) - yCoord(OldLoc)	
						l_delta = list(delta_x delta_y)				
						rot = InpRot - OldRot							
						mir = (InpMir && !OldMir)||(!InpMir && OldMir)	
						axlTransformObject(car(OldTxtId) ?move l_delta ?mirror mir ?angle rot )
					else
						DummyVal1 = "False"
						foreach(OldTxtBlkListlp OldTxtBlkList
							OldTxtBlkVal = nth(0 parseString(OldTxtBlkListlp ","))
							OldTxtBlkValI = atoi(OldTxtBlkVal)
							OldTxtBlkValRest = cdr(parseString(OldTxtBlkListlp ","))
							OldTxtBlkValRestUp = buildString(OldTxtBlkValRest ",")
							foreach(InTxtBlkListlp1 InTxtBlkList
								TxtBlkVal1 = nth(0 parseString(InTxtBlkListlp1 ","))
								TxtBlkValRest1 = cdr(parseString(InTxtBlkListlp1 ","))
								TxtBlkValRestUp1 = buildString(TxtBlkValRest1 ",")
								if(InpBlk == TxtBlkVal1 then 
									if(TxtBlkValRestUp1 == OldTxtBlkValRestUp then
										DummyVal1 = "True"
										new_orient = make_axlTextOrientation(?textBlock OldTxtBlkValI, ?rotation InpRot, ?mirrored InpMir, ?justify InpJus) 
										new_refdes = axlDBCreateText(InpRef, InpLoc, new_orient, InpLyr, OldComp) 
										if(new_refdes then
											OldDbId = nth(0 OldTxtId)
											axlDeleteObject(OldDbId) 
										)
									)
								)
							)
						)
						
						if(DummyVal1 == "False" then
							foreach(InTxtBlkListlp2 InTxtBlkList
								TxtBlkVal2 = nth(0 parseString(InTxtBlkListlp2 ","))
								TxtBlkValRest2 = cdr(parseString(InTxtBlkListlp2 ","))
								TxtBlkValRestUp2 = buildString(TxtBlkValRest2 ",")
								if(InpBlk == TxtBlkVal2 then
									Val = TxtBlkTot + 1
									wid = atof(nth(3 parseString(InTxtBlkListlp2 ",")))
									hgt = atof(nth(2 parseString(InTxtBlkListlp2 ",")))
									ls = atof(nth(5 parseString(InTxtBlkListlp2 ",")))
									cs = atof(nth(4 parseString(InTxtBlkListlp2 ",")))
									pw = atof(nth(1 parseString(InTxtBlkListlp2 ",")))
									UpdatedDt = sprintf(nil "%d,%f,%f,%f,%f,%f", Val, pw, hgt, wid, cs, ls)
									when(UpdatedDt push(UpdatedDt OldTxtBlkList))
									BlkCrct = axlDBTextBlockCreate(Val ?width wid ?height hgt ?lineSpace ls ?charSpace cs ?photoWidth pw)
									if(BlkCrct then
										new_orient1 = make_axlTextOrientation(?textBlock BlkCrct, ?rotation InpRot, ?mirrored InpMir, ?justify InpJus) 
										new_refdes1 = axlDBCreateText(InpRef, InpLoc, new_orient1, InpLyr, OldComp) 
										if(new_refdes1 then
											OldDbId = nth(0 OldTxtId)
											axlDeleteObject(OldDbId)
										)
									else
										axlUIConfirm("Error : Unable to Create New Text Block Please Delete Unused Text Block...!")
									)
								)
							)
						)
					)
				)
				axlVisibleSet(CurrentView) 
				axlUIWUpdate(nil) 
				close(InAssTBList)
				close(InAssList)
				axlUIConfirm("SubDrawing Has been Imported Successfully...!")
			else
                axlUIConfirm("Error : Input Not Selected...!")
			)
		)
	)
	axlFormDisplay(AS_form)
)

procedure(FuncFindId(sym tlayer) 
	prog(list(child l_children o_type o_layer match_loc) 
		l_children = car(axlSelectByName("REFDES" sym))->children 
		foreach(child l_children 
			o_type = child->objType 
			o_layer = child->layer 
			if(o_type == "text" && o_layer == tlayer then  
				match_loc = child->xy 
				axlClearSelSet() 
				return(list(child match_loc))
			)
		)
	)
)