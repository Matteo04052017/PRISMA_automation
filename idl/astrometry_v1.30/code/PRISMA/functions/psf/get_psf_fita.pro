; provide FITA vector for PSF model

function get_psf_fita, model, param=param

compile_opt idl2

case strlowcase(model) of

  'gaussian'     : fita = [0,1,1,1,1,1,1,0]
  'gaussian_int' : fita = [0,1,1,1,1,1,1,0]
  'gaussian_num' : fita = [0,1,1,1,1,1,1,0]
;  'moffat'       : fita = [0,1,1,1,1,1,1,1,0]

  else: begin

    message, 'fita definition not implemented for ' + strlowcase(model) + '. Please check.'

  end

endcase

return, fita

end