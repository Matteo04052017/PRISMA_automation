; lists of points az and zd for sky magnitude computation

function get_skypoints

compile_opt idl2

az = [0., $
      0., 45., 90., 135., 180., 225., 270., 315., $
      0., 30., 60., 90., 120., 150., 180., 210., 240., 270., 300., 330. $
     ]/!radeg
     
zd = [0., $
      45., 45., 45., 45., 45., 45., 45., 45., $
      70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 70. $
     ]/!radeg

retv = {az:az, zd:zd, npoints:n_elements(az)}

return, retv

end