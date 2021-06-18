; read the catalog file and construct the catalog structure to be returned

function get_catalog, catalog

compile_opt idl2

ff = file_search(catalog)

if ff eq '' then begin
  
  message, catalog + ' file cannot be found. Please check.'
  
endif

; reading catalog file
readcol, catalog, id, typ, alpha, delta, magU, magB, magV, magR, magI, magP, spectyp, format='(A,A,F,F,F,F,F,F,F,F,A)', /silent

n_stars = n_elements(alpha)

mag = [ [magU], [magB], [magV], [magR], [magI], [magP] ]

retv = {id:id, alpha:alpha, delta:delta, mag:mag, type:typ, spectype:spectyp, n:n_stars}

return, retv

end