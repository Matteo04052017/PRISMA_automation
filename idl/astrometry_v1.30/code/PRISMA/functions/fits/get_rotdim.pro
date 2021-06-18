; retrieve new dimensions after rotate

function get_rotdim, par

compile_opt idl2

rot = par.fits.rotate mod 8

while rot lt 0 do rot = rot + 8

case rot of
  
  0: retv = [par.fits.dim[0], par.fits.dim[1]]
  1: retv = [par.fits.dim[1], par.fits.dim[0]]
  2: retv = [par.fits.dim[0], par.fits.dim[1]]
  3: retv = [par.fits.dim[1], par.fits.dim[0]]
  4: retv = [par.fits.dim[1], par.fits.dim[0]]
  5: retv = [par.fits.dim[0], par.fits.dim[1]]
  6: retv = [par.fits.dim[1], par.fits.dim[0]]
  7: retv = [par.fits.dim[0], par.fits.dim[1]]
  else:
  
endcase

return, retv

end