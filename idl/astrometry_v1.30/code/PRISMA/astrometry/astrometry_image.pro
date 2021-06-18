; astrometry processing for image data, find and correlation algorithm and photometry calibration

pro astrometry_image, par, this_day, captures,             $
                      report_photo=report_photo,           $
                      yplot=yplot,                         $
                      cat_yplot=cat_yplot,                 $
                      stop_iter=stop_iter,                 $
                      stop_image=stop_image,               $
                      stop=stop                            

compile_opt idl2

if keyword_set(report_photo) then par.config.image.report_photo = report_photo
if keyword_set(yplot)        then par.config.image.yplot        = yplot                      
if keyword_set(cat_yplot)    then par.config.image.cat_yplot    = cat_yplot
if keyword_set(stop_image)   then par.config.image.stop_image   = stop_image
if keyword_set(stop_iter)    then par.config.image.stop_iter    = stop_iter
if keyword_set(stop)         then par.config.image.stop         = stop            

cd, par.config.path.dir_astrometry, current = old_dir

; rebin factor for image and association display
rebin = 2.

; retrieving month string
this_month = get_month(this_day)

; retrieving list of names for output files
files = get_files(this_day, par)

; loading catalog structure from txt
catalog = get_catalog(par.config.path.catalog)

n = n_elements(captures)

if n le 1 then begin
  
  cd, old_dir
  message, par.camera + '_' + this_day + ' - not enough frames to compute astrometry properly.', /continue 
  return
  
endif

name_captures = file_basename(captures)

; frames rotated dimensions
rotdim  = get_rotdim(par)

stack   = fltarr(rotdim[0],rotdim[1], n)
headers = list()

ii_dim = []
for i=0, n-1 do begin
  
  ; reading the fits file
  img = rdfits(captures[i], rotate=par.fits.rotate, header=h)

  s = size(img)

  if s[0] eq 2 and s[1] eq rotdim[0] and s[2] eq rotdim[1] then begin
    
    stack[*,*,i] = img
    headers.add, h
    ii_dim = [ii_dim, i]
    
  endif 
  
endfor

n = n_elements(ii_dim)

if n gt 1 then begin

  captures      = captures[ii_dim]
  name_captures = name_captures[ii_dim]
  stack         = stack[*,*,ii_dim]

endif else begin
  
  cd, old_dir
  message, par.camera + '_' + this_day + ' - not enough frames to compute astrometry properly.', /continue
  return
  
endelse

; retrieve skypoints for sky magnitude computation
skyp = get_skypoints()

; model info for image model
info = astro_model_info(par.astrometry.model_image)
  
; defining some empty vectors
exposure    = fltarr(n)
julian_date = dblarr(n)
sun_az      = fltarr(n)
sun_zd      = fltarr(n)
sun_alt     = fltarr(n)
moon_az     = fltarr(n)
moon_zd     = fltarr(n)
moon_alt    = fltarr(n)
moon_phase  = fltarr(n)
info_mag    = intarr(n)
nstars      = fltarr(n)
scalev      = fltarr(n)
Cv          = fltarr(n) + par.photometry.C
s_Cv        = fltarr(n) 
Kv          = fltarr(n) + par.photometry.k
s_Kv        = fltarr(n)
mag_sky     = fltarr(21, n)
s_mag_sky   = fltarr(21, n)
param       = fltarr(info.nparam, n)
sigma       = fltarr(info.nparam, n)

x_phot  = []
y_phot  = []
me_phot = []

; defining CCD position vectors
xv = indgen(rotdim[0])
yv = indgen(rotdim[1])

; defining CCD position matrices
mat_x = xv # (yv*0 + 1)
mat_y = (xv*0 + 1) # yv            
 
; retrieving the radial plate scale of the CCD
scale = get_astro_scale(par.astrometry.model_image, par.astrometry.param_image)
scalev = scalev + scale

mask_sim = intarr(n) + 1

