; function that create or load the bit mak for frames

function get_mask, par, ii_R=ii_R, ii_extR=ii_extR

compile_opt idl2

cd, par.config.path.dir_mask, current = old_dir

if par.fits.mask ne '' then begin
  
  ff = file_search(par.fits.mask)

  if ff[0] ne '' then begin
    
    ; reading the mask bmp
    mask = read_bmp(par.fits.mask)
    
    dim = size(mask)
    
    case dim[0] of
      
      1: begin
        
        cd, old_dir
        message, 'bmp mask file ' + par.fits.mask + ' not appropriated. Please check.'
        
      end
      
      3: begin
        
        mask = reform(mask[0,*,*])
        
      end
      
    endcase
    
    mini = min(mask)
    maxi = max(mask)
    
    mask = rotate(mask, par.fits.rotate)
    
    if mini eq maxi and maxi ne 0 then mask = mask/maxi
    if mini ne maxi and maxi ne 0 then mask = (mask-mini)/maxi    

    ii_R = where(mask eq 1, complement = ii_extR)

  endif else begin
    
    cd, old_dir
    message, 'bmp mask file ' + par.fits.mask + ' not found. Please check.'

  endelse
  
endif else begin
  
  rotdim = get_rotdim(par)
  
  ; defining CCD position vectors
  xv = indgen(rotdim[0])
  yv = indgen(rotdim[1])

  ; defining CCD position matrices
  mat_x = xv # (yv*0 + 1)
  mat_y = (xv*0 + 1) # yv
  
  mask = intarr(rotdim[0], rotdim[1])
  
  ; computing matrix of distance from the center
  distanze = sqrt(float(mat_x-par.fits.center[0])^2+float(mat_y-par.fits.center[1])^2)

  ; defining good pixel on the frame (excluding horizon)
  ii_R = where(distanze le par.fits.radius-par.fits.horizon, complement = ii_extR)
  
  mask[ii_R] = 1
  
endelse

cd, old_dir
return, mask

end