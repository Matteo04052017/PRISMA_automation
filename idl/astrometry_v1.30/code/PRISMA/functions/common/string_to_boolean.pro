; yes/no to boolean 1/0 conversion

function string_to_boolean, yn

compile_opt idl2

case strlowcase(yn) of
  
  'yes': retv = 1
  'no' : retv = 0
  else : retv = 0
  
endcase

return, retv

end