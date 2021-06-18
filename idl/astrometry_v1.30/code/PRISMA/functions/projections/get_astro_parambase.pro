; function that define baseline parameters for the corresponding astrometric model

function get_astro_parambase, model, param

compile_opt idl2

case strlowcase(model) of
  
  'proj_poly2'           : retv = [param[0:3], 0.]
  'proj_asin1'           : retv = param
  'proj_exp1'            : retv = [param[0:3], 0., 0.]
  'proj_rot_poly2'       : retv = [param[0:2], 0., 0., param[5], 0.]
  'proj_rotz_poly2'      : retv = [param[0:2], param[1:2], param[5], 0.]
  'proj_rot_exp1'        : retv = [param[0:2], 0., 0., param[5], 0., 0.]  
  'proj_rotz_exp1'       : retv = [param[0:2], param[1:2], param[5], 0., 0.] 
  'proj_rot_poly2_asym'  : retv = [param[0:2], 0., 0., param[5], 0., 0., 0.]
  'proj_rotz_poly2_asym' : retv = [param[0:2], param[1:2], param[5], 0., 0., 0.]
  'proj_rot_exp1_asym'   : retv = [param[0:2], 0., 0., param[5], 0., 0., 0., 0.]
  'proj_rotz_exp1_asym'  : retv = [param[0:2], param[1:2], param[5], 0., 0., 0., 0.]
  
  else: begin
    
    message, 'baseline parameters not defined for ' + strlowcase(model) + ' model. Please check.'
    
  end
  
endcase

return, retv

end