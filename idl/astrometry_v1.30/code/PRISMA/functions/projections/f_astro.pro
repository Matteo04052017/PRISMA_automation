; function called in astrometry_images find-assoc recursion (not first iteration)

function f_astro, model_image, x, y, sx, sy, mag, smag, ctlg, res, r_corr

compile_opt idl2

; building fit variables
x_fit = [res.match.x, res.match.y]
y_fit = [res.match_ctlg.az, res.match_ctlg.zd]
err   = err_xy2az(model_image, res.match.x, res.match.sx, res.match.y, res.match.sy, res.proj.param, res.proj.param*0)
me    = [ err.az, err.zd ]
fita  = res.proj.fita

; invoking fitting function
yfit = mpastro_fit(model_image, x_fit, y_fit, param, estimates=res.proj.param, sigma=sigma, status=status, fita=fita, measure_errors = me)

if status eq 0 then begin
  
  ; computing new projection
  xy_proj = az2xy(model_image, ctlg.az, ctlg.zd, param)
  x_proj  = xy_proj.x
  y_proj  = xy_proj.y

  ; invoking list correlation routine
  srcor, x_proj, y_proj, x, y, r_corr, ii1, ii2, /silent, option=1

  if n_elements(ii1) lt 2 then begin
    
    match = {status:1}
    retv = {match:match}

    return, retv

  endif

  ; match catalog structure definition
  match_ctlg = {id:ctlg.id[ii1], type:ctlg.type[ii1], spectype:ctlg.spectype[ii1], $
                alpha:ctlg.alpha[ii1], delta:ctlg.delta[ii1], $
                az:ctlg.az[ii1], alt:ctlg.alt[ii1], zd:ctlg.zd[ii1], ha:ctlg.ha[ii1], $
                mag:ctlg.mag[ii1], x:x_proj[ii1], y:y_proj[ii1]}

  ; match sources structure definition
  match = {x:x[ii2], y:y[ii2], sx:sx[ii2], sy:sy[ii2], mag:mag[ii2], smag:smag[ii2], n:n_elements(ii2), status:0}

  ; projection structure to be input for next iteration
  proj = {x:x_proj, y:y_proj, param:param, sigma:sigma, fita:fita}

  ; defining return structure
  retv = {match:match, proj:proj, match_ctlg:match_ctlg}

  return, retv
  
endif else begin

  match = {status:1}
  retv = {match:match}

  return, retv  
  
endelse

end