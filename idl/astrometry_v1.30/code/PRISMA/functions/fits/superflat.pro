; superflat computation from a stack of fits

function superflat, stack, median=median

compile_opt idl2

s = size(stack)

stack1 = stack

for i=0, s[3]-1 do begin

  temp = stack[*,*,i]

  if keyword_set(median) then fact = median[i] else fact = 1

  stack1[*,*,i] = temp/fact

endfor

retv = median(stack1, dimension = 3, /even)

return, retv

end