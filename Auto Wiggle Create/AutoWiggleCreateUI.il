axlCmdRegister("AutoWiggleCreateUI" 'AutoWiggleCreateUI)
(setq AutoSingleWiggle_form_file "AutoWiggleCreateUI_v2.form")

/* ============================================================ */
/* GLOBALS                                                      */
/* ============================================================ */
CSeg_objs         = nil
WiggleMark        = nil
SingleWigglePopup = nil
notdone           = nil
start             = nil
start1            = nil

UFixedDepth = 10.0   /* fixed 45-deg corner leg length (mils) */

/* ============================================================ */
/* MAIN ENTRY                                                   */
/* ============================================================ */
procedure(AutoWiggleCreateUI()
    axlShell("Done")
    if(isFile(AutoSingleWiggle_form_file) then
        deleteFile(AutoSingleWiggle_form_file)
    )
    CreateSingleAutoWiggle_form()
    RunSingleAutoWiggle_form()
)

/* ============================================================ */
/* FORM RUN                                                     */
/* ============================================================ */
procedure(RunSingleAutoWiggle_form()
    let((SingleAutoWiggle_form)
        SingleAutoWiggle_form = axlFormCreate(gensym() AutoSingleWiggle_form_file nil 'SingleAutoWiggle_Action t)
        axlFormDisplay(SingleAutoWiggle_form)
    )
)

/* ============================================================ */
/* FORM CREATE                                                  */
/*                                                              */
/*  RADVAL  = Radius (ARC) / Flat-Top Len (45) / TopLen (U)    */
/*  AIRVAL  = Airgap (all modes)                                */
/*  OBJFLD  = ARC | 45 DEG | U SHAPE                           */
/*                                                              */
/*  U-SHAPE:                                                    */
/*    CL      = UFixedDepth = 10 mil  (fixed 45° corner leg)   */
/*    Depth   = Airgap + TraceWidth - CL - 10  (calc after sel)*/
/*    TopLen  = RADVAL                                          */
/*    HorizSpan = 4*10 + TopLen  (auto)                        */
/* ============================================================ */
procedure(CreateSingleAutoWiggle_form()
    let((SingleAutoWiggle_form)
        SingleAutoWiggle_form = outfile(AutoSingleWiggle_form_file "w")

        fprintf(SingleAutoWiggle_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(SingleAutoWiggle_form "FORM\n")
        fprintf(SingleAutoWiggle_form "FIXED\n")
        fprintf(SingleAutoWiggle_form "PORT 48 55\n")
        fprintf(SingleAutoWiggle_form "HEADER \"Auto Wiggle Create\"\n")
        fprintf(SingleAutoWiggle_form "\n")
        fprintf(SingleAutoWiggle_form "TILE\n")

        fprintf(SingleAutoWiggle_form "TEXT \" RADIUS / FLAT-TOP LEN    >>> \"\n")
        fprintf(SingleAutoWiggle_form "TLOC 1 2\n")
        fprintf(SingleAutoWiggle_form "ENDTEXT\n")
        fprintf(SingleAutoWiggle_form "FIELD %s\n" "RADVAL")
        fprintf(SingleAutoWiggle_form "FLOC 30 2\n")
        fprintf(SingleAutoWiggle_form "STRFILLIN 10 5\n")
        fprintf(SingleAutoWiggle_form "ENDFIELD\n")
        fprintf(SingleAutoWiggle_form "\n")

        fprintf(SingleAutoWiggle_form "TEXT \" AIRGAP VALUE              >>> \"\n")
        fprintf(SingleAutoWiggle_form "TLOC 1 5\n")
        fprintf(SingleAutoWiggle_form "ENDTEXT\n")
        fprintf(SingleAutoWiggle_form "FIELD %s\n" "AIRVAL")
        fprintf(SingleAutoWiggle_form "FLOC 30 5\n")
        fprintf(SingleAutoWiggle_form "STRFILLIN 10 5\n")
        fprintf(SingleAutoWiggle_form "ENDFIELD\n")
        fprintf(SingleAutoWiggle_form "\n")

        fprintf(SingleAutoWiggle_form "TEXT \" CHOOSE MODE              >>> \"\n")
        fprintf(SingleAutoWiggle_form "TLOC 1 8\n")
        fprintf(SingleAutoWiggle_form "ENDTEXT\n")
        fprintf(SingleAutoWiggle_form "POPUP <OBJ>\"ARC\"\"ARC\",\"45 DEG\"\"45 DEG\",\"U SHAPE\"\"U SHAPE\".\n")
        fprintf(SingleAutoWiggle_form "FIELD OBJFLD\n")
        fprintf(SingleAutoWiggle_form "FLOC 30 8\n")
        fprintf(SingleAutoWiggle_form "ENUMSET 9\n")
        fprintf(SingleAutoWiggle_form "POP \"OBJ\"\n")
        fprintf(SingleAutoWiggle_form "ENDFIELD\n")
        fprintf(SingleAutoWiggle_form "\n")

        fprintf(SingleAutoWiggle_form "FIELD PROC\n")
        fprintf(SingleAutoWiggle_form "FLOC 10 12\n")
        fprintf(SingleAutoWiggle_form "MENUBUTTON \"CLICK HERE TO PROCEED..!\" 20 4\n")
        fprintf(SingleAutoWiggle_form "ENDFIELD\n")
        fprintf(SingleAutoWiggle_form "\n")

        fprintf(SingleAutoWiggle_form "ENDTILE\n")
        fprintf(SingleAutoWiggle_form "\n")
        fprintf(SingleAutoWiggle_form "ENDFORM\n")

        drain()
        close(SingleAutoWiggle_form)
    )
)

/* ============================================================ */
/* FORM ACTION                                                  */
/* ============================================================ */
procedure(SingleAutoWiggle_Action(SingleAutoWiggle_form)
    case((SingleAutoWiggle_form->curField)
        ("PROC"

            RadVal = axlFormGetField(SingleAutoWiggle_form "RADVAL")
            AirVal = axlFormGetField(SingleAutoWiggle_form "AIRVAL")
            Obj    = axlFormGetField(SingleAutoWiggle_form "OBJFLD")

            if(RadVal == "" || AirVal == "" || Obj == "" then
                axlUIConfirm("Error : All fields are required.")
                axlFormDisplay(SingleAutoWiggle_form)
                return()
            )

            RadVal = atof(RadVal)
            AirVal = atof(AirVal)

            Use45     = (Obj == "45 DEG")
            UseUshape = (Obj == "U SHAPE")

            /* ---- Validate & prepare per mode ---- */
            if(UseUshape then

                /* U-SHAPE:
                   RADVAL  = TopLen  (bottom flat segment)
                   AIRVAL  = Airgap  (baseline to top-flat edge-to-edge)
                   CL      = 10 mil fixed (45° corner leg)
                   Depth   = calculated after trace selected (needs TraceWidth)   */
                UBotWidth = RadVal
                UCL       = UFixedDepth
                UAirVal   = AirVal

                if(UBotWidth < 0.0 then
                    axlUIConfirm("Error : Top/Bottom Flat length must be >= 0")
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )

                if(UAirVal <= 0.0 then
                    axlUIConfirm("Error : Airgap must be > 0")
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )

                UHorizSpan = (4.0 * UCL) + UBotWidth

                axlUIWPrint(nil sprintf(nil
                    "U-SHAPE: TopLen=%.4f  Airgap=%.4f  CornerLeg=%.4f  HorizSpan=%.4f"
                    UBotWidth UAirVal UCL UHorizSpan))

            else if(Use45 then

                FlatLen = RadVal
                LegH    = AirVal / 2.0

                if(FlatLen < 0.0 then
                    axlUIConfirm("Error : Flat-Top Length must be >= 0")
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )
                if(LegH <= 0.0 then
                    axlUIConfirm("Error : Airgap must be > 0")
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )

                axlUIWPrint(nil sprintf(nil
                    "45-DEG: FlatLen=%.4f  PeakHeight=%.4f  LegH=%.4f"
                    FlatLen AirVal LegH))

            else

                Rad        = RadVal
                Gap        = AirVal
                TopFlatLen = 0

                if(Rad <= 0 then
                    axlUIConfirm("Error : Radius must be > 0")
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )
                if(Gap <= 0 then
                    axlUIConfirm("Error : Airgap must be > 0")
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )
                if(Gap > (2 * Rad) then
                    axlUIConfirm(sprintf(nil
                        "Gap %.4f not possible with Radius %.4f. Max = %.4f"
                        Gap Rad (2 * Rad)))
                    axlFormDisplay(SingleAutoWiggle_form)
                    return()
                )

                Ratio    = 1.0 - (Gap / (2.0 * Rad))
                ThetaRad = acos(Ratio)
                ThetaDeg = ThetaRad * 180.0 / 3.14159265358979
                dx       = Rad * sin(ThetaRad)
                dy       = Rad * (1.0 - cos(ThetaRad))

                axlUIWPrint(nil sprintf(nil
                    "ARC: Radius=%.4f  Gap=%.4f  Angle=%.2f  dx=%.4f  dy=%.4f"
                    Rad Gap ThetaDeg dx dy))
            )
            )

            /* ---- Setup popup + transaction ---- */
            CSeg_objs         = nil
            WiggleMark        = nil
            SingleWigglePopup = nil
            notdone           = nil
            start             = nil
            start1            = nil

            axlSetFindFilter(?enabled '("NOALL" "CLINESEGS")
                             ?onButtons '("CLINESEGS"))
            axlControlRaise('find)

            SingleWigglePopup = axlUIPopupDefine(nil
                (list
                    (list "Done"   'SingleWiggleDone)
                    (list "Oops"   'SingleWiggleOops)
                    (list "Cancel" 'SingleWiggleCancel)
                )
            )
            axlUIPopupSet(SingleWigglePopup)

            notdone = t
            start1  = axlDBTransactionStart()
            axlDBTransactionMark(start1)

            while(notdone

                axlClearSelSet()
                axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
                CSeg_objs = axlGetSelSet(axlSelect(?groupMode nil ?prompt "Select Cline Segment..!"))
                start = axlDBTransactionStart()

                if(CSeg_objs then
                    axlDBTransactionMark(start)
                    axlClearSelSet()

                    print("Please Pick a point to create wiggle...!")
                    event1 = axlEnterEvent(list('PICK) nil t)
                    WigglePoint = event1->xy

                    print("Please Pick a Side to create wiggle...!")
                    event2 = axlEnterEvent(list('PICK) nil t)
                    SidePoint = event2->xy

                    Linetypeval = car(CSeg_objs)->lineType
                    linevalstr  = sprintf(nil "%s" Linetypeval)

                    CSegXY = car(CSeg_objs)->startEnd
                    CSegX  = nth(0 CSegXY)
                    CSegY  = nth(1 CSegXY)

                    FirstX = car(CSegX)   FirstY = cadr(CSegX)
                    SecX   = car(CSegY)   SecY   = cadr(CSegY)

                    CSegWid = car(CSeg_objs)->width
                    CSegLyr = car(CSeg_objs)->layer

                    WigglePointX = car(WigglePoint)
                    WigglePointY = cadr(WigglePoint)
                    SidePointX   = car(SidePoint)
                    SidePointY   = cadr(SidePoint)

                    if(UseUshape then
                        /* Depth calculation:
                           Allegro AirGap = (CL + Depth) - TraceWidth
                           => Depth = AirGap + TraceWidth - CL - 10     */
                        UDepth_actual = UAirVal + CSegWid - UCL - 10.0

                        if(UDepth_actual <= 0.0 then
                            axlUIConfirm(sprintf(nil
                                "Error: Airgap %.4f too small. Increase airgap value."
                                UAirVal))
                            return()
                        )

                        axlUIWPrint(nil sprintf(nil
                            "U-SHAPE DRAW: CL=%.4f  TraceWid=%.4f  SideLeg=%.4f  TotalDy=%.4f  AllegroAirGap=%.4f"
                            UCL CSegWid UDepth_actual (UCL + UDepth_actual) (UCL + UDepth_actual - CSegWid)))

                        SingleCreateWiggleU(linevalstr WigglePointX WigglePointY
                                            SidePointX SidePointY
                                            FirstX FirstY SecX SecY
                                            CSegWid CSegLyr
                                            UCL UDepth_actual UBotWidth)

                    else if(Use45 then
                        SingleCreateWiggle45(linevalstr WigglePointX WigglePointY
                                             SidePointX SidePointY
                                             FirstX FirstY SecX SecY
                                             CSegWid CSegLyr LegH FlatLen)
                    else
                        SingleCreateWiggleArc(linevalstr WigglePointX WigglePointY
                                              SidePointX SidePointY
                                              FirstX FirstY SecX SecY
                                              CSegWid CSegLyr Rad Gap dx dy ThetaDeg TopFlatLen)
                    )
                    )
                )
            )
        )
    )
    axlFormDisplay(SingleAutoWiggle_form)
)

/* ============================================================ */
/* CREATE ARC WIGGLE                                            */
/* ============================================================ */
procedure(SingleCreateWiggleArc(linevalstr WigglePointX WigglePointY
                                SidePointX SidePointY
                                FirstX FirstY SecX SecY
                                CSegWid CSegLyr Rad Gap dx dy ThetaDeg TopFlatLen)
    prog(()
        if(linevalstr == "horizontal" then
            C1PointX = WigglePointX
            C1PointY = FirstY
            if(SidePointY > WigglePointY then
                C2PointX = C1PointX + dx   C2PointY = C1PointY + dy
                path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_1 CSegLyr)
                C3PointX = C2PointX + dx   C3PointY = C2PointY + dy
                path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY t ThetaDeg)
                axlDBCreatePath(path_arc_2 CSegLyr)
                MidLineStartX = C3PointX  MidLineStartY = C3PointY
                MidLineEndX = MidLineStartX + TopFlatLen  MidLineEndY = MidLineStartY
                if(TopFlatLen > 0 then
                    path_mid = axlPathStart(list(MidLineStartX:MidLineStartY) CSegWid)
                    axlPathLine(path_mid CSegWid MidLineEndX:MidLineEndY)
                    axlDBCreatePath(path_mid CSegLyr)
                )
                C4PointX = MidLineEndX + dx  C4PointY = MidLineEndY - dy
                path_arc_3 = axlPathStart(list(MidLineEndX:MidLineEndY) CSegWid)
                axlPathArcAngle(path_arc_3 CSegWid C4PointX:C4PointY t ThetaDeg)
                axlDBCreatePath(path_arc_3 CSegLyr)
                C5PointX = C4PointX + dx  C5PointY = C4PointY - dy
                path_arc_4 = axlPathStart(list(C4PointX:C4PointY) CSegWid)
                axlPathArcAngle(path_arc_4 CSegWid C5PointX:C5PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_4 CSegLyr)
            else
                C2PointX = C1PointX + dx   C2PointY = C1PointY - dy
                path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY t ThetaDeg)
                axlDBCreatePath(path_arc_1 CSegLyr)
                C3PointX = C2PointX + dx   C3PointY = C2PointY - dy
                path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_2 CSegLyr)
                MidLineStartX = C3PointX  MidLineStartY = C3PointY
                MidLineEndX = MidLineStartX + TopFlatLen  MidLineEndY = MidLineStartY
                if(TopFlatLen > 0 then
                    path_mid = axlPathStart(list(MidLineStartX:MidLineStartY) CSegWid)
                    axlPathLine(path_mid CSegWid MidLineEndX:MidLineEndY)
                    axlDBCreatePath(path_mid CSegLyr)
                )
                C4PointX = MidLineEndX + dx  C4PointY = MidLineEndY + dy
                path_arc_3 = axlPathStart(list(MidLineEndX:MidLineEndY) CSegWid)
                axlPathArcAngle(path_arc_3 CSegWid C4PointX:C4PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_3 CSegLyr)
                C5PointX = C4PointX + dx  C5PointY = C4PointY + dy
                path_arc_4 = axlPathStart(list(C4PointX:C4PointY) CSegWid)
                axlPathArcAngle(path_arc_4 CSegWid C5PointX:C5PointY t ThetaDeg)
                axlDBCreatePath(path_arc_4 CSegLyr)
            )
        else
            if(linevalstr == "vertical" then
                C1PointX = FirstX
                C1PointY = WigglePointY
                if(SidePointX < WigglePointX then
                    C2PointX = C1PointX - dy   C2PointY = C1PointY + dx
                    path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                    axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY nil ThetaDeg)
                    axlDBCreatePath(path_arc_1 CSegLyr)
                    C3PointX = C2PointX - dy   C3PointY = C2PointY + dx
                    path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                    axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY t ThetaDeg)
                    axlDBCreatePath(path_arc_2 CSegLyr)
                    MidLineStartX = C3PointX  MidLineStartY = C3PointY
                    MidLineEndX = MidLineStartX  MidLineEndY = MidLineStartY + TopFlatLen
                    if(TopFlatLen > 0 then
                        path_mid = axlPathStart(list(MidLineStartX:MidLineStartY) CSegWid)
                        axlPathLine(path_mid CSegWid MidLineEndX:MidLineEndY)
                        axlDBCreatePath(path_mid CSegLyr)
                    )
                    C4PointX = MidLineEndX + dy  C4PointY = MidLineEndY + dx
                    path_arc_3 = axlPathStart(list(MidLineEndX:MidLineEndY) CSegWid)
                    axlPathArcAngle(path_arc_3 CSegWid C4PointX:C4PointY t ThetaDeg)
                    axlDBCreatePath(path_arc_3 CSegLyr)
                    C5PointX = C4PointX + dy  C5PointY = C4PointY + dx
                    path_arc_4 = axlPathStart(list(C4PointX:C4PointY) CSegWid)
                    axlPathArcAngle(path_arc_4 CSegWid C5PointX:C5PointY nil ThetaDeg)
                    axlDBCreatePath(path_arc_4 CSegLyr)
                else
                    C2PointX = C1PointX + dy   C2PointY = C1PointY + dx
                    path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                    axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY t ThetaDeg)
                    axlDBCreatePath(path_arc_1 CSegLyr)
                    C3PointX = C2PointX + dy   C3PointY = C2PointY + dx
                    path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                    axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY nil ThetaDeg)
                    axlDBCreatePath(path_arc_2 CSegLyr)
                    MidLineStartX = C3PointX  MidLineStartY = C3PointY
                    MidLineEndX = MidLineStartX  MidLineEndY = MidLineStartY + TopFlatLen
                    if(TopFlatLen > 0 then
                        path_mid = axlPathStart(list(MidLineStartX:MidLineStartY) CSegWid)
                        axlPathLine(path_mid CSegWid MidLineEndX:MidLineEndY)
                        axlDBCreatePath(path_mid CSegLyr)
                    )
                    C4PointX = MidLineEndX - dy  C4PointY = MidLineEndY + dx
                    path_arc_3 = axlPathStart(list(MidLineEndX:MidLineEndY) CSegWid)
                    axlPathArcAngle(path_arc_3 CSegWid C4PointX:C4PointY nil ThetaDeg)
                    axlDBCreatePath(path_arc_3 CSegLyr)
                    C5PointX = C4PointX - dy  C5PointY = C4PointY + dx
                    path_arc_4 = axlPathStart(list(C4PointX:C4PointY) CSegWid)
                    axlPathArcAngle(path_arc_4 CSegWid C5PointX:C5PointY t ThetaDeg)
                    axlDBCreatePath(path_arc_4 CSegLyr)
                )
            )
        )
        SingleDeleteSpan(C1PointX C1PointY C5PointX C5PointY)
    )
)

/* ============================================================ */
/* CREATE 45-DEG TRAPEZOID WIGGLE                               */
/* ============================================================ */
procedure(SingleCreateWiggle45(linevalstr WigglePointX WigglePointY
                               SidePointX SidePointY
                               FirstX FirstY SecX SecY
                               CSegWid CSegLyr LegH FlatLen)
    prog(()
        if(linevalstr == "horizontal" then
            C1X = WigglePointX  C1Y = FirstY
            if(SidePointY > WigglePointY then
                C2X = C1X + LegH   C2Y = C1Y + LegH
                p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                axlPathLine(p1 CSegWid C2X:C2Y)
                axlDBCreatePath(p1 CSegLyr)
                C3X = C2X + LegH   C3Y = C2Y + LegH
                p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                axlPathLine(p2 CSegWid C3X:C3Y)
                axlDBCreatePath(p2 CSegLyr)
                C4X = C3X + FlatLen  C4Y = C3Y
                if(FlatLen > 0 then
                    pT = axlPathStart(list(C3X:C3Y) CSegWid)
                    axlPathLine(pT CSegWid C4X:C4Y)
                    axlDBCreatePath(pT CSegLyr)
                )
                C5X = C4X + LegH   C5Y = C4Y - LegH
                p3 = axlPathStart(list(C4X:C4Y) CSegWid)
                axlPathLine(p3 CSegWid C5X:C5Y)
                axlDBCreatePath(p3 CSegLyr)
                C6X = C5X + LegH   C6Y = C5Y - LegH
                p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                axlPathLine(p4 CSegWid C6X:C6Y)
                axlDBCreatePath(p4 CSegLyr)
            else
                C2X = C1X + LegH   C2Y = C1Y - LegH
                p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                axlPathLine(p1 CSegWid C2X:C2Y)
                axlDBCreatePath(p1 CSegLyr)
                C3X = C2X + LegH   C3Y = C2Y - LegH
                p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                axlPathLine(p2 CSegWid C3X:C3Y)
                axlDBCreatePath(p2 CSegLyr)
                C4X = C3X + FlatLen  C4Y = C3Y
                if(FlatLen > 0 then
                    pT = axlPathStart(list(C3X:C3Y) CSegWid)
                    axlPathLine(pT CSegWid C4X:C4Y)
                    axlDBCreatePath(pT CSegLyr)
                )
                C5X = C4X + LegH   C5Y = C4Y + LegH
                p3 = axlPathStart(list(C4X:C4Y) CSegWid)
                axlPathLine(p3 CSegWid C5X:C5Y)
                axlDBCreatePath(p3 CSegLyr)
                C6X = C5X + LegH   C6Y = C5Y + LegH
                p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                axlPathLine(p4 CSegWid C6X:C6Y)
                axlDBCreatePath(p4 CSegLyr)
            )
        else
            if(linevalstr == "vertical" then
                C1X = FirstX  C1Y = WigglePointY
                if(SidePointX < WigglePointX then
                    C2X = C1X - LegH   C2Y = C1Y + LegH
                    p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                    axlPathLine(p1 CSegWid C2X:C2Y)
                    axlDBCreatePath(p1 CSegLyr)
                    C3X = C2X - LegH   C3Y = C2Y + LegH
                    p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                    axlPathLine(p2 CSegWid C3X:C3Y)
                    axlDBCreatePath(p2 CSegLyr)
                    C4X = C3X   C4Y = C3Y + FlatLen
                    if(FlatLen > 0 then
                        pT = axlPathStart(list(C3X:C3Y) CSegWid)
                        axlPathLine(pT CSegWid C4X:C4Y)
                        axlDBCreatePath(pT CSegLyr)
                    )
                    C5X = C4X + LegH   C5Y = C4Y + LegH
                    p3 = axlPathStart(list(C4X:C4Y) CSegWid)
                    axlPathLine(p3 CSegWid C5X:C5Y)
                    axlDBCreatePath(p3 CSegLyr)
                    C6X = C5X + LegH   C6Y = C5Y + LegH
                    p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                    axlPathLine(p4 CSegWid C6X:C6Y)
                    axlDBCreatePath(p4 CSegLyr)
                else
                    C2X = C1X + LegH   C2Y = C1Y + LegH
                    p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                    axlPathLine(p1 CSegWid C2X:C2Y)
                    axlDBCreatePath(p1 CSegLyr)
                    C3X = C2X + LegH   C3Y = C2Y + LegH
                    p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                    axlPathLine(p2 CSegWid C3X:C3Y)
                    axlDBCreatePath(p2 CSegLyr)
                    C4X = C3X   C4Y = C3Y + FlatLen
                    if(FlatLen > 0 then
                        pT = axlPathStart(list(C3X:C3Y) CSegWid)
                        axlPathLine(pT CSegWid C4X:C4Y)
                        axlDBCreatePath(pT CSegLyr)
                    )
                    C5X = C4X - LegH   C5Y = C4Y + LegH
                    p3 = axlPathStart(list(C4X:C4Y) CSegWid)
                    axlPathLine(p3 CSegWid C5X:C5Y)
                    axlDBCreatePath(p3 CSegLyr)
                    C6X = C5X - LegH   C6Y = C5Y + LegH
                    p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                    axlPathLine(p4 CSegWid C6X:C6Y)
                    axlDBCreatePath(p4 CSegLyr)
                )
            )
        )
        SingleDeleteSpan(C1X C1Y C6X C6Y)
    )
)

/* ============================================================ */
/* CREATE U-SHAPE WIGGLE                                        */
/* ============================================================ */
procedure(SingleCreateWiggleU(linevalstr WigglePointX WigglePointY
                              SidePointX SidePointY
                              FirstX FirstY SecX SecY
                              CSegWid CSegLyr
                              CL Depth BotWidth)
    prog(()
        if(linevalstr == "horizontal" then
            C1X = WigglePointX
            C1Y = FirstY

            if(SidePointY < WigglePointY then
                /* ======== HORIZONTAL BOTTOM ======== */
                C2X = C1X + CL      C2Y = C1Y - CL
                p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                axlPathLine(p1 CSegWid C2X:C2Y)
                axlDBCreatePath(p1 CSegLyr)

                C3X = C2X           C3Y = C2Y - Depth
                p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                axlPathLine(p2 CSegWid C3X:C3Y)
                axlDBCreatePath(p2 CSegLyr)

                C4X = C3X + CL      C4Y = C3Y - CL
                p3 = axlPathStart(list(C3X:C3Y) CSegWid)
                axlPathLine(p3 CSegWid C4X:C4Y)
                axlDBCreatePath(p3 CSegLyr)

                C5X = C4X + BotWidth  C5Y = C4Y
                if(BotWidth > 0 then
                    pB = axlPathStart(list(C4X:C4Y) CSegWid)
                    axlPathLine(pB CSegWid C5X:C5Y)
                    axlDBCreatePath(pB CSegLyr)
                )

                C6X = C5X + CL      C6Y = C5Y + CL
                p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                axlPathLine(p4 CSegWid C6X:C6Y)
                axlDBCreatePath(p4 CSegLyr)

                C7X = C6X           C7Y = C6Y + Depth
                p5 = axlPathStart(list(C6X:C6Y) CSegWid)
                axlPathLine(p5 CSegWid C7X:C7Y)
                axlDBCreatePath(p5 CSegLyr)

                C8X = C7X + CL      C8Y = C7Y + CL
                p6 = axlPathStart(list(C7X:C7Y) CSegWid)
                axlPathLine(p6 CSegWid C8X:C8Y)
                axlDBCreatePath(p6 CSegLyr)

            else
                /* ======== HORIZONTAL TOP ======== */
                C2X = C1X + CL      C2Y = C1Y + CL
                p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                axlPathLine(p1 CSegWid C2X:C2Y)
                axlDBCreatePath(p1 CSegLyr)

                C3X = C2X           C3Y = C2Y + Depth
                p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                axlPathLine(p2 CSegWid C3X:C3Y)
                axlDBCreatePath(p2 CSegLyr)

                C4X = C3X + CL      C4Y = C3Y + CL
                p3 = axlPathStart(list(C3X:C3Y) CSegWid)
                axlPathLine(p3 CSegWid C4X:C4Y)
                axlDBCreatePath(p3 CSegLyr)

                C5X = C4X + BotWidth  C5Y = C4Y
                if(BotWidth > 0 then
                    pB = axlPathStart(list(C4X:C4Y) CSegWid)
                    axlPathLine(pB CSegWid C5X:C5Y)
                    axlDBCreatePath(pB CSegLyr)
                )

                C6X = C5X + CL      C6Y = C5Y - CL
                p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                axlPathLine(p4 CSegWid C6X:C6Y)
                axlDBCreatePath(p4 CSegLyr)

                C7X = C6X           C7Y = C6Y - Depth
                p5 = axlPathStart(list(C6X:C6Y) CSegWid)
                axlPathLine(p5 CSegWid C7X:C7Y)
                axlDBCreatePath(p5 CSegLyr)

                C8X = C7X + CL      C8Y = C7Y - CL
                p6 = axlPathStart(list(C7X:C7Y) CSegWid)
                axlPathLine(p6 CSegWid C8X:C8Y)
                axlDBCreatePath(p6 CSegLyr)
            )

        else
            if(linevalstr == "vertical" then
                C1X = FirstX
                C1Y = WigglePointY

                if(SidePointX < WigglePointX then
                    /* ======== VERTICAL LEFT ======== */
                    C2X = C1X - CL      C2Y = C1Y + CL
                    p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                    axlPathLine(p1 CSegWid C2X:C2Y)
                    axlDBCreatePath(p1 CSegLyr)

                    C3X = C2X - Depth   C3Y = C2Y
                    p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                    axlPathLine(p2 CSegWid C3X:C3Y)
                    axlDBCreatePath(p2 CSegLyr)

                    C4X = C3X - CL      C4Y = C3Y + CL
                    p3 = axlPathStart(list(C3X:C3Y) CSegWid)
                    axlPathLine(p3 CSegWid C4X:C4Y)
                    axlDBCreatePath(p3 CSegLyr)

                    C5X = C4X           C5Y = C4Y + BotWidth
                    if(BotWidth > 0 then
                        pB = axlPathStart(list(C4X:C4Y) CSegWid)
                        axlPathLine(pB CSegWid C5X:C5Y)
                        axlDBCreatePath(pB CSegLyr)
                    )

                    C6X = C5X + CL      C6Y = C5Y + CL
                    p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                    axlPathLine(p4 CSegWid C6X:C6Y)
                    axlDBCreatePath(p4 CSegLyr)

                    C7X = C6X + Depth   C7Y = C6Y
                    p5 = axlPathStart(list(C6X:C6Y) CSegWid)
                    axlPathLine(p5 CSegWid C7X:C7Y)
                    axlDBCreatePath(p5 CSegLyr)

                    C8X = C7X + CL      C8Y = C7Y + CL
                    p6 = axlPathStart(list(C7X:C7Y) CSegWid)
                    axlPathLine(p6 CSegWid C8X:C8Y)
                    axlDBCreatePath(p6 CSegLyr)

                else
                    /* ======== VERTICAL RIGHT ======== */
                    C2X = C1X + CL      C2Y = C1Y + CL
                    p1 = axlPathStart(list(C1X:C1Y) CSegWid)
                    axlPathLine(p1 CSegWid C2X:C2Y)
                    axlDBCreatePath(p1 CSegLyr)

                    C3X = C2X + Depth   C3Y = C2Y
                    p2 = axlPathStart(list(C2X:C2Y) CSegWid)
                    axlPathLine(p2 CSegWid C3X:C3Y)
                    axlDBCreatePath(p2 CSegLyr)

                    C4X = C3X + CL      C4Y = C3Y + CL
                    p3 = axlPathStart(list(C3X:C3Y) CSegWid)
                    axlPathLine(p3 CSegWid C4X:C4Y)
                    axlDBCreatePath(p3 CSegLyr)

                    C5X = C4X           C5Y = C4Y + BotWidth
                    if(BotWidth > 0 then
                        pB = axlPathStart(list(C4X:C4Y) CSegWid)
                        axlPathLine(pB CSegWid C5X:C5Y)
                        axlDBCreatePath(pB CSegLyr)
                    )

                    C6X = C5X - CL      C6Y = C5Y + CL
                    p4 = axlPathStart(list(C5X:C5Y) CSegWid)
                    axlPathLine(p4 CSegWid C6X:C6Y)
                    axlDBCreatePath(p4 CSegLyr)

                    C7X = C6X - Depth   C7Y = C6Y
                    p5 = axlPathStart(list(C6X:C6Y) CSegWid)
                    axlPathLine(p5 CSegWid C7X:C7Y)
                    axlDBCreatePath(p5 CSegLyr)

                    C8X = C7X - CL      C8Y = C7Y + CL
                    p6 = axlPathStart(list(C7X:C7Y) CSegWid)
                    axlPathLine(p6 CSegWid C8X:C8Y)
                    axlDBCreatePath(p6 CSegLyr)
                )
            )
        )
        SingleDeleteSpan(C1X C1Y C8X C8Y)
    )
)

/* ============================================================ */
/* HELPER : DELETE ORIGINAL STRAIGHT SPAN                       */
/* ============================================================ */
procedure(SingleDeleteSpan(StartX StartY EndX EndY)
    prog(()
        if(StartX == nil || StartY == nil || EndX == nil || EndY == nil then
            axlUIWPrint(nil "SingleDeleteSpan skipped: nil coordinate")
            return()
        )
        axlVisibleUpdate(t)
        axlClearSelSet()
        axlSetFindFilter(?enabled `("NOALL" "CLINESEGS") ?onButtons `("CLINESEGS"))
        ClineSegDel = axlGetSelSet(axlSingleSelectBox(list(StartX:StartY EndX:EndY)))
        if(ClineSegDel != nil then
            foreach(ClineSegDellp ClineSegDel
                DelCSeg = ClineSegDellp->startEnd
                if(DelCSeg && length(DelCSeg) >= 2 then
                    DelFPoint = car(DelCSeg)
                    DelSPoint = cadr(DelCSeg)
                    if(DelFPoint && DelSPoint then
                        DelFPointX = car(DelFPoint)
                        DelFPointY = cadr(DelFPoint)
                        DelSPointX = car(DelSPoint)
                        DelSPointY = cadr(DelSPoint)
                        if(DelFPointX != nil && DelFPointY != nil && DelSPointX != nil && DelSPointY != nil then
                            DelStr1 = sprintf(nil "(%.2f %.2f)(%.2f %.2f)" DelFPointX DelFPointY DelSPointX DelSPointY)
                            DelStr2 = sprintf(nil "(%.2f %.2f)(%.2f %.2f)" DelSPointX DelSPointY DelFPointX DelFPointY)
                            InpStr  = sprintf(nil "(%.2f %.2f)(%.2f %.2f)" StartX StartY EndX EndY)
                            if(DelStr1 == InpStr || DelStr2 == InpStr then
                                axlDeleteObject(ClineSegDellp)
                            )
                        )
                    )
                )
            )
        )
    )
)

/* ============================================================ */
/* POPUP CALLBACKS                                              */
/* ============================================================ */
procedure(SingleWiggleOops()
    if(!axlDBTransactionOops(start) then
        axlUIWPrint(nil "-- Nothing Left To Undo. --")
    else
        axlUIWPrint(nil "-- Restored. --")
    )
    axlClearSelSet()
)

procedure(SingleWiggleCancel()
    if(!axlDBTransactionRollback(start1) then
        axlUIWPrint(nil "-- Nothing to Cancel. --")
    else
        notdone = nil
        axlCancelEnterFun()
        axlUIPopupSet(nil)
        axlUIWPrint(nil "-- Cancelled. --")
    )
    axlClearSelSet()
    axlShell("Done")
    axlUIConfirm("Cancelled Successfully...!")
)

procedure(SingleWiggleDone()
    axlUIWPrint(nil "Done")
    axlDBTransactionCommit(start1)
    notdone = nil
    axlFinishEnterFun()
    axlUIPopupSet(nil)
    axlClearSelSet()
    axlShell("Done")
    axlUIConfirm("Done...!")
)
