; This procedure manages the modification events on the 
; filename text of PRISMAwidget

pro PWwidget_filename, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget

PW_open_image, pwwidget, /cd, /sensitive

end