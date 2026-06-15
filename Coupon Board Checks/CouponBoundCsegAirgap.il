axlCmdRegister("BoundCSegAirgap" 'BoundCSegAirgap)
procedure(BoundCSegAirgap()
BA_BrowC2 = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	BA_OpenFileC2 = axlDMFileParts(BA_BrowC2)
	BA_DataInFileC2 = axlDMOpenFile("ALLEGRO_TEXT" cadr(BA_OpenFileC2) "r") 
	BA_UserInputC2 = nil
		while(gets(BA_Inp_ValC2 BA_DataInFileC2)
			BA_Inp_ValC2 = car(parseString(BA_Inp_ValC2 "\n"))
				when(BA_Inp_ValC2 push(BA_Inp_ValC2 BA_UserInputC2))
			)
axlDMClose(BA_DataInFileC2)
BA_UserInputC2 = unique(BA_UserInputC2)
if(BA_UserInputC2 == nil then
	axlUIConfirm("Input is Empty...!")
)
Inp_AirGap = axlEnterString(?prompts list("Enter the Minimum Distance Between Boundary and Cline Segment...!"))
Inp_AirGap = atof(Inp_AirGap)
originalVisible = axlVisibleGet()
axlVisibleDesign(t)

CsegList = nil
axlShell("redisplay")
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "SHAPES") ?onButtons `("SHAPES"))
Shpdata = axlGetSelSet(axlAddSelectAll()) 
foreach(Shpdatalp Shpdata
	lyr = Shpdatalp->layer
	if(lyr == "BOARD GEOMETRY/OUTLINE" then
		axlClearSelSet()
		axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
		Csegdata = axlGetSelSet(axlAddSelectAll()) 
		foreach(Csegdatalp Csegdata
			CSegLyr = nth(1 parseString(Csegdatalp -> layer "/"))
			CSegNetName = Csegdatalp->net->name 
			foreach(BA_UserInputC2lp BA_UserInputC2
				if(BA_UserInputC2lp == CSegNetName then
					(data = (axlAirGap Csegdatalp Shpdatalp nil 'anyLayer))
					when(data
						if(data < Inp_AirGap then
							ClineSegData = sprintf(nil "%s,%s,%.2f,(%.2f %.2f),(%.2f %.2f)", CSegNetName, CSegLyr, data, xCoord(car(Csegdatalp->startEnd)), yCoord(car(Csegdatalp->startEnd)), xCoord(cadr(Csegdatalp->startEnd)), yCoord(cadr(Csegdatalp->startEnd))) 
							when(ClineSegData push(ClineSegData CsegList))
						)
					)
				)
			)
		)
	)
)
CsegList = unique(CsegList)
if(CsegList != nil then
	logfile = "CouponBoundCsegAirgap.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
		fprintf(port, "%s\n\n", "ERROR LIST :")
		fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n\n", "NET NAME", "LAYER NAME", "AIRGAP", "XY LOCATION", "XY LOCATION")
		foreach(MissMatchListlp CsegList
			FinalListS_filt = parseString(MissMatchListlp ",")
			fprintf(port, "%-25s %-25s %-25s %-25s %-25s \n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt), nth(4 FinalListS_filt))
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Coupon Boundry CSegment Airgap", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Error Found...!")

)
axlVisibleSet(originalVisible)
axlShell("redisplay")
)