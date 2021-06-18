; astrometry MP-LAD modified fitting routine

function mpastro_fit, function_name,                $
                      xIn,                          $
                      yIn,                          $
                      a,                            $
                      CHISQ=chisq,                  $
                      ESTIMATES = est,              $
                      MEASURE_ERRORS=measureErrors, $
                      SIGMA=sigma,                  $
                      STATUS=status,                $
                      FITA  =fita,                  $
                      COVAR = covar                 

compile_opt idl2

x = double(xIn)
y = double(yIn)

n = n_elements(yIn)

if keyword_set(measure_errors) then me = float(measureErrors) else me = replicate(1.,n)
ii = where(measureErrors eq 0)
if ii[0] ne -1 then measureErrors[ii] = 1.

a = double(est)
na = n_elements(A)
parinfo = replicate({fixed:0, limited:[0,0], limits:[0.,0.], mpside:2, relstep:0.}, na)
if keyword_set(fita) then parinfo.fixed=~fita

functargs = {X:x, Y:y, ERR:me, FUNCTION_name:function_name}

param = MPFIT('MPASTRO_FUNCT', a, FUNCTARGS=functargs, STATUS=status, AUTODERIVATIVE=1, PARINFO=parinfo, /QUIET)

stat1 = abs([-18,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0]-status)
stat0 = abs([1,2,3,4,5,6,7,8,9]-status)
if min(stat1) eq 0 then status = 1
if min(stat0) eq 0 then status = 0

if status eq 0 then begin
  
  sigma    = dblarr(na)
  covar    = dblarr(na,na)
  
  a = double(param)
  na = n_elements(A)
  parinfo = replicate({fixed:0, limited:[0,0], limits:[0.,0.], mpside:2, relstep:0.01}, na)
  if keyword_set(fita) then parinfo.fixed=~fita

  param = MPFIT('MPASTRO_FUNCT', a, FUNCTARGS=functargs, PERROR=sigma, COVAR = covar, AUTODERIVATIVE=1, DOF=dof, PARINFO=parinfo, BESTNORM=bestnorm, maxiter = 0, /QUIET)

  if dof le 0 then dof=1
  
  chisq = bestnorm/dof
  sigma = FLOAT(sigma)*sqrt(chisq)
  a = FLOAT(param)
  covar = FLOAT(covar)*chisq
  
  check_az, a[0]
  
  case function_name of
    
    'proj_rot_poly2'       : begin & a1 = a[3] & z1 = a[4] & check_az, a1, z1 & a[3] = a1 & a[4] = z1 & end
    'proj_rot_exp1'        : begin & a1 = a[3] & z1 = a[4] & check_az, a1, z1 & a[3] = a1 & a[4] = z1 & end
    'proj_rot_poly2_asym'  : begin & a1 = a[3] & z1 = a[4] & check_az, a1, z1 & a[3] = a1 & a[4] = z1 & $
                                     a1 = a[8] & z1 = a[7] & check_az, a1, z1 & a[8] = a1 & a[7] = z1 & end
    'proj_rotz_poly2_asym' : begin & a1 = a[8] & z1 = a[7] & check_az, a1, z1 & a[8] = a1 & a[7] = z1 & end
    'proj_rot_exp1_asym'   : begin & a1 = a[3] & z1 = a[4] & check_az, a1, z1 & a[3] = a1 & a[4] = z1 & $
                                     a1 = a[9] & z1 = a[8] & check_az, a1, z1 & a[9] = a1 & a[8] = z1 & end
    'proj_rotz_exp1_asym'  : begin & a1 = a[9] & z1 = a[8] & check_az, a1, z1 & a[9] = a1 & a[8] = z1 & end   
    else                   :
   
  endcase

endif else begin

  sigma    = fltarr(na)
  covar    = fltarr(na,na)
  chisq    = !values.f_NaN

endelse

x1  = x[0:n/2-1]
y1  = x[n/2:n-1]

yfit = xy2az(function_name, x1, y1, param)

yfit = [yfit.az, yfit.zd]

return, yfit

end
