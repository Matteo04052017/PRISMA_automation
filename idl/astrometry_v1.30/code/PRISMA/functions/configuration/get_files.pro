; get filenames for output 

function get_files, day, par, detection=detection

compile_opt idl2

month = get_month(day)

; {{ IMAGE }}

; { ASTROMETRY }

; ASSOC
name_assoc = par.camera + '_' + day + '_assoc.txt'

heads_assoc = [                          $
               ['image',       '[/]'],   $
               ['julian_date', '[/]'],   $
               ['x',           '[px]'],  $
               ['s_x',         '[px]'],  $
               ['y',           '[px]'],  $
               ['s_y',         '[px]'],  $
               ['star_id',     '[/]'],   $
               ['az',          '[rad]'], $
               ['zd',          '[rad]'], $
               ['mags',        '[/]'],   $
               ['s_mags',      '[/]']    $
              ]

format_w = '(A38,F21.8,F13.3,F13.3,F13.3,F13.3,A19,F15.7,F15.7,F13.3,F13.3)'
format_r = '(A,D,F,F,F,F,A,D,D,F,F)'

trat = strjoin(replicate('-',total(format_length(format_w))))

header_assoc = [ 'model = ' + par.astrometry.model_image, trat, string(heads_assoc[0,*], format=format_header(format_w)), $
                                                                string(heads_assoc[1,*], format=format_header(format_w)), trat,' ']

assoc = { name:name_assoc, header:header_assoc, format_w:format_w, format_r:format_r }

; PARAM-SIGMA
name_param = par.camera + '_' + day + '_astro_param.txt'
name_sigma = par.camera + '_' + day + '_astro_sigma.txt'

heads_param = [                        $
               ['image',       '[/]'], $
               ['julian_date', '[/]'], $
               ['n',           '[/]']  $
              ]

heads_sigma = heads_param

names = astro_model_info(par.astrometry.model_image)

for i=0, n_elements(names.names)-1 do begin

  heads_param = [ [heads_param], [names.names[i], '[' + names.units[i] + ']'] ]
  heads_sigma = [ [heads_sigma], ['s_'+names.names[i], '[' + names.units[i] + ']'] ]

endfor

format_w = '(A38,F21.8,F13.0,' + strmid(names.format_w, 1, strlen(names.format_w)-1)
format_r = '(A,D,F,' + strmid(names.format_r, 1, strlen(names.format_r)-1)

trat = strjoin(replicate('-',total(format_length(format_w))))

header_param = [ 'model = ' + par.astrometry.model_image, trat, string(heads_param[0,*], format=format_header(format_w)), $
                                                                string(heads_param[1,*], format=format_header(format_w)), trat, ' '] 
                                                                                                                               
header_sigma = [ 'model = ' + par.astrometry.model_image, trat, string(heads_sigma[0,*], format=format_header(format_w)), $
                                                                string(heads_sigma[1,*], format=format_header(format_w)), trat, ' ']

param = { name:name_param, header:header_param, format_w:format_w, format_r:format_r } 
sigma = { name:name_sigma, header:header_sigma, format_w:format_w, format_r:format_r } 

astrometry = { param:param, sigma:sigma, assoc:assoc }

; { PHOTOMETRY } 

; PARAM-SIGMA
name_param = par.camera + '_' + day + '_photo_param.txt'
name_sigma = par.camera + '_' + day + '_photo_sigma.txt'

heads_param = [                              $
               ['image',       '[/]'],       $
               ['julian_date', '[/]'],       $
               ['n',           '[/]'],       $
               ['f',           '[/]'],       $
               ['exp',         '[sec]'],     $
               ['m_ph',        '[/]'],       $
               ['m_az',        '[rad]'],     $
               ['m_zd',        '[rad]'],     $
               ['s_az',        '[rad]'],     $
               ['s_zd',        '[rad]'],     $
               ['scale',       '[rad/px]'],  $
               ['c',           '[/]'],       $
               ['k',           '[/]'],       $
               ['z1',          '[/]'],       $
               ['m1', '[/]'], ['m2', '[/]'], ['m3', '[/]'], ['m4', '[/]'], ['m5', '[/]'], ['m6', '[/]'], ['m7', '[/]'], ['m8', '[/]'], $
               ['l1', '[/]'], ['l2', '[/]'], ['l3', '[/]'], ['l4', '[/]'], ['l5', '[/]'], ['l6', '[/]'], ['l7', '[/]'], ['l8', '[/]'], $
               ['l9', '[/]'], ['l10', '[/]'], ['l11', '[/]'], ['l12', '[/]']                                                           $
              ]
              
