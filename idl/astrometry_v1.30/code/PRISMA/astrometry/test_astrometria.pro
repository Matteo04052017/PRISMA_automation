; testing astrometric model to determine starting points for calibration

pro test_astrometria

compile_opt idl2

config_file = '/PRISMA/settings/configuration.ini'

camera   = 'ITMA02'
this_day = '20201021'

fmodel = 'proj_rotz_exp1_asym'

this_month = get_month(this_day)
par        = get_par(config_file, camera)
catalog    = get_catalog(par.config.path.catalog)
files      = get_files(this_day, par)

!quiet  = par.config.quiet
!except = par.config.except
on_error, par.config.on_error

dimw = [550,750]
range_az = [-30,30]
range_zd = [-30,30]

useful_vars

loadct, 13, rgb_table = rgb_table

cd, par.config.path.dir_astrometry, current = old_dir
cd, par.camera
cd, this_month

info1 = file_info(files.image.astrometry.param.name)
info2 = file_info(files.image.astrometry.assoc.name)

if info1.size eq 0 or info2.size eq 0 then begin
  
  cd, old_dir
  message, par.camera + '_' + this_day + ' - no image results to be processed.'
  
endif

readcol, files.image.astrometry.param.name, junk, junk, model_image, format = '(A,A,A)', /silent
model_image = model_image[0]

case strlowcase(model_image) of
  
  'proj_poly2': begin
    
    readcol, files.image.astrometry.param.name, immagine, junk, junk, a0, xc, yc, P1, P2, $
             format=files.image.astrometry.param.format_r, /silent

    ; medie dei parametri
    param_0  = [mean(a0), mean(xc), mean(yc), mean(P1), mean(P2)]
    
  end
  
  'proj_asin1': begin
    
    readcol, files.image.astrometry.param.name, immagine, junk, junk, a0, xc, yc, F, R1, $
             format=files.image.astrometry.param.format_r, /silent

    ; medie dei parametri
    param_0  = [mean(a0), mean(xc), mean(yc), mean(F), mean(R1)]
    
  end
  
  else: begin
    
    cd, old_dir
    message, par.camera + '_' + this_day + ' - parameters file reading not implemented for ' + model_image + '. Please check.'
    
  end
  
endcase

readcol, files.image.astrometry.assoc.name, name, julian_date ,x , sx, y, sy, id, az, zd, mag_s, smag_s, $
         format=files.image.astrometry.assoc.format_r, /silent

fstars = id[sort(id)]
fstars = fstars[uniq(fstars)]

dec_me = []
x_me   = []
y_me   = []

w1 = window(dimensions = [1000,600])

p1 = plot([0,0],[1,1], /nodata, $ 
          current = w1, layout=[2,1,1], margin = 0.15, $
          title = 'Meridian and zenith point determination', xtitle='x [px]', ytitle='y [px]', $
          xrange = [par.fits.center[0]-par.fits.radius, par.fits.center[0]+par.fits.radius], $
          yrange = [par.fits.center[1]-par.fits.radius, par.fits.center[1]+par.fits.radius], $
          aspect_ratio=1)         
circle_p1 = ellipse(par.fits.center[0], par.fits.center[1], major = par.fits.radius, target=p1, color='black', $
                    thick=3, /data, FILL_TRANSPARENCY=100, linestyle=0, /clip)

for i=0, n_elements(fstars)-1 do begin
  
  ii = where(id eq fstars[i])
  jd_i = julian_date[ii]
  x_i = x[ii]
  y_i = y[ii]
  
  ct2lst, st_i, par.station.longitude, 0., jd_i
  
  ii = where(catalog.id eq fstars[i])
  alpha_i = catalog.alpha[ii]
  delta_i = catalog.delta[ii]
  
  ra_i = alpha_i/15D
  
  if min(st_i) lt ra_i and max(st_i) gt ra_i then begin
    
    ii = where(st_i gt ra_i[0] -1 and st_i lt ra_i[0] +1)
    
    if n_elements(ii) gt 6 then begin
      
      ii = sort(st_i)
      st_i = st_i[ii]
      x_i = x_i[ii]
      y_i = y_i[ii]
      x_me = [x_me, interpol(x_i, st_i, ra_i, /lsquadratic, /nan)]
      y_me = [y_me, interpol(y_i, st_i, ra_i, /lsquadratic, /nan)]
      dec_me = [dec_me, delta_i]
      
      ps = plot(x_i, y_i, '.', overplot = p1)
      
    endif
    
  endif 
  
