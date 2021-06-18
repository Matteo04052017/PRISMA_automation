function brightest_pixel, img

ii = where(img eq max(img))

aa = array_indices(img, ii)

if n_elements(aa.dim) gt 1 then bp = mean(aa, dimension=2) else bp = aa

return, bp

end