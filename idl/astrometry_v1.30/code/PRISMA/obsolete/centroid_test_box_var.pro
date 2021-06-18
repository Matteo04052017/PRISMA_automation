pro centroid_test_box_var

n    = 30
m    = 100

dim = findgen(n) + 1

bkg = replicate(10., m)
h   = findgen(m)*20 + 20
xc  = replicate(0.1, m)
sx  = replicate(2., m)
noi = replicate(0., m)

p = [[h],[xc],[sx],[bkg]]

rep = 1000.

bias = fltarr(n,m,rep)

; non più di m = 256
loadct, 13, rgb_table = table
ii = findgen(m)*floor(256./m)
colors = table[ii,*]

for i=0, n-1 do begin
  
  for k=0, m-1 do begin
    
    for j=0, rep-1 do begin
      
      this_dim = 2*dim[i]+1
      
      xv = findgen(this_dim) - dim[i]

      gau = gaussian(xv, p[k,*])

      noise = randomn(boh, this_dim)*noi[k]

      f = gau + noise

      res = barycentre1D(xv,f)

      bias[i,k,j] = res[0] - p[k,1]
      

    endfor
    
  endfor

endfor

b  = abs(mean(bias, dimension=3))

parr = objarr(m)

parr[0]  = plot(dim/sx[0], b[*,0], xtitle = 'L/$\sigma$', ytitle = 'centre bias [pix]', $
                color = transpose(colors[0,*]), /ylog, font_size = 14)

for k=1, m-1 do begin
  
  parr[k]  = plot(dim/sx[k], b[*,k], xtitle = 'L/$\sigma$', ytitle = 'centre bias [pix]', $
                  color = transpose(colors[k,*]), /ylog, overplot = parr[0])
  
endfor

stop

end