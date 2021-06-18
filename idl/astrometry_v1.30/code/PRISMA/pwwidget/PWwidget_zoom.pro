; This procedure manages the events on the zoom draw window of PRISMAwidget

pro PWwidget_zoom, event

compile_opt idl2

widget_control, event.top, get_uvalue=pwwidget
widget_control, pwwidget.text_filename, get_value=filename

if filename ne '' then begin
  
  ; case for different event types
  case event.type of

    ; moving mouse on image
    2: begin

      widget_control, pwwidget.draw_zoom, get_uvalue=imgzoom
      widget_control, pwwidget.text_xpos, set_value=strtrim(imgzoom.xcoord[event.x], 2)
      widget_control, pwwidget.text_ypos, set_value=strtrim(imgzoom.ycoord[event.y], 2)
      widget_control, pwwidget.text_imgvalue, set_value=strtrim(fix(imgzoom.image[event.x,event.y]), 2)

    end

    ; button released
    1: begin

      ; retrieve images
      widget_control,pwwidget.draw_big, get_uvalue=img
      widget_control,pwwidget.draw_zoom, get_uvalue=imgzoom

      ; retrieve mouse position in image coordinates
      imgzoom.xcn = imgzoom.xcoord[event.x]
      imgzoom.ycn = imgzoom.ycoord[event.y]

      ; right click - save current position in position.txt
      if event.release eq 4 then begin

        if widget_info(pwwidget.button_loadpos, /button_set) then begin

          widget_control, pwwidget.button_pos, get_uvalue=position
          widget_control, pwwidget.slider_box, get_value=dbox
          
          defined   = position.defined
          Ndet      = position.Ndet
          posfile   = position.posfile
          freeture  = position.freeture
          det_frame = position.det_frame
          xpos      = position.xpos
          ypos      = position.ypos
          strcoord  = position.strcoord
          data      = position.data
          box       = position.box
          
          if defined then begin
            
            ; looking if the current image is already listed in position
            ii = where(det_frame eq img.framenum, complement=ii0)
            
            ; if listed
            if ii[0] ne -1 then begin

              id = ii[0]
              
              ; if the selected pixel is the same already saved
              if xpos[id] eq imgzoom.xcn and ypos[id] eq imgzoom.ycn then begin
                
                ; remove from the list
                if ii0[0] ne -1 then begin
                  
                  Ndet      = Ndet - 1
                  det_frame = det_frame[ii0]
                  xpos      = xpos[ii0]
                  ypos      = ypos[ii0]
                  strcoord  = strcoord[ii0]
                  data      = data[ii0]
                  box       = box[ii0]
                
                ; it was the last one, undefine position
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
              
              ; replace the value in position
              endif else begin

                xpos[id]     = imgzoom.xcn
                ypos[id]     = imgzoom.ycn
                strcoord[id] = '('+strtrim(imgzoom.xcn,2)+';'+strtrim(imgzoom.ycn,2)+')'
                data[id]     = img.data
                box[id]      = dbox

              endelse
            
            ; add to the list
            endif else begin
              
              Ndet      = Ndet + 1
              det_frame = [det_frame,img.framenum]
              xpos      = [xpos,imgzoom.xcn]
              ypos      = [ypos,imgzoom.ycn]
              strcoord  = [strcoord,'('+strtrim(imgzoom.xcn,2)+';'+strtrim(imgzoom.ycn,2)+')']
              data      = [data,img.data]
              box       = [box,dbox]

              jj        = sort(det_frame)

              det_frame = det_frame[jj]
              xpos      = xpos[jj]
              ypos      = ypos[jj]
              strcoord  = strcoord[jj]
              data      = data[jj]
              box       = box[jj]

            endelse
          
          ; it is the first value inserted, define position
          endif else begin
            
            defined   = 1
            Ndet      = 1
            det_frame = [img.framenum]
            xpos      = [imgzoom.xcn]
            ypos      = [imgzoom.ycn]
            strcoord  = ['('+strtrim(imgzoom.xcn,2)+';'+strtrim(imgzoom.ycn,2)+')']
            data      = [img.data]
            box       = dbox
            
          endelse
          
          position = {defined:defined, posfile:posfile, freeture:freeture, Ndet:Ndet, det_frame:det_frame, xpos:xpos, ypos:ypos, strcoord:strcoord, data:data, box:box}

          widget_control, pwwidget.button_pos, set_uvalue=position

          nl = n_elements(xpos)
          openw, lun, posfile, /get_lun
          if defined then for i=0, nl-1 do printf, lun, det_frame[i], strcoord[i], data[i], box[i], format='(I7,A15,A30,I7)'
          close, lun & free_lun, lun

          ; print position to widget table
          if defined then begin
            
            str = transpose([[string(fix(det_frame))], [string(strcoord)], [string(data)], [string(box)]])
            
          endif else begin
          
            str = ['','','','']
          
          endelse
          
          widget_control, pwwidget.table_pos, table_ysize=Ndet>25, alignment=2, set_value=str

          PW_draw_image, pwwidget

        endif
      
      ; left click - re-centre zoom box
      endif else begin 

        ; update window centre coordinates
        ds=long(15*2^imgzoom.scale)

        ; correct for border effects
        if imgzoom.xcn lt ds then imgzoom.xcn = ds
        if imgzoom.xcn gt img.xsize-ds then imgzoom.xcn = img.xsize-ds
        if imgzoom.ycn lt ds then imgzoom.ycn = ds
        if imgzoom.ycn gt img.ysize-ds then imgzoom.ycn = img.ysize-ds
        widget_control, pwwidget.text_zoomxc, set_value=strtrim(imgzoom.xcn,2)
        widget_control, pwwidget.text_zoomyc, set_value=strtrim(imgzoom.ycn,2)
        xcoord = imgzoom.xcn-ds+indgen(2*ds)
        ycoord = imgzoom.ycn-ds+indgen(2*ds)
        imgzoom.xcoord = rebin(xcoord, 480)
        imgzoom.ycoord = rebin(ycoord, 480)
        imgtmp = img.image[imgzoom.xcn-ds:imgzoom.xcn+ds-1, imgzoom.ycn-ds:imgzoom.ycn+ds-1]
        imgzoom.image = rebin(imgtmp, 480, 480, sample=~widget_info(pwwidget.button_interpol, /button_set))
        widget_control, pwwidget.draw_zoom, set_uvalue=imgzoom

        PW_draw_image, pwwidget

      endelse

    end
    
    ; nothing to do in the other case
    else: begin

    end

  endcase

endif

end