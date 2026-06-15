axlCmdRegister("AddNetToBusBySite" `AddNetToBusBySite)
procedure(AddNetToBusBySite()
ErrorList = nil
foreach(NetDtlp axlDBGetDesign()->nets
	InpNetName = NetDtlp->name
	InpBusName = NetDtlp->bus->name
	if(InpBusName != nil then
		BusId = car(axlSelectByName("BUS" InpBusName))
		TxtPrse1 = substring(InpNetName 1 3)
		TxtPrse2 = substring(InpNetName -3 3)
		TxtPrse3 = substring(InpNetName 1 4)
		TxtPrse4 = substring(InpNetName -4 4)
		if(TxtPrse1 == "S1_" || TxtPrse3 == "S01_" then 
			if(TxtPrse1 == "S1_" then
				pcre1 = pcreCompile("S1_")
			else
				pcre1 = pcreCompile("S01_")
			)
			Inp_Net_Up = pcreReplace(pcre1 InpNetName "S*_" 1)
			foreach(NetUpDtlp axlDBGetDesign()->nets
				UpNetName = NetUpDtlp->name
				UpBusName = NetUpDtlp->bus->name
				pcre3 = pcreCompile(Inp_Net_Up)
				when(pcreExecute(pcre3 UpNetName)
					InpNetNamePrse = parseString(InpNetName "_")
					InpNetNameList = cdr(InpNetNamePrse)
					InpPrseval = buildString(InpNetNameList "_")
					
					UpNetNamePrse = parseString(UpNetName "_")
					UpNetNameList = cdr(UpNetNamePrse)
					UpPrseval = buildString(UpNetNameList "_")
					
					if(InpPrseval == UpPrseval then
						if(UpBusName == nil then
							axlDBAddGroupObjects(BusId NetUpDtlp)
						else
							if(InpBusName != UpBusName then
								ErrorData = sprintf(nil "(%s) - This Net Already Exist in (%s) Bus --- SITE 1 Bus - (%s)", UpNetName, UpBusName, InpBusName)
								when(ErrorData push(ErrorData ErrorList))							
							)
						)
					)
				)
			)
		else
			if(TxtPrse2 == "_S1"  || TxtPrse4 == "_S01" then
				if(TxtPrse2 == "_S1" then
					pcre2 = pcreCompile("_S1")
					count = 0
					val = strlen(InpNetName)
					for(i 1 val
						TxtPrse = substring(InpNetName i 3)
						if(TxtPrse == "_S1" then
							count = count + 1
						)
					)
				else
					pcre2 = pcreCompile("_S01")
					count = 0
					val = strlen(InpNetName)
					for(i 1 val
						TxtPrse = substring(InpNetName i 4)
						if(TxtPrse == "_S01" then
							count = count + 1
						)
					)
				)
				Inp_Net_Up1 = pcreReplace(pcre2 InpNetName "_S*" count)
				foreach(NetUpDtlp1 axlDBGetDesign()->nets
					UpNetName1 = NetUpDtlp1->name
					UpBusName1 = NetUpDtlp1->bus->name
					pcre4 = pcreCompile(Inp_Net_Up1)
					when(pcreExecute(pcre4 UpNetName1)
						InpNetNamePrse1 = parseString(InpNetName "_")
						InpNetNameList1 = reverse(cdr(reverse(InpNetNamePrse1)))
						InpPrseval1 = buildString(InpNetNameList1 "_")
						
						UpNetNamePrse1 = parseString(UpNetName1 "_")
						UpNetNameList1 = reverse(cdr(reverse(UpNetNamePrse1)))
						UpPrseval1 = buildString(UpNetNameList1 "_")
						
						if(InpPrseval1 == UpPrseval1 then
							if(UpBusName1 == nil then
								axlDBAddGroupObjects(BusId NetUpDtlp1)
							else
								if(InpBusName != UpBusName1 then
									ErrorData = sprintf(nil "(%s) - This Net Already Exist in (%s) Bus --- SITE 1 Bus - (%s)", UpNetName1, UpBusName1, InpBusName)
									when(ErrorData push(ErrorData ErrorList))
								)
							)
						)
					)
				)
			)
		)
	)
)
NonBusErrorList  = nil
foreach(NonBusErrlp axlDBGetDesign()->nets
	NBNetName = NonBusErrlp->name
	NBBusName = NonBusErrlp->bus->name
	if(NBBusName == nil then
		NonBusErrorData = sprintf(nil "(%s) - This Net Not Exist in any BUS", NBNetName) 
		when(NonBusErrorData push(NonBusErrorData NonBusErrorList))
	)
)
ErrorList = unique(ErrorList)
ErrorList = sort(ErrorList 'alphalessp)

NonBusErrorList = unique(NonBusErrorList)
NonBusErrorList = sort(NonBusErrorList 'alphalessp)	

FinalError = append(ErrorList NonBusErrorList)
if(FinalError != nil then
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	logfile = "AddNetToBusBySite.log"
	port_Error = axlDMOpenLog(logfile)
	fprintf(port_Error, "Design name: %s\n", design_path)
	fprintf(port_Error, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	
	if(ErrorList != nil then
		fprintf(port_Error, "%s\n\n", "SKIPPED NETS :")
		foreach(ErrorListlp ErrorList
			fprintf(port_Error, "%-22s\n", ErrorListlp)
		)
		fprintf(port_Error, "\n\n")
		fprintf(port_Error, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port_Error, "%s\n", "NO ERROR..!")
		fprintf(port_Error, "\n\n")
		fprintf(port_Error, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(NonBusErrorList != nil then
		fprintf(port_Error, "%s\n\n", "WARNINGS :")
		foreach(NonBusErrorListlp NonBusErrorList
			fprintf(port_Error, "%-22s\n", NonBusErrorListlp)
		)
		fprintf(port_Error, "\n\n")
		fprintf(port_Error, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port_Error, "%s\n", "NO WARNINGS...!")
		fprintf(port_Error, "\n\n")
		fprintf(port_Error, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	axlDMClose(port_Error)
	axlUIViewFileCreate(logfile, "Add Net To BUS", nil, '(30 25), '(CENTER))
else
	axlUIConfirm("Done...!")
)

)

