;symbols = setof(sym, axlDBGetDesign() ->symbols, sym ->refdes)
;multiRefdesList = setof(refdes, symbols ~>refdes, refdes && !onep(length(setof(ref, symbols ~>refdes, ref == refdes))))

procedure( Duplicate()
 let((logFile, oldSetData, refdesText, multiRefdesText, port)
	logFile = "DuplicateRefdes.log"

	oldSetData = list(axlGetSelSet(), axlGetFindFilter(nil), axlGetFindFilter(t))
	axlClearSelSet()
	axlSetFindFilter(?enabled '("noall", "text", "invisible"), ?onButtons '("noall", "text"))
	axlAddSelectAll()
	;Get all REF DES/SILKSCREEN_[side] text:
	refdesText = setof(obj, axlGetSelSet(), substring(obj ->layer, 1, 8) == "REF DES/" && index(obj ->layer, "/SILKSCREEN_"))
	axlSetFindFilter(?enabled cons("noall", cadr(oldSetData)) ?onButtons cons("noall", caddr(oldSetData)))
	axlSingleSelectObject(car(oldSetData))
	axlClearSelSet()
	;Find the duplicates:
	multiRefdesText = setof(txtObj1, refdesText, exists(txtObj2, refdesText, txtObj2 != txtObj1 && txtObj2 ->text == txtObj1 ->text))

	;Write the log:
	port = axlDMOpenLog(logFile)
	fprintf(port, "Duplicate Refdes List\n")
	foreach(txt, unique(multiRefdesText ~>text)
		fprintf(port, "\t%s:\n", txt)
		foreach(txtObj, setof(obj, multiRefdesText, obj ->text == txt)
			fprintf(port, "\t\t%s %L\n", txtObj ->layer, txtObj ->xy)
		)
	)
	axlHighlightObject(multiRefdesText)
	fprintf(port, "\n%d Duplicates", length(unique(multiRefdesText ~>text)))
	axlDMClose(port)

	axlUIViewFileCreate(logFile, "Duplicate Refdes", nil, '(30 25), '(CENTER))
))
axlCmdRegister("Duplicate" 'Duplicate)