; procedure written to test the EXPROT/EXPROT_Z model and deduce appropriate starting points

pro test_astrometria_asinrot

compile_opt idl2

config_file = '/PRISMA/configuration.ini'

modello_finale = 'ASIN7ROT_Z'

camera   = 'ITPI01'
month    = '201701'
this_day = '20170103'

par       = get_par(config_file, camera, month)
catalogue = get_catalogue(par.config.path.catalogue)
filename  = get_files(this_day, par)

yrange = [-60,60]

cd, par.config.path.dir_astrometry
cd, par.camera
cd, par.month

readcol, filename.image.astrometry.param.name, immagine, junk, junk, a0, xc, yc, P1, P2, $
         format='(A,A,A,F,F,F,F,F)', /silent
readcol, filename.image.astrometry.assoc.name, name, julian_date ,x , sx, y, sy, id, az, zd, mag_s, smag_s, $
         format='(A,D,F,F,F,F,A,A,F,F,F,F)', /silent

fstars = id[sort(id)]
fstars = fstars[uniq(fstars)]

dec_me = []
x_me   = []
y_me   = []

; medie dei parametri
param_0  = [mean(a0), mean(xc), mean(yc), mean(P1), mean(P2)]
sparam_0 = [stddev(a0), stddev(xc), stddev(yc), stddev(P1), stddev(P2)]

p1 = plot([0,0],[1,1], /nodata, xtitle='x [pixel]', ytitle='y [pixel]', title = 'Meridian and zenith point determination', $
          xrange = [par.fits.center[0]-par.fits.radius, par.fits.center[0]+par.fits.radius], $
          yrange = [par.fits.center[1]-par.fits.radius, par.fits.center[1]+par.fits.radius], aspect_ratio=1, $
          dimensions = [1000,600], layout=[2,1,1], margin = 0.15)         
circle_p1 = ellipse(par.fits.center[0], par.fits.center[1], major = par.fits.radius, target=p1, color='black', $
                    thick=3, /data, FILL_TRANSPARENCY=100, linestyle=0, /clip)

for i=0, n_elements(fstars)-1 do begin
  
  ii = where(id eq fstars[i])
  jd_i = julian_date[ii]
  x_i = x[ii]
  y_i = y[ii]
  
  ct2lst, st_i, par.station.longitude, 0., jd_i
  
  ii = where(catalogue.id eq fstars[i])
  alpha_i = catalogue.alpha[ii]
  delta_i = catalogue.delta[ii]
  
  ra_i = alpha_i/15D
  
  if min(st_i) lt ra_i and max(st_i) gt ra_i then begin
    
    ii = where(st_i gt ra_i[0] -1 and st_i lt ra_i[0] +1)
    
    if n_elements(ii) gt 6 then begin
      
      ii = sort(st_i)
      st_i = st_i[ii]
      x_i = x_i[ii]
      y_i = y_i[ii]
      x_me = [x_me, poly_interp(st_i, x_i, ra_i, 10, yfit = yfit_x)]
      y_me = [y_me, poly_interp(st_i, y_i, ra_i, 10, yfit = yfit_y)]
      dec_me = [dec_me, delta_i]
      
      ps = plot(yfit_x[1:-2], yfit_y[1:-2], overplot = p1)
      
    endif
    
  endif 
  
endfor

ii = sort(dec_me)
dec_me = dec_me[ii]
x_me = x_me[ii]
y_me = y_me[ii]

x0 = poly_interp(dec_me, x_me, par.station.latitude, 10, yfit = yfit_xm)
y0 = poly_interp(dec_me, y_me, par.station.latitude, 10, yfit = yfit_ym)

p1m = plot(yfit_xm[1:-2], yfit_ym[1:-2], color='red', thick = 2, overplot=p1)
zen = ellipse(x0, y0, major = 5, minor = 5, target=p1, color='blue', fill_color='blue', thick=2, /data, linestyle=0, /clip)

px  = plot(dec_me, x_me, '.', sym_size = 2, xtitle = '$\delta$ [deg]', ytitle = 'x [pix]', /current, layout = [2,1,2], $
           position = [0.55,0.55,0.95,0.95])
px1 = plot(dec_me, yfit_xm, color = 'red', overplot = px)
xr = px.xrange
yr = px.yrange
px2 = plot([par.station.latitude, par.station.latitude],[yr[0], x0], color='blue', margin = 0, overplot=px)
px3 = plot([xr[0], par.station.latitude],[x0, x0], color='blue', margin = 0, overplot=px)
px1.order, /send_to_back
px.xrange = xr
px.yrange = yr

py  = plot(dec_me, y_me, '.', sym_size = 2, xtitle = '$\delta$ [deg]', ytitle = 'y [pix]', /current, layout = [2,1,2], $
           position = [0.55,0.07,0.95,0.45])
