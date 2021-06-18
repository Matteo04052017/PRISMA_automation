; compute format length from format string

function format_length, format

compile_opt idl2

retv = mg_streplace(format,"[A-Z]",'', /global)
retv = strcompress(retv, /remove_all)
retv = strmid(retv,1,strlen(retv)-2)
retv = strsplit(retv, ',', /extract)
retv = fix(float(retv))

return, retv

end