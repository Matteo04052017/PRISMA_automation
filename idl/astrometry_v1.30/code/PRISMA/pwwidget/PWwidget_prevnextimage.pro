; This procedure manages the prev/next buttons events 
; i.e. going to the prev/next image in the list of PRISMAwidget

pro PWwidget_prevnextimage, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, event.id, get_uvalue=filename
widget_control, pwwidget.list_mode, get_uvalue=mode
widget_control, pwwidget.text_filename, set_value=filename

if filename ne '' then begin
  
  ; case for different mode
  case mode of
    
    'detection': begin
      
      fdecomp, filename, disk, folder, name, ext
      name = strmid(name,0,6)
      
      ; check for filename
      if name eq 'frame_' then begin

        PW_open_image, pwwidget

      endif else begin

        dialog = dialog_message('This option is valid only for freeture detections', /error)
        widget_control, event.id, get_uvalue=currfile
        widget_control, event.id, set_value=currfile
        return

      endelse
      
    end
    
    'capture': begin
      
      PW_open_image, pwwidget
      
    end
    
  endcase
  
endif

end