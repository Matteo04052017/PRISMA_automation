; determination of the bolide position and astrometry of a detection

pro detection_astrometry, config, event, detection,  $
                          positions=positions,       $
                          fill_frames=fill_frames,   $
                          recenter=recenter,         $
                          box_bolide=box_bolide,     $
                          model_psf=model_psf,       $
                          model_bar=model_bar,       $
                          report=report,             $
                          image=image,               $
                          video=video,               $
                          stop=stop

compile_opt idl2

; retrieve pseudo from filename
info   = strsplit(detection, '_', /extract)
pseudo = info[0]

; retrieve code configuration from the config file
par = get_par(config, pseudo, /pseudo, /return0)

if ~par.file then begin

  message, detection + ' - incomplete parameters settings. Skipping this detection. Please check.', /continue
  return

endif

; retrieve files structure
files = get_files('*', par, detection=detection)

if keyword_set(positions)   then par.config.event.positions   = positions
if keyword_set(fill_frames) then par.config.event.fill_frames = fill_frames
if keyword_set(recenter)    then par.config.event.recenter    = recenter
if keyword_set(box_bolide)  then par.config.event.box_bolide  = box_bolide
if keyword_set(model_psf)   then par.config.event.model_psf   = model_psf
if keyword_set(model_bar)   then par.config.event.model_bar   = model_bar
if keyword_set(report)      then par.config.event.report      = report
if keyword_set(image)       then par.config.event.image       = image
if keyword_set(video)       then par.config.event.video       = video
if keyword_set(stop)        then par.config.event.stop        = stop

cd, detection, current = old_dir

if par.config.event.positions eq '' then begin
  
  ff_pos    = file_search('positions.txt')
  ff_newpos = file_search('newpositions.txt')
  
  if ff_pos[0] ne '' and ff_newpos[0] eq '' then ff = ff_pos[0]
  if ff_pos[0] eq '' and ff_newpos[0] ne '' then ff = ff_newpos[0]
  if ff_pos[0] ne '' and ff_newpos[0] ne '' then ff = ff_newpos[0]  
  if ff_pos[0] eq '' and ff_newpos[0] eq '' then begin
    
    cd, old_dir
    message, detection + ' - no positions file specified, nor positions.txt neither newpositions.txt can be found. Skipping this detection. Please check.', /continue
    return
    
  endif
  
endif else begin
  
  ff = file_search(par.config.event.positions)
  
  if ff[0] eq '' then begin
    
    cd, old_dir
    message, detection + ' - positions file not found. Skipping this detection. Please check.', /continue
    return
    
  endif
  
endelse

path_posfile = file_search(ff[0], /fully_qualify_path) 

; reading positions file
table = read_table(ff[0], /text)
s = size(table)

det_frame = reform(fix(table[0,*]))
strcoord  = reform(table[1,*])
data      = reform(table[2,*])

; number of detected frames
Ndet = n_elements(det_frame)

; box bolide definition
case s[1] of

  3: box = replicate(par.config.event.box_bolide, Ndet)
  4: box = reform(fix(table[3,*]))

endcase
  
ii = sort(det_frame)
det_frame = det_frame[ii]
strcoord  = strcoord[ii]
data      = data[ii]
box       = box[ii]

; extract coordinates from position string
get_coord, strcoord, xpos, ypos

; fits folder
cd, 'fits2D'

; sorting fits file
ff = file_search('frame_*.fit*')
ff = ff[sort(ff)]
N = n_elements(ff)

if par.config.event.fill_frames then begin
  
  ; filling missing frames in between
  fill_frames, ff, det_frame, Ndet, xpos, ypos
  
endif

frames = fix(strmid(ff, 6, strlen(ff[0])-1))
mlen = max(strlen(strtrim(frames,2)))

; getting fits filename from det_frame vector
frame_bolide = fits_filename(det_frame, mlen=mlen)

; converting device to ceplecha coordinates
device2ceplecha, xpos, ypos, par

; frames rotated dimension
rotdim = get_rotdim(par)

; allocating variables for fits reading
bolidi = dblarr(rotdim[0], rotdim[1], Ndet)

julian_date = dblarr(Ndet)
data        = strarr(Ndet)
exposure    = dblarr(Ndet) 