heads_sigma = [                              $
               ['image',       '[/]'],       $
               ['julian_date', '[/]'],       $
               ['n',           '[/]'],       $
               ['f',           '[/]'],       $
               ['exp',         '[sec]'],     $
               ['m_ph',        '[/]'],       $
               ['m_az',        '[rad]'],     $
               ['m_zd',        '[rad]'],     $
               ['s_az',        '[rad]'],     $
               ['s_zd',        '[rad]'],     $
               ['scale',       '[rad/px]'],  $
               ['s_c',         '[/]'],      $
               ['s_k',         '[/]'],      $
               ['s_z1',        '[/]'],      $
               ['s_m1', '[/]'], ['s_m2', '[/]'], ['s_m3', '[/]'], ['s_m4', '[/]'], ['s_m5', '[/]'], ['s_m6', '[/]'], ['s_m7', '[/]'], ['s_m8', '[/]'], $
               ['s_l1', '[/]'], ['s_l2', '[/]'], ['s_l3', '[/]'], ['s_l4', '[/]'], ['s_l5', '[/]'], ['s_l6', '[/]'], ['s_l7', '[/]'], ['s_l8', '[/]'], $
               ['s_l9', '[/]'], ['s_l10', '[/]'], ['s_l11', '[/]'], ['s_l12', '[/]']                                                                   $
              ]

format_w = '(A38,F21.8,F10.0,F8.0,E13.2,F12.4,F12.4,F12.4,F12.4,F12.4,F12.4,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3,F10.3)'
format_r = '(A,D,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F)'

trat = strjoin(replicate('-',total(format_length(format_w))))

header_param = [ 'model = ' + par.astrometry.model_image, trat, string(heads_param[0,*], format=format_header(format_w)), $
                                                                string(heads_param[1,*], format=format_header(format_w)), trat, ' ']
                                                                
header_sigma = [ 'model = ' + par.astrometry.model_image, trat, string(heads_sigma[0,*], format=format_header(format_w)), $
                                                                string(heads_sigma[1,*], format=format_header(format_w)), trat, ' ']

param = { name:name_param, header:header_param, format_w:format_w, format_r:format_r }
sigma = { name:name_sigma, header:header_sigma, format_w:format_w, format_r:format_r }

photometry = { param:param, sigma:sigma }

image = { astrometry:astrometry, photometry:photometry }

; {{ DAILY }}

; { ASTROMETRY }

; PARAM-SIGMA
name_param = par.camera + '_' + month + '_astro_param.txt'
name_sigma = par.camera + '_' + month + '_astro_sigma.txt'

heads_param = [                        $
               ['date',        '[/]'], $
               ['julian_date', '[/]'], $
               ['n',           '[/]']  $
              ]
             
heads_sigma = heads_param

names = astro_model_info(par.astrometry.model_daily)    

for i=0, n_elements(names.names)-1 do begin
  
  heads_param = [ [heads_param], [names.names[i], '[' + names.units[i] + ']'] ]
  heads_sigma = [ [heads_sigma], ['s_'+names.names[i], '[' + names.units[i] + ']'] ]
  
endfor

format_w = '(A12,F15.1,F10.0,' + strmid(names.format_w, 1, strlen(names.format_w)-1)
format_r = '(A,D,F,' + strmid(names.format_r, 1, strlen(names.format_r)-1)

trat = strjoin(replicate('-',total(format_length(format_w))))

header_param = [ 'model = ' + par.astrometry.model_daily, trat, string(heads_param[0,*], format=format_header(format_w)), $
                                                                string(heads_param[1,*], format=format_header(format_w)), trat, ' ']
                                                                
header_sigma = [ 'model = ' + par.astrometry.model_daily, trat, string(heads_sigma[0,*], format=format_header(format_w)), $
                                                                string(heads_sigma[1,*], format=format_header(format_w)), trat, ' ']

param = { name:name_param, header:header_param, format_w:format_w, format_r:format_r }
sigma = { name:name_sigma, header:header_sigma, format_w:format_w, format_r:format_r }

; REPORT
name_report = par.camera + '_' + day + '_astro_report.pdf'

