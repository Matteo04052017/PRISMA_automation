; This widget is used to interactively visualize the PRISMA data 
; (both detections and captures) and allows to produce animated gif 
; and images, e.g. for meteors detections.

pro PRISMAwidget

; In order to produce the runtime distribution the value of "runtime" has to be set to 1
runtime = 0

cd, current=basedir

; custom path (for runtime=0,1)
if runtime then solutions = basedir + path_sep() + 'PRISMAcamera.txt' $
           else solutions = '/PRISMA/settings/solutions.ini'

if runtime then path_black = basedir + path_sep() + 'PRISMAlogo_black.png' $
           else path_black = '/PRISMA/settings/logo_black.png'

if runtime then path_white = basedir + path_sep() + 'PRISMAlogo_white.png' $
           else path_white = '/PRISMA/settings/logo_white.png'

; read the black/white logos
logo_black = get_logo(path_black, transparent=0)
logo_white = get_logo(path_white, transparent=255)

; read the solutions file
readcol, solutions, list_camera, list_pseudo, format = '(A,A)', /silent

list_camera = strupcase(list_camera)
list_pseudo = strupcase(list_pseudo)

; creating the various components of the widget
tlb              = widget_base(title='PRISMA Widget', /column, mbar=mbar)
button_file      = widget_button(mbar, value='File', /menu, event_pro='PWwidget_file')
button_detection = widget_button(button_file, value='Open Detection')
button_capture   = widget_button(button_file, value='Open Capture')
button_exit      = widget_button(button_file, value='Exit')

button_pos     = widget_button(mbar, value='Positions', /menu, event_pro='PWwidget_positions', sensitive=0)
button_loadpos = widget_button(button_pos, value='Load', /checked_menu, sensitive=0)
button_autopos = widget_button(button_pos, value='Auto-centre', /checked_menu, sensitive=0)
button_showbox = widget_button(button_pos, value='Show Box', /checked_menu, sensitive=0)

base1 = widget_base(tlb, /row) 

list_mode        = widget_droplist(base1, value=['Detection','Capture'], /dynamic_resize, event_pro='PWwidget_modelist')
label            = widget_label(base1, value='   Image filename:', /dynamic_resize)
text_filename    = widget_text(base1, xsize=144, ysize=1, value='', /editable, event_pro='PWwidget_filename')
button_previmage = widget_button(base1, value='<<', event_pro='PWwidget_prevnextimage', sensitive=0)
button_nextimage = widget_button(base1, value='>>', event_pro='PWwidget_prevnextimage', sensitive=0)
label            = widget_label(base1, value='  Movie:', /dynamic_resize)
text_nframe      = widget_text(base1, xsize=6, ysize=1, value='', /editable, sensitive=0)
button_playmovie = widget_button(base1, value='Play', event_pro='PWwidget_playmovie', sensitive=0)
button_savemovie = widget_button(base1, value='Save', event_pro='PWwidget_playmovie', sensitive=0)

base2 = widget_base(tlb, /row) 

draw_big  = widget_draw(base2, xsize=640, ysize=480, /motion_events, /frame, /button_events, event_pro='PWwidget_draw', sensitive=0)
draw_zoom = widget_draw(base2, xsize=480, ysize=480, /motion_events, /button_events, /frame, event_pro='PWwidget_zoom', sensitive=0)
table_pos = widget_table(base2, value=['','','',''], xsize=4, ysize=25, scr_xsize=310, scr_ysize=487, /scroll, $
                         alignment=2, column_width=[36,70,150,36], /no_row_headers, column_labels=['#','(X;Y)','TIME UTC','BOX'], sensitive=0)

base3 = widget_base(tlb, /row) 

base31 = widget_base(base3, /row, /frame)

label      = widget_label(base31, value='  Image Cuts      Min  ')
slider_min = widget_slider(base31, xsize=380, minimum=0, maximum=4095, value=0, event_pro='PWwidget_slider_minmax', sensitive=0)
label      = widget_label(base31, value='         Max  ')
slider_max = widget_slider(base31, xsize=380, minimum=0, maximum=4095, value=4095, event_pro='PWwidget_slider_minmax', sensitive=0)

base32 = widget_base(base3, /row, /frame)

label       = widget_label(base32, value='  Zoom Scale  ')
slider_zoom = widget_slider(base32, minimum=0, maximum=5, value=5, xsize=118, event_pro='PWwidget_slider_zoom', sensitive=0)

base33 = widget_base(base3, /row, /frame)

label       = widget_label(base33, value='  Centering Box Dim  ')
slider_box  = widget_slider(base33, minimum=2, maximum=20, xsize=143, value=8, event_pro='PWwidget_slider_box', sensitive=0)
base37      = widget_base(base33, /column, /nonexclusive)
button_fixbox = widget_button(base37, value='  Fix', sensitive=0)

base4 = widget_base(tlb, /row)

base41 = widget_base(base4, /row, /frame)

label     = widget_label(base41, value='  Pixel  ')
label     = widget_label(base41, value=' X ', xsize=17)
text_xpos = widget_text(base41, scr_xsize=40, sensitive=0)
label     = widget_label(base41, value=' Y ', xsize=17)
text_ypos = widget_text(base41, scr_xsize=40, sensitive=0)

base42 = widget_base(base4, /row, /frame)

label         = widget_label(base42, value='   Pixel Value  ')
text_imgvalue = widget_text(base42, scr_xsize=40, sensitive=0)

base43 = widget_base(base4, /row, /frame) 

