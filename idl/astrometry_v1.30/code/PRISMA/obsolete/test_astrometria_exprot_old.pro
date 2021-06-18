pro test_astrometria_exprot_old

!EXCEPT = 0

cd, '/PRISMA/astrometria'

resid = 1

camera = 'ITPI01'
mese = '201701'
notte = '20170107'

cd, camera
cd, mese

par = camera_par(camera)

catalogo = '/PRISMA/procedure_astro/catalogo.txt'

; leggo il catalogo
readcol, catalogo, id, junk, star, cost, alpha, delta, mag, format='(I,A,A,A,F,F,F)', /silent

n_stars = n_elements(alpha)

; eliminimo le 'non-stelle'
ii    = where(junk eq '*')
id    = id[ii]
name  = star[ii] + ' ' + cost[ii]
alpha = alpha[ii]
delta = delta[ii]
mag   = mag[ii]
n_stars = n_elements(ii)

catalogo = {name:name, alpha:alpha, delta:delta, mag:mag, n:n_stars}

nomefilepar   = camera + '_' + notte + '_poly2_par.txt'
nomefileassoc = camera + '_' + notte + '_poly2_assoc.txt'

readcol, nomefilepar, immagine, junk, junk, a0, xc, yc, P1, P2, format='(A,A,A,F,F,F,F,F)', /silent
readcol, nomefileassoc, name, julian_date ,x , sx, y, sy, star, cost, az, zd, format='(A,D,F,F,F,F,A,A,F,F)', /silent

name = star + ' ' + cost

; medie dei parametri
param_0  = [mean(a0), mean(xc), mean(yc), mean(P1), mean(P2)]
sparam_0 = [stddev(a0), stddev(xc), stddev(yc), stddev(P1), stddev(P2)]

bmodel = xy2az('POLY2', x, y, param_0)
az_bmodel = bmodel.az
zd_bmodel = bmodel.zd
dAZb      = az - az_bmodel
dZDb      = zd - zd_bmodel

ii = where(abs(dAZb lt !pi/2))

x    = x[ii]
y    = y[ii]
sx   = sx[ii]
sy   = sy[ii]
name = name[ii]
star = star[ii]
cost = cost[ii]
az   = az[ii]
zd   = zd[ii]

x_fit = [x, y]
y_fit = [az, zd]
err   = err_xy2az('POLY2', x, sx, y, sy, param_0, param_0*0.)
me = [err.az, err.zd]

fita = [1,1,1,1,1]

