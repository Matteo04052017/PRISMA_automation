; This procedure computes the expected value of (x,y) by filtered barycentre

pro PW_autopos, pwwidget

compile_opt idl2
 
; retrieve user values
widget_control, pwwidget.button_pos, get_uvalue=position

defined   = position.defined

; if there is at least one position
if defined then begin
  
  posfile   = position.posfile
  freeture  = position.freeture
  Ndet      = position.Ndet
  det_frame = position.det_frame
  xpos      = position.xpos
  ypos      = position.ypos
  strcoord  = position.strcoord
  data      = position.data
  box       = position.box
  
  widget_control, pwwidget.draw_big, get_uvalue=img
  
  ; compute img index of minimum distance from img.framenum; NOTE: can be zero if button_pos exists
  junk = min(abs(det_frame-img.framenum), ii)  
  ii   = ii[0]
  
  ; check for button_fixbox
  button_fixbox = widget_info(pwwidget.button_fixbox, /button_set)
  widget_control, pwwidget.slider_box, get_value=dbox 
  if button_fixbox then this_box = dbox else this_box = box[ii]
  
  ; compute the box limits
  minx = max([0, xpos[ii]-this_box])
  maxx = min([img.xsize-1, xpos[ii]+this_box])
  miny = max([0, ypos[ii]-this_box])
  maxy = min([img.ysize-1, ypos[ii]+this_box])
  
  bocs = img.image[minx:maxx,miny:maxy]
  
  ; median filtering
  mediana = median(bocs, /even)
  sigma   = sqrt(mean((bocs-mediana)^2))
  jj      = where(bocs gt mediana+3*sigma)
  
  ; (x,y) bolide position found: perform autocentering
  if jj[0] ne -1 then begin

    ind   = array_indices(bocs,jj)
    xpos1 = round(mean(ind[0,*]))+xpos[ii]-this_box
    ypos1 = round(mean(ind[1,*]))+ypos[ii]-this_box
    kk    = where(det_frame eq img.framenum)
    kk    = kk[0]
    
    ; replace position in list
    if kk ne -1 then begin

      xpos[kk]     = xpos1
      ypos[kk]     = ypos1
      strcoord[kk] = '('+strtrim(xpos1,2)+';'+strtrim(ypos1,2)+')'
      data[kk]     = img.data
      box[kk]      = this_box
    
    ; add position to the list
    endif else begin

      Ndet      = Ndet + 1
      det_frame = [det_frame, img.framenum]
      xpos      = [xpos, xpos1]
      ypos      = [ypos, ypos1]
      strcoord  = [strcoord, '('+strtrim(xpos1,2)+';'+strtrim(ypos1,2)+')']
      data      = [data, img.data]
      box       = [box, this_box]
      
      hh = sort(det_frame)
      
      det_frame = det_frame[hh]
      xpos      = xpos[hh]
      ypos      = ypos[hh]
      strcoord  = strcoord[hh]
      data      = data[hh]
      box       = box[hh]
      
    endelse
  
  ; no position found, remove from the list
  endif else begin 
    
    kk0 = where(det_frame ne img.framenum)

    if kk0[0] ne -1 then begin

      Ndet      = Ndet-n_elements(kk0)
      det_frame = det_frame[kk0]
      xpos      = xpos[kk0]
      ypos      = ypos[kk0]
      strcoord  = strcoord[kk0]
      data      = data[kk0]
      box       = box[kk0]
    
    ; no more position in list
    endif else begin
      
      defined   = 0
      Ndet      = 0
      det_frame = 0
      xpos      = 0
      ypos      = 0
      strcoord  = ''
      data      = ''
      box       = this_box

    endelse

  endelse
  
  ; print position to file
  nl = n_elements(xpos)
  openw, lun, posfile,/get_lun
  if defined then for i=0, nl-1 do printf, lun, det_frame[i], strcoord[i], data[i], box[i], format='(I7,A15,A30,I7)'
  close, lun & free_lun, lun
  
  ; save position values
  position = {defined:defined, posfile:posfile, freeture:freeture, Ndet:Ndet, det_frame:det_frame, xpos:xpos, ypos:ypos, strcoord:strcoord, data:data, box:box}
  widget_control, pwwidget.button_pos, set_uvalue=position
  
  ; print position to widget table
  if defined then begin
    
    str = transpose([[string(fix(det_frame))], [string(strcoord)], [string(data)], [string(box)]])
    
  endif else begin
  
    str = ['','','','']
  
  endelse
  
  widget_control, pwwidget.table_pos, table_ysize=Ndet>25, alignment=2, set_value=str

endif

end