axlCmdRegister("XsectionMod" 'XsectionMod)
(setq Thick_form_file "XSec.form") 
procedure(XsectionMod()
	CreateThick_form()
	RunThick_form()
)

procedure(RunThick_form() 
	let((Thick_form)
		(Thick_form = axlFormCreate(gensym() Thick_form_file nil 'Thick_Action t))
		axlFormDisplay(Thick_form)
	)
)

procedure(CreateThick_form()
	let((Thick_form)
		(Thick_form = outfile(Thick_form_file "w")) 
		fprintf(Thick_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(Thick_form "FORM\n") 
		fprintf(Thick_form "FIXED\n") 
		fprintf(Thick_form "PORT 50 50\n") 
		fprintf(Thick_form "HEADER \"Cross Section\"\n") 
		fprintf(Thick_form "\n")
		fprintf(Thick_form "TILE\n")
		
		fprintf(Thick_form "FIELD THICK\n") 
		fprintf(Thick_form "FLOC 2 1\n") 
		fprintf(Thick_form "MENUBUTTON \"THICKNESS\" 20 6\n") 
		fprintf(Thick_form "ENDFIELD\n")
		fprintf(Thick_form "\n")
		
		fprintf(Thick_form "FIELD THMAT\n") 
		fprintf(Thick_form "FLOC 28 1\n") 
		fprintf(Thick_form "MENUBUTTON \"THICK AND MAT\" 20 6\n") 
		fprintf(Thick_form "ENDFIELD\n")
		fprintf(Thick_form "\n")
		
		
		fprintf(Thick_form "TEXT \">>> X Section \"\n")
		fprintf(Thick_form "TLOC 17 7\n")
		fprintf(Thick_form "ENDTEXT\n")
		


		fprintf(Thick_form "\n") 
		fprintf(Thick_form "\n") 
		fprintf(Thick_form "ENDTILE\n")
		
		fprintf(Thick_form "\n") 
		fprintf(Thick_form "ENDFORM\n")
		
		drain() 
		close(Thick_form)
	)
)

procedure(Thick_Action(Thick_form) 
	case((Thick_form->curField)
		
		("THICK"
			Thick_Inp = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
			fileparts = axlDMFileParts(Thick_Inp)
			Thick_Inp_Pass = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts) "r")
			Thick_List = nil
			if(Thick_Inp_Pass != nil then
				while(gets(Thick_Inp_loop Thick_Inp_Pass)
				Thick_Inp_loop_prse = car(parseString(Thick_Inp_loop "\n"))
				when(Thick_Inp_loop_prse push(Thick_Inp_loop_prse Thick_List))
				)
			axlDMClose(Thick_Inp_Pass)
			)
			Rev_Thick_List = reverse(Thick_List)
			XSecVal= axlGetXSection()
			XSecVec = listToVector(XSecVal)
			IncVal = 1
			foreach(Thick_List_lpp Rev_Thick_List
				XSecVec[IncVal] = list(nth(0 XSecVec[IncVal]) nth(1 XSecVec[IncVal]) nth(2 XSecVec[IncVal]) Thick_List_lpp nth(4 XSecVec[IncVal]) nth(5 XSecVec[IncVal]) nth(6 XSecVec[IncVal]) nth(7 XSecVec[IncVal]) nth(8 XSecVec[IncVal]) nth(9 XSecVec[IncVal]) nth(10 XSecVec[IncVal]) nth(11 XSecVec[IncVal]) nth(12 XSecVec[IncVal]) nth(13 XSecVec[IncVal]) nth(14 XSecVec[IncVal]))
				UpXSecVal = vectorToList(XSecVec)
				_fpBioImportXSection(UpXSecVal)
				IncVal = IncVal + 1
			)
		axlUIConfirm( "Done..." )
		axlFormClose(Thick_form)	
		shell("rm -f Thick_form.form")
		nil

		)
		
		("THMAT"
			Thick_Inp = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
			fileparts = axlDMFileParts(Thick_Inp)
			Thick_Inp_Pass = axlDMOpenFile("ALLEGRO_TEXT" cadr(fileparts) "r")
			Thick_List = nil
			if(Thick_Inp_Pass != nil then
				while(gets(Thick_Inp_loop Thick_Inp_Pass)
				Thick_Inp_loop_prse = car(parseString(Thick_Inp_loop "\n"))
				when(Thick_Inp_loop_prse push(Thick_Inp_loop_prse Thick_List))
				)
			axlDMClose(Thick_Inp_Pass)
			)
			Rev_Thick_List = reverse(Thick_List)
			XSecVal= axlGetXSection()
			XSecVec = listToVector(XSecVal)
			IncVal = 1
			foreach(Thick_List_lp Rev_Thick_List
				InpMat = nth(0 parseString(Thick_List_lp ","))
				InpThick = nth(1 parseString(Thick_List_lp ",")) 
				XSecVec[IncVal] = list(nth(0 XSecVec[IncVal]) nth(1 XSecVec[IncVal]) InpMat InpThick nth(4 XSecVec[IncVal]) nth(5 XSecVec[IncVal]) nth(6 XSecVec[IncVal]) nth(7 XSecVec[IncVal]) nth(8 XSecVec[IncVal]) nth(9 XSecVec[IncVal]) nth(10 XSecVec[IncVal]) nth(11 XSecVec[IncVal]) nth(12 XSecVec[IncVal]) nth(13 XSecVec[IncVal]) nth(14 XSecVec[IncVal]))
				UpXSecVal = vectorToList(XSecVec)
				_fpBioImportXSection(UpXSecVal)
				IncVal = IncVal + 1
			)
		axlUIConfirm( "Done..." )
		axlFormClose(Thick_form)	
		shell("rm -f Thick_form.form")
		nil
			
		)
	)
	axlFormDisplay(Thick_form)
)