label       = widget_label(base43, value='  Zoom Centre  ')
label       = widget_label(base43, value=' Xc ', xsize=17)
text_zoomxc = widget_text(base43, scr_xsize=40, sensitive=0)
label       = widget_label(base43, value=' Yc ', xsize=17)
text_zoomyc = widget_text(base43, scr_xsize=40, sensitive=0)

base44 = widget_base(base4, /row, /frame, /nonexclusive)

button_negative = widget_button(base44, value='  Negative', event_pro='PWwidget_negative', sensitive=0)
button_logscale = widget_button(base44, value='  Log Scale', event_pro='PWwidget_logscale', sensitive=0)
button_interpol = widget_button(base44, value='  Interpolation', event_pro='PWwidget_interpolation', sensitive=0)

base45 = widget_base(base4, /column, /base_align_right, xsize=678)
label = widget_label(base45, value='Authors: Dario Barghini and Daniele Gardiol (for the PRISMA collaboration)')
label = widget_label(base45, value='INAF Osservatorio Astrofisico di Torino - 23/12/2019')
    
animation = '..' + path_sep() + 'animation.gif'
track     = '..' + path_sep() + 'track.png'
   
; variable structure
var = {                          $
       RUNTIME:runtime,          $    ; boolean for runtime distribution
       BASEDIR:basedir,          $    ; base directory
       SOLUTIONS:solutions,      $    ; solutions file
       LIST_CAMERA:list_camera,  $    ; list of cameras
       LIST_PSEUDO:list_pseudo,  $    ; list of pseudos
       LOGO_BLACK:logo_black,    $    ; black background logo image
       LOGO_WHITE:logo_white,    $    ; white background logo image
       ANIMATION:animation,      $    ; filename of gif animation
       TRACK:track               $    ; filename of png track
      }

; structure to store tlb uvalue
pwwidget = {                                    $
            TLB:tlb,                            $    ; main window
            BUTTON_FILE:button_file,            $    ; file button
            TEXT_FILENAME:text_filename,        $    ; filename text
            BUTTON_PREVIMAGE:button_previmage,  $    ; button to select previous image (if exists)
            BUTTON_NEXTIMAGE:button_nextimage,  $    ; button to select next image (if exists)
            TEXT_NFRAME:text_nframe,            $    ; text widget for custom movie of n frames starting from current image
            BUTTON_PLAYMOVIE:button_playmovie,  $    ; button to play custom movie
            BUTTON_SAVEMOVIE:button_savemovie,  $    ; button to save of custom movie after play
            LIST_MODE:list_mode,                $    ; droplist for detection and capture mode selection
            DRAW_BIG:draw_big,                  $    ; draw widget (big)
            DRAW_ZOOM:draw_zoom,                $    ; draw widget (small, zoom window)
            TABLE_POS:table_pos,                $    ; table widget for position file visualization
            TEXT_XPOS:text_XPOS,                $    ; text for current xpos cursor
            TEXT_YPOS:text_YPOS,                $    ; text for current ypos cursor
            TEXT_IMGVALUE:text_imgvalue,        $    ; text for current imgvalue cursor
            TEXT_ZOOMXC:text_zoomxc,            $    ; text for xcentre zoom box
            TEXT_ZOOMYC:text_zoomyc,            $    ; text for ycentre zoom box
            SLIDER_MIN:slider_min,              $    ; slider for min image curt value
            SLIDER_MAX:slider_max,              $    ; slider for max image cut value
            SLIDER_ZOOM:slider_zoom,            $    ; slider for zoom window dim
            SLIDER_BOX:slider_box,              $    ; slider for box auto-centre
            BUTTON_FIXBOX:button_fixbox,        $    ; fix box button
            BUTTON_POS:button_pos,              $    ; position menu
            BUTTON_LOADPOS:button_loadpos,      $    ; load position button
            BUTTON_AUTOPOS:button_autopos,      $    ; load position button
            BUTTON_SHOWBOX:button_showbox,      $    ; show box button
            BUTTON_NEGATIVE:button_negative,    $    ; button for negative colorscale control
            BUTTON_LOGSCALE:button_logscale,    $    ; button for log-scale control
            BUTTON_INTERPOL:button_interpol,    $    ; button for rebin interpolation control
            VAR:var                             $       
           }
           
; realize the widgets
widget_control, tlb, /realize
widget_control, tlb, set_uvalue=pwwidget

; initializing uvalues
img = {IMAGE:fltarr(1280,960), XSIZE:1280, YSIZE:960, FRAMENUM:0, DATA:'', CAMERA:'', PSEUDO:''}
widget_control, draw_big, set_uvalue=img

imgzoom = {IMAGE:fltarr(480,480), SCALE:5, XSIZE:480, YSIZE:480, XCN:640, YCN:480, XCOORD:lonarr(480),YCOORD:lonarr(480)}
widget_control, draw_zoom, set_uvalue=imgzoom

posfile   = '..' + path_sep() + 'newpositions.txt'
freeture  = '..' + path_sep() + 'positions.txt'

position = {DEFINED:0, POSFILE:posfile, FREETURE:freeture, NDET:0, DET_FRAME:0, XPOS:0, YPOS:0, STRCOORD:'', DATA:'', BOX:8}
widget_control, button_pos, set_uvalue=position

widget_control, button_file, set_uvalue=basedir
widget_control, list_mode, set_uvalue='detection'
widget_control, text_filename, set_uvalue=''

widget_control, table_pos, set_table_view=[0,0], set_table_select=[-1,-1,-1,-1]

; launching the event manager
xmanager, 'PWwidget', tlb, /no_block, cleanup='PWwidget_cleanup'

device, /decompose

end