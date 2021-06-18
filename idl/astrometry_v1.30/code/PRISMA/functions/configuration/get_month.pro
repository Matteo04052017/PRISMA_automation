; retrieve month string from given string (day)

function get_month, day

if strlen(day) ge 6 then begin

  retv = strmid(day, 0, 6)

endif else begin
  
  if strmid(day, strlen(day)-1, 1) eq '*' then begin
    
    retv = '*'
    
  endif else begin
    
    message, 'day ' + day + ' format incompatible. Please check.'
    
  endelse

endelse

return, retv

end