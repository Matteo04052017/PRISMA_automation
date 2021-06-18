; PSF fitting routine

function mppsf_fit, function_name,                $
                    xIn,                          $
                    yIn,                          $
                    zIn,                          $
                    a,                            $
                    GAIN=gain,                    $
                    CHISQ=chisq,                  $
                    ESTIMATES = est,              $
                    SIGMA=sigma,                  $
                    STATUS=status,                $
                    FITA  =fita,                  $
                    COVAR = covar

compile_opt idl2

n = n_elements(zIn)

x = double(xIn)
y = double(yIn)
z = double(zIn)

;s = size(z)
;
;if s[0] eq 1 then begin
;    
;  x1 = x
;  y1 = y
;  x = x1 # (y1*0 + 1)
;  y = (x1*0 + 1) # y1
;  undefine, x1, y1
;  
;endif

if ~keyword_set(gain) then gain = 1.

xf  = [x, y]
yf  = [z, z]
mef = yf*0. + sqrt(mean(yf*gain))
;mef = sqrt(yf*gain)
ii = where(mef eq 0)
if ii[0] ne -1 then mef[ii] = sqrt(gain)

a = double(est)
na = n_elements(A)
parinfo = replicate({fixed:0, limited:[0,0], limits:[0.,0.], mpside:2, relstep:0.005}, na)
parinfo.fixed=~fita

functargs = {X:xf, Y:yf, ERR:mef, FUNCTION_NAME:function_name}

sigma    = dblarr(na)
covar    = dblarr(na,na)

param = MPFIT('MPPSF_FUNCT', a, FUNCTARGS=functargs, PERROR=sigma, COVAR = covar, AUTODERIVATIVE=1, DOF=dof, PARINFO=parinfo, BESTNORM=bestnorm, STATUS=status, /quiet)

stat1 = abs([-18,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,9]-status)
stat0 = abs([1,2,3,4,5,6,7,8]-status)
if min(stat1) eq 0 then status = 1
if min(stat0) eq 0 then status = 0

dof = round(dof/2.)
if dof le 0 then dof=1
bestnorm = bestnorm/2.

yfit = PSF(function_name, x, y, param)

if status eq 0 then begin
  
  chisq = bestnorm/dof
  sigma = FLOAT(sigma)*sqrt(chisq)
  a = FLOAT(param)
  covar = FLOAT(covar)*chisq
  
  case function_name of
    
    'gaussian'    : begin & a1 = a[7] & check_az, a1 & a[7] = a1 & end
    'gaussian_int': begin & a1 = a[7] & check_az, a1 & a[7] = a1 & end
    'gaussian_num': begin & a1 = a[7] & check_az, a1 & a[7] = a1 & end
;    'moffat'      : begin & a1 = a[8] & check_az, a1 & a[8] = a1 & end
    else          :
    
  endcase

endif else begin

  sigma    = fltarr(na)
  covar    = fltarr(na,na)
  chisq    = !values.f_NaN

endelse

return, yfit

end
