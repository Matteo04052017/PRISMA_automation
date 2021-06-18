; procedure that print the detection report

pro detection_report, par, var, files

dimw      = [550,750]
buffer    = 1
font_size = 8

time = (var.julian_date - min(var.julian_date, /nan))*24.*60.*60.

Ndet = n_elements(time)

; plot results on a graphic window
xrange = plot_range(time)

w1 = window(dimensions = dimw, buffer = buffer)

text1 = text(0.12, 0.98, 'model_psf = ' + par.config.event.model_psf, /normal, target = w1, $
             color='blue', font_size = font_size)

text3 = text(text1.position[2]+0.02, 0.98, 'model_bar = ' + par.config.event.model_bar, /normal, target = w1, $
             color='red', font_size = font_size)

yrange = plot_range([var.psf.param[1,*],var.bar.param[1,*]], error = [var.psf.sigma[1,*],var.bar.sigma[1,*]], /min0)

p1 = errorplot(time, var.psf.param[1,*], var.psf.sigma[1,*], '.', $
               current = w1, position = [0.12,0.72,0.47,0.93], $
               title = 'Background level', xtitle = 'time [s]', ytitle = 'bkg [ADU]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
p1a = plot(time, var.psf.param[1,*], overplot = p1, thick = 0.5, color = 'blue')
p1b = errorplot(time, var.bar.param[1,*], var.bar.sigma[1,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = p1)
p1c = plot(time, var.bar.param[1,*], overplot = p1, thick = 0.5, color = 'red')

yrange = plot_range([var.psf.param[2,*],var.bar.param[2,*]], error = [var.psf.sigma[2,*],var.bar.sigma[2,*]], /min0)

p2 = errorplot(time, var.psf.param[2,*], var.psf.sigma[2,*], '.', $
               current = w1, position = [0.62,0.72,0.97,0.93], $
               title = 'PSF height', xtitle = 'time [s]', ytitle = 'h [ADU]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
p2a = plot(time, var.psf.param[2,*], overplot = p2, thick = 0.5, color = 'blue')
p2b = errorplot(time, var.bar.param[2,*], var.bar.sigma[2,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = p2)
p2c = plot(time, var.bar.param[2,*], overplot = p2, thick = 0.5, color = 'red')

yrange = plot_range([var.psf.param[3,*],var.bar.param[3,*]], error = [var.psf.sigma[3,*],var.bar.sigma[3,*]])

p3 = errorplot(time, var.psf.param[3,*], var.psf.sigma[3,*], '.', $
               current = w1, position = [0.12,0.41,0.47,0.62], $
               title = 'x position', xtitle = 'time [s]', ytitle = 'x [px]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
p3a = plot(time, var.psf.param[3,*], overplot = p3, thick = 0.5, color = 'blue')
p3b = errorplot(time, var.bar.param[3,*], var.bar.sigma[3,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = p3)
p3c = plot(time, var.bar.param[3,*], overplot = p3, thick = 0.5, color = 'red')

yrange = plot_range([var.psf.param[4,*],var.bar.param[4,*]], error = [var.psf.sigma[4,*],var.bar.sigma[4,*]])

p4 = errorplot(time, var.psf.param[4,*], var.psf.sigma[4,*], '.', $
               current = w1, position = [0.62,0.41,0.97,0.62], $
               title = 'y position', xtitle = 'time [s]', ytitle = 'y [px]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
p4a = plot(time, var.psf.param[4,*], overplot = p4, thick = 0.5, color = 'blue')
p4b = errorplot(time, var.bar.param[4,*], var.bar.sigma[4,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = p4)
p4c = plot(time, var.bar.param[4,*], overplot = p4, thick = 0.5, color = 'red')

yrange = plot_range([var.psf.param[5,*],var.psf.param[6,*],var.bar.param[5,*],var.bar.param[6,*]], $
                    error = [var.psf.sigma[5,*],var.psf.sigma[6,*], var.bar.sigma[5,*], var.bar.sigma[6,*]], /min0)

p5 = errorplot(time, var.psf.param[5,*], var.psf.sigma[5,*], '.', $
               current = w1, position = [0.12,0.10,0.47,0.31], $
               title = 'PSF x-width', xtitle = 'time [s]', ytitle = '$\sigma_x$ [px]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
p5a = plot(time, var.psf.param[5,*], overplot = p5, thick = 0.5, color = 'blue')
p5b = errorplot(time, var.bar.param[5,*], var.bar.sigma[5,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = p5)
p5c = plot(time, var.bar.param[5,*], overplot = p5, thick = 0.5, color = 'red')

p6 = errorplot(time, var.psf.param[6,*], var.psf.sigma[6,*], '.', $
               current = w1, position = [0.62,0.10,0.97,0.31], $
               title = 'PSF y-width', xtitle = 'time [s]', ytitle = '$\sigma_y$ [px]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
p6a = plot(time, var.psf.param[6,*], overplot = p6, thick = 0.5, color = 'blue')
p6b = errorplot(time, var.bar.param[6,*], var.bar.sigma[6,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = p6)
p6c = plot(time, var.bar.param[6,*], overplot = p6, thick = 0.5, color = 'red')

w2 = window(dimensions = dimw, buffer = buffer)

yrange = plot_range([var.psf.param[3,*],var.bar.param[3,*]], error = [var.psf.sigma[3,*],var.bar.sigma[3,*]])

px = errorplot(time, var.psf.param[3,*], var.psf.sigma[3,*], '.', $
               current = w2, position = [0.12,0.70,0.47,0.93], $
               title = 'x position', xtitle = 'time [s]', ytitle = 'x [px]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
pxa = plot(time, var.psf.param[3,*], overplot = px, thick = 0.5, color = 'blue')
pxb = errorplot(time, var.bar.param[3,*], var.bar.sigma[3,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = px)
pxc = plot(time, var.bar.param[3,*], overplot = px, thick = 0.5, color = 'red')

dx = var.psf.param[3,*] - var.bar.param[3,*]

pdx = plot(time, dx, $
           current = w2, position = [0.12,0.55,0.47,0.65], $
           xtitle = 'time [s]', ytitle = 'x$_{psf}$ - x$_{bar}$ [px]', $
           xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0x = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdx)

yrange = plot_range([var.psf.param[4,*],var.bar.param[4,*]], error = [var.psf.sigma[4,*],var.bar.sigma[4,*]])

py = errorplot(time, var.psf.param[4,*], var.psf.sigma[4,*], '.', $
               current = w2, position = [0.62,0.70,0.97,0.93], $
               title = 'y position', xtitle = 'time [s]', ytitle = 'y [px]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
pya = plot(time, var.psf.param[4,*], overplot = py, thick = 0.5, color = 'blue')
pyb = errorplot(time, var.bar.param[4,*], var.bar.sigma[4,*], '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = py)
pyc = plot(time, var.bar.param[4,*], overplot = py, thick = 0.5, color = 'red')

dy = var.psf.param[4,*] - var.bar.param[4,*]

pdy = plot(time, dy, $
           current = w2, position = [0.62,0.55,0.97,0.65], $
           xtitle = 'time [s]', ytitle = 'y$_{psf}$ - y$_{bar}$ [px]', $
           xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0y = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdy)

yrange = plot_range([var.psf.fwhm,var.bar.fwhm], error = [var.psf.s_fwhm,replicate(0, Ndet)], /min0)

pfw = errorplot(time, var.psf.fwhm, var.psf.s_fwhm, '.',$
                current = w2, position = [0.12,0.22,0.47,0.45], $
                title = 'FWHM', xtitle = 'time [s]', ytitle = '$\Gamma$ [px]', $
                xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
                errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
pfwa = plot(time, var.psf.fwhm, overplot = pfw, thick = 0.5, color = 'blue')
pfwb = errorplot(time, var.bar.fwhm, var.bar.s_fwhm, '.', errorbar_capsize = 0., $
                 errorbar_thick = 0.5, sym_thick = 0.5, overplot = pfw)
pfc = plot(time, var.bar.fwhm, overplot = pfw, thick = 0.5, color = 'red')

dfw = var.psf.fwhm - var.bar.fwhm

pdfw = plot(time, dfw, $
            current = w2, position = [0.12,0.07,0.47,0.17], $
            xtitle = 'time [s]', ytitle = '$\Gamma_{psf}$ - $\Gamma_{bar}$ [/]', $
            xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 
p0fw = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdfw)

yrange = plot_range([var.psf.mag,var.bar.mag], error = [var.psf.s_mag,var.bar.s_mag], /reverse)

pm = errorplot(time, var.psf.mag, var.psf.s_mag, '.', $
               current = w2, position = [0.62,0.22,0.97,0.45], $
               title = 'Apparent Magnitude', xtitle = 'time [s]', ytitle = 'm [/]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
pma = plot(time, var.psf.mag, overplot = pm, thick = 0.5, color = 'blue')
pmb = errorplot(time, var.bar.mag, var.bar.s_mag, '.', errorbar_capsize = 0., $
                errorbar_thick = 0.5, sym_thick = 0.5, overplot = pm)
pmc = plot(time, var.bar.mag, overplot = pm, thick = 0.5, color = 'red')

dm = var.psf.mag - var.bar.mag

pdm = plot(time, dm, $
           current = w2, position = [0.62,0.07,0.97,0.17], $
           xtitle = 'time [s]', ytitle = 'm$_{psf}$ - m$_{bar}$ [/]', $
           xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0m = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdm)

w3 = window(dimensions = dimw, buffer = buffer)

yrange = plot_range([var.psf.az,var.bar.az], error = [var.psf.s_az,var.bar.s_az])

paz = errorplot(time, var.psf.az*!radeg, var.psf.s_az*!radeg, '.', $
               current = w3, position = [0.12,0.70,0.47,0.93], $
               title = 'Azimuth', xtitle = 'time [s]', ytitle = 'a [deg]', $
               xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange*!radeg, $
               errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
paza = plot(time, var.psf.az*!radeg, overplot = paz, thick = 0.5, color = 'blue')
pazb = errorplot(time, var.bar.az*!radeg, var.bar.s_az*!radeg, '.', errorbar_capsize = 0., $
                 errorbar_thick = 0.5, sym_thick = 0.5, overplot = paz)
pazc = plot(time, var.bar.az*!radeg, overplot = paz, thick = 0.5, color = 'red')

daz = var.psf.az - var.bar.az
closest, dAZ

pdaz = plot(time, daz*!ramin, $
           current = w3, position = [0.12,0.55,0.47,0.65], $
           xtitle = 'time [s]', ytitle = 'a$_{psf}$ - a$_{bar}$ [arcmin]', $
           xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0az = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdaz)

yrange = plot_range([var.psf.alt,var.bar.alt], error = [var.psf.s_alt,var.bar.s_alt])

palt = errorplot(time, var.psf.alt*!radeg, var.psf.s_alt*!radeg, '.', $
                 current = w3, position = [0.62,0.70,0.97,0.93], $
                 title = 'Elevation', xtitle = 'time [s]', ytitle = 'h [deg]', $
                 xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange*!radeg, $
                 errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
palta = plot(time, var.psf.alt*!radeg, overplot = palt, thick = 0.5, color = 'blue')
paltb = errorplot(time, var.bar.alt*!radeg, var.bar.s_alt*!radeg, '.', errorbar_capsize = 0., $
                  errorbar_thick = 0.5, sym_thick = 0.5, overplot = palt)
paltc = plot(time, var.bar.alt*!radeg, overplot = palt, thick = 0.5, color = 'red')

dalt = var.psf.alt - var.bar.alt

pdalt = plot(time, dalt*!ramin, $
            current = w3, position = [0.62,0.55,0.97,0.65], $
            xtitle = 'time [s]', ytitle = 'h$_{psf}$ - h$_{bar}$ [arcmin]', $
            xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0alt = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdalt)

yrange = plot_range([var.psf.ra,var.bar.ra], error = [var.psf.s_ra,var.bar.s_ra])

pra = errorplot(time, var.psf.ra*!radeg, var.psf.s_ra*!radeg, '.', $
                current = w3, position = [0.12,0.22,0.47,0.45], $
                title = 'Right ascension', xtitle = 'time [s]', ytitle = '$\alpha$ [deg]', $
                xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange*!radeg, $
                errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
praa = plot(time, var.psf.ra*!radeg, overplot = pra, thick = 0.5, color = 'blue')
prab = errorplot(time, var.bar.ra*!radeg, var.bar.s_ra*!radeg, '.', errorbar_capsize = 0., $
                 errorbar_thick = 0.5, sym_thick = 0.5, overplot = pra)
prac = plot(time, var.bar.ra*!radeg, overplot = pra, thick = 0.5, color = 'red')

dra = var.psf.ra - var.bar.ra

pdra = plot(time, dra*!ramin, $
            current = w3, position = [0.12,0.07,0.47,0.17], $
            xtitle = 'time [s]', ytitle = '$\alpha_{psf}$ - $\alpha_{bar}$ [arcmin]', $
            xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0ra = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pdra)

yrange = plot_range([var.psf.dec,var.bar.dec], error = [var.psf.s_dec,var.bar.s_dec])

pdec = errorplot(time, var.psf.dec*!radeg, var.psf.s_dec*!radeg, '.', $
                 current = w3, position = [0.62,0.22,0.97,0.45], $
                 title = 'Declination ', xtitle = 'time [s]', ytitle = '$\delta$ [deg]', $
                 xminor = 4, yminor = 4, xthick = 0.5, ythick = 0.5, xrange = xrange, yrange = yrange*!radeg, $
                 errorbar_capsize = 0., errorbar_thick = 0.5, sym_thick = 0.5, font_size = font_size)
pdeca = plot(time, var.psf.dec*!radeg, overplot = pdec, thick = 0.5, color = 'blue')
pdecb = errorplot(time, var.bar.dec*!radeg, var.bar.s_dec*!radeg, '.', errorbar_capsize = 0., $
                  errorbar_thick = 0.5, sym_thick = 0.5, overplot = pdec)
pdecc = plot(time, var.bar.dec*!radeg, overplot = pdec, thick = 0.5, color = 'red')

ddec = var.psf.dec - var.bar.dec

pddec = plot(time, ddec*!ramin, $
             current = w3, position = [0.62,0.07,0.97,0.17], $
             xtitle = 'time [s]', ytitle = '$\delta_{psf}$ - $\delta_{bar}$ [arcmin]', $
             xrange = xrange, xminor = 4, yminor = 0, xthick = 0.5, ythick = 0.5, font_size = font_size, thick = 0.5) 

p0dec = plot(time, replicate(0,Ndet), thick = 0.5, linestyle = '--', overplot=pddec)

w1.save, files.detection.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w2.save, files.detection.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w3.save, files.detection.report.name, /append, /close, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95

if isa(w1) then w1.close
if isa(w2) then w2.close
if isa(w3) then w3.close

end