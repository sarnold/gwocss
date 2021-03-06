C********************************************************************
        SUBROUTINE SFCTRP(NCALL)
C********************************************************************
C
C  THIS SUBROUTINE GETS FIRST ESTIMATE OF SELECTED MET VARIABLES
C  AT LOWEST GRID POINTS. USES INVERSE DISTANCE-SQUARED WHEN FALSE.
C
C   THIS VERSION FLUDWIG 3/2002
C
        INCLUDE 'NGRIDS.PAR'
C
        INCLUDE 'ANCHOR.CMM'
        INCLUDE 'FLOWER.CMM'
        INCLUDE 'LIMITS.CMM'
        INCLUDE 'STALOC.CMM'
C
	REAL UOB(NSITES),VOB(NSITES),XVAL(NSITES),YVAL(NSITES)
C
	SAVE
C
        DATA ZERO /0.0/
C
C  FIRST, GET A VALUE FOR EACH X,Y GRID POINT.
C
C  INTERPOLATE TO GET VALUES AT 10 M U(IX,IY,1) & V(IX,IY,1)
C  ABOVE EACH GRID POINT ON 1ST CALL
C
	IF (NCALL .LE.1) THEN
C
C*********BUG FIX WHEN MULTIPLE CASES RUN*****1/2002********
C  FLOW SURFACE HEIGHTS MUST BE RESET TO TERRAIN-FOLLOWING ON 1ST
C  CALL TO AVOID NEGATIVE VALUES LEFT OVER FROM PRECEDING CALCULATIONS
C
	   ZRISE=SFCHI-SFCLOW
	   RELHT=AVTHK
C
C  GET HEIGHT OF EACH 1ST GUESS SURFACE RELATIVE TO TERRAIN FOR EACH 
C  GRID PT. CHANGE IN HT RELATIVE TO THE LOWEST HT (MSL) IS ASSUMED 
C  PROPORTIONAL TO SIGMA FOR THAT SFC.
C
	   DO 67 JY=1,NROW
	      DO 66 IX=1,NCOL
                 DO 65 KZ=1,NLVL
		    IF (KZ.EQ.1) THEN
	               RHS(IX,JY,KZ) = Z10
		    ELSE
	               RHS(IX,JY,KZ) =SIGMA(KZ)*AVTHK- 
     $                   (SFCHT(IX,JY)-SFCLOW)*(1.0-SLFAC)
		    END IF
C
     	            IF (RHS(IX,JY,KZ) .LE. 0.0) THEN
		       WRITE (*,*) 'BAD TERRAIN-FOLLOWING IN SFCTRP'
		      
		       STOP
		    END IF
65               CONTINUE
66            CONTINUE
67	   CONTINUE
C
C*********END BUG FIX WHEN MULTIPLE CASES RUN*************
C
C  INTERPOLATING WIND COMPONENTS BETWEEN SURFACE OBSERVATIONS.
C
	   NUMTRU=0
	   DO 80 IOB=1,NUMNWS
	      IF (UCOMP(IOB).GT.-9998.9) THEN
	         NUMTRU=NUMTRU+1
	         UOB(NUMTRU)=UCOMP(IOB)
	         VOB(NUMTRU)=VCOMP(IOB)
	         XVAL(NUMTRU)=XG(IOB)
	         YVAL(NUMTRU)=YG(IOB)
	      END IF	
80	   CONTINUE
C
C  NOW ASSIGN INTERPOLATED VALUES TO LEVEL 1
C
	   DO 124 IY=1,NROW
	      Y2=FLOAT(IY)
	      DO 122 IX=1,NCOL
	         X2=FLOAT(IX)
	         CALL RINVMOD(TRPVAL,X2,Y2,XVAL,YVAL,NUMTRU,UOB)
		 U(IX,IY,1)=TRPVAL
	         CALL RINVMOD(TRPVAL,X2,Y2,XVAL,YVAL,NUMTRU,VOB)
		 V(IX,IY,1)=TRPVAL
	         LEVBOT(IX,IY)=2
