; readcol for multiple files

pro myreadcol, name, v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15, $
                     v16,v17,v18,v19,v20,v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,$
                     v31,v32,v33,v34,v35,v36,v37,v38,v39,v40,v41,v42,v43,v44,v45, $
                     v46,v47,v48,v49,v50, COMMENT = comment, $
                     FORMAT = format, DEBUG=debug, SILENT=silent, SKIPLINE = skipline, $
                     NUMLINE = numline, DELIMITER = delimiter, NAN = NaN, $
                     PRESERVE_NULL = preserve_null, COUNT=ngood, NLINES=nlines, $
                     STRINGSKIP = stringskip, QUICK = quick, COMPRESS = compress

compile_opt idl2

if ~keyword_set(comment)       then comment = []
if ~keyword_set(format)        then format = []
if ~keyword_set(debug)         then debug = []
if ~keyword_set(silent)        then silent = []
if ~keyword_set(delimiter)     then delimiter = []
if ~keyword_set(NaN)           then NaN = []
if ~keyword_set(preserve_null) then preserve_null = []
if ~keyword_set(count)         then ngood = []
if ~keyword_set(nlines)        then nlines = []
if ~keyword_set(stringskip)    then stringskip = []
if ~keyword_set(skipline)      then skipline = []
if ~keyword_set(numline)       then numline = []
if ~keyword_set(quick)         then quick = []
if ~keyword_set(compress)      then compress = []
                     
n = N_params() - 1
m = n_elements(name)

var = strarr(n)
inp = strarr(n)

for i=0, n-1 do begin
  
  inp[i] = "v" + strtrim(i+1,2)
  var[i] = "e" + strtrim(i+1,2)
  res = execute("v" + strtrim(i+1,2) + " = []",1,1)
  
endfor

for j=0, m-1 do begin
  
  str = "readcol, '" + name[j] + "'" 
  
  for i=0, n-1 do begin
    
    str = str + ", " + var[i]
    
  endfor
  
  str = str + ", COMMENT = comment," + $
               " FORMAT = format, DEBUG=debug, SILENT=silent, SKIPLINE=skipline," + $
               " NUMLINE=numline, DELIMITER = delimiter, NAN = NaN," + $
               " PRESERVE_NULL = preserve_null, COUNT=ngood, NLINES=nlines," + $
               " STRINGSKIP = skipstart, QUICK = quick, COMPRESS = compress"
              
  res = execute(str,1,1)
  
  for i=0, n-1 do begin
    
    res = execute(inp[i] + " = [" + inp[i] + ", " + var[i] + "]",1,1)
    
  endfor
  
endfor

end
