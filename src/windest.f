C*******************************************************************
        SUBROUTINE FIXWND (IFXPT,LVL)
C******************************************************************
C
C  THIS ROUTINE IDENTIFIES PTS NEAR OBSERVATION SITES SO THAT
C  WIND ADJUSTMENTS CAN BE RESTRAINED IN SUBROUTINE BAL5.
C
C___________________________________________________________________
C
C  MODIFIED SO THAT ALL LEVELS ABOVE AN UPPER WIND SITE ARE IDENTIFIED,
C  BUT ONLY THE FIRST ABOVE GROUND LEVEL FOR SURFACE WIND SITES.
C
C		F. L. LUDWIG, 3/96
C___________________________________________________________________
C
C  FURTHER MODIFIED SO THAT ABOVE GROUND POINTS ON A SURFACE ARE 
C  FLAGGED FOR RESTRAINED ADJUSTMENT IF THEY HAVE 3 OR MORE OF THE 4 
C  SURROUNDING POINTS ARE BELOW GROUND.
C
C		FLUDWIG 3/2000
C___________________________________________________________________
C
          INCLUDE 'NGRIDS.PAR'       
C
          INCLUDE 'FLOWER.CMM'
          INCLUDE 'LIMITS.CMM'
          INCLUDE 'STALOC.CMM'
C
        LOGICAL IFXPT(NXGRD,NYGRD)
	SAVE
C
C  INTIALIZE IFXPT VALUES TO FALSE
C
	DO 22 IX=1,NXGRD
	   DO 20 IY=1,NYGRD
		IFXPT(IX,IY)=.FALSE.
20	   CONTINUE
22	CONTINUE
C
C  CHECK ALL GRID POINTS TO SEE IF THEY SHOULD BE ADJUSTED
C  IF THE POINT ITSELF, OR 3 OR 4 OF THE SURROUNDING POINTS 
C  ARE SUBTERRAINIAN, RESTRICT ADJUSTMENTS, I.E. SET IFXPT TO .TRUE.  
C
	DO 50 IX=2,NCOL-1
	   DO 48 IY=2,NROW-1
	      IF (RHS(IX,IY,LVL).LE. 0.0) THEN
		 IFXPT(IX,IY)=.TRUE.
	      ELSE
		 NSUBTER=0
		 DO  44 JX=IX-1,IX+1,2
		    DO  40 JY=IY-1,IY+1,2
 		        IF (RHS(JX,JY,LVL).LE. 0.0) 
     $                             NSUBTER=NSUBTER+1
40		    CONTINUE
44		CONTINUE
 		IF (NSUBTER .GE. 3)  THEN
                   IFXPT(IX,IY)=.TRUE.
		ELSE
                   IFXPT(IX,IY)=.FALSE.
		END IF
	     END IF
48	  CONTINUE
50	CONTINUE
		      
C
C  SET FLAG FOR LIMITED ADJUSTMENT AT POINTS AROUND OBS SITE
C
	DO 200 I=1,NSITES
          IF (I .LE. NUMNWS ) THEN
C
C  CHECK TO SEE IF THIS SITE HAD AN OBSERVATION
C
	      IF (JGOOD(I)) THEN
                  IX=NINT(XG(I))
                  IY=NINT(YG(I))
                  IF (IX.GT.0 .AND. IX.LE.NCOL   
     $                 .AND. IY.GT.0 .AND.    
     $                          IY .LE.NROW) THEN
C
C  CHECK TO SEE IF THIS IS FIRST LEVEL ABOVE SURFACE FOR 
C  SURFACE OBSERVATIONS.  
C
		     IF (RHS(IX,IY,LVL) .GT. 0.0 .OR. LVL.EQ.1) 
     $                               IFXPT(IX,IY)=.TRUE.
		  END IF
	       END IF
	    END IF
C
200	CONTINUE
C
        RETURN
        END
C
C*********************************************************************
        SUBROUTINE BETWIN
C*********************************************************************
C
C  THIS SUBROUTINE ESTIMATES WINDS BETWEEN THE TOP AND BOTTOM LEVELS. 
C  THE DEVIATION OF OBSERVED WINDS FROM A LOG PROFILE IS FIRST 
C  DETERMINED.  THEN THE DEVIATIONS AT EACH LEVEL ARE INTERPOLATED BY 
C  AN INVERSE DISTANCE TO A POWER WEIGHTING SCHEME.  THE 
C  INTERPOLATED DEVIATIONS ARE USED TO CORRECT  THE CALCULATED LOG 
C  PROFILES AT THE GRID POINTS.
C               --F  LUDWIG  12/87
C
	INCLUDE 'NGRIDS.PAR'