py1 = plot(dec_me, yfit_ym, color = 'red', overplot = py)
xr = py.xrange
yr = py.yrange
py2 = plot([par.station.latitude, par.station.latitude],[yr[0], y0], color='blue', margin = 0, overplot=py)
py3 = plot([xr[0], par.station.latitude],[y0, y0], color='blue', margin = 0, overplot=py)
py1.order, /send_to_back
py.xrange = xr
py.yrange = yr

print, 'x0 = ', x0, format = '(A,F9.4)'
print, 'y0 = ', y0, format = '(A,F9.4)'

stop

if isa(p1) then p1.close

nx = n_elements(x)

x_fit = [x, y]
y_fit = [az, zd]
err   = err_xy2az(par.astrometry.model_image, x, sx, y, sy, param_0, param_0*0.)
me = [err.az, err.zd]

fita = get_fita(par.astrometry.model_image, param=param_0)

yfit = mpastro_fit(par.astrometry.model_image, x_fit, y_fit, param_asin, estimates=param_0, sigma=sigma_asin, status=status, fita=fita, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az(par.astrometry.model_image, x, y, param_asin)
r        = sqrt((x-param_asin[1])^2 + (y-param_asin[2])^2)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', title='Azimuth residuals', xtitle='a [deg]', $
          ytitle='$\delta$a$\cdot$sin(z) [arcmin]', sym_thick = 0.3, yrange=yrange, xrange = [0,365], $
          LAYOUT=[1,2,1], dimensions = [600,800], margin = [0.2, 0.12, 0.05, 0.12])
pz = plot(zd*!radeg, dZD*!ramin, '.', title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
          sym_thick = 0.3, yrange=yrange, xrange = [0,90], /current, LAYOUT=[1,2,2], $
          margin = [0.2, 0.12, 0.05, 0.12]) 

print, param_asin, sigma_asin, format='(5F20.10)'
          
stop

if isa(pa) then pa.close

step = 1.
d = 30
dim = 2*d/step + 1

xv = findgen(dim)*step + fix(x0[0]) - d
yv = findgen(dim)*step + fix(y0[0]) - d

eps = fltarr(dim,dim)
E = fltarr(dim,dim)
tool = fltarr(dim,dim)

for i=0, dim-1 do begin
  
  for j=0, dim-1 do begin
    
    xc = xv[i]
    yc = yv[j]
    
    E[i,j] = atan(yc - y0, xc - x0) + param_asin[0] 
    r_eps = sqrt((xc - x0)^2 + (yc - y0)^2)
    eps[i,j] = param_asin[3] * asin(r_eps / param_asin[4])
    
    p1 = [param_asin[0], xc, yc,  E[i,j], eps[i,j], param_asin[3:*]]
    
    model    = xy2az('ASINROT', x, y, p1)
    az_model = model.az
    zd_model = model.zd
    dAZ      = az_model - az
    dZD      = zd_model - zd
    
    closest, dAZ
    
    tool[i,j] = sqrt(total(abs(dAZ/err.az), /nan) + total(abs(dZD/err.zd), /nan))/n_elements(dAZ)
    
  endfor
  
endfor

mi = min(tool,ii)
ind = array_indices(tool, ii)

eps0 = eps[ind[0],ind[1]]
E0 = E[ind[0],ind[1]]

xc = xv[ind[0]]
yc = yv[ind[1]]

im = image(tool, xv, yv, rgb_table = 13, xtitle='x [pixel]', ytitle='y [pixel]', $
           title = 'Estimation of (E,$\epsilon$) and ($x_c$,$y_c$)', axis_style = 1, $
           xticklen = 0., yticklen = 0., dimensions = [600,600], position = [0.2,0.1,0.9,0.9], font_size = 14) 

print, 'xc  = ', xc  , format = '(A,F9.4)'
print, 'yc  = ', yc  , format = '(A,F9.4)'
print, 'eps = ', eps0, format = '(A,F9.4)'
print, 'E   = ', E0  , format = '(A,F9.4)'

stop

case modello_finale of
  
  'ASIN7ROT'  : begin
     
     modello_prefinale = 'ASINROT'
     param_asinrot0 = [param_asin[0], xc, yc, E0, eps0, param_asin[3:*]]
     
   end
  
  'ASIN7ROT_Z': begin 
    
    modello_prefinale = 'ASINROT_Z'
    param_asinrot0 = [param_asin[0], xc, yc, x0, y0, param_asin[3:*]]
    
  end
  
endcase

fita_asinrot = get_fita(modello_prefinale, param=param_asin)

yfit = mpastro_fit(modello_prefinale, x_fit, y_fit, param_asinrot, estimates=param_asinrot0, sigma=sigma_asinrot, $
                   covar=covar_asinrot, status=status, fita=fita_asinrot, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az(modello_prefinale, x, y, param_asinrot)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
          sym_thick = 0.3, yrange=yrange, xrange = [0,365], LAYOUT=[1,2,1], dimensions = [600,800], $
          margin = [0.2, 0.12, 0.05, 0.12])
