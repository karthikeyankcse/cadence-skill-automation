axlCmdRegister("ViaDelAndRplc" 'ViaDelAndRplc)
(setq ViaDel_form_file "ViaDelAndRplc.form") 
procedure(ViaDelAndRplc()
	CreateViaDel_form()
	RunViaDel_form()
)


procedure(RunViaDel_form() 
	let((ViaDel_form)
		(ViaDel_form = axlFormCreate(gensym() ViaDel_form_file nil 'ViaDel_Action t))
		axlFormDisplay(ViaDel_form)
	)
)

procedure(CreateViaDel_form()
	let((ViaDel_form)
		(ViaDel_form = outfile(ViaDel_form_file "w")) 
		fprintf(ViaDel_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(ViaDel_form "FORM\n") 
		fprintf(ViaDel_form "FIXED\n") 
		fprintf(ViaDel_form "PORT 50 50\n") 
		fprintf(ViaDel_form "HEADER \"Via Delete And Update\"\n") 
		fprintf(ViaDel_form "\n")
		fprintf(ViaDel_form "TILE\n")
		
		fprintf(ViaDel_form "FIELD VDEL\n") 
		fprintf(ViaDel_form "FLOC 6 3\n") 
		fprintf(ViaDel_form "MENUBUTTON \"VIA DELETE ALONE..\" 20 4\n") 
		fprintf(ViaDel_form "ENDFIELD\n")
		fprintf(ViaDel_form "\n")
		
		fprintf(ViaDel_form "FIELD VDELUP\n") 
		fprintf(ViaDel_form "FLOC 5 10\n") 
		fprintf(ViaDel_form "MENUBUTTON \"VIA DELETE AND UPDATE..\" 20 4\n") 
		fprintf(ViaDel_form "ENDFIELD\n")
		fprintf(ViaDel_form "\n")
		


		fprintf(ViaDel_form "\n") 
		fprintf(ViaDel_form "\n") 
		fprintf(ViaDel_form "ENDTILE\n")
		
		fprintf(ViaDel_form "\n") 
		fprintf(ViaDel_form "ENDFORM\n")
		
		drain() 
		close(ViaDel_form)
	)
)

procedure(ViaDel_Action(ViaDel_form) 
	case((ViaDel_form->curField)
		("VDEL"
			a = 0
			println("Delete Alone Option is Choosed..!")
			axlUIConfirm( "Please Select One Sample Via to Delete...!")
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
			ViaINP = axlGetSelSet(axlSelect( ))
			ViaINPDt = car(ViaINP)
			if(ViaINPDt then
				ViaInpName = ViaINPDt->name
				ViaInpDrill = ViaINPDt->definition->drillDiameter
				InpVal = sprintf(nil "Choosed Via Name - %s Choosed Via Drill - %.2f", ViaInpName, ViaInpDrill) 
				println(InpVal)
				originalVisible=axlVisibleGet()
				axlVisibleDesign(t)
				axlClearSelSet()
				axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
				DelVia = axlGetSelSet(axlAddSelectAll())
				if(DelVia then
					foreach(DelVialp DelVia
						DelViaName = DelVialp->name
						DelViaDrill = DelVialp->definition->drillDiameter
						if(DelViaName == ViaInpName && ViaInpDrill == DelViaDrill then
							axlDeleteObject(DelVialp)
							axlDBRefreshId(nil)
							a = a + 1
						)
					)
				)
				
				axlVisibleSet(originalVisible)
				axlUIConfirm( "Via Deleted Successfully...!")
			)
			val1 = sprintf(nil "Total Number of Via Deleted - %d", a)
			println(val1)
			axlFormClose(ViaDel_form)
		)
		
		("VDELUP"
			b = 0
			println("Delete And Update Option is Choosed..!")
			axlUIConfirm( "Please Select One Sample Via to Delete...!")
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
			DU_ViaINP = axlGetSelSet(axlSelect( ))
			DU_ViaINPDt = car(DU_ViaINP)
			
			axlUIConfirm( "Please Select One Sample Via to Update...!")
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
			DU_ViaUP = axlGetSelSet(axlSelect( ))
			DU_ViaUPDt = car(DU_ViaUP)
			
			if(DU_ViaINPDt then
				if(DU_ViaUPDt then
					DU_ViaInpName = DU_ViaINPDt->name
					DU_ViaInpDrill = DU_ViaINPDt->definition->drillDiameter
					DU_ViaUPName = DU_ViaUPDt->name
					DU_ViaUPDrill = DU_ViaUPDt->definition->drillDiameter
					InpVal1 = sprintf(nil "Choosed Via Name - %s Choosed Via Drill - %.2f", DU_ViaInpName, DU_ViaInpDrill) 
					println(InpVal1)
					InpVal2 = sprintf(nil "Choosed Via Name to Update - %s Choosed Via Drill to Update - %.2f", DU_ViaUPName, DU_ViaUPDrill) 
					println(InpVal2)
					originalVisible=axlVisibleGet()
					axlVisibleDesign(t)
					axlClearSelSet()
					axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
					DelAndUpVia = axlGetSelSet(axlAddSelectAll())
					if(DelAndUpVia then
						foreach(DelAndUpVialp DelAndUpVia
							DelAndUpViaName = DelAndUpVialp->name
							DelAndUpViaDrill = DelAndUpVialp->definition->drillDiameter
							DelAndUpNetName = DelAndUpVialp->net->name
							DelAndUpX = car(DelAndUpVialp->xy)
							DelAndUpY = cadr(DelAndUpVialp->xy)
							if(DelAndUpViaName == DU_ViaInpName && DU_ViaInpDrill == DelAndUpViaDrill then
								axlDeleteObject(DelAndUpVialp)
								axlDBRefreshId(nil)
								myvia = axlDBCreateVia(DU_ViaUPName, DelAndUpX:DelAndUpY, DelAndUpNetName, nil, 0.0, nil)
								b = b + 1
							)
						)
					)
					axlVisibleSet(originalVisible)
					axlUIConfirm( "Via Updated Successfully...!")
				)
			)
			val2 = sprintf(nil "Total Number of Via Updated - %d", b)
			println(val2)
		axlFormClose(ViaDel_form)	
		)
		
	)
	axlFormDisplay(ViaDel_form)
)
