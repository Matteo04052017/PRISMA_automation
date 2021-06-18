; (a,z) -> (x,y) projection

function az2xy, model, az, zd, p

compile_opt idl2

n = n_elements(az)

check_az, az, zd

case 1 of
  
  strlowcase(model) eq 'proj_poly2': begin
    
    r = az*0.

    for i=0, n-1 do begin

      cc = [ -zd[i] , p[3], p[4] ]
      r[i] = min(real_polyroots(cc))

    endfor

    x = p[1] + r*cos( az-p[0] )
    y = p[2] + r*sin( az-p[0] )
    
   end
   
   strlowcase(model) eq 'proj_asin1': begin

     r = p[4]*sin( zd/p[3] )

     x = p[1] + r*cos( az-p[0] )
     y = p[2] + r*sin( az-p[0] )

   end
   
   strlowcase(model) eq 'proj_exp1': begin
    
     if p[3] eq 0 then begin

       if p[4]*p[5] eq 0 then r = az*0. else r = alog( ( zd+p[4] ) / p[4] ) / p[5]

     endif else begin 

       if p[5] eq 0 then r = ( zd+p[4]-p[4]*exp(1) )/p[3] else r = ( zd+p[4] )/p[3] - lambertw( p[4]*p[5]*exp( p[5]*( zd+p[4] )/p[3] )/p[3] )/p[5]

     endelse

     x = p[1] + r*cos( az-p[0] )
     y = p[2] + r*sin( az-p[0] )
    
    end
    
    strlowcase(model) eq 'proj_rot_poly2' or strlowcase(model) eq 'proj_rotz_poly2': begin

      case strlowcase(model) of

        'proj_rot_poly2': begin

          E   = p[3]
          eps = p[4]

        end

        'proj_rotz_poly2': begin

          E     = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
          r_eps = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
          eps   = p[5]*r_eps + p[6]*r_eps^2

        end

      endcase

      if eps ne 0. then begin

        Qm  = cos(zd)*cos(eps) + cos(az-E)*sin(zd)*sin(eps)
        Hym = sin(az-E)*sin(zd)
        Hxm = cos(az-E)*sin(zd)*cos(eps) - cos(zd)*sin(eps)

        u = acos( Qm )
        b = atan2( Hym , Hxm )

      endif else begin

        u = zd
        b = az - E

      endelse

      r = az*0.

      for i=0, n-1 do begin

        cc = [ -u[i] , p[5], p[6] ]
        r[i] = min(real_polyroots(cc))

      endfor

      x = p[1] + r*cos( b-p[0]+E )
      y = p[2] + r*sin( b-p[0]+E )

    end
    
    strlowcase(model) eq 'proj_rot_exp1' or strlowcase(model) eq 'proj_rotz_exp1': begin
      
      case strlowcase(model) of
        
        'proj_rot_exp1': begin
        
            E   = p[3]
            eps = p[4]
          
        end
        
        'proj_rotz_exp1': begin

          E     = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
          r_eps = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
          eps   = p[5]*r_eps + p[6]*( exp( p[7]*r_eps ) -1 )

        end
        
      endcase

      if eps ne 0. then begin
        
        Qm  = cos(zd)*cos(eps) + cos(az-E)*sin(zd)*sin(eps)
        Hym = sin(az-E)*sin(zd)
        Hxm = cos(az-E)*sin(zd)*cos(eps) - cos(zd)*sin(eps)
        
        u = acos( Qm )
        b = atan2( Hym , Hxm )

      endif else begin

        u = zd
        b = az - E

      endelse

      if p[5] eq 0 then begin

        if p[6]*p[7] eq 0 then r = az*0. else r = alog( ( u+p[6] )/p[6] )/p[7]

      endif else begin 

        if p[7] eq 0 then r = ( u+p[6]-p[6]*exp(1) )/p[5] else r = ( u+p[6] )/p[5] - lambertw( p[6]*p[7]*exp( p[7]*( u+p[6] )/p[5] ) /p[5] )/p[7]

      endelse

      x = p[1] + r*cos( b-p[0]+E )
      y = p[2] + r*sin( b-p[0]+E )

    end
    
    strlowcase(model) eq 'proj_rot_poly2_asym' or strlowcase(model) eq 'proj_rotz_poly2_asym': begin

      case strlowcase(model) of

        'proj_rot_poly2_asym': begin

          E   = p[3]
          eps = p[4]

        end

        'proj_rotz_poly2_asym': begin

          theta_eps = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
          r_eps = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 ) * ( 1 + p[7]*sin( theta_eps - p[8] ) )

          E     = theta_eps
          eps   = p[5]*r_eps + p[6]*r_eps^2

        end

      endcase

      if eps ne 0. then begin

        Qm  = cos(zd)*cos(eps) + cos(az-E)*sin(zd)*sin(eps)
        Hym = sin(az-E)*sin(zd)
        Hxm = cos(az-E)*sin(zd)*cos(eps) - cos(zd)*sin(eps)

        u = acos( Qm )
        b = atan2( Hym , Hxm )

      endif else begin

        u = zd
        b = az - E

      endelse

      r = az*0.

      for i=0, n-1 do begin

        cc = [ -u[i] , p[5], p[6] ]
        r[i] = min(real_polyroots(cc))

      endfor

      theta = b + E
      gamma = 1 + p[7] * sin( theta - p[8] )

      x = p[1] + (r/gamma)*cos( theta - p[0] )
      y = p[2] + (r/gamma)*sin( theta - p[0] )


    end
    
    strlowcase(model) eq 'proj_rot_exp1_asym' or strlowcase(model) eq 'proj_rotz_exp1_asym': begin

      case strlowcase(model) of
        
        'proj_rot_exp1_asym': begin
        
            E   = p[3]
            eps = p[4]
          
        end
        
        'proj_rotz_exp1_asym': begin

           theta_eps = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
           r_eps = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 ) * ( 1 + p[8]*sin( theta_eps - p[9] ) )
           
           E     = theta_eps
           eps   = p[5]*r_eps + p[6]*( exp( p[7]*r_eps ) -1 )

        end
        
      endcase

      if eps ne 0. then begin
        
        Qm  = cos(zd)*cos(eps) + cos(az-E)*sin(zd)*sin(eps)
        Hym = sin(az-E)*sin(zd)
        Hxm = cos(az-E)*sin(zd)*cos(eps) - cos(zd)*sin(eps)
        
        u = acos( Qm )
        b = atan2( Hym , Hxm )

      endif else begin

        u = zd
        b = az - E

      endelse

      if p[5] eq 0 then begin

        if p[6]*p[7] eq 0 then r = az*0. else r = alog( ( u+p[6] )/p[6] )/p[7]

      endif else begin 

        if p[7] eq 0 then r = ( u+p[6]-p[6]*exp(1) )/p[5] else r = ( u+p[6] )/p[5] - lambertw( p[6]*p[7]*exp( p[7]*( u+p[6] )/p[5] ) /p[5] )/p[7]

      endelse
      
      theta = b + E
      gamma = 1 + p[8] * sin( theta - p[9] )

      x = p[1] + (r/gamma)*cos( theta - p[0] )
      y = p[2] + (r/gamma)*sin( theta - p[0] )

      
    end

    else: begin

      message, 'az,zd -> x,y not implemented for ' + strlowcase(model) + '. Please check.'

    end
  
endcase

retv = { x:x , y:y }

return, retv

end