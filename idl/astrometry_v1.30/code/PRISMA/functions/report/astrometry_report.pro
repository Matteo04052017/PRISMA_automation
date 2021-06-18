pro astrometry_report, par, config, files, var, res

compile_opt idl2

loadct, 13, rgb_table = rgb, /silent

dimw      = [550,750]
buffer    = 1
font_size = 8

; bin size definitions
bsx_matXY = 2.
bsy_matXY = 2.

bs1D_resAZ = 1.
bs1D_resZD = 1.

bs2Dx_resAZ = 1.
bs2Dy_resAZ = 0.5

bs2Dx_resZD = 0.25
bs2Dy_resZD = 0.5

bs1D_covX = 5.
bs1D_covY = 5.

bs2Dx_covXY = 5.
bs2Dy_covXY = 5.

bs1D_covAZ = 2.
bs1D_covZD = 0.5

bs2Dx_covAZ = 1.
bs2Dy_covAZ = 0.5

range_az = [-60,60]
range_zd = [-60,60]

ns = n_elements(var.x)

; frames rotated dimensions
rotdim = get_rotdim(par)

; definition of matrices and vector for maps
dim_x = round(par.fits.radius*2/bsx_matXY)
dim_y = round(par.fits.radius*2/bsy_matXY)

xv = findgen(dim_x)*bsx_matXY - par.fits.radius + par.fits.center[0]
yv = findgen(dim_y)*bsy_matXY - par.fits.radius + par.fits.center[1]

mat_x = xv # (yv*0 + 1)
mat_y = (xv* 0 + 1) # yv
mask_r2 = fltarr(dim_x,dim_y)
r2 = sqrt((mat_x-par.fits.center[0])^2 + (mat_y-par.fits.center[1])^2)
ii = where(r2 le par.fits.radius, complement = ii0)
mask_r2[ii]  = 1
mask_r2[ii0] = !values.f_NaN

; model evaluation to compute residuals on azimuth and zenith distance
model    = xy2az(res.model, var.x, var.y, res.param)
az_model = model.az
zd_model = model.zd

; astrometric residuals
dAZ      = var.az - az_model
dZD      = var.zd - zd_model

closest, dAZ

w1 = window(dimensions = dimw, buffer=buffer)
w2 = window(dimensions = dimw, buffer=buffer)
w3 = window(dimensions = dimw, buffer=buffer)
w4 = window(dimensions = dimw, buffer=buffer)
w5 = window(dimensions = dimw, buffer=buffer)

; 2D residual plots
if config.histo then begin

  rgb_mod = rgb
  rgb_mod[0,*] = [255,255,255]

  ; 2D histograms
  h2D_resAZ = myhist_2d(var.az*!radeg, dAZ*sin(var.zd)*!ramin, min1 = 0, max1 = 360, min2 = range_az[0], $
                        max2 = range_az[1], bin1 = bs2Dx_resAZ, bin2 = bs2Dy_resAZ, $
                        loc1 = loc_h2Dx_resAZ, loc2 = loc_h2Dy_resAZ)
                        
  h2D_resZD = myhist_2d(var.zd*!radeg, dZD*!ramin, min1 = 0, max1 = 90, min2 = range_zd[0], $
                        max2 = range_zd[1], bin1 = bs2Dx_resZD, bin2 = bs2Dy_resZD, $
                        loc1 = loc_h2Dx_resZD, loc2 = loc_h2Dy_resZD)

  ; log stretching
  h2D_resAZ = alog10(h2D_resAZ + 1)
  h2D_resZD = alog10(h2D_resZD + 1)

  ; histogram plots
  pa = image(h2D_resAZ, loc_h2Dx_resAZ, loc_h2Dy_resAZ, rgb_table=rgb_mod, $ 
             current = w1, position=[0.12, 0.55, 0.75, 0.93], $
             title = 'Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
             axis_style = 2, xrange=[0,360], yrange = range_az, $
             aspect_ratio = 0, xthick=0.5, ythick=0.5, font_size = font_size)
             
  pz = image(h2D_resZD, loc_h2Dx_resZD, loc_h2Dy_resZD, rgb_table=rgb_mod, $
             current = w1, position=[0.12, 0.07, 0.75, 0.45], $
             title = 'Zenith distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
             axis_style = 2, xrange=[0,90], yrange = range_zd, $
             aspect_ratio = 0, xthick=0.5, ythick=0.5, font_size = font_size)

  ; 2D histograms
  h2D_covXY = myhist_2d(var.x, var.y, min1 = min(xv), max1 = max(xv), min2 = min(yv), max2 = max(yv), $
                        bin1 = bs2Dx_covXY, bin2 = bs2Dy_covXY, loc1 = loc_h2Dx_covXY, loc2 = loc_h2Dy_covXY)
                        
  h2D_covAZ = myhist_2d(var.az*!radeg, var.zd*!radeg, min1 = 0, max1 = 360, min2 = 0, max2 = 90, $
                        bin1 = bs2Dx_covAZ, bin2 = bs2Dy_covAZ, loc1 = loc_h2Dx_covAZ, loc2 = loc_h2Dy_covAZ)

  ; log stretching
  h2D_covXY = alog10(h2D_covXY + 1)
  h2D_covAZ = alog10(h2D_covAZ + 1)

  ; coverage histograms
  pxy = image(h2D_covXY, loc_h2Dx_covXY, loc_h2Dy_covXY, rgb_table=rgb_mod, $
              current = w2, position = [0.38, 0.66, 0.77, 0.93], $
              title = '(x,y) coverage histogram', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
              axis_style = 2, xrange=minmax(xv), yrange=minmax(yv), $
              aspect_ratio = 0, xthick=0.5, ythick=0.5, font_size = font_size)  
                          
  paz = image(h2D_covAZ, loc_h2Dx_covAZ, loc_h2Dy_covAZ, rgb_table=rgb_mod, $
              current = w2, position = [0.25, 0.18, 0.90, 0.45], $
              title = '(a,z) coverage histogram', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
              axis_style = 2, xrange=[0,360], yrange=[0,90], $
              aspect_ratio = 0, xthick=0.5, ythick=0.5, font_size = font_size)
              