C
C  ON 1ST CALL EXTRAPOLATE OR INTERPOLATE TO NEXT SURFACE
C
                  CALL LGNTRP(U(IX,IY,2),Z0,Z10,
     $                    RHS(IX,IY,2),ZERO,U(IX,IY,1))
                  CALL LGNTRP(V(IX,IY,2),Z0,Z10,
     $                    RHS(IX,IY,2),ZERO,V(IX,IY,1))
122	      CONTINUE
C
124	   CONTINUE
C
	ELSE
C
C  ON SECOND CALL USE VALUES FROM 1ST CALL TO 
C  DETERMINE COMPONENTS AT 1ST ABOVE GROUND LEVEL
C
	   DO 150 IY=1,NROW
              DO 148 IX=1,NCOL
C
C  NOW SET SUBSFC VALUES TO ZERO AND INTER(EXTRA)POLATE TO 
C  LOWEST ABOVE-GROUND FLOW SURFACE.
C
	         IF (LEVBOT(IX,IY).GT.2) THEN
                    DO 145 L=2,LEVBOT(IX,IY)-1
C
                       U(IX,IY,L)=0.0
                       V(IX,IY,L)=0.0
145                 CONTINUE
		 END IF
C
                 UU =U(IX,IY,1)
                 VV =V(IX,IY,1)
                 CALL LGNTRP(U(IX,IY,LEVBOT(IX,IY)),Z0,Z10,
     $                             RHS(IX,IY,LEVBOT(IX,IY)),ZERO,UU)
                 CALL LGNTRP(V(IX,IY,LEVBOT(IX,IY)),Z0,Z10,
     $                             RHS(IX,IY,LEVBOT(IX,IY)),ZERO,VV)
148	      CONTINUE
150	   CONTINUE
	END IF
C
        RETURN
C
        END
C
********************************************************************
	SUBROUTINE VRSMOO(VAL,VALTRP,NUMBER)
C*******************************************************************
C  
C  THIS PROGRAM INTERPOLATES TO FIND VALUES (VALTRP) AT GRID POINTS
C  FROM OBSERVED VALUES (VAL)
C
C		FLUDWIG, OCT 97
C  THIS VERSION USES SIMPLE INVERSE DISTANCE SQUARED WEIGHTING SO THAT
C  THOSE PARAMETERS LIKE ALTIMETER SETTING AND POTENTIAL TEMPERATURE
C  WHICH ARE NOT EXPECTED TO HAVE VERY SHARP HORIZONTAL GRADIENTS WILL
C  BE SMOOTHED.  PRESSURE OBSERVATIONS SEEMED SUFFICIENTLY UNRELIABLE
C  THAT SMOOTHING WAS DEEMED DESIRABLE.
C
C       FLUDWIG,  6/2002
C
C
C  XG,YG,VAL	COORDINATES (GRID UNITS) & VALUE AT OBSERVING SITES
C  VAL		OBSERVED VARIABLE VALUES
C  XVAL,YVAL	COORDINATES NORMALIZED FOR MQ INTERPOLATION
C  VALTRP	INTERPOLATED VALUES AT GRID POINTS
C  NUMBER	NUMBER OF OBSERVATIONS
C  
        INCLUDE 'NGRIDS.PAR'
C
        INCLUDE 'LIMITS.CMM'
        INCLUDE 'STALOC.CMM'
C
	REAL VAL(NSITES),VALTRP(NXGRD,NYGRD)
	SAVE
C
C BEGIN LOOP S THROUGH GRID POINTS
C
	DO 370 IX=1,NCOL
	   X2=FLOAT(IX)
	   DO 365 IY=1,NROW
	      Y2=FLOAT(IY)
	      NUMTRU=0
	      SUM=0.0
	      SUMWT=0.0
	      DO 355 IS=1,NUMBER
C
C CHECK THAT DATA ARE GOOD
C
	         IF (VAL(IS).GT.-9998.9) THEN
		    WEIGHT=WNDWT(X2,Y2,XG(IS),YG(IS))
		    SUMWT=SUMWT+WEIGHT
		    SUM=SUM+WEIGHT*VAL(IS)
		 END IF
