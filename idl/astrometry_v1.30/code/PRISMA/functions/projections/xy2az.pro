; (x,y) -> (a,z) projection

function xy2az, model, x, y, p

compile_opt idl2

n = n_elements(x)

case 1 of
  
  strlowcase(model) eq 'proj_poly2': begin
    
    r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

    az = p[0] + atan2( y-p[2] , x-p[1] )
    zd = p[3]*r + p[4]*r^2
    
   end
   
   strlowcase(model) eq 'proj_asin1': begin

     r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

     az = p[0] + atan2( y-p[2] , x-p[1] )
     zd = p[3]*asin( r/p[4] )

   end
   
   strlowcase(model) eq 'proj_exp1': begin
    
     r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

     az = p[0] + atan2( y-p[2] , x-p[1] )
     zd = p[3]*r + p[4]*( exp( p[5]*r ) -1 ) 
    
   end
   
   strlowcase(model) eq 'proj_rot_poly2' or strlowcase(model) eq 'proj_rotz_poly2': begin

     case strlowcase(model) of

       'proj_rot_poly2': begin

         E   = p[3]
         eps = p[4]

       end

       'proj_rotz_poly2': begin

         r_eps     = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )

         E     = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
         eps   = p[5]*r_eps + p[6]*r_eps^2

       end

     endcase

     r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

     u = p[5]*r + p[6]*r^2
     b = p[0] - E + atan2( y-p[2] , x-p[1] )

     if eps ne 0. then begin

       Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
       Hy = sin(b)*sin(u)
       Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)

       zd = acos( Q )
       az = E + atan2( Hy , Hx )

     endif else begin

       zd = u
       az = E + b

     endelse

   end
   
   strlowcase(model) eq 'proj_rot_exp1' or strlowcase(model) eq 'proj_rotz_exp1': begin
     
     case strlowcase(model) of
      
      'proj_rot_exp1': begin
        
        E   = p[3]
        eps = p[4]
        
      end
      
      'proj_rotz_exp1': begin
        
        r_eps     = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
        
        E     = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )  
        eps   = p[5]*r_eps + p[6]*( exp( p[7]*r_eps ) -1 )
        
      end
      
     endcase

     r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

     u = p[5]*r + p[6]*( exp( p[7]*r ) -1 )
     b = p[0] - E + atan2( y-p[2] , x-p[1] )

     if eps ne 0. then begin
       
       Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
       Hy = sin(b)*sin(u)
       Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)
       
       zd = acos( Q )
       az = E + atan2( Hy , Hx )

     endif else begin 

       zd = u
       az = E + b

     endelse

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

     theta = p[0] + atan2( y-p[2] , x-p[1] )
     r     = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 ) * ( 1 + p[7]*sin( theta - p[8] ) )

     u = p[5]*r + p[6]*r^2
     b = theta - E

     if eps ne 0. then begin

       Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
       Hy = sin(b)*sin(u)
       Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)

       zd = acos( Q )
       az = E + atan2( Hy , Hx )

     endif else begin

       zd = u
       az = E + b

     endelse

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
     
     theta = p[0] + atan2( y-p[2] , x-p[1] )
     r     = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 ) * ( 1 + p[8]*sin( theta - p[9] ) )

     u = p[5]*r + p[6]*( exp( p[7]*r ) -1 )
     b = theta - E

     if eps ne 0. then begin

       Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
       Hy = sin(b)*sin(u)
       Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)

       zd = acos( Q )
       az = E + atan2( Hy , Hx )

     endif else begin

       zd = u
       az = E + b

     endelse

   end
   
   else: begin

     message, 'x,y -> az,zd not implemented for ' + strlowcase(model) + '. Please check.'
    
   end
  
endcase

check_az, az, zd

retv = { az:az , zd:zd }

return, retv

end