; This procedure manages the choice of the mode of PRISMAwidget 
; between Detection and Capture (droplist)

pro PWwidget_modelist, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, pwwidget.text_filename, get_value=filename
widget_control, pwwidget.list_mode, get_uvalue=currmode

mode = widget_info(event.id, /droplist_select)

; define the new mode
case mode of
  
  0: mode = 'detection'
  1: mode = 'capture'
  
endcase

; check if there is something to do 
if filename ne '' and currmode ne mode then begin

  path = file_dirname(filename)
  dir = strsplit(path, path_sep(), /extract)

  case mode of

    'detection': PW_open_image, pwwidget, /detection, status=status

    'capture': PW_open_image, pwwidget, /capture, status=status

  endcase
  
  if status then begin
    
    case currmode of
      
      'detection': widget_control, pwwidget.list_mode, set_droplist_select=0
      'capture': widget_control, pwwidget.list_mode, set_droplist_select=1
      
    endcase

  endif

endif else begin
  
  widget_control, pwwidget.list_mode, set_uvalue=mode
  
endelse

end