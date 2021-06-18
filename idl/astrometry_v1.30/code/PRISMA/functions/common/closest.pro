; mod 2!pi function 

pro closest, angle, abs=abs

compile_opt idl2

s = size(angle)

angle = angle mod (2.*!pi)

vect = reform([[[angle-2.*!pi]], [[angle]], [[angle+2.*!pi]]])
sign = signum(vect)

angle = min(abs(vect), ii, dimension=s[0]+1)
angle = angle*sign[ii]

if keyword_set(abs) then angle = abs(angle)

end