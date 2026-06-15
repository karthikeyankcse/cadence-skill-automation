axlCmdRegister("AddTriShpPwrAE" 'AddTriShpPwrAE)
(defun AddTriShpPwrAE ()
	createTSform()
	TSform()
)
(defun TSform () 
	TSform=axlFormCreate( (gensym) TSform_file nil 'TS_Action t)
	axlFormDisplay(TSform)
)
 
(defun createTSform ()
	drain()
		TSform_file = "AddTriShpPwrAE.form"
		TSform = outfile(TSform_file "w")

		fprintf(TSform "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(TSform "FORM\n") 
		fprintf(TSform "FIXED\n")
		fprintf(TSform "PORT 39 10\n")

		fprintf(TSform "HEADER \"Creating Anti Etch Shape\"\n")
		fprintf(TSform "\n")
		fprintf(TSform "TILE\n")
		
		fprintf(TSform "FIELD TSCRT\n") 
		fprintf(TSform "FLOC 12 2\n") 
		fprintf(TSform "MENUBUTTON \"CREATE\" 15 4\n") 
		fprintf(TSform "ENDFIELD\n")
		fprintf(TSform "\n")
		
		fprintf(TSform "TEXT \"ENTER THE LENGTH :\"\n")
		fprintf(TSform "TLOC 8 7\n")
		fprintf(TSform "ENDTEXT\n")
		
		fprintf(TSform "FIELD SLEN\n") 
		fprintf(TSform "FLOC 25 7\n") 
		fprintf(TSform "STRFILLIN 6 10\n") 
		fprintf(TSform "ENDFIELD\n")
		fprintf(TSform "\n") 
		
		TOPLEFT = "TOPLEFT" 
		fprintf(TSform "FIELD %s\n" TOPLEFT)
		fprintf(TSform "FLOC 12 10 \n")
		fprintf(TSform "CHECKLIST \"---> TOP LEFT\" \n")
		fprintf(TSform "ENDFIELD\n")
		
		TOPRIGHT = "TOPRIGHT" 
		fprintf(TSform "FIELD %s\n" TOPRIGHT)
		fprintf(TSform "FLOC 12 12 \n")
		fprintf(TSform "CHECKLIST \"---> TOP RIGHT\" \n")
		fprintf(TSform "ENDFIELD\n")
		
		BOTLEFT = "BOTLEFT" 
		fprintf(TSform "FIELD %s\n" BOTLEFT)
		fprintf(TSform "FLOC 12 14 \n")
		fprintf(TSform "CHECKLIST \"---> BOT LEFT\" \n")
		fprintf(TSform "ENDFIELD\n")
		
		BOTRIGHT = "BOTRIGHT" 
		fprintf(TSform "FIELD %s\n" BOTRIGHT)
		fprintf(TSform "FLOC 12 16 \n")
		fprintf(TSform "CHECKLIST \"---> BOT RIGHT\" \n")
		fprintf(TSform "ENDFIELD\n")
		
		fprintf(TSform "\n")
		fprintf(TSform "ENDTILE\n")
		fprintf(TSform "\n")
		fprintf(TSform "ENDFORM\n")
	close( TSform)
)


(defun TS_Action (TSform)
	(case TSform->curField	
		("TSCRT"
			axlUIConfirm("Please Pick the Point To Create Shape..!")
			PickPoint = axlEnterPoint(?prompts "Please Pick The Point..!" ?gridSnap t)
			PicPointX1 = car(PickPoint)
			PicPointY1 = cadr(PickPoint)
			(LenVal = (axlFormGetField TSform "SLEN"))
			LenVal = atoi(LenVal)
			PicPointX = 0
			PicPointY = 0
			axlClearSelSet()
			axlSetFindFilter(?enabled `("NOALL" "LINESEGS") ?onButtons `("LINESEGS"))
			LineSegDt = axlGetSelSet(axlSingleSelectBox( list(PicPointX1:PicPointY1 PicPointX1:PicPointY1)))
			foreach(LineSegDtlp LineSegDt
				LyrVal = LineSegDtlp->layer
				LyrAE = nth(0 parseString(LineSegDtlp -> layer "/"))				
				CSegXpoint = xCoord(car(LineSegDtlp->startEnd))
				CSegYpoint = yCoord(car(LineSegDtlp->startEnd))
				if(eqv(xCoord(car(LineSegDtlp->startEnd)) xCoord(cadr(LineSegDtlp->startEnd))) then
					(orient="Vertical")
					PicPointX = CSegXpoint 
				else
					if(eqv(yCoord(car(LineSegDtlp->startEnd)) yCoord(cadr(LineSegDtlp->startEnd))) then
						(orient="Horizonal")
						PicPointY = CSegYpoint
					else
						(orient="Odd-Angle")
					)
				)
			)
			if(LyrAE == "ANTI ETCH" then
				if(PicPointX != 0 && PicPointY != 0 then 
					when((axlFormGetField TSform TOPLEFT)
						path = axlPathStart( list(PicPointX:PicPointY PicPointX - LenVal:PicPointY PicPointX:PicPointY + LenVal PicPointX:PicPointY))
						shape = axlDBCreateShape(path t LyrVal nil)
					)
					
					when((axlFormGetField TSform TOPRIGHT)
						path = axlPathStart( list(PicPointX:PicPointY PicPointX + LenVal:PicPointY PicPointX:PicPointY + LenVal PicPointX:PicPointY))
						shape = axlDBCreateShape(path t LyrVal nil)
					)
					
					when((axlFormGetField TSform BOTLEFT)
						path = axlPathStart( list(PicPointX:PicPointY PicPointX - LenVal:PicPointY PicPointX:PicPointY - LenVal PicPointX:PicPointY))
						shape = axlDBCreateShape(path t LyrVal nil)
					)
					
					when((axlFormGetField TSform BOTRIGHT)
						path = axlPathStart( list(PicPointX:PicPointY PicPointX + LenVal:PicPointY PicPointX:PicPointY - LenVal PicPointX:PicPointY))
						shape = axlDBCreateShape(path t LyrVal nil)
					)
				)
			else
				println("Error : Selected Line is Not from ANTI ETCH..!")
				axlUIConfirm("Error : Selected Line is Not from ANTI ETCH..!")
			)
			axlClearSelSet()
		)
	)
	axlFormDisplay(TSform)
)

