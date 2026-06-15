
;  DISCLAIMER:
;       The user of this command assumes all responsibility and does not
;       hold Cadence Design Systems nor the author of this code responsible
;	for any undesired results or problems due to the use of this code.
;
;       This code is unsupported!

; Date Created: Feb 8, 2005
; Tested with Allegro Release:  15.2
; Name of this file: check_short_segs.il
; Written by Ron Guthrie (rong@cadence.com)
;
;
; Usage:
; To use this file, load it from the APD/Allegro command line or allegro.ilinit file 
; and then issue the command
;
;  css
;
; NOTES:
;
; The checking in this file is very simple it assumes a round pad and will flag any 
; segment that starts on the pad origin and has and endpoint that is within the pad
; radius on that layer.
; No attempt has been made for error checking.
; 
defun( rbg_check_short_segs ()
   l_segs=list()
   short_seg_log=axlDMOpenLog("short_segments")
   fprintf(short_seg_log "Segments that may have a vertex inside the pad.\n\n")

   axlSetFindFilter(?enabled '(noall invisible pins vias) ?onButtons '(noall pins vias))
   axlClearSelSet()
   axlAddSelectAll()
   l_pin_via=axlGetSelSet()
   axlClearSelSet()
   foreach(pv l_pin_via
      unless(pv->isMech
        pin_branch=pv->branch
        pin_loc=pv->xy
	foreach(child pin_branch->children
		if(child->objType == "path" then
		  foreach(seg child->segments
		  	seg_startEnd=seg->startEnd
		  	seg_start=car(seg_startEnd)
		  	seg_end=cadr(seg_startEnd)
		  	if(pin_loc==seg_start||pin_loc==seg_end then
		  		seg_length=rbg_get_segLen(seg_startEnd)
		  		seg_layer=seg->layer
		  		pin_rad=rbg_get_pin_radius(pv seg_layer)
		  		if(seg_length<pin_rad then
		  		  fprintf(short_seg_log "Layer: %s\t\t Location: %L\n" seg_layer pin_loc)
		  		);endif
		  	);endif pin
		  );foreach seg
		);endif child
	);foreach child
      );unless pv->isMech
   );foreach pv
      
   close(short_seg_log)
   axlUIViewFileCreate("short_segments.log" "Short Segments Log" nil)
)

procedure(rbg_get_segLen( l_coords )
 let( (x1 x2 y1 y2 x_len y_len h)
	x1=xCoord(car(l_coords))
	x2=xCoord(cadr(l_coords))
	y1=yCoord(car(l_coords))
	y2=yCoord(cadr(l_coords))
	x_len=x2-x1
	y_len=y2-y1
	h=sqrt(x_len**2+y_len**2)
 )
);endproc

procedure(rbg_get_pin_radius(pin_id chk_layer)
 ;let( (l_pads pad pad_box px1 px2)
 	pin_rad=0
	l_pads=pin_id->definition->pads
	foreach(pad l_pads
		if(pad->type=="REGULAR"&&pad->layer==chk_layer then
		  pad_box=pad->bBox
		  px1=xCoord(car(pad_box))
		  px2=xCoord(cadr(pad_box))
		);endif
	);foreach
	pin_rad=abs((px2-px1)/2)
 ;)
);endproc

axlCmdRegister("css" 'rbg_check_short_segs )