; function that read the logo image and provide transparent background

function get_logo, filename, transparent=transparent

; loading PRISMA logo
logo = read_image(filename)

if isa(transparent) then begin
  
  ; rendo il logo a background trasparente
  logo_3 = reform(logo[3,*,*])
  logo0 = reform(logo[0,*,*])
  iilogo0 = where(logo0 eq transparent)
  logo_3[iilogo0] = 0
  logo[3,*,*] = logo_3
  
endif

return, logo

end