; astrometry processing for monthly results

pro astrometry_month, par, month,                  $
                      report_astro=report_astro,   $
                      histo=histo,                 $              
                      stop=stop

compile_opt idl2

if keyword_set(report_astro) then par.config.monthly.report_astro = report_astro
if keyword_set(histo)        then par.config.monthly.histo        = histo 
if keyword_set(stop)         then par.config.monthly.stop         = stop

cd, par.config.path.dir_astrometry, current = old_dir
cd, par.camera
cd, month

; retrieving list of names for output files
files = get_files(month + '*', par)

; searching for all association and paramaters files in the month directory
ff_assoc = file_search(files.image.astrometry.assoc.name)

if ff_assoc[0] ne '' then begin

myreadcol, ff_assoc, name, julian_date , x, sx, y, sy, id, az, zd, mag, smag, $
           format=files.image.astrometry.assoc.format_r, /silent
           
message, par.camera + '_' + month + ' - processing ' + strtrim(n_elements(x),2) + ' associations.', /informational
  
endif else begin
  
  cd, old_dir
  message, par.camera + '_' + month + ' - no image results to be processed.', /continue
  return
  
endelse

; fit with model_image to estimate errors on dependent variables
x_fit = [x, y]
y_fit = [az, zd]
err   = err_xy2az(par.astrometry.model_image, x, sx, y, sy, par.astrometry.param_image, par.astrometry.param_image*0. )
me = [err.az, err.zd]

yfit = mpastro_fit(par.astrometry.model_monthly, x_fit, y_fit, param, estimates=par.astrometry.param_monthly, $
                   sigma=sigma, status=status, fita=par.astrometry.fita_monthly, measure_errors = me, covar = covar)

; if the fit status is ok
if status eq 0 then begin
  
  message, par.camera + '_' + month + ' - successful convergence achieved.', /informational
  
  err = astrometry_error({x:x, y:y, az:az, zd:zd}, {model:par.astrometry.model_monthly, param:param, sigma:sigma, covar:covar})
  
  if par.config.monthly.report_astro then $
    astrometry_report, par, par.config.monthly, files.monthly, {x:x, y:y, az:az, zd:zd, err:err}, {model:par.astrometry.model_monthly, param:param, sigma:sigma, covar:covar}
  
  ; print solution file
  print_header, files.monthly.astrometry.solution

  names = astro_model_info(par.astrometry.model_monthly)

  openw, lun, files.monthly.astrometry.solution.name, /get_lun, /append

  for i=0, n_elements(param)-1 do begin

    printf, lun, names.names[i] + ' = ', param[i], ' ± ', sigma[i], names.units[i], format = files.monthly.astrometry.solution.format_w

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
  print_header, files.monthly.astrometry.error
  
  openw, lun, files.monthly.astrometry.error.name, /get_lun, /append

  for i=0, nrads-1 do begin

    printf, lun, rads[i], bAZ[i], dAZ[i], sAZ[i], bZD[i], dZD[i], sZD[i], format = files.monthly.astrometry.error.format_w

  endfor

  close, lun & free_lun, lun
  
  ; print covar file
  print_header, files.monthly.astrometry.covar

  openw, lun, files.monthly.astrometry.covar.name, /get_lun, /append

  for i=0, n_elements(param)-1 do begin

    printf, lun, covar[*,i], format = files.monthly.astrometry.covar.format_w

  endfor

  close, lun & free_lun, lun

  if par.config.monthly.stop then begin

    stop

  endif
  
endif else begin
  
  message, par.camera + '_' + month + ' - astrometry fit do not converge.', /continue

endelse

cd, old_dir

end