endfor

ii = sort(dec_me)
dec_me = dec_me[ii]
x_me = x_me[ii]
y_me = y_me[ii]

xz = poly_interp(dec_me, x_me, par.station.latitude, 10, yfit = yfit_xm)
yz = poly_interp(dec_me, y_me, par.station.latitude, 10, yfit = yfit_ym)

p1m = plot(yfit_xm, yfit_ym, color='red', thick = 2, overplot=p1)
zen = ellipse(xz, yz, major = 5, minor = 5, target=p1, color='blue', fill_color='blue', thick=2, /data, linestyle=0, /clip)

px  = plot(dec_me, x_me, '.', $
           current = w1, position = [0.55,0.55,0.95,0.95], $
           xtitle = '$\delta$ [deg]', ytitle = 'x [px]', $
           sym_size = 2)
px1 = plot(dec_me, yfit_xm, color = 'red', overplot = px)
xr = px.xrange
yr = px.yrange
px2 = plot([par.station.latitude, par.station.latitude],[yr[0], xz], color='blue', margin = 0, overplot=px)
px3 = plot([xr[0], par.station.latitude],[xz, xz], color='blue', margin = 0, overplot=px)
px1.order, /send_to_back
px.xrange = xr
px.yrange = yr

py  = plot(dec_me, y_me, '.', $
           current = w1, position = [0.55,0.07,0.95,0.45], $
           xtitle = '$\delta$ [deg]', ytitle = 'y [px]', $
           sym_size = 2)
py1 = plot(dec_me, yfit_ym, color = 'red', overplot = py)
xr = py.xrange
yr = py.yrange
py2 = plot([par.station.latitude, par.station.latitude],[yr[0], yz], color='blue', margin = 0, overplot=py)
py3 = plot([xr[0], par.station.latitude],[yz, yz], color='blue', margin = 0, overplot=py)
py1.order, /send_to_back
py.xrange = xr
py.yrange = yr

if ~!quiet then print, 'xz = ', xz, format = '(A,F9.4)'
if ~!quiet then print, 'yz = ', yz, format = '(A,F9.4)'

stop

if isa(w1) then w1.close

nx = n_elements(x)

x_fit = [x, y]
y_fit = [az, zd]
err   = err_xy2az(model_image, x, sx, y, sy, param_0, param_0*0.)
me = [err.az, err.zd]

yfit = mpastro_fit(model_image, x_fit, y_fit, param, estimates=param_0, sigma=sigma, status=status, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az(model_image, x, y, param)
r        = sqrt((x-param[1])^2 + (y-param[2])^2)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

closest, dAZ

w2 = window(dimensions = dimw)

pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', $
          current = w2, LAYOUT=[1,2,1], $
          title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
          sym_thick = 0.3, xrange = [0,365], yrange=range_az)
pz = plot(zd*!radeg, dZD*!ramin, '.', $ 
          current = w2, LAYOUT=[1,2,2], $
          title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
          sym_thick = 0.3, xrange = [0,90], yrange=range_zd) 

if ~!quiet then print, param, sigma
          
stop

if isa(w2) then w2.close

