C*******************************************************************
        SUBROUTINE FLOWHT
C******************************************************************
C
C  THIS SUBROUTINE DETERMINES THE WEIGHTED AVERAGE FLOW SURFACE HEIGHTS
C  BASED ON THE VALUES THAT WOULD BE OBTAINED FROM THE INDIVIDUAL
C  TEMPERATURE PROFILES--F LUDWIG, JANUARY 1988
C
          INCLUDE 'NGRIDS.PAR'
C
          INCLUDE 'ANCHOR.CMM'
          INCLUDE 'FLOWER.CMM'
          INCLUDE 'LIMITS.CMM'
          INCLUDE 'STALOC.CMM'
          INCLUDE 'TSONDS.CMM'
C
	REAL RYZVAR(NSITES),XVAR(NSITES),YVAR(NSITES)
	INTEGER NRYZ
C
C  DZMAX(IT,IZ) = MAXIMUM RISE FOR IZTH FLOW SFC AS DETERMINED FROM
C
        DO 220 IX = 1,NCOL
           XX = FLOAT(IX)
           DO 200 IY = 1,NROW
	      YY=FLOAT(IY)
              HERE=SFCHT(IX,IY)
              DO 175 L = 1,NLVL
		 IF (NUMTMP .GT. 1) THEN
C
C  IF THE SITE HAD VALID DATA (NTHTS >0)) THEN GET WEIGHTED AVERAGE RISE
C  AFTER GETTING RELATION FOR LOCAL TOPOGRAPHY HEIGHT VERSUS MAXIMUM 
C  RISE FROM FUNCTION SLOPER.
C
	            NRYZ=0
                    DO 150 IT = 1,NUMTMP
                       IF (NTHTS(IT) .GT. 0 .AND. 
     $                                 DZMAX(IT,L).GT.-9998.) THEN
                          ZRATIO=SLOPER(HERE,SFCLOW,ZRISE)
			  NRYZ=NRYZ+1
			  XVAR(NRYZ)=XTMP(IT)
			  YVAR(NRYZ)=YTMP(IT)
                          ZRATIO=SLOPER(HERE,SFCLOW,ZRISE)
                          RYZVAR(NRYZ)= ZRATIO*DZMAX(IT,L)
                       END IF
150                 CONTINUE
                    IF (NRYZ .GT. 0) THEN
		       CALL RINVMOD(RHERE,XX,YY,XVAR,YVAR,NRYZ,RYZVAR)
                       RHS(IX,IY,L) = 
     $                    RHERE+AVTHK*SIGMA(L)+SFCLOW-HERE
	            ELSE
C
C  IF NO SOUNDING REACHES THIS HIGH THEN USE SAME RISE AS NEXT 
C  LOWER LEVEL -- IF NO SOUNDING AT ALL USE A RISE = TO 3/4 THE 
C  TERRAIN RISE.
C
	               IF (L.GT.1) THEN
		          RHERE=RHS(IX,IY,L-1)-
     $                          (AVTHK*SIGMA(L-1)+SFCLOW-HERE)
                          RHS(IX,IY,L)= 
     $                         RHERE+AVTHK*SIGMA(L)+SFCLOW-HERE
		       ELSE
                          RHS(IX,IY,L)= 
     $                       AVTHK*SIGMA(L)-0.25*(HERE-SFCLOW)
		       END IF
		    END IF
                 ELSE IF (NUMTMP .LT.1) THEN
C
C  IF NO SOUNDING USE SFC THAT RISES 3/4 AS FAST AS THE  TERRAIN.
C
	            WRITE (*,*) 'BE WARY -- NO SOUNDING'
                    RHS(IX,IY,L)= AVTHK*SIGMA(L)-0.25*(HERE-SFCLOW)
		 ELSE IF (NUMTMP.EQ.1) THEN
		    IF (DZMAX(1,L) .GT. -9998.) THEN
C
C  IF ONE SOUNDING REACHES THIS LEVEL, USE IT
C
		       RHERE=SLOPER(HERE,SFCLOW,ZRISE)*DZMAX(1,L)
                       RHS(IX,IY,L)=RHERE+AVTHK*SIGMA(L)+SFCLOW-HERE
		    ELSE 
		      IF (L.GT.1 .AND. DZMAX(1,L-1).GT.-9998.) THEN
C
C  IF ONLY ONE SOUNDING AND IT DOESN'T REACH THIS LEVEL, USE HIGHEST
C  AVAILABLE DZMAX FOR UPPER LEVELS
C
	                 DZMAX(1,L)=DZMAX(1,L-1)
		         RHERE=SLOPER(HERE,SFCLOW,ZRISE)*DZMAX(1,L)
                         RHS(IX,IY,L)=RHERE+AVTHK*SIGMA(L)+SFCLOW-HERE
		      ELSE
C
C  IF NO SONDE THIS LEVEL OR THE ONE BELOW USE SFC THAT RISES 3/4 
C  AS FAST AS THE  TERRAIN.
C
                         RHS(IX,IY,L)=AVTHK*SIGMA(L)-
     $	                                  0.25*(HERE-SFCLOW)
		      END IF                    
		    END IF                    
		 END IF
C
C  SETTING FLOW SURFACE THAT CLEARS TERRAIN TO CLEAR IT BY AT LEAST
C  20 M.
C
		 IF (RHS(IX,IY,L).GE.Z0 .AND. 
     $                RHS(IX,IY,L) .LT. 20.0) RHS(IX,IY,L)=20.0
175           CONTINUE
	      DO 178 L=2,NLVL
	         LEVBOT(IX,IY)=L
	         IF (RHS(IX,IY,L).GT.Z0) GO TO 200
178	      CONTINUE
200	   CONTINUE
220	CONTINUE
C
        RETURN
        END

