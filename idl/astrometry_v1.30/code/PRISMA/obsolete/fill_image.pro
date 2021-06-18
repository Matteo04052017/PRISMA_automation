; fill holes in images

function fill_image, img, ii, order

compile_opt idl2

indici = array_indices(img, ii)

s = size(img)

imgfill = img

for i = 0, n_elements(ii)-1 do begin

  if indici[0,i] gt order and indici[1,i] gt order and indici[0,i] lt s[1]-order-1 and indici[1,i] lt s[2]-order-1 then begin

    cont = imgfill[indici[0,i]-order:indici[0,i]+order,indici[1,i]-order:indici[1,i]+order]
    cont[order,order] = 0.
    dimcont = (2*order+1)^2 - 1.
    imgfill[indici[0,i],indici[1,i]] = total(cont)/dimcont

  endif

endfor

return, imgfill

end