; ATAN2 fortran style

function atan2, y, x

compile_opt idl2

if x eq !null then res = atan(y) else res = atan(y,x)

check_az, res

return, res

end