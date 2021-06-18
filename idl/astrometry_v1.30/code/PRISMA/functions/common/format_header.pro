; compute header format from format string

function format_header, format

compile_opt idl2

len = format_length(format)

retv = '('

for i=0, n_elements(len)-1 do begin
  
  if i ne 0 then retv = retv + ','
  retv = retv + 'A' + strtrim(len[i],2)
  
endfor

retv = retv + ')'

return, retv

end