yfit = mpastro_fit('POLY2', x_fit, y_fit, param, estimates=param_0, sigma=sigma, status=status, fita=fita, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az('POLY2', x, y, param)
r        = sqrt((x-param[1])^2 + (y-param[2])^2)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

pa = plot(az*!radeg, dAZ*sin(ZD)*!radeg*60.,'.', title='Azimuth residuals', xtitle='AZ [deg]', ytitle='dAZ$\cdot$sin(ZD) [arcmin]', sym_thick = 0.3, $
  yrange=[-0.05,0.05]*!radeg*60., xrange = [0,365], LAYOUT=[1,2,1], dimensions = [600,800], margin = [0.2, 0.12, 0.05, 0.12])
pz = plot(zd*!radeg, dZD*!radeg*60., '.', title='Zenital Distance residuals', xtitle='ZD [deg]', ytitle='dZD [arcmin]', sym_thick = 0.3, $
  yrange=[-0.05,0.05]*!radeg*60., xrange = [0,90], /current, LAYOUT=[1,2,2], margin = [0.2, 0.12, 0.05, 0.12])

print, param, sigma, format='(5F20.10)'

stop

if isa(pa) then pa.close

ii = where(zd lt 0.2, n_ZD)

x_ZD = r[ii]
y_ZD = zd[ii]
me_ZD = err.zd[ii]

res = ladfit(x_ZD, y_ZD)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az('POLY2', x, y, [param[0:2],res[1],0] )
r = sqrt((x-param[1])^2 + (y-param[2])^2)
zd_model = model.zd
dZD      = zd - zd_model

pz = plot(r, dZD*!radeg*60., '.', title='Zenital Distance residuals', xtitle='r [pixel]', ytitle='dZD [arcmin]', sym_thick = 0.3, $
  xrange = [0,500], margin = [0.2, 0.12, 0.05, 0.12], /ylog)

ii = where(zd gt 0.7)

x_ZD = r[ii]
y_ZD = alog(dZD[ii])
me_ZD = err.zd[ii]

ii = where(finite(y_ZD))
x_ZD = x_ZD[ii]
y_ZD = y_ZD[ii]
me_ZD = me_ZD[ii]

;res1 = poly_fit(x_ZD, y_ZD, 1, measure_errors = me_ZD)
res1 = ladfit(x_ZD, y_ZD)
r_interp = findgen(max(r))

S0 = exp(res1[0])
D0 = res1[1]
yfit1 = S0*exp(D0*r_interp)

pz1 = plot(r_interp, yfit1*!radeg*60., color='red', overplot=pz, thick = 2)

print, 'S0  = ', S0  , format = '(A,F10.6)'
print, 'D0  = ', D0  , format = '(A,F10.6)'

stop

if isa(pz) then pz.close

param_exp0 = [param[0:2],res[1], S0, D0]
fita_exp = [1,1,1,1,1,1]

yfit = mpastro_fit('EXP', x_fit, y_fit, param_exp, estimates=param_exp0, sigma=sigma_exp, status=status, fita=fita_exp, measure_errors = me)

; valuto il modello per plottare i residui e le proiezioni
model    = xy2az('EXP', x, y, param_exp)
az_model = model.az
zd_model = model.zd
dAZ      = az - az_model
dZD      = zd - zd_model

pa = plot(az*!radeg, dAZ*sin(ZD)*!radeg*60.,'.', title='Azimuth residuals', xtitle='AZ [deg]', ytitle='dAZ$\cdot$sin(ZD) [arcmin]', sym_thick = 0.3, $
  yrange=[-0.05,0.05]*!radeg*60., xrange = [0,365], LAYOUT=[1,2,1], dimensions = [600,800], margin = [0.2, 0.12, 0.05, 0.12])
pz = plot(zd*!radeg, dZD*!radeg*60., '.', title='Zenital Distance residuals', xtitle='ZD [deg]', ytitle='dZD [arcmin]', sym_thick = 0.3, $
  yrange=[-0.05,0.05]*!radeg*60., xrange = [0,90], /current, LAYOUT=[1,2,2], margin = [0.2, 0.12, 0.05, 0.12])

print, param_exp, sigma_exp, format='(6F20.10)'

stop

if isa(pa) then pa.close

dAZ = -dAZ
dZD = -dZD

pa = plot(az*!radeg, dAZ*sin(ZD)*!radeg*60.,'.', title='Azimuth residuals', xtitle='AZ [deg]', ytitle='dAZ$\cdot$sin(ZD) [arcmin]', sym_thick = 0.3, $
  yrange=[-0.05,0.05]*!radeg*60., xrange = [0,365], LAYOUT=[1,2,1], dimensions = [600,800], margin = [0.2, 0.12, 0.05, 0.12])
pz = plot(az*!radeg, dZD*!radeg*60., '.', title='Zenital Distance residuals', xtitle='AZ [deg]', ytitle='dZD [arcmin]', sym_thick = 0.3, $
  yrange=[-0.05,0.05]*!radeg*60., xrange = [0,365], /current, LAYOUT=[1,2,2], margin = [0.2, 0.12, 0.05, 0.12])

az_resid = az
zd_resid = zd
az1_resid = az_model
zd1_resid = zd_model
dAZ_resid = dAZ*sin(ZD)
dZD_resid = dZD
sAZ_resid = sqrt((err.az*sin(zd))^2 + (az*cos(zd)*err.zd)^2)
sZD_resid = err.zd

ii_resid = where(abs(dAZ_resid)*sin(ZD_resid) lt 0.05 and abs(dZD_resid) lt 0.05)

az_resid = az_resid[ii_resid]
zd_resid = zd_resid[ii_resid]
az1_resid = az1_resid[ii_resid]
zd1_resid = zd1_resid[ii_resid]
dAZ_resid = dAZ_resid[ii_resid]
dZD_resid = dZD_resid[ii_resid]
sAZ_resid = sAZ_resid[ii_resid]
sZD_resid = sZD_resid[ii_resid]

mi = 0.1
ma = 1.2
st = 0.05
n_sin = (ma-mi)/st
vmi = findgen(n_sin)*st + mi
vma = vmi+st

x_AZ = [az_resid,zd_resid]
y_AZ = [dAZ_resid,dAZ_resid]
me_AZ = [sAZ_resid,sAZ_resid]

fita_AZresid = [0,0,0,1,1,1,replicate(1,n_sin)]
param_AZresid0 = [mi,ma,st,0,1,0,replicate(0.,n_sin)]

yfitAZ = mpresid_fit(x_AZ, y_AZ, param_AZresid, estimates=param_AZresid0, sigma=sigma_AZresid, fita=fita_AZresid, measure_errors = me_AZ)

az0    = param_AZresid[3+0]
om_az  = param_AZresid[3+1]
phi_az = param_AZresid[3+2]
amp_az = param_AZresid[3+3:*]

x_ZD = [az_resid,zd_resid]
y_ZD = [dZD_resid,dZD_resid]
me_ZD = [sZD_resid,sZD_resid]

fita_ZDresid = [0,0,0,1,1,1,replicate(1.,n_sin)]
param_ZDresid0 = [mi,ma,st,0,0.5,0,replicate(0.,n_sin)]

yfitZD = mpresid_fit(x_ZD, y_ZD, param_ZDresid, estimates=param_ZDresid0, sigma=sigma_ZDresid, fita=fita_ZDresid, measure_errors = me_ZD)

zd0    = param_ZDresid[3+0]
om_zd  = param_ZDresid[3+1]
phi_zd = param_ZDresid[3+2]
amp_zd = param_ZDresid[3+3:*]

x_interp = (findgen(361))/!radeg

zdi = (vmi+vma)/2.

for i=0, n_sin -1 do begin

  ii = where(zd_resid gt vmi[i] and zd_resid lt vma[i])

  if ii[0] ne -1 then begin

    piAZ = plot(x_interp*!radeg, mpresid_yfit(x_interp,[az0,om_az,phi_az,amp_az[i]])*!radeg*60., color='red', overplot=pa)
    piAZ = plot(x_interp*!radeg, mpresid_yfit(x_interp,[zd0,om_zd,phi_zd,amp_zd[i]])*!radeg*60., color='red', overplot=pz)

  endif

endfor

E0 = phi_az + !pi

beta = asin( sin(zd)/sin(zd_model) * sin(E0-az) ) - az_model

a = az_model + beta
b = E0 - az

lA = zd
lB = zd_model

;lC = tan(0.5*(lA+lB)) * cos(0.5*(a+b)) / cos(0.5*(a-b))
;lC = 2*atan(lC)

lC = tan(0.5*(lA-lB)) * sin(0.5*(a+b)) / sin(0.5*(a-b))
lC = 2*atan(lC)

stop

if isa(pa) then pa.close

end