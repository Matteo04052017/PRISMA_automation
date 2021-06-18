; costum 1d rebin

function myrebin_1d, v, fact

compile_opt idl2

dim = n_elements(v)
dim_ceil = ceil(float(dim)/fact)
dim_floor = floor(float(dim)/fact)
v_1 = fltarr(dim_ceil)

for i = 0, dim_floor-1 do begin

  v_1[i] = total(v[fact*i:fact*i+fact-1])

endfor

if dim_floor ne dim_ceil then begin

  v_1[dim_ceil-1] = total(v[fact*dim_floor:*])

endif

return, v_1

end