; function that build parameters setting for the calibration routines

function get_par, config_file, name, return0=return0, pseudo=pseudo

compile_opt idl2

if ~isa(return0) then return0=0

case strlowcase(typename(config_file)) of
  
  'string': begin
    
    ; retrieve code configuration from the config file
    config = get_config(config_file, return0=return0)

    if ~config.file then begin

      retv = { file:'' }
      if return0 then return, retv else retall

    endif
    
  end
  
  'anonymous' or 'struct': begin
    
    config = config_file
    
  end
  
  else: begin
    
    message, 'config_file variable should be set as a string (filename) or structure (already imported by get_config). Please check.', /continue
    retv = { file:'' }
    if return0 then return, retv else retall
    
  end
  
endcase

if keyword_set(pseudo) then begin
  
  pseudo = name
  
  camera = pseudo_to_camera(config.path.solutions, name, return0=return0)
  
  if camera eq '' then begin
    
    retv = { file:'' }
    if return0 then return, retv else retall
    
  endif  
  
endif else begin
  
  camera = name
  pseudo = camera_to_pseudo(config.path.solutions, name, return0=return0) 
    
  if pseudo eq '' then begin

    retv = { file:'' }
    if return0 then return, retv else retall

  endif
  
endelse

; loading camera setting from specified config file
cam_par = camera_par(camera, config.path.dir_config, return0=return0)

if cam_par.file eq '' then begin
  
  retv = { file:'' }
  if return0 then return, retv else retall
  
endif else begin
  
  ; store everything in a structure, wrapping cam_par
  retv = create_struct(cam_par, 'camera', camera, 'pseudo', pseudo, 'config', config)
  return, retv
  
endelse

end