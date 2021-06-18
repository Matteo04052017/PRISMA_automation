; costum 2d rebin

function myrebin_2d, img, factx, facty

compile_opt idl2

s = size(img)

dimx_ceil = ceil(float(s[1])/factx)
dimx_floor = floor(float(s[1])/factx)
dimy_ceil = ceil(float(s[2])/facty)
dimy_floor = floor(float(s[2])/facty)

img_1 = fltarr(dimx_ceil,dimy_ceil)

for i=0, dimx_floor-1 do begin

  for j=0, dimy_floor-1 do begin

    img_1[i,j] = total(img[factx*i:factx*i+factx-1,facty*j:facty*j+facty-1])

  endfor

endfor

if dimx_floor ne dimx_ceil then begin

  for j=0, dimy_floor-1 do begin

    img_1[dimx_ceil-1,j] = total(img[factx*dimx_floor:*,facty*j:facty*j+facty-1])

  endfor

endif

if dimy_floor ne dimy_ceil then begin

  for i=0, dimx_floor-1 do begin

    img_1[i,dimy_ceil-1] = total(img[factx*i:factx*i+factx-1,facty*dimy_floor:*])

  endfor

endif

if (dimx_floor ne dimx_ceil) and (dimy_floor ne dimy_ceil) then begin

  img_1[dimx_ceil-1,dimy_ceil-1] = total(img[factx*dimx_floor:*,facty*dimy_floor:*])

endif

return, img_1

end