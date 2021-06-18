pro detection

image_fit = 0
plot_res  = 1

config_file = '/PRISMA/configuration.ini'

; event directory
event = '20171024T234349_UT'

; station directory
detect = 'PINOTORINESE_20171024T234350_UT'

; parameters of the algorithm
box_bolide = 8
nsig       = 4

; file to be used as input positions
position = 'positions.txt'

config = get_config(config_file)
info   = strsplit(detect, '_', /extract)
camera = pseudo_to_camera(config.path.solutions, info[0])
undefine, config

; retrieve code configuration from the config file
par = get_par(config_file, camera, '*')

nomefileout_fit = detect + '_fit.txt'
nomefileout_cen = detect + '_bar.txt'

; legge i parametri da file di astrometria (mese)
solution = get_solution(par)

cd, par.config.path.dir_events
cd, event
cd, detect

; reading FreeTure positions file
readcol, position, det_frame, strcoord, data, format='(I,A,A)', /silent

; number of detected frames
Ndet = n_elements(det_frame)

; extracting positions from strcoord
xpos = intarr(Ndet)
ypos = intarr(Ndet)

for i=0, Ndet-1 do begin

  strcoord[i] = strmid(strcoord[i],1,strlen(strcoord[i])-2)
  res = strsplit(strcoord[i],';', /extract)
  xpos[i] = float(res[0])
  ypos[i] = float(res[1])

endfor

; fits folder
cd,'fits2D'

; sorting fits file
ff = file_search('*.fit')
ff = ff[sort(ff)]
N = n_elements(ff)

; filling missing frames in between
fill_frames, ff, det_frame, Ndet, xpos, ypos

; fits filename
str = strtrim(det_frame,2)
len = strlen(str)
mlen = max(len)
ii = where(len ne mlen)

if ii[0] ne -1 then begin

  for i=0, n_elements(ii)-1 do begin

    for j=0, mlen - len[ii[i]] - 1 do str[ii[i]] = '0' + str[ii[i]]

  endfor

endif

frame_bolide = 'frame_'+str+'.fit'

; converting device to ceplecha coordinates
device2ceplecha, xpos, ypos, par

; allocating variables for fits reading
bolidi = dblarr(par.fits.dim[0], par.fits.dim[1], Ndet)

julian_date = dblarr(Ndet)
data        = strarr(Ndet)

ibolidi = 0
; reading fits file
for i=0, N-1 do begin

  ii = where(frame_bolide eq ff[i])

  if ii[0] ne -1 then begin

    bld = rdfits(ff[i], header=h)
    
    bolidi[*,*,ibolidi] = bld
    
    iitime  = where(strmid(h,0,8) eq 'DATE-OBS')
    
    time          = strmid(h[iitime],11,24)
    data[ibolidi] = time
    
    yr  = long(strmid(time,0,4))
    mn  = long(strmid(time,5,2))
    day = long(strmid(time,8,2))
    hh  = double(strmid(time,11,2))
    mm  = double(strmid(time,14,2))
    ss  = double(strmid(time,17,7))
    hr  = hh + mm/60D + ss/3600D

    ; computing julian date
    jdcnv, yr, mn, day, hr, jd

    julian_date[ibolidi] = jd
    
    ibolidi = ibolidi + 1

  endif

endfor

; adjusting data string
ii = where(strmid(data,21,3) eq "'  ")
if ii[0] ne -1 then data[ii] = strmid(data[ii],0,21) + '000'

ii = where(strmid(data,22,2) eq "' ")
if ii[0] ne -1 then data[ii] = strmid(data[ii],0,22) + '00'

ii = where(strmid(data,23,1) eq "'")
if ii[0] ne -1 then data[ii] = strmid(data[ii],0,23) + '0'

; PSF fit model & number of parameters of the model
model = 'GAUSSIAN' & np = 8 

; allocating variables for fit results
chi  = fltarr(Ndet)
stat = fltarr(Ndet)
res  = fltarr(Ndet, np)
sres = fltarr(Ndet, np)

fita = [0,1,1,1,1,1,1,0]

