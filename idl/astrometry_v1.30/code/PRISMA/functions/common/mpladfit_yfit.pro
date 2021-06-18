FUNCTION mpLADFIT_yfit, x, a

COMPILE_OPT idl2

na = n_elements(A)

model = x*0.

for i=0, na-1 do begin

  model = model + a[i]*x^i

endfor

RETURN, model

END