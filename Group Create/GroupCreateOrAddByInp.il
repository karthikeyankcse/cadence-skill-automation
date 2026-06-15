axlCmdRegister("GroupCreateOrAddByInp" 'GroupCreateOrAddByInp)
procedure(GroupCreateOrAddByInp()
axlShell("Done")
axlMsgPut("--- Create or Add Members in Group ---")
axlUIConfirm( "Please Select The Input to Create or Add Members in Group..." )
GrpList = nil
ErrorList = nil
GRPBrow = axlDMFileBrowse(nil nil ?optFilters "Input files (*.csv)|*.csv|")
when(GRPBrow
    GRPOpenFile = axlDMFileParts(GRPBrow)
    when(GRPOpenFile
        filePath = strcat(car(GRPOpenFile) "/" caddr(GRPOpenFile))
        GRPDataInFile = axlDMOpenFile("ALLEGRO_TEXT" filePath "r")
        when(GRPDataInFile
            while(gets(GRPInp_Val GRPDataInFile)
                GRPInp_Val = car(parseString(GRPInp_Val "\n"))
                GRPInp_Val = car(parseString(GRPInp_Val "\357\273\277"))
                GRPInp_ValFilt = nth(1 parseString(GRPInp_Val ","))
                if(GRPInp_ValFilt != nil then
                    GRPInp_Val = upperCase(GRPInp_Val)
                    when(GRPInp_Val push(GRPInp_Val GrpList))
                else
                    ErrorDt = sprintf(nil "%s - Error : Group Name Or Refdes Not Found In Input", GRPInp_Val)
                    when(ErrorDt push(ErrorDt ErrorList))
                )
            )
            axlDMClose(GRPDataInFile)
        )
    )
)

GrpList = unique(GrpList)

DuplicateList = nil
foreach(GrpListlp GrpList
    if(length(setof(ell GrpList nth(0 parseString(ell ",")) == nth(0 parseString(GrpListlp ",")))) > 1 then
        when(GrpListlp push(GrpListlp DuplicateList))
        DupRef = nth(0 parseString(GrpListlp ","))
        ErrorDt = sprintf(nil "%s - Error : Duplicate -- Refdes Found in Multiple Group in Input List", DupRef)
        when(ErrorDt push(ErrorDt ErrorList))
    )
)

GrpList = setof(item, GrpList, !member(item, DuplicateList))


UpdatedList = nil

BrdGrpList = nil
foreach(GrpDt axlDBGetDesign()->groups
    BrdGrpName = GrpDt->name
    BrdGrpName = upperCase(BrdGrpName)
    when(BrdGrpName push(BrdGrpName BrdGrpList))
    foreach(MemLp GrpDt->groupMembers
        MemRef = MemLp->refdes
        foreach(DelListlp GrpList
            DelRefName = upperCase(nth(0 parseString(DelListlp ",")))
            UpGrpName = upperCase(nth(1 parseString(DelListlp ",")))
            if(DelRefName == MemRef then
                axlDBRemoveGroupObjects(GrpDt MemLp)
                if(BrdGrpName != UpGrpName then
                    UpdatedDt = sprintf(nil "%s --- %s Group Updated to --> %s", DelRefName, BrdGrpName, UpGrpName)
                    when(UpdatedDt push(UpdatedDt UpdatedList))
                )
            )
        )
    )
)
BrdGrpList = unique(BrdGrpList)
axlDBRefreshId(nil)

GrpNameList = nil
GrpAllList = nil
foreach(GrpListlp GrpList
    GrpListlpFilt = nth(1 parseString(GrpListlp ","))
    if(GrpListlpFilt != nil then
        GrpListlpFilt = upperCase(GrpListlpFilt)
        GrpListlp = upperCase(GrpListlp)
        when(GrpListlpFilt push(GrpListlpFilt GrpNameList))
        when(GrpListlp push(GrpListlp GrpAllList))
    )
)
GrpNameList = unique(GrpNameList)
GrpAllList = unique(GrpAllList)

ToCreateGrpList = setof(item, GrpNameList, !member(item, BrdGrpList))

foreach(ToCreateGrpListlp ToCreateGrpList
    Dbid = axlDBCreateGroup(ToCreateGrpListlp "generic" nil)
)
axlDBRefreshId(nil)


UpdatedList1 = nil

foreach(ToCreateGrpListlp GrpNameList
    MemList = nil
    foreach(GrpAllListlp GrpAllList
        GrpRefFilt = nth(0 parseString(GrpAllListlp ","))
        GrpNameFilt = nth(1 parseString(GrpAllListlp ","))
        if(GrpNameFilt == ToCreateGrpListlp then 
            RefId = axlDBFindByName('refdes GrpRefFilt)
            if(RefId != nil then
                SymRefId = RefId->symbol
                ;foreach(GrpDtDel axlDBGetDesign()->groups
                    ;foreach(MemLp GrpDtDel->groupMembers
                        ;MemRef = MemLp->refdes
                        ;if(GrpRefFilt == MemRef then
                            ;axlDBRemoveGroupObjects(GrpDtDel MemLp)
                        ;)
                    ;)
                ;)
                when(SymRefId push(SymRefId MemList))

                UpdatedDt1 = sprintf(nil "%s --- Added Group --> %s", GrpRefFilt, GrpNameFilt)
                when(UpdatedDt1 push(UpdatedDt1 UpdatedList1))

            else
                ErrorDt = sprintf(nil "%s - Error : Refdes Not Found", GrpRefFilt)
                when(ErrorDt push(ErrorDt ErrorList))
            )
        )
    )
    MemList = unique(MemList)
    foreach(GrpDt axlDBGetDesign()->groups
        BrdGrpName = GrpDt->name
        BrdGrpName = upperCase(BrdGrpName)
        if(BrdGrpName == ToCreateGrpListlp then
            GrbObj = axlDBAddGroupObjects(GrpDt MemList)
        )
    )
    axlDBRefreshId(nil)
)

ErrorList = unique(ErrorList)
UpdatedList1 = unique(UpdatedList1)
UpdatedList = unique(UpdatedList)

Comb = append(ErrorList UpdatedList1)
CombinedList = append(UpdatedList Comb)

ExistGrp = length(GrpNameList) - length(ToCreateGrpList)
axlShell("Done")

if(CombinedList != nil then
	logfile = "GrpCrctAndAddByinp.log"
	designName = axlCurrentDesign()
	design_path = axlGetDrawingName()
	design_unit = car(axlDBGetDesignUnits())
	port = axlDMOpenLog(logfile)
	fprintf(port, "Design name: %s\n", design_path)
	fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	fprintf(port, "%s%d\n\n", "TOTAL NUMBER OF GROUP AS PER INPUT : ", length(GrpNameList))
    fprintf(port, "%s%d\n\n", "TOTAL NUMBER OF GROUP NEWLY CREATED : ", length(ToCreateGrpList))
    fprintf(port, "%s%d\n\n", "TOTAL NUMBER OF ALREADY EXIST GROUP : ", ExistGrp)
    fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	if(ErrorList != nil then
		fprintf(port, "%s\n\n", "ERROR LIST :")
		foreach(ErrorListlp ErrorList 
			fprintf(port, "%-25s  \n", ErrorListlp)
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO ERROR FOUND..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(UpdatedList != nil then
		fprintf(port, "%s\n\n", "UPDATED GROUP LIST :")
        fprintf(port, "%s%d\n\n", "TOTAL NUMBER OF UPDATED GROUP LIST : ", length(UpdatedList))
		foreach(UpdatedListlp UpdatedList
			fprintf(port, "%-25s \n", UpdatedListlp)
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO UPDATED GROUP LIST..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	
	if(UpdatedList1 != nil then
		fprintf(port, "%s\n\n", "NEWLY ADDED GROUP LIST :")
        fprintf(port, "%s%d\n\n", "TOTAL NUMBER OF ADDED GROUP LIST : ", length(UpdatedList1))
		foreach(UpdatedList1lp UpdatedList1 
			fprintf(port, "%-25s \n", UpdatedList1lp) 
		)
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	else
		fprintf(port, "%s\n", "NO SYMBOL ADDED IN GROUP..!")
		fprintf(port, "\n\n")
		fprintf(port, "%s\n\n", "---------------------------------------------------------------------------------------------------------------------------")
	)
	axlDMClose(port)
	axlUIViewFileCreate(logfile, "Group Create Or Add", nil, '(30 25), '(CENTER))
)

)