endif else begin
  
  ; residuals plots
  pa = plot(var.az*!radeg, dAZ*sin(var.zd)*!ramin,'.', $
            current = w1, position=[0.12, 0.55, 0.75, 0.93], $
            title='Azimuth residuals',  xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
            xrange = [0,360], yrange=range_az, $
            sym_thick = 0.3, xthick=0.5, ythick=0.5, font_size = font_size)
                                   
  pz = plot(var.zd*!radeg, dZD*!ramin, '.', $
            current = w1, position=[0.12, 0.07, 0.75, 0.45], $
            title='Zenith Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
            xrange = [0,90], yrange=range_zd, $
            sym_thick = 0.3, xthick=0.5, ythick=0.5, font_size = font_size) 
  
  ; (x,y) coverage plots
  pxy = plot(var.x,var.y, '.',$
             current = w2, position = [0.38, 0.66, 0.77, 0.93], $
             title = '(x,y) coverage plot', xtitle = 'x [px]', ytitle = 'y [px]', $
             xrange = minmax(xv), yrange = minmax(yv), $
             sym_thick = 0.3, xthick=0.5, ythick=0.5, font_size = font_size)

  ; (a,z) coverage plots
  paz = plot(var.az*!radeg, var.zd*!radeg,'.', $
             current = w2, position=[0.25, 0.18, 0.90, 0.45], $
             title = '(a,z) coverage plot', xtitle='a [deg]', ytitle='z [deg]', $
             xrange = [0,360], yrange = [0,90], $
             sym_thick = 0.3, xthick=0.5, ythick=0.5, font_size = font_size)

endelse

str1 = '$n_*$ = ' + strtrim(ns, 2) + ', model = ' + strlowcase(res.model)
t1 = text(0.1, 0.98, str1, /normal, target=w1, font_size = font_size)

pxy['axis0'].showtext = 0
pxy['axis1'].showtext = 0

paz['axis0'].showtext = 0
paz['axis1'].showtext = 0

; residual histograms
h1D_resAZ = histogram(dAZ*sin(var.ZD)*!ramin, min = range_az[0], $
                      max = range_az[1], binsize = bs1D_resAZ, locations = loc_h1D_resAZ)                    
h1D_resZD = histogram(dZD*!ramin, min = range_zd[0], $
                      max = range_zd[1], binsize = bs1D_resZD, locations = loc_h1D_resZD)

h1D_resAZ = float(h1D_resAZ)*100/(n_elements(var.az)*bs1D_resAZ)
h1D_resZD = float(h1D_resZD)*100/(n_elements(var.zd)*bs1D_resZD)