report =  { name     : name_report, $
            header   : 0,           $
            format_w : 0,           $
            format_r : 0            $
          }

; SOLUTION 
name_solution = par.camera + '_' + day + '_astro_solution.txt'

solution =  { name     : name_solution,                                 $
              header   : [                                              $
                          'model =  ' + par.astrometry.model_daily,     $                                                                                                                     
                          ' '                                           $
                         ],                                             $
              format_w : '(A10,E19.6,A5,E19.6,A13)',                    $
              format_r : '(A,A,F,A,F,A)'                                $
            }

; ERROR  
name_error = par.camera + '_' + day + '_astro_error.txt'

heads_error = [                              $
               ['angle '         , '[rad]'], $
               ['bias_az*sin(zd)', '[rad]'], $
               ['std_az*sin(zd)' , '[rad]'], $
               ['int_az*sin(zd)' , '[rad]'], $
               ['bias_zd'        , '[rad]'], $
               ['std_zd'         , '[rad]'], $
               ['int_zd'         , '[rad]']  $
              ]

format_w = '(F19.6,E19.6,E19.6,E19.6,E19.6,E19.6,E19.6)'
format_r = '(F,F,F,F,F,F,F)'
    
trat = strjoin(replicate('-',total(format_length(format_w))))

header_error = [ 'model = ' + par.astrometry.model_daily, trat, string(heads_error[0,*], format=format_header(format_w)), $
                                                                string(heads_error[1,*], format=format_header(format_w)), trat, ' ']

error = { name:name_error, header:header_error, format_w:format_w, format_r:format_r }

; COVAR
name_covar = par.camera + '_' + day + '_astro_covar.txt'

heads_covar = []

names = astro_model_info(par.astrometry.model_daily)

for i=0, n_elements(names.names)-1 do begin

  heads_covar = [ [heads_covar], [names.names[i], '[' + names.units[i] + ']'] ]

endfor

format_w = names.format_w
format_r = names.format_r

trat = strjoin(replicate('-',total(format_length(format_w))))

header_covar = [ 'model = ' + par.astrometry.model_daily, trat, string(heads_covar[0,*], format=format_header(format_w)), $
                                                                string(heads_covar[1,*], format=format_header(format_w)), trat, ' ']

covar = { name:name_covar, header:header_covar, format_w:format_w, format_r:format_r }
          
astrometry = { param:param, sigma:sigma, report:report, solution:solution, error:error, covar:covar }

; { PHOTOMETRY }

; PARAM-SIGMA
name_param = par.camera + '_' + month + '_photo_param.txt'
name_sigma = par.camera + '_' + month + '_photo_sigma.txt'

heads_param = [                              $
               ['date',        '[/]'],       $
               ['julian_date', '[/]'],       $
               ['n',           '[/]'],       $
               ['f',           '[/]'],       $ 
               ['exp',         '[sec]'],     $
               ['m_ph',        '[/]'],       $
               ['m_zd',        '[rad]'],     $
               ['scale',       '[rad/px]'],  $             
               ['c',           '[/]'],       $
               ['k',           '[/]'],       $
               ['z',           '[/]'],       $
               ['m',           '[/]'],       $
               ['l',           '[/]']        $
              ]
              
heads_sigma = [                              $
               ['date',        '[/]'],       $
               ['julian_date', '[/]'],       $
               ['n',           '[/]'],       $
               ['f',           '[/]'],       $
               ['exp',         '[sec]'],     $
               ['m_ph',        '[/]'],       $
               ['m_zd',        '[rad]'],     $
               ['scale',       '[rad/px]'],  $  
               ['s_c',         '[/]'],       $
               ['s_k',         '[/]'],       $
               ['s_z',         '[/]'],       $
               ['s_m',         '[/]'],       $
               ['s_l',         '[/]']        $
              ]

format_w = '(A12,F15.1,F10.0,F8.0,E13.2,F12.4,F12.4,F12.4,F10.3,F10.3,F10.3,F10.3,F10.3)'
format_r = '(A,D,F,F,F,F,F,F,F,F,F,F,F)

trat = strjoin(replicate('-',total(format_length(format_w))))

header_param = [ 'model = ' + par.astrometry.model_image, trat, string(heads_param[0,*], format=format_header(format_w)), $
                                                                string(heads_param[1,*], format=format_header(format_w)), trat, ' ']

