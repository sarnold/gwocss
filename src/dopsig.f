C********************************************************************
        SUBROUTINE DOPSIG(ICALL)
C********************************************************************
C
C  ASSIGN WND STA WIND PROFILES TO FLOW SURFACES.MISSING WINDS ARE 
C  DENOTED BY -9999. IF SOUNDING IS NOT COMPLETE THE LAST REPORTED WIND 
C  IS USED AT THE HIGHEST ALTITUDES. AFTER FLOW SURFACES ARE REDEFINED 
C  (RESIG), DOPSIG IS RECALLED (ICALL >1) AND THE SOUNDINGS ARE 
C  REINTERPOLATED TO THE SURFACES. TOPWIND AND BETWIN ARE RECALLED TO 
C  PROVIDE THE WINDS THAT ARE TO BE BALANCED. THE ORIGINAL VERSION OF 
C  THIS SUBROUTINE WAS WRITTEN BY R.M. ENDLICH, SRI INTN'L, MENLO PARK 
C  CA 94025. 
C  IT WAS LARGELY REWRITTEN  BY LUDWIG IN NOV,1987. THIS VERSION 
C  INCLUDES CHANGES MADE IN APRIL, 1989.
C
C  FURTHER MODIFIED MAY 1989 TO PROVIDE FOR A SECOND CALL WHERE WINDS 
C  ARE REINTERPOLATED TO THE NEWLY DEFINED FLOW SURFACES; DATA READING
C  AND OTHER PARTS OF THE ROUTINE ARE SKIPPED -- F. LUDWIG
C
C
        INCLUDE 'NGRIDS.PAR'
C
	INCLUDE 'ANCHOR.CMM'
        INCLUDE 'FLOWER.CMM'
        INCLUDE 'LIMITS.CMM'
        INCLUDE 'STALOC.CMM'
        INCLUDE 'TSONDS.CMM'
C
	REAL DPHT(NSNDHT,NWSITE), DPUC(NSNDHT,NWSITE)
	REAL DPVC(NSNDHT,NWSITE),RHS1(NZGRD),SYTHYT(NWSITE)
	INTEGER LEVHI(NWSITE)
C
      	DATA UVO/0.0/
	SAVE
C
C  VARIABLES ARE:
C    DPUC=U COMPONENT OF WND STA WIND IN MPS
C    DPVC=V COMPONENT OF WND STA WIND IN MPS
C    NWHTS=NUMBER OF POINTS IN VERTICAL WIND PROFILE
C    NLVL=NUMBER OF FLOW LEVELS
C    RHS=HT OF FLOW SURFACES ABOVE TERRAIN (M)
C    XG,YG=STA. DIST IN X,Y IN GRID UNITS FROM 0,0 (SW CORNER)
C    Z0, UVO = ROUGHNESS HT AND ZERO-LEVEL WIND FOR INTERPOLATING
C    SYTHYT(IS)=SFC ELEVATION FOR SITE IS
C    LEVHI(IS)=HIGHEST FLOW SURFACE FOR WHICH WIND WAS OBSERVED AT SITE IS
C
C    ON 1ST CALL AT EACH TIME, READ IN WIND PROFILES.
C
	IF (ICALL .EQ. 1) THEN
	   DO 45 IT=1,NUMDOP
C
C  ZERO VALUES ON FLOW SURFACES BEFORE CALCULATING
C
	      DO 11 ILEV=1,NLVL
	         USIG(IT,ILEV)=0.0
	         VSIG(IT,ILEV)=0.0
11	      CONTINUE
C
C  SKIP BLANK LINE THEN READ COORDINATES OF SITE
C
              READ (12,*)
              READ (12,*)  DOPX,DOPY,DOPZ
	      SYTHYT(IT)=DOPZ
C
C  LOCATE GRID POINT NEAREST THE SOUNDING (NOTE ORIGIN AT 1,1).
C
	      XDOP(IT)=1.0+(DOPX-XORIG)/DSCRS
	      YDOP(IT)=1.0+(DOPY-YORIG)/DSCRS
	      ZDOP(IT)=DOPZ
              IX=MAX(1,NINT(XDOP(IT)))
              JY=MAX(1,NINT(YDOP(IT)))
              IX=MIN(IX,NCOL)
              JY=MIN(JY,NROW)
	      ZFIX=SFCHT(IX,JY)-SYTHYT(IT)
              READ (12,*) NWHTS(IT)
