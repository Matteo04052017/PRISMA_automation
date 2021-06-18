; This procedure manages the event of button_interpol button of PRISMAwidget

pro PWwidget_interpolation, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, pwwidget.draw_big, get_uvalue=img
widget_control, pwwidget.draw_zoom, get_uvalue=imgzoom

ds=long(15*2^imgzoom.scale)

imgtmp = img.image[imgzoom.xcn-ds:imgzoom.xcn+ds-1, imgzoom.ycn-ds:imgzoom.ycn+ds-1]
xcoord=imgzoom.xcn-ds+indgen(2*ds)
ycoord=imgzoom.ycn-ds+indgen(2*ds)

imgzoom.xcoord = rebin(xcoord, imgzoom.xsize)
imgzoom.ycoord = rebin(ycoord, imgzoom.ysize)
imgzoom.image  = rebin(imgtmp, imgzoom.xsize, imgzoom.ysize, sample=~widget_info(pwwidget.button_interpol, /button_set))

widget_control, pwwidget.draw_zoom, set_uvalue=imgzoom

PW_draw_image, pwwidget

end