pz = plot(zd*!radeg, dZD*!ramin, '.', title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
          sym_thick = 0.3, yrange=yrange, xrange = [0,90], /current, LAYOUT=[1,2,2], margin = [0.2, 0.12, 0.05, 0.12])
     
print, param_asinrot, sigma_asinrot, format='(7F20.10)'

stop


if isa(im) then im.close
if isa(pa) then pa.close

ii = where(zd lt 30./!radeg)

x_fit1 = [x[ii], y[ii]]
y_fit1 = [az[ii], zd[ii]]
me1 = [err.az[ii], err.zd[ii]]

fita_asinrot = get_fita(modello_prefinale, param=param_asinrot)
fita_asinrot[0:4] = 0

yfit = mpastro_fit(modello_prefinale, x_fit1, y_fit1, param_asinrot, estimates=param_asinrot, sigma=sigma_asinrot, $
                  covar=covar_asinrot, status=status, fita=fita_asinrot, measure_errors = me1)
                  
; valuto il modello per plottare i residui e le proiezioni
model    = xy2az(modello_prefinale, x, y, param_asinrot)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

r = sqrt( (x-param_asinrot[1])^2 + (y-param_asinrot[2])^2 )

min_r  = 0.
max_r  = 420
step_r = 5.
n_r    = (max_r-min_r)/step_r

r_fbias = [findgen(n_r)*step_r + step_r]
zd_bias  = fltarr(n_r)
err_zd   = fltarr(n_r)

inf = -40/!ramin
sup = 40/!ramin

good_r = []

for i=0, n_r-1 do begin

  ii_r = where(r ge r_fbias[i] - step_r and r lt r_fbias[i]+step_r and dZD gt inf and dZD lt sup)

  if ii_r[0] ne -1 then begin

    zd_bias[i] = mean(dZD[ii_r])
    err_zd[i]  = stddev(dZD[ii_r])
    good_r    = [good_r, i]

  endif

endfor

if n_elements(good_r) gt 1 then begin

  r_fbias  = r_fbias[good_r]
  zd_bias  = zd_bias[good_r]
  err_zd   = err_zd[good_r]

endif

; plotto i residui
pz   = plot(r, dZD*!ramin, '.', title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
            sym_thick = 0.3, yrange=yrange, dimension = [800,600], margin = [0.2, 0.12, 0.05, 0.12])
pzb  = plot(r_fbias, zd_bias*!ramin, 'D-', sym_thick = 2., overplot=pz, color='blue', thick = 2)
pinf = plot(r_fbias, replicate(inf*!ramin, n_r), '--', overplot=pz, color='blue', thick = 1)
psup = plot(r_fbias, replicate(sup*!ramin, n_r), '--', overplot=pz, color='blue', thick = 1)

A    = [param_asinrot[5:6], -2000., !values.f_Infinity, 1000.] 
fita = [0,0,1,0,1]

yfit = curvefit(r_fbias, zd_bias, [], A, sigma, fita = fita, function_name='gfunct_asin', /noderivative)

pfit = plot(r_fbias, yfit*!ramin, 'D-', sym_thick = 2., overplot=pz, color='red', thick = 2)

print, a, sigma, format='(5F20.10)'

stop

param_asinrot0 = [param_asinrot[0:6], A[2:4]]

fita_asinrot = get_fita(modello_finale, param=param_asinrot0)


yfit = mpastro_fit(modello_finale, x_fit, y_fit, param_asinrot, estimates=param_asinrot0, sigma=sigma_asinrot, $
                   covar=covar_asinrot, status=status, fita=fita_asinrot, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az(modello_finale, x, y, param_asinrot)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
          sym_thick = 0.3, yrange=yrange, xrange = [0,365], LAYOUT=[1,2,1], dimensions = [600,800], $
          margin = [0.2, 0.12, 0.05, 0.12])
pz = plot(zd*!radeg, dZD*!ramin, '.', title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
          sym_thick = 0.3, yrange=yrange, xrange = [0,90], /current, LAYOUT=[1,2,2], margin = [0.2, 0.12, 0.05, 0.12])
          
print, param_asinrot, sigma_asinrot, format='(10F20.10)'

stop

if isa(pa) then pa.close

; definisco le matrici di posizione per calcolare le mappe di distorsione e degli errori
; di proiezione
bsx_matXY = 2.
bsy_matXY = 2.

; definition of matrices and vector for maps
dim_x = round(par.fits.radius*2/bsx_matXY)
dim_y = round(par.fits.radius*2/bsy_matXY)