355	      CONTINUE
	      IF (SUMWT .GT. 0.0 ) THEN
	         VALTRP(IX,IY)=SUM/SUMWT
	      ELSE
	      	 WRITE (*,*) ' NO GOOD PRESSURE OR TEMP OBS IN VRSMOO'
		 WRITE (*,*) 'RETURN TO QUIT'
		 PAUSE
		 STOP
	      END IF
365	   CONTINUE
370	CONTINUE
C
	RETURN
C
	END
C
********************************************************************
	SUBROUTINE VRSDIS(VAL,VALTRP,NUMBER)
C*******************************************************************
C  
C  THIS PROGRAM INTERPOLATES TO FIND VALUES (VALTRP) AT GRID POINTS
C  FROM OBSERVED VALUES (VAL)
C
C		FLUDWIG, OCT 97
C
C
C  MODIFIED TO USE INPUT VALUE WHEN WITHIN 0.5*SQRT(2) GRID UNITS
C  OR INVERSE DISTANCE POLYNOMIAL FIT BASED ON NEAREST OBSERVATIONS
C  OTHERWISE  --- RINVMOD (TRPVAL,X0,Y0,XX,YY,NOBS,VARBL)
C 
C
C       FLUDWIG,  7/2002
C
C
C  XG,YG,VAL	COORDINATES (GRID UNITS) & VALUE AT OBSERVING SITES
C  VALTRP	INTERPOLATED VALUES AT GRID POINTS
C  NUMBER	NUMBER OF OBSERVATIONS
C  
        INCLUDE 'NGRIDS.PAR'
C
        INCLUDE 'LIMITS.CMM'
        INCLUDE 'STALOC.CMM'
C
	REAL VAL(NSITES),VALTRP(NXGRD,NYGRD)
	REAL VARBL(NSITES),XVAL(NSITES),YVAL(NSITES)
C
	SAVE
C
C CHECK THAT DATA ARE GOOD
C	
	WRITE (*,*) NUMBER,(NINT(100.0*VAL(IOB)),IOB=1,NUMBER)
C
	IF (NUMBER.LE.0) THEN
	   WRITE(*,*) 'BAD OBSERVED DATA'
	   PAUSE
	   STOP
	ELSE
C
C BEGIN LOOP S THROUGH GRID POINTS
C
	   DO 370 IY=1,NROW
	      Y2=FLOAT(IY)
	      DO 365 IX=1,NCOL
	         X2=FLOAT(IX)
	         CALL RINVMOD(TRPVAL,X2,Y2,XVAL,YVAL,NUMTRU,VARBL)
		 VALTRP(IX,IY)=TRPVAL
365	      CONTINUE
	      WRITE (*,*) IY,(NINT(100.0*VALTRP(JX,IY)),JX=20,40)
370	   CONTINUE
	END IF
C
	RETURN
C
	END
C**********************************************************************
        REAL FUNCTION SLOPER(HERE,SFCMIN,HIRISE)
C**********************************************************************
C
C  DETERMINES RATIO OF HEIGHT ABOVE LOWEST TOPOGRAPHY TO MAXIMUM
C  HEIGHT ABOVE LOWEST POINT. OTHER RELATIONSHIPS CAN BE SUBSTITUTED
C  TO GIVE DIFFERENT FLOW SURFACE HEIGHTS.  -- LUDWIG 11/87
C
        IF ((HIRISE-SFCMIN) .EQ. 0.0 .OR. HIRISE .EQ. 0.0) THEN
C
C  FLAT TERRAIN ALWAYS GIVES FLAT SFCS
C
           SLOPER =0.0
        ELSE
C
C  SFC RISE AT THIS PT PROPORTIONAL TO TERRAIN INCREMENT AS A FRACTION 
C  OF MAXIMUM TERRAIN ELEVATION DIFFERENCES.
C
           SLOPER = (HERE-SFCMIN)/HIRISE
        END IF
C
        RETURN
        END

