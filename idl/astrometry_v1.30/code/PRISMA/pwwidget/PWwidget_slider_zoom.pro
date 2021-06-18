; This procedures manages the event on the zoom slider of PRISMAwidget

pro PWwidget_slider_zoom, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, pwwidget.slider_zoom, get_value=scala
widget_control, pwwidget.draw_big, get_uvalue=img
widget_control, pwwidget.draw_zoom, get_uvalue=imgzoom

imgzoom.scale = scala
ds=long(15*2^imgzoom.scale)

; adjust border effects
if imgzoom.xcn lt ds then imgzoom.xcn = ds
if imgzoom.xcn gt img.xsize-ds then imgzoom.xcn = img.xsize-ds
if imgzoom.ycn lt ds then imgzoom.ycn = ds
if imgzoom.ycn gt img.ysize-ds then imgzoom.ycn = img.ysize-ds

widget_control, pwwidget.TEXT_ZOOMXC, set_value=strtrim(imgzoom.xcn,2)
widget_control, pwwidget.TEXT_ZOOMYC, set_value=strtrim(imgzoom.ycn,2)

xcoord = imgzoom.xcn-ds+indgen(2*ds)
ycoord = imgzoom.ycn-ds+indgen(2*ds)
imgzoom.xcoord = rebin(xcoord, 480)
imgzoom.ycoord = rebin(ycoord, 480)

imgtmp = img.image[imgzoom.xcn-ds:imgzoom.xcn+ds-1, imgzoom.ycn-ds:imgzoom.ycn+ds-1]
imgzoom.image=rebin(imgtmp, 480, 480, sample=~widget_info(pwwidget.button_interpol, /button_set))

widget_control, pwwidget.draw_zoom, set_uvalue=imgzoom
PW_draw_image, pwwidget

end