axlCmdRegister( "VOP" `VOP)
(defun VOP ()
originalVisible = axlVisibleGet()
designName = axlCurrentDesign()
design_path = axlGetDrawingName()
design_unit = car(axlDBGetDesignUnits())
count_num = 0
All_syms = list()

;#### Open temp files to work on ####
writeOutFile = outfile("./Via_on_pad_report.log" "w")
timeperform = fileTimeModified("Via_on_pad_report.log")
fprintf(writeOutFile, "Design name: %s\n", design_path)
fprintf(writeOutFile, "%s %s\n\n", "Check Date: ", timeToString(timeperform))
fprintf(writeOutFile, "%s\n", "------------------------------------------------")
fprintf(writeOutFile, "%-8s %-8s %-18s\n\n", "Symbol", "Layer", "Drc Location")

foreach(sym, axlDBGetDesign()->symbols
sym_refdes = sym->refdes
Sym_side = if(sym->isMirrored, "BOTTOM", "TOP");end if
Sym_pins = sym->pins

axlVisibleDesign(nil)
axlVisibleLayer(strcat("VIA CLASS/", Sym_side) t)
axlSetFindFilter(?enabled '(NOALL VIAS) ?onButtons '(NOALL VIAS))
axlClearSelSet()
foreach(pin Sym_pins
pin_pad = axlDBGetPad(pin, strcat("ETCH/", Sym_side), "REGULAR")

pin_pad_bBox = pin_pad->bBox
pin_bBox_chk = list(axlMXYAdd(pin->xy car(pin_pad_bBox)) axlMXYAdd(pin->xy lastelem(pin_pad_bBox)))
data_in_box = axlGetSelSet(axlSingleSelectBox(pin_bBox_chk))
axlClearSelSet()
foreach(via data_in_box
via_pad = axlDBGetPad(via, strcat("ETCH/", Sym_side), "REGULAR")
size_via = abs(xCoord(car(via_pad->bBox))- xCoord(cadr(via_pad->bBox)))
Via_pad_drillSize = via->definition->drillDiameter
expand_value = abs(size_via - Via_pad_drillSize)*(-1.0)
Via_poly = car(axlPolyFromDB(via ?padType 'REGULAR))
ViaHole_poly = car(axlPolyExpand(Via_poly expand_value/2 'NONE))
Pin_poly = car(axlPolyFromDB(pin ?padType 'REGULAR))
AndPoly = car(axlPolyOperation(ViaHole_poly Pin_poly 'AND))
if(AndPoly != nil then
count_num = count_num + 1
fprintf(writeOutFile, "%-8s %-8s %-L\n", sym_refdes, Sym_side, pin->xy)
);end if
);end foreach
);end foreach
);end foreach

; Close the file and wrap up
fprintf(writeOutFile,"Total error found: %d errors\n", count_num)
fprintf(writeOutFile, "%s\n", "END OF FILE")
close(writeOutFile)

axlVisibleSet(originalVisible)
axlShell("redisplay")
if(count_num > 0 then
axlUIViewFileCreate("Via_on_pad_report.log", "Via_on_pad_report" nil )
else
axlUIConfirm("No error found.")
if(isFile("Via_on_pad_report.log") == t then deleteFile("Universal_via_check.log"));end if
); end if
);end defun VOP