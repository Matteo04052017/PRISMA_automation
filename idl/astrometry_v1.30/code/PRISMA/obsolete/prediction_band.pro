;+
; NAME:
; sse
;
;
; PURPOSE:
; return the sum-squared error of the residuals
;
;
; CATEGORY:
; Stats
;
; INPUTS:
; res: residuals to do calculation on
;
;
; OPTIONAL INPUTS:
; none
;
;
; KEYWORD PARAMETERS:
; none
;
;
; OUTPUTS:
; sum: squared error of residuals
;
;
; OPTIONAL OUTPUTS:
; none
;
;
;
; MODIFICATION HISTORY:
;
;       Sun Nov 25 23:28:11 2007, Brian Larsen
;   documented, written previously
;
;-
FUNCTION sse, res

  sse = total((res)^2., /nan, /double)

  RETURN, sse
END

;+
; NAME:
; mse.pro
;
;
; PURPOSE:
; return the mean squared error of the inout residuls
;
;
; CATEGORY:
; Stats
;
;
; INPUTS:
; res: array of residuals
;
;
; OUTPUTS:
; mean squared error
;
;
; MODIFICATION HISTORY:
;
;       Tue Jan 22 13:22:44 2008, Brian Larsen
;   documented, written previously
;
;-
FUNCTION mse, res

  ; mse is sse/n-2
  mse = sse(res)/double((N_ELEMENTS(res)-2 ))

  RETURN, mse
END

;+
; NAME:
; confidence_band
;
;
; PURPOSE:
; compute and optionally plot the confidence bands on a regression plot
;
;
; INPUTS:
; X: 'x' values to regress against
; Y: 'y' values to regress
;
;
; OPTIONAL INPUTS:
; none
;
;
; KEYWORD PARAMETERS:
; confidence: set this to specify the conidence band (default 0.95)
; PLOT: set this to plot the data
; RESIDUAL: input the residualts instead of calculation them
; REG_EQ: input a regression equation found externally
; OPLOT: oplot the confidence band on an exsisting plot
; EQUATION: show the equation on the plot
; CORRELATION: returns the correlation coefficient of regression
; LINESTYLE: linestyle of the confidence bands
; PSYM: specifiy the symbol to use when plotting the points
; NAN: pull out any nan data
; _EXTRA: extra keywords to plot
;
; OUTPUTS:
; structure of points for the confidence bands at the points passed in
; in x
;
; Structure format is:
;   YTOP            DOUBLE    Array[N_ELEMENTS(x)]
;   YBOT            DOUBLE    Array[N_ELEMETNS(x)]
;
;
; OPTIONAL OUTPUTS:
; none except plots to the screen
;
;
;
; RESTRICTIONS:
; currently only works for single regression
;
;
; EXAMPLE:
; a=confidence_band(findgen(10)+randomn(seed, 10), findgen(10), /plot)
;
;
;
; MODIFICATION HISTORY:
;
;       Mon Mar 5 08:52:08 2007, Brian Larsen
;   added _extra call and remove various keywords
;       Tue Jun 20 14:35:58 2006, Brian Larsen
;   added xtitle, ytitle, and nan keywords
;       Wed Jun 7 14:16:07 2006, Brian Larsen
;   documented, written previously
;
;-

FUNCTION prediction_band, x, y, MEASURE_ERRORS = me, confidence=confidence, PLOT=plot, $
  RESIDUAL=residual, REG_EQ=reg_EQ, OPLOT=oplot, $
  EQUATION=equation, CORRELATION=correlation, $
  LINESTYLE=linestyle, PSYM=psym, NAN=nan, $
  _EXTRA=_extra

  ;; get rid of any nan
  IF KEYWORD_SET(nan)  THEN BEGIN
    indnan = where(x EQ x AND y EQ y)
    x = x[indnan]
    y = y[indnan]
  ENDIF

  IF N_ELEMENTS(me) EQ 0 then me = replicate(1,n_elements(x))


  ;; this is from Applied Linear statistical models
  ;;

  IF N_ELEMENTS(reg_eq) EQ 2  THEN BEGIN
    yfit = reg_eq[0] + reg_EQ[1]*x
  ENDIF ELSE BEGIN
    reg = regress(x, y, const=const, yfit=yfit, correlation=correlation, measure_errors = me)
  ENDELSE

  IF N_ELEMENTS(residual) EQ 0   THEN BEGIN
    ; get the residuals
    res = y-yfit              ; this is the dfn of residua
  ENDIF

  mse = mse(res)

  sq_diff = 0d

  IF N_ELEMENTS(confidence) NE 1 THEN confidence = 0.95

  w = sqrt(2.*  F_CVF( (1.-confidence), 2, N_ELEMENTS(res)-2))

  numer = (x-mean(x, /nan))^2.
  denom = total((x-mean(x, /nan))^2.)

  IF N_ELEMENTS(reg) EQ 0  THEN BEGIN
    reg = reg_EQ[1]
    const = reg_EQ[0]
  ENDIF

  yt = const + (reg[0]*x + w*sqrt(mse)* $
    sqrt(1 + 1./N_ELEMENTS(y) +  numer/denom))


  yb = const + reg[0]*x - w*sqrt(mse)* $
    sqrt(1 + 1./N_ELEMENTS(y) +  numer/denom)

  IF N_ELEMENTS(psym) EQ 0  THEN BEGIN
    psym=1
  ENDIF


  IF KEYWORD_SET(plot)  THEN BEGIN
    subtitle = 'Confidence Level: ' + strtrim(confidence)
    plot, x, y, PSYM=psym, _STRICT_EXTRA=_extra
  ENDIF

  IF N_ELEMENTS(linestyle) EQ 0   THEN BEGIN
    linestyle=2
  ENDIF

  IF KEYWORD_SET(oplot) OR KEYWORD_SET(plot)   THEN BEGIN
    srt = sort(x)
    oplot, x[srt], yfit[srt]
    oplot, x[srt], yt[srt], linestyle=linestyle
    oplot, x[srt], yb[srt], linestyle=linestyle
  ENDIF

  IF N_ELEMENTS(equation) NE 0 AND (KEYWORD_SET(plot) OR KEYWORD_SET(oplot)) THEN BEGIN
    IF N_ELEMENTS(equation) NE 2 THEN BEGIN
      xo = max(!x.crange)*0.4
      yo = max(!y.crange)*0.9
    ENDIF ELSE BEGIN
      xo = equation[0]
      yo = equation[1]
    ENDELSE
    xyouts, xo, yo, 'Y = ' + strtrim(reg[0]) + ' X + ' + strtrim(const), align=0.5
  ENDIF


  RETURN, create_struct('ytop', reform(yt), 'ybot', reform(yb))
END
