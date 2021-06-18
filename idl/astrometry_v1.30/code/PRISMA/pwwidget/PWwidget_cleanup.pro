; This procedure managed the action to be performed when the
; PRISMAwidget is closed or die

pro PWwidget_cleanup, widgetid

compile_opt idl2

; go to the initial directory and destroy the widget
widget_control, widgetid, get_uvalue=pwwidget
cd, pwwidget.var.basedir
widget_control, widgetid, /destroy

end