case 1 of
  
  strlowcase(fmodel) eq 'proj_rot_poly2' or strlowcase(fmodel) eq 'proj_rot_poly2' or $
  strlowcase(fmodel) eq 'proj_rot_poly2_asym' or strlowcase(fmodel) eq 'proj_rotz_poly2_asym': begin
    
    ii = where(zd lt 0.2, n_ZD)

    x_ZD = r[ii]
    y_ZD = zd[ii]
    me_ZD = err.zd[ii]

    res = ladfit(x_ZD, y_ZD)
    V0 = res[1]
    
    r_interp = findgen(max(r))
    
    model    = xy2az('proj_poly2', x, y, [param[0:2],res[1],0] )
    r = sqrt( (x-param[1])^2 + (y-param[2])^2 )
    zd_model = model.zd
    dZD      = zd - zd_model
               
    ii = where(zd gt 0.7)
    
    x_ZD = r[ii]
    y_ZD = dZD[ii]
    me_ZD = err.zd[ii]
    
    W0 = median(y_ZD/x_ZD^2)
    
    fita = [1,1]
    A = [V0, W0]
    
    yfit = curvefit(r, ZD, [], A, sigma, fita = fita, function_name='gfunct_poly2', /noderivative)
    
    V0 = A[0]
    W0 = A[1]
    
    dZD = ZD - A[0]*r
    
    gfunct_poly2, r_interp, [A[0], 0], yfit0
    gfunct_poly2, r_interp, [0, A[1]], yfit1
    
    w3 = window(dimensions = [1000,400])

    pz = plot(r, zd*!radeg, '.', $
              current = w3, layout=[2,1,1], $
              title='r vs ZD', xtitle='r [px]', ytitle='z [deg]', $
              sym_thick = 0.3, xrange = [0,500])

    pz1 = plot(r_interp, yfit0*!radeg, color='red', overplot=pz, thick = 2)
    
    pz2 = plot(r, dZD*!ramin, '.', $
               current = w3, layout=[2,1,2], $
               title='ZD residuals', xtitle='r [px]', ytitle='$\delta$z [arcmin]', $
               sym_thick = 0.3, xrange = [0,500])
    
    pz1 = plot(r_interp, yfit1*!ramin, color='red', overplot=pz2, thick = 2)

    if ~!quiet then print, 'W = ', W0
    
    stop
    
    if isa(w3) then w3.close

    this_model = 'proj_poly2'

    param_0 = [param_0[0:2], V0, W0]

    yfit = mpastro_fit(this_model, x_fit, y_fit, param, estimates=param_0, sigma=sigma, status=status, measure_errors = me)

    ; valuto il modello per plottare i residui e le proiezioni
    model    = xy2az(this_model, x, y, param)
    az_model = model.az
    zd_model = model.zd
    dAZ      = az - az_model
    dZD      = zd - zd_model

    closest, dAZ

    w4 = window(dimensions = dimw)

    pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', $
      current = w4, LAYOUT=[1,2,1], $
      title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
      sym_thick = 0.3, xrange = [0,360], yrange=range_az)
    pz = plot(zd*!radeg, dZD*!ramin, '.', $
      current = w4, LAYOUT=[1,2,2], $
      title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
      sym_thick = 0.3, xrange = [0,90], yrange=range_zd)
    
  end
 
  strlowcase(fmodel) eq 'proj_rot_exp1' or strlowcase(fmodel) eq 'proj_rotz_exp1' or $ 
  strlowcase(fmodel) eq 'proj_rot_exp1_asym' or strlowcase(fmodel) eq 'proj_rotz_exp1_asym': begin
    
    ii = where(zd lt 0.2, n_ZD)

    x_ZD = r[ii]
    y_ZD = zd[ii]
    me_ZD = err.zd[ii]

    res = ladfit(x_ZD, y_ZD)
    V0 = res[1]
    
    r_interp = findgen(max(r))
    yfit    = res[0] + res[1]*r_interp
    
    model    = xy2az('proj_poly2', x, y, [param[0:2],res[1],0] )
    r = sqrt( (x-param[1])^2 + (y-param[2])^2 )
    zd_model = model.zd
    dZD      = zd - zd_model
    
    w3 = window(dimensions = [1000,400])
    
    pz = plot(r, zd*!radeg, '.', $
              current = w3, layout=[2,1,1], $
              title='r vs ZD', xtitle='r [px]', ytitle='z [deg]', $
              sym_thick = 0.3, xrange = [0,500])
              
    pz1 = plot(r_interp, yfit*!radeg, color='red', overplot=pz, thick = 2)

    pz2 = plot(r, dZD*!ramin, '.', $
               current = w3, layout=[2,1,2], $
               title='ZD residuals', xtitle='r [px]', ytitle='$\delta$z [arcmin]', $
               sym_thick = 0.3, xrange = [0,500])
              
    ii = where(zd gt 0.7)
    
    x_ZD = r[ii]
    y_ZD = alog(dZD[ii])
    me_ZD = err.zd[ii]
    
    ii = where(finite(y_ZD))
    x_ZD = x_ZD[ii]
    y_ZD = y_ZD[ii]
    me_ZD = me_ZD[ii]
    
    res1 = ladfit(x_ZD, y_ZD)
    
    S0 = exp(res1[0])
    D0 = res1[1]
    
    fita = [1,1]
    A = [S0, D0]

    yfit = curvefit(r, dZD, [], A, sigma, fita = fita, function_name='gfunct_exp1', /noderivative)

    S0 = A[0]
    D0 = A[1]
    gfunct_exp1, r_interp, A, yfit

    pz1 = plot(r_interp, yfit*!ramin, color='red', overplot=pz2, thick = 2)
    
    if ~!quiet then print, 'S = ', S0
    if ~!quiet then print, 'D = ', D0
    
    stop
    
    if isa(w3) then w3.close
    
    this_model = 'proj_exp1'
        
    param_0 = [param_0[0:2], V0, S0, D0]

    yfit = mpastro_fit(this_model, x_fit, y_fit, param, estimates=param_0, sigma=sigma, status=status, measure_errors = me)

    ; valuto il modello per plottare i residui e le proiezioni
    model    = xy2az(this_model, x, y, param)
    az_model = model.az
    zd_model = model.zd
    dAZ      = az - az_model
    dZD      = zd - zd_model
    
    closest, dAZ
    
    w4 = window(dimensions = dimw)

    pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', $
              current = w4, LAYOUT=[1,2,1], $
              title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
              sym_thick = 0.3, xrange = [0,360], yrange=range_az)
    pz = plot(zd*!radeg, dZD*!ramin, '.', $
              current = w4, LAYOUT=[1,2,2], $
              title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
              sym_thick = 0.3, xrange = [0,90], yrange=range_zd)

  end 
  
  else: begin
    
    cd, old_dir
    message, par.camera + '_' + this_day + ' - estimates computation not defined for model ' + strlowcase(fmodel) + '. Please check.'
    
  end
  
