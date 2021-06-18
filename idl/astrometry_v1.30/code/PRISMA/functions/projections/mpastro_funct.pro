; 'chi2' definition for mpastro_fit

FUNCTION mpastro_funct, A, X=x, Y=y, ERR=err, function_name=function_name

compile_opt idl2

nx = N_ELEMENTS(x)

x1 = x[0:nx/2-1]
y1 = x[nx/2:nx-1]
az = y[0:nx/2-1]
zd = y[nx/2:nx-1]

err_az = err[0:nx/2-1]
err_zd = err[nx/2:nx-1]

res = xy2az(function_name, x1, y1, a)

dAZ = az - res.az
dZD = zd - res.zd

closest, dAZ

d = [dAZ, dZD]/[err_az, err_zd]

resid = signum(d)*sqrt(abs(d))

RETURN, resid

END