; histogram plots
pha = plot(h1D_resAZ, loc_h1D_resAZ+bs1D_resAZ, /histogram, $
           current = w1, position=[0.75, 0.55, 0.90, 0.93], $
           xtitle='% occurrences', $
           xrange=[0,max([h1D_resAZ,h1D_resZD])*1.2], yrange=range_az, $
           fill_background = 1, fill_color='blue', $
           xthick=0.5, ythick=0.5, thick=0.3, font_size = font_size)
           
pha['axis0'].minor = 0
pha['axis0'].text_orientation = -90
pha['axis1'].showtext = 0
pha['axis2'].minor = 0
           
phz = plot(h1D_resZD, loc_h1D_resZD+bs1D_resZD, /histogram, $
           current = w1, position=[0.75, 0.07, 0.90, 0.45], $
           xtitle='% occurrences', $
           xrange=[0,max([h1D_resAZ,h1D_resZD])*1.2], yrange=range_zd, $
           fill_background = 1, fill_color='blue', $
           xthick=0.5, ythick=0.5, thick=0.3, font_size = font_size)  
           
phz['axis0'].minor = 0
phz['axis0'].text_orientation = -90
phz['axis1'].showtext = 0
phz['axis2'].minor = 0

; coverage 1D histogram
h1D_covX = histogram(var.x, min = min(xv), max = max(xv), binsize = bs1D_covX, locations = loc_h1D_covX)
h1D_covY = histogram(var.y, min = min(yv), max = max(yv), binsize = bs1D_covX, locations = loc_h1D_covY)

h1D_covAZ = histogram(var.az*!radeg, min = 0., max = 360., binsize = bs1D_covAZ, locations = loc_h1D_covAZ)
h1D_covZD = histogram(var.zd*!radeg, min = 0., max = 90., binsize = bs1D_covZD, locations = loc_h1D_covZD)

h1D_covX = float(h1D_covX)*100/(bs1D_covX*ns)
h1D_covY = float(h1D_covY)*100/(bs1D_covY*ns)

h1D_covAZ = float(h1D_covAZ)*100/(bs1D_covAZ*ns)
h1D_covZD = float(h1D_covZD)*100/(bs1D_covZD*ns)

; histogram plots
phx = plot(loc_h1D_covX, h1D_covX, /histogram, $
           current = w2, position=[0.38, 0.56, 0.77, 0.66], $
           xtitle = 'x [px]', ytitle='% stars/px', $
           xrange=minmax(xv), yrange=plot_range(h1D_covX, border = 0.2, /min0), $
           fill_background = 1, fill_color='blue', $
           xthick=0.5, ythick=0.5, thick=0.3, font_size = font_size)
          
phx['axis1'].showtext = 0
phx['axis1'].minor = 0
phx['axis3'].showtext = 1
phx['axis3'].minor = 0
          
phy = plot(h1D_covY, loc_h1D_covY+bs1D_covY, /histogram, $
           current = w2, position=[0.25, 0.66, 0.38, 0.93], $
           xtitle = '% stars/px', ytitle='y [px]', $
           xrange=plot_range(h1D_covY, border = 0.2, /min0), yrange=minmax(yv), $
           fill_background = 1, fill_color='blue', $
           xthick=0.5, ythick=0.5, thick=0.3, font_size = font_size)
          
phy['axis0'].showtext = 0
phy['axis0'].minor = 0
phy['axis2'].showtext = 1
phy['axis2'].minor = 0
phy['axis2'].text_orientation = -90

; histogram plots
phaz = plot(loc_h1D_covAZ, h1D_covAZ, /histogram, $
            current = w2, position=[0.25, 0.08, 0.90, 0.18], $
            xtitle = 'a [deg]', ytitle='% stars/deg', $
            xrange=[0,360], yrange=plot_range(h1D_covAZ, border = 0.2, /min0), $
            fill_background = 1, fill_color='blue', $
            xthick=0.5, ythick=0.5, thick=0.3, font_size = font_size)

phaz['axis1'].showtext = 0
phaz['axis1'].minor = 0
phaz['axis3'].showtext = 1
phaz['axis3'].minor = 0

phzd = plot(h1D_covZD, loc_h1D_covZD+bs1D_covZD, $
            current = w2, position=[0.12, 0.18, 0.25, 0.45], $
            xtitle = '% stars/deg', ytitle='z [deg]', $
            /histogram, yrange=[0,90], xrange=plot_range(h1D_covZD, border = 0.2, /min0), $
            fill_background = 1, fill_color='blue', $
            xthick=0.5, ythick=0.5, thick=0.3, font_size = font_size)

