; polynomial interpolation 

function poly_interp, x, y, x_int, degmax, yfit=yfit

compile_opt idl2

dmax = min([degmax, n_elements(x)-1])

ndeg = dmax-1
deg = findgen(ndeg) + 1
res = fltarr(ndeg)

n = n_elements(x)

for i=0, ndeg-1 do begin
  
  ;a = imsl_polyregress(x, y, deg[i], residual = resi)
  a = poly_fit(x, y, deg[i], yfit = yfit)
  
  ;res[i] = total(resi^2)/(n-deg[i]-1)
  res[i] = total((y-yfit)^2)/(n-deg[i]-1)
  
endfor

ii = where(finite(res) and res gt 0)

deg = deg[ii]
res = res[ii]

mi = min(res,ii)

degmin = deg[ii[0]]

;a = imsl_polyregress(float(x), float(y), degmin, predict_info = info)
a = poly_fit(float(x), float(y), degmin, yfit = yfit)

y_int = fltarr(n_elements(x_int))
yfit  = fltarr(n_elements(x))

for i=0, degmin do begin
  
  y_int = y_int + a[i]*float(x_int)^i
  yfit  = yfit  + a[i]*float(x)^i
  
endfor

return, y_int

end