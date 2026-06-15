 axlCmdRegister("swaplistseckar" 'SwapUpdateAutoKar ?cmdType "interactive")
procedure(SwapUpdateAutoKar()
;DRC Report Generation
out = outfile("DRC.lst")
foreach(drc_id axlDBGetDesign()->drcs
foreach(item drc_id->violations
if(item->objType == "pin" then  
fprintf(out, "%s%s%s,",item->parent->refdes, ".", item->number)
if(item->net->name == "" then
	fprintf(out, "%s,", "Dummy Net")
else
	fprintf(out, "%s,", item->net->name)
)
foreach(itemm drc_id->violations
if(itemm->objType == "line" || itemm->objType == "path"|| itemm->objType == "shape" || itemm->objType == "arc" then
if(itemm->net->name != nil then 
fprintf(out, "%s\n", itemm->net->name)
) 
)))))
close(out)

;List Declaration
alist = '("B1" "C2" "B3" "C4" "B5" "C6" "B7" "C8" "B9" "C10" "B11" "C12" "B13" "C14" "B15" "C16") 
blist = '("B1" "C2" "B3" "C4" "B5" "C6" "B7" "C8" "B9" "C10" "B11" "C12" "B13" "C14" "B15" "C16" "A2" "D3" "A4" "D5" "A6" "D7" "A8" "D9" "A10" "D11" "A12" "D13" "A14" "D15" "A16" "B17")
clist = '("B01" "C02" "B03" "C04" "B05" "C06" "B07" "C08" "B09" "C10" "B11" "C12" "B13" "C14" "B15" "C16" "A02" "D03" "A04" "D05" "A06" "D07" "A08" "D09" "A10" "D11" "A12" "D13" "A14" "D15" "A16" "B17" "E18" "F19" "E20" "F21" "E22" "F23" "E24" "F25" "E26" "F27" "E28" "F29" "E30" "F31" "E32" "F33" "F18" "G19" "F20" "G21" "F22" "G23" "F24" "G25" "F26" "G27" "F28" "G29" "F30" "G31" "F32" "G33")
dlist = '("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16")   
elist = '("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16") 
flist = '("A01" "B02" "A03" "B03" "A04" "B05" "A06" "A13" "B14" "B06" "A07" "B08" "A09" "B10" "A11" "B12")
glist = '("A01" "B02" "A03" "B03" "A04" "B05" "A06" "B06" "A07" "B08" "A09" "B10" "A11" "B12" "A13" "B14" "D01" "D02" "D03" "D04" "D05" "D06" "D07" "D08" "D10" "D11" "D12" "D13" "D14" "D15" "D16" "D17") 
hlist = '("Z422" "Z420" "Z416" "Z414" "Z418" "AB418" "AB416" "AB414" "AD422" "AD420" "AB422" "AB420" "AD418" "AD416" "AD414" "AD412" "AD410" "AD408" "AD404" "AD402" "AB410" "AB408" "AD406" "AB406" "AB412" "Z412" "Z406" "Z404" "AB404" "AB402" "Z410" "Z408" "R422" "R420" "R416" "R414" "R418" "T418" "T416" "T414" "X422" "X420" "T422" "T420" "X418" "X416" "X414" "X412" "X410" "X408" "X404" "X402" "T410" "T408" "X406" "T406" "T412" "R412" "R406" "R404" "T404" "T402" "R410" "R408" "H422" "H420" "H416" "H414" "H418" "K418" "K416" "K414" "N420" "N418" "K422" "K420" "N416" "N414" "N412" "K412" "N410" "N408" "N404" "N402" "K410" "K408" "N406" "K406" "H412" "H410" "H404" "H402" "K404" "K402" "H408" "H406" "B422" "B420" "B416" "B414" "B418" "D418" "D416" "D414" "F420" "F418" "D422" "D420" "F416" "F414" "F412" "D412" "F410" "F408" "F404" "F402" "D410" "D408" "F406" "D406" "B412" "B410" "B404" "B402" "D404" "D402" "B408" "B406" "F302" "F304" "F308" "F310" "F306" "D306" "D308" "D310" "B302" "B304" "D302" "D304" "B306" "B308" "B310" "B312" "B314" "B316" "B320" "B322" "D314" "D316" "B318" "D318" "D312" "F312" "F318" "F320" "D320" "D322" "F314" "F316" "N302" "N304" "N308" "N310" "N306" "K306" "K308" "K310" "H302" "H304" "K302" "K304" "H306" "H308" "H310" "H312" "H314" "H316" "H320" "H322" "K314" "K316" "H318" "K318" "K312" "N312" "N318" "N320" "K320" "K322" "N314" "N316" "X302" "X304" "X308" "X310" "X306" "T306" "T308" "T310" "R304" "R306" "T302" "T304" "R308" "R310" "R312" "T312" "R314" "R316" "R320" "R322" "T314" "T316" "R318" "T318" "X312" "X314" "X320" "X322" "T320" "T322" "X316" "X318" "AD302" "AD304" "AD308" "AD310" "AD306" "AB306" "AB308" "AB310" "Z304" "Z306" "AB302" "AB304" "Z308" "Z310" "Z312" "AB312" "Z314" "Z316" "Z320" "Z322" "AB314" "AB316" "Z318" "AB318" "AD312" "AD314" "AD320" "AD322" "AB320" "AB322" "AD316" "AD318")
ilist = '("J204" "J205" "M204" "M205" "E202" "E203" "P202" "P203" "M202" "M203" "F202" "F203" "N202" "N203" "G202" "G203" "W204" "W205" "F204" "F205" "T211" "W211" "K202" "K203" "W202" "W203" "H202" "H203" "S202" "S203" "J202" "J203" "K207" "K208" "G207" "G208" "K204" "K205" "P204" "P205" "N204" "N205" "H204" "H205" "T202" "T203" "R202" "R203" "W207" "W208" "P207" "P208" "T209" "T210" "G204" "G205" "W209" "W210" "E204" "E205" "S204" "S205" "R204" "R205" "J209" "J210" "P209" "P210" "H207" "H208" "E207" "E208" "F207" "F208" "J207" "J208" "S207" "S208" "T204" "T205" "R209" "R210" "M209" "M210" "S209" "S210" "M207" "M208" "T207" "T208" "N207" "N208" "G209" "G210" "R207" "R208" "H211" "H212" "N211" "N212" "J211" "J212" "P211" "P212" "N209" "N210" "H209" "H210" "E209" "E210" "F209" "F210" "E211" "E212" "K211" "K212" "F211" "F212" "M211" "M212" "G211" "G212" "K209" "K210" "R211" "R212" "S211" "S212" "H311" "H312" "N311" "N312" "J311" "J312" "P311" "P312" "N309" "N310" "H309" "H310" "P309" "P310" "J309" "J310" "K311" "K312" "R311" "R312" "M311" "M312" "E311" "E312" "K309" "K310" "F311" "F312" "M309" "M310" "G311" "G312" "S311" "S312" "E309" "E310" "H307" "H308" "E307" "E308" "F307" "F308" "J307" "J308" "G307" "G308" "K307" "K308" "F309" "F310" "G309" "G310" "M307" "M308" "R309" "R310" "N307" "N308" "S309" "S310" "P307" "P308" "T307" "T308" "R307" "R308" "S307" "S308" "K304" "K305" "P304" "P305" "N304" "N305" "H304" "H305" "M304" "M305" "J304" "J305" "T304" "T305" "S304" "S305" "G304" "G305" "W307" "W308" "E304" "E305" "T309" "T310" "F304" "F305" "W309" "W310" "R304" "R305" "T302" "T303" "E302" "E303" "P302" "P303" "M302" "M303" "F302" "F303" "N302" "N303" "G302" "G303" "R302" "R303" "S302" "S303" "K302" "K303" "W304" "W305" "H302" "H303" "T311" "W311" "J302" "J303" "W302" "W303")
jlist = '("3" "6" "7" "10" "11" "14" "15" "18" "19" "22" "23" "26" "27" "30" "31" "34" "35" "38" "39" "42" "43" "46" "47" "50" "51" "54" "55" "58" "59" "62" "63" "66")
klist = '("B1" "C2" "B3" "C4" "B5" "C6" "B7" "C8" "B9" "C10" "B11" "C12" "B13" "C14" "B15" "C16" "A2" "D3" "A4" "D5" "A6" "D7" "A8" "D9" "A10" "D11" "A12" "D13" "A14" "D15" "A16" "B17" "E18" "F19" "E20" "F21" "E22" "F23" "E24" "F25" "E26" "F27" "E28" "F29" "E30" "F31" "E32" "F33" "F18" "G19" "F20" "G21" "F22" "G23" "F24" "G25" "F26" "G27" "F28" "G29" "F30" "G31" "F32" "G33")
llist = '("B1" "C2" "B3" "C4" "B5" "C6" "B7" "C8" "B9" "C10" "B11" "C12" "B13" "C14" "B15" "C16" "A2" "D3" "A4" "D5" "A6" "D7" "A8" "D9" "A10" "D11" "A12" "D13" "A14" "D15" "A16" "B17" "E18" "F19" "E20" "F21" "E22" "F23" "E24" "F25" "E26" "F27" "E28" "F29" "E30" "F31" "E32" "F33" "F18" "G19" "F20" "G21" "F22" "G23" "F24" "G25" "F26" "G27" "F28" "G29" "F30" "G31" "F32" "G33" "E18" "F19" "E20" "F21" "E22" "F23" "E24" "F25" "E26" "F27" "E28" "F29" "E30" "F31" "E32" "F33" "F18" "G19" "F20" "G21" "F22" "G23" "F24" "G25" "F26" "G27" "F28" "G29" "F30" "G31" "F32" "G33")
;Un routed netlist 
unrouted = nil
foreach(unroute setof(el axlDBGetDesign()->nets el->unconnected > 0)
		unrouteprnt = unroute->net->name
		when(unrouteprnt push(unrouteprnt unrouted))
)

;Generated Input Stored in List
DRCinp = nil
inpdata = infile("DRC.lst")
while(gets(inplp inpdata)
	inplp = nth(0 parseString(inplp "\n"))  
when(inplp push(inplp DRCinp))
);end while 
close(inpdata)

;User input stored in List
userinpall = nil
userinptwo = nil
userinpdata = infile("POGO_CONNECTOR.lst")
while(gets(userinplp userinpdata)
	userinplpall = nth(0 parseString(userinplp "\n"))
		when(userinplpall push(userinplpall userinpall))
	userinplptwo = nth(1 parseString(userinplp ",\n"))
		when(userinplptwo push(userinplptwo userinptwo))	
)

userinptwounq = nil
userinptwounq = unique(userinptwo)

foreach(userinptwounqlp userinptwounq
datainplist2 = nil
	foreach(userinplpalllp userinpall
		userinplpalllpprsetwo = nth(1 parseString(userinplpalllp ","))
		userinplpalllpprseone = nth(0 parseString(userinplpalllp ","))
		if(userinptwounqlp == userinplpalllpprsetwo then
		if(userinptwounqlp == "S93K-PS1600" then
			foreach(listeddata alist
				inpdata1 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
				when(inpdata1 push(inpdata1 datainplist2))
		)
		else
			if(userinptwounqlp == "S93K-PS1600-HD" then
				foreach(listeddata blist
					inpdata2 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
					when(inpdata2 push(inpdata2 datainplist2))
					)    
			else
				if(userinptwounqlp == "S93K-PS1600-VHD" then					
					foreach(listeddata clist
						inpdata3 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
						when(inpdata3 push(inpdata3 datainplist2))
						)
      
				else
					if(userinptwounqlp == "S93K-PS9G" then						
						foreach(listeddata dlist
							inpdata4 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
							when(inpdata4 push(inpdata4 datainplist2))
						)
       
					else
						if(userinptwounqlp == "S93K-PSSL" then							
							foreach(listeddata elist
								inpdata5 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
								when(inpdata5 push(inpdata5 datainplist2))
							)
       
						else
							if(userinptwounqlp == "S93K-Utility" then								
								foreach(listeddata flist
									inpdata6 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
									when(inpdata6 push(inpdata6 datainplist2))
								)
        
							else
								if(userinptwounqlp == "S93K-Utility-HD" then								
									foreach(listeddata glist
										inpdata7 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
										when(inpdata7 push(inpdata7 datainplist2))
									)
         
								else
									if(userinptwounqlp == "UF-UP1600" then									
										foreach(listeddata hlist
											inpdata8 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
											when(inpdata8 push(inpdata8 datainplist2))
										)
          
									else
										if(userinptwounqlp == "UF-Support Board" then											
											foreach(listeddata ilist 
												inpdata9 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
												when(inpdata9 push(inpdata9 datainplist2))
											)
           
										else
											if(userinptwounqlp == "Chroma-LPC" then												
												foreach(listeddata jlist
													inpdata10 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
													when(inpdata10 push(inpdata10 datainplist2))
													) 
											else
												if(userinptwounqlp == "S93K-PS5000-HD" then												
													foreach(listeddata klist
														inpdata11 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
														when(inpdata11 push(inpdata11 datainplist2))
													)
												else
													if(userinptwounqlp == "S93K-PS5000-VHD" then												
														foreach(listeddata llist
														inpdata12 = sprintf(nil, "%s%s%s", userinplpalllpprseone, ".", listeddata)
														when(inpdata12 push(inpdata12 datainplist2))
														) 
            
													else
														print("Please check the input file")))))))))))))
			
		)
	)

;Phase 1 Code 
swaplist1 = nil
swaplist2 = nil
swaplist3 = nil
swaplist4 = nil
commonswap = nil
commonswapfinal = nil

;PIN Repeat check
swaplistunq = nil
foreach(itm DRCinp
DRCinplpprse = nth(0 parseString(itm ",\n"))
	foreach(datainplist2lp datainplist2
		if(datainplist2lp == DRCinplpprse then
			if(length(setof(el DRCinp nth(0 parseString(el ",")) == nth(0 parseString(itm ",")))) > 1 then
				swappar1 = parseString(itm ",") 
				data1 = sprintf(nil, "%s,%s,%s,%s" , nth(0 swappar1), nth(1 swappar1), nth(2 swappar1), "Pin Repeating - ERROR")
				when(data1 push(data1 swaplistunq))))
));end foreach
swaplist3 = unique(swaplistunq)

swaplistunq1 = nil
foreach(itmUp DRCinp
PinDt = nth(0 parseString(itmUp ",\n")) 
	foreach(datainplist2lp datainplist2
		if(datainplist2lp == PinDt then
			foreach(BrdPinDt setof(comps axlDBGetDesign() ->components comps->symbol)
				foreach(BrdPinDtlp BrdPinDt->pins
					BrdPinNum = sprintf(nil "%s%s%s" BrdPinDtlp->parent->refdes, ".", BrdPinDtlp->number)
					if(BrdPinNum == PinDt then
						ConLyr = axlDBGetConnect(BrdPinDtlp t)
						foreach(ConLyrlp ConLyr
							if(ConLyrlp->objType == "path" then
								swappar1Up = parseString(itmUp ",")
								data1Up = sprintf(nil, "%s,%s,%s,%s" , nth(0 swappar1Up), nth(1 swappar1Up), nth(2 swappar1Up), "Multiple Connection in Pin - ERROR")
								when(data1Up push(data1Up swaplistunq1))
							)
						)
					)
				)
			)
		)
	)
)
swaplist4 = unique(swaplistunq1)

;Net Repeat check
foreach(itmm DRCinp
DRCinplpprsee = nth(0 parseString(itmm ",\n"))
	foreach(datainplist2lpp datainplist2
		if(datainplist2lpp == DRCinplpprsee then
			if(length(setof(ell DRCinp nth(2 parseString(ell ",")) == nth(2 parseString(itmm ",")))) > 1 then
				swappar2 = parseString(itmm ",") 
				data2 = sprintf(nil, "%s,%s,%s,%s" , nth(0 swappar2), nth(1 swappar2), nth(2 swappar2), "Net Repeating - ERROR")
				when(data2 push(data2 swaplist2))
));end if
))

;GND Check
foreach(gnditm DRCinp
DRCinplpprseee = nth(0 parseString(gnditm ",\n"))
gnddata = nth(1 parseString(gnditm ",\n"))
	foreach(datainplist2lppp datainplist2
	if(datainplist2lppp == DRCinplpprseee then
		if(gnddata == "GND" || gnddata == "UGND" || gnddata == "DGND" || gnddata == "AGND" then
			swappar3 = parseString(gnditm ",") 
			data3 = sprintf(nil, "%s,%s,%s,%s" , nth(0 swappar3), nth(1 swappar3), nth(2 swappar3), "GND - ERROR")
			when(data3 push(data3 swaplist1))
	))	
))
commonswap = nil
commonswapfinal = nil
commonswapfinal1 = nil
commonswap = append(swaplist1 swaplist2)
commonswapfinal = append(commonswap swaplist3)
commonswapfinal1 = append(commonswapfinal swaplist4)
;Phase 2 
;Un Routing Check

;pin list from brd
pindataprselst = nil
foreach(pinlp setof(comps axlDBGetDesign() ->components comps->symbol)
	foreach(pinrpts pinlp->pins
		pindata = sprintf(nil "%s%s%s,%s", pinrpts->parent->refdes, ".", pinrpts->number, pinrpts->net->name)
		when(pindata push(pindata pindataprselst))
	)
)

inpprsedatafinal = nil
foreach(inploop datainplist2
	foreach(pindatafinal pindataprselst
		pindataprs = car(parseString(pindatafinal ","))  
			if(pindataprs == inploop then
				when(pindatafinal push(pindatafinal inpprsedatafinal)) 	
			)
	)
)

list3 = nil
foreach(swpdatalp DRCinp
swapprsedata = nth(2 parseString(swpdatalp ",\n")) 
	when(swapprsedata push(swapprsedata list3))
)

list4 = nil
foreach(inpdatalp inpprsedatafinal
inpprsedata = nth(1 parseString(inpdatalp ",\n")) 
	when(inpprsedata push(inpprsedata list4))
)



chkdlist = nil
unqchkdlist = nil
chkdlist = setof(item, list4, !member(item, list3))
unqchkdlist = unique(chkdlist)

inprutedata = nil
foreach(inpdataold inpprsedatafinal
	inpprsedataold = nth(1 parseString(inpdataold ","))
	if(inpprsedataold != nil then
		foreach(inpdatanew unqchkdlist
			inpdatanewprnt = sprintf(nil "%s", inpdatanew)
			if(inpdatanewprnt == inpprsedataold then
				inpdataoldprnt = sprintf(nil "%s", inpdataold)		
				when(inpdataoldprnt push(inpdataoldprnt inprutedata))
			)
		)
	)
)

unroutedlist = nil
foreach(inproutechkdata inprutedata
	inproutechkprse = parseString(inproutechkdata ",")
	inproutechkprseprnt = sprintf(nil "%s", nth(1 inproutechkprse))
		foreach(unrouteddata unrouted
			unrouteddataprnt = sprintf(nil "%s", unrouteddata)
			if(unrouteddataprnt == inproutechkprseprnt then
				unrouteddataprint = sprintf(nil, "%s,%s,%s,%s",nth(0 inproutechkprse), nth(1 inproutechkprse), "*****", "Un Routed - ERROR")
					when(unrouteddataprint push(unrouteddataprint unroutedlist))
			)
		)		
)

routedfinal = nil
foreach(unroutedlistlp unroutedlist
unroutedlistprse = nth(1 parseString(unroutedlistlp ",\n"))
 when(unroutedlistprse push(unroutedlistprse routedfinal))
)

routedlist = setof(item, routedfinal, !member(item, unrouted))
routedlistunq = unique(routedlist)

routedlistunqlpprntlist = nil
routedlistunqlpprntlistnxt = nil

foreach(routedlistunqlp routedlistunq
	foreach(inprutedatalp inprutedata
		inprutedatalpprse = parseString(inprutedatalp ",\n")
		if(nth(1 inprutedatalpprse) != nil then
			if(nth(1 inprutedatalpprse) == routedlistunqlp then
				routedlistunqlpprnt = sprintf(nil "%s,%s,%s,%s", nth(0 inprutedatalpprse), nth(1 inprutedatalpprse), nth(1 inprutedatalpprse), "NO CONNECTION REMAINING")
				routedlistunqlpprntnxt = sprintf(nil "%s,%s,%s", nth(0 inprutedatalpprse), nth(1 inprutedatalpprse), nth(1 inprutedatalpprse))
				when(routedlistunqlpprnt push(routedlistunqlpprnt routedlistunqlpprntlist))
				when(routedlistunqlpprntnxt push(routedlistunqlpprntnxt routedlistunqlpprntlistnxt))
			)
		)
	)
)
phasetwofinal = nil
phasetwofinal = append(unroutedlist routedlistunqlpprntlist)
finalphase = nil
finalphase = append(commonswapfinal1 phasetwofinal)


Ncpinlist = nil

Ncpinlistmem1 = nil
Ncpinlistmem2 = nil

foreach(NCpin pindataprselst
	NCpindata = nth(0 parseString(NCpin "."))
	foreach(datainplist2_lp datainplist2
		datainplist2_prse = nth(0 parseString(datainplist2_lp "."))
			if(NCpindata == datainplist2_prse then 
				NCpindata1 = nth(0 parseString(NCpin ","))
				when(NCpindata1 push(NCpindata1 Ncpinlist))
			)
	)
)

Ncpinlistmem1 = setof(item, Ncpinlist, !member(item, datainplist2))
Ncpinlistmem2 = setof(item1, datainplist2, !member(item1, Ncpinlist))

Ncpinlistmem_unq = nil
Ncpinlistmem_unq = append(Ncpinlistmem1 Ncpinlistmem2)
Ncpinlistmem = nil
Ncpinlistmem = unique(Ncpinlistmem_unq)

NCpinchklistfinal = nil
if(Ncpinlistmem != nil then
	foreach(NCpindatachk DRCinp
	NCpindatalst = nth(0 parseString(NCpindatachk ","))
		foreach(Ncpinlistmemlp Ncpinlistmem
			if(Ncpinlistmemlp == NCpindatalst then
				NCpindatachkprnt = sprintf(nil "%s,%s", NCpindatachk, "OutSide Tester Config - ERROR") 
				when(NCpindatachkprnt push(NCpindatachkprnt NCpinchklistfinal))
			)	
		)
	)
)

finalphasenc = nil
finalphasenc = append(finalphase NCpinchklistfinal)
finalprintphselst = nil

foreach(finalphsxy finalphasenc
	finalphsxyprse = nth(0 parseString(finalphsxy ",")) 
	foreach(finalpinlp setof(comps axlDBGetDesign() ->components comps->symbol)
			foreach(finalpinrpts finalpinlp->pins
				finalpinrptsprnt = sprintf(nil "%s%s%s" finalpinrpts->parent->refdes, ".", finalpinrpts->number)
					if(finalphsxyprse == finalpinrptsprnt then
						finalprintphse = sprintf(nil "%s,%L", finalphsxy, finalpinrpts->xy)   
						when(finalprintphse push(finalprintphse finalprintphselst))
					)
		)
	)
)

red = listnindex(axlColorGet('all), '(0 255 0)) || 7
;Pin highlight
swappinhigh = nil
swappinhigh = append(swaplist3 NCpinchklistfinal) 
foreach(swaplist3lp swappinhigh
	swaplist3lpprse = nth(0 parseString(swaplist3lp ","))
		foreach(swaplist3loop setof(comps axlDBGetDesign() ->components comps->symbol)
			foreach(swaplist3lprnt swaplist3loop->pins
					swaplist3lprnthigh = sprintf(nil "%s%s%s" swaplist3lprnt->parent->refdes, ".", swaplist3lprnt->number)
					if(swaplist3lprnthigh == swaplist3lpprse then					
					axlCustomColorObject(swaplist3lprnt, red)
				)								
			)
		)	
)

;net highlight
nethigh = nil
nethigh = append(unroutedlist commonswap)

foreach(nethighlp nethigh
	nethighprse = nth(1 parseString(nethighlp ","))
		foreach(nethighget axlDBGetDesign() ->nets
			if(nethighget ->name == nethighprse then
				axlCustomColorObject(nethighget, red)
			)	
		)
)

DRCinplplist = nil
foreach(DRCinplp DRCinp
	DRCinpprse = parseString(DRCinplp ",\n")
	DRCinplpprse = nth(0 parseString(DRCinplp ",\n"))
	foreach(datainplist2lp datainplist2
		if(datainplist2lp == DRCinplpprse then			
			DRCoutp = sprintf(nil, "%s,%s,%s", nth(0 DRCinpprse) || "NIL", nth(1 DRCinpprse) || "NIL", nth(2 DRCinpprse) || "NIL")
			when(DRCoutp push(DRCoutp DRCinplplist))
		)
	)
)
DRCfinalptunq = nil
DRCfinalptunq = unique(DRCinplplist)


if(finalprintphselst == nil then
	swaplistreportprnt = sprintf(nil "%s%s%s", "Swap-List-", userinptwounqlp, ".CSV")
	swaplistreport = outfile(swaplistreportprnt)
	fprintf(swaplistreport, "%s,%s,%s\n", "PIN NO", "OLD NET NAME", "NEW NET NAME")
	swaplistreportapp = append(DRCfinalptunq routedlistunqlpprntlistnxt)
		foreach(nilswaplp swaplistreportapp
			fprintf(swaplistreport, "%s\n", nilswaplp)
		)
	close(swaplistreport)
	axlUIConfirm("No Error SwapList-Report.csv Report Generated Successfully...")
else
	logfileprnt = sprintf(nil "%s%s%s", "Swap-List-", userinptwounqlp, ".log") 
	logfile = logfileprnt
	originalVisible=axlVisibleGet()
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	axlVisibleDesign(t)
		timeperform = fileTimeModified("SwapList.log")
		port = axlDMOpenLog(logfile)
			fprintf(port, "Design name: %s\n", design_path)
			fprintf(port, "%s\n", "------------------------------------------------")
			fprintf(port, "%-16s %-16s %-32s %-32s %-32s \n", "PIN NO", "XY LOCATION", "OLD NETNAME", "NEW NETNAME", "ERROR MESSAGE")
				foreach(finalphaselp finalprintphselst
					finalphaselpprse = parseString(finalphaselp ",") 
					fprintf(port, "%-16s %-16s %-32s %-32s %-32s \n", nth(0 finalphaselpprse), nth(4 finalphaselpprse), nth(1 finalphaselpprse), nth(2 finalphaselpprse), nth(3 finalphaselpprse)) 
				)
		axlDMClose(port)
	axlVisibleSet(originalVisible)
	logprnt = sprintf(nil "%s%s", "Swap List Of -", userinptwounqlp) 
	axlUIViewFileCreate(logfile, logprnt, nil, '(30 25), '(CENTER))
)
)
)