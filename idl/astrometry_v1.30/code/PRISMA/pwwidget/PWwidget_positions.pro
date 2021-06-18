; This procedure manages the Position menu events of PRISMAwidget

pro PWwidget_positions, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, event.id, get_value=value
widget_control, pwwidget.button_pos, get_uvalue=position

; case for different buttons
case value of

  'Load': begin

    widget_control, pwwidget.button_loadpos, set_button=~widget_info(pwwidget.button_loadpos, /button_set)
    
    ; load position file
    if widget_info(pwwidget.button_loadpos, /button_set) then begin
      
      widget_control, pwwidget.table_pos, sensitive=1
      widget_control, pwwidget.slider_box, sensitive=1
      widget_control, pwwidget.button_fixbox, sensitive=1
      
      PW_loadpos, pwwidget
      PW_draw_image, pwwidget
    
    ; clear position
    endif else begin
      
      widget_control, pwwidget.slider_box, get_value=dbox
      
      position = {DEFINED:0, POSFILE:position.posfile, FREETURE:position.freeture, NDET:0, DET_FRAME:0, XPOS:0, YPOS:0, STRCOORD:'', DATA:'', BOX:dbox}
      widget_control,pwwidget.button_pos,set_uvalue=position
      
      widget_control, pwwidget.button_autopos, set_button=0
      widget_control, pwwidget.button_showbox, set_button=0
      widget_control, pwwidget.table_pos, sensitive=0, table_ysize=25, alignment=2, set_value=['','','',''], set_table_view=[0,0], set_table_select=[-1,-1,-1,-1]
      widget_control, pwwidget.slider_box, sensitive=0
      widget_control, pwwidget.button_fixbox, set_button=0, sensitive=0

      PW_draw_image, pwwidget
      
    endelse

  end

  'Auto-centre': begin

    widget_control,pwwidget.button_autopos, set_button=~widget_info(pwwidget.button_autopos, /button_set)
    
    if widget_info(pwwidget.button_autopos,/button_set) and widget_info(pwwidget.button_loadpos,/button_set) then begin
      
      ; check for fix-box button
      button_fixbox = widget_info(pwwidget.button_fixbox, /button_set)
      
      if ~button_fixbox then begin
        
        widget_control, pwwidget.draw_big, get_uvalue=img
        kk = where(position.det_frame eq img.framenum)
        kk = kk[0]

        if kk ne -1 then widget_control, pwwidget.slider_box, set_value=position.box[kk]
        
      endif
      
      PW_autopos, pwwidget
      PW_draw_image, pwwidget

    endif

  end
  
  'Show Box': begin
    
    widget_control, pwwidget.button_showbox, set_button=~widget_info(pwwidget.button_showbox, /button_set)
    
    PW_draw_image, pwwidget
    
  end

endcase

end