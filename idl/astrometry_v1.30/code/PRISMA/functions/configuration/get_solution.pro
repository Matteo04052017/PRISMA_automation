; function that retrieve the astrometric solution

function get_solution, par, julian_date=julian_date, return0=return0

compile_opt idl2

if ~isa(return0) then return0=0

file = ['','','']
C    = !values.f_NaN
k    = !values.f_NaN

cd, par.config.path.dir_solutions, current = old_dir

dd = file_search(par.camera, /test_directory)

if dd eq '' then begin
  
  cd, old_dir
  message, par.camera + ' : astrometric solution not listed in ' + par.config.path.dir_solutions + '. Please check.', /continue
  retv = { file:file, C:C, k:k }
  if return0 then return, retv else retall
  
endif

cd, dd[0]

files = get_files('*', par)

ff_solution = file_search(files.monthly.astrometry.solution.name)

if ff_solution eq '' then begin
  
  cd, old_dir
  message, par.camera + ': no astrometric solution file can be found. Please check.', /continue
  retv = { file:file, C:C, k:k }
  if return0 then return, retv else retall
  
endif

if n_elements(ff_solution) gt 1 then begin
  
  cd, old_dir
  message, par.camera + ': found more than one astrometric solution file. Please check.', /continue
  retv = { file:file, C:C, k:k }
  if return0 then return, retv else retall
  
endif

file_solution = ff_solution[0]
file[0] = file_solution

readcol, file_solution, junk, junk, model, format = '(A,A,A)', /silent
model_solution = model[0]

readcol, file_solution, junk, junk, param, junk, sigma, junk, format = files.monthly.astrometry.solution.format_r, /silent

error = 0.
covar = 0.

ff_error = file_search(files.monthly.astrometry.error.name)

if n_elements(ff_error) gt 1 then begin
  
  cd, old_dir
  message, par.camera + ' : found more than one astrometric error file. Please check.', /continue
  retv = { file:file, C:C, k:k }
  if return0 then return, retv else retall
  
endif

if ff_error[0] ne '' then begin
  
  file_error = ff_error[0]
  
  readcol, file_error, junk, junk, model, format = '(A,A,A)', /silent
  model_error = model[0]

  if model_solution ne model_error then begin
    
    cd, old_dir
    message, par.camera + ' : astrometric model specified in ' + file_solution + ' and in ' + file_error + ' conflict. Please check.'
    retv = { file:file, C:C, k:k }
    if return0 then return, retv else retall

  endif else begin

    readcol, file_error, rads, bAZ, dAZ, sAZ, bZD, dZD, sZD, format = files.daily.astrometry.error.format_r, /silent
    
    file[1] = file_error
    
    ii_az = where(finite(sAZ))
    ii_zd = where(finite(sZD))
    
    error = {az:rads[ii_az], zd:rads[ii_zd], $
             bias:{az:bAZ[ii_az], zd:bZD[ii_zd]}, std:{az:dAZ[ii_az], zd:dZD[ii_zd]}, int:{az:sAZ[ii_az], zd:sZD[ii_zd]}}
    
  endelse

endif

ff_covar = file_search(files.monthly.astrometry.covar.name)

if n_elements(ff_covar) gt 1 then begin
  
  cd, old_dir
  message, par.camera + ': found more than one astrometric covar file. Please check.', /continue
  retv = { file:file, C:C, k:k }
  if return0 then return, retv else retall
  
endif

if ff_covar[0] ne '' then begin
  
  file_covar = ff_covar[0]
  
  readcol, file_covar, junk, junk, model, format = '(A,A,A)', /silent
  model_covar = model[0]

  if model_solution ne model_covar then begin
    
    cd, old_dir
    message, par.camera + ' : astrometric model specified in ' + file_solution + ' and in ' + file_covar + ' conflict. Please check.'
    retv = { file:file, C:C, k:k }
    if return0 then return, retv else retall

  endif else begin

    covar = read_table(file_covar, head=6)
    file[2] = file_covar

  endelse

endif

ff_photo = file_search(files.daily.photometry.solution.name)

if n_elements(ff_photo) gt 1 then begin

  cd, old_dir
  message, par.camera + ': found more than one photometric solution file. Please check.', /continue
  retv = { file:file, C:C, k:k }
  if return0 then return, retv else retall

endif

if ff_photo ne '' then begin

  readcol, ff_photo[0], junk, junk, p, junk, sp, junk, format = files.daily.photometry.solution.format_r
  
  C  = p[0]
  K  = p[1]
  
endif else begin
  
  ff_photo = file_search(files.daily.photometry.param.name)
  
  file_tot = []
  jd_tot   = []
  Cv_tot   = []
  Kv_tot   = []
  
  if ff_photo[0] ne '' then begin
 
    for i=0, n_elements(ff_photo)-1 do begin
      
      readcol, ff_photo[i], junk, jd, junk, f, junk, junk, junk, junk, Cv, Kv, junk, junk, junk, format = files.daily.photometry.param.format_r, /silent
      
      ii_ok = where(f, n_ok)
      
      if ii_ok[0] eq -1 then continue
      
      file_tot = [file_tot, replicate(ff_photo[i], n_ok)]
      jd_tot   = [jd_tot, jd[ii_ok]]
      Cv_tot   = [Cv_tot, Cv[ii_ok]]
      Kv_tot   = [Kv_tot, Kv[ii_ok]]
      
    endfor
    
  endif
    
  if n_elements(Cv_tot) ge 1 then begin
  
    if keyword_set(julian_date) then begin
      
      jd_tot = round(jd_tot) - round(julian_date)
      ii_jd = where(jd_tot eq 0.)
      ii_jd = ii_jd[0]
      
      if ii_jd ne -1 then begin
        
        C = Cv_tot[ii_jd]
        K = Kv_tot[ii_jd]
        
      endif else begin
        
        C = median(Cv_tot, /even)
        K = median(Kv_tot, /even)
        
      endelse
    
    endif else begin
      
      C = median(Cv_tot, /even)
      K = median(Kv_tot, /even)
      
    endelse    
    
  endif else begin
    
    C = par.photometry.C
    K = par.photometry.k
    
  endelse
  
  C = C[0]
  k = k[0]
  
endelse

cd, old_dir
retv = { file:file, model:model_solution, param:param, sigma:sigma, error:error, covar:covar, C:C, K:K }
return, retv

end