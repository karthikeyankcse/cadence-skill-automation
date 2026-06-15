axlCmdRegister("AutoWiggleCreateUIATE1" 'AutoWiggleCreateUIATE1)
(setq AutoWiggle_ATE1_form_file "AutoWiggleCreateUIATE1.form")

/* ============================================================ */
/* GLOBALS                                                      */
/* ============================================================ */
AW_notdone = nil
AW_start   = nil
AW_start1  = nil
AW_popup   = nil

/* ============================================================ */
/* MAIN ENTRY                                                   */
/* ============================================================ */
procedure(AutoWiggleCreateUIATE1()
    axlShell("Done")
    CreateAutoWiggle_ATE1_form()
    RunAutoWiggle_ATE1_form()
)

/* ============================================================ */
/* FORM RUN                                                     */
/* ============================================================ */
procedure(RunAutoWiggle_ATE1_form()
    let((AutoWiggle_ATE1_form)
        (AutoWiggle_ATE1_form = axlFormCreate(gensym() AutoWiggle_ATE1_form_file nil 'AutoWiggle_ATE1_Action t))
        axlFormDisplay(AutoWiggle_ATE1_form)
    )
)

/* ============================================================ */
/* FORM CREATE                                                  */
/* ============================================================ */
procedure(CreateAutoWiggle_ATE1_form()
    let((AutoWiggle_ATE1_form)
        (AutoWiggle_ATE1_form = outfile(AutoWiggle_ATE1_form_file "w"))
        fprintf(AutoWiggle_ATE1_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(AutoWiggle_ATE1_form "FORM\n")
        fprintf(AutoWiggle_ATE1_form "FIXED\n")
        fprintf(AutoWiggle_ATE1_form "PORT 40 50\n")
        fprintf(AutoWiggle_ATE1_form "HEADER \"Auto Wiggle Create\"\n")
        fprintf(AutoWiggle_ATE1_form "\n")
        fprintf(AutoWiggle_ATE1_form "TILE\n")

        fprintf(AutoWiggle_ATE1_form "TEXT \" RADIUS VALUE           >>> \"\n")
        fprintf(AutoWiggle_ATE1_form "TLOC 1 2\n")
        fprintf(AutoWiggle_ATE1_form "ENDTEXT\n")
        fprintf(AutoWiggle_ATE1_form "FIELD %s\n" "RADVAL")
        fprintf(AutoWiggle_ATE1_form "FLOC 25 2\n")
        fprintf(AutoWiggle_ATE1_form "STRFILLIN 10 5\n")
        fprintf(AutoWiggle_ATE1_form "ENDFIELD\n")

        fprintf(AutoWiggle_ATE1_form "TEXT \" AIRGAP MAX             >>> \"\n")
        fprintf(AutoWiggle_ATE1_form "TLOC 1 5\n")
        fprintf(AutoWiggle_ATE1_form "ENDTEXT\n")
        fprintf(AutoWiggle_ATE1_form "FIELD %s\n" "AIRVAL")
        fprintf(AutoWiggle_ATE1_form "FLOC 25 5\n")
        fprintf(AutoWiggle_ATE1_form "STRFILLIN 10 5\n")
        fprintf(AutoWiggle_ATE1_form "ENDFIELD\n")

        fprintf(AutoWiggle_ATE1_form "TEXT \" ACTUAL LENGTH          >>> \"\n")
        fprintf(AutoWiggle_ATE1_form "TLOC 1 8\n")
        fprintf(AutoWiggle_ATE1_form "ENDTEXT\n")
        fprintf(AutoWiggle_ATE1_form "FIELD %s\n" "ALEN")
        fprintf(AutoWiggle_ATE1_form "FLOC 25 8\n")
        fprintf(AutoWiggle_ATE1_form "STRFILLIN 10 5\n")
        fprintf(AutoWiggle_ATE1_form "ENDFIELD\n")

        fprintf(AutoWiggle_ATE1_form "TEXT \" WIGGLE LENGTH          >>> \"\n")
        fprintf(AutoWiggle_ATE1_form "TLOC 1 11\n")
        fprintf(AutoWiggle_ATE1_form "ENDTEXT\n")
        fprintf(AutoWiggle_ATE1_form "FIELD %s\n" "WLEN")
        fprintf(AutoWiggle_ATE1_form "FLOC 25 11\n")
        fprintf(AutoWiggle_ATE1_form "STRFILLIN 10 5\n")
        fprintf(AutoWiggle_ATE1_form "ENDFIELD\n")

        fprintf(AutoWiggle_ATE1_form "FIELD PROC\n")
        fprintf(AutoWiggle_ATE1_form "FLOC 10 15\n")
        fprintf(AutoWiggle_ATE1_form "MENUBUTTON \"CLICK HERE TO PROCEED..!\" 20 4\n")
        fprintf(AutoWiggle_ATE1_form "ENDFIELD\n")

        fprintf(AutoWiggle_ATE1_form "ENDTILE\n")
        fprintf(AutoWiggle_ATE1_form "ENDFORM\n")

        drain()
        close(AutoWiggle_ATE1_form)
    )
)

/* ============================================================ */
/* HELPER : DELETE ORIGINAL STRAIGHT SPAN UNDER WIGGLE          */
/* ============================================================ */
procedure(AWDeleteOriginalSpan(StartX StartY EndX EndY)
    prog(()
        if(StartX == nil || StartY == nil || EndX == nil || EndY == nil then
            axlUIWPrint(nil "AWDeleteOriginalSpan skipped: nil coordinate")
            return()
        )
        axlVisibleUpdate(t)
        axlClearSelSet()
        axlSetFindFilter(
            ?enabled   '("NOALL" "CLINESEGS")
            ?onButtons '("CLINESEGS")
        )
        ClineSegDel = axlGetSelSet(axlSingleSelectBox(list(StartX:StartY EndX:EndY)))
        if(ClineSegDel != nil then
            foreach(seg ClineSegDel
                DelCSeg = seg->startEnd
                if(DelCSeg && length(DelCSeg) >= 2 then
                    DelFPoint = car(DelCSeg)
                    DelSPoint = cadr(DelCSeg)
                    if(DelFPoint && DelSPoint then
                        DelFX = car(DelFPoint)
                        DelFY = cadr(DelFPoint)
                        DelSX = car(DelSPoint)
                        DelSY = cadr(DelSPoint)
                        if(DelFX != nil && DelFY != nil && DelSX != nil && DelSY != nil then
                            DelStr1 = sprintf(nil "(%.2f %.2f)(%.2f %.2f)" DelFX DelFY DelSX DelSY)
                            DelStr2 = sprintf(nil "(%.2f %.2f)(%.2f %.2f)" DelSX DelSY DelFX DelFY)
                            InpStr  = sprintf(nil "(%.2f %.2f)(%.2f %.2f)" StartX StartY EndX EndY)
                            if(DelStr1 == InpStr || DelStr2 == InpStr then
                                axlDeleteObject(seg)
                            )
                        )
                    )
                )
            )
        )
    )
)

/* ============================================================ */
/* MAIN ACTION                                                  */
/* ============================================================ */
procedure(AutoWiggle_ATE1_Action(form)
    case((form->curField)
        ("PROC"

            Rad    = atof(axlFormGetField(form "RADVAL"))
            GapMax = atof(axlFormGetField(form "AIRVAL"))
            AC_Len = atof(axlFormGetField(form "ALEN"))
            W_Len  = atof(axlFormGetField(form "WLEN"))

            if(Rad <= 0.0 || GapMax <= 0.0 then
                axlUIConfirm("ERROR: Radius and Airgap must be > 0.")
                axlFormDisplay(form)
                return()
            )
            if(W_Len <= AC_Len then
                axlUIConfirm("ERROR: Wiggle Length must be greater than Actual Length.")
                axlFormDisplay(form)
                return()
            )
            if(GapMax > (2.0 * Rad) then
                GapMax = 2.0 * Rad
            )

            PI       = 3.14159265358979
            MinFlat  = 5.0
            ExtraLen = W_Len - AC_Len

            RatioMax = 1.0 - (GapMax / (2.0 * Rad))
            if(RatioMax >  1.0 then RatioMax =  1.0)
            if(RatioMax < -1.0 then RatioMax = -1.0)
            T_max        = acos(RatioMax)
            ArcAdd_max   = 4.0*Rad*T_max - 4.0*Rad*sin(T_max)

            if(ArcAdd_max < ExtraLen then
                axlUIConfirm(sprintf(nil
                    "ERROR: Cannot reach required extra length.\nRequired  : %.4f\nMax possible : %.4f\nIncrease Radius or Airgap Max."
                    ExtraLen ArcAdd_max))
                axlFormDisplay(form)
                return()
            )

            ;; Binary search: find T so ArcAdded(T) = ExtraLen
            low  = 0.0001
            high = T_max

            for(i 1 80
                mid    = (low + high) / 2.0
                addMid = 4.0*Rad*mid - 4.0*Rad*sin(mid)
                if(addMid < ExtraLen then
                    low = mid
                else
                    high = mid
                )
            )

            ThetaRad  = (low + high) / 2.0
            ThetaDeg  = ThetaRad * 180.0 / PI
            SolvedGap = 2.0 * Rad * (1.0 - cos(ThetaRad))
            dx_arc    = Rad * sin(ThetaRad)
            dy_arc    = Rad * (1.0 - cos(ThetaRad))
            FlatLen   = MinFlat

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; SETUP POPUP + TRANSACTION
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            AW_popup = axlUIPopupDefine(nil
                (list
                    (list "Done"   'AWDone)
                    (list "Oops"   'AWOops)
                    (list "Cancel" 'AWCancel)
                )
            )
            axlUIPopupSet(AW_popup)

            AW_notdone = t
            AW_start1  = axlDBTransactionStart()
            axlDBTransactionMark(AW_start1)

            while(AW_notdone

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; SELECT CLINE SEGMENT
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                axlSetFindFilter(
                    ?enabled   '("NOALL" "CLINESEGS")
                    ?onButtons '("CLINESEGS")
                )
                axlClearSelSet()
                print("Please Select the Cline Segment to place the Wiggle..!")
                CSeg_objs = axlGetSelSet(axlSelect(?groupMode nil ?prompt "Select Cline Segment..!"))

                if(!CSeg_objs then
                    axlFormDisplay(form)
                    return()
                )

                Linetypeval = car(CSeg_objs)->lineType
                linevalstr  = sprintf(nil "%s" Linetypeval)

                if(!(linevalstr == "horizontal" || linevalstr == "vertical") then
                    axlUIConfirm(sprintf(nil
                        "Error: Unsupported segment type = %s\nOnly horizontal or vertical supported."
                        linevalstr))
                    axlFormDisplay(form)
                    return()
                )

                CSegXY  = car(CSeg_objs)->startEnd
                CSegPt1 = nth(0 CSegXY)
                CSegPt2 = nth(1 CSegXY)

                FirstX = car(CSegPt1)
                FirstY = cadr(CSegPt1)
                SecX   = car(CSegPt2)
                SecY   = cadr(CSegPt2)

                CSegWid = car(CSeg_objs)->width
                CSegLyr = car(CSeg_objs)->layer

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; PICK WIGGLE START POINT
                ;; Horizontal: snap Y to segment, use user X only
                ;; Vertical:   snap X to segment, use user Y only
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                print("Please Pick a Point on the Segment to Start Wiggle..!")
                ev1   = axlEnterEvent(list('PICK) nil t)
                PickX = car(ev1->xy)
                PickY = cadr(ev1->xy)

                if(linevalstr == "horizontal" then
                    StartX = PickX
                    StartY = FirstY
                else
                    StartX = FirstX
                    StartY = PickY
                )

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; PICK SIDE
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                print("Please Pick a Side to create the Wiggle..!")
                ev2   = axlEnterEvent(list('PICK) nil t)
                SideX = car(ev2->xy)
                SideY = cadr(ev2->xy)

                if(linevalstr == "horizontal" then
                    SideIsPositive = if(SideY > StartY then t else nil)
                else
                    SideIsPositive = if(SideX > StartX then t else nil)
                )

                if(SideIsPositive then
                    SideStr = "positive"
                else
                    SideStr = "negative"
                )

                axlUIWPrint(nil sprintf(nil
                    "Wiggle start=(%.3f, %.3f)  Side=%s  Theta=%.4f deg  Gap=%.4f  Flat=%.4f"
                    StartX StartY SideStr ThetaDeg SolvedGap FlatLen))

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; START TRANSACTION
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                AW_start = axlDBTransactionStart()
                axlDBTransactionMark(AW_start)

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; DRAW WIGGLE
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                if(linevalstr == "horizontal" then

                    if(SideIsPositive then
                        C1X = StartX          C1Y = StartY
                        C2X = C1X + dx_arc    C2Y = C1Y + dy_arc
                        C3X = C2X + dx_arc    C3Y = C2Y + dy_arc
                        EX  = C3X + FlatLen   EY  = C3Y
                        C4X = EX  + dx_arc    C4Y = EY  - dy_arc
                        C5X = C4X + dx_arc    C5Y = C4Y - dy_arc

                        p = axlPathStart(list(C1X:C1Y) CSegWid)
                        axlPathArcAngle(p CSegWid C2X:C2Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C2X:C2Y) CSegWid)
                        axlPathArcAngle(p CSegWid C3X:C3Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C3X:C3Y) CSegWid)
                        axlPathLine(p CSegWid EX:EY)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(EX:EY) CSegWid)
                        axlPathArcAngle(p CSegWid C4X:C4Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C4X:C4Y) CSegWid)
                        axlPathArcAngle(p CSegWid C5X:C5Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                    else
                        C1X = StartX          C1Y = StartY
                        C2X = C1X + dx_arc    C2Y = C1Y - dy_arc
                        C3X = C2X + dx_arc    C3Y = C2Y - dy_arc
                        EX  = C3X + FlatLen   EY  = C3Y
                        C4X = EX  + dx_arc    C4Y = EY  + dy_arc
                        C5X = C4X + dx_arc    C5Y = C4Y + dy_arc

                        p = axlPathStart(list(C1X:C1Y) CSegWid)
                        axlPathArcAngle(p CSegWid C2X:C2Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C2X:C2Y) CSegWid)
                        axlPathArcAngle(p CSegWid C3X:C3Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C3X:C3Y) CSegWid)
                        axlPathLine(p CSegWid EX:EY)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(EX:EY) CSegWid)
                        axlPathArcAngle(p CSegWid C4X:C4Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C4X:C4Y) CSegWid)
                        axlPathArcAngle(p CSegWid C5X:C5Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)
                    )

                else
                    if(SideIsPositive then
                        ;; Vertical RIGHT
                        C1X = StartX           C1Y = StartY
                        C2X = C1X + dy_arc     C2Y = C1Y + dx_arc
                        C3X = C2X + dy_arc     C3Y = C2Y + dx_arc
                        EX  = C3X              EY  = C3Y + FlatLen
                        C4X = EX  - dy_arc     C4Y = EY  + dx_arc
                        C5X = C4X - dy_arc     C5Y = C4Y + dx_arc

                        p = axlPathStart(list(C1X:C1Y) CSegWid)
                        axlPathArcAngle(p CSegWid C2X:C2Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C2X:C2Y) CSegWid)
                        axlPathArcAngle(p CSegWid C3X:C3Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C3X:C3Y) CSegWid)
                        axlPathLine(p CSegWid EX:EY)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(EX:EY) CSegWid)
                        axlPathArcAngle(p CSegWid C4X:C4Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C4X:C4Y) CSegWid)
                        axlPathArcAngle(p CSegWid C5X:C5Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                    else
                        ;; Vertical LEFT
                        C1X = StartX           C1Y = StartY
                        C2X = C1X - dy_arc     C2Y = C1Y + dx_arc
                        C3X = C2X - dy_arc     C3Y = C2Y + dx_arc
                        EX  = C3X              EY  = C3Y + FlatLen
                        C4X = EX  + dy_arc     C4Y = EY  + dx_arc
                        C5X = C4X + dy_arc     C5Y = C4Y + dx_arc

                        p = axlPathStart(list(C1X:C1Y) CSegWid)
                        axlPathArcAngle(p CSegWid C2X:C2Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C2X:C2Y) CSegWid)
                        axlPathArcAngle(p CSegWid C3X:C3Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C3X:C3Y) CSegWid)
                        axlPathLine(p CSegWid EX:EY)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(EX:EY) CSegWid)
                        axlPathArcAngle(p CSegWid C4X:C4Y t ThetaDeg)
                        axlDBCreatePath(p CSegLyr)

                        p = axlPathStart(list(C4X:C4Y) CSegWid)
                        axlPathArcAngle(p CSegWid C5X:C5Y nil ThetaDeg)
                        axlDBCreatePath(p CSegLyr)
                    )
                )

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; DELETE ORIGINAL SPAN
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                AWDeleteOriginalSpan(C1X C1Y C5X C5Y)

                ArcAdded = 4.0*Rad*ThetaRad - 4.0*Rad*sin(ThetaRad)
                axlUIWPrint(nil sprintf(nil
                    "SUCCESS: NewClineLen=%.4f  Target=%.4f  Error=%.6f  Gap=%.4f  Flat=%.4f"
                    (AC_Len + ArcAdded) W_Len abs((AC_Len + ArcAdded) - W_Len)
                    SolvedGap FlatLen))
            )
        )
    )
    axlFormDisplay(form)
)

/* ============================================================ */
/* POPUP CALLBACKS                                              */
/* ============================================================ */

procedure(AWOops()
    if(!axlDBTransactionOops(AW_start) then
        axlUIWPrint(nil "-- Nothing Left To Undo. --")
    else
        axlUIWPrint(nil "-- Restored. --")
    )
    axlClearSelSet()
)

procedure(AWCancel()
    AW_notdone = nil
    axlClearDynamics()
    axlCancelEnterFun()
    axlUIPopupSet(nil)
    axlUIWPrint(nil "-- Cancelled. --")
    axlClearSelSet()
    axlShell("Done")
    axlUIConfirm("Cancelled Successfully...!")
)

procedure(AWDone()
    AW_notdone = nil
    axlDBTransactionCommit(AW_start1)
    axlClearDynamics()
    axlFinishEnterFun()
    axlUIPopupSet(nil)
    axlClearSelSet()
    axlShell("Done")
    axlUIConfirm("Done...!")
)