phzd['axis0'].showtext = 0
phzd['axis0'].minor = 0
phzd['axis2'].showtext = 1
phzd['axis2'].minor = 0
phzd['axis2'].text_orientation = -90
           
; definition of the baseline model
param_base = get_astro_parambase(res.model, res.param)

; baseline projection
proj_base = xy2az(res.model, mat_x, mat_y, param_base)
proj      = xy2az(res.model, mat_x, mat_y, res.param)

; distorsion matrices
dAZ_proj = proj.az*mask_r2 - proj_base.az*mask_r2
closest, dAZ_proj, /abs
dZD_proj = abs(proj_base.zd*mask_r2 - proj.zd*mask_r2)

; distorsion maps
im1 = image(dAZ_proj*sin(proj.zd)*!ramin, xv , yv, rgb_table=rgb, $
            current = w3, LAYOUT=[1,2,1], margin = 0.15, $
            title = 'Azimuth distorsion [$\Delta$a$\cdot$sin(z), arcmin]', xtitle='x [px]', ytitle='y [px]', $
            axis_style = 2, xticklen = 0., yticklen = 0., xthick=0.5, ythick=0.5, font_size = font_size)
            
im2 = image(dZD_proj*!ramin, xv, yv, rgb_table=rgb, $
            current = w3, LAYOUT=[1,2,2], margin = 0.15, $
            title = 'Zenith distance distorsion [$\Delta$z, arcmin]', xtitle='x [px]', ytitle='y [px]', $
            axis_style = 2, xticklen = 0., yticklen = 0., xthick=0.5, ythick=0.5, font_size = font_size)
            
c1 = colorbar(target=im1, orientation = 1, font_size = font_size, position = [0.9, 0.6, 0.97, 0.9], minor = 0)
c2 = colorbar(target=im2, orientation = 1, font_size = font_size, position = [0.9, 0.1, 0.97, 0.4], minor = 0)

err = ERR_XY2AZ(res.model, mat_x, mat_x*0., mat_y, mat_y*0., res.param, res.covar)

; intrinsic error maps
sAZ = err.az
sZD = err.zd

sAZ = sAZ*mask_r2
sZD = sZD*mask_r2

im3 = image(sAZ*sin(proj.zd)*!ramin, xv, yv, rgb_table=rgb, $
            current = w4, LAYOUT=[1,2,1], margin = 0.15, $
            title = 'Azimuth projection error [$\sigma_a\cdot$sin(z), arcmin]', xtitle='x [px]', ytitle='y [px]', $
            axis_style = 2, xticklen = 0., yticklen = 0., xthick=0.5, ythick=0.5, font_size = font_size)
            
im4 = image(sZD*!ramin, xv, yv, rgb_table=rgb, $
            current = w4, LAYOUT=[1,2,2], margin = 0.15, $
            title = 'Zenith distance projection error [$\sigma_z$, arcmin]', xtitle='x [px]', ytitle='y [px]', $
            axis_style = 2, xticklen = 0., yticklen = 0., xthick=0.5, ythick=0.5, font_size = font_size)
            
c3 = colorbar(target=im3, orientation = 1, font_size = font_size, position = [0.9, 0.6, 0.97, 0.9], minor = 0)
c4 = colorbar(target=im4, orientation = 1, font_size = font_size, position = [0.9, 0.1, 0.97, 0.4], minor = 0)

range_az_az = plot_range([var.err.bias.az_az-var.err.std.az_az, -4*var.err.int.az_az,$
                          var.err.bias.az_az+var.err.std.az_az, 4*var.err.int.az_az]*!ramin, border = 0.1)
                          
range_az_az[0] = max([range_az_az[0],range_az[0]])
range_az_az[1] = min([range_az_az[1],range_az[1]])      
                    
range_zd_zd = plot_range([var.err.bias.zd_zd-var.err.std.zd_zd, -4*var.err.int.zd_zd,$
                          var.err.bias.zd_zd+var.err.std.zd_zd, 4*var.err.int.zd_zd]*!ramin, border = 0.1)
                          
range_zd_zd[0] = max([range_zd_zd[0],range_zd[0]])
range_zd_zd[1] = min([range_zd_zd[1],range_zd[1]])

