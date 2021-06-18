; apply solution to measurements

pro solve, solution, x, s_x, y, s_y, az, s_az, zd, s_zd, mags, s_mags, mag, s_mag, eff_correction=eff_correction

compile_opt idl2

if solution.file[0] eq '' then begin

  message, 'Solution structure is empty. Please check.'

endif

if n_params() eq 9 or n_params() eq 13 then begin

  n = n_elements(x)
  
  proj = xy2az(solution.model, x, y, solution.param)

  az = proj.az
  zd = proj.zd
  
  s_az = az*0.
  s_zd = zd*0.
  
  if strlen(solution.file[1]) gt 0 then begin
  
    daz = interpol(solution.error.bias.az, solution.error.az, az, /lsquadratic, /nan)
    dzd = interpol(solution.error.bias.zd, solution.error.zd, zd, /lsquadratic, /nan)
    
    zd = zd + dzd
    az = az + daz/sin(zd)
    
    check_az, az, zd
      
    s_az1 = interpol(solution.error.std.az, solution.error.az, az, /lsquadratic, /nan)
    s_zd1 = interpol(solution.error.std.zd, solution.error.zd, zd, /lsquadratic, /nan)
    
    s_az = sqrt( s_az^2 + ( s_az1/sin(zd) )^2 )
    s_zd = sqrt( s_zd^2 + s_zd1^2 )
    
  endif
  
  if strlen(solution.file[2]) gt 0 then begin

    err = err_xy2az(solution.model, x, s_x, y, s_y, solution.param, solution.covar)

    s_az = sqrt( s_az^2 + err.az^2 )
    s_zd = sqrt( s_zd^2 + err.zd^2 )

  endif else begin

    if strlen(solution.file[1]) gt 0 then begin

      s_az1 = interpol(solution.error.int.az, solution.error.az, az, /lsquadratic, /nan)
      s_zd1 = interpol(solution.error.int.zd, solution.error.zd, zd, /lsquadratic, /nan)

      s_az = sqrt( s_az^2 + ( s_az1/sin(zd) )^2 )
      s_zd = sqrt( s_zd^2 + s_zd1^2 )

    endif else begin

      err = err_xy2az(solution.model, x, s_x, y, s_y, solution.param, solution.sigma)

      s_az = sqrt( s_az^2 + err.az^2 )
      s_zd = sqrt( s_zd^2 + err.zd^2 )
      
    endelse

  endelse
  
  if n_params() eq 13 then begin
    
    if keyword_set(eff_correction) then begin
      
      eff_correction, mags, zd, err=s_mags, /mag
      
    endif
   
    airmass = air_mass(az, zd)
    
    mag  = mags + solution.C + solution.k*airmass
    s_mag = s_mags
    
  endif  
  
endif else begin
  
  message, 'Solve procedure should be called with 1+8 or 1+12 arguments. Please check.'
  
endelse

end