; procedure that analyze a directory of an event, made of two or more detection

pro event_pro

compile_opt idl2

config_file = '/PRISMA/settings/configuration.ini'

; event directory
event = '20200101T182654_UT'

; retrieve configuration 
config = get_config(config_file)

!quiet  = config.quiet
!except = config.except
on_error, config.on_error

cd, config.path.dir_events, current = old_dir
cd, event

useful_vars

; listing detection in the directory of the event
detection = file_search(/test_directory)
n = n_elements(detection)

message, event + ' - start processing.', /informational

for i=0, n-1 do begin
  
  message, detection[i] + ' - start processing.', /informational
  
  if ~!quiet then tic
  
  detection_astrometry, config, event, detection[i]
  
  if ~!quiet then toc
  
endfor

cd, old_dir

end