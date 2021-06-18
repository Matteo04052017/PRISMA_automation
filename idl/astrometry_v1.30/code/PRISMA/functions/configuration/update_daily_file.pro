; updating param or sigma type file

pro update_daily_file, file, this_day, datum, model

; param file
info = file_info(file.name)

; if the file for daily parameters do not exists or it's empty
if info.size eq 0 then begin

  days = [this_day]
  data = [datum]

  ; if the file for daily parameters exists and it's not empty
endif else begin

  readcol, file.name, junk, junk, this_model, format = '(A,A,A)', /silent

  if this_model[0] eq model then begin

    ; reading existing data
    columns = indgen(n_elements(datum))+1

    data = read_table(file.name, columns = columns, head=6)
    days = read_table(file.name, columns = [0], /text, head=6)

    ; finding if the current day is already reported in the file
    ii = where(days eq this_day)

    ; if the current day is not reported, let's add it
    if ii[0] eq -1 then begin

      days = [[days], [this_day]]
      data = [[data], [datum]]

    endif else begin

      ; else, let's replace it
      data[*,ii] = [datum]

    endelse

    ; sorting rows
    ii   = sort(days)
    days = days[ii]
    data = data[*,ii]

  endif else begin

    days = [this_day]
    data = [datum]

  endelse

endelse

print_header, file

openw, lun, file.name, /get_lun, /append

for i=0, n_elements(days)-1 do begin

  printf, lun, days[i], data[*,i], format = file.format_w

endfor

close, lun & free_lun, lun

end