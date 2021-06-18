; comvert camera id to pseudo name

function camera_to_pseudo, solutions, camera, return0=return0

compile_opt idl2

if ~isa(return0) then return0=0

readcol, solutions, cam, pse, format = '(A,A)', /silent

cam = strupcase(cam)
pse = strupcase(pse)

ii = where(cam eq camera)

if ii[0] ne -1 then begin
  
  retv = pse[ii]
  retv = retv[0]
  return, retv
  
endif else begin
  
  message, camera + ' not listed in ' + solutions + '. Please check', /continue
  retv = ''
  if return0 then return, retv else retall
  
endelse

end