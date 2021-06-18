; filling leading zeros in data string

pro lzeros_datastring, data

compile_opt idl2

data = strmid(data,0,24)

for i=0, n_elements(data)-1 do begin
  
  aa = strsplit(data[i], '.', /extract)
  
  case n_elements(aa) of
    
    1 : data[i] = aa[0] + '.' + '0000'
    
    2: begin
      
      if strlen(aa[1]) eq 1 then data[i] = aa[0] + '.' + aa[1] + '000'
      if strlen(aa[1]) eq 2 then data[i] = aa[0] + '.' + aa[1] + '00'
      if strlen(aa[1]) eq 3 then data[i] = aa[0] + '.' + aa[1] + '0'
      
    end
    
    else:
    
  endcase
  
endfor

end