for i=0, n-1 do begin
  
  img = stack[*,*,i]
  h   = headers[i]
  
  ; reading time from the header
  time   = sxpar(h, 'DATE-OBS')
  yr     = long(strmid(time,0,4))
  mn     = long(strmid(time,5,2))
  day    = long(strmid(time,8,2))
  hh     = double(strmid(time,11,2))
  mm     = double(strmid(time,14,2))
  ss     = double(strmid(time,17,strlen(time)-17))
  hr     = hh + mm/60D + ss/3600D
  
  ; reading exposure from header
  ex = sxpar(h, 'EXPOSURE')
  exposure[i] = ex

  ; computing julian day
  jdcnv, yr, mn, day, hr, jd  
  julian_date[i] = jd

  ; computing sun ephemeris
  sunpos, jd, sun_alpha, sun_delta

  ; converting to horizontal coordinates
  eq2hor, sun_alpha, sun_delta, jd, s_alt, s_az, sun_ha, LAT=par.station.latitude, LON=par.station.longitude, $
          ALTITUDE=par.station.elevation
  
  s_az  = s_az/!radeg
  s_alt = s_alt/!radeg
  s_zd  = !pi/2. - s_alt
  
  sun_az[i]  = s_az 
  sun_alt[i] = s_alt
  sun_zd[i]  = s_zd
  
  ; computing moon ephemeris
  moonpos, jd, moon_alpha, moon_delta
  
  ; computing moon phase
  mphase, jd, k  
  moon_phase[i] = k
  
  ; converting to horizontal coordinates
  eq2hor, moon_alpha, moon_delta, jd, m_alt, m_az, moon_ha, LAT=par.station.latitude, LON=par.station.longitude, $
          ALTITUDE=par.station.elevation
  
  m_az  = m_az/!radeg
  m_alt = m_alt/!radeg
  m_zd  = !pi/2 - m_alt
  
  moon_alt[i] = m_alt
  moon_az[i]  = m_az 
  moon_zd[i]  = m_zd
  
  ; computing expected CCD position at points for sky magnitude evaluation
  xy_v = az2xy(par.astrometry.model_image, skyp.az, skyp.zd, par.astrometry.param_image)
  x_v = xy_v.x
  y_v = xy_v.y
  
  ; computing flux for sky magnitude evaluation (aperture photometry)
  aper, img, x_v, y_v, junk, junk, ski, sski, 1, par.photometry.sky_aper[0], par.photometry.sky_aper[1:2], $
        /nan, /flux, /silent 
  
  ; ZD efficiency correction
  eff_correction, ski, skyp.zd, err=sski, /flux   
  
  ; computing magnitudes from flux
  mag_sky[*,i]   = -2.5*alog10(ski/exposure[i]) + 5.*alog10(scalev[i]*!rasec)
  s_mag_sky[*,i] = 2.5*alog10(exp(1))*sski/ski
    
endfor

; checking azimuth values range
check_az, moon_az, moon_zd
check_az, sun_az, sun_zd

; excluding frames with sun
ii_ok = where(sun_alt lt par.ephemeris.sun_alt_lim and exposure eq par.photometry.exposure, m)

; if there are no frames without sun saturation
if m le 1 then begin
  
  cd, old_dir
  message, par.camera + '_' + this_day + ' - no frame respect sun ephemeris condition or exposure time settings.', /continue
  return
  
endif
  
; let's erase frame that we will not use in computation, but remember the definition of ii_ok (j)
stack = stack[*,*,ii_ok]

; get a copy of stack matrix
stack1 = stack

; computing expected moon positions on the CCD to mask is phase is greater then a given limit
moon_xy = az2xy(par.astrometry.model_image, moon_az, moon_zd, par.astrometry.param_image)
moon_x = moon_xy.x
moon_y = moon_xy.y

; retrieve the mask for this camera  
mask = get_mask(par, ii_R=ii_R, ii_extR=ii_extR)

; if there are no good pixels
if ii_R[0] eq -1 then begin
  
  cd, old_dir
  message, par.camera + '_' + this_day + ' - please check estimation of the center, radius and horizon width in the ' + $
           par.camera + '.ini file, or the mask definition.'
  
endif

; looking whether the astrometry directory for the camera exists
ff = file_search(par.camera, /test_directory)

; if not, let's create it
if ff[0] eq '' then begin

  file_mkdir, par.camera

endif

cd, par.camera

; looking whether the astrometry directory for the month exists
; in the camera directory
ff = file_search(this_month, /test_directory)

; if not, let's create it
if ff[0] eq '' then begin

  file_mkdir, this_month

endif

cd, this_month

for i=0, m-1 do begin
  
  ; j is the index of the whole arrays
  j = ii_ok[i]
  
  ; masking the moon
  if moon_phase[j] gt par.ephemeris.moon_phase_lim and moon_alt[j] gt par.ephemeris.moon_alt_lim $
  and par.ephemeris.r_moon_mask gt 0 then begin
    
    temp = stack[*,*,i]
    dist_moon = sqrt(float(mat_x-moon_x[j])^2+float(mat_y-moon_y[j])^2) 
    ii_moon = where(dist_moon lt par.ephemeris.r_moon_mask)
    if ii_moon[0] ne -1 then temp[ii_moon] = !values.f_NaN
    stack[*,*,i]  = temp
    
  endif
  
