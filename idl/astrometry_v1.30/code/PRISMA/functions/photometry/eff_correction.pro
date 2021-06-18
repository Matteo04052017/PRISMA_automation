; correction for differential radial efficiency

pro eff_correction, var, zd, err=err, flux=flux, mag=mag

compile_opt idl2

if keyword_set(flux) and keyword_set(mag) then begin
  
  message, 'FLUX and MAG keywords are exclusive. Please check.'
  
endif

if ~keyword_set(flux) and ~keyword_set(mag) then begin

  message, 'one between FLUX or MAG keywords is mandatory. Please check.'

endif

; PRISMA
A0 = 1.04819
A1 = 0.00483018*!radeg
A2 = 0.04819

corr = A0 - A1*zd - A2 * exp( - (A1/A2) * zd )

;; DMI_SKYCAM
;corr = zd*0. + 1.

if keyword_set(mag) then begin
  
  var = var + 2.5*alog10(corr) 
  
endif 

if keyword_set(flux) then begin
  
  var = var / corr
  err = err / corr
  
endif

end