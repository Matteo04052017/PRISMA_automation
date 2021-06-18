; getting fits filename from det_frame vector

function fits_filename, det_frame, mlen=mlen 

compile_opt idl2

str = strtrim(det_frame,2)
len = strlen(str)
if ~keyword_set(mlen) then mlen = max(len)
ii = where(len ne mlen)

if ii[0] ne -1 then begin

  for i=0, n_elements(ii)-1 do begin

    for j=0, mlen - len[ii[i]] - 1 do str[ii[i]] = '0' + str[ii[i]]

  endfor

endif

retv = 'frame_'+str+'.fit'

return, retv

end