endfor

; arrays of median (will have 'i' index as stack)
median = stack_median(stack, ii_R=ii_R)

; 'superflat' computation
supflat = superflat(stack, median=median)

; 'flat-field' computation
flat = flatfield(stack, supflat, median=median)

; restore original frames
stack = stack1
undefine, stack1

; count variable to track number of total associated stars
nfound = 0

; printing file headers
print_header, files.image.astrometry.assoc
print_header, files.image.astrometry.param
print_header, files.image.astrometry.sigma

; cycle on selected images
for i=0, m-1 do begin
  
  ; j is the index of whole arrays
  j = ii_ok[i]
  
  id       = catalog.id
  typ      = catalog.type
  spectyp  = catalog.spectype
  alpha    = catalog.alpha
  delta    = catalog.delta
  mag      = catalog.mag[*,par.photometry.band]
  n_stars  = catalog.n
    
  ; converting to horizontal coordinates
  eq2hor, alpha, delta, replicate(julian_date[j],n_stars), alt, az, ha, LAT=par.station.latitude, $
          LON=par.station.longitude, ALTITUDE=par.station.elevation

  ; converting to radiant angle
  alpha = alpha/!radeg
  delta = delta/!radeg
  alt   = alt/!radeg
  az    = az/!radeg
  
  ; computing zenith distance
  zd = !pi/2. - alt
  
  ; checking azimuth and zenith distance values
  check_az, az, zd
  
  ; back-up of the original image
  img_plot = stack[*,*,i]
  
  ; getting the flatten frame
  img = flat[*,*,i]
  
  ; including only good pixels
  img[ii_extR] = 0.
  
  ; calling source finding routine
  find, img, x, y, flux, sharp, roundness, par.find.h_min2, par.find.fwhm, par.find.roundlim, par.find.sharplim, /silent

  ; if no stars are found, break
  if n_elements(x) eq 0 then continue
  
  ; aperture photometry for found sources
  aper, img_plot, x, y, flux, sflux, ski, sski, 1, par.photometry.star_aper[0], par.photometry.star_aper[1:2], $
        /nan, /flux, /silent

  ; excluding negative flux sources
  ii = where(flux gt 0)
  
  if ii[0] ne -1 then begin
    
    x         = x[ii]
    y         = y[ii]
    flux      = flux[ii]
    sflux     = sflux[ii]
    ski       = ski[ii]
    sski      = sski[ii]
    sharp     = sharp[ii]
    roundness = roundness[ii]
    
  endif else begin
     
    continue
    
  endelse
  
  ; screen plot window for visualizing associations
  if par.config.image.yplot then window, 0, xs=round(rotdim[0]/rebin), ys=round(rotdim[1]/rebin)
  
  ; computing magnitudes
  mag_strum  = -2.5*alog10(flux/exposure[j])
  smag_strum = 2.5*alog10(exp(1))*sflux/flux
  
  ; computing width and errors
  nfind = n_elements(x)
  sig = par.find.fwhm/(2.*sqrt(2.*alog(2.)))
  sx = replicate(par.find.sx, nfind)
  sy = replicate(par.find.sy, nfind)
  
  ; setting initial iteration properties
  h_min_iter   = par.find.h_min1
  alt_lim_iter = par.find.alt_lim1
  mag_lim_iter = par.find.mag_lim1
  r_corr_iter  = par.find.r_corr1

  ; astrometry iteration
  for k = 0, par.find.max_iter-1 do begin

    ii = where(flux/median[i] ge h_min_iter, n_find)

    if n_find gt 0 then begin
      
      x_iter    = x[ii]
      sx_iter   = sx[ii]
      y_iter    = y[ii]
      sy_iter   = sy[ii]
      mag_iter  = mag_strum[ii]
      smag_iter = smag_strum[ii]
      
    endif else begin
      
      break
      
    endelse
    
    ; excluding stars that do not respect given limits 
    ii = where(alt ge alt_lim_iter and mag lt mag_lim_iter, n_stars)
    
    if n_stars gt 0 then begin
      
      id_ctlg      = id[ii]
      typ_ctlg     = typ[ii]
      spectyp_ctlg = spectyp[ii]
      alpha_ctlg   = alpha[ii]
      delta_ctlg   = delta[ii]
      alt_ctlg     = alt[ii]
      az_ctlg      = az[ii]
      zd_ctlg      = zd[ii]
      ha_ctlg      = ha[ii]
      mag_ctlg     = mag[ii]
      
    endif else begin
      
      break
      
    endelse

    ; defining catalog structure to be passed at the astrometry function
    ctlg = {id:id_ctlg, type:typ_ctlg, spectype:spectyp_ctlg, alpha:alpha_ctlg, delta:delta_ctlg, az:az_ctlg, $
            alt:alt_ctlg, zd:zd_ctlg, ha:ha_ctlg, mag:mag_ctlg, n:n_stars }
            
    ; plotting found stars
    if par.config.image.yplot then begin

      tvscl, bytscl(congrid(img_plot, round(rotdim[0]/rebin), round(rotdim[1]/rebin)), 0, max(img_plot))

      tvcircle, (par.fits.radius-par.fits.horizon)/rebin, par.fits.center[0]/rebin , par.fits.center[1]/rebin, color='blue', /device

      ; plotting every stars found
      for ix=0, n_find-1 do begin

        tvcircle, 5./rebin, x_iter[ix]/rebin, y_iter[ix]/rebin, color='red', /device

      endfor
      
    endif
    
    if k eq 0 then begin
        
      param_old = par.astrometry.param_image
      
      ; calling the astrometry function for the first time in the cycle element
      res = f_astro0(par.astrometry.model_image, x_iter, y_iter, sx_iter, sy_iter, mag_iter, smag_iter, ctlg, $
                     param_old, par.astrometry.fita_image, r_corr_iter)
      
      if par.config.image.yplot and par.config.image.cat_yplot and res.match.status ne 0 then begin
          
          xy_proj = az2xy(par.astrometry.model_image, ctlg.az, ctlg.zd, par.astrometry.param_image)
          x_proj  = xy_proj.x
          y_proj  = xy_proj.y
          
          ; plotting expected positions for all the catalog stars
          for ix=0, n_elements(x_proj)-1 do begin
  
            tvcircle, 5./rebin, xy_proj.x[ix]/rebin, xy_proj.y[ix]/rebin, color='yellow', /device
  
          endfor
        
        if par.config.image.stop_iter then stop
        
      endif
      
    endif else begin
      
      param_old = res.proj.param
      
      ; calling the astrometry function
      res = f_astro(par.astrometry.model_image, x_iter, y_iter, sx_iter, sy_iter, mag_iter, smag_iter, ctlg, res, r_corr_iter)
      
    endelse
    
    if res.match.status ne 0 then break  
    if k ge 1 and res.match.n lt par.find.n_min then break   
    
    ; plotting found and associated stars
    if par.config.image.yplot then begin
     
     if par.config.image.cat_yplot then begin
        
          xy_proj = az2xy(par.astrometry.model_image, ctlg.az, ctlg.zd, res.proj.param)
          x_proj  = xy_proj.x
          y_proj  = xy_proj.y
          
          ; plotting expected positions for all the catalog stars
          for ix=0, n_elements(x_proj)-1 do begin
  
            tvcircle, 5./rebin, xy_proj.x[ix]/rebin, xy_proj.y[ix]/rebin, color='yellow', /device
  
          endfor
        
      endif else begin
        
        ; plotting expected positions for only associated catalog stars
        for ix=0, res.match.n-1 do begin

          tvcircle, 5./rebin, res.match_ctlg.x[ix]/rebin, res.match_ctlg.y[ix]/rebin, color='yellow', /device

        endfor
        
      endelse
      
    endif
      
    ; at the third iteration, let's modify some setting for the algorithm      
    if k eq par.find.switch_iter then begin
      
      h_min_iter   = par.find.h_min2 
      alt_lim_iter = par.find.alt_lim2    
      mag_lim_iter = par.find.mag_lim2
      r_corr_iter  = par.find.r_corr2
      
    endif
    
    if par.config.image.stop_iter then stop
    
    ; convergence criteria to exit from the iteration
    dpar = res.proj.param - param_old 
    
    if (sqrt(total(dpar^2)) lt par.find.param_tool or k eq par.find.max_iter-1) and k gt par.find.min_iter then begin
      
      nfound += res.match.n
      nstars[j]  = res.match.n
      param[*,j] = res.proj.param
      sigma[*,j] = res.proj.sigma       
      
      this_mag = res.match.mag
      this_smag = res.match.smag   
      
      ii_mag = where(finite(this_mag), n_mag)   
      
      ; compute photometry if enough stars were associated
      if n_mag ge par.find.n_min then begin
        
        p0   = [par.photometry.C, par.photometry.k]
        fita = [1,1]
        
        eff_correction, this_mag, res.match_ctlg.zd, err=this_smag, /mag
        
        xi = air_mass(res.match_ctlg.az, res.match_ctlg.zd)
        yi = res.match_ctlg.mag - this_mag

        x1 = xi[ii_mag]
        y1 = yi[ii_mag]
        me = this_smag[ii_mag]
        
        x_phot  = [x_phot, x1]
        y_phot  = [y_phot, y1]
        me_phot = [me_phot, me]                 

        yfit = mpladfit(x1, y1, p, estimates=p0, measure_errors=me, sigma=sp, status = status, fita = fita, chisq=chi2)
        
        if status eq 0 and p[1] lt 0. then begin
          
          info_mag[j] = 1

          ; saving C and k computed values
          Cv[j]   = p[0]
          Kv[j]   = p[1]
          s_Cv[j] = sp[0]
          s_Kv[j] = sp[1]

        endif

      endif else begin
        
        p  = [par.photometry.C, par.photometry.k]
        sp = [0., 0.]
        
      endelse           
      
      ; if stop was selected, plot some results
      if par.config.image.stop_image then begin
        
        ; computing astrometric residuals
        model    = xy2az(par.astrometry.model_image, res.match.x, res.match.y, res.proj.param)
        r        = sqrt((res.match.x-res.proj.param[1])^2+(res.match.y-res.proj.param[2])^2)
        theta    = atan(res.match.y-res.proj.param[2], res.match.x-res.proj.param[1])
        az_model = model.az
        zd_model = model.zd
        dAZ      = res.match_ctlg.az - az_model
        dZD      = res.match_ctlg.zd - zd_model
        
        closest, dAZ
        
        ; astrometric residuals plots    
        w1 = window(dimensions = [600,850])
        
        pa = plot(res.match_ctlg.az*!radeg, dAZ*sin(res.match_ctlg.zd)*!ramin,'*', $
                  current = w1, LAYOUT=[1,2,1], margin = [0.2, 0.12, 0.05, 0.12], $
                  title='Azimuth residuals', xtitle='AZ [deg]', ytitle='dAZ$\cdot$sin(ZD) [arcmin]', $
                  xrange = [0,360], sym_thick = 0.3)
        pz = plot(res.match_ctlg.zd*!radeg, dZD*!radeg*60.,'*', $
                  current = w1, LAYOUT=[1,2,2], margin = [0.2, 0.12, 0.05, 0.12], $
                  title='Zenital Distance residuals', xtitle='ZD [deg]', ytitle='dZD [arcmin]', $
                  xrange = [0,90], sym_thick = 0.3)
                  
        print, res.proj.param, res.proj.sigma

        if info_mag[j] eq 1 then begin
                 
          step = (max(x1)-min(x1))/29.
          xi_fit = findgen(30)*step + min(x1)
          yi_fit = p[0] + p[1]*xi_fit
          
          ; photometric plots
          pmag  = errorplot(x1, y1, me, '.', title = 'Photometric calibration', xtitle = 'AIRMASS', ytitle = '$\Delta m$', $
                            sym_size = 8, errorbar_capsize = 0.05, sym_filled = 1)
          pmag1 = plot(xi_fit, yi_fit, color='red', overplot=pmag, thick = 2)
          
          print, p, sp
          
        endif
       
        stop
  
        if isa(w1) then w1.close
        if isa(pmag) then pmag.close
        
      endif

      openw, lun, files.image.astrometry.param.name, /get_lun, /append
      printf, lun, name_captures[j], julian_date[j], res.match.n, res.proj.param, format = files.image.astrometry.param.format_w
      close, lun & free_lun, lun

      openw, lun, files.image.astrometry.sigma.name, /get_lun, /append
      printf, lun, name_captures[j], julian_date[j], res.match.n, res.proj.sigma, format = files.image.astrometry.sigma.format_w
      close, lun & free_lun, lun

      openw, lun, files.image.astrometry.assoc.name, /get_lun, /append

      for imatch=0, res.match.n-1 do begin

        printf, lun, name_captures[j], julian_date[j], res.match.x[imatch], res.match.sx[imatch], res.match.y[imatch], $
                     res.match.sy[imatch], res.match_ctlg.id[imatch], res.match_ctlg.az[imatch], res.match_ctlg.zd[imatch], $
                     res.match.mag[imatch], res.match.smag[imatch], format = files.image.astrometry.assoc.format_w

      endfor

      close, lun & free_lun, lun
       
      break
        
    endif
    
  endfor
  
