pro centroid_test_box

n    = 30
step = 1
dim = findgen(n)*step + 1

bkg = 10.
h   = 1000.
xc  = 0.4
sx  = 2.
noi = 1.

p = [h, xc, sx, bkg]

rep = 10000

bias = fltarr(n,rep)

for i=0, n-1 do begin
  
  for j=0, rep-1 do begin
    
    this_dim = 2*dim[i]+1
    
    xv = findgen(this_dim) - dim[i]

    gau = gaussian(xv, p)

    noise = randomn(boh, this_dim)*noi

    f = gau + noise

    res = barycentre1D(xv,f)

    bias[i,j] = res[0] - p[1]
    
  endfor
  
endfor

b  = abs(mean(bias, dimension=2))
sb = stddev(bias, dimension=2)

sbup = sb
sbdw = sb

ii = where(b - sb le 0, complement=ii0)
if ii[0] ne -1 then sbdw[ii] = b[ii] - min(b/100)

err = transpose([[sbdw],[sbup]])

p1  = errorplot(dim/sx, b, err, xtitle = 'L/$\sigma$', ytitle = 'centre bias [pix]', /ylog)
range = p1['axis0'].yrange 
p1['axis0'].yrange = [min(b/10),range[1]]

stop

end