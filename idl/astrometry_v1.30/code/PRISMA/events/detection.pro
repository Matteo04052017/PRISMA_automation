; procedure that analyze a single detection in an event directory

pro detection, event, detection, config_file=config_file

compile_opt idl2

if ~isa(config_file) then config_file   = '/PRISMA/settings/configuration.ini'

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