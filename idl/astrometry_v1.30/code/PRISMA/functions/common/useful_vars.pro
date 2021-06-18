; definition of useful global variables

pro useful_vars

compile_opt idl2

DEFSYSV, '!ramin', !radeg*60., 1
DEFSYSV, '!rasec', !radeg*60.*60., 1

end