endfor

message, par.camera + '_' + this_day + ' - found ' + strtrim(nfound,2) + ' associations.', /informational

if nfound eq 0 then begin
  
  file_delete, files.image.astrometry.assoc.name
  file_delete, files.image.astrometry.param.name
  file_delete, files.image.astrometry.sigma.name
  
endif

; in each case, print photometry results to file
ii_phot  = where(info_mag eq 1, n_phot)

fm = 0
  
if ii_phot[0] ne -1 or n_elements(x_phot) gt 0 then begin
  
  p0   = [par.photometry.C, par.photometry.k]
  fita = [1,1]
  
  yfit = mpladfit(x_phot, y_phot, p, estimates=p0, measure_errors=me_phot, sigma=sp, status = status, fita = fita, chisq=chi2)
  
  if status eq 0 and p[1] lt 0. then begin
    
    fm = 1

    Cm = p[0]
    Km = p[1]

    s_Cm = sp[0]
    s_Km = sp[1]
    
  endif else begin
    
    Cm = par.photometry.C
    Km = par.photometry.k

    s_Cm = 0.
    s_Km = 0.
    
  endelse
  
endif else begin

  Cm = par.photometry.C
  Km = par.photometry.k

  s_Cm = 0.
  s_Km = 0.
  
endelse
  
