function astrometry_error, var, res

compile_opt idl2

; model evaluation to compute residuals on azimuth and zenith distance
model    = xy2az(res.model, var.x, var.y, res.param)
az_model = model.az
zd_model = model.zd

; astrometric residuals
dAZ      = var.az - az_model
dZD      = var.zd - zd_model

closest, dAZ

min_az  = 0.
max_az  = 360./!radeg
step_az = 20./!radeg
n_az    = (max_az-min_az)/step_az + 1

min_zd  = 0.
max_zd  = 90./!radeg
step_zd = 5./!radeg
n_zd    = (max_zd-min_zd)/step_zd + 1

max_zd1 = 80./!radeg + step_zd/2.

az_fbias     = findgen(n_az)*step_az + min_az
zd_fbias     = findgen(n_zd)*step_zd + min_zd

prot_az = fltarr(n_az) + !values.f_NaN
prot_zd = fltarr(n_zd) + !values.f_NaN

bias = {az_az:prot_az, zd_az:prot_az, az_zd:prot_zd, zd_zd:prot_zd}
std  = {az_az:prot_az, zd_az:prot_az, az_zd:prot_zd, zd_zd:prot_zd}
int  = {az_az:prot_az, zd_az:prot_az, az_zd:prot_zd, zd_zd:prot_zd}

sig_az = stddev(dAZ*sin(var.ZD))
sig_zd = stddev(dZD)

for i=0, n_az-1 do begin
  
  ext1 = az_fbias[i]-step_az/2.
  ext2 = az_fbias[i]+step_az/2.
  
  check_az, ext1
  check_az, ext2
  
  diff1 = var.az-ext1
  diff2 = var.az-ext2
  
  closest, diff1
  closest, diff2
  
  ii_az = where(diff1 ge 0. and diff2 lt 0. and $
                abs(dAZ*sin(var.zd)) le 3*sig_az and $
                abs(dZD) le 3*sig_zd and $
                var.zd lt max_zd1, nii_az)

  if ii_az[0] ne -1 then begin
    
    me_az = median(dAZ[ii_az]*sin(var.ZD[ii_az]), /even)
    me_zd = median(dZD[ii_az], /even)
    
    bias.az_az[i]   = me_az
    bias.zd_az[i]   = me_zd
    std.az_az[i]    = sqrt(mean((dAZ[ii_az]*sin(var.ZD[ii_az]) - me_az)^2))/sqrt(nii_az)
    std.zd_az[i]    = sqrt(mean((dZD[ii_az] - me_zd)^2))/sqrt(nii_az)

  endif
  
endfor

for i=0, n_zd-1 do begin

  ii_zd = where(var.zd ge zd_fbias[i]-step_zd/2. and $
                var.zd lt zd_fbias[i]+step_zd/2. and $
                abs(dAZ*sin(var.zd)) le 3*sig_az and $
                abs(dZD) le 3*sig_zd and $
                var.zd lt max_zd1, nii_zd)
  
  if ii_zd[0] ne -1 then begin
    
    me_az = median(dAZ[ii_zd]*sin(var.ZD[ii_zd]), /even)
    me_zd = median(dZD[ii_zd], /even)

    bias.az_zd[i]   = me_az
    bias.zd_zd[i]   = me_zd
    std.az_zd[i]    = sqrt(mean((dAZ[ii_zd]*sin(var.ZD[ii_zd]) - me_az)^2))/sqrt(nii_zd)
    std.zd_zd[i]    = sqrt(mean((dZD[ii_zd] - me_zd)^2))/sqrt(nii_zd)

  endif

endfor

az_mat = az_fbias # (zd_fbias*0 + 1)
zd_mat = (az_fbias*0 + 1) # zd_fbias

ii_boh = where(zd_mat eq 0.)
if ii_boh[0] ne -1 then zd_mat[ii_boh] = 1/60./60./!radeg

xy_mat = az2xy(res.model, az_mat, zd_mat, res.param)

err_in = ERR_XY2AZ(res.model, xy_mat.x, xy_mat.x*0., xy_mat.y, xy_mat.y*0., res.param, res.covar)

int.az_az = mean(err_in.az*sin(zd_mat), dimension=2, /NaN)
int.az_zd = mean(err_in.az*sin(zd_mat), dimension=1, /NaN)
int.zd_az = mean(err_in.zd, dimension=2, /NaN)
int.zd_zd = mean(err_in.zd, dimension=1, /NaN)

retv = {az:az_fbias, zd:zd_fbias, bias:bias, std:std, int:int}

return, retv

end