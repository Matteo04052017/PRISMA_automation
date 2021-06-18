; compute real root of polynomial equation

function real_polyroots, cc

compile_opt idl2

if keyword_set(min) and keyword_set(max) then begin
  
  message, 'MIN and MAX keywords are exclusive. Please check.'
  retall
  
endif

cc1 = cc

if total(finite(cc1)) ne n_elements(cc1) then begin
  
  retv = !values.f_Nan
  return, retv
  
endif

while 1 do begin
  
  if cc1[n_elements(cc1)-1] ne 0. then break else begin
    
    if n_elements(cc1) eq 1 then begin
      
      retv = !values.f_Nan
      return, retv
      
    endif
    
    cc1 = cc1[0:n_elements(cc1)-2]
    
  endelse
  
endwhile

res = fz_roots(cc1)

ii  = where(imaginary(res) eq 0)

if ii[0] ne -1 then begin

  res = real_part(res[ii])
  ii = where(res ge 0)
  res = res[ii]
  retv = res[sort(res)]

endif else begin

  retv = !values.f_Nan

endelse

return, retv

end