endcase
          
if ~!quiet then print, param, sigma

stop

if isa(w4) then pa.close

step = 1.
d = 30.
dim = 2*d/step + 1

xv = findgen(dim)*step + fix(xz[0]) - d
yv = findgen(dim)*step + fix(yz[0]) - d

eps = fltarr(dim,dim)
E = fltarr(dim,dim)
tool = fltarr(dim,dim)

base_model = this_model

case strlowcase(fmodel) of
  
  'proj_rot_poly2'       : this_model = 'proj_rot_poly2'
  'proj_rotz_poly2'      : this_model = 'proj_rot_poly2'
  'proj_rot_exp1'        : this_model = 'proj_rot_exp1'
  'proj_rotz_exp1'       : this_model = 'proj_rot_exp1'
  'proj_rot_poly2_asym'  : this_model = 'proj_rot_poly2'
  'proj_rotz_poly2_asym' : this_model = 'proj_rot_poly2'
  'proj_rot_exp1_asym'   : this_model = 'proj_rot_exp1'
  'proj_rotz_exp1_asym'  : this_model = 'proj_rot_exp1'
  
  else: begin
    
    cd, old_dir
    message, par.camera + '_' + this_day + ' - model conversion not implemented for ' + strlowcase(fmodel) + '. Please check.'
    
  end
  
endcase

