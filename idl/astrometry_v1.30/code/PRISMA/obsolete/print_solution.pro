; print astrometric solution to file

pro print_solution, files, param, sigma, model

compile_opt idl2

print_header, files.astrometry.solution

names = astro_model_info(model)

openw, lun, files.astrometry.solution.name, /get_lun, /append

for i=0, n_elements(param)-1 do begin
   
  printf, lun, names.names[i] + ' = ', param[i], ' ± ', sigma[i], names.units[i], format = files.astrometry.solution.format_w
  
endfor

close, lun & free_lun, lun

end