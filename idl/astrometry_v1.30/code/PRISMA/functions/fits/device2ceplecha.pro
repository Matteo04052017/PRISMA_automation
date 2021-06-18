; converts device to Ceplecha coordinates using parameters loaded from config file

pro device2ceplecha, x, y, par

compile_opt idl2

x1 = x
y1 = y

rot = fix(par.fits.rotate) mod 8

while rot lt 0 do rot = rot + 8

case rot of
  
  0: begin
    
    x = x1
    y = y1
    
  end
  
  1: begin
    
    x = (par.fits.dim[1] - 1) - y1
    y = x1
    
  end
  
  2: begin

    x = (par.fits.dim[0] - 1) - x1
    y = (par.fits.dim[1] - 1) - y1

  end
  
  3: begin

    x = y1
    y = (par.fits.dim[0] - 1) - x1

  end
  
  4: begin

    x = y1
    y = x1

  end
  
  5: begin

    x = (par.fits.dim[0] - 1) - x1
    y = y1

  end
  
  6: begin

    x = (par.fits.dim[1] - 1) - y1
    y = (par.fits.dim[0] - 1) - x1

  end
  
  7: begin

    x = x1
    y = (par.fits.dim[1] - 1) - y1

  end
  
endcase

end