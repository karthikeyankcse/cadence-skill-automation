axlCmdRegister("TelesisNetupdateSec" 'TelesisNetupdateSec)
procedure(TelesisNetupdateSec()
Inp_File_browse = axlDMFileBrowse(nil t ?optFilters "Input files|*.txt|")
	Inp_File_data = axlDMFileParts(Inp_File_browse)
	Netlist_Inp_data = axlDMOpenFile("ALLEGRO_TEXT" cadr(Inp_File_data) "r") 
	Net_data_output = nil
		while(gets(Net_data_Inp_loop Netlist_Inp_data)
			Net_data_Inp_loop = car(parseString(Net_data_Inp_loop "\n"))
				when(Net_data_Inp_loop push(Net_data_Inp_loop Net_data_output))
			)
	axlDMClose(Netlist_Inp_data)

Net_data_output_rev = nil	
Net_data_output_rev = reverse(Net_data_output)

Split_net_list = nil
prog(()	
foreach(split_loop_net Net_data_output
	if(split_loop_net == "$NETS" then
		return()
	else
		when(split_loop_net push(split_loop_net Split_net_list))
	)
)
)

Split_net_list_rev = nil
Split_net_list_rev = reverse(Split_net_list) 

Split_pack_list = nil
prog(()	
foreach(split_loop_pack Net_data_output_rev
	if(split_loop_pack == "$NETS" then
		return()
	else
		when(split_loop_pack push(split_loop_pack Split_pack_list))
	)
)
)

Split_pack_list_rev = nil
Split_pack_list_rev = reverse(Split_pack_list)


out = outfile("Telesis NetList Divise.txt")
fprintf(out, "%s\n", "$PACKAGES")

foreach(Net_data_output_loop Split_pack_list_rev
	if(Net_data_output_loop != "$PACKAGES" then
		Net_data_output_prse = nth(0 parseString(Net_data_output_loop "!"))
		Net_data_output_prse_frst = nth(1 parseString(Net_data_output_loop "! ")) 
		Net_data_output_prse_sec_nxt = nth(0 parseString(Net_data_output_prse_frst ";"))
		Net_data_output_prse_trd = nth(1 parseString(Net_data_output_loop ";"))
		fprintf(out, "%s %s %s%s%s %s%s\n", Net_data_output_prse,"!", "'", Net_data_output_prse_sec_nxt, "'", ";", Net_data_output_prse_trd)
	)
)

Net_command = "False"
fprintf(out, "%s\n", "$NETS")
foreach(Net_data_output_loop_trd Split_net_list
		Net_Comp = pcreCompile(";") 
		Net_Rep_frst = pcreReplace(Net_Comp Net_data_output_loop_trd " ;" 0)
		Net_comp_Sec = pcreCompile("  ") 
		Net_Rep_output = pcreReplace(Net_comp_Sec Net_Rep_frst " " 0)
		fprintf(out, "%s\n", Net_Rep_output)
)
close(out)
axlUIConfirm( "Telesis NetList Report Generated Successfully.." )
)