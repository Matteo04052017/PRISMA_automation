; This procedure manages the event of log-scale button of PRISMAwidget of PRISMAwidget

pro PWwidget_logscale, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget

PW_draw_image, pwwidget

end