for i=0, Ndet-1 do begin

  xv = findgen(2*box_bolide+1) + xpos[i] - box_bolide
  yv = findgen(2*box_bolide+1) + ypos[i] - box_bolide

  mat_x = xv # (yv*0. + 1)
  mat_y = (xv*0. + 1) # yv

  bld = bolidi[xpos[i]-box_bolide:xpos[i]+box_bolide, ypos[i]-box_bolide:ypos[i]+box_bolide, i]
  err = sqrt(par.photometry.gain*bld)

  ma = max(bld)
  ii = where(bld eq ma)
  x_in = mean(mat_x[ii])
  y_in = mean(mat_y[ii])

  xv = findgen(2*box_bolide+1) + x_in - box_bolide
  yv = findgen(2*box_bolide+1) + y_in - box_bolide

  mat_x = xv # (yv*0. + 1)
  mat_y = (xv*0. + 1) # yv

  bld = bolidi[x_in-box_bolide:x_in+box_bolide, y_in-box_bolide:y_in+box_bolide, i]/par.photometry.saturation
  err = sqrt(par.photometry.gain*bld)/par.photometry.saturation

  est = [1.,median(bld),max(bld),x_in,y_in,1.,1.,0.]

  yfit = mpPSF_fit(model, xv, yv, bld, result, gain=gain, estimates=est, fita = fita, sigma=sigma, CHISQ=chi2, status = status)

  res[i,*] = result
  sres[i,*] = sigma
  stat[i] = status
  chi[i] = chi2
  
  ; image of original image and fitted PSF
  if image_fit then begin
    
    im1 = image(bld, xv, yv, layout = [1,2,1], dimensions = [400,800], axis_style = 1, rgb_table = 13)
    im2 = image(yfit, xv, yv, layout = [1,2,2], /current, axis_style = 1, rgb_table = 13)

    print, result, sigma, format = '(8F20.5)'
    print, 'chi2 = ', chi2

    stop

    if isa(im1) then im1.close
    
  endif

endfor

bkg_fit       = res[*,1]
sbkg_fit      = sres[*,1]

h_fit         = res[*,2]
sh_fit        = sres[*,2]

x_fit         = res[*,3]
sx_fit        = sres[*,3]

y_fit         = res[*,4]
sy_fit        = sres[*,4]

sigx_fit      = res[*,5]
ssigx_fit     = sres[*,5]

sigy_fit      = res[*,6]
ssigy_fit     = sres[*,6]

; allocating variables for barycentre results
x_bar = fltarr(Ndet)
y_bar = fltarr(Ndet)

for i=0, Ndet-1 do begin

  x_in = round(x_fit[i])
  y_in = round(y_fit[i])
  l_x = round(nsig*sigx_fit[i])
  l_y = round(nsig*sigy_fit[i])

  xv = findgen(2*l_x+1) + x_in - l_x
  yv = findgen(2*l_y+1) + y_in - l_y

  mat_x = xv # (yv*0. + 1)
  mat_y = (xv*0. + 1) # yv

  bld = bolidi[x_in-l_x:x_in+l_x,y_in-l_y:y_in+l_y,i]

  Ax   = total(bld*mat_x)
  Ay   = total(bld*mat_y)
  B    = total(bld)

  x_bar[i]  = Ax/B
  y_bar[i]  = Ay/B

endfor