C
	INCLUDE 'ANCHOR.CMM'
	INCLUDE 'FLOWER.CMM'
	INCLUDE 'LIMITS.CMM'
	INCLUDE 'STALOC.CMM'
	INCLUDE 'TSONDS.CMM'
C
        REAL DDOPU(NWSITE,NZGRD),DDOPV(NWSITE,NZGRD)
        REAL DUTMP(NSITES),DVTMP(NSITES),XVAR(NSITES),YVAR(NSITES)
C
	INTEGER LBOT(NWSITE)
C
	LOGICAL OKSOND(NWSITE,NZGRD)
C
        IF (NLVL .LE. 3) THEN
           WRITE (*,*) ' ONLY ',NLVL-1,' FLOW SURFACES'
           RETURN
        END IF
C
C  GET LOG PROFILES AT OBSERVATION POINTS AND DEVIATIONS FROM THEM. 
C  Z0=ROUGHNESS HT.
C
	IF (NUMDOP .GT. 0) THEN
	   DO 50 JDOP = 1,NUMDOP
C
C  FIND LOWEST FLOW SURFACE FOR THIS SONDE
C
	      DO 22 IL=2,NLVL
	         IF (ZSIGL(JDOP,IL) .GE. Z0) THEN
                    H0=ZSIGL(JDOP,IL)
		    LBOT(JDOP)=IL
		    GO TO 24
		 END IF
22	      CONTINUE
C
C  INTERPOLATE BETWEEN LOWEST AND HIGHEST LEVELS ABOVE THE
C  SURFACE FOR GETTING DEVIATIONS.
C
24	      UU = USIG(JDOP,LBOT(JDOP))
	      VV = VSIG(JDOP,LBOT(JDOP))
	      H0 = ZSIGL(JDOP,LBOT(JDOP))
              UTOP = USIG(JDOP,NLVL)
              VTOP = VSIG(JDOP,NLVL)
              ZTOP = ZSIGL(JDOP,NLVL)
              DDOPU(JDOP,NLVL)=0.0
              DDOPV(JDOP,NLVL)=0.0
	      OKSOND(JDOP,NLVL)=.TRUE.
	      OKSOND(JDOP,LBOT(JDOP))=.TRUE.
              DO 38 LL = 2,NLVL-1
                 IF (LL .GT. LBOT(JDOP)) THEN
                    ZZ = ZSIGL(JDOP,LL)
                    CALL LGNTRP(UU,H0,ZTOP,ZZ,U0,UTOP)
                    CALL LGNTRP(VV,H0,ZTOP,ZZ,V0,VTOP)
C
C  GET DEVIATIONS FROM LOG INTERPOLATED VALUE FOR THIS LEVEL
C
                    DDOPU(JDOP,LL) = USIG(JDOP,LL)-UU
                    DDOPV(JDOP,LL) = VSIG(JDOP,LL)-VV
	            OKSOND(JDOP,LL)=.TRUE.
                 ELSE
                    DDOPU(JDOP,LL)=0.0
                    DDOPV(JDOP,LL)=0.0
	            IF (LL.NE.LBOT(JDOP)) OKSOND(JDOP,LL)=.FALSE.
                 END IF
38            CONTINUE
50         CONTINUE	   
	END IF
C
C  GET LOG PROFILES AT EACH GRID POINT-- FROM 1ST ABOVE-GROUND LEVEL.
C  THEN ADD DEVIATION FROM LOG AS DETERMINED FROM HORIZONTAL 
C  INTERPOLATION BETWEEN SOUNDINGS
C
	NEVENT=0
        DO 100 IX = 1,NCOL
	   XHERE=FLOAT(IX)
           DO 90 IY = 1,NROW
	      YHERE=FLOAT(IY)
              UTOP = U(IX,IY,NLVL)
              VTOP = V(IX,IY,NLVL)
              ZTOP = RHS(IX,IY,NLVL)
              H0 = 10.0
              U0 = U(IX,IY,1)
              V0 = V(IX,IY,1)
	      DO 80 LL=LEVBOT(IX,IY),NLVL-1
