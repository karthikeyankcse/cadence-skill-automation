axlCmdRegister( "csa" `csa)
(defun csa ()
	originalVisible=axlVisibleGet()
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())

	AllObject=list()
	drc = 0
	stop = nil
	logWindow = nil
	max_angle = 90.0
	
	axlSetFindFilter(?enabled '(noall CLINES) ?onButtons '(noall CLINES))
	mypopup = axlUIPopupDefine(nil	(list (list "Done" 'axlFinishEnterFun) (list "Cancel" 'axlCancelEnterFun)))
	axlUIPopupSet( mypopup)
	while(axlSelect(?prompt "Please select Cline...")
		AllObject = axlGetSelSet()
		axlClearSelSet()
		if(logWindow != nil then 
			axlUIWClose(logWindow)
			if(isFile("Clineseg_angle.log") == t then deleteFile("Clineseg_angle.log"));end if
			logWindow = nil
		);end if	
		drc = 0
		
		WriteOutFile = outfile("./Clineseg_angle.log" "w")
		fprintf(WriteOutFile, "Design name: %s\n", design_path)
		fprintf(WriteOutFile, "Angle Check: %f\n", max_angle)
		fprintf(WriteOutFile, "%s %s\n", "Check Date:", timeToString(fileTimeModified("Clineseg_angle.log")))
		fprintf(WriteOutFile, "%s\n", "------------------------------------------------")
		fprintf(WriteOutFile, "%-14s %-10s %s\n", "Layer", "Angle", "Locations")

		foreach(object AllObject
			Netname = object->net->name
			Layer = object->layer
			drcLayer = strcat("DRC ERROR CLASS/", cadr(parseString(Layer, "/")))
			Cline_Segments = object->segments			
			while(length(Cline_Segments) > 1
				First_seg = car(Cline_Segments)
				Second_seg = nthelem(2,Cline_Segments)
				First_seg_width = First_seg->width
				Second_seg_width = Second_seg->width
				if(First_seg_width < Max_LW || Second_seg_width < Max_LW then
					First_seg_length = axlDistance(car(First_seg->startEnd) lastelem(First_seg->startEnd))
					Second_seg_length = axlDistance(car(Second_seg->startEnd) lastelem(Second_seg->startEnd))
					Third_seg_length = axlDistance(car(First_seg->startEnd) lastelem(Second_seg->startEnd))

					aa = First_seg_length*First_seg_length
					bb = Second_seg_length*Second_seg_length
					cc = Third_seg_length*Third_seg_length
					ab2 = 2*First_seg_length*Second_seg_length
					CosC = (aa + bb - cc)/ab2
					AngleInDegree = axlRadToDeg(acos(CosC))	
					;### CONG THUC TINH GOC _axlAngleBetweenLines(list(pt1, pt2), list(pt3, pt4))  =>CHUA TEST THU
					if(AngleInDegree <= max_angle then
						fprintf(WriteOutFile, "%-14s %-10.2f %L\n", Layer, AngleInDegree, car(Second_seg->startEnd))
						actual_text = sprintf(actual_text "%.2f", AngleInDegree)
						drc_text = sprintf(drc_text "No Permit Angle In Cline")										
						drc_maker = axlDBCreateExternalDRC(list(drc_text sprintf(nil "%.3f", max_angle)), car(Second_seg->startEnd), drcLayer , list(First_seg Second_seg) , nil , actual_text) 								
						drc = drc + 1
					;else
					;	printf("%L\n", AngleInDegree)
					);end if
				);end if seg_width 
				Cline_Segments = cdr(Cline_Segments)
			);end while i> 1
		);end foreach clines AllObject
		; Close the file and wrap up
		fprintf(WriteOutFile, "%s\n", "END OF FILE")

		close(WriteOutFile)
		printf("Process done!\n")
		axlVisibleSet(originalVisible)
		axlShell("redisplay")
		if(drc > 0 then
			logWindow = axlUIViewFileCreate("Clineseg_angle.log" "Angle report..." nil );t xoa file sau khi xem, nil khong xoa
		else
			printf("No Error Found!\n")
			if(isFile("Clineseg_angle.log")  then deleteFile("Clineseg_angle.log"))
		);end if
		printf("Please select Cline...\n")
	);end while
);end defun Clineseg_angle