; tracking for missing frames in fits2D
ibolidi = []

; reading fits file
for i=0, Ndet-1 do begin

  ii = where(ff eq frame_bolide[i])
  ii = ii[0]
  
  if ii ne -1 then begin

    bld = rdfits(ff[ii], rotate=par.fits.rotate, header=h)
    
    bolidi[*,*,i] = bld
    
    time = sxpar(h, 'DATE-OBS')
    data[i] = time
    
    yr  = long(strmid(time,0,4))
    mn  = long(strmid(time,5,2))
    day = long(strmid(time,8,2))
    hh  = double(strmid(time,11,2))
    mm  = double(strmid(time,14,2))
    ss  = double(strmid(time,17,7))
    hr  = hh + mm/60D + ss/3600D

    ; computing julian date
    jdcnv, yr, mn, day, hr, jd
    julian_date[i] = jd
    
    ex = sxpar(h, 'EXPOSURE')
    exposure[i] = ex
    
    ibolidi = [ibolidi, i]

  endif

endfor

if n_elements(ibolidi) gt 1 then begin
  
  Ndet        = n_elements(ibolidi)
  
  det_frame   = det_frame[ibolidi]
  bolidi      = bolidi[*,*,ibolidi]
  strcoord    = strcoord[ibolidi]
  xpos        = xpos[ibolidi]
  ypos        = ypos[ibolidi]
  box         = box[ibolidi]
  julian_date = julian_date[ibolidi]
  data        = data[ibolidi]
  exposure    = exposure[ibolidi]
  
endif else begin
  
  cd, old_dir
  message, detection + ' - not enough valid frames for computation. Skipping this detection. Please check.', /continue
  return
  
endelse

cd, '..'

; filling leading zeros in data string
lzeros_datastring, data

; PSF fita
fita = get_psf_fita(par.config.event.model_psf)

; PSF model infos
info = psf_model_info(par.config.event.model_psf)

prot1 = fltarr(Ndet) + !values.f_NaN
prot2 = fltarr(info.nparam, Ndet) + !values.f_NaN

; allocating structure for results
psf = {                           $
        status:prot1,             $
        param:prot2,              $
        sigma:prot2,              $
        fwhm:prot1,               $
        s_fwhm:prot1,             $
        sat_corr:prot1,           $
        flux:prot1,               $
        s_flux:prot1,             $
        mags:prot1,               $
        s_mags:prot1,             $
        az:prot1,                 $
        s_az:prot1,               $
        zd:prot1,                 $
        s_zd:prot1,               $
        alt:prot1,                $
        s_alt:prot1,              $
        ra:prot1,                 $
        s_ra:prot1,               $
        dec:prot1,                $
        s_dec:prot1,              $
        ha:prot1,                 $
        s_ha:prot1,               $
        mag:prot1,                $
        s_mag:prot1               $
      }
       
bar = {                           $  
        status:prot1,             $
        param:prot2,              $
        sigma:prot2,              $
        fwhm:prot1,               $
        s_fwhm:prot1,             $
        flux:prot1,               $
        s_flux:prot1,             $
        mags:prot1,               $
        s_mags:prot1,             $
        az:prot1,                 $
        s_az:prot1,               $
        zd:prot1,                 $
        s_zd:prot1,               $
        alt:prot1,                $
        s_alt:prot1,              $
        ra:prot1,                 $
        s_ra:prot1,               $
        dec:prot1,                $
        s_dec:prot1,              $
        ha:prot1,                 $
        s_ha:prot1,               $
        mag:prot1,                $
        s_mag:prot1               $
      }
      
undefine, prot1, prot2

