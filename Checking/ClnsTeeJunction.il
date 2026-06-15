axlCmdRegister("ClnsTeeJunction" 'ClnsTeeJunction)
procedure(ClnsTeeJunction()
originalVisible = axlVisibleGet()
axlVisibleDesign(t)
ErrorList = nil
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "CLINES") ?onButtons `("CLINES"))
ClineDt = axlGetSelSet(axlAddSelectAll())
foreach(ClineDtlp ClineDt
DummyVal = 0
	ConLyr = axlDBGetConnect(ClineDtlp t)
	foreach(ConLyrlp ConLyr
		if(ConLyrlp->objType == "tee" then
			ClineSegDt = ClineDtlp ->segments
			ClineSegDtRev = reverse(ClineSegDt)
			ClineSegFirst = car(ClineSegDt)
			ClineSegLast = car(ClineSegDtRev)
			CSegXYPointFirst = sprintf(nil "(%.2f %.2f)", xCoord(car(ClineSegFirst->startEnd)), yCoord(car(ClineSegFirst->startEnd)))
			CSegXYPointLast = sprintf(nil "(%.2f %.2f)", xCoord(cadr(ClineSegLast->startEnd)), yCoord(cadr(ClineSegLast->startEnd)))
			CLineLayer = ClineDtlp->layer
			CLineNetName = ClineDtlp->net->name 
			if(CLineNetName != nil then
				ErrorDt = sprintf(nil "%s,%s,%s,%s", CLineNetName, CLineLayer, CSegXYPointFirst, CSegXYPointLast)   
				when(ErrorDt push(ErrorDt ErrorList))
			)
		)
	)
)
ErrorList = unique(ErrorList)
axlVisibleSet(originalVisible)
axlClearSelSet()
if(ErrorList != nil then
	logfile = "Clines-T-Junction.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "----------------------------------------------------------------------------------------------------------------------------------------------------------------------")
		fprintf(port, "%s\n\n", "ERROR LIST :")
		fprintf(port, "%-25s %-25s %-25s %-25s\n\n", "NET NAME", "LAYER NAME", "XY LOCATION", "XY LOCATION")
		foreach(ErrorListlp ErrorList
			FinalListS_filt = parseString(ErrorListlp ",")
			fprintf(port, "%-25s %-25s %-25s %-25s\n", nth(0 FinalListS_filt), nth(1 FinalListS_filt), nth(2 FinalListS_filt), nth(3 FinalListS_filt))
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "------------------------------------------------------------------------------------------------------------------------------------------------------------------")
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Non Connected Clines in Via Or Pin", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("No Error Found...!")

)
)