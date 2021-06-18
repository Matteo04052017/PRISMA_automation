; provide astrometric model information

function astro_model_info, model

compile_opt idl2

case strlowcase(model) of
  
  'proj_poly2': begin

    names    =  ['a0' , 'xc' , 'yc' , 'p1'    , 'p2'          ]
    units    =  ['rad', 'px' , 'px' , 'rad/px', 'rad^(1/2)/px']
    format_w = '(E19.6, E19.6, E19.6, E19.6   , E19.6         )'
    format_r = '(F    , F    , F    , F       , F             )'
    

  end
  
  'proj_asin1': begin

    names    =  ['a0' , 'xc' , 'yc' , 'f'  , 'r1' ]
    units    =  ['rad', 'px' , 'px' , '/'  , 'px' ]
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6)'
    format_r = '(F    , F    , F    , F    , F    )'

  end
  
  'proj_exp1': begin
    
    names    =  ['a0' , 'xc' , 'yc' , 'v'     , 's'  , 'd'   ]
    units    =  ['rad', 'px' , 'px' , 'rad/px', 'rad', '1/px']
    format_w = '(E19.6, E19.6, E19.6, E19.6   , E19.6, E19.6 )'
    format_r = '(F    , F    , F    , F       , F    , F     )'
     
  end
  
  'proj_rot_poly2': begin

    names    =  ['a0' , 'xo' , 'yo' , 'e'  , 'eps', 'p1'    , 'p2'          ]
    units    =  ['rad', 'px' , 'px' , 'rad', 'rad', 'rad/px', 'rad^(1/2)/px']
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6         )'
    format_r = '(F    , F    , F    , F    , F    , F       , F             )'

  end

  'proj_rotz_poly2': begin

    names    =  ['a0' , 'xo' , 'yo' , 'xz' , 'yz' , 'p1'    , 'p2'          ]
    units    =  ['rad', 'px' , 'px' , 'px' , 'px' , 'rad/px', 'rad^(1/2)/px']
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6         )'
    format_r = '(F    , F    , F    , F    , F    , F       , F             )'

  end
  
  'proj_rot_exp1': begin
   
    names    =  ['a0' , 'xo' , 'yo' , 'e'  , 'eps', 'v'     , 's'  , 'd'   ]
    units    =  ['rad', 'px' , 'px' , 'rad', 'rad', 'rad/px', 'rad', '1/px']   
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6, E19.6 )'
    format_r = '(F    , F    , F    , F    , F    , F       , F    , F     )'

  end

  'proj_rotz_exp1': begin

    names    =  ['a0' , 'xo' , 'yo' , 'xz' , 'yz' , 'v'     , 's'  , 'd'   ]
    units    =  ['rad', 'px' , 'px' , 'px' , 'px' , 'rad/px', 'rad', '1/px']   
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6, E19.6 )'
    format_r = '(F    , F    , F    , F    , F    , F       , F    , F     )'

  end
  
  'proj_rot_poly2_asym': begin

    names    =  ['a0' , 'xo' , 'yo' , 'e'  , 'eps', 'p1'    , 'p2'          , 'j'  , 'phi']
    units    =  ['rad', 'px' , 'px' , 'rad', 'rad', 'rad/px', 'rad^(1/2)/px', '/'  , 'rad']
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6         , E19.6, E19.6)'
    format_r = '(F    , F    , F    , F    , F    , F       , F             , F    , F    )'

  end

  'proj_rotz_poly2_asym': begin

    names    =  ['a0' , 'xo' , 'yo' , 'xz' , 'yz' , 'p1'    , 'p2'          , 'j'  , 'phi']
    units    =  ['rad', 'px' , 'px' , 'px' , 'px' , 'rad/px', 'rad^(1/2)/px', '/'  , 'rad']
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6         , E19.6, E19.6)'
    format_r = '(F    , F    , F    , F    , F    , F       , F             , F    , F    )'

  end
  
  'proj_rot_exp1_asym': begin

    names    =  ['a0' , 'xo' , 'yo' , 'e'  , 'eps', 'v'     , 's'  , 'd'   , 'j'  , 'phi']
    units    =  ['rad', 'px' , 'px' , 'rad', 'rad', 'rad/px', 'rad', '1/px', '/'  , 'rad']
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6, E19.6 , E19.6, E19.6)'
    format_r = '(F    , F    , F    , F    , F    , F       , F    , F     , F    , F    )'

  end

  'proj_rotz_exp1_asym': begin

    names    =  ['a0' , 'xo' , 'yo' , 'xz' , 'yz' , 'v'     , 's'  , 'd'   , 'j'  , 'phi']
    units    =  ['rad', 'px' , 'px' , 'px' , 'px' , 'rad/px', 'rad', '1/px', '/'  , 'rad']
    format_w = '(E19.6, E19.6, E19.6, E19.6, E19.6, E19.6   , E19.6, E19.6 , E19.6, E19.6)'
    format_r = '(F    , F    , F    , F    , F    , F       , F    , F     , F    , F    )'

  end
  
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