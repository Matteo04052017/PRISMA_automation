; funzione per la minimizzazione del residui per Bannister
FUNCTION mpresid_funct,A,X=x,Y=y,ERR=err

!EXCEPT = 0

COMPILE_OPT idl2, hidden
ON_ERROR,2

nx = n_elements(x)

az = x[0:nx/2-1]
zd = x[nx/2:nx-1]
dAZ = y[0:nx/2-1]

mi = a[0]
ma = a[1]
st = a[2]

n_sin = (ma-mi)/st

vmi = findgen(n_sin)*st+mi
vma = vmi+st

F = fltarr(nx/2)

for i=0, n_sin - 1 do begin
  
  ii = where(zd gt vmi[i] and zd le vma[i])
  if ii[0] ne -1 then begin
    
    F[ii] = a[3+0] + a[3+3+i]*sin(a[3+1]*az[ii] - a[3+2])
    
  endif  
  
endfor

F = [F,F]

; calcolo il residuo
resid = (y - F)/err

RETURN, resid

END