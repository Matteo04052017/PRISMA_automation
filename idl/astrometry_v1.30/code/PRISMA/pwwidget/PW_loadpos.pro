; This procedure loads the position values into the PRISMAwidget 

pro PW_loadpos, pwwidget

widget_control, pwwidget.button_pos, get_uvalue=position
 
posfile  = position.posfile
freeture = position.freeture

; search for the newpositions.txt file
ff = file_search(posfile)

; if there is no newpositions.txt
if ff[0] eq '' then begin
  
  ; search for positions.txt
  gg = file_search(freeture)
  
  ; if there is positions.txt
  if gg[0] ne '' then begin
    
    ; copy positions.txt and rename newpositions.txt
    file_copy, freeture, posfile
  
  ; create newpositions.txt file
  endif else begin

    openw, lun, posfile, /get_lun
    close, lun & free_lun, lun

  endelse

endif

; size of newpositions.txt
info = file_info(posfile)

; if it is not empty
if info.size gt 0 then begin
  
  defined = 1
  
  ; read the file
  table = read_table(posfile, /text)
  s = size(table)
  
  det_frame = reform(fix(table[0,*]))
  strcoord  = reform(table[1,*])
  data      = reform(table[2,*])
  lzeros_datastring, data
  
  Ndet = n_elements(strcoord)
  widget_control, pwwidget.slider_box, get_value=dbox
  
  case s[1] of
    
    3: box = replicate(dbox, Ndet)
    4: box = reform(fix(table[3,*]))
    
  endcase
  
  oo = sort(det_frame)
  det_frame = det_frame[oo]
  strcoord  = strcoord[oo]
  data      = data[oo]
  box       = box[oo]
  
  uu = uniq(det_frame)
  det_frame = det_frame[uu]
  strcoord  = strcoord[uu]
  data      = data[uu]
  box       = box[uu] 

  ; extract coordinates from position string
  get_coord, strcoord, xpos, ypos
  
  ; if auto-centre option is selected
  if widget_info(pwwidget.button_autopos,/button_set) then begin
    
    widget_control, pwwidget.draw_big, get_uvalue=img
    
    kk = where(det_frame eq img.framenum)
    kk = kk[0]
    
    if kk ne -1 then begin
      
      ; if fix-box button is selected
      button_fixbox = widget_info(pwwidget.button_fixbox, /button_set)

      if button_fixbox then box[kk] = dbox else widget_control, pwwidget.slider_box, set_value = box[kk]

    endif
    
  endif
  
endif else begin
  
    defined   = 0
    Ndet      = 0
    det_frame = 0
    xpos      = 0
    ypos      = 0
    strcoord  = ''
    data      = ''
    box       = dbox

endelse

; save position values
position = {defined:defined, posfile:posfile, freeture:freeture, Ndet:Ndet, det_frame:det_frame, strcoord:strcoord, xpos:xpos, ypos:ypos, data:data, box:box}
widget_control, pwwidget.button_pos, set_uvalue=position

; print position to widget table
if defined then begin
  
  str = transpose([[string(fix(det_frame))], [string(strcoord)], [string(data)], [string(box)]])
  
endif else begin

  str = ['','','','']

endelse

widget_control, pwwidget.table_pos, table_ysize=Ndet>25, alignment=2, set_value=str

; print position to file
nl = n_elements(xpos)
openw, lun, posfile, /get_lun
if defined then for i=0,nl-1 do printf, lun, det_frame[i], strcoord[i], data[i], box[i], format='(I7,A15,A30,I7)'
close, lun & free_lun, lun

end