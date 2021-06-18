; 'flat-fielding' for stars identification

function flatfield, img, supflat, gain=gain, median=median, err=err

compile_opt idl2

if ~keyword_set(gain) then gain = 1.
if keyword_set(median) then fact = median else fact = 1.

s  = size(img)

ii = where(supflat eq 0.)

case s[0] of
  
  2: begin
    
    img1 = img/(supflat*fact)
    img1[ii] = 0.
    
    if keyword_set(err) then begin
      
      err = sqrt(gain*img1)/(supflat*fact)
      err1[ii] = 0.
      
    endif

  end
  
  3: begin
    
    img1 = img
    if keyword_set(err) then err = img
    
    for i=0, s[3]-1 do begin
      
      temp = reform(img[*,*,i])
      temp1 = temp/(supflat*fact[i])
      temp1[ii] = 0.
      
      img1[*,*,i] = temp1
      
      if keyword_set(err) then begin

        temp2 = sqrt(gain*temp)/(supflat*fact[i])
        temp2[ii] = 0.
        err[*,*,i] = temp2

      endif 
      
    endfor
      
  end
  
  else: 
  
endcase

return, img1

end