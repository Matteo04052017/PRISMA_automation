; This procedure is called when the user select the File menu button of PRISMAwidget

pro PWwidget_file, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, event.id, get_value=value
widget_control, pwwidget.button_file, get_uvalue=currdir

; case for different menu options
case value of

  'Open Detection': begin 
    
    filename = DIALOG_PICKFILE(path=currdir, filter='*.fit*', /must_exist, dialog_parent=event.top)
    widget_control, pwwidget.text_filename, set_value=filename
    
    PW_open_image, pwwidget, /cd, /sensitive, /detection
    
  end
  
  'Open Capture': begin 
    
    filename = DIALOG_PICKFILE(path=currdir, filter='*.fit*', /must_exist, dialog_parent=event.top)
    widget_control, pwwidget.text_filename, set_value=filename
    
    PW_open_image, pwwidget, /cd, /sensitive, /capture
    
  end

  'Exit': begin
    
    cd, pwwidget.var.basedir
    widget_control, event.top, /destroy

  end

endcase

end