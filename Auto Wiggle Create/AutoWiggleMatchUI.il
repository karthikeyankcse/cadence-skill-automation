axlCmdRegister("AutoWiggleMatchUI" 'AutoWiggleMatchUI)

(setq AutoWiggle_form_file "AutoWiggleMatchUI.form")

/* ============================================================ */
/* GLOBALS                                                      */
/* ============================================================ */
CSeg_objs   = nil
WiggleMark  = nil
WigglePopup = nil
notdone     = nil
start       = nil
start1      = nil
ShortCline  = nil

/* ============================================================ */
/* MAIN ENTRY                                                   */
/* ============================================================ */
procedure(AutoWiggleMatchUI()
    prog(()
        axlShell("Done")
        CreateAutoWiggle_form()
        RunAutoWiggle_form()
    )
)

/* ============================================================ */
/* FORM RUN                                                     */
/* ============================================================ */
procedure(RunAutoWiggle_form()
    prog(()
        AutoWiggle_form = axlFormCreate(gensym() AutoWiggle_form_file nil 'AutoWiggle_Action t)
        axlFormDisplay(AutoWiggle_form)
    )
)

/* ============================================================ */
/* FORM CREATE                                                  */
/*                                                              */
/*  RADVAL  = Radius (ARC mode)  /  Flat-Top Length (45 mode)  */
/*  CNTVAL  = Number of wiggles (both modes)                    */
/*  OBJFLD  = ARC | 45 DEG                                      */
/* ============================================================ */
procedure(CreateAutoWiggle_form()
    prog(()
        AutoWiggle_form = outfile(AutoWiggle_form_file "w")

        fprintf(AutoWiggle_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(AutoWiggle_form "FORM\n")
        fprintf(AutoWiggle_form "FIXED\n")
        fprintf(AutoWiggle_form "PORT 45 55\n")
        fprintf(AutoWiggle_form "HEADER \"Auto Wiggle Match\"\n")
        fprintf(AutoWiggle_form "\n")
        fprintf(AutoWiggle_form "TILE\n")

        /* Row 2 : RADVAL */
        fprintf(AutoWiggle_form "TEXT \" RADIUS / FLAT-TOP LEN    >>> \"\n")
        fprintf(AutoWiggle_form "TLOC 1 2\n")
        fprintf(AutoWiggle_form "ENDTEXT\n")

        fprintf(AutoWiggle_form "FIELD %s\n" "RADVAL")
        fprintf(AutoWiggle_form "FLOC 28 2\n")
        fprintf(AutoWiggle_form "STRFILLIN 10 5\n")
        fprintf(AutoWiggle_form "ENDFIELD\n")
        fprintf(AutoWiggle_form "\n")

        /* Row 5 : CNTVAL (wiggle count) */
        fprintf(AutoWiggle_form "TEXT \" NO. OF WIGGLES            >>> \"\n")
        fprintf(AutoWiggle_form "TLOC 1 5\n")
        fprintf(AutoWiggle_form "ENDTEXT\n")

        fprintf(AutoWiggle_form "FIELD %s\n" "CNTVAL")
        fprintf(AutoWiggle_form "FLOC 28 5\n")
        fprintf(AutoWiggle_form "STRFILLIN 10 5\n")
        fprintf(AutoWiggle_form "ENDFIELD\n")
        fprintf(AutoWiggle_form "\n")

        /* Row 8 : mode selector */
        fprintf(AutoWiggle_form "TEXT \" CHOOSE ARC OR 45          >>> \"\n")
        fprintf(AutoWiggle_form "TLOC 1 8\n")
        fprintf(AutoWiggle_form "ENDTEXT\n")

        fprintf(AutoWiggle_form "POPUP <OBJ>\"ARC\"\"ARC\",\"45 DEG\"\"45 DEG\".\n")
        fprintf(AutoWiggle_form "FIELD OBJFLD\n")
        fprintf(AutoWiggle_form "FLOC 28 8\n")
        fprintf(AutoWiggle_form "ENUMSET 9\n")
        fprintf(AutoWiggle_form "POP \"OBJ\"\n")
        fprintf(AutoWiggle_form "ENDFIELD\n")
        fprintf(AutoWiggle_form "\n")


        /* Row 15 : proceed button */
        fprintf(AutoWiggle_form "FIELD PROC\n")
        fprintf(AutoWiggle_form "FLOC 10 13\n")
        fprintf(AutoWiggle_form "MENUBUTTON \"CLICK HERE TO PROCEED..!\" 20 4\n")
        fprintf(AutoWiggle_form "ENDFIELD\n")
        fprintf(AutoWiggle_form "\n")

        fprintf(AutoWiggle_form "ENDTILE\n")
        fprintf(AutoWiggle_form "\n")
        fprintf(AutoWiggle_form "ENDFORM\n")

        drain()
        close(AutoWiggle_form)
    )
)

/* ============================================================ */
/* ARC MATH HELPERS                                             */
/* ============================================================ */

/* Extra path length added by one arc wiggle */
procedure(GetWiggleAddedLen(Rad Gap TopFlatLen)
    prog(()
        if(Gap <= 0 then return(0.0))
        if(Gap > (2 * Rad) then Gap = 2 * Rad)
        Ratio = 1.0 - (Gap / (2.0 * Rad))
        if(Ratio >  1.0 then Ratio =  1.0)
        if(Ratio < -1.0 then Ratio = -1.0)
        ThetaRad = acos(Ratio)
        dx = Rad * sin(ThetaRad)
        return((4.0 * Rad * ThetaRad) + TopFlatLen - (4.0 * dx) - TopFlatLen)
    )
)

/* Straight span replaced by one arc wiggle */
procedure(GetWiggleReplaceSpan(Rad Gap TopFlatLen)
    prog(()
        if(Gap <= 0 then return(0.0))
        if(Gap > (2 * Rad) then Gap = 2 * Rad)
        Ratio = 1.0 - (Gap / (2.0 * Rad))
        if(Ratio >  1.0 then Ratio =  1.0)
        if(Ratio < -1.0 then Ratio = -1.0)
        ThetaRad = acos(Ratio)
        dx = Rad * sin(ThetaRad)
        return((4.0 * dx) + TopFlatLen)
    )
)

/* ============================================================ */
/* SOLVE ARC GAP FOR EXACT COUNT                                */
/*                                                              */
/*  Given:  NeedExtra, WigCount, Rad, TopFlatLen, AvailLen      */
/*  Find:   Gap such that WigCount * AddedLen(Gap) = NeedExtra  */
/*          AND WigCount * ReplaceSpan(Gap) <= AvailLen         */
/*                                                              */
/*  Strategy: binary search on Gap in (0, 2*Rad]               */
/*  Returns: Gap  or  -1.0 on failure                           */
/* ============================================================ */
procedure(SolveArcGapForCount(Rad WigCount TopFlatLen NeedExtra AvailLen)
    prog(()
        if(WigCount <= 0 then return(-1.0))

        AddPerWig  = NeedExtra / WigCount
        if(AddPerWig <= 0.0 then return(-1.0))

        /* Check if even maximum gap can provide enough added length */
        GapHi  = 2.0 * Rad
        AddMax = GetWiggleAddedLen(Rad GapHi TopFlatLen)

        if(AddMax < AddPerWig then
            axlUIWPrint(nil sprintf(nil
                "SolveArcGapForCount: max gap (%.4f) adds only %.4f but need %.4f per wiggle"
                GapHi AddMax AddPerWig))
            return(-1.0)
        )

        /* Binary search: find Gap so that AddedLen(Gap) == AddPerWig */
        GapLo  = 0.001
        Result = -1.0
        Iter   = 0

        while(Iter < 200
            GapMid  = (GapLo + GapHi) / 2.0
            AddMid  = GetWiggleAddedLen(Rad GapMid TopFlatLen)
            ErrMid  = abs(AddMid - AddPerWig)

            if(ErrMid < 0.0001 then
                Result = GapMid
                Iter = 200  /* break */
            else
                if(AddMid < AddPerWig then
                    GapLo = GapMid
                else
                    GapHi = GapMid
                )
            )
            Iter = Iter + 1
        )

        if(Result < 0.0 then
            /* Accept best midpoint */
            Result = (GapLo + GapHi) / 2.0
        )

        /* Verify span fits:
           WigCount wiggles + (WigCount-1) inter-wiggle flat gaps of TopFlatLen each */
        SpanOne       = GetWiggleReplaceSpan(Rad Result TopFlatLen)
        InterGapTotal = (WigCount - 1) * TopFlatLen
        TotalSpan     = (WigCount * SpanOne) + InterGapTotal

        if(TotalSpan > AvailLen then
            axlUIWPrint(nil sprintf(nil
                "SolveArcGapForCount: total span %.4f exceeds AvailLen %.4f"
                TotalSpan AvailLen))
            return(-1.0)
        )

        return(Result)
    )
)

/* ============================================================ */
/* 45-DEG MATH HELPERS                                          */
/*                                                              */
/*  Shape per wiggle (horizontal TOP):                          */
/*        C3────────C4    <- FlatLen                            */
/*       /            \                                         */
/*     C2              C5  <- each leg = LegH horiz & vert     */
/*     /                \                                       */
/*  C1                   C6                                     */
/*                                                              */
/*  Span    = 4*LegH + FlatLen                                  */
/*  Added   = 4*LegH*(sqrt(2)-1)                               */
/*  => LegH = Added / (4*(sqrt(2)-1))    [exact inversion]     */
/* ============================================================ */

procedure(Get45WiggleAddedLen(LegH FlatLen)
    prog(()
        if(LegH <= 0 then return(0.0))
        return(4.0 * LegH * (1.41421356237 - 1.0))
    )
)

procedure(Get45WiggleReplaceSpan(LegH FlatLen)
    prog(()
        if(LegH <= 0 then return(0.0))
        return((4.0 * LegH) + FlatLen)
    )
)

/* ============================================================ */
/* SOLVE 45-DEG LegH FOR EXACT COUNT                            */
/*                                                              */
/*  Added = 4*LegH*(sqrt2-1)  =>  exact closed-form inversion  */
/*  Returns: LegH  or  -1.0 on failure                         */
/* ============================================================ */
procedure(Solve45LegHForCount(WigCount FlatLen NeedExtra AvailLen)
    prog(()
        if(WigCount <= 0 then return(-1.0))

        AddPerWig = NeedExtra / WigCount
        if(AddPerWig <= 0.0 then return(-1.0))

        /* LegH = AddPerWig / (4*(sqrt2-1)) */
        LegH = AddPerWig / (4.0 * (1.41421356237 - 1.0))

        if(LegH <= 0.0 then return(-1.0))

        /* Verify total span fits:
           WigCount wiggles + (WigCount-1) inter-wiggle flat gaps of FlatLen each */
        SpanOne       = Get45WiggleReplaceSpan(LegH FlatLen)
        InterGapTotal = (WigCount - 1) * FlatLen
        TotalSpan     = (WigCount * SpanOne) + InterGapTotal

        if(TotalSpan > AvailLen then
            axlUIWPrint(nil sprintf(nil
                "Solve45LegHForCount: total span %.4f exceeds AvailLen %.4f"
                TotalSpan AvailLen))
            return(-1.0)
        )

        return(LegH)
    )
)

/* ============================================================ */
/* HELPER : DELETE ORIGINAL STRAIGHT SPAN                       */
/* ============================================================ */
procedure(DeleteOriginalSpan(StartX StartY EndX EndY)
    prog(()
        if(StartX == nil || StartY == nil || EndX == nil || EndY == nil then
            axlUIWPrint(nil "DeleteOriginalSpan skipped: nil coordinate")
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
/* HELPER : CREATE ONE ARC WIGGLE                               */
/* ============================================================ */
procedure(CreateOneWiggle(StartX StartY linevalstr SideIsPositive CSegWid CSegLyr Rad Gap TopFlatLen)
    prog(()
        if(Gap <= 0 then return(list(StartX StartY)))
        if(Gap > (2 * Rad) then Gap = 2 * Rad)
        Ratio = 1.0 - (Gap / (2.0 * Rad))
        if(Ratio >  1.0 then Ratio =  1.0)
        if(Ratio < -1.0 then Ratio = -1.0)
        ThetaRad = acos(Ratio)
        ThetaDeg = ThetaRad * 180.0 / 3.14159265358979
        dx = Rad * sin(ThetaRad)
        dy = Rad * (1.0 - cos(ThetaRad))
        C1PointX = StartX
        C1PointY = StartY

        if(linevalstr == "horizontal" then
            if(SideIsPositive then
                C2PointX = C1PointX + dx  C2PointY = C1PointY + dy
                path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_1 CSegLyr)
                C3PointX = C2PointX + dx  C3PointY = C2PointY + dy
                path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY t ThetaDeg)
                axlDBCreatePath(path_arc_2 CSegLyr)
                MidLineStartX = C3PointX  MidLineStartY = C3PointY
                MidLineEndX   = MidLineStartX + TopFlatLen  MidLineEndY = MidLineStartY
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
                C2PointX = C1PointX + dx  C2PointY = C1PointY - dy
                path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY t ThetaDeg)
                axlDBCreatePath(path_arc_1 CSegLyr)
                C3PointX = C2PointX + dx  C3PointY = C2PointY - dy
                path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_2 CSegLyr)
                MidLineStartX = C3PointX  MidLineStartY = C3PointY
                MidLineEndX   = MidLineStartX + TopFlatLen  MidLineEndY = MidLineStartY
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
        else  /* vertical */
            if(SideIsPositive then
                C2PointX = C1PointX + dy  C2PointY = C1PointY + dx
                path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY t ThetaDeg)
                axlDBCreatePath(path_arc_1 CSegLyr)
                C3PointX = C2PointX + dy  C3PointY = C2PointY + dx
                path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_2 CSegLyr)
                MidLineStartX = C3PointX  MidLineStartY = C3PointY
                MidLineEndX   = MidLineStartX  MidLineEndY = MidLineStartY + TopFlatLen
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
            else
                C2PointX = C1PointX - dy  C2PointY = C1PointY + dx
                path_arc_1 = axlPathStart(list(C1PointX:C1PointY) CSegWid)
                axlPathArcAngle(path_arc_1 CSegWid C2PointX:C2PointY nil ThetaDeg)
                axlDBCreatePath(path_arc_1 CSegLyr)
                C3PointX = C2PointX - dy  C3PointY = C2PointY + dx
                path_arc_2 = axlPathStart(list(C2PointX:C2PointY) CSegWid)
                axlPathArcAngle(path_arc_2 CSegWid C3PointX:C3PointY t ThetaDeg)
                axlDBCreatePath(path_arc_2 CSegLyr)
                MidLineStartX = C3PointX  MidLineStartY = C3PointY
                MidLineEndX   = MidLineStartX  MidLineEndY = MidLineStartY + TopFlatLen
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
            )
        )

        if(C5PointX == nil || C5PointY == nil then
            axlUIWPrint(nil sprintf(nil "CreateOneWiggle(ARC) failed: line=%s Start=(%.2f %.2f)" linevalstr StartX StartY))
            return(nil)
        )
        return(list(C5PointX C5PointY))
    )
)

/* ============================================================ */
/* HELPER : CREATE ONE 45-DEG TRAPEZOID WIGGLE                  */
/* ============================================================ */
procedure(CreateOneWiggle45(StartX StartY linevalstr SideIsPositive CSegWid CSegLyr LegH FlatLen)
    prog(()
        if(LegH <= 0 then return(list(StartX StartY)))

        C1X = StartX  C1Y = StartY
        C6X = nil     C6Y = nil

        if(linevalstr == "horizontal" then
            if(SideIsPositive then
                /* TOP */
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
                /* BOTTOM */
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

        else  /* vertical */
            if(SideIsPositive then
                /* RIGHT */
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

            else
                /* LEFT */
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
            )
        )

        if(C6X == nil || C6Y == nil then
            axlUIWPrint(nil sprintf(nil "CreateOneWiggle45 failed: line=%s Start=(%.2f %.2f)" linevalstr StartX StartY))
            return(nil)
        )
        return(list(C6X C6Y))
    )
)

/* ============================================================ */
/* FORM ACTION                                                  */
/* ============================================================ */
procedure(AutoWiggle_Action(AutoWiggle_form)
    prog(()
        case((AutoWiggle_form->curField)
            ("PROC"

                RadVal = axlFormGetField(AutoWiggle_form "RADVAL")
                CntVal = axlFormGetField(AutoWiggle_form "CNTVAL")
                Obj    = axlFormGetField(AutoWiggle_form "OBJFLD")

                if(RadVal == "" || CntVal == "" || Obj == "" then
                    axlUIConfirm("Error : Required Input Field is Empty..")
                    axlFormDisplay(AutoWiggle_form)
                    return()
                )

                RadVal   = atof(RadVal)
                WigCount = atoi(CntVal)
                Tol      = 0.01

                Use45 = (Obj == "45 DEG")

                /* ---- Validate count ---- */
                if(WigCount <= 0 then
                    axlUIConfirm("Error : No. of Wiggles must be >= 1")
                    axlFormDisplay(AutoWiggle_form)
                    return()
                )

                /* ---- Mode-specific input validation ---- */
                if(Use45 then
                    FlatLen = RadVal
                    if(FlatLen < 0.0 then
                        axlUIConfirm("Error : Flat-Top Length must be >= 0")
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )
                else
                    Rad        = RadVal
                    TopFlatLen = 0.0
                    if(Rad <= 0 then
                        axlUIConfirm("Error : Radius must be > 0")
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )
                )

                CSeg_objs   = nil
                WiggleMark  = nil
                WigglePopup = nil
                notdone     = nil
                start       = nil
                start1      = nil
                ShortCline  = nil

                WigglePopup = axlUIPopupDefine(nil
                    (list
                        (list "Done"   'WiggleDone)
                        (list "Oops"   'WiggleOops)
                        (list "Cancel" 'WiggleCancel)
                    )
                )
                axlUIPopupSet(WigglePopup)

                notdone = t
                start1  = axlDBTransactionStart()
                axlDBTransactionMark(start1)

                while(notdone

                    /* ---- Select first cline ---- */
                    axlSetFindFilter(?enabled '("NOALL" "CLINES") ?onButtons '("CLINES"))
                    axlClearSelSet()
                    Cline_F = axlGetSelSet(axlSelect(?groupMode nil ?prompt "Select The First Cline ..!"))

                    if(Cline_F == nil then
                        return()
                        axlFormClose(AutoWiggle_form)
                    )

                    /* ---- Select second cline ---- */
                    axlSetFindFilter(?enabled '("NOALL" "CLINES") ?onButtons '("CLINES"))
                    axlClearSelSet()
                    Cline_S = axlGetSelSet(axlSelect(?groupMode nil ?prompt "Select The Second Cline ..!"))

                    if(!(Cline_F && Cline_S) then
                        axlUIConfirm("Error : Select both clines")
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )

                    LenVal_F = axlDBGetLength(car(Cline_F))
                    LenVal_S = axlDBGetLength(car(Cline_S))

                    if(LenVal_F >= LenVal_S then
                        LongCline  = car(Cline_F)
                        ShortCline = car(Cline_S)
                        LongLen    = LenVal_F
                        ShortLen   = LenVal_S
                    else
                        LongCline  = car(Cline_S)
                        ShortCline = car(Cline_F)
                        LongLen    = LenVal_S
                        ShortLen   = LenVal_F
                    )

                    NeedExtra = LongLen - ShortLen

                    if(NeedExtra <= Tol then
                        axlUIConfirm("Both clines are already nearly same length.")
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )

                    /* ---- Highlight shorter cline ---- */
                    axlClearSelSet()
                    axlHighlightObject(ShortCline)
                    axlVisibleUpdate(t)
                    axlUIWPrint(nil sprintf(nil
                        "Shorter cline highlighted. NeedExtra=%.4f  WigCount=%d"
                        NeedExtra WigCount))

                    /* ---- Select segment on shorter cline ---- */
                    axlSetFindFilter(?enabled '("NOALL" "CLINESEGS") ?onButtons '("CLINESEGS"))
                    axlClearSelSet()
                    CSeg_objs = axlGetSelSet(axlSelect(?groupMode nil ?prompt "Select Segment On Shorter Cline..!"))

                    if(!CSeg_objs then
                        axlUIConfirm("Error : No segment selected")
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )

                    Linetypeval = car(CSeg_objs)->lineType
                    linevalstr  = sprintf(nil "%s" Linetypeval)

                    if(!(linevalstr == "horizontal" || linevalstr == "vertical") then
                        axlUIConfirm(sprintf(nil "Error : Unsupported segment lineType = %s" linevalstr))
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )

                    CSegXY  = car(CSeg_objs)->startEnd
                    CSegX   = nth(0 CSegXY)
                    CSegY   = nth(1 CSegXY)
                    FirstX  = car(CSegX)
                    FirstY  = cadr(CSegX)
                    SecX    = car(CSegY)
                    SecY    = cadr(CSegY)
                    CSegWid = car(CSeg_objs)->width
                    CSegLyr = car(CSeg_objs)->layer

                    SkipThreshold = CSegWid * 2.0
                    if(NeedExtra <= SkipThreshold then
                        axlUIConfirm(sprintf(nil
                            "Difference %.4f <= 2X trace width (%.4f). Wiggle skipped."
                            NeedExtra SkipThreshold))
                        axlFormDisplay(AutoWiggle_form)
                        return()
                    )

                    /* ---- Pick wiggle start point ---- */
                    print("Please Pick a point to create wiggle...!")
                    event1 = axlEnterEvent(list('PICK) nil t)
                    WigglePoint = event1->xy

                    print("Please Pick a Side to create wiggle...!")
                    event2 = axlEnterEvent(list('PICK) nil t)
                    SidePoint = event2->xy

                    WigglePointX = car(WigglePoint)
                    WigglePointY = cadr(WigglePoint)
                    SidePointX   = car(SidePoint)
                    SidePointY   = cadr(SidePoint)

                    if(linevalstr == "horizontal" then
                        SideIsPositive = (SidePointY > WigglePointY)
                        StartX = WigglePointX
                        StartY = FirstY
                        if(SecX > FirstX then
                            AvailLen = abs(SecX - StartX)
                        else
                            AvailLen = abs(FirstX - StartX)
                        )
                    else
                        SideIsPositive = (SidePointX > WigglePointX)
                        StartX = FirstX
                        StartY = WigglePointY
                        if(SecY >= FirstY then
                            AvailLen = abs(SecY - StartY)
                        else
                            AvailLen = abs(FirstY - StartY)
                        )
                    )

                    axlUIWPrint(nil sprintf(nil
                        "Start=(%.3f,%.3f)  AvailLen=%.4f  NeedExtra=%.4f  Count=%d  Mode=%s"
                        StartX StartY AvailLen NeedExtra WigCount Obj))

                    /* ======================================== */
                    /*  45-DEG BRANCH                           */
                    /* ======================================== */
                    if(Use45 then

                        /* Solve: find uniform LegH so that
                           WigCount * Get45WiggleAddedLen(LegH, FlatLen) = NeedExtra
                           and total span fits in AvailLen                           */
                        LegH = Solve45LegHForCount(WigCount FlatLen NeedExtra AvailLen)

                        if(LegH <= 0.0 then
                            axlUIConfirm(sprintf(nil
                                "Cannot fit %d equal 45-deg wiggles in available length.\nNeedExtra=%.4f  AvailLen=%.4f  FlatLen=%.4f\nTry fewer wiggles or a shorter flat-top."
                                WigCount NeedExtra AvailLen FlatLen))
                            axlFormDisplay(AutoWiggle_form)
                            return()
                        )

                        TotalAdd    = WigCount * Get45WiggleAddedLen(LegH FlatLen)
                        SpanPerWig  = Get45WiggleReplaceSpan(LegH FlatLen)
                        TotalSpan   = (WigCount * SpanPerWig) + ((WigCount - 1) * FlatLen)
                        ErrorVal    = abs(TotalAdd - NeedExtra)
                        PeakHeight  = 2.0 * LegH

                        axlUIWPrint(nil sprintf(nil
                            "45-Plan: Count=%d  LegH=%.4f  PeakHeight=%.4f  Span/wiggle=%.4f  TotalSpan=%.4f  Added=%.4f  Need=%.4f  Err=%.4f"
                            WigCount LegH PeakHeight SpanPerWig TotalSpan TotalAdd NeedExtra ErrorVal))

                        if(ShortCline then
                            axlDehighlightObject(ShortCline)
                            axlVisibleUpdate(t)
                        )

                        start = axlDBTransactionStart()
                        axlDBTransactionMark(start)

                        CurrX = StartX
                        CurrY = StartY
                        OK    = t

                        for(i 1 WigCount
                            EndPt = CreateOneWiggle45(CurrX CurrY linevalstr SideIsPositive CSegWid CSegLyr LegH FlatLen)
                            if(EndPt == nil || car(EndPt) == nil || cadr(EndPt) == nil then
                                axlUIConfirm(sprintf(nil "Error: 45-deg wiggle %d/%d failed." i WigCount))
                                OK = nil
                                return()
                            )
                            DeleteOriginalSpan(CurrX CurrY car(EndPt) cadr(EndPt))
                            CurrX = car(EndPt)
                            CurrY = cadr(EndPt)

                            /* Draw flat gap between wiggles (not after the last one) */
                            if(i < WigCount && FlatLen > 0.0 then
                                if(linevalstr == "horizontal" then
                                    GapEndX = CurrX + FlatLen
                                    GapEndY = CurrY
                                else
                                    GapEndX = CurrX
                                    GapEndY = CurrY + FlatLen
                                )
                                path_gap = axlPathStart(list(CurrX:CurrY) CSegWid)
                                axlPathLine(path_gap CSegWid GapEndX:GapEndY)
                                axlDBCreatePath(path_gap CSegLyr)
                                DeleteOriginalSpan(CurrX CurrY GapEndX GapEndY)
                                CurrX = GapEndX
                                CurrY = GapEndY
                            )
                        )

                        if(OK then
                            axlUIWPrint(nil sprintf(nil
                                "SUCCESS (45-DEG): %d wiggles  LegH=%.4f  Added=%.4f  Needed=%.4f  Err=%.4f"
                                WigCount LegH TotalAdd NeedExtra ErrorVal))
                        )

                    else
                    /* ======================================== */
                    /*  ARC BRANCH                              */
                    /* ======================================== */

                        /* Solve: find uniform Gap so that
                           WigCount * GetWiggleAddedLen(Rad, Gap, TopFlatLen) = NeedExtra
                           and total span fits in AvailLen                               */
                        Gap = SolveArcGapForCount(Rad WigCount TopFlatLen NeedExtra AvailLen)

                        if(Gap <= 0.0 then
                            axlUIConfirm(sprintf(nil
                                "Cannot fit %d equal arc wiggles in available length.\nNeedExtra=%.4f  Rad=%.4f  AvailLen=%.4f\nTry fewer wiggles or a larger radius."
                                WigCount NeedExtra Rad AvailLen))
                            axlFormDisplay(AutoWiggle_form)
                            return()
                        )

                        TotalAdd    = WigCount * GetWiggleAddedLen(Rad Gap TopFlatLen)
                        TotalSpan   = WigCount * GetWiggleReplaceSpan(Rad Gap TopFlatLen)
                        ErrorVal    = abs(TotalAdd - NeedExtra)
                        SpanPerWig  = GetWiggleReplaceSpan(Rad Gap TopFlatLen)

                        axlUIWPrint(nil sprintf(nil
                            "ARC-Plan: Count=%d  Gap=%.4f  Span/wiggle=%.4f  TotalSpan=%.4f  Added=%.4f  Need=%.4f  Err=%.4f"
                            WigCount Gap SpanPerWig TotalSpan TotalAdd NeedExtra ErrorVal))

                        if(ShortCline then
                            axlDehighlightObject(ShortCline)
                            axlVisibleUpdate(t)
                        )

                        start = axlDBTransactionStart()
                        axlDBTransactionMark(start)

                        CurrX = StartX
                        CurrY = StartY
                        OK    = t

                        for(i 1 WigCount
                            EndPt = CreateOneWiggle(CurrX CurrY linevalstr SideIsPositive CSegWid CSegLyr Rad Gap TopFlatLen)
                            if(EndPt == nil || car(EndPt) == nil || cadr(EndPt) == nil then
                                axlUIConfirm(sprintf(nil "Error: arc wiggle %d/%d failed." i WigCount))
                                OK = nil
                                return()
                            )
                            DeleteOriginalSpan(CurrX CurrY car(EndPt) cadr(EndPt))
                            CurrX = car(EndPt)
                            CurrY = cadr(EndPt)
                        )

                        if(OK then
                            axlUIWPrint(nil sprintf(nil
                                "SUCCESS (ARC): %d wiggles  Gap=%.4f  Added=%.4f  Needed=%.4f  Err=%.4f"
                                WigCount Gap TotalAdd NeedExtra ErrorVal))
                        )
                    )
                )
            )
        )

        axlFormDisplay(AutoWiggle_form)
    )
)

/* ============================================================ */
/* POPUP CALLBACKS                                              */
/* ============================================================ */

procedure(WiggleOops()
    if(!axlDBTransactionOops(start) then
        axlUIWPrint(nil "-- Nothing Left To Undo. --")
    else
        axlUIWPrint(nil "-- Restored. --")
    )
    axlClearSelSet()
)

procedure(WiggleCancel()
    notdone = nil
    axlClearDynamics()
    axlCancelEnterFun()
    axlUIPopupSet(nil)
    axlUIWPrint(nil "-- Cancelled. --")
    axlFormClose(AutoWiggle_form)
    axlClearSelSet()
    axlShell("Done")
    axlUIConfirm("Cancelled Successfully...!")
)

procedure(WiggleDone()
    notdone = nil
    axlUIWPrint(nil "Done")
    axlDBTransactionCommit(start1)
    axlClearDynamics()
    axlFinishEnterFun()
    axlUIPopupSet(nil)
    axlFormClose(AutoWiggle_form)
    axlClearSelSet()
    axlShell("Done")
    axlUIConfirm("Done...!")
)
