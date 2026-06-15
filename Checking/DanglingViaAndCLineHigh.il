axlCmdRegister("DanglingViaAndCLineHigh" 'DanglingViaAndCLineHigh)
(setq DangHigh_form_file "DanglingViaAndCLineHigh.form") 
procedure(DanglingViaAndCLineHigh()
	CreateDangHigh_form()
	RunDangHigh_form()
)

procedure(RunDangHigh_form() 
	let((DangHigh_form)
		(DangHigh_form = axlFormCreate(gensym() DangHigh_form_file nil 'DangHigh_Action t))
		axlFormDisplay(DangHigh_form)
	)
)

procedure(CreateDangHigh_form()
	let((DangHigh_form)
		(DangHigh_form = outfile(DangHigh_form_file "w")) 
		fprintf(DangHigh_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(DangHigh_form "FORM\n") 
		fprintf(DangHigh_form "FIXED\n") 
		fprintf(DangHigh_form "PORT 50 50\n") 
		fprintf(DangHigh_form "HEADER \"Highlight Dangling Vias And Lines \"\n") 
		fprintf(DangHigh_form "\n")
		fprintf(DangHigh_form "TILE\n")
		
		
		fprintf(DangHigh_form "FIELD HIGHLINE\n") 
		fprintf(DangHigh_form "FLOC 1 1\n") 
		fprintf(DangHigh_form "MENUBUTTON \"HIGHLIGHT DANGLING LINES\" 20 4\n") 
		fprintf(DangHigh_form "ENDFIELD\n")
		fprintf(DangHigh_form "\n")
		
		fprintf(DangHigh_form "FIELD HIGHVIA\n") 
		fprintf(DangHigh_form "FLOC 27 1\n") 
		fprintf(DangHigh_form "MENUBUTTON \"HIGHLIGHT DANGLING VIAS\" 20 4\n") 
		fprintf(DangHigh_form "ENDFIELD\n")
		fprintf(DangHigh_form "\n")
		
		fprintf(DangHigh_form "FIELD DEHIGH\n") 
		fprintf(DangHigh_form "FLOC 16 5\n") 
		fprintf(DangHigh_form "MENUBUTTON \"DEHIGHLIGHT\" 20 4\n") 
		fprintf(DangHigh_form "ENDFIELD\n")
		fprintf(DangHigh_form "\n")
		
		fprintf(DangHigh_form "FIELD DELLINE\n") 
		fprintf(DangHigh_form "FLOC 3 9\n") 
		fprintf(DangHigh_form "MENUBUTTON \"DELETE DANGLING LINES\" 20 4\n") 
		fprintf(DangHigh_form "ENDFIELD\n")
		fprintf(DangHigh_form "\n")
		
		fprintf(DangHigh_form "FIELD DELVIA\n") 
		fprintf(DangHigh_form "FLOC 27 9\n") 
		fprintf(DangHigh_form "MENUBUTTON \"DELETE DANGLING VIAS\" 20 4\n") 
		fprintf(DangHigh_form "ENDFIELD\n")
		fprintf(DangHigh_form "\n")
		
		fprintf(DangHigh_form "FIELD DELALL\n") 
		fprintf(DangHigh_form "FLOC 16 13\n") 
		fprintf(DangHigh_form "MENUBUTTON \"DELETE ALL\" 20 4\n") 
		fprintf(DangHigh_form "ENDFIELD\n")
		fprintf(DangHigh_form "\n")

		fprintf(DangHigh_form "\n") 
		fprintf(DangHigh_form "\n") 
		fprintf(DangHigh_form "ENDTILE\n")
		
		fprintf(DangHigh_form "\n") 
		fprintf(DangHigh_form "ENDFORM\n")
		
		drain() 
		close(DangHigh_form)
	)
)

procedure(DangHigh_Action(DangHigh_form) 
	case((DangHigh_form->curField)
		("HIGHLINE"
			DangData()
			foreach(LineDangListlp LineDangList
				axlHighlightObject(LineDangListlp)
			)
			Val1 = sprintf(nil "Total Number Of Dangling Cline Highlighted - %d", length(LineDangList))
			println(Val1)
			axlUIConfirm(Val1)
		)
		
		("HIGHVIA"
			DangData()
			foreach(ViaDangListlp ViaDangList
				axlHighlightObject(ViaDangListlp)
			)
			Val2 = sprintf(nil "Total Number Of Dangling Via Highlighted - %d", length(ViaDangList))
			println(Val2)
			axlUIConfirm(Val2)
		)
		
		("DEHIGH"
			DangData()
			foreach(DangListlp DangList
				axlDehighlightObject(DangListlp)
			)
			axlUIConfirm("DeHighlighted Successfully..!")
		)
		
		("DELLINE"
			DangData()
			foreach(LineDangListlpS LineDangList
				axlDeleteObject(LineDangListlpS)
			)
			Val3 = sprintf(nil "Total Number Of Dangling Line Deleted - %d", length(LineDangList))
			println(Val3)
			axlUIConfirm(Val3)
		)
		
		("DELVIA"
			DangData()
			foreach(ViaDangListlpS ViaDangList
				axlDeleteObject(ViaDangListlpS)
			)
			Val4 = sprintf(nil "Total Number Of Dangling Via Deleted - %d", length(ViaDangList))
			println(Val4)
			axlUIConfirm(Val4)
		)
		
		("DELALL"
			DangData()
			foreach(DangListlpS DangList
				axlDeleteObject(DangListlpS)
			)
			Val5 = sprintf(nil "Total Number Of Dangling Line Deleted - %d & Dangling Via Deleted - %d", length(LineDangList), length(ViaDangList))
			println(Val5)
			axlUIConfirm(Val5)
		)
	)
	axlFormDisplay(DangHigh_form)
)


procedure(DangData()
	originalVisible=axlVisibleGet()
	axlVisibleDesign(t)
	
	LineDangList = nil
	ViaDangList = nil
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "CLINES"), ?onButtons "CLINES")
	LineDt = axlGetSelSet(axlAddSelectAll())
	foreach(LineDtlp LineDt
		if(length(axlDBGetConnect(LineDtlp t)) < 2 then
			when(LineDtlp push(LineDtlp LineDangList))
		)
	)
	
	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL", "VIAS"), ?onButtons "VIAS")
	ViaDt = axlGetSelSet(axlAddSelectAll())
	foreach(ViaDtlp ViaDt
		if(length(axlDBGetConnect(ViaDtlp t)) < 2 then
			when(ViaDtlp push(ViaDtlp ViaDangList))
		)
	)
	
	LineDangList = unique(LineDangList)
	ViaDangList = unique(ViaDangList)
	DangList = append(LineDangList ViaDangList)
	
	axlVisibleSet(originalVisible)
	axlClearSelSet()
)
