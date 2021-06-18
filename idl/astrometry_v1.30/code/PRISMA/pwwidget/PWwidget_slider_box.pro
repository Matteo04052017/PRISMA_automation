; This procedure manages the events on the box dim slider of PRISMAwidget

pro PWwidget_slider_box, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, pwwidget.draw_big, get_uvalue=img
widget_control, pwwidget.button_pos, get_uvalue=position
widget_control, pwwidget.slider_box, get_value=box

if widget_info(pwwidget.button_loadpos, /button_set) and widget_info(pwwidget.button_autopos, /button_set) then begin
  
  kk = where(position.det_frame eq img.framenum)
  kk = kk[0]

  if kk ne -1 then position.box[kk] = box

  widget_control, pwwidget.button_pos, set_uvalue=position
  
  PW_autopos, pwwidget
  PW_draw_image, pwwidget
  
endif

end