; plot results on a graphic window
if plot_res then begin

  p1 = errorplot(det_frame, bkg_fit, sbkg_fit, '.', layout = [2,3,1], dimensions = [800,1000], xtitle = 'n° frame', ytitle = 'bkg [%]', $
                 errorbar_capsize = 0., yrange = [0,max(bkg_fit)*1.1])
  p11 = plot(det_frame, bkg_fit, overplot = p1, thick = 1)

  p2 = errorplot(det_frame, h_fit, sh_fit, '.', /current, layout = [2,3,2], xtitle = 'n° frame', ytitle = 'h [%]', $
                 errorbar_capsize = 0., yrange = [0,max(h_fit)*1.1])
  p21 = plot(det_frame, h_fit, overplot = p2, thick = 1)

  p3 = errorplot(det_frame, x_fit, sx_fit, '.', /current, layout = [2,3,3], xtitle = 'n° frame', ytitle = 'x [pix]', $
                errorbar_capsize = 0., yrange = [floor(min(x_fit)-5), floor(max(x_fit)+5)])
  p31 = plot(det_frame, x_fit, overplot = p3, thick = 1)

  p4 = errorplot(det_frame, y_fit, sy_fit, '.', /current, layout = [2,3,4], xtitle = 'n° frame', ytitle = 'y [pix]', $
                 errorbar_capsize = 0., yrange = [floor(min(y_fit)-5), floor(max(y_fit)+5)])
  p41 = plot(det_frame, y_fit, overplot = p4, thick = 1)

  p5 = errorplot(det_frame, sigx_fit, ssigx_fit, '.', /current, layout = [2,3,5], xtitle = 'n° frame', ytitle = '$\sigma_x$ [pix]', $
                 errorbar_capsize = 0., yrange = [min([sigx_fit,sigy_fit])*0.9,max([sigx_fit,sigy_fit])*1.1])
  p51 = plot(det_frame, sigx_fit, overplot = p5, thick = 1)

  p6 = errorplot(det_frame, sigy_fit, ssigy_fit, '.', /current, layout = [2,3,6], xtitle = 'n° frame', ytitle = '$\sigma_y$ [pix]', $
                 errorbar_capsize = 0., yrange = [min([sigx_fit,sigy_fit])*0.9,max([sigx_fit,sigy_fit])*1.1])
  p61 = plot(det_frame, sigy_fit, overplot = p6, thick = 1)

  px  = plot(det_frame, x_fit, thick = 1, xtitle = 'n° frame', ytitle = 'x [pix]', title = 'x position from fit [black] vs barycentre [red]', $
             dimensions = [1000,600], position = [0.1,0.4,0.45,0.9])
  px1 = plot(det_frame, x_bar, thick = 1, color = 'red', overplot = px)
  pdx = plot(det_frame, x_fit-x_bar, thick = 1, xtitle = 'n° frame', ytitle = 'x$_{fit}$ - x$_{bar}$', /current, position = [0.1,0.1,0.45,0.3])
  p0x = plot(det_frame, replicate(0,Ndet), thick = 2, color='blue', overplot=pdx)
  
  py  = plot(det_frame, y_fit, thick = 1, xtitle = 'n° frame', ytitle = 'x [pix]', title = 'y position from fit [black] vs barycentre [red]', $
             /current, position = [0.55,0.4,0.9,0.9])
  py1 = plot(det_frame, y_bar, thick = 1, color = 'red', overplot = py)
  pdy = plot(det_frame, y_fit-y_bar, thick = 1, xtitle = 'n° frame', ytitle = 'y$_{fit}$ - y$_{bar}$', /current, position = [0.55,0.1,0.9,0.3])
  p0y = plot(det_frame, replicate(0,Ndet), thick = 2, color='blue', overplot=pdy)
  
  stop

  if isa(p1) then px.close
  if isa(px) then py.close

endif

stop

proj = xy2az(par.astrometry.model_monthly, x, y, param_astro)
err_proj = err_xy2az(par.astrometry.model_monthly, x, sx, y, sx, param_astro, sigma_astro)

az  = proj.az
saz = err_proj.az
zd  = proj.zd
szd = err_proj.zd

alt = !pi/2 - zd
salt = szd

az   = az*!radeg
saz  = saz*!radeg
zd   = zd*!radeg
szd  = szd*!radeg
alt  = alt*!radeg
salt = salt*!radeg

az_inf = az - saz
az_sup = az + saz
alt_inf = alt - salt
alt_sup = alt + salt

hor2eq, alt, az, julian_date, ra, dec, ha, lat = lat, lon = lon, altitude = elev
hor2eq, alt_inf, az_inf, julian_date, ra_ii, dec_ii, ha_ii, lat=lat, lon=lon, altitude = elev
hor2eq, alt_inf, az_sup, julian_date, ra_is, dec_is, ha_is, lat=lat, lon=lon, altitude = elev
hor2eq, alt_sup, az_inf, julian_date, ra_si, dec_si, ha_si, lat=lat, lon=lon, altitude = elev
hor2eq, alt_sup, az_sup, julian_date, ra_ss, dec_ss, ha_ss, lat=lat, lon=lon, altitude = elev

ra_mat = [[ra_ii],[ra_is],[ra_si],[ra_ss]]
dec_mat = [[dec_ii],[dec_is],[dec_si],[dec_ss]]

sra = (max(ra_mat, dimension=2) - min(ra_mat, dimension=2))/2.
sdec = (max(dec_mat, dimension=2) - min(dec_mat, dimension=2))/2.

cd, '..'

openw, lun, nomefileout, /get_lun
printf, lun, '| n° FRAME |         UTC TIME           |     JULIAN DATE         |   AZ [DD]   |    ALT [DD]   |    RA [DD]   |    DEC [DD]  |'
printf, lun, ' '

for i=0, Ndet-1 do begin

  printf, lun, det_frame[i], data[i], julian_date[i], az[i], alt[i], ra[i], dec[i], format = '(I8, A30, F25.10, 4F15.4)'

endfor

close, lun & free_lun, lun

stop

end

