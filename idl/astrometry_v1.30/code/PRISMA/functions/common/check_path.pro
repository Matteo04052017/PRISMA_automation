; check path for homogeneity

function check_path, path

compile_opt idl2

sep = strmid(path, strlen(path)-1, 1)

if sep eq path_sep() then retv = strmid(path, 0, strlen(path)-2) else retv = path
   
return, retv

end