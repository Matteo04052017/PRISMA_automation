function barycentre2D, xm, ym, a

x = total(xm*a)/total(a)
y = total(ym*a)/total(a)

retv = [x,y]

return, retv

end