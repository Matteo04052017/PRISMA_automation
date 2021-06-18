function PSF1, model, x, y, param

  !EXCEPT = 0

  n = n_elements(x)

  x = double(x)
  y = double(y)
  param = double(param)

  case model of

    'GAUSSIAN': begin

      npeaks = n_elements(param)/7

      sat = param[0]
      z = param[1]

      for i=0, npeaks-1 do begin

        p = param[2+i*6:7+i*6]

        xp = x - p[1]
        yp = y - p[2]
        
        a =  cos(p[5])^2/p[3]^2 + sin(p[5])^2/p[4]^2
        b = -sin(2*p[5])/p[3]^2 + sin(2*p[5])/p[4]^2
        c =  sin(p[5])^2/p[3]^2 + cos(p[5])^2/p[4]^2
        
        u = a*xp^2 + b*xp*yp + c*yp^2
        
        z = z + p[0]*exp(-0.5 * u)
        ii = where(z ge sat)
        if ii[0] ne -1 then z[ii] = sat

      endfor

    end

    'MOFFAT': begin

      npeaks = n_elements(param)/8

      sat = param[0]
      z = param[1]

      for i=0, npeaks-1 do begin

        p = param[2+i*7:8+i*7]

        xp = x - p[1]
        yp = y - p[2]

        u = ( (xp*(cos(p[5])/p[3]) - yp*(sin(p[5])/p[3]))^2 +  (xp*(sin(p[5])/p[4]) + yp*(cos(p[5])/p[4]))^2 )
        z = z + p[0]*(1 + u)^(-p[6])
        ii = where(z ge sat)
        if ii[0] ne -1 then z[ii] = sat

      endfor

    end

    else: begin

      z = fltarr(n)

    end

  endcase

  return, z

end