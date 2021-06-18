; provide model informations for PSF models

function psf_model_info, model, param=param

compile_opt idl2

case strlowcase(model) of

  'gaussian' : begin
    
    names    =  ['sat', 'bkg', 'h'  , 'xc' , 'yc' , 'sx' , 'sy' , 'tilt']
    units    =  ['/'  , 'adu', 'adu', 'px' , 'px' , 'px' , 'px' , 'rad' ]
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6 )'
    format_r = '(F    , F    , F    , F    , F    , F    , F    , F     )'
    
  end
  
  'gaussian_int' : begin
    
    names    =  ['sat', 'bkg', 'h'  , 'xc' , 'yc' , 'sx' , 'sy' , 'tilt']
    units    =  ['/'  , 'adu', 'adu', 'px' , 'px' , 'px' , 'px' , 'rad' ]
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6 )'
    format_r = '(F    , F    , F    , F    , F    , F    , F    , F     )'
    
  end
  
  'gaussian_num' : begin 
    
    names    =  ['sat', 'bkg', 'h'  , 'xc' , 'yc' , 'sx' , 'sy' , 'tilt']
    units    =  ['/'  , 'adu', 'adu', 'px' , 'px' , 'px' , 'px' , 'rad' ]
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6 )'
    format_r = '(F    , F    , F    , F    , F    , F    , F    , F     )'
  
  end
  
;  'moffat' : begin 
;    
;    names    =  ['sat', 'bkg', 'h'  , 'xc' , 'yc' , 'sx' , 'sy' , 'gamma', 'tilt']
;    units    =  ['/'  , 'adu', 'adu', 'px' , 'px' , 'px' , 'px' , '/'    , 'rad' ]
;    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6, E19.6  , E19.6 )'
;    format_r = '(F    , F    , F    , F    , F    , F    , F    , F      , F     )'
;    
;  end

  else: begin

    message, 'parameters info not defined for ' + strlowcase(model) + ' model. Please check.'

  end

endcase

names  = strlowcase(names)
units  = strlowcase(units)
format_w = strcompress(format_w, /remove_all)
format_r = strcompress(format_r, /remove_all)

retv = {names:names, units:units, format_w:format_w, format_r:format_r, nparam:n_elements(names)}

return, retv

end