pb_az_az  = errorplot(var.err.az*!radeg, var.err.bias.az_az*!ramin, var.err.std.az_az*!ramin, '.-', $
                      current = w5, position = [0.12, 0.55, 0.90, 0.93], $
                      title='Azimuth bias', xtitle='a [deg]', ytitle='$\Delta$a$\cdot$sin(z) [arcmin]', $
                      xrange = [0,360], yrange=range_az_az, $
                      errorbar_capsize = 0, errorbar_thick = 0.5, $
                      sym_thick = 1., xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)

poly = POLYGON([var.err.az,reverse(var.err.az)]*!radeg, [3*var.err.int.az_az, reverse(2*var.err.int.az_az)]*!ramin, $
                /fill_background, fill_color='red', fill_transparency = 50, linestyle='', /data, target=pb_az_az)
                
poly = POLYGON([var.err.az,reverse(var.err.az)]*!radeg, [2*var.err.int.az_az, reverse(1*var.err.int.az_az)]*!ramin, $
                /fill_background, fill_color='orange', fill_transparency = 50, linestyle='', /data, target=pb_az_az)

poly = POLYGON([var.err.az,reverse(var.err.az)]*!radeg, [var.err.int.az_az,reverse(-var.err.int.az_az)]*!ramin, $
                /fill_background, fill_color='lime', fill_transparency = 50, linestyle='', /data, target=pb_az_az)
 
poly = POLYGON([var.err.az,reverse(var.err.az)]*!radeg, [-var.err.int.az_az,reverse(-2*var.err.int.az_az)]*!ramin, $
                /fill_background, fill_color='orange', fill_transparency = 50, linestyle='', /data, target=pb_az_az)
                
poly = POLYGON([var.err.az,reverse(var.err.az)]*!radeg, [-2*var.err.int.az_az,reverse(-3*var.err.int.az_az)]*!ramin, $
                /fill_background, fill_color='red', fill_transparency = 50, linestyle='', /data, target=pb_az_az)
                
pb_az_az.order, /bring_to_front           

pb_zd_zd  = errorplot(var.err.zd*!radeg, var.err.bias.zd_zd*!ramin, var.err.std.zd_zd*!ramin, '.-', $
                      current = w5, position=[0.12, 0.07, 0.90, 0.45], $
                      title='Zenith Distance bias', xtitle='z [deg]', ytitle='$\Delta$z [arcmin]', $
                      xrange = [0,90], yrange=range_zd_zd, $
                      errorbar_capsize = 0, errorbar_thick = 0.5, $
                      sym_thick = 1., xthick=0.5, ythick=0.5, thick = 0.5, font_size = font_size)
                 
poly = POLYGON([var.err.zd,reverse(var.err.zd)]*!radeg, [3*var.err.int.zd_zd, reverse(2*var.err.int.zd_zd)]*!ramin, $
                /fill_background, fill_color='red', fill_transparency = 50, linestyle='', /data, target=pb_zd_zd)
                
poly = POLYGON([var.err.zd,reverse(var.err.zd)]*!radeg, [2*var.err.int.zd_zd, reverse(1*var.err.int.zd_zd)]*!ramin, $
                /fill_background, fill_color='orange', fill_transparency = 50, linestyle='', /data, target=pb_zd_zd)

poly = POLYGON([var.err.zd,reverse(var.err.zd)]*!radeg, [var.err.int.zd_zd,reverse(-var.err.int.zd_zd)]*!ramin, $
                /fill_background, fill_color='lime', fill_transparency = 50, linestyle='', /data, target=pb_zd_zd)
 
poly = POLYGON([var.err.zd,reverse(var.err.zd)]*!radeg, [-var.err.int.zd_zd,reverse(-2*var.err.int.zd_zd)]*!ramin, $
                /fill_background, fill_color='orange', fill_transparency = 50, linestyle='', /data, target=pb_zd_zd)
                
poly = POLYGON([var.err.zd,reverse(var.err.zd)]*!radeg, [-2*var.err.int.zd_zd,reverse(-3*var.err.int.zd_zd)]*!ramin, $
                /fill_background, fill_color='red', fill_transparency = 50, linestyle='', /data, target=pb_zd_zd)
                
pb_zd_zd.order, /bring_to_front   

w1.save, files.astrometry.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w2.save, files.astrometry.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w3.save, files.astrometry.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w4.save, files.astrometry.report.name, /append, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95
w5.save, files.astrometry.report.name, /append, /close, /centimeters, /memory, /bitmap, page_size = 'A4', xmargin = 0.65, ymargin = 0.95

if isa(w1) then w1.close
if isa(w2) then w2.close
if isa(w3) then w3.close
if isa(w4) then w4.close
if isa(w5) then w5.close

end