mph    = mean(moon_phase[ii_ok], /NaN)
mzd    = min(moon_zd[ii_ok], /NaN)

Zm  = median(mag_sky[0,ii_ok], /even)
sZm = sqrt(mean((mag_sky[0,ii_ok]-Zm)^2, /NaN))
Mm  = median(mag_sky[1:8,ii_ok], /even)
sMm = sqrt(mean((mag_sky[1:8,ii_ok]-Mm)^2, /NaN))
Lm  = median(mag_sky[9:20,ii_ok], /even)
sLm = sqrt(mean((mag_sky[9:20,ii_ok]-Lm)^2, /NaN))

jdcnv, float(strmid(this_day,0,4)) , float(strmid(this_day,4,2)), float(strmid(this_day,6,2)), 0, jd
jd = floor(jd, /L64)

; print daily photometry param-sigma files
update_daily_file, files.daily.photometry.param, this_day, [jd, nfound, fm, par.photometry.exposure, mph, mzd, scale, Cm, Km, Zm, Mm, Lm], par.astrometry.model_image
update_daily_file, files.daily.photometry.sigma, this_day, [jd, nfound, fm, par.photometry.exposure, mph, mzd, scale, s_Cm, s_Km, sZm, sMm, sLm], par.astrometry.model_image

; print photometry solution file
print_header, files.daily.photometry.solution

