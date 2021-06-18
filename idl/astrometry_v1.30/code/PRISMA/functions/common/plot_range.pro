; compute nice axis range

function plot_range, data, border=border, min0=min0, reverse=reverse, error=error

compile_opt idl2

if ~isa(border)  then border  = 0.05
if ~isa(min0)    then min0    = 0
if ~isa(reverse) then reverse = 0

if keyword_set(error) then begin
  
  minimo  = min(data-error, /nan)
  if min0 then minimo = 0.
  massimo = max(data+error, /nan)
  range   = massimo - minimo
  
endif else begin
  
  minimo  = min(data, /nan)
  if min0 then minimo = 0.
  massimo = max(data, /nan)
  range   = massimo - minimo
  
endelse

retv = [minimo - border*range, massimo + border*range]

if min0 then retv[0] = 0.

if ~finite(retv[0]) then retv[0] = 0
if ~finite(retv[1]) then retv[1] = 1
if retv[0] eq retv[1] then retv = [0,1]

if reverse then retv = reverse(retv)

return, retv

end