; procedure that hanlde the calibration of one month of captures

pro calibration_pro

compile_opt idl2

; camera code to be analyzed
camera = 'ITCP03'

; target of the analysis, can be a single day (e.g. 20170104) or a whole month (e.g. 201701)
target = '20200722'

; configuration file
config_file = '/PRISMA/settings/configuration.ini'

process_image = 1
process_day   = 1
process_month = 1

config = get_config(config_file, return0=0)

!quiet  = config.quiet
!except = config.except
on_error, config.on_error

case strlen(target) of
  
  ; month input
  6: begin

    this_month = target
    this_day   = ''

  end
  
  ; day input
  8: begin
    
    this_month = strmid(target,0,6)
    this_day   = target
    
  end
  
  else: begin
    
    message, target + ' input not valid. Please check.'
    
  end
  
endcase

useful_vars

; retrieve setting parameters
par = get_par(config, camera, return0=0)

; finding every captures for the month of the camera
info = par.config.path.dir_captures + path_sep() + par.camera + path_sep() + this_month + $
       path_sep() + par.camera + '_' + '*.fit*'
ff = file_search(info)

if ff[0] eq '' then begin
  
  message, par.camera + this_month + ' - no data found in ' + info + path_sep() + '. Please check.'
  
endif

ff = ff[sort(ff)]
n  = n_elements(ff)

; reading time from filenames
len    = strlen(file_dirname(ff[0], /mark_directory)) + strlen(par.camera) + 1
year   = long(strmid(ff, len, 4))
month  = long(strmid(ff, len+4, 2))
day    = long(strmid(ff, len+6, 2))
hour   = double(strmid(ff, len+9, 2))
minute = double(strmid(ff, len+11, 2))
second = double(strmid(ff, len+13, 2))
hr     = hour + minute/60D + second/3600D

; computing julian dates for frames
jdcnv, year, month, day, hr, julian_date

; splitting the ensemble of month acquisition in julian days (from 12 UTC to 12 UTC of the next day)

flor = floor(julian_date)

start  = []
finish = []

ii0 = where(flor gt 0) & ok = 1

while ok do begin
  
  current = min(flor[ii0], /nan)
  ii = where(flor eq current)
  
  start  = [start, ii[0]]
  finish = [finish, ii[n_elements(ii)-1]]
  
  flor[ii] = 0
  
  ii0 = where(flor gt 0)
  
  if ii0[0] ne -1 then ok = 1 else ok = 0
  
endwhile

if n_elements(start) eq 0 or n_elements(finish) eq 0 then begin
  
  message, par.camera + this_month + ' - splitting data in julian days in ' + info + $
           path_sep() + ' was somehow impossible. Please check.'
  
endif

Nday = n_elements(start)

days = strarr(Nday)
ii = where(hour[start] ge 12, complement=ii0)

if ii[0]  ne -1 then days[ii]  = strtrim(day[start[ii]], 2)
if ii0[0] ne -1 then days[ii0] = strtrim(day[start[ii0]]-1, 2)

ii = where(strlen(days) eq 1)
if ii[0] ne -1 then days[ii] = '0' + days[ii]

days = this_month + days

if this_day ne '' then begin
  
  ii = where(days eq this_day)
  
  if ii[0] ne -1 and n_elements(ii) eq 1 then begin 
    
    days   = days[ii] 
    start  = start[ii]
    finish = finish[ii]
    
  endif else begin
    
    message, par.camera + '_' + this_day + ' - data cannot be found. Please check.'
    
  endelse
  
endif

; calling astrometry (and photometry) procedures for each day
if process_image or process_day then begin
  
  for i = 0, n_elements(start)-1 do begin
  
    if finish[i] - start[i] gt 1 then begin
      
      if ~!quiet then tic
      
      captures = ff[start[i]:finish[i]]
      
      message, par.camera + '_' + days[i] + ' - start processing.', /informational
      
      if process_image then astrometry_image, par, days[i], captures;, /stop_image;, /yplot;, /stop_iter;, /cat_yplot
      
      if process_day then astrometry_day, par, days[i]
      
      if ~!quiet then toc
      
    endif

  endfor
  
endif

if process_month then begin
  
  if ~!quiet then tic
  
  message, par.camera + '_' + this_month + ' - start processing.', /informational

  ; calling astrometry (and photometry) procedures for the month
  astrometry_month, par, this_month
  
  if ~!quiet then toc
  
endif

end