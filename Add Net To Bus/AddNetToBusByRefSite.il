axlCmdRegister("AddNetToBusBySite" `AddNetToBusBySite)
procedure(AddNetToBusBySite()
ErrorList = nil
foreach(BrdPinDt setof(comps axlDBGetDesign() ->components comps->symbol)
foreach(NetDtlp BrdPinDt->pins
	InpNetName = NetDtlp->net->name
	InpBusName = NetDtlp->net->bus->name
	InpRef = NetDtlp->parent->refdes
	if(InpBusName != nil then
		BusId = car(axlSelectByName("BUS" InpBusName))
		TxtPrse1 = substring(InpRef 1 3)
		TxtPrse2 = substring(InpRef -3 3)
		TxtPrse3 = substring(InpRef 1 4)
		TxtPrse4 = substring(InpRef -4 4)
		if(TxtPrse1 == "S1_" || TxtPrse3 == "S01_" then 
			if(TxtPrse1 == "S1_" then
				pcre1 = pcreCompile("S1_")
			else
				pcre1 = pcreCompile("S01_")
			)
			
			Inp_Net_Up = pcreReplace(pcre1 InpRef "S*_" 1)
			foreach(BrdPinDt1 setof(comps1 axlDBGetDesign() ->components comps1->symbol)
			foreach(NetUpDtlp BrdPinDt1->pins
				UpNetName = NetUpDtlp->net->name
				UpBusName = NetUpDtlp->net->bus->name
				UpRef = NetUpDtlp->parent->refdes
				UpNet = car(axlSelectByName("NET" UpNetName))
				pcre3 = pcreCompile(Inp_Net_Up)
				when(pcreExecute(pcre3 UpRef)
					InpNetNamePrse = parseString(InpRef "_")
					InpNetNameList = cdr(InpNetNamePrse)
					InpPrseval = buildString(InpNetNameList "_")
					
					UpNetNamePrse = parseString(UpRef "_")
					UpNetNameList = cdr(UpNetNamePrse)
					UpPrseval = buildString(UpNetNameList "_")
					
					if(InpPrseval == UpPrseval then
						if(UpBusName == nil then
							axlDBAddGroupObjects(BusId UpNet)
						else
							if(InpBusName != UpBusName then
								ErrorData = sprintf(nil "(%s) - This Net Already Exist in (%s) Bus --- SITE 1 Bus - (%s)", UpNetName, UpBusName, InpBusName)
								when(ErrorData push(ErrorData ErrorList))							
							)
						)
					)
				)
			)
			)
		else
			if(TxtPrse2 == "_S1"  || TxtPrse4 == "_S01" then
				if(TxtPrse1 == "_S1" then
					pcre2 = pcreCompile("_S1")
					count = 0
					val = strlen(InpRef)
					for(i 1 val
						TxtPrse = substring(InpRef i 3)
						if(TxtPrse == "_S1" then
							count = count + 1
						)
					)
				else
					pcre2 = pcreCompile("_S01")
					count = 0
					val = strlen(InpRef)
					for(i 1 val
						TxtPrse = substring(InpRef i 4)
						if(TxtPrse == "_S01" then
							count = count + 1
						)
					)
				)
				
				Inp_Net_Up1 = pcreReplace(pcre2 InpRef "_S*" count)
				foreach(BrdPinDt2 setof(comps2 axlDBGetDesign() ->components comps2->symbol)
				foreach(NetUpDtlp1 BrdPinDt2->pins
					UpNetName1 = NetUpDtlp1->net->name
					UpBusName1 = NetUpDtlp1->net->bus->name
					UpRef1 = NetUpDtlp1->parent->refdes
					UpNet1 = car(axlSelectByName("NET" UpNetName1))
					pcre4 = pcreCompile(Inp_Net_Up1)
					when(pcreExecute(pcre4 UpRef1)
						InpNetNamePrse1 = parseString(InpRef "_")
						InpNetNameList1 = reverse(cdr(reverse(InpNetNamePrse1)))
						InpPrseval1 = buildString(InpNetNameList1 "_")
						
						UpNetNamePrse1 = parseString(UpRef1 "_")
						UpNetNameList1 = reverse(cdr(reverse(UpNetNamePrse1)))
						UpPrseval1 = buildString(UpNetNameList1 "_")
						
						if(InpPrseval1 == UpPrseval1 then
							if(UpBusName1 == nil then
								axlDBAddGroupObjects(BusId UpNet1)
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
)
)

println(ErrorList)
)