C
C  GET COMPONENTS FROM LOG LINEAR INTERPOLATION BETWEEN TOP AND BOTTOM
C
                 ZZ=RHS(IX,IY,LL)
                 CALL LGNTRP(U(IX,IY,LL),H0,ZTOP,ZZ,U0,UTOP)
                 CALL LGNTRP(V(IX,IY,LL),H0,ZTOP,ZZ,V0,VTOP)
C
C  GET CORRECTION FOR THIS GRID POINT AND FLOW LEVEL
C
	         N4USE=0
	         DO 78 JDOP = 1,NUMDOP
C
		    IF (OKSOND(JDOP,LL)) THEN
	               N4USE=N4USE+1
		       DUTMP(N4USE)=DDOPU(JDOP,LL)
		       DVTMP(N4USE)=DDOPV(JDOP,LL)
		       XVAR(N4USE)=XDOP(JDOP)
		       YVAR(N4USE)=YDOP(JDOP)
		     END IF
78	          CONTINUE
C
C  IF THIS GRID PT. IS BELOW THE BOTTOM FLOW SFC FOR ALL SOUNDINGS, WE 
C  SET THE DEVIATION TO 0 AND USE THE INTERPOLATED VALUE
C
	          IF (N4USE.LE.0) THEN
		     NEVENT=NEVENT+1
		     DU=0.0
	             DV=0.0
		  ELSE
	             CALL RINVMOD(DU,XHERE,YHERE,XVAR,YVAR,
     $                             N4USE,DUTMP)
	             CALL RINVMOD(DV,XHERE,YHERE,XVAR,YVAR,
     $                             N4USE,DVTMP)
		  END IF
C
C  CHECK FOR INTERPOLATED SOND DATA AND USE IT TO CORRECT  THE
C  LOG PROFILE.I IF NO OBS ON THIS FLOW SFC, USE THE VALUES ALREADY
C  INTERPOLATED.
C
                  U(IX,IY,LL)=DU+U(IX,IY,LL)
                  V(IX,IY,LL)=DV+V(IX,IY,LL)
C              
80             CONTINUE
90	   CONTINUE
100	CONTINUE
C
C  INTRODUCE INFLUECE OF OBSERVED SURFACE WINDS ON LOWEST LAYER ALOFT 
C  BY INTERPOLATING BETWEEN ANEMOMETER HT. AND 2ND LOWEST SFC.TO 
C  OBTAIN WIND ON THE LOWEST ABOVE GROUND SURFACE.   IF ONLY THE TOP
C  SFC IS ABOVE GROUND, EXTRAPOLATE UP FROM SFC.   
C
	DO 200 IX=1,NCOL
	   DO 190 IY=1,NROW
C
	      IF (LEVBOT(IX,IY).LT.NLVL) THEN
	         U0=U(IX,IY,1)
	         V0=V(IX,IY,1)
	         H0=Z10
		 UTOP=U(IX,IY,LEVBOT(IX,IY)+1)
		 VTOP=V(IX,IY,LEVBOT(IX,IY)+1)
		 ZTOP=RHS(IX,IY,LEVBOT(IX,IY)+1)
		 ZZ=RHS(IX,IY,LEVBOT(IX,IY))
                 CALL LGNTRP(UU,H0,ZTOP,ZZ,U0,UTOP)
                 CALL LGNTRP(VV,H0,ZTOP,ZZ,V0,VTOP)
		 U(IX,IY,LEVBOT(IX,IY))=UU
		 V(IX,IY,LEVBOT(IX,IY))=VV
	      ELSE
		 U0=0.0
		 V0=0.0
		 H0=Z0
		 UTOP=U(IX,IY,1)
		 VTOP=V(IX,IY,1)
		 ZTOP=Z10
		 ZZ=RHS(IX,IY,NLVL)
                 CALL LGNTRP(UU,H0,ZTOP,ZZ,U0,UTOP)
                 CALL LGNTRP(VV,H0,ZTOP,ZZ,V0,VTOP)
		 U(IX,IY,LEVBOT(IX,IY))=UU
		 V(IX,IY,LEVBOT(IX,IY))=VV
	      END IF
190	   CONTINUE
200	CONTINUE
C
        RETURN
C
        END
