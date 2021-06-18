; computing projection indetermination for (x,y) - > (a,z)
; (x,y)   : Ceplecha device coordinates
; (sx,sy) : errors on (x,y)
; p       : projection parameters
; sp      : vector of error in p or covariance matrix for p

function err_xy2az, model, xIn, sxIn, yIn, syIn, pIn, spIn

compile_opt idl2

x  = double(xIn)
sx = double(sxIn)
y  = double(yIn)
sy = double(syIn)
p  = double(pIn)
sp = double(spIn)

np  = n_elements(p)

s = size(sp)

case s[0] of
  
  0: sp1 = diag_matrix(fltarr(n_elements(p)))
  1: sp1 = diag_matrix(sp^2)
  2: sp1 = sp
  
  else: begin
    
    message, 'error/covariance vector/matrix has not the right dimensions (0,1,2). Please check.'
    
  end
  
endcase

cov = fltarr(np+2,np+2)
cov[0:np-1,0:np-1] = sp1

sa = x*0.
sz = x*0

case 1 of
  
  strlowcase(model) eq 'proj_poly2': begin
    
    r  = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

    z = p[3]*r + p[4]*r^2
    a = p[0] + atan2( y-p[2] , x-p[1] )

    for i=0, n_elements(x)-1 do begin
      
      dz_dr = p[3] + 2*p[4]*r[i]
    
      dz_dp = [ 0.                        , $
                -dz_dr*( x[i]-p[1] )/r[i] , $
                -dz_dr*( y[i]-p[2] )/r[i] , $
                r[i]                      , $
                r[i]^2                    , $
                dz_dr*( x[i]-p[1] )/r[i]  , $
                dz_dr*( y[i]-p[2] )/r[i]    $
               ]

      da_dp = [ 1.                      , $
                ( y[i] - p[2] )/r[i]^2  , $
                -( x[i] - p[1] )/r[i]^2 , $
                0.                      , $
                0.                      , $
                -( y[i] - p[2] )/r[i]^2 , $
                ( x[i] - p[1] )/r[i]^2    $
               ]
      
      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt( da_dp # cov # da_dp )
      sz[i] = sqrt( dz_dp # cov # dz_dp )

    endfor
    
  end
  
  strlowcase(model) eq 'proj_asin1': begin

    r  = sqrt( (x-p[1])^2 + (y-p[2])^2 )

    z = p[3]*asin( r/p[4] )
    a = p[0] + atan2( y-p[2], x-p[1] )

    for i=0, n_elements(x)-1 do begin

      dz_dr = p[3]/sqrt( p[4]^2 - r[i]^2 )

      dz_dp = [ 0.                                          , $
                -dz_dr*( x[i]-p[1] )/r[i]                   , $
                -dz_dr*( y[i]-p[2] )/r[i]                   , $
                asin( r[i]/p[4] )                           , $
                -( r[i]*p[3]/p[4] )/sqrt( p[4]^2 - r[i]^2 ) , $
                dz_dr*( x[i]-p[1] )/r[i]                    , $
                dz_dr*( y[i]-p[2] )/r[i]                      $
              ]

      da_dp = [ 1.                      , $
                ( y[i] - p[2] )/r[i]^2  , $
                -( x[i] - p[1] )/r[i]^2 , $
                0.                      , $
                0.                      , $
                -( y[i] - p[2] )/r[i]^2 , $
                ( x[i] - p[1] )/r[i]^2    $
              ]

      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt( da_dp # cov # da_dp )
      sz[i] = sqrt( dz_dp # cov # dz_dp )

    endfor

  end
  
  strlowcase(model) eq 'proj_exp1': begin
    
    r  = sqrt( (x-p[1])^2 + (y-p[2])^2 )

    z = p[3]*r + p[4]*( exp( p[5]*r ) -1 )
    a = p[0] + atan2( y-p[2], x-p[1] )

    for i=0, n_elements(x)-1 do begin
      
      dz_dr = p[3] + p[5]*p[4]*exp( p[5]*r[i] )

      dz_dp = [ 0.                         , $
                -dz_dr*( x[i]-p[1] )/r[i]  , $
                -dz_dr*( y[i]-p[2] )/r[i]  , $
                r[i]                       , $
                exp( p[5]*r[i] ) - 1       , $
                p[4]*r[i]*exp( p[5]*r[i] ) , $
                dz_dr*( x[i]-p[1] )/r[i]   , $
                dz_dr*( y[i]-p[2] )/r[i]     $
               ]

      da_dp = [ 1.                      , $
                ( y[i] - p[2] )/r[i]^2  , $
                -( x[i] - p[1] )/r[i]^2 , $
                0.                      , $
                0.                      , $
                0.                      , $
                -( y[i] - p[2] )/r[i]^2 , $
                ( x[i] - p[1] )/r[i]^2    $
               ]

      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt( da_dp # cov # da_dp )
      sz[i] = sqrt( dz_dp # cov # dz_dp )

    endfor
    
  end
  
  strlowcase(model) eq 'proj_rot_poly2' or strlowcase(model) eq 'proj_rotz_poly2': begin

    jacob = diag_matrix(fltarr(np+2)+1)

    case strlowcase(model) of

      'proj_rot_poly2': begin

        E   = p[3]
        eps = p[4]

      end

      'proj_rotz_poly2': begin

        E     = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
        r_eps = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
        eps   = p[5]*r_eps + p[6]*r_eps^2

        deps_dr_eps = p[5] + 2*p[6]*r_eps

        jacob[3,4] = -deps_dr_eps*( p[1]-p[3] )/r_eps
        jacob[3,3] = ( p[2]-p[4] )/r_eps^2
        jacob[4,4] = -deps_dr_eps*( p[2]-p[4] )/r_eps
        jacob[4,3] = -( p[1]-p[3] )/r_eps^2

        jacob[1,4] = deps_dr_eps*(p[1]-p[3])/r_eps
        jacob[2,4] = deps_dr_eps*(p[2]-p[4])/r_eps
        jacob[5,4] = r_eps
        jacob[6,4] = r_eps^2

        jacob[0,3] = 1
        jacob[1,3] = -( p[2] - p[4] )/r_eps^2
        jacob[2,3] = ( p[1] - p[3] )/r_eps^2

      end

    endcase

    r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

    u = p[5]*r + p[6]*r^2
    b = p[0] - E + atan2( y - p[2] , x - p[1] )

    Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
    Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)
    Hy = sin(b)*sin(u)

    z = acos( Q )
    a = E + atan2( Hy , Hx )

    for i=0, n_elements(x)-1 do begin

      dz_dQ  = -1./sqrt( 1 - Q[i]^2 )
      dz_dHx = 0.
      dz_dHy = 0.

      dz_dp = [ 0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                     $
               ]

      da_dQ  = 0.
      da_dHx = -Hy[i]/( Hx[i]^2 + Hy[i]^2 )
      da_dHy = Hx[i]/( Hx[i]^2 + Hy[i]^2 )

      da_dp = [ 0.                    , $
                0.                    , $
                0.                    , $
                1.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                      $
               ]

      dQ_du = - cos(eps)*sin(u[i]) - cos(b[i])*cos(u[i])*sin(eps)
      dQ_db = sin(b[i])*sin(u[i])*sin(eps)

      dQ_dp = [ 0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                -cos(u[i])*sin(eps) - cos(b[i])*sin(u[i])*cos(eps)     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                       $
               ]

      dHx_du = cos(b[i])*cos(eps)*cos(u[i]) - sin(eps)*sin(u[i])
      dHx_db = -cos(eps)*sin(b[i])*sin(u[i])

      dHx_dp = [ 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 cos(eps)*cos(u[i]) - cos(b[i])*sin(eps)*sin(u[i])     , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                      $
                ]

      dHy_du = sin(b[i])*cos(u[i])
      dHy_db = cos(b[i])*sin(u[i])

      dHy_dp = [ 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.               $
                ]

      du_dr = p[5] + 2*p[6]*r[i]

      dr_dp = [ 0.                 , $
                ( p[1]-x[i] )/r[i] , $
                ( p[2]-y[i] )/r[i] , $
                0.                 , $
                0.                 , $
                0.                 , $
                0.                 , $
                ( x[i]-p[1] )/r[i] , $
                ( y[i]-p[2] )/r[i]   $
               ]

      du_dp = [ 0.                     , $
                0.                     , $
                0.                     , $
                0.                     , $
                0.                     , $
                r[i]                   , $
                r[i]^2                 , $
                0.                     , $
                0.                       $
               ]                         $
                + du_dr*dr_dp

      db_dp = [ 1.                    , $
                ( y[i]-p[2] )/r[i]^2  , $
                ( p[1]-x[i] )/r[i]^2  , $
                -1                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                ( p[2]-y[i] )/r[i]^2  , $
                ( x[i]-p[1] )/r[i]^2    $
               ]

      dz_dp_tot = dz_dp + dz_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + dz_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  dz_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )
      da_dp_tot = da_dp + da_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + da_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  da_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )

      dz_dp_tot = jacob # dz_dp_tot
      da_dp_tot = jacob # da_dp_tot

      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt(da_dp_tot # cov # da_dp_tot)
      sz[i] = sqrt(dz_dp_tot # cov # dz_dp_tot)

    endfor

  end
  
  strlowcase(model) eq 'proj_rot_exp1' or strlowcase(model) eq 'proj_rotz_exp1': begin
    
    jacob = diag_matrix(fltarr(np+2)+1)
    
    case strlowcase(model) of
      
      'proj_rot_exp1': begin
        
        E   = p[3]
        eps = p[4]
        
      end
      
      'proj_rotz_exp1': begin
        
        E     = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
        r_eps = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
        eps   = p[5]*r_eps + p[6]*( exp( p[7]*r_eps ) -1 )
        
        deps_dr_eps = p[5] + p[7]*p[6]*exp( p[7]*r_eps )

        jacob[3,4] = -deps_dr_eps*( p[1]-p[3] )/r_eps
        jacob[3,3] = ( p[2]-p[4] )/r_eps^2
        jacob[4,4] = -deps_dr_eps*( p[2]-p[4] )/r_eps
        jacob[4,3] = -( p[1]-p[3] )/r_eps^2

        jacob[1,4] = deps_dr_eps*(p[1]-p[3])/r_eps
        jacob[2,4] = deps_dr_eps*(p[2]-p[4])/r_eps
        jacob[5,4] = r_eps
        jacob[6,4] = exp( p[7]*r_eps ) - 1
        jacob[7,4] = r_eps * p[6] * exp( p[7]*r_eps )

        jacob[0,3] = 1
        jacob[1,3] = -( p[2] - p[4] )/r_eps^2
        jacob[2,3] = ( p[1] - p[3] )/r_eps^2
      
      end
      
    endcase
    
    r = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )

    u = p[5]*r + p[6]*( exp( p[7]*r ) -1 )
    b = p[0] - E + atan2( y - p[2] , x - p[1] )

    Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
    Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)
    Hy = sin(b)*sin(u)

    z = acos( Q )
    a = E + atan2( Hy , Hx )

    for i=0, n_elements(x)-1 do begin

      dz_dQ  = -1./sqrt( 1 - Q[i]^2 )
      dz_dHx = 0.
      dz_dHy = 0.

      dz_dp = [ 0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                     $
               ]

      da_dQ  = 0.
      da_dHx = -Hy[i]/( Hx[i]^2 + Hy[i]^2 )
      da_dHy = Hx[i]/( Hx[i]^2 + Hy[i]^2 )

      da_dp = [ 0.                    , $
                0.                    , $
                0.                    , $
                1.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                      $
               ]

      dQ_du = - cos(eps)*sin(u[i]) - cos(b[i])*cos(u[i])*sin(eps)
      dQ_db = sin(b[i])*sin(u[i])*sin(eps)

      dQ_dp = [ 0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                -cos(u[i])*sin(eps) - cos(b[i])*sin(u[i])*cos(eps)     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                       $
               ]

      dHx_du = cos(b[i])*cos(eps)*cos(u[i]) - sin(eps)*sin(u[i])
      dHx_db = -cos(eps)*sin(b[i])*sin(u[i])

      dHx_dp = [ 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 cos(eps)*cos(u[i]) - cos(b[i])*sin(eps)*sin(u[i])     , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $               
                 0.                                                    , $
                 0.                                                      $
                ]

      dHy_du = sin(b[i])*cos(u[i])
      dHy_db = cos(b[i])*sin(u[i])

      dHy_dp = [ 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.               $
                ]
               
      du_dr = p[5] + p[7]*p[6]*exp( p[7]*r[i] )
      
      dr_dp = [ 0.                 , $
                ( p[1]-x[i] )/r[i] , $
                ( p[2]-y[i] )/r[i] , $
                0.                 , $
                0.                 , $
                0.                 , $
                0.                 , $
                0.                 , $
                ( x[i]-p[1] )/r[i] , $
                ( y[i]-p[2] )/r[i]   $
               ]
      
      du_dp = [ 0.                     , $
                0.                     , $
                0.                     , $
                0.                     , $
                0.                     , $
                r[i]                   , $
                exp( p[7]*r[i] ) - 1   , $
                0.                     , $
                0.                     , $
                0.                       $
               ]                         $
                + du_dr*dr_dp

      db_dp = [ 1.                    , $
                ( y[i]-p[2] )/r[i]^2  , $
                ( p[1]-x[i] )/r[i]^2  , $
                -1                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                ( p[2]-y[i] )/r[i]^2  , $
                ( x[i]-p[1] )/r[i]^2    $
               ]

      dz_dp_tot = dz_dp + dz_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + dz_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  dz_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )
      da_dp_tot = da_dp + da_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + da_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  da_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )
      
      dz_dp_tot = jacob # dz_dp_tot
      da_dp_tot = jacob # da_dp_tot

      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt(da_dp_tot # cov # da_dp_tot)
      sz[i] = sqrt(dz_dp_tot # cov # dz_dp_tot)

    endfor

  end
  
  strlowcase(model) eq 'proj_rot_poly2_asym' or strlowcase(model) eq 'proj_rotz_poly2_asym': begin

    jacob = diag_matrix(fltarr(np+2)+1)

    case strlowcase(model) of

      'proj_rot_poly2_asym': begin

        E   = p[3]
        eps = p[4]

      end

      'proj_rotz_poly2_asym': begin

        theta_eps = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )

        rho_eps   = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
        gamma_eps = 1 + p[8]*sin( theta_eps - p[9] )
        r_eps     = rho_eps * gamma_eps

        E     = theta_eps
        eps   = p[5]*r_eps + p[6]*r_eps^2

        deps_dr_eps = p[5] + 2*p[6]*r_eps

        ; jacob[nuovo, vecchio]
        jacob[3,4] = deps_dr_eps * ( ( ( p[3]-p[1] )/rho_eps ) * gamma_eps + p[7]*cos(theta_eps - p[8])*( p[2]-p[4] )/rho_eps )
        jacob[3,3] = ( p[2]-p[4] )/r_eps^2
        jacob[4,4] = deps_dr_eps * ( ( ( p[4]-p[2] )/rho_eps ) * gamma_eps + p[7]*cos(theta_eps - p[9])*( p[3]-p[1] )/rho_eps )
        jacob[4,3] = -( p[1]-p[3] )/r_eps^2

        jacob[1,4] = deps_dr_eps * ( ( ( p[1]-p[3] )/rho_eps ) * gamma_eps + p[7]*cos(theta_eps - p[8])*( p[4]-p[2] )/rho_eps )
        jacob[2,4] = deps_dr_eps * ( ( ( p[2]-p[4] )/rho_eps ) * gamma_eps + p[7]*cos(theta_eps - p[8])*( p[1]-p[3] )/rho_eps )
        jacob[5,4] = r_eps
        jacob[6,4] = r_eps^2
        jacob[7,4] = deps_dr_eps * rho_eps * sin( theta_eps - p[8] )
        jacob[8,4] = - deps_dr_eps * rho_eps * p[7] * cos( theta_eps - p[8] )

        jacob[0,3] = 1
        jacob[1,3] = -( p[2] - p[4] )/r_eps^2
        jacob[2,3] = ( p[1] - p[3] )/r_eps^2

      end

    endcase

    theta = p[0] + atan2( y - p[2] , x - p[1] )

    rho   = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )
    gamma = 1 + p[8]*sin( theta - p[9] )
    r     = rho * gamma

    u = p[5]*r + p[6]*r^2
    b = theta - E

    Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
    Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)
    Hy = sin(b)*sin(u)

    z = acos( Q )
    a = E + atan2( Hy , Hx )

    for i=0, n_elements(x)-1 do begin

      dz_dQ  = -1./sqrt( 1 - Q[i]^2 )
      dz_dHx = 0.
      dz_dHy = 0.

      dz_dp = [ 0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                     $
               ]

      da_dQ  = 0.
      da_dHx = -Hy[i]/( Hx[i]^2 + Hy[i]^2 )
      da_dHy = Hx[i]/( Hx[i]^2 + Hy[i]^2 )

      da_dp = [ 0.                    , $
                0.                    , $
                0.                    , $
                1.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                      $
               ]

      dQ_du = - cos(eps)*sin(u[i]) - cos(b[i])*cos(u[i])*sin(eps)
      dQ_db = sin(b[i])*sin(u[i])*sin(eps)

      dQ_dp = [ 0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                -cos(u[i])*sin(eps) - cos(b[i])*sin(u[i])*cos(eps)     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                       $
               ]

      dHx_du = cos(b[i])*cos(eps)*cos(u[i]) - sin(eps)*sin(u[i])
      dHx_db = -cos(eps)*sin(b[i])*sin(u[i])

      dHx_dp = [ 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 cos(eps)*cos(u[i]) - cos(b[i])*sin(eps)*sin(u[i])     , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                      $
                ]

      dHy_du = sin(b[i])*cos(u[i])
      dHy_db = cos(b[i])*sin(u[i])

      dHy_dp = [ 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.               $
                ]

      du_dr     = p[5] + 2*p[6]*r[i]

      dr_dp = [ 0.                                                                                    , $
                ( ( p[1]-x[i] )/rho[i] ) * gamma[i] +  p[8]*cos(theta[i] - p[9])*( y[i]-p[2] )/rho[i] , $
                ( ( p[2]-y[i] )/rho[i] ) * gamma[i] +  p[8]*cos(theta[i] - p[9])*( p[1]-x[i] )/rho[i] , $
                0.                                                                                    , $
                0.                                                                                    , $
                0.                                                                                    , $
                0.                                                                                    , $
                rho[i] * sin(theta[i] - p[9])                                                         , $
                - rho[i] * p[8] * cos(theta[i] - p[9])                                                , $
                ( ( x[i]-p[1] )/rho[i] ) * gamma[i] + p[8]*cos(theta[i] - p[9])*( p[2]-y[i] )/rho[i]  , $
                ( ( y[i]-p[2] )/rho[i] ) * gamma[i] + p[8]*cos(theta[i] - p[9])*( x[i]-p[1] )/rho[i]    $
                ]

      du_dp = [ 0.                         , $
                0.                         , $
                0.                         , $
                0.                         , $
                0.                         , $
                r[i]                       , $
                r[i]^2                     , $
                0.                         , $
                0.                         , $
                0.                         , $
                0.                           $
               ]                             $
                + du_dr*dr_dp


      db_dp = [ 1.                    , $
                ( y[i]-p[2] )/r[i]^2  , $
                ( p[1]-x[i] )/r[i]^2  , $
                -1.                   , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                ( p[2]-y[i] )/r[i]^2  , $
                ( x[i]-p[1] )/r[i]^2    $
               ]

      dz_dp_tot = dz_dp + dz_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + dz_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  dz_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )
      da_dp_tot = da_dp + da_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + da_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  da_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )

      dz_dp_tot = jacob # dz_dp_tot
      da_dp_tot = jacob # da_dp_tot

      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt(da_dp_tot # cov # da_dp_tot)
      sz[i] = sqrt(dz_dp_tot # cov # dz_dp_tot)

    endfor

  end
  
  strlowcase(model) eq 'proj_rot_exp1_asym' or strlowcase(model) eq 'proj_rotz_exp1_asym': begin

        jacob = diag_matrix(fltarr(np+2)+1)
    
    case strlowcase(model) of
      
      'proj_rot_exp1_asym': begin
        
        E   = p[3]
        eps = p[4]
        
      end
      
      'proj_rotz_exp1_asym': begin
        
        theta_eps = p[0] + atan2( p[2] - p[4] , p[1] - p[3] )
        
        rho_eps   = sqrt( ( p[1] - p[3] )^2 + ( p[2] - p[4] )^2 )
        gamma_eps = 1 + p[8]*sin( theta_eps - p[9] )
        r_eps     = rho_eps * gamma_eps
        
        E     = theta_eps
        eps   = p[5]*r_eps + p[6]*( exp( p[7]*r_eps ) -1 )
        
        deps_dr_eps = p[5] + p[7]*p[6]*exp( p[7]*r_eps )
        
        ; jacob[nuovo, vecchio]
        jacob[3,4] = deps_dr_eps * ( ( ( p[3]-p[1] )/rho_eps ) * gamma_eps + p[8]*cos(theta_eps - p[9])*( p[2]-p[4] )/rho_eps )
        jacob[3,3] = ( p[2]-p[4] )/r_eps^2
        jacob[4,4] = deps_dr_eps * ( ( ( p[4]-p[2] )/rho_eps ) * gamma_eps + p[8]*cos(theta_eps - p[9])*( p[3]-p[1] )/rho_eps )
        jacob[4,3] = -( p[1]-p[3] )/r_eps^2

        jacob[1,4] = deps_dr_eps * ( ( ( p[1]-p[3] )/rho_eps ) * gamma_eps + p[8]*cos(theta_eps - p[9])*( p[4]-p[2] )/rho_eps )
        jacob[2,4] = deps_dr_eps * ( ( ( p[2]-p[4] )/rho_eps ) * gamma_eps + p[8]*cos(theta_eps - p[9])*( p[1]-p[3] )/rho_eps )
        jacob[5,4] = r_eps
        jacob[6,4] = exp( p[7]*r_eps ) - 1
        jacob[7,4] = r_eps * p[6] * exp( p[7]*r_eps )
        jacob[8,4] = deps_dr_eps * rho_eps * sin( theta_eps - p[9] )
        jacob[9,4] = - deps_dr_eps * rho_eps * p[8] * cos( theta_eps - p[9] )

        jacob[0,3] = 1
        jacob[1,3] = -( p[2] - p[4] )/r_eps^2
        jacob[2,3] = ( p[1] - p[3] )/r_eps^2
      
      end
      
    endcase
    
    theta = p[0] + atan2( y - p[2] , x - p[1] )
    
    rho   = sqrt( ( x-p[1] )^2 + ( y-p[2] )^2 )
    gamma = 1 + p[8]*sin( theta - p[9] )
    r     = rho * gamma

    u = p[5]*r + p[6]*( exp( p[7]*r ) -1 )
    b = theta - E

    Q  = cos(u)*cos(eps) - cos(b)*sin(u)*sin(eps)
    Hx = cos(b)*sin(u)*cos(eps) + cos(u)*sin(eps)
    Hy = sin(b)*sin(u)

    z = acos( Q )
    a = E + atan2( Hy , Hx )

    for i=0, n_elements(x)-1 do begin

      dz_dQ  = -1./sqrt( 1 - Q[i]^2 )
      dz_dHx = 0.
      dz_dHy = 0.

      dz_dp = [ 0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                   , $
                0.                     $
               ]

      da_dQ  = 0.
      da_dHx = -Hy[i]/( Hx[i]^2 + Hy[i]^2 )
      da_dHy = Hx[i]/( Hx[i]^2 + Hy[i]^2 )

      da_dp = [ 0.                    , $
                0.                    , $
                0.                    , $
                1.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                      $
               ]

      dQ_du = - cos(eps)*sin(u[i]) - cos(b[i])*cos(u[i])*sin(eps)
      dQ_db = sin(b[i])*sin(u[i])*sin(eps)

      dQ_dp = [ 0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                -cos(u[i])*sin(eps) - cos(b[i])*sin(u[i])*cos(eps)     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                     , $
                0.                                                       $
               ]

      dHx_du = cos(b[i])*cos(eps)*cos(u[i]) - sin(eps)*sin(u[i])
      dHx_db = -cos(eps)*sin(b[i])*sin(u[i])

      dHx_dp = [ 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $
                 cos(eps)*cos(u[i]) - cos(b[i])*sin(eps)*sin(u[i])     , $
                 0.                                                    , $
                 0.                                                    , $
                 0.                                                    , $   
                 0.                                                    , $
                 0.                                                    , $            
                 0.                                                    , $
                 0.                                                      $
                ]

      dHy_du = sin(b[i])*cos(u[i])
      dHy_db = cos(b[i])*sin(u[i])

      dHy_dp = [ 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.             , $
                 0.               $
                ]
       
      du_dr     = p[5] + p[7]*p[6]*exp( p[7]*r[i] )      
      
      dr_dp = [ 0.                                                                                    , $
                ( ( p[1]-x[i] )/rho[i] ) * gamma[i] +  p[8]*cos(theta[i] - p[9])*( y[i]-p[2] )/rho[i] , $
                ( ( p[2]-y[i] )/rho[i] ) * gamma[i] +  p[8]*cos(theta[i] - p[9])*( p[1]-x[i] )/rho[i] , $
                0.                                                                                    , $
                0.                                                                                    , $
                0.                                                                                    , $
                0.                                                                                    , $
                0.                                                                                    , $
                rho[i] * sin(theta[i] - p[9])                                                         , $
                - rho[i] * p[8] * cos(theta[i] - p[9])                                                , $
                ( ( x[i]-p[1] )/rho[i] ) * gamma[i] + p[8]*cos(theta[i] - p[9])*( p[2]-y[i] )/rho[i]  , $
                ( ( y[i]-p[2] )/rho[i] ) * gamma[i] + p[8]*cos(theta[i] - p[9])*( x[i]-p[1] )/rho[i]    $
               ]          

      du_dp = [ 0.                         , $
                0.                         , $
                0.                         , $
                0.                         , $
                0.                         , $
                r[i]                       , $
                exp( p[7]*r[i] ) - 1       , $
                p[6]*r[i]*exp( p[7]*r[i] ) , $
                0.                         , $
                0.                         , $
                0.                         , $
                0.                           $
               ]                             $
                + du_dr*dr_dp
                     

      db_dp = [ 1.                    , $
                ( y[i]-p[2] )/r[i]^2  , $
                ( p[1]-x[i] )/r[i]^2  , $
                -1.                   , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                0.                    , $
                ( p[2]-y[i] )/r[i]^2  , $
                ( x[i]-p[1] )/r[i]^2    $
               ]     

      dz_dp_tot = dz_dp + dz_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + dz_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  dz_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )
      da_dp_tot = da_dp + da_dQ*( dQ_dp + dQ_du*du_dp + dQ_db*db_dp ) + da_dHx*( dHx_dp + dHx_du*du_dp + dHx_db*db_dp ) + $
                  da_dHy*( dHy_dp + dHy_du*du_dp + dHy_db*db_dp )
      
      dz_dp_tot = jacob # dz_dp_tot
      da_dp_tot = jacob # da_dp_tot

      cov[np,np]     = sx[i]^2
      cov[np+1,np+1] = sy[i]^2

      sa[i] = sqrt(da_dp_tot # cov # da_dp_tot)
      sz[i] = sqrt(dz_dp_tot # cov # dz_dp_tot)

    endfor

  end
  
  else: begin
    
    message, 'error computation not implemented for ' + strlowcase(model) + '. Please check.'
    
  end
  
endcase

retv = { az:float(sa) , zd:float(sz) }

return, retv

end