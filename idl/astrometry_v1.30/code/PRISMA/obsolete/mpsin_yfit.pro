; funzione per la minimizzazione del residui per Bannister
FUNCTION mpsin_yfit,X,A

!EXCEPT = 0

COMPILE_OPT idl2, hidden
ON_ERROR,2

F = a[0] + a[3]*sin(a[1]*x - a[2])

RETURN, F

END