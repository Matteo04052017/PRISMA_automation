; print headers provided in get_files.pro

pro print_header, struct

compile_opt idl2

openw, lun, struct.name, /get_lun

for i=0, n_elements(struct.header)-1 do begin

  printf, lun, struct.header[i]

endfor

close, lun & free_lun, lun

end