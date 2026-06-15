axlCmdRegister( "bbViaReport" `ViaReport)
(defun ViaReport ()
; Find all of the vias in the design
allViasInDesign=list()
originalVisible=axlVisibleGet()
designName = axlCurrentDesign()
axlVisibleDesign(t)
axlShell("redisplay")
axlSetFindFilter(?enabled '(noall vias) ?onButtons '(noall vias))
allViasInDesign=axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
; Open a file to work on
if(length(allViasInDesign)==0
then
axlUIConfirm("No vias in this design. Please try another design.")
else
writeOutFile = outfile("./DesignViaReport.csv" "w")
fprintf(writeOutFile strcat("Design Via Report for " designName "\n\n"))
fprintf(writeOutFile "Via Location,Via Net Name,Padstack Name,Via Start
Layer,Via End Layer\n")
; Output data for each via to the file
foreach(via allViasInDesign
when(or(not(nindex(car(via->startEnd) axlConductorTopLayer())) not(nindex(cadr(via->startEnd) axlConductorBottomLayer())))
when(or(not(nindex(car(via->startEnd) axlConductorBottomLayer())) not(nindex(cadr(via->startEnd) axlConductorTopLayer())))
when(or(not(nindex(car(via->startEnd) axlConductorBottomLayer())) not(nindex(cadr(via->startEnd) axlConductorBottomLayer())))
when(or(not(nindex(car(via->startEnd) axlConductorTopLayer())) not(nindex(cadr(via->startEnd) axlConductorTopLayer())))
viaLocation = sprintf(nil "%L:%L" car(via->xy) cadr(via->xy))
a = sprintf(nil "%L" via->net->name)
b = sprintf(nil "%L" via->name)
c = sprintf(nil "%L" car(via->startEnd))
d = sprintf(nil "%L" cadr(via->startEnd))
fprintf(writeOutFile strcat(viaLocation ","))
fprintf(writeOutFile strcat(a ","))
fprintf(writeOutFile strcat(b ","))
fprintf(writeOutFile strcat(c ","))
fprintf(writeOutFile strcat(d "\n"))
);end when via span not Top to Bottom
)
)
)
);end foreach via allViasInDesign
; Close the file and wrap up
fprintf(writeOutFile "END OF FILE")
close(writeOutFile)
axlVisibleSet(originalVisible)
axlShell("redisplay")
axlUIConfirm( "Report has been generated in your working directory." )
; This next line launches Excel and displays the report
axlHttp("DesignViaReport.csv")
);end if length(allViasInDesign)==0
);end defun myCompanyViaReport
