; wrapper for readfits, perform automatically ceplecha SR rotation and image cutting

function rdfits, nomefile, rotate=rotate, header=header

compile_opt idl2

if ~isa(rotate) then rotate=0

;img = REVERSE(TRANSPOSE(READFITS(nomefile, header, /silent)))
retv = rotate(readfits(nomefile, header, /silent), rotate)

return, retv

END