header_sigma = [ 'model = ' + par.astrometry.model_image, trat, string(heads_sigma[0,*], format=format_header(format_w)), $
                                                                string(heads_sigma[1,*], format=format_header(format_w)), trat, ' ']

param = { name:name_param, header:header_param, format_w:format_w, format_r:format_r }
sigma = { name:name_sigma, header:header_sigma, format_w:format_w, format_r:format_r }

; REPORT
name_report = par.camera + '_' + day + '_photo_report.pdf'

report =  { name     : name_report, $
            header   : 0,           $
            format_w : 0,           $
            format_r : 0            $
          }
          
; SOLUTION
name_solution  = par.camera + '_' + day + '_photo_solution.txt'

solution =  { name     : name_solution,                                   $
              header   : [                                                $
                         'model  =  ' + par.astrometry.model_image,       $
                         ' '                                              $
                        ],                                                $
              format_w : '(A10,F19.6,A5,F19.6,A13)',                      $
              format_r : '(A,A,F,A,F,A)'                                  $
            }

photometry = { param:param, sigma:sigma, report:report, solution:solution }

daily = { astrometry:astrometry, photometry:photometry }

; {{ MONTHLY }}

; { ASTROMETRY }

; REPORT
name_report = par.camera + '_' + month + '_astro_report.pdf'

report =  { name     : name_report, $
            header   : 0,           $
            format_w : 0,           $
            format_r : 0            $
          }
          

; SOLUTION       
name_solution  = par.camera + '_' + month + '_astro_solution.txt'

solution =  { name     : name_solution,                                   $
              header   : [                                                $
                         'model  =  ' + par.astrometry.model_monthly,     $
                         ' '                                              $
                        ],                                                $
              format_w : '(A10,E19.6,A5,E19.6,A13)',                      $
              format_r : '(A,A,F,A,F,A)'                                  $
             }
 
; ERROR
name_error = par.camera + '_' + month + '_astro_error.txt'

heads_error = [                              $
               ['angle '         , '[rad]'], $
               ['bias_az*sin(zd)', '[rad]'], $
               ['std_az*sin(zd)' , '[rad]'], $
               ['int_az*sin(zd)' , '[rad]'], $
               ['bias_zd'        , '[rad]'], $
               ['std_zd'         , '[rad]'], $
               ['int_zd'         , '[rad]']  $
               ]

format_w = '(F19.6,E19.6,E19.6,E19.6,E19.6,E19.6,E19.6)'
format_r = '(F,F,F,F,F,F,F)'

trat = strjoin(replicate('-',total(format_length(format_w))))

header_error = [ 'model = ' + par.astrometry.model_monthly, trat, string(heads_error[0,*], format=format_header(format_w)), $
               string(heads_error[1,*], format=format_header(format_w)), trat, ' ']

error = { name:name_error, header:header_error, format_w:format_w, format_r:format_r }
             
; COVAR
name_covar = par.camera + '_' + month + '_astro_covar.txt'

heads_covar = []

names = astro_model_info(par.astrometry.model_monthly)

for i=0, n_elements(names.names)-1 do begin

  heads_covar = [ [heads_covar], [names.names[i], '[' + names.units[i] + ']'] ]

endfor

format_w = names.format_w
format_r = names.format_r

trat = strjoin(replicate('-',total(format_length(format_w))))

header_covar = [ 'model = ' + par.astrometry.model_monthly, trat, string(heads_covar[0,*], format=format_header(format_w)), $
                                                                  string(heads_covar[1,*], format=format_header(format_w)), trat, ' ']

covar = { name:name_covar, header:header_covar, format_w:format_w, format_r:format_r }
          
astrometry = { report:report, solution:solution, error:error, covar:covar }

; { PHOTOMETRY }
photometry = 0

monthly = { astrometry:astrometry, photometry:photometry }

