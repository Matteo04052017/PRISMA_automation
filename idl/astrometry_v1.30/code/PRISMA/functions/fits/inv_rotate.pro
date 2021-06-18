; return inverse rotation coefficient for rotate.pro

function inv_rotate, rotate

compile_opt idl2

rot = fix(rotate) mod 8

while rot lt 0 do rot = rot + 8

case rot of
  
  0: retv = 0
  1: retv = 3
  2: retv = 2
  3: retv = 1
  4: retv = 4
  5: retv = 7
  6: retv = 6
  7: retv = 5
  
end

return, retv

end