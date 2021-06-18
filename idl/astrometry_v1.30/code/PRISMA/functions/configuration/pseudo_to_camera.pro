; convert pseudo name to camera id

function pseudo_to_camera, solutions, pseudo, return0=return0

compile_opt idl2

if ~isa(return0) then return0=0

readcol, solutions, cam, pse, format = '(A,A)', /silent

cam = strupcase(cam)
pse = strupcase(pse)

ii = where(pse eq pseudo)

if ii[0] ne -1 then begin

  retv = cam[ii]
  retv = retv[0]
  return, retv

endif else begin

  message, pseudo + ' not listed in ' + solutions + '. Please check.', /continue
  retv = ''
  if return0 then return, retv else retall

endelse

end