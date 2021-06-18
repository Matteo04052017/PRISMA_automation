; funzione per la minimizzazione del residui per Bannister
FUNCTION mpsin_funct,A,X=x,Y=y,ERR=err

!EXCEPT = 0

COMPILE_OPT idl2, hidden
ON_ERROR,2

F = a[0] + a[3]*sin(a[1]*x - a[2])

; calcolo il residuo
resid = (y - F)/err

RETURN, resid

END