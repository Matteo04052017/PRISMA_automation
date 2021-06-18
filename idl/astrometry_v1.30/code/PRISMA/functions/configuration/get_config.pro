; read configuration file for astrometry and photometry pipeline

function get_config, config_file, return0=return0

compile_opt idl2

if ~isa(return0) then return0=0

ff = file_search(config_file)

if ff[0] eq '' then begin
  
  message, config_file + ' cannot be found. Please check.', /continue
  retv = { file:'' }
  if return0 then return, retv else retall
  
endif

config = mg_read_config(config_file)

quiet    = fix(config->get('quiet'))
on_error = fix(config->get('on_error'))
except   = fix(config->get('except'))

; Path
dir_config     = check_path(config->get('dir_config', section='Path'))
dir_solutions  = check_path(config->get('dir_solutions', section='Path'))
dir_mask       = check_path(config->get('dir_mask', section='Path'))
dir_captures   = check_path(config->get('dir_captures', section='Path'))
dir_astrometry = check_path(config->get('dir_astrometry', section='Path'))
dir_events     = check_path(config->get('dir_events', section='Path'))
dir_results    = check_path(config->get('dir_results', section='Path'))
solutions      = check_path(config->get('solutions', section='Path'))
catalog        = check_path(config->get('catalog', section='Path'))
logo           = check_path(config->get('logo', section='Path'))

path = {                                   $
         dir_config:dir_config,            $
         dir_solutions:dir_solutions,      $
         dir_mask:dir_mask,                $
         dir_captures:dir_captures,        $
         dir_astrometry:dir_astrometry,    $
         dir_events:dir_events,            $
         dir_results:dir_results,          $
         solutions:solutions,              $
         catalog:catalog,                  $
         logo:logo                         $
       }

; Image
report_photo = string_to_boolean(config->get('report_photo', section='Image'))
yplot        = string_to_boolean(config->get('yplot', section='Image')) 
cat_yplot    = string_to_boolean(config->get('cat_yplot', section='Image')) 
stop_iter    = string_to_boolean(config->get('stop_iter', section='Image')) 
stop_image   = string_to_boolean(config->get('stop_image', section='Image'))
stop         = string_to_boolean(config->get('stop', section='Image')) 

image  = {                            $
           report_photo:report_photo, $
           yplot:yplot,               $
           cat_yplot:cat_yplot,       $
           stop_iter:stop_iter,       $
           stop_image:stop_image,     $
           stop:stop                  $
         } 
         
; Daily 
report_astro   = string_to_boolean(config->get('report_astro', section='Daily'))
histo          = string_to_boolean(config->get('histo', section='Daily'))
stop           = string_to_boolean(config->get('stop', section='Daily'))

daily = {                                $
          report_astro:report_astro,     $
          histo:histo,                   $
          stop:stop                      $
        }
      
; Monthly
report_astro   = string_to_boolean(config->get('report_astro', section='Monthly'))
histo          = string_to_boolean(config->get('histo', section='Monthly'))
stop           = string_to_boolean(config->get('stop', section='Monthly'))

monthly = {                                $
            report_astro:report_astro,     $
            histo:histo,                   $
            stop:stop                      $
          }
          
; Event
positions   = config->get('positions', section='Event')
fill_frames = string_to_boolean(config->get('fill_frames', section='Event'))
recenter    = string_to_boolean(config->get('recenter', section='Event'))
box_bolide  = float(config->get('box_bolide', section='Event'))
model_psf   = strlowcase(config->get('model_psf', section='Event'))
model_bar   = strlowcase(config->get('model_bar', section='Event'))
report      = string_to_boolean(config->get('report', section='Event'))
image1      = string_to_boolean(config->get('image', section='Event'))
video       = string_to_boolean(config->get('video', section='Event'))
stop        = string_to_boolean(config->get('stop', section='Event'))

event = {                            $
          positions:positions,       $
          fill_frames:fill_frames,   $
          recenter:recenter,         $
          box_bolide:box_bolide,     $
          model_psf:model_psf,       $
          model_bar:model_bar,       $
          report:report,             $
          image:image1,              $
          video:video,               $
          stop:stop                  $ 
        }
      
retv = { file:ff[0], quiet:quiet, on_error:on_error, except:except, path:path, image:image, daily:daily, monthly:monthly, event:event }
         
return, retv

end