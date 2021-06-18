function astro_find, res, img, err, par

nfind = n_elements(x)

x  = res.match.x
sx = res.match.sx
y  = res.match.y
sy = res.match.sy

if par.moda eq '' then begin
  
  retv = { x:x, sx:sx, y:y, sy:sy }

  return, retv
  
endif else begin
  
  box1 = round(par.box*par.fwhm)
  
  xv0 = findgen(2*box1+1)
  yv0 = findgen(2*box1+1)

  for j = 0, nfind-1 do begin

    x_in = round(x[j])
    y_in = round(y[j])

    xv = xv0 + x_in - box1
    yv = yv0 + y_in - box1

    img1 = img[x_in - box1 : x_in + box1, y_in - box1 : y_in + box1]
    
    jj = where(x ge min(xv) and x le max(xv) and y ge min(yv) and y le max(yv))
    
    np = n_elements(jj)
    
    est  = [max(img), median(img1)]
    fita = [0, 1]
      
      if par.moda eq 'fit_gauss' then begin

        for k=0, np-1 do begin
          
          est = [est, max(img1)-median(img1), x[jj[k]], y[jj[k]], sig, sig, 0.]
          fita = [fita, 1, 1, 1, 1, 1, 0]
          
        endfor
        
        yfit = mpPSF_fit('GAUSSIAN', xv, yv, img1, res, gain=par.gain, estimates=est, fita=fita, sigma=sigma, CHISQ=chi2, status=status)
         
        print, res[0:7], sigma[0:7], format = '(8F20.5)'
       
        im1 = image(img1, layout = [1,2,1])
        im2 = image(yfit, layout = [1,2,2], /current)
      
        stop 
      
        if isa(im1) then im1.close

        if status eq 0 then begin
            
          if sigma[4] lt 1. and sigma[5] lt 1. then begin
              
            x[j]  = res[4]
            sx[j] = sigma[4]
            y[j]  = res[5]
            sy[j] = sigma[5]
              
          endif else begin
              
            sx[j] = sig
            sy[j] = sig
            
          endelse
    
        endif else begin
            
          sx[j] = sig
          sy[j] = sig
          
       endelse
       
    endif

    if par.moda eq 'baricentro' then begin

      xm = mat_x +  x_in - box1
      ym = mat_y +  y_in - box1

      Ax   = total(img1*xm)
      sAx2 = total((err1*xm)^2)
      Ay   = total(img1*ym)
      sAy2 = total((err1*ym)^2)
      B    = total(img1)
      sB2  = total(err1^2)

      x[j]  = Ax/B
      sx[j] = sqrt( sAx2/B^2 + sB2*Ax^2/B^4 )
      y[j]  = Ay/B
      sy[j] = sqrt( sAy2/B^2 + sB2*Ay^2/B^4 )

    endif

  endfor
  
endelse

retv = { x:x, sx:sx, y:y, sy:sy }

return, retv

end