xv = findgen(dim_x)*bsx_matXY - par.fits.radius + par.fits.center[0]
yv = findgen(dim_y)*bsy_matXY - par.fits.radius + par.fits.center[1]

if isa(pa) then pa.close
if isa(pxy) then pxy.close
if isa(im) then im.close

mat_x = xv # (yv*0 + 1)
mat_sx = fltarr(dim_x,dim_y)
mat_y = (xv* 0 + 1) # yv
mat_sy = fltarr(dim_x,dim_y)
mask_r2 = fltarr(dim_x,dim_y)
r2 = sqrt((mat_x-par.fits.center[0])^2 + (mat_y-par.fits.center[1])^2)
ii = where(r2 le par.fits.radius and mat_x ge 0 and mat_y ge 0, complement = ii0)
mask_r2[ii]  = 1
mask_r2[ii0] = !values.f_NaN

param_base = get_parambase(modello_finale, param_asinrot)

proj_base = xy2az(modello_finale, mat_x, mat_y, param_base)
proj      = xy2az(modello_finale, mat_x, mat_y, param_asinrot)

dAZ_proj = abs(proj.az*mask_r2 - proj_base.az*mask_r2)
dZD_proj = abs(proj_base.zd*mask_r2 - proj.zd*mask_r2)

ii_dis = where(dAZ_proj gt !pi, complement=ii_cont)

if ii_dis[0] ne -1 then begin
  
  dAZ_proj[ii_dis] = 0.
  dAZ_proj = fill_image(fill_image(dAZ_proj, ii_dis, 5), ii_dis,5)
  
endif

im1 = image(sin(proj.zd)*dAZ_proj*!ramin, xv, yv, rgb_table=13, xtitle='x [pixel]', ytitle='y [pixel]', $
            title = 'Azimuth distorsion [$\Delta$a$\cdot$sin(z), arcmin]', axis_style = 1, $
            xticklen = 0., yticklen = 0., dimensions = [600,700])
im2 = image(dZD_proj*!ramin, xv, yv, rgb_table=13, xtitle='x [pixel]', ytitle='y [pixel]', $
            title = 'Zenithal distance distorsion [$\Delta$z, arcmin]', axis_style = 1, $
            xticklen = 0., yticklen = 0., dimensions = [600,700])
circle_im1 = ellipse(param_asinrot[1], param_asinrot[2], major = mean(param_asinrot[1:2]), target=im1, $
                     color='white', thick=3, /data, FILL_TRANSPARENCY=100, linestyle=0)
circle_im2 = ellipse(param_asinrot[1], param_asinrot[2], major = mean(param_asinrot[1:2]), target=im2, $
                     color='white', thick=3, /data, FILL_TRANSPARENCY=100, linestyle=0)
c1 = colorbar(target=im1, orientation = 0)
c2 = colorbar(target=im2, orientation = 0)

err = ERR_XY2AZ(modello_finale, mat_x, mat_sx, mat_y, mat_sy, param_asinrot, covar_asinrot)

sAZ = err.az
sZD = err.zd

sAZ = sAZ*mask_r2
sZD = sZD*mask_r2

im3 = image(sAZ*sin(proj.zd)*!rasec, xv, yv, rgb_table=13, xtitle='x [pixel]', ytitle='y [pixel]', $
            title = 'Azimuth error [$\sigma_a\cdot$sin(z), arcsec]', axis_style = 1, $
            xticklen = 0., yticklen = 0., dimensions = [600,700])
im4 = image(sZD*!rasec, xv, yv, rgb_table=13, xtitle='x [pixel]', ytitle='y [pixel]', $
            title = 'Zenithal distance error [$\sigma_z$, arcsec]', axis_style = 1, $
            xticklen = 0., yticklen = 0., dimensions = [600,700])
circle_im3 = ellipse(param_asinrot[1], param_asinrot[2], major = mean(param_asin[1:2]), target=im3, $
                     color='white', thick=3, /data, FILL_TRANSPARENCY=100, linestyle=0)
circle_im4 = ellipse(param_asinrot[1], param_asinrot[2], major = mean(param_asin[1:2]), target=im4, $
                     color='white', thick=3, /data, FILL_TRANSPARENCY=100, linestyle=0)
c3 = colorbar(target=im3, orientation = 0)
c4 = colorbar(target=im4, orientation = 0)
  
stop

if isa(im1) then im1.close
if isa(im2) then im2.close
if isa(im3) then im3.close
if isa(im4) then im4.close

end

PRO gfunct_asin, X, A, F, pder

F = A[0] * ( asin( x/A[1] + (x/A[2])^3 + (x/A[3])^5 + (X/A[4])^7 ) - asin(x/A[1]) )

;  IF N_PARAMS() GE 4 THEN pder = [[exp(A[1]*X^2)-1], [A[0]*X^2*exp(A[1]*X^2)]]

END