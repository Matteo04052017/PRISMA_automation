; astrometry processing for daily results

pro astrometry_day, par, this_day,                $
                    report_astro=report_astro,    $                
                    histo=histo,                  $
                    stop=stop

compile_opt idl2

if keyword_set(report_astro) then par.config.daily.report_astro = report_astro
if keyword_set(histo)        then par.config.daily.histo        = histo
if keyword_set(stop)         then par.config.daily.stop         = stop

this_month = get_month(this_day)

cd, par.config.path.dir_astrometry, current = old_dir
cd, par.camera
cd, this_month

; retrieving list of names for output files
files = get_files(this_day, par)

jdcnv, float(strmid(this_day,0,4)) , float(strmid(this_day,4,2)), float(strmid(this_day,6,2)), 0, jd
jd = floor(jd, /L64)

info = file_info(files.image.astrometry.assoc.name)

if info.size eq 0 then begin
  
  cd, old_dir
  message, par.camera + '_' + this_day + ' - no image results to be processed.', /continue 
  return
  
endif

; reading associations file
readcol, files.image.astrometry.assoc.name, name, julian_date, x, sx, y, sy, id, az, zd, mag_s, smag_s, $
         format = files.image.astrometry.assoc.format_r, /silent
         
message, par.camera + '_' + this_day + ' - processing ' + strtrim(n_elements(x),2) + ' associations.', /informational 

; fit with model_image to estimate errors on dependent variables
x_fit = [x, y]
y_fit = [az, zd]
err   = err_xy2az(par.astrometry.model_image, x, sx, y, sy, par.astrometry.param_image, par.astrometry.param_image*0.)
me = [err.az, err.zd]

yfit = mpastro_fit(par.astrometry.model_daily, x_fit, y_fit, param, estimates=par.astrometry.param_daily, $
                   sigma=sigma, status=status, fita=par.astrometry.fita_daily, measure_errors = me, covar = covar)

; if the fit status is ok
if status eq 0 then begin

  message, par.camera + '_' + this_day + ' - successful convergence achieved.', /informational

  ; error analysis
  err = astrometry_error({x:x, y:y, az:az, zd:zd}, {model:par.astrometry.model_daily, param:param, sigma:sigma, covar:covar})

  ; astrometry report
  if par.config.daily.report_astro then $
    astrometry_report, par, par.config.daily, files.daily, {x:x, y:y, az:az, zd:zd, err:err}, {model:par.astrometry.model_daily, param:param, sigma:sigma, covar:covar}
  
  ; print solution file
  print_header, files.daily.astrometry.solution

  names = astro_model_info(par.astrometry.model_daily)

  openw, lun, files.daily.astrometry.solution.name, /get_lun, /append

  for i=0, n_elements(param)-1 do begin

    printf, lun, names.names[i] + ' = ', param[i], ' ± ', sigma[i], names.units[i], format = files.daily.astrometry.solution.format_w

  endfor

  close, lun & free_lun, lun
  
  ; formatting error output
  rads = [err.az, err.zd]
  rads = rads[sort(rads)]
  rads = rads[uniq(rads)]
  
  nrads = n_elements(rads)
  
  bAZ  = fltarr(nrads) + !values.f_NaN
  dAZ  = fltarr(nrads) + !values.f_NaN
  sAZ  = fltarr(nrads) + !values.f_NaN
  bZD  = fltarr(nrads) + !values.f_NaN
  dZD  = fltarr(nrads) + !values.f_NaN
  sZD  = fltarr(nrads) + !values.f_NaN
  
  for i=0, nrads-1 do begin
    
    ii_az = where(err.az eq rads[i])
    ii_zd = where(err.zd eq rads[i])
    
    if ii_az[0] ne -1 then begin
      
      bAZ[i] = err.bias.az_az[ii_az]
      dAZ[i] = err.std.az_az[ii_az]
      sAZ[i] = err.int.az_az[ii_az]
      
    endif 
    
    if ii_zd[0] ne -1 then begin
      
      bZD[i] = err.bias.zd_zd[ii_zd]
      dZD[i] = err.std.zd_zd[ii_zd]
      sZD[i] = err.int.zd_zd[ii_zd]
      
    endif
    
  endfor
  
  ; print error file
  print_header, files.daily.astrometry.error
  
  openw, lun, files.daily.astrometry.error.name, /get_lun, /append

  for i=0, nrads-1 do begin

    printf, lun, rads[i], bAZ[i], dAZ[i], sAZ[i], bZD[i], dZD[i], sZD[i], format = files.daily.astrometry.error.format_w

  endfor

  close, lun & free_lun, lun
  
  ; print covar file
  print_header, files.daily.astrometry.covar

  openw, lun, files.daily.astrometry.covar.name, /get_lun, /append

  for i=0, n_elements(param)-1 do begin

    printf, lun, covar[*,i], format = files.daily.astrometry.covar.format_w

  endfor

  close, lun & free_lun, lun
  
  ; param-sigma file
  update_daily_file, files.daily.astrometry.param, this_day, [jd, n_elements(x), param], par.astrometry.model_daily
  update_daily_file, files.daily.astrometry.sigma, this_day, [jd, n_elements(x), sigma], par.astrometry.model_daily

  if par.config.daily.stop then begin

    stop

  endif

endif else begin
    
  message, par.camera + '_' + this_day + ' - astrometry fit do not converge.', /continue

endelse

cd, old_dir

end