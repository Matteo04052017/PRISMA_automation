; Hor2Eq error propagation

pro hor2eq_error, alt1, s_alt, az1, s_az, jd, ra, s_ra, dec, s_dec, ha, s_ha, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                  B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                  refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                  _extra = _extra

if ~keyword_set(lat)         then lat         = []
if ~keyword_set(lon)         then lon         = []
if ~keyword_set(WS)          then WS          = []
if ~keyword_set(obsname)     then obsname     = []
if ~keyword_set(B1950)       then B1950       = []
if ~keyword_set(verbose)     then verbose     = []
if ~keyword_set(precess_)    then precess_    = []
if ~keyword_set(nutate_)     then nutate_     = []
if ~keyword_set(refract_)    then refract_    = []
if ~keyword_set(aberration_) then aberration_ = []
if ~keyword_set(altitude)    then altitude    = []
if ~keyword_set(_extra)      then _extra      = []

alt2 = alt1 + s_alt
alt3 = alt1 - s_alt
az2  = az1 + s_az
az3  = az1 - s_az

hor2eq, alt1, az1, jd, ra1, dec1, ha1, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra

hor2eq, alt1, az2, jd, ra2, dec2, ha2, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra

hor2eq, alt1, az3, jd, ra3, dec3, ha3, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra
                                       
hor2eq, alt2, az1, jd, ra4, dec4, ha4, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra

hor2eq, alt2, az2, jd, ra5, dec5, ha5, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra
                                       
hor2eq, alt2, az3, jd, ra6, dec6, ha6, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra

hor2eq, alt3, az1, jd, ra7, dec7, ha7, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra

hor2eq, alt3, az2, jd, ra8, dec8, ha8, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra
                                       
hor2eq, alt3, az3, jd, ra9, dec9, ha9, lat=lat, lon=lon, WS=WS, obsname=obsname,$
                                       B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                                       refract_ = refract_, aberration_ = aberration_, altitude=altitude, $
                                       _extra = _extra

ra = ra1
a = [[ra2-ra1],[ra3-ra1],[ra4-ra1],[ra5-ra1],[ra6-ra1],[ra7-ra1],[ra8-ra1],[ra9-ra1]]/!radeg
closest, a
s_ra = max(abs(a), dimension=2)*!radeg   

dec = dec1
a = [[dec2-dec1],[dec3-dec1],[dec4-dec1],[dec5-dec1],[dec6-dec1],[dec7-dec1],[dec8-dec1],[dec9-dec1]]/!radeg
closest, a
s_dec = max(abs(a), dimension=2)*!radeg   

ha = ha1
a = [[ha2-ha1],[ha3-ha1],[ha4-ha1],[ha5-ha1],[ha6-ha1],[ha7-ha1],[ha8-ha1],[ha9-ha1]]/!radeg
closest, a
s_ha = max(abs(a), dimension=2)*!radeg   

;; ha    = atan2(Hy,Hx)
;Hx = -cos(alt)*sin(az)
;Hy = sin(alt)*cos(lat) - cos(alt)*cos(az)*sin(lat)
;
;dha_dHx = -Hy / (Hx^2 + Hy^2)
;dha_dHy =  Hx / (Hx^2 + Hy^2)
;
;dHx_dalt = sin(alt)*sin(az)
;dHx_daz  = -cos(alt)*cos(az)
;dHy_dalt = cos(alt)*cos(lat) + sin(alt)*cos(az)*sin(lat)
;dHy_daz  = cos(alt)*sin(az)*sin(lat)
;
;dha_dalt = dha_dHx*dHx_dalt + dha_dHy*dHy_dalt
;dha_daz  = dha_dHx*dHx_daz + dha_dHy*dHy_daz
;
;s_ha = sqrt( (dha_dalt*s_alt)^2 + (dha_daz*s_az)^2 )*!radeg
;s_ra = s_ha
;
;; dec = asin(Q)
;Q  = sin(alt)*sin(lat) + cos(alt)*cos(az)*cos(lat)   
;
;ddec_dQ = 1./sqrt( 1.-Q^2 ) 
;
;dQ_dalt = cos(alt)*sin(lat) - sin(alt)*cos(az)*cos(lat)
;dQ_daz  = -cos(alt)*sin(az)*cos(lat)
;
;ddec_dalt = ddec_dQ*dQ_dalt
;ddec_daz  = ddec_dQ*dQ_daz
;
;s_dec = sqrt( (ddec_dalt*s_alt)^2 + (ddec_daz*s_az)^2 )*!radeg       
                  
end