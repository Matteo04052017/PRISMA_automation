; funzione di fit con metodo LAD polinomiale

function mpLADFIT, xIn,                          $
                   yIn,                          $
                   a,                            $
                   CHISQ=chisq,                  $
                   ESTIMATES = est,              $
                   MEASURE_ERRORS=measureErrors, $
                   SIGMA=sigma,                  $
                   STATUS=status,                $
                   FITA  =fita,                  $
                   COVAR = covar

!EXCEPT = 0
COMPILE_OPT idl2

x = DOUBLE(xIn)
y = DOUBLE(yIn)
me = DOUBLE(measureErrors)

n = n_elements(yIn)

ii = where(measureErrors eq 0)
if ii[0] ne -1 then measureErrors[ii] = 1D

a = double(est)
na = n_elements(A)
parinfo = replicate({fixed:0, limited:[0,0], limits:[0.,0.]}, n_elements(a))
parinfo.fixed=~fita

functargs = {X:x, Y:y, ERR:me}

sigma    = fltarr(na)
covar    = fltarr(na,na)

param = MPFIT('MPLADFIT_FUNCT', a, FUNCTARGS=functargs, PERROR=sigma, STATUS=status, COVAR = covar, AUTODERIVATIVE=0, DOF=dof, PARINFO=parinfo, BESTNORM=bestnorm, /QUIET)

dof = dof-1

if dof le 0 then dof=1

stat1 = abs([-18,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0]-status)
stat0 = abs([1,2,3,4,5,6,7,8,9]-status)
if min(stat1) eq 0 then status = 1
if min(stat0) eq 0 then status = 0

if status eq 0 then begin

  chisq = bestnorm/dof
  sigma = FLOAT(sigma)*sqrt(chisq)
  a = FLOAT(param)
  covar = FLOAT(covar)*chisq

endif else begin

  sigma    = fltarr(na)
  covar    = fltarr(na,na)
  chisq    = 0

endelse

yfit = mpLADFIT_YFIT(x,a)

return, yfit

end
