; residual minimization for PSF fitting

FUNCTION mppsf_funct, A, X=x, Y=y, ERR=err, FUNCTION_NAME=function_name

compile_opt idl2

s = size(x)

x1 = x[0:s[1]/2-1,*]
y1 = x[s[1]/2:*,*]

z1 = y[0:s[1]/2-1,*]

err1 = err[0:s[1]/2-1,*]

f = psf(function_name, x1, y1, a)

res = (z1[*] - f[*])/err1[*]

resid = [res, res]

RETURN, resid

END