openw, lun, files.daily.photometry.solution.name, /get_lun, /append

printf, lun, 'c = ', Cm, ' ± ', s_Cm, '/', format = files.daily.photometry.solution.format_w
printf, lun, 'k = ', Km, ' ± ', s_Km, '/', format = files.daily.photometry.solution.format_w

close, lun & free_lun, lun
  
; print astrometry files
print_header, files.image.photometry.param
print_header, files.image.photometry.sigma
  
openw, lun, files.image.photometry.param.name, /get_lun, /append
openw, lun1, files.image.photometry.sigma.name, /get_lun, /append
 
for i=0, n-1 do begin
    
  printf, lun, name_captures[i], julian_date[i], nstars[i], info_mag[i], exposure[i], $
               moon_phase[i], moon_az[i], moon_zd[i], sun_az[i], sun_zd[i], $
               scalev[i], Cv[i], Kv[i], mag_sky[*,i], $
               format = files.image.photometry.param.format_w
                 
  printf, lun1, name_captures[i], julian_date[i], nstars[i], info_mag[i], exposure[i], $
                moon_phase[i], moon_az[i], moon_zd[i], sun_az[i], sun_zd[i], $
                scalev[i], s_Cv[i], s_Kv[i], s_mag_sky[*,i], $
                format = files.image.photometry.sigma.format_w
    
endfor
  
close, lun  & free_lun, lun
close, lun1 & free_lun, lun1
  
if par.config.image.report_photo then $
   photometry_report, par, files.daily, {julian_date:julian_date, mag_sky:mag_sky + Cm, exposure:exposure}
   
if par.config.image.stop then stop

cd, old_dir
  
end