for i=0, Ndet-1 do begin

  img = reform(bolidi[*,*,i])
  
  x_in = xpos[i]
  y_in = ypos[i]
  
  this_box = box[i]
  
  min_x = x_in - this_box > 0
  max_x = x_in + this_box < rotdim[0] - 1
  min_y = y_in - this_box > 0
  max_y = y_in + this_box < rotdim[1] - 1

  nx = max_x - min_x + 1
  ny = max_y - min_y + 1
  
  xv = findgen(nx) + min_x
  yv = findgen(ny) + min_y

  mat_x = xv # (yv*0. + 1)
  mat_y = (xv*0. + 1) # yv
  
  bld = img[min_x:max_x,min_y:max_y]
  err = sqrt(par.photometry.gain*bld)
  
  if par.config.event.recenter then begin

    ma = max(bld)
    ii = where(bld eq ma)

    this_x = round(mean(mat_x[ii]))
    this_y = round(mean(mat_y[ii]))
    
    j = 0
    while (this_x ne x_in or this_y ne y_in) and j lt 10 do begin
      
      x_in = this_x
      y_in = this_y
      
      min_x = x_in - this_box > 0
      max_x = x_in + this_box < rotdim[0] - 1
      min_y = y_in - this_box > 0
      max_y = y_in + this_box < rotdim[1] - 1
    
      nx = max_x - min_x + 1
      ny = max_y - min_y + 1
      
      xv = findgen(nx) + min_x
      yv = findgen(ny) + min_y
    
      mat_x = xv # (yv*0. + 1)
      mat_y = (xv*0. + 1) # yv
      
      bld = img[min_x:max_x,min_y:max_y]
      err = sqrt(par.photometry.gain*bld)
      
      ma = max(bld)
      ii = where(bld eq ma)

      this_x = round(mean(mat_x[ii]))
      this_y = round(mean(mat_y[ii]))
      
      j = j+1
      
    endwhile
    
  endif
  
  est = [par.photometry.saturation,median(bld, /even),max(bld),x_in,y_in,1.,1.,0.]

  yfit = mpPSF_fit(par.config.event.model_psf, mat_x, mat_y, bld, param, gain=gain, estimates=est, fita = fita, sigma=sigma, CHISQ=chi2, status = status)

  ; image of original image and fitted PSF
  if 0 then begin

    im1  = image(bld, xv, yv, dimensions = [500,500], position = [0.2,0.2,0.8,0.8], $
                 xtitle = 'x [px]', ytitle = 'y [px]', axis_style = 1, rgb_table = 13)
    im1c = contour(yfit, xv+0.5, yv+0.5, overplot=im1, c_label_show = 0, $
                   n_levels = 4, c_color=0, color='white', c_thick = 2)

    stop
    if isa(im1) then im1.close

  endif
  
  psf.status[i] = status
  
  if status eq 0 then begin
    
    psf.param[*,i] = param
    psf.sigma[*,i] = sigma
    
    psf.fwhm[i]   = 2.335*mean(param[5:6])
    psf.s_fwhm[i] = 2.335*sqrt(sigma[5]^2 + sigma[6]^2)/2.
    
    param1 = [!values.f_Infinity, 0., param[2:7]]
    psf1 = psf(par.config.event.model_psf, mat_x, mat_y, param1) 
    
    param2 = [param[0]-param[1], 0., param[2:7]]
    psf2 = psf(par.config.event.model_psf, mat_x, mat_y, param2)
    
    psf.sat_corr[i] = total(psf1)/total(psf2)
    
    flux  = 2*!pi*param[2]*param[5]*param[6]/exposure[i]
    s_flux = 2*!pi*sqrt( (param[5]*param[6]*sigma[2])^2 + (param[2]*param[6]*sigma[5])^2 + (param[2]*param[5]*sigma[6])^2 )/exposure[i]
    
    psf.flux[i]  = flux
    psf.s_flux[i] = s_flux
    
    psf.mags[i]  = -2.5*alog10(flux)
    psf.s_mags[i] = 2.5*alog10(exp(1))*s_flux/flux
        
    x0    = round(param[3])
    y0    = round(param[4])
    sigx0 = param[5]
    sigy0 = param[6]

    wx0 = round(4.*sigx0)
    wy0 = round(4.*sigy0)
    
    if wx0 lt 2 then wx0 = 2
    if wy0 lt 2 then wy0 = 2
    if wx0 gt this_box then wx0 = this_box
    if wy0 gt this_box then wy0 = this_box
    
    s0    = mean([sigx0,sigy0])
    maxs0 = this_box
    
    fwhm = max([wx0,wy0])/0.637
    
    case 1 of
      
      s0 lt 1     : ap0 = [2.,5.,10.]
      s0 gt maxs0 : ap0 = round([maxs0,1.5*maxs0,3.*maxs0])
      else        : ap0 = round([3.*s0,4.*s0,6*s0])
      
    endcase

    if param[2] lt 0.01 then begin & wx0 = 2 & wy0 = 2 & fwhm = 2./0.673 & ap0 = [2,5,10] & endif
    
  endif else begin
    
    psf.sat_corr[i] = 1.
    
    x0   = x_in
    y0   = y_in
    wx0  = 2.
    wy0  = 2.
    fwhm = 2./0.673
    ap0  = [2,5,10]
    
  endelse
  
  if ap0[1]-ap0[0] lt 1 then ap0[1] = ap0[1]+1
  if ap0[2]-ap0[1] lt 1 then ap0[2] = ap0[2]+1
  
  min_x = x0 - wx0 > 0
  max_x = x0 + wx0 < rotdim[0] - 1
  min_y = y0 - wy0 > 0 
  max_y = y0 + wy0 < rotdim[1] - 1

  nx = max_x - min_x + 1
  ny = max_y - min_y + 1

  xv = findgen(nx) + min_x
  yv = findgen(ny) + min_y

  mat_x = xv # (yv*0. + 1)
  mat_y = (xv*0. + 1) # yv

  bld = img[min_x:max_x, min_y:max_y]
  err = sqrt(par.photometry.gain*bld)

  aper, img, x0, y0, flux, s_flux, bkg0, s_bkg0, 1, ap0[0], ap0[1:2], /nan, /flux, /silent

  bkg0   = bkg0[0]
  s_bkg0 = s_bkg0[0]
  
  h0 = img[x0,y0]
  
  bar.param[0,i] = par.photometry.saturation
  
  bar.param[1,i] = bkg0
  bar.param[2,i] = h0

  bar.sigma[1,i] = s_bkg0
  bar.sigma[2,i] = sqrt(par.photometry.gain*h0)
  
  flux  = psf.sat_corr[i]*flux[0]/exposure[i]
  s_flux = psf.sat_corr[i]*s_flux[0]/exposure[i]
  
  bar.flux[i]   = flux
  bar.s_flux[i] = s_flux

  bar.mags[i]   = -2.5*alog10(flux)
  bar.s_mags[i] = 2.5*alog10(exp(1))*s_flux/flux
     
  ; bar computation
  ii = where(bld lt par.photometry.saturation and bld gt bkg0 + 3*s_bkg0)
  
  if ii[0] ne -1 then begin
    
    bld1 = bld[ii]
    err1 = err[ii]
    x1   = mat_x[ii]
    y1   = mat_y[ii]

    F1 = total(bld1)

    xb = total(x1*bld1)/F1
    yb = total(y1*bld1)/F1
    
  endif else begin
    
    xb = -1
    yb = -1
    
  endelse
  
  case strlowcase(par.config.event.model_bar) of
    
    'fbc'  :     
    'deriv': cntrd, img, x0, y0, xb, yb, fwhm, /keepcenter, /silent
    'find' : gcntrd, img, x0, y0, xb, yb, fwhm, /keepcenter, /silent
     else  : begin
      
      cd, old_dir
      message, detection + ' - barycentre method ' + strlowcase(par.config.event.model_bar) + ' not implemented. Please check.'
      
     end
  
  endcase
      
  if xb[0] ne -1 and yb[0] ne -1 then begin
    
    bar.status[i] = 0
    
    s_xb = sqrt(total(((x1-xb)*err1/F1)^2))
    s_yb = sqrt(total(((y1-yb)*err1/F1)^2))
    
    sigx = sqrt(total((x1-xb)^2*bld1)/F1)
    sigy = sqrt(total((y1-yb)^2*bld1)/F1)
    
    s_sigx = !values.f_NaN
    s_sigy = !values.f_NaN
    
    bar.param[3,i] = xb
    bar.param[4,i] = yb

    bar.sigma[3,i] = s_xb
    bar.sigma[4,i] = s_yb
    
    bar.param[5,i] = sigx
    bar.param[6,i] = sigy

    bar.sigma[5,i] = s_sigx
    bar.sigma[6,i] = s_sigy
    
    bar.fwhm[i]   = 2.335*mean([sigx,sigy])
    bar.s_fwhm[i] = 2.335*sqrt(s_sigx^2 + s_sigy^2)/2.
    
  endif else bar.status[i] = 1

