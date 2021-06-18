; This procedure manages the event of button_negative button of PRISMAwidget

pro PWwidget_negative, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget

PW_draw_image, pwwidget

end