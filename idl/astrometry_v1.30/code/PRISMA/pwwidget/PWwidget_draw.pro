; This procedure manages the events on the draw widget big (main) window
; of PRISMAwidget

pro PWwidget_draw, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, pwwidget.text_filename, get_value=filename

; if there is a loaded image on the widget
if filename ne '' then begin

  case event.type of

    ; moving mouse on image
    2: begin
      widget_control, pwwidget.TEXT_XPOS, set_value=strtrim(event.x*2,2)
      widget_control, pwwidget.TEXT_YPOS, set_value=strtrim(event.y*2,2)

    end

    ; button released
    1: begin

      ; right click
      if event.release eq 4 then begin
      
      ;left click
      endif else begin 

        ; update window centre coordinates
        widget_control, pwwidget.draw_big, get_uvalue=img
        widget_control, pwwidget.draw_zoom, get_uvalue=imgzoom
        imgzoom.xcn = event.x*2
        imgzoom.ycn = event.y*2
        ds = long(15*2^imgzoom.scale)

        ; correct for border effects
        if imgzoom.xcn lt ds then imgzoom.xcn = ds
        if imgzoom.xcn gt img.xsize-ds then imgzoom.xcn = img.xsize-ds
        if imgzoom.ycn lt ds then imgzoom.ycn = ds
        if imgzoom.ycn gt img.ysize-ds then imgzoom.ycn = img.ysize-ds

        widget_control, pwwidget.TEXT_ZOOMXC, set_value=strtrim(imgzoom.xcn, 2)
        widget_control, pwwidget.TEXT_ZOOMYC, set_value=strtrim(imgzoom.ycn, 2)

        xcoord = imgzoom.xcn-ds+indgen(2*ds)
        ycoord = imgzoom.ycn-ds+indgen(2*ds)
        imgzoom.xcoord = rebin(xcoord,480)
        imgzoom.ycoord = rebin(ycoord,480)

        imgtmp = img.image[imgzoom.xcn-ds:imgzoom.xcn+ds-1, imgzoom.ycn-ds:imgzoom.ycn+ds-1]
        imgzoom.image = rebin(imgtmp,480,480, sample=~widget_info(pwwidget.button_interpol, /button_set))
        widget_control, pwwidget.draw_zoom, set_uvalue=imgzoom

        PW_draw_image, pwwidget

      endelse

    end
    
    ; no action to be performed
    else: begin

    end

  endcase

endif

end