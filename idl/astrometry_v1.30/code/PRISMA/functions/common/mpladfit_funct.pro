FUNCTION mpLADFIT_funct, A, dA, X=x, Y=y, ERR=err

COMPILE_OPT idl2, hidden

na = n_elements(A)
nx = n_elements(x)

model = y*0.

for i=0, na-1 do begin
  
  model = model + a[i]*x^i
  
endfor

d = (y-model)/err

; calcolo il residuo
resid = signum(d)*sqrt(abs(d))

dA = make_array(nx, na, value=x[0]*0)

for i=0, na-1 do begin
  
  dA[*,i] = x^i/err
  
endfor

RETURN, resid

END