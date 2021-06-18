; procedure that analyze a single detection in an event directory

pro detection_pro

compile_opt idl2

config_file = '/PRISMA/settings/configuration.ini'

; event directory
event = '20190110T041837_UT'

; detection directory
detection = 'FINALELIGURE_20190110T041838_UT'

; retrieve configuration 
config = get_config(config_file)

!quiet  = config.quiet
!except = config.except
on_error, config.on_error

cd, config.path.dir_events, current = old_dir
cd, event

useful_vars

message, detection + ' - start processing.', /informational

if ~!quiet then tic

detection_astrometry, config, event, detection

if ~!quiet then toc

cd, old_dir

end