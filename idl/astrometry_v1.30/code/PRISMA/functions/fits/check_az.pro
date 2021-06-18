; checking azimuth values to be in [0,2pi]

pro check_az, az, zd

compile_opt idl2

if n_params() ge 1 then begin
  
  az = (az) mod (2*!pi)

  ii = where(az lt 0)
  if ii[0] ne -1 then az[ii] = az[ii] + 2*!pi
  
endif

if n_params() eq 2 then begin
  
  ii = where(zd lt 0)
  
  if ii[0] ne -1 then begin
    
    az[ii] = (az[ii] + !pi) mod (2*!pi)
    zd[ii] = abs(zd[ii])
    
  endif
  
endif
  
end