; read camera configuration file in dir_config

function camera_par, camera, dir_config, return0=return0

compile_opt idl2

if ~isa(return0) then return0=0

cd, dir_config, current = old_dir

config_file = camera + '.ini'

ff = file_search(config_file)

if ff[0] eq '' then begin
  
  cd, old_dir
  message, config_file + ' cannot be found in ' + dir_config + '. Please check.', /continue
  retv = { file:'' }
  if return0 then return, retv else retall
  
endif

config = mg_read_config(config_file)

; Fits
dim     = long(config->get('dim', section='Fits', /extract))
rotate  = long(config->get('rotate', section='Fits'))
center  = long(config->get('center', section='Fits', /extract))
radius  = long(config->get('radius', section='Fits'))
horizon = long(config->get('horizon', section='Fits'))
mask    = config->get('mask', section='Fits')
          
fits = {                    $
         dim:dim,           $
         rotate:rotate,     $
         center:center,     $
         radius:radius,     $
         horizon:horizon,   $
         mask:mask          $
       }

; Camera
latitude  = double(config->get('latitude', section='Station'))
longitude = double(config->get('longitude', section='Station'))
elevation = double(config->get('elevation', section='Station'))

station = {                                     $
            latitude:latitude,                  $
            longitude:longitude,                $
            elevation:elevation                 $
          }

; Astrometry
model_image   = strlowcase(config->get('model_image', section='Astrometry'))
param_image   = float(config->get('param_image', section='Astrometry', /extract))
fita_image    = float(config->get('fita_image', section='Astrometry', /extract))
model_daily   = strlowcase(config->get('model_daily', section='Astrometry'))
param_daily   = float(config->get('param_daily', section='Astrometry', /extract))
fita_daily    = float(config->get('fita_daily', section='Astrometry', /extract))
model_monthly = strlowcase(config->get('model_monthly', section='Astrometry'))
param_monthly = float(config->get('param_monthly', section='Astrometry', /extract))
fita_monthly = float(config->get('fita_monthly', section='Astrometry', /extract))

astrometry = {                                  $
               model_image:model_image,         $
               param_image:param_image,         $
               fita_image:fita_image,           $
               model_daily:model_daily,         $
               param_daily:param_daily,         $
               fita_daily:fita_daily,           $
               model_monthly:model_monthly,     $
               param_monthly:param_monthly,     $
               fita_monthly:fita_monthly        $
             }

; Find
fwhm        = float(config->get('fwhm', section='Find'))
sx          = float(config->get('sx', section='Find'))
sy          = float(config->get('sy', section='Find'))
roundlim    = float(config->get('roundlim', section='Find', /extract))
sharplim    = float(config->get('sharplim', section='Find', /extract))
min_iter    = long(config->get('min_iter', section='Find'))
max_iter    = long(config->get('max_iter', section='Find'))
switch_iter = long(config->get('switch_iter', section='Find'))
h_min1      = float(config->get('h_min1', section='Find'))
h_min2      = float(config->get('h_min2', section='Find'))
mag_lim1    = float(config->get('mag_lim1', section='Find'))
mag_lim2    = float(config->get('mag_lim2', section='Find'))
r_corr1     = float(config->get('r_corr1', section='Find'))
r_corr2     = float(config->get('r_corr2', section='Find'))
alt_lim1    = float(config->get('alt_lim1', section='Find'))/!radeg
alt_lim2    = float(config->get('alt_lim2', section='Find'))/!radeg
n_min       = long(config->get('n_min', section='Find'))
param_tool  = float(config->get('param_tool', section='Find'))

find = {                           $
         fwhm:fwhm,                $
         sx:sx,                    $
         sy:sy,                    $
         roundlim:roundlim,        $
         sharplim:sharplim,        $
         min_iter:min_iter,        $
         max_iter:max_iter,        $
         switch_iter:switch_iter,  $
         h_min1:h_min1,            $
         h_min2:h_min2,            $
         mag_lim1:mag_lim1,        $
         mag_lim2:mag_lim2,        $
         r_corr1:r_corr1,          $
         r_corr2:r_corr2,          $
         alt_lim1:alt_lim1,        $
         alt_lim2:alt_lim2,        $
         n_min:n_min,              $
         param_tool:param_tool     $
       }                    

; Ephemeris
r_moon_mask    = float(config->get('r_moon_mask', section='Ephemeris'))
sun_alt_lim    = float(config->get('sun_alt_lim', section='Ephemeris'))/!radeg
moon_phase_lim = float(config->get('moon_phase_lim', section='Ephemeris'))
moon_alt_lim   = float(config->get('moon_alt_lim', section='Ephemeris'))/!radeg

ephemeris = {                                   $
              sun_alt_lim:sun_alt_lim,          $
              r_moon_mask:r_moon_mask,          $
              moon_phase_lim:moon_phase_lim,    $
              moon_alt_lim:moon_alt_lim         $
            }

; Photometry
band       = long(config->get('band', section='Photometry'))
gain       = float(config->get('gain', section='Photometry'))
saturation = float(config->get('saturation', section='Photometry'))
exposure   = float(config->get('exposure', section='Photometry'))
star_aper  = long(config->get('star_aper', section='Photometry', /extract))
sky_aper   = long(config->get('sky_aper', section='Photometry', /extract))
C          = float(config->get('C', section='Photometry'))
k          = float(config->get('k', section='Photometry'))

photometry = {                                   $
               band:band,                        $
               gain:gain,                        $
               saturation:saturation,            $
               exposure:exposure,                $
               star_aper:star_aper,              $
               sky_aper:sky_aper,                $
               C:C,                              $
               k:k                               $
             }

;    ; per Bertaina (20180313) da commentare altrimenti
;    az_magsky[0:4] = [120.,171.,144.,0.,126.]/!radeg
;    zd_magsky[0:4] = [55.,57.,70.,0.,83.]/!radeg
;    sky_aper[2] = 45.

;    ; per Bertaina (20180314) da commentare altrimenti
;    az_magsky[0:3] = [181.,224.,0.,203.]/!radeg
;    zd_magsky[0:3] = [62.,57.,0.,5.]/!radeg
;    sky_aper[2] = 45
    

retv = {                         $ 
         file:ff[0],             $  
         fits:fits,              $
         station:station,        $
         astrometry:astrometry,  $
         find:find,              $                             
         ephemeris:ephemeris,    $
         photometry:photometry   $
       }
         
cd, old_dir
return, retv
  
end