; This procedure takes care of all the actions to be performed when a new
; fits file is requested for PRISMAwidget

pro PW_open_image, pwwidget, sensitive=sensitive, cd=cd, detection=detection, capture=capture, status=status

compile_opt idl2

status = 0

; retrieve filename
widget_control, pwwidget.text_filename, get_value=filename
widget_control, pwwidget.text_filename, get_uvalue=currfile
widget_control, pwwidget.list_mode, get_uvalue=mode

filename = filename[0]

if filename eq '' then begin
  
  widget_control, pwwidget.text_filename, set_value=currfile
  return
  
endif

; check if file exists
ver = file_search(filename, /test_regular)

if ver[0] eq '' then begin
  
  status = 1
  dialog = dialog_message('Cannot find ' + filename, /error)
  widget_control, pwwidget.text_filename, set_value=currfile
  return
   
endif

if keyword_set(detection) then mode = 'detection'
if keyword_set(capture)   then mode = 'capture'

path = file_dirname(filename)

case mode of
  
  'detection': begin
    
    dir = strsplit(path, path_sep(), /extract)
    fdecomp, filename, disk, folder, name, ext
    name = strmid(name,0,6)

    ; check for freeture directories and filename
    if dir[n_elements(dir)-1] ne 'fits2D' or name ne 'frame_' then begin
      
      status = 1
      dialog = dialog_message('This option is valid only for freeture detections', /error)
      widget_control, pwwidget.text_filename, set_value=currfile
      return
      
    endif
    
  end
  
  'capture': 
  
endcase

if keyword_set(cd) then cd, path, current=currdir

; retrieve image
ima = readfits(filename, header, /silent)

s = size(ima)

widget_control, pwwidget.draw_big, get_uvalue=img
widget_control, pwwidget.draw_zoom, get_uvalue=imgzoom

; if image is not defined
if s[0] ne 2 then begin
  
  status = 1
  dialog = dialog_message('The image in ' + filename + ' was not loaded properly or is not a .fit file or does not have the right dimensions.', /error)
  if keyword_set(cd) then cd, currdir
  widget_control, pwwidget.text_filename, set_value=currfile
  return
  
endif

if s[1] lt img.xsize or s[2] lt img.ysize then begin
  
  status = 1
  dialog = dialog_message('The image in ' + filename + ' does not have the right dimensions.', /error)
  if keyword_set(cd) then cd, currdir
  widget_control, pwwidget.text_filename, set_value=currfile
  return
  
endif
     
obsdate = sxpar(header, 'DATE-OBS')

if typename(obsdate) ne 'STRING' then begin

  status = 1
  dialog = dialog_message('Cannot find DATE-OBS keyword in the header of ' + filename, /error)
  if keyword_set(cd) then cd, currdir
  widget_control, pwwidget.text_filename, set_value=currfile
  return

endif
 
obsdate = strtrim(obsdate)
 
lzeros_datastring, obsdate
img.data = obsdate

pseudo = sxpar(header, 'TELESCOP')
 
if typename(pseudo) ne 'STRING' then begin

  status = 1
  dialog = dialog_message('Cannot find TELESCOP keyword in the header of ' + filename, /error)
  if keyword_set(cd) then cd, currdir
  widget_control, pwwidget.text_filename, set_value=currfile
  return

endif
 
pseudo = strupcase(strtrim(pseudo))

ii = where(pseudo eq pwwidget.var.list_pseudo)

if ii[0] ne -1 then begin

  camera = pwwidget.var.list_camera[ii[0]]

endif else begin
  
  status = 1
  dialog = dialog_message('Please add ' + pseudo + ' in ' + pwwidget.var.solutions, /error)
  if keyword_set(cd) then cd, currdir
  widget_control, pwwidget.text_filename, set_value=currfile
  return

endelse
 
; if /sensitive has been requested
if keyword_set(sensitive) and strlen(currfile) eq 0 then begin
   
  ; setting sensitivities for widget components
  widget_control, pwwidget.draw_big, sensitive=1
  widget_control, pwwidget.draw_zoom, sensitive=1
  widget_control, pwwidget.text_xpos, sensitive=1
  widget_control, pwwidget.text_ypos, sensitive=1
  widget_control, pwwidget.text_imgvalue, sensitive=1
  widget_control, pwwidget.text_zoomxc, sensitive=1
  widget_control, pwwidget.text_zoomyc, sensitive=1
  widget_control, pwwidget.slider_min, sensitive=1
  widget_control, pwwidget.slider_max, sensitive=1
  widget_control, pwwidget.slider_zoom, sensitive=1
  widget_control, pwwidget.button_negative, sensitive=1
  widget_control, pwwidget.button_logscale, sensitive=1
  widget_control, pwwidget.button_interpol, sensitive=1
  widget_control, pwwidget.text_nframe, sensitive=1
  widget_control, pwwidget.button_playmovie, sensitive=1
  widget_control, pwwidget.button_savemovie, sensitive=1