for i=0, dim-1 do begin
  
  for j=0, dim-1 do begin
    
    x1 = xv[i]
    y1 = yv[j]
    
    p1 = [param[0], xz, yz, param[3:*]]
    
    az1 = xy2az(base_model, x1, y1, p1)
    
    E[i,j]   = az1.az
    eps[i,j] = az1.zd
    
    p1 = [param[0], x1, y1,  E[i,j], eps[i,j], param[3:*]]
    
    model    = xy2az(this_model, x, y, p1)
    az_model = model.az
    zd_model = model.zd
    dAZ      = az_model - az
    dZD      = zd_model - zd
    
    closest, dAZ
    
    tool[i,j] = total(abs(dAZ*sin(zd)/err.az), /nan)/n_elements(dAZ) + total(abs(dZD/err.zd), /nan)/n_elements(dZD)
    
  endfor
  
endfor

mi = min(tool,ii)
ind = array_indices(tool, ii)

eps0 = eps[ind[0],ind[1]]
E0 = E[ind[0],ind[1]]

xo = xv[ind[0]]
yo = yv[ind[1]]

w5 = window(dimensions = [600,600])

im = image(tool/n_elements(x), xv, yv, rgb_table = 13, $
           current = w5, margin = 0.15, $
           title = 'Estimation of (E,$\epsilon$) and ($x_O$,$y_O$)', xtitle='x$_O$ [px]', ytitle='y$_O$ [px]', $
           axis_style = 1,  xticklen = 0., yticklen = 0.)
           
cb = colorbar(target=im, orientation = 1) 

if ~!quiet then print, 'XO  = ', xo  
if ~!quiet then print, 'YO  = ', yo  
if ~!quiet then print, 'E   = ', E0  
if ~!quiet then print, 'eps = ', eps0
    
stop

case strlowcase(fmodel) of

  'proj_rot_poly2'       : begin this_model = 'proj_rot_poly2' & param_0 = [param[0], xo, yo, E0, eps0, param[3:*]] & end
  'proj_rotz_poly2'      : begin this_model = 'proj_rotz_poly2' & param_0 = [param[0], xo, yo, xz, yz, param[3:*]] & end  
  'proj_rot_exp1'        : begin this_model = 'proj_rot_exp1' & param_0 = [param[0], xo, yo, E0, eps0, param[3:*]] & end 
  'proj_rotz_exp1'       : begin this_model = 'proj_rotz_exp1' & param_0 = [param[0], xo, yo, xz, yz, param[3:*]] & end
  'proj_rot_poly2_asym'  : begin this_model = 'proj_rot_poly2' & param_0 = [param[0], xo, yo, E0, eps0, param[3:*]] & end
  'proj_rotz_poly2_asym' : begin this_model = 'proj_rotz_poly2' & param_0 = [param[0], xo, yo, xz, yz, param[3:*]] & end
  'proj_rot_exp1_asym'   : begin this_model = 'proj_rot_exp1' & param_0 = [param[0], xo, yo, E0, eps0, param[3:*]] & end
  'proj_rotz_exp1_asym'  : begin this_model = 'proj_rotz_exp1' & param_0 = [param[0], xo, yo, xz, yz, param[3:*]] & end
  
  else: begin
    
    cd, old_dir
    message, par.camera + '_' + this_day + ' - model conversion not implemented for ' + strlowcase(fmodel) + '. Please check.'

  end
  
endcase

yfit = mpastro_fit(this_model, x_fit, y_fit, param, estimates=param_0, sigma=sigma, $
                   covar=covar, status=status, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az(this_model, x, y, param)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

closest, dAZ

w6 = window(dimensions = dimw)
  
; plotto i residui
pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', $
          current = w6, LAYOUT=[1,2,1], $
          title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
          sym_thick = 0.3, xrange = [0,360], yrange=range_az)
pz = plot(zd*!radeg, dZD*!ramin, '.', $
          current = w6, LAYOUT=[1,2,2], $
          title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
          sym_thick = 0.3, xrange = [0,90], yrange=range_zd) 

if ~!quiet then print, param, sigma

stop

if isa(w5) then w5.close
if isa(w6) then w6.close

