; This procedure manages the drawing of the current image on both the big and
; zoom windows of PRISMAwigdget

pro PW_draw_image, pwwidget

compile_opt idl2

; retrieve images 
widget_control, pwwidget.draw_big, get_uvalue=img
widget_control, pwwidget.draw_zoom, get_uvalue=imgzoom
widget_control, pwwidget.text_filename, get_value=filename

if filename ne '' then begin
  
  ; display image in draw_big
  s = size(img.image)

  ; image is defined
  if s[1] ne 0 then begin

    ; display image in main draw window
    widget_control, pwwidget.draw_big, get_value=dWin
    wset, dWin
    erase

    ; retrieve slider values
    widget_control, pwwidget.slider_min, get_value=minimo
    widget_control, pwwidget.slider_max, get_value=massimo

    ; if log-scale option is selecred
    if widget_info(pwwidget.button_logscale, /button_set) then begin

      tvima = bytscl(alog10(img.image+1), alog10(minimo+1), alog10(massimo+1))

    endif else begin

      tvima = bytscl(img.image, minimo, massimo)

    endelse

    ; if button_negative option is selected
    if widget_info(pwwidget.button_negative, /button_set) then begin

      tv, 255-rebin(tvima, 640, 480, sample=~widget_info(pwwidget.button_interpol, /button_set))

    endif else begin

      tv, rebin(tvima, 640, 480, sample=~widget_info(pwwidget.button_interpol, /button_set))

    endelse

    ; draw blue box for zoom region
    boxdim = long(15*2^imgzoom.scale)
    tvbox, boxdim, imgzoom.xcn/2, imgzoom.ycn/2, color='blue'

    ; if positions is selected
    if widget_info(pwwidget.button_loadpos,/button_set) then begin

      widget_control, pwwidget.button_pos, get_uvalue=position

      ; if framenum is listed in position
      if position.defined then begin

        ii = where(position.det_frame eq img.framenum)

        if ii[0] ne -1 then begin

          ii = ii[0]

          ; draw red circle
          tvcircle, 5, position.xpos[ii]/2, position.ypos[ii]/2, color='red',thick=2

        endif

      endif

    endif

  endif

  ; display image in draw_zoom
  s = size(imgzoom.image)

  ; image is defined
  if s[1] ne 0 then begin

    ; display image in main draw window
    widget_control, pwwidget.draw_zoom, get_value=dWin
    wset, dWin
    erase

    ; retrieve slider values
    widget_control, pwwidget.slider_min, get_value=minimo
    widget_control, pwwidget.slider_max, get_value=massimo

    ; if log-scale option is selected
    if widget_info(pwwidget.button_logscale, /button_set) then begin

      tvimazoom = bytscl(alog10(imgzoom.image+1), alog10(minimo+1), alog10(massimo+1))

    endif else begin

      tvimazoom = bytscl(imgzoom.image, minimo, massimo)

    endelse

    ; if button_negative option is selected
    if widget_info(pwwidget.button_negative, /button_set) then begin

      tv, 255-tvimazoom

    endif else begin

      tv, tvimazoom

    endelse

    ; draw position if available
    if widget_info(pwwidget.button_loadpos, /button_set) then begin

      widget_control, pwwidget.button_pos, get_uvalue=position

      ; if framenum is listed in position
      if position.defined then begin

        ii=where(position.det_frame eq img.framenum)

        if ii[0] ne -1 then begin

          ii = ii[0]

          if position.xpos[ii] ge min(imgzoom.xcoord) and position.xpos[ii] le max(imgzoom.xcoord) and $
            position.ypos[ii] ge min(imgzoom.ycoord) and position.ypos[ii] le max(imgzoom.ycoord) then begin

            dx = abs(imgzoom.xcoord - position.xpos[ii])
            dy = abs(imgzoom.ycoord - position.ypos[ii])

            jx = where(abs(dx) eq min(dx))
            jy = where(abs(dy) eq min(dy))

            jx = median(jx)
            jy = median(jy)

            ; draw green box
            tvcircle, 5, jx, jy, color='red',thick=2

            if widget_info(pwwidget.button_showbox, /button_set) then begin

              tvbox, 2^(4-imgzoom.scale)*(2*position.box[ii]+1), jx, jy, color='green', thick=2, /device

            endif

          endif

        endif

      endif

    endif

  endif
  
endif

end