; This procedure manages the events on the min-max slider of PRISMAwidget

pro PWwidget_slider_minmax, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget

; retrieve displayed image
widget_control, pwwidget.draw_big, get_uvalue=ima
s = size(ima)

; select draw window big
widget_control, pwwidget.draw_big, GET_VALUE=dWin
wset, dWin
widget_control, pwwidget.slider_min, get_value=minimo
widget_control, pwwidget.slider_max, get_value=massimo

case event.id of

  ; slider min was updated
  pwwidget.slider_min: begin
    
    widget_control, pwwidget.slider_max, set_slider_min=minimo

  end

  ; slider max was updated
  pwwidget.slider_max: begin
    
    widget_control, pwwidget.slider_min, set_slider_max=massimo
    
  end

endcase

PW_draw_image, pwwidget

end