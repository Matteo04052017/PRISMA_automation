; procedure that export image or video of the detection

pro export_media, par, var, files

Ndet = n_elements(var.det_frame)

; loading PRISMA logo
logo = get_logo(par.config.path.logo, transparent=0)

; logo and text positions for output
pos_logo    = [0.82,0.,1.,0.18*par.fits.dim[0]/par.fits.dim[1]]
pos_station = [0.02, 0.94]
pos_data    = [0.02, 0.90]

; informational text on frame
text_station = par.camera + ' - ' + par.pseudo
text_data    = str_replace(strmid(var.data[0], 0, 19), 'T', ' @ ') + ' UT'

; 'superflat' computation
supflat = superflat(var.bolidi)

med = median(supflat, /even)
sup1 = supflat
ii = where(sup1 gt 10.*med)
sup1[ii] = 0
sup2 = smooth(sup1, [100,100], /edge_truncate)

bkg = med*supflat/sup2

ii_std = where(bkg lt 100)
std_bkg = meanabsdev(bkg[ii_std]-med)

min_value = alog(max([0,med-4*std_bkg])+1)
max_value = alog(par.photometry.saturation+1)

if par.config.event.image then image_bolide = bkg

; open video buffer
if par.config.event.video then write_video, files.detection.media.video.name, handle=h, video_dimensions=par.fits.dim, video_fps=10

for i=0, Ndet-1 do begin

  if var.psf.status[i] eq 0 then begin
      
    this_box = var.box[i]

    img = reform(var.bolidi[*,*,i])

    x_in = round(var.psf.param[3,i])
    y_in = round(var.psf.param[4,i])

    sig_x = var.psf.param[5,i]
    sig_y = var.psf.param[6,i]

    if sig_x lt 1. then sig_x = 1.
    if sig_y lt 1. then sig_y = 1.

    if sig_x gt this_box then sig_x = this_box
    if sig_y gt this_box then sig_y = this_box

    sx_in = ceil(3*sig_x)
    sy_in = ceil(3*sig_y)

    bolide = img[x_in-sx_in:x_in+sx_in, y_in-sy_in:y_in+sy_in] - var.psf.param[1,i]

    ii = where(bolide lt 0)
    if ii[0] ne -1 then bolide[ii] = 0.

    gaus = gaussian_function([sx_in,sy_in]/2., width=2*[sx_in,sy_in]+1)
    
    if par.config.event.image then begin

      image_bolide[x_in-sx_in:x_in+sx_in, y_in-sy_in:y_in+sy_in] = image_bolide[x_in-sx_in:x_in+sx_in, y_in-sy_in:y_in+sy_in] + gaus*bolide

    endif
    
  endif

  if par.config.event.video then begin

    video_bolide = bkg
    
    if var.psf.status[i] eq 0 then video_bolide[x_in-sx_in:x_in+sx_in, y_in-sy_in:y_in+sy_in] = video_bolide[x_in-sx_in:x_in+sx_in, y_in-sy_in:y_in+sy_in] + gaus*bolide

    ii_sat = where(video_bolide gt par.photometry.saturation)
    if ii_sat[0] ne -1 then video_bolide[ii_sat] = par.photometry.saturation

    video_bolide = rotate(alog(video_bolide+1), inv_rotate(par.fits.rotate))

    ; bolide video frame
    w1 = window(dimensions = par.fits.dim, buffer = 1)

    im1    = image(video_bolide, current = w1, min_value=min_value, max_value=max_value, margin = 0.)
    im2    = image(logo, current = w1, position = pos_logo)
    text1  = text(pos_station[0], pos_station[1], text_station, target = w1, $
                  /normal, font_color='white', font_size = 24)
    text2  = text(pos_data[0], pos_data[1], text_data, target = w1, $
                  /normal, font_color='white', font_size = 20)
    sgrab = w1.copywindow()
    if isa(w1) then w1.close
    write_video, files.detection.media.video.name, sgrab, handle=h, video_dimensions = par.fits.dim

  endif
  
endfor

; close video buffer
if par.config.event.video then write_video, /close, handle=h

if par.config.event.image then begin

  ii_sat = where(image_bolide gt par.photometry.saturation)
  if ii_sat[0] ne -1 then image_bolide[ii_sat] = par.photometry.saturation

  image_bolide = rotate(alog(image_bolide+1), inv_rotate(par.fits.rotate))

  ; bolide image
  w2 = window(dimensions = par.fits.dim, buffer = 1)

  image1 = image(image_bolide, current = w2, min_value=min_value, max_value=max_value, margin = 0.)
  image2 = image(logo, current = w2, position = pos_logo)
  text1  = text(pos_station[0], pos_station[1], text_station, target = w2, $
                /normal, font_color='white', font_size = 24)
  text2  = text(pos_data[0], pos_data[1], text_data, target = w2, $
                /normal, font_color='white', font_size = 20)

  w2.save, files.detection.media.image.name, width = par.fits.dim[0], height = par.fits.dim[1]
  w2.save, files.detection.media.thumb.name, width = round(par.fits.dim[0]/3), height = round(par.fits.dim[1]/3)
  if isa(w2) then w2.close

endif

end