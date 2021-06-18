; funzione di fit (Levemberg-Marquardt) delle relazioni di Bannister
Function mpresid_fit, xIn, yIn, a, $
CHISQ=chisq, $
ESTIMATES = est, $
MEASURE_ERRORS=measureErrors, $
SIGMA=sigma, $
YERROR=yerror, $
;    FUNCTION_NAME=function_name, $
STATUS=status, $
FITA  =fita, $
COVAR = covar

COMPILE_OPT idl2

on_error,2

n = n_elements(yIn)
nMeas = N_ELEMENTS(measureErrors)
if ((nMeas gt 0) && (nMeas ne n)) then $
  MESSAGE, 'MEASURE_ERRORS must be a vector of the same length as Y'

isDouble = SIZE(xIn,/TYPE) eq 5 || SIZE(yIn,/TYPE) eq 5

x = DOUBLE(xIn)
y = DOUBLE(yIn)


if (nMeas gt 0) then begin

  ii = where(measureErrors eq 0)
  if ii[0] ne -1 then measureErrors[ii]=1.

endif

a = double(est)
na = n_elements(A)
parinfo = replicate({fixed:0, limited:[0,0], limits:[0.,0.], relstep:0.01, mpside:2}, n_elements(a))
parinfo.fixed=~fita

functargs = {X:x, Y:y, ERR:measureErrors}

bestnorm=fltarr(n)
sigma=fltarr(na)
covar=fltarr(na,na)

param = MPFIT('MPRESID_FUNCT', a, FUNCTARGS=functargs, PERROR=sigma, BESTNORM=bestnorm, STATUS=status, COVAR = covar, AUTODERIVATIVE=1, DOF=dof, PARINFO=parinfo, /QUIET)
if dof le 0 then dof=1
stat1 = abs([-18,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0]-status)
stat0 = abs([1,2,3,4,5,6,7,8,9]-status)

if min(stat1) eq 0 then status = 1
if min(stat0) eq 0 then status = 0

if status eq 0 then begin

  chisq = bestnorm/dof
  sigma = FLOAT(sigma)
  a = FLOAT(param)
  covar = FLOAT(covar)
  
  if a[3+2] lt -!pi then a[3+2] = a[3+2] + 2*!pi
  if a[3+2] gt !pi then a[3+2] = a[3+2] - 2*!pi

endif else begin

  bestnorm=fltarr(n)
  sigma=fltarr(na)
  covar=fltarr(na,na)
  chisq=0

endelse

yfit = 0

return, yfit

end