C
C  SKIP COLUMN HEADING LINE
C
              READ (12,*)
	      DO 15 LL=1,NWHTS(IT)
                 READ (12,*) ZZHT,ZZWD,ZZWS
C   
                 IF (LL .LT. NSNDHT) THEN
                    DPHT(LL,IT)=ZZHT-SYTHYT(IT)
                    DPWD(LL)=ZZWD
                    DPWS(LL)=ZZWS
	         ELSE
                    DPHT(NSNDHT,IT)=ZZHT-SYTHYT(IT)
                    DPWD(NSNDHT)=ZZWD
                    DPWS(NSNDHT)=ZZWS
                 END IF
15	      CONTINUE
	      IF (NWHTS(IT) .GT. NSNDHT) NWHTS(IT)=NSNDHT
C
C  CONVERT WIND MEASUREMENT HEIGHTS IN METERS (MSL) TO METERS (AGL)
C  ADJUST FOR FACT THAT SOUNDING LOCATION NOT AT GRID PT.
C
	      DO 25 LL=1,NLVL
                 RHS1(LL)=RHS(IX,JY,LL)
		 ZSIGL(IT,LL)=RHS1(LL)
25	      CONTINUE
C
C
C  CHANGE DIRECTION AND SPEED (MPS) TO U AND V; CHECK FOR MISSING DATA 
C  OR BELOW GROUND HEIGHTS (AFTER CONVERSION FROM MSL) ON 1ST CALL.
C
	      NEWLL=0
              DO 40 LL=1,NWHTS(IT)
                 IF (DPWD(LL).GT.-9998.9) THEN
                    IF (DPHT(LL,IT) .GT. Z0) THEN
                       NEWLL=NEWLL+1
                       DPUC(NEWLL,IT)=
     $                          -DPWS(LL)*SIN(DPWD(LL)/57.295)
                       DPVC(NEWLL,IT)=
     $                          -DPWS(LL)*COS(DPWD(LL)/57.295)
                       DPHT(NEWLL,IT)=DPHT(LL,IT)
                    END IF
                 END IF
40	      CONTINUE
              NWHTS(IT)=NEWLL
45	   CONTINUE
	END IF
C
C  INTERPOLATE TO ORIGINAL, OR NEWLY DEFINED, FLOW SURFACE HEIGHTS
C  AT LEVELS WHERE DATA ARE AVAILABLE
C	
	DO 150 IT=1,NUMDOP
           IX=MAX(1,NINT(XDOP(IT)))
           JY=MAX(1,NINT(YDOP(IT)))
           IX=MIN(IX,NCOL)
           JY=MIN(JY,NROW)
C
C  FIND HIGHEST FLOW SURFACE REACHED BY THIS SOUNDING. ALSO CHECK
C  FOR HIGHEST SFC REACHED BY ANY SNDING
C
	   LEVHI(IT)=0
           DO 100 KL=1,NLVL
              ZLEVKL=RHS(IX,JY,KL)
              RHS1(KL)=ZLEVKL
	      ZSIGL(IT,KL)=ZLEVKL
	      DO 96 IZ=1,NWHTS(IT)
	         IF (DPHT(IZ,IT).GT.ZLEVKL) LEVHI(IT)=KL
96	      CONTINUE
100	   CONTINUE
C
C  ASSIGNING OBSERVED WINDS TO FLOW SURFACE HEIGHTS UP TO TOP 
C  OF SONDE
C
	   DO 140 KL=1,LEVHI(IT)
	      ZF=RHS1(KL)
C
	      IF (ZF .LE. Z0) THEN
C
C  ZERO WIND WHEN FLOW SFC BELOW ROUGHNESS HEIGHT.
C
                 USIG(IT,KL)=0.0
                 VSIG(IT,KL)=0.0
	      ELSE IF (ZF.GT.Z0 .AND. ZF.LE. DPHT(1,IT)) THEN
