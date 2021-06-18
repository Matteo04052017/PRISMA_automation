; extract coordinates from position string

pro get_coord, strcoord, xpos, ypos

compile_opt idl2

Ndet = n_elements(strcoord)

; extracting positions from strcoord
xpos = intarr(Ndet)
ypos = intarr(Ndet)
str1 = strcoord

for i=0, Ndet-1 do begin

  str1[i] = strmid(str1[i],1,strlen(str1[i])-2)
  res = strsplit(str1[i],';', /extract)
  xpos[i] = float(res[0])
  ypos[i] = float(res[1])

endfor

end