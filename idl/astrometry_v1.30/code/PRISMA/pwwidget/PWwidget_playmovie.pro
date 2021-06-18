; This procedure manages the play and save movie function of PRISMAwidget

pro PWwidget_playmovie, event

compile_opt idl2

widget_control, /hourglass

widget_control, event.top, get_uvalue=pwwidget

; verify if the input is valid
widget_control, pwwidget.text_nframe, get_value=value

split = strsplit(value, ',', /extract)

case n_elements(split) of
  
  0: begin
    
    error = dialog_message('Please specify a non-zero number of frames', /error)
    return
    
  end
  
  1: begin
    
    nframe = long(split[0])
    delay  = long(15)
  
  end
  
  2: begin
    
    nframe = long(split[0])
    delay  = long(split[1])
    
  end
  
  else: begin
    
    error = dialog_message('Please specify a non-zero number of frames and optionally the desired delay time' + $
                           'of the movie in 1/100 seconds units, in the format nframe, delay', /error)
    return
    
  end
  
endcase

direction = sign(nframe)
nframe    = abs(nframe)

; not a valid frame number
if nframe eq 0 then begin
  
  error = dialog_message('Please specify a non-zero number of frames', /error)
  return
  
endif

; not a valid delay time
if delay lt 1 then begin
  
  error = dialog_message('Please specify a delay time of at least 1 (= 1/100 seconds)', /error)
  return
  
endif

; retrieve current image name
widget_control, pwwidget.text_filename, get_value=filename
current = filename[0]

if event.id eq pwwidget.button_savemovie then begin
  
  ; loading the appropriate logo for the background
  if widget_info(pwwidget.button_negative, /button_set) then begin
    
    logo = pwwidget.var.logo_white
    text_color = 'black'
    
  endif else begin
    
    logo = pwwidget.var.logo_black
    text_color = 'white'
    
  endelse
  
  ; binning the logo to a nice dimension
  logo = rebin(logo[*,0:112*4-1,0:108*4-1],4,112,108)
  imgstack = bytarr(nframe,480,480)
  imgsum = lonarr(3,480,480)
  r = bytarr(nframe,256)
  g = bytarr(nframe,256)
  b = bytarr(nframe,256)
  timestart = ''
  
endif

; iterating on the images
for i=0, nframe-1 do begin
  
   if i eq 0 then begin
     
     status = 0
     PW_draw_image, pwwidget
    
   endif else begin
     
     case direction of
      
        1: widget_control, pwwidget.button_nextimage, get_uvalue=filename
       -1: widget_control, pwwidget.button_previmage, get_uvalue=filename
      
     endcase
     
     ; reaching the end of the file list
     if filename eq '' then begin

       if event.id eq pwwidget.button_savemovie then imgstack=imgstack[0:i-1,*,*]
       nframe = i
       break

     endif
     
     ; open the image
     widget_control, pwwidget.text_filename, set_value=filename
     
     PW_open_image, pwwidget, status=status
     
   endelse
   
   if status then begin
     
     widget_control, pwwidget.text_filename, set_value=current
     PW_open_image, pwwidget
     return

   endif
   
   widget_control, pwwidget.draw_big, get_uvalue=img
   
   if event.id eq pwwidget.button_savemovie then begin
     
     ; snapshot of the current zoom window
     snapshot = tvrd(/true)
     imgsum = imgsum + long(snapshot)
     
     ; overplot the logo
     cgimage, logo, alphafgposition=[(479.-112.)/480.,0.,1.,108./480.]
     camera = img.camera + ' - ' + img.pseudo
     time = str_replace(strmid(img.data, 0, 22), 'T', ' @ ') + ' UT'
     
     cgtext, 10, 450, camera, /device, color=text_color, charsize = 2.5, /font, tt_font='DejaVuSans Bold'
     cgtext, 10, 425, time, /device, color=text_color, charsize = 2., /font, tt_font = 'DejaVuSans Bold'
     
     ; saving start time (first frame)
     if i eq 0 then begin
       
       camera_start = camera
       time_start = time
     
     endif
     
     ; getting the RGB decomposition and converting for gif format
     tvlct, r0, g0, b0, /get
     snapshot = tvrd(/true)
     imgstack[i,*,*] = color_quan(snapshot, 1, r0, g0, b0, colors=256, dither=0)
     r[i,*] = r0
     g[i,*] = g0
     b[i,*] = b0
         
   endif
   
   wait, delay/100.
   
endfor

if event.id eq pwwidget.button_savemovie then begin
  
  ; save the gif animation
  for i=0, nframe-1 do write_gif, pwwidget.var.animation, reform(imgstack[i,*,*]), reform(r[i,*]), reform(g[i,*]), reform(b[i,*]), /multiple, repeat_count=0, delay_time=delay
  write_gif, pwwidget.var.animation, reform(imgstack[0,*,*]), reform(r[0,*]), reform(g[0,*]), reform(b[0,*]), /close
  
  ; display the summed image
  tvscl, imgsum, /true
  
  ; overplot the logo
  cgimage, logo, alphafgposition=[(479-112)/480.,0.,1.,108./480]

  cgtext, 10, 450, camera_start, /device, color=text_color, charsize = 2.5, /font, tt_font='DejaVuSans Bold'
  cgtext, 10, 425, time_start, /device, color=text_color, charsize = 2., /font, tt_font = 'DejaVuSans Bold'
  
  ; save the png track
  snapshot = tvrd(/true)
  write_png, pwwidget.var.track, snapshot
  
  wait, 3
  
endif

; reaload the initial image
widget_control, pwwidget.text_filename, set_value=current
PW_open_image, pwwidget

end