; computation of the stack median

function stack_median, stack, ii_R=ii_R

compile_opt idl2

s = size(stack)

if ~keyword_set(ii_R) then ii_R = findgen(s[1]*s[2])

retv = fltarr(s[3])

for i=0, s[3]-1 do begin

  temp = stack[*,*,i]
  
  retv[i] = median(temp[ii_R], /even)

endfor

return, retv

end