C
C  FLOW SFC BELOW 1ST OBSERVATION HT -- LOG INTERP TO FLOW SFC.
C
	         CALL LGNTRP(USIG(IT,KL),Z0,DPHT(1,IT),
     $                                  ZF,UVO,DPUC(1,IT))
                 CALL LGNTRP(VSIG(IT,KL),Z0,DPHT(1,IT),
     $                                  ZF,UVO,DPVC(1,IT))
	      ELSE
C
C  FLOW SURFACE ABOVE LOWEST OB -- FIND WHICH OBS IT IS BETWEEN
C  AND LOG INTERPOLATE.
C
	         DO 135 JHT=1,NWHTS(IT)-1
	            ZW1=DPHT(JHT,IT)
                    ZW2=DPHT(JHT+1,IT)
                    IF (ZF.GT.ZW1 .AND. ZF.LE.ZW2) THEN
C
C FLOW SFC BETWEEN OBSERVATION HTS
C
                       CALL LGNTRP(USIG(IT,KL),ZW1,ZW2,ZF,
     $                           DPUC(JHT,IT),DPUC(JHT+1,IT))
                       CALL LGNTRP(VSIG(IT,KL),ZW1,ZW2,ZF,
     $                             DPVC(JHT,IT),DPVC(JHT+1,IT))
     	               GO TO 140
     	            END IF
135		 CONTINUE
C
	      END IF
140	   CONTINUE
150	CONTINUE
C
C  FIND HIGHEST LEVEL REACHED BY ANY SONDE
C
	LEVTOP=0
	DO 160 JSOND=1,NUMDOP
	   LEVTOP=MAX(LEVTOP,LEVHI(JSOND))
160	CONTINUE
C
C  ALL OBSERVED DATA INTERPOLATED VERTICALLY TO FLOW SURFACES.  NOW,
C  INTERPOLATE HORIZONTALLY UP TO TOP OBSERVATION WHERE REQUIRED
C
	DO 200 JSOND=1,NUMDOP
           XX=XDOP(JSOND)
	   YY=YDOP(JSOND)
	   DO 180 IL=LEVHI(JSOND)+1,LEVTOP
C
C  THIS ONE IS MISSING INTERPOLATE FROM OTHERS AVAILABLE AT THIS LEVEL
C
	      SUMU=0.0
	      SUMV=0.0
	      SUMWT=0.0
	      DO 175 JD=1,NUMDOP
C
C  SKIP WHEN LOOKING AT SAME SOUNDING BEING INTERPOLATED FOR.
C
	         IF (JD.NE.JSOND) THEN
		    IF (LEVHI(JD).GE.IL) THEN
		       WEIGHT=WNDWT(XX,YY,XDOP(JD),YDOP(JD))
		       SUMWT=SUMWT+WEIGHT
		       SUMU=SUMU+WEIGHT*USIG(JD,IL)
		       SUMV=SUMV+WEIGHT*VSIG(JD,IL)
		    END IF
		 END IF
175	      CONTINUE
C
	      IF (SUMWT.GT.0.0) THEN
	         USIG(JSOND,IL)=SUMU/SUMWT
	         VSIG(JSOND,IL)=SUMV/SUMWT
	      ELSE
		 WRITE (*,*) 'CHECK DOPSIG NEAR 180'
		 STOP
	      END IF
180	   CONTINUE
200  	CONTINUE
C
C  IF NO SOUNDING GOES AS HIGH AS UPPERMOST LEVEL, EXTRAPOLATE
C  UPPERMOST VALUESTO TOP OF DOMAIN.
C
	IF (LEVTOP.LT.NLVL) THEN
	   DO 225 JSOND=1,NUMDOP
	      DO 220 IL=LEVTOP+1,NLVL
	         USIG(JSOND,IL)=USIG(JSOND,LEVTOP)
	         VSIG(JSOND,IL)=VSIG(JSOND,LEVTOP)
220	      CONTINUE
225	   CONTINUE
	END IF
C
C  ALL MISSING UPPER WIND DATA HAVE BEEN ESTIMATED.
C
        RETURN
C
        END

