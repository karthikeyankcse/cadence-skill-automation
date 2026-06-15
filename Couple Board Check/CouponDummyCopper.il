axlCmdRegister("CouponDummyCopper" 'CouponDummyCopper)
procedure(CouponDummyCopper()
originalVisible = axlVisibleGet()
axlVisibleDesign(t)
axlShell("redisplay")
LyrFoundList = nil
axlUIConfirm("Please Select the Coupon board...")
axlClearSelSet()
axlSetFindFilter(?enabled `("NOALL" "SHAPES" "CLINES") ?onButtons `("SHAPES" "CLINES"))
ShpInp = axlGetSelSet(axlSelect( ))   
axlClearSelSet()
foreach(ShpInplp ShpInp
	clslayer = nth(0 parseString(ShpInplp -> layer "/"))
	if(clslayer == "ETCH" then
		FoundData = nth(1 parseString(ShpInplp -> layer "/"))
		when(FoundData push(FoundData LyrFoundList))
	)
)
LyrFoundList = unique(LyrFoundList)
etchparam = axlGetParam("paramLayerGroup:ETCH")
l_layers = etchparam->groupMembers
LayerMissList = nil
LayerMissList = setof(item1, l_layers, !member(item1, LyrFoundList))
LayerMissList = unique(LayerMissList)
axlVisibleSet(originalVisible)
axlShell("redisplay")
if(LayerMissList != nil then
	logfile = "CouponBrdDummyCopper.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	fprintf(port, "%-25s %-25s \n\n", "LAYER NAME", "MESSAGE")
	foreach(LayerMissListlp LayerMissList
		fprintf(port, "%-25s %-25s \n", LayerMissListlp, "NO SHAPE OR TRACE FOUND IN THIS LAYER...")
	)
else
	axlUIConfirm("No Error Found...!")
)
axlDMClose(port)
axlUIViewFileCreate(logfile, "Coupon Dummy Copper", nil, '(30 25), '(CENTER))
)