if fmodel eq 'proj_rot_poly2_asym' or fmodel eq 'proj_rotz_poly2_asym' or $
   fmodel eq 'proj_rot_exp1_asym' or fmodel eq 'proj_rotz_exp1_asym' then begin
  
  r     = sqrt((x-param[1])^2 + (y-param[2])^2)
  theta = param[0] + atan2(y-param[2],x-param[1])
  
  check_az, theta

  proj = az2xy(this_model, az, zd, param)
  x1 = proj.x
  y1 = proj.y

  r1 = sqrt((x1-param[1])^2 + (y1-param[2])^2)
  
  xf = theta
  yf = r1/r - 1
  
  stdyf = stddev(yf, /nan)

  min_alpha  = 0.
  max_alpha  = 360./!radeg
  step_alpha = 20./!radeg
  n_alpha    = (max_alpha-min_alpha)/step_alpha + 1
  
  alpha = findgen(n_alpha)*step_alpha
  dr = fltarr(n_alpha) + !values.f_NaN
  
  for i=0, n_alpha-1 do begin
    
    ii_alpha = where(xf ge alpha[i]-step_alpha/2. and xf lt alpha[i]+step_alpha/2. and abs(yf) le 3*stdyf, nii_alpha)
    
    if ii_alpha[0] ne -1 then begin

      dr[i] = median(yf[ii_alpha], /even)

    endif
    
  endfor
  
  ii = where(finite(dr))
  
  if ii[0] eq -1 then begin
    
    cd, old_dir
    message, par.camera + '_' + this_day + ' - model estimation do not converge for ' + strlowcase(fmodel) + '. Please check.'
    
  endif
  
  fita = [1,1]
  A    = [0.01, 0.]

  yfit = curvefit(alpha[ii], dr[ii], [], A, sigma, fita = fita, function_name='gfunct_sin', /noderivative)
  
  a1 = A[1]
  z1 = A[0]
  check_az, a1, z1
  A = [z1, a1]

  gfunct_sin, alpha, A, rr
  
  w7 = window(dimensions=[500,500])

  pr  = plot(xf*!radeg, yf, '.', current = w7, $ 
             xrange = [0,360], yrange=[-2*stdyf, +2*stdyf], $
             title = 'Estimation of (J,$\phi$)', xtitle = '$\theta$ [deg]', ytitle = 'r/r$_{old}$ - 1')
  pr1 = plot(alpha*!radeg, dr, color='blue', overplot=pr, thick=2)
  pr2 = plot(alpha*!radeg, rr, color='red', overplot=pr, thick=2)

  if ~!quiet then print, 'J   = ', A[0]
  if ~!quiet then print, 'phi = ', A[1]

  stop

  if isa(w7) then pr.close

  param_0 = [param[*], A[0], A[1]]

  yfit = mpastro_fit(fmodel, x_fit, y_fit, param, estimates=param_0, sigma=sigma, $
                     covar=covar, status=status, measure_errors = me)

  ; valuto il modello per plottare i residui e le proiezioni
  model    = xy2az(fmodel, x, y, param)
  az_model = model.az
  zd_model = model.zd
  dAZ      = az - az_model
  dZD      = zd - zd_model

  closest, dAZ

  w8 = window(dimensions = dimw)

  ; plotto i residui
  pa = plot(az*!radeg, dAZ*sin(ZD)*!ramin,'.', $
            current = w8, LAYOUT=[1,2,1], $
            title='Azimuth residuals', xtitle='a [deg]', ytitle='$\delta$a$\cdot$sin(z) [arcmin]', $
            sym_thick = 0.3, xrange = [0,360], yrange=range_az)
  pz = plot(zd*!radeg, dZD*!ramin, '.', $
            current = w8, LAYOUT=[1,2,2], $
            title='Zenital Distance residuals', xtitle='z [deg]', ytitle='$\delta$z [arcmin]', $
            sym_thick = 0.3, xrange = [0,90], yrange=range_zd)
            
  if ~!quiet then print, param, sigma

  stop
  
  if isa(w8) then w8.close
  
endif

end

PRO gfunct_exp1, X, A, F, pder

  F = A[0] * ( exp( A[1]*X ) - 1 )

END

PRO gfunct_sin, X, A, F, pder

  F = A[0] * sin(X - A[1])

END

PRO gfunct_poly2, X, A, F, pder

  F = A[0]*X + A[1]*X^2

END