; fill missing frames list for events

pro fill_frames, ff, det_frame, Ndet, xpos, ypos

compile_opt idl2

min_frame = min(det_frame)
max_frame = max(det_frame)

missing =[]

for fn=min_frame, max_frame do begin

  framefile = 'frame_'+strtrim(fn,2)+'.fit'
  thereis_ff = where(ff eq framefile)
  thereis_det = where(det_frame eq fn)

  if thereis_ff[0] ne -1 and thereis_det[0] eq -1 then missing = [missing, fn]

endfor

if n_elements(missing) gt 0 then begin
  
  missing_xpos = round(interpol(xpos, det_frame, float(missing), /lsquadratic, /nan))
  missing_ypos = round(interpol(ypos, det_frame, float(missing), /lsquadratic, /nan))

  xpos = [xpos, missing_xpos]
  ypos = [ypos, missing_ypos]

  det_frame = [det_frame, missing]
  sort_frame = sort(det_frame)
  det_frame = det_frame[sort_frame]
  xpos = xpos[sort_frame]
  ypos = ypos[sort_frame]
  Ndet = n_elements(det_frame)

endif

end