if keyword_set(detection) then begin
  
  len = strlen(par.pseudo)+1
  
  yr  = long(strmid(detection,len,4))
  mn  = long(strmid(detection,len+4,2))
  day = long(strmid(detection,len+6,2))
  hh  = double(strmid(detection,len+9,2))
  mm  = double(strmid(detection,len+11,2))
  ss  = double(strmid(detection,len+13,2))
  hr  = hh + mm/60D + ss/3600D

  ; computing julian date
  jdcnv, yr, mn, day, hr, jd
  
  names = psf_model_info(par.config.event.model_psf)
  solut = get_solution(par, julian_date=jd, /return0)
  
  file_solution = solut.file[0]
  if file_solution eq '' then file_solution = 'NaN'

  file_error = solut.file[1]
  if file_error eq '' then file_error = 'NaN'

  file_covar = solut.file[2]
  if file_covar eq '' then file_covar = 'NaN'
  
  ; { PSF }
  
  ; PARAM-SIGMA
  name_param = detection + '_psf_param.txt'
  name_sigma = detection + '_psf_sigma.txt'

  heads_param = [                            $
                 ['det_frame',    '[/]'],    $
                 ['date',         '[/]'],    $
                 ['julian_date',  '[/]'],    $
                 ['exp',          '[s]']     $
                ]
                
  heads_sigma = heads_param
  
  for i=0, n_elements(names.names)-1 do begin
  
    heads_param = [ [heads_param], [names.names[i], '[' + names.units[i] + ']'] ]
    heads_sigma = [ [heads_sigma], ['s_'+names.names[i], '[' + names.units[i] + ']'] ]
  
  endfor                
                
  heads_param = [ [heads_param],              $          
                  ['mags',      '[/]']        $
                ]
                
  heads_sigma = [ [heads_sigma],              $
                 ['s_mags',      '[/]']       $
                ]

  format_w = '(A13,A33,F21.8,E13.2,' + strmid(names.format_w, 1, strlen(names.format_w)-2) + ',F13.3)'
  format_r = '(A,A,D,F,F,' + strmid(names.format_r, 1, strlen(names.format_r)-2) + ',F)'
  
  trat = strjoin(replicate('-',total(format_length(format_w))))

  header_param = [ 'model = ' + par.config.event.model_psf, trat, string(heads_param[0,*], format=format_header(format_w)), $
                                                                  string(heads_param[1,*], format=format_header(format_w)), trat, ' ']

  header_sigma = [ 'model = ' + par.config.event.model_psf, trat, string(heads_sigma[0,*], format=format_header(format_w)), $
                                                                  string(heads_sigma[1,*], format=format_header(format_w)), trat, ' ']

  param = { name:name_param, header:header_param, format_w:format_w, format_r:format_r }
  sigma = { name:name_sigma, header:header_sigma, format_w:format_w, format_r:format_r }
  
  ; RESULT
  name_result = detection + '_psf.txt'
  
  heads_result = [                            $
                  ['date',         '[/]'],    $
                  ['julian_date',  '[/]'],    $
                  ['az',           '[deg]'],  $
                  ['s_az',         '[deg]'],  $
                  ['alt',          '[deg]'],  $
                  ['s_alt',        '[deg]'],  $
                  ['ra',           '[deg]'],  $
                  ['s_ra',         '[deg]'],  $
                  ['dec',          '[deg]'],  $
                  ['s_dec',        '[deg]'],  $
                  ['mag',          '[/]'],    $
                  ['s_mag',        '[/]']     $
                 ]
                 
  format_w = '(A28,F21.8,F13.4,F13.4,F13.4,F13.4,F13.4,F13.4,F13.4,F13.4,F13.3,F13.3)'
  format_r = '(A,D,D,D,D,D,D,D,D,D,D,D)'   
  
  trat = strjoin(replicate('-',total(format_length(format_w))))
  
  header_result = [ 'file_solution = ' + file_solution,    $
                    'file_error    = ' + file_error,       $
                    'file_covar    = ' + file_covar,       $
                    'C             = ' + strtrim(string(solut.C, format = '(F10.3)'), 2),        $
                    'k             = ' + strtrim(string(solut.k, format = '(F10.3)'), 2),  trat, $
                    string(heads_result[0,*], format=format_header(format_w)),       $
                    string(heads_result[1,*], format=format_header(format_w)), trat, ' ']           

  result = { name:name_result, header:header_result, format_w:format_w, format_r:format_r }
  
  psf = { param:param, sigma:sigma, result:result }
  
  ; { BAR }
  name_param = detection + '_bar_param.txt'
  name_sigma = detection + '_bar_sigma.txt'

  heads_param = [                            $
                 ['det_frame',    '[/]'],    $
                 ['date',         '[/]'],    $
                 ['julian_date',  '[/]'],    $
                 ['exp',          '[s]']     $
                ]
                
  heads_sigma = heads_param
  
  for i=0, n_elements(names.names)-1 do begin
  
    heads_param = [ [heads_param], [names.names[i], '[' + names.units[i] + ']'] ]
    heads_sigma = [ [heads_sigma], ['s_'+names.names[i], '[' + names.units[i] + ']'] ]
  
  endfor                
                
  heads_param = [ [heads_param],              $          
                  ['mags',      '[/]']        $
                ]
                
  heads_sigma = [ [heads_sigma],              $
                 ['s_mags',      '[/]']       $
                ]

  format_w = '(A13,A33,F21.8,E13.2,' + strmid(names.format_w, 1, strlen(names.format_w)-2) + ',F13.3)'
  format_r = '(A,A,D,F,F,' + strmid(names.format_r, 1, strlen(names.format_r)-2) + ',F)'
  
  trat = strjoin(replicate('-',total(format_length(format_w))))

  header_param = [ 'model = ' + par.config.event.model_bar, trat, string(heads_param[0,*], format=format_header(format_w)), $
                                                                  string(heads_param[1,*], format=format_header(format_w)), trat, ' ']

  header_sigma = [ 'model = ' + par.config.event.model_bar, trat, string(heads_sigma[0,*], format=format_header(format_w)), $
                                                                  string(heads_sigma[1,*], format=format_header(format_w)), trat, ' ']

  param = { name:name_param, header:header_param, format_w:format_w, format_r:format_r }
  sigma = { name:name_sigma, header:header_sigma, format_w:format_w, format_r:format_r }
  
  ; RESULT
  name_result = detection + '_bar.txt'

  heads_result = [                            $
                  ['date',         '[/]'],    $
                  ['julian_date',  '[/]'],    $
                  ['az',           '[deg]'],  $
                  ['s_az',         '[deg]'],  $
                  ['alt',          '[deg]'],  $
                  ['s_alt',        '[deg]'],  $
                  ['ra',           '[deg]'],  $
                  ['s_ra',         '[deg]'],  $
                  ['dec',          '[deg]'],  $
                  ['s_dec',        '[deg]'],  $
                  ['mag',          '[/]'],    $
                  ['s_mag',        '[/]']     $
                 ]

  format_w = '(A28,F21.8,F13.4,F13.4,F13.4,F13.4,F13.4,F13.4,F13.4,F13.4,F13.3,F13.3)'
  format_r = '(A,D,D,D,D,D,D,D,D,D,D,D,D)'   

  trat = strjoin(replicate('-',total(format_length(format_w))))

  header_result = [ 'file_solution = ' + file_solution,    $
                    'file_error    = ' + file_error,       $
                    'file_covar    = ' + file_covar,       $
                    'C             = ' + strtrim(string(solut.C, format = '(F10.3)'), 2),        $
                    'k             = ' + strtrim(string(solut.k, format = '(F10.3)'), 2),  trat, $
                    string(heads_result[0,*], format=format_header(format_w)),       $
                    string(heads_result[1,*], format=format_header(format_w)), trat, ' ']  

  result = { name:name_result, header:header_result, format_w:format_w, format_r:format_r }
  
  bar = { param:param, sigma:sigma, result:result }
  
  ; { REPORT }  
  name_report = detection + '_report.pdf'

  report =  { name     : name_report, $
              header   : 0,           $
              format_w : 0,           $
              format_r : 0            $
            }
  
  ; { IMAGE }
  name_image = detection + '_image.png'

  image1 =  { name     : name_image,   $
              header   : 0,            $
              format_w : 0,            $
              format_r : 0             $
            }
            
  ; { THUMB }
  name_thumb = detection + '_thumb.png'

  thumb =  { name     : name_thumb,  $
             header   : 0,           $
             format_w : 0,           $
             format_r : 0            $
            }
  
  ; { VIDEO }
  name_video = detection + '_video.avi'

  video =  { name     : name_video,   $
              header   : 0,            $
              format_w : 0,            $
              format_r : 0             $
            }
            
  media = { image:image1, thumb:thumb, video:video }
            
  detect = { psf:psf, bar:bar, report:report, media:media }
  
  retv = { image:image, daily:daily, monthly:monthly, detection:detect }
  
endif else begin
  
  retv = { image:image, daily:daily, monthly:monthly }
  
endelse

return, retv

end