pro photometry_report, par, files, var

compile_opt idl2

; fractional part of jd
time = var.julian_date - floor(min(var.julian_date))
ii = where(var.exposure eq par.photometry.exposure)

dimw      = [550,750]
buffer    = 1
font_size = 8

w1 = window(dimensions = dimw, buffer=buffer)
w2 = window(dimensions = dimw, buffer=buffer)
w3 = window(dimensions = dimw, buffer=buffer)

plotZ  = objarr(1)
plotZ1 = objarr(1)
plotM  = objarr(8)
plotM1 = objarr(8)
plotL  = objarr(12)
plotL1 = objarr(12)

colorM = [ 'Black', 'Brown', 'Red', 'Orange', 'Dark Green', 'Navy', 'Purple', 'Deep Pink' ]
colorL = [ 'Black', 'Brown', 'Salmon', 'Red', 'Orange', 'Lime', 'Dark Green', 'Navy', 'Cyan', 'Purple', 'Medium Purple', 'Deep Pink' ]

skyp = get_skypoints()

skyp.az = skyp.az*!radeg
skyp.zd = skyp.zd*!radeg

textM = strtrim(fix(skyp.az[1:8]), 2) + '°'
textL = strtrim(fix(skyp.az[9:20]), 2) + '°'

textM[0] = 'a = ' + textM[0]
textL[0] = 'a = ' + textL[0]

plotZ[0]  = plot(time, var.mag_sky[0,*], $
                 current = w1, position=[0.12, 0.58, 0.88, 0.93], $
                 title='Sky magnitude (day-night, z = ' + strtrim(fix(skyp.zd[0]),2) + '°)', xtitle='time [JD fraction]', ytitle='mag/arcsec$^2$', $
                 xrange = [0,1], yrange=[ceil(max(var.mag_sky[0,*], /nan)+1), floor(min(var.mag_sky[0,*], /nan)-1)], $
                 xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

if n_elements(ii) gt 1 then begin

  plotZ1[0] = plot(time[ii], var.mag_sky[0,ii], $
                   current = w1, position=[0.12, 0.13, 0.88, 0.48], $
                   title='Sky magnitude (night, z = ' + strtrim(fix(skyp.zd[0]),2) + '°)', xtitle='time [JD fration]', ytitle='mag/arcsec$^2$', $
                   xrange = minmax(time[ii]), yrange=[ceil2(max(var.mag_sky[0,ii], /nan))+0.5, floor2(min(var.mag_sky[0,ii], /nan))-0.5], $
                   xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

endif

plotM[0]  = plot(time, var.mag_sky[1,*], color=colorM[0], name = textM[0], $
                 current = w2, position=[0.12, 0.58, 0.88, 0.93], $
                 xtitle='time [JD fraction]', ytitle='mag/arcsec$^2$', title='Sky magnitude (day-night, z = ' + strtrim(fix(skyp.zd[1]),2) + '°)', $
                 xrange = [0,1], yrange=[ceil(max(var.mag_sky[1:8,*], /nan)+1), floor(min(var.mag_sky[1:8,*], /nan)-1)], $
                 xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

if n_elements(ii) gt 1 then begin

  plotM1[0] = plot(time[ii], var.mag_sky[1,ii], color=colorM[0], name = textM[0], $
                   current = w2, position=[0.12, 0.13, 0.88, 0.48], $
                   xtitle='time [JD fraction]', ytitle='mag/arcsec$^2$', title='Sky magnitude (night, z = ' + strtrim(fix(skyp.zd[1]),2) + '°)', $
                   xrange = minmax(time[ii]), yrange=[ceil2(max(var.mag_sky[1:8,ii], /nan))+0.5, floor2(min(var.mag_sky[1:8,ii], /nan))-0.5], $
                   xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

endif

for j=2, 8 do begin

  plotM[j-1]  = plot(time, var.mag_sky[j,*], overplot = plotM[0], color = colorM[j-1], name = textM[j-1], thick = 0.5)

  if n_elements(ii) gt 1 then begin

    plotM1[j-1] = plot(time[ii], var.mag_sky[j,ii], overplot = plotM1[0], color = colorM[j-1], name = textM[j-1], thick=0.5)

  endif

endfor

; plot legend
legM1 = legend(target = plotM[0:3], /auto_text_color, orientation = 1, horizontal_spacing = 0.05, sample_width = 0.14, $
               linestyle = 'none', position = [0.90, 0.06], /normal, font_size = font_size)
legM2 = legend(target = plotM[4:7], /auto_text_color, orientation = 1, horizontal_spacing = 0.05, sample_width = 0.14, $
               linestyle = 'none', position = [0.90, 0.02], /normal, font_size = font_size)

plotL[0]  = plot(time, var.mag_sky[9,*], color = colorL[0], name = textL[0], $ 
                 current = w3, position=[0.12, 0.58, 0.88, 0.93], $
                 xtitle='time [JD fraction]', ytitle='mag/arcsec$^2$', title='Sky magnitude (day-night, z = ' + strtrim(fix(skyp.zd[9]),2) + '°)', $
                 xrange = [0,1], yrange=[ceil(max(var.mag_sky[10:20,*], /nan)+1), floor(min(var.mag_sky[10:20,*], /nan)-1)], $
                 xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

if n_elements(ii) gt 1 then begin

  plotL1[0] = plot(time[ii], var.mag_sky[9,ii], color = colorL[0], name = textL[0], $
                   current = w3, position=[0.12, 0.13, 0.88, 0.48], $
                   xtitle='time [JD fraction]', ytitle='mag/arcsec$^2$', title='Sky magnitude (night, z = ' + strtrim(fix(skyp.zd[9]),2) + '°)', $
                   xrange = minmax(time[ii]), yrange=[ceil2(max(var.mag_sky[10:20,ii], /nan))+0.5, floor2(min(var.mag_sky[10:20,ii], /nan))-0.5], $
                   xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

endif

for j=10, 20 do begin

  plotL[j-9]  = plot(time, var.mag_sky[j,*], overplot = plotL[0], color = colorL[j-9], name = textL[j-9], thick = 0.5)

  if n_elements(ii) gt 1 then begin

    plotL1[j-9] = plot(time[ii], var.mag_sky[j,ii], overplot = plotL1[0], color = colorL[j-9], name = textL[j-9], thick = 0.5)

  endif

endfor

; plot legend
legL1 = legend(target = plotL[0:5], /auto_text_color, orientation = 1, horizontal_spacing = 0.021, sample_width = 0.1, $
               linestyle = 'none', position = [0.90, 0.06], /normal, font_size = font_size)
legL2 = legend(target = plotL[6:11], /auto_text_color, orientation = 1, horizontal_spacing = 0.02, sample_width = 0.1, $
               linestyle = 'none', position = [0.90, 0.02], /normal, font_size = font_size)

w1.save, files.photometry.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w2.save, files.photometry.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w3.save, files.photometry.report.name, /append, /close, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95

if isa(w1) then w1.close
if isa(w2) then w2.close
if isa(w3) then w3.close
  
end