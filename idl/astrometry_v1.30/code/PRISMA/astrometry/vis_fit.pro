; procedure written to deduce center and radius for the selected camera

pro vis_fit

compile_opt idl2

config_file = '/PRISMA/settings/configuration.ini'

capture = 'ITMA02_20201021T233003_UT-0.fit'

camera = strmid(capture, 0, 6)
month  = strmid(capture, 7, 6)

config = get_config(config_file)

cd, config.path.dir_captures, current = old_dir
cd, camera
cd, month

img = rdfits(capture, rotate=1) & cd, old_dir

dim = img.dim

center  = [485, 635] 
radius  = 480
horizon = 40

window, 0, xs=dim[0]/2., ys=dim[1]/2.
tvscl, bytscl(congrid(img, dim[0]/2.,dim[1]/2.),0,2000)
tvcircle, radius/2., center[0]/2., center[1]/2, color='red'
tvcircle, (radius-horizon)/2., center[0]/2., center[1]/2, color='blue'

stop

end