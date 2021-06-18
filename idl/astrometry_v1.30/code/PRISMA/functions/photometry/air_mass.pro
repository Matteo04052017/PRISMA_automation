; airmass formula

function air_mass, az, zd

compile_opt idl2

case n_params() of
  
  1: begin
    
    retv = (cos(az)+0.0025*exp(-11.*cos(az)))^(-1)

    ii = where(retv gt 40.)
    if ii[0] ne -1 then retv[ii] = 40.
    
  end
  
  2: begin
    
    retv = (cos(zd)+0.0025*exp(-11.*cos(zd)))^(-1)

    ii = where(retv gt 40.)
    if ii[0] ne -1 then retv[ii] = 40.
    
  end
  
  else: begin
    
    message, '1 (zd) or 2 (az,zd) arguments allowed. Please check.'
    
  end
  
endcase



return, retv

end 