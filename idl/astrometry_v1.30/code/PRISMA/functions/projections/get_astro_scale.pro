; retrieve radial plate scale from parameters vector, depending from different models

function get_astro_scale, model, param

compile_opt idl2

case strlowcase(model) of

  'proj_poly2'           : retv = param[3] 
  'proj_asin1'           : retv = param[3]/param[4]
  'proj_exp1'            : retv = param[3]
  'proj_rot_poly2'       : retv = param[5]
  'proj_rotz_poly2'      : retv = param[5] 
  'proj_rot_exp1'        : retv = param[5]  
  'proj_rotz_exp1'       : retv = param[5]
  'proj_rot_poly2_asym'  : retv = param[5]
  'proj_rotz_poly2_asym' : retv = param[5]
  'proj_rot_exp1_asym'   : retv = param[5]
  'proj_rotz_exp1_asym'  : retv = param[5]

  else: begin
    
    message, 'scale computation not defined for ' + strlowcase(model) + ' model. Please check.'

  end

endcase

return, retv

end