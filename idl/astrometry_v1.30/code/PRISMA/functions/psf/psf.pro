; PSF computing

function psf, model, x, y, param, dx=dx, dy=dy

compile_opt idl2

n = n_elements(x)

x = float(x)
y = float(y)
param = float(param)

case strlowcase(model) of

  'gaussian': begin
    
    npeaks = n_elements(param)/7

    sat = param[0]
    z = x*0. + param[1]

    for i=0, npeaks-1 do begin

      p = param[2+i*6:7+i*6]
      
      xp = x - p[1]
      yp = y - p[2]
      
;      a =  cos(p[5])^2/p[3]^2 + sin(p[5])^2/p[4]^2
;      b = -sin(2*p[5])/p[3]^2 + sin(2*p[5])/p[4]^2
;      c =  sin(p[5])^2/p[3]^2 + cos(p[5])^2/p[4]^2
;
;      u = a*xp^2 + b*xp*yp + c*yp^2

      u = ( (xp*(cos(p[5])/p[3]) - yp*(sin(p[5])/p[3]))^2 +  (xp*(sin(p[5])/p[4]) + yp*(cos(p[5])/p[4]))^2 )
      
      z = z + p[0]*exp(-0.5 * u)
      ii = where(z ge sat)
      if ii[0] ne -1 then z[ii] = sat

    endfor
    
  end
  
  'gaussian_int': begin

    npeaks = n_elements(param)/7

    sat = param[0]
    z = x*0. + param[1]

    for i=0, npeaks-1 do begin

      p = param[2+i*6:7+i*6]

      xp1 = (x - p[1] + 0.5)/(sqrt(2)*p[3])
      xp2 = (x - p[1] - 0.5)/(sqrt(2)*p[3])
      yp1 = (y - p[2] + 0.5)/(sqrt(2)*p[4])
      yp2 = (y - p[2] - 0.5)/(sqrt(2)*p[4])

      this_peak = p[0]*(!pi/2.)*p[3]*p[4]*( erf(xp1) - erf(xp2) )*( erf(yp1) - erf(yp2) )

      if p[5] ne 0. then begin

        this_peak = rot(this_peak, p[5], 1, p[1], p[2], /interp, /pivot)

      endif

      z = z + this_peak
      ii = where(z ge sat)
      if ii[0] ne -1 then z[ii] = sat

    endfor

  end
  
  'gaussian_num': begin

    npeaks = n_elements(param)/7

    sat = param[0]
    z = x*0. + param[1]

    for i=0, npeaks-1 do begin

      p = param[2+i*6:7+i*6]

      xp = x - p[1]
      yp = y - p[2]

      if keyword_set(dx) then deltax = dx else deltax = 0.01
      if keyword_set(dy) then deltay = dy else deltay = 0.01

      for j=0, n-1 do begin

        xv_u = findgen(floor(1/deltax))*deltax + xp[j] - 0.5
        yv_u = findgen(floor(1/deltay))*deltay + yp[j] - 0.5

        xm_u = xv_u # (yv_u*0 + 1)
        ym_u = (xv_u*0 + 1) # yv_u

        ;              a =  cos(p[5])^2/p[3]^2 + sin(p[5])^2/p[4]^2
        ;              b = -sin(2*p[5])/p[3]^2 + sin(2*p[5])/p[4]^2
        ;              c =  sin(p[5])^2/p[3]^2 + cos(p[5])^2/p[4]^2
        ;
        ;              u = a*xu^2 + b*xu*yu + c*yu^2

        u = ( (xm_u*(cos(p[5])/p[3]) - ym_u*(sin(p[5])/p[3]))^2 +  (xm_u*(sin(p[5])/p[4]) + ym_u*(cos(p[5])/p[4]))^2 )

        z[j] = z[j] + p[0]*mean(exp(-0.5 * u))

      endfor

      ii = where(z ge sat)
      if ii[0] ne -1 then z[ii] = sat

    endfor

  end
  
;  'moffat': begin
;
;    npeaks = n_elements(param)/8
;    
;    sat = param[0]
;    z = param[1]
;
;    for i=0, npeaks-1 do begin
;
;      p = param[2+i*7:8+i*7]
;
;      xp = x - p[1]
;      yp = y - p[2]
;
;      u = ( (xp*(cos(p[5])/p[3]) - yp*(sin(p[5])/p[3]))^2 +  (xp*(sin(p[5])/p[4]) + yp*(cos(p[5])/p[4]))^2 )
;      z = z + p[0]*(1 + u)^(-p[6])
;      ii = where(z ge sat)
;      if ii[0] ne -1 then z[ii] = sat
;
;    endfor
;
;  end

  else: begin

    message, 'psf model ' + strlowcase(model) + ' not implemented. Please check.'

  end

endcase

return, z

end