endfor

; computing julian date
jdcnv, yr, mn, day, hr, jd

; retrieving the astrometric solution for this camera
solution = get_solution(par, julian_date = julian_date[0], /return0)

if solution.file[0] ne '' then begin
  
  x_psf      = reform(psf.param[3,*])
  s_x_psf    = reform(psf.sigma[3,*])
  y_psf      = reform(psf.param[4,*])
  s_y_psf    = reform(psf.sigma[4,*])
  mags_psf   = reform(psf.mags)
  s_mags_psf = reform(psf.s_mags)
  
  ; applying astro/photometric solution to observation from psf method
  solve, solution, x_psf, s_x_psf, y_psf, s_y_psf, $
         az_psf, s_az_psf, zd_psf, s_zd_psf, mags_psf, s_mags_psf, mag_psf, s_mag_psf, /eff_correction
  
  alt_psf   = !pi/2. - zd_psf
  s_alt_psf = s_zd_psf
  
  ; computing RA,DEC coordinates
  hor2eq_error, alt_psf*!radeg, s_alt_psf*!radeg, az_psf*!radeg, s_alt_psf*!radeg, julian_date, ra_psf, s_ra_psf, dec_psf, s_dec_psf, ha_psf, s_ha_psf, $
                lat = par.station.latitude, lon = par.station.longitude, altitude = par.station.elevation
  
  psf.mags   = mags_psf
  psf.s_mags = s_mags_psf
  psf.az     = az_psf
  psf.s_az   = s_az_psf
  psf.zd     = zd_psf
  psf.s_zd   = s_zd_psf
  psf.alt    = alt_psf
  psf.s_alt  = s_alt_psf
  psf.ra     = ra_psf/!radeg
  psf.s_ra   = s_ra_psf/!radeg
  psf.dec    = dec_psf/!radeg
  psf.s_dec  = s_dec_psf/!radeg
  psf.ha     = ha_psf/!radeg
  psf.s_ha   = s_ha_psf/!radeg
  psf.mag    = mag_psf
  psf.s_mag  = s_mag_psf
  
  undefine, x_psf, s_x_psf, y_psf, s_y_psf
  undefine, mags_psf, s_mags_psf, az_psf, s_az_psf, zd_psf, s_zd_psf, alt_psf, s_alt_psf
  undefine, ra_psf, s_ra_psf, dec_psf, s_dec_psf, ha_psf, s_ha_psf, mag_psf, s_mag_psf
  
  x_bar      = reform(bar.param[3,*])
  s_x_bar    = reform(bar.sigma[3,*])
  y_bar      = reform(bar.param[4,*])
  s_y_bar    = reform(bar.sigma[4,*])
  mags_bar   = reform(bar.mags)
  s_mags_bar = reform(bar.s_mags)
  
  ; applying astro/photometric solution to observation from bar method
  solve, solution, x_bar, s_x_bar, y_bar, s_y_bar, $
         az_bar, s_az_bar, zd_bar, s_zd_bar, mags_bar, s_mags_bar, mag_bar, s_mag_bar, /eff_correction
  
  alt_bar   = !pi/2. - zd_bar
  s_alt_bar = s_zd_bar
  
  ; computing RA,DEC coordinates
  hor2eq_error, alt_bar*!radeg, s_alt_bar*!radeg, az_bar*!radeg, s_alt_bar*!radeg, julian_date, ra_bar, s_ra_bar, dec_bar, s_dec_bar, ha_bar, s_ha_bar, $
                lat = par.station.latitude, lon = par.station.longitude, altitude = par.station.elevation
  
  bar.mags   = mags_bar
  bar.s_mags = s_mags_bar
  bar.az     = az_bar
  bar.s_az   = s_az_bar
  bar.zd     = zd_bar
  bar.s_zd   = s_zd_bar
  bar.alt    = alt_bar
  bar.s_alt  = s_alt_bar
  bar.ra     = ra_bar/!radeg
  bar.s_ra   = s_ra_bar/!radeg
  bar.dec    = dec_bar/!radeg
  bar.s_dec  = s_dec_bar/!radeg
  bar.ha     = ha_bar/!radeg
  bar.s_ha   = s_ha_bar/!radeg
  bar.mag    = mag_bar
  bar.s_mag  = s_mag_bar
  
  undefine, x_bar, s_x_bar, y_bar, s_y_bar
  undefine, mags_bar, s_mags_bar, az_bar, s_az_bar, zd_bar, s_zd_bar, alt_bar, s_alt_bar
  undefine, ra_bar, s_ra_bar, dec_bar, s_dec_bar, ha_bar, s_ha_bar, mag_bar, s_mag_bar

endif

cd, par.config.path.dir_results

; looking whether the event directory exists
ff = file_search(event, /test_directory)

; if not, let's create it
if ff[0] eq '' then begin

  file_mkdir, event

endif

cd, event

; looking whether the detection directory exists
; in the event directory
ff = file_search(detection, /test_directory)

; if not, let's create it
if ff[0] eq '' then begin

  file_mkdir, detection

endif

cd, detection

; copying the position file to the results directory
cd, current = curr_dir
file_copy, path_posfile, curr_dir, /overwrite

; printing headers of result files
print_header, files.detection.psf.param
print_header, files.detection.psf.sigma
print_header, files.detection.psf.result
print_header, files.detection.bar.param
print_header, files.detection.bar.sigma
print_header, files.detection.bar.result

openw, lun1, files.detection.psf.param.name, /get_lun, /append
openw, lun2, files.detection.psf.sigma.name, /get_lun, /append
openw, lun3, files.detection.psf.result.name, /get_lun, /append
openw, lun4, files.detection.bar.param.name, /get_lun, /append
openw, lun5, files.detection.bar.sigma.name, /get_lun, /append
openw, lun6, files.detection.bar.result.name, /get_lun, /append

; printing results files
for i=0, Ndet-1 do begin

  printf, lun1, det_frame[i], data[i], julian_date[i], exposure[i], psf.param[*,i], psf.mags[i], $
          format = files.detection.psf.param.format_w

  printf, lun2, det_frame[i], data[i], julian_date[i], exposure[i], psf.sigma[*,i], psf.s_mags[i], $
          format = files.detection.psf.sigma.format_w

  printf, lun3, data[i], julian_date[i], psf.az[i]*!radeg, psf.s_az[i]*!radeg, psf.alt[i]*!radeg, psf.s_alt[i]*!radeg, $
          psf.ra[i]*!radeg, psf.s_ra[i]*!radeg, psf.dec[i]*!radeg, psf.s_dec[i]*!radeg, psf.mag[i], psf.s_mag[i], $
          format = files.detection.psf.result.format_w

  printf, lun4, det_frame[i], data[i], julian_date[i], exposure[i], bar.param[*,i], bar.mags[i], $
          format = files.detection.bar.param.format_w

  printf, lun5, det_frame[i], data[i], julian_date[i], exposure[i], bar.sigma[*,i], bar.s_mags[i], $
          format = files.detection.bar.sigma.format_w

  printf, lun6, data[i], julian_date[i], bar.az[i]*!radeg, bar.s_az[i]*!radeg, bar.alt[i]*!radeg, bar.s_alt[i]*!radeg, $
          bar.ra[i]*!radeg, bar.s_ra[i]*!radeg, bar.dec[i]*!radeg, bar.s_dec[i]*!radeg, bar.mag[i], bar.s_mag[i], $
          format = files.detection.bar.result.format_w

endfor

close, lun1 & free_lun, lun1
close, lun2 & free_lun, lun2
close, lun3 & free_lun, lun3
close, lun4 & free_lun, lun4
close, lun5 & free_lun, lun5
close, lun6 & free_lun, lun6

; printing pdf report
if par.config.event.report then detection_report, par, {det_frame:det_frame, julian_date:julian_date, data:data, bolidi:bolidi, psf:psf, bar:bar}, files

; saving detection image and video
if par.config.event.image or par.config.event.video then export_media, par, {det_frame:det_frame, julian_date:julian_date, data:data, box:box, bolidi:bolidi, psf:psf, bar:bar}, files

if par.config.event.stop then stop

;ff = file_search('fits2D.tar.gz')
;if ff[0] eq '' then file_tar, 'fits2D', /gzip

cd, old_dir

end