endif

; if /detection has been requested
if keyword_set(detection) then begin

  ; setting sensitivities for widget components
  widget_control, pwwidget.button_pos, sensitive=1
  widget_control, pwwidget.button_loadpos, sensitive=1
  widget_control, pwwidget.button_autopos, sensitive=1
  widget_control, pwwidget.button_showbox, sensitive=1
  widget_control, pwwidget.list_mode, set_droplist_select=0, set_uvalue=mode

endif

; if /capture has been requested
if keyword_set(capture) then begin

  ; setting sensitivities for widget components
  widget_control, pwwidget.button_pos, sensitive=0
  widget_control, pwwidget.button_loadpos, set_button=0, sensitive=0
  widget_control, pwwidget.button_autopos, set_button=0, sensitive=0
  widget_control, pwwidget.button_showbox, set_button=0, sensitive=0
  widget_control, pwwidget.table_pos, sensitive=0, table_ysize=25, alignment=2, set_value=['','','',''], set_table_view=[0,0], set_table_select=[-1,-1,-1,-1]
  widget_control, pwwidget.slider_box, sensitive=0
  widget_control, pwwidget.button_fixbox, set_button=0, sensitive=0
  widget_control, pwwidget.list_mode, set_droplist_select=1, set_uvalue=mode
  widget_control, pwwidget.button_pos, get_uvalue=position
  widget_control, pwwidget.slider_box, get_value=dbox

  position = {DEFINED:0, POSFILE:position.posfile, FREETURE:position.freeture, NDET:0, DET_FRAME:0, XPOS:0, YPOS:0, STRCOORD:'', DATA:'', BOX:dbox}

  widget_control, pwwidget.button_pos, set_uvalue=position

endif

img.camera = camera
img.pseudo = pseudo
 
img.image = ima[0:img.xsize-1, 0:img.ysize-1]
 
ds=long(15*2^imgzoom.scale)

imgtmp = img.image[imgzoom.xcn-ds:imgzoom.xcn+ds-1, imgzoom.ycn-ds:imgzoom.ycn+ds-1]
xcoord = imgzoom.xcn-ds+indgen(2*ds)
ycoord = imgzoom.ycn-ds+indgen(2*ds)

imgzoom.xcoord = rebin(xcoord, imgzoom.xsize)
imgzoom.ycoord = rebin(ycoord, imgzoom.ysize)
imgzoom.image  = rebin(imgtmp, imgzoom.xsize, imgzoom.ysize, sample=~widget_info(pwwidget.button_interpol, /button_set))
 
case mode of
 
  'detection': begin
    
    basename = file_basename(filename)
    basename = strmid(basename,6,strlen(basename))
    img.framenum = fix(basename)
    
  end
  
  'capture': begin
    
    img.framenum = 0
    
  end
  
endcase
 
widget_control,pwwidget.draw_big, set_uvalue=img
widget_control,pwwidget.draw_zoom, set_uvalue=imgzoom

widget_control, pwwidget.text_filename, set_uvalue=filename
widget_control, pwwidget.button_file, set_uvalue=path
   
; if position is checked, retrieve newposition.txt (or create new file from position.txt if first time)
if widget_info(pwwidget.button_loadpos, /button_set) then begin

  PW_loadpos, pwwidget

  ; if auto centre is checked then
  if widget_info(pwwidget.button_autopos, /button_set) then PW_autopos, pwwidget

endif

; draw image
PW_draw_image, pwwidget

; check if previous and next images exists
files = file_search(path + path_sep() + '*.fit*')

; current requested file
ii = where(files eq filename[0])
ii = ii[0]
 
; check for prev and next files
if ii ne -1 then begin

  if ii ne n_elements(files)-1 then begin

    widget_control, pwwidget.button_nextimage, set_uvalue=files[ii+1]
    widget_control, pwwidget.button_nextimage, /sensitive

  endif else begin

    widget_control, pwwidget.button_nextimage, set_uvalue=''
    widget_control, pwwidget.button_nextimage, sensitive=0

  endelse

  if ii ne 0 then begin

    widget_control, pwwidget.button_previmage, set_uvalue=files[ii-1]
    widget_control, pwwidget.button_previmage, /sensitive

  endif else begin

    widget_control, pwwidget.button_previmage, set_uvalue=''
    widget_control, pwwidget.button_previmage, sensitive=0

  endelse
  
endif

end