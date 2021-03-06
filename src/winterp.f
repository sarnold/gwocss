C*********************************************************************
        SUBROUTINE TOPWND
C*********************************************************************
C
C  INTERPOLATES WINDS AT TOPMOST LEVEL BETWEEN OBSERVATION PTS--WHEN
C  ONLY ONE WIND AVAILABLE IT'S USED EVERYWHERE. LUDWIG, NOVEMBER,1987.
C
	INCLUDE 'NGRIDS.PAR'
       
C
       	INCLUDE 'FLOWER.CMM'
     	INCLUDE 'LIMITS.CMM'
	INCLUDE 'STALOC.CMM'
C
        DIMENSION UU(NWSITE),VV(NWSITE)
C
C  USE THE ONE WIND AVAILABLE EVERYWHERE
C
        IF (NUMDOP.EQ.1) THEN
          UU(1)=USIG(1,NLVL)
          VV(1)=VSIG(1,NLVL)
          DO 25 I = 1,NCOL
            DO 25 J = 1,NROW
              U(I,J,NLVL)=UU(1)
              V(I,J,NLVL)=VV(1)
25        CONTINUE
        ELSE
          DO 30 I=1,NUMDOP
            UU(I)=USIG(I,NLVL)
            VV(I)=VSIG(I,NLVL)
30        CONTINUE
C
          DO 65 J = 1,NROW
	    XX=FLOAT(J)
	    DO 60 I = 1,NCOL
	      YY=FLOAT(I)
	      SUMDOP=0.0
              U(I,J,NLVL)=0.0
              V(I,J,NLVL)=0.0
              DO 50 IK=1,NUMDOP
C
C  FOLLOWING STATEMENT CHANGED [ FROM IT=IDOP(JK) ] BY FLL 5/24/2000
C  BUG FOUND BY DOUG MILLER OF THE NAVAL POSTGRADUATE SCHOOL.  IT
C  APPEARS TO AFFECT ONLY RESULTS OBTAINED WHEN MORE THAN ONE
C  SOUNDING IS AVAILABLE.
C
                   IT=IK
		   DWATE=WNDWT(XX,YY,XDOP(IT),YDOP(IT))
		   SUMDOP=SUMDOP+DWATE
                   U(I,J,NLVL)=U(I,J,NLVL)+DWATE*UU(IT)
                   V(I,J,NLVL)=V(I,J,NLVL)+DWATE*VV(IT)
50		CONTINUE
		IF (SUMDOP.GT.0.0) THEN
                   U(I,J,NLVL)=U(I,J,NLVL)/SUMDOP
                   V(I,J,NLVL)=V(I,J,NLVL)/SUMDOP
		ELSE
		   WRITE (*,*) 'NO TOP WINDS'
		   STOP
		END IF
60          CONTINUE
C
65	  CONTINUE
        ENDIF
C
        RETURN
C
        END
C
C*********************************************************************
        SUBROUTINE TSTWND( CHMMDDTTTT)
C*********************************************************************
C
C  USES LEVWND TO INTERPOLATE MASS ADJUSTED FIELD TO ANEMOMETER 
C  HEIGHT (Z10, FOR INDEX=1) & NFLAT FLAT PLANES (FOR Z INDICES 2-6) 
C  SET AT THE HEIGHTS  ZCHOOZ ABOVE THE LOWEST TERRAIN GRID POINT IN 
C  THE COARSE GRID, AND TO CONVERT INTERPOLATED WINDS BACK TO 
C  METEOROLOGICAL SPEEDS AND ANGLES, THAT CAN BE PLOTTED IF DESIRED.  
C  
C   LUDWIG--FEB 2000
C
          INCLUDE 'NGRIDS.PAR'
        
C
      	PARAMETER(RAD2D=180./3.14159,ZERO=0.0,NMAX=200)
	PARAMETER (VALMIS=-9999.0)
C
	INCLUDE 'ANCHOR.CMM'
	INCLUDE 'FLOWER.CMM'
	INCLUDE 'LIMITS.CMM'
        INCLUDE 'STALOC.CMM'
C
	INTEGER NCALLS
	CHARACTER*8 CHMMDDTTTT
C
C  INTERPOLATES MASS ADJUSTED FIELD TO ANEMOMETER HEIGHT (Z10, FOR 
C  INDEX=1) THIS SUBROUTINE ALSO CONVERTS INTERPOLATED WINDS BACK TO 
C  METEOROLOGICAL SPEEDS AND ANGLES, THAT CAN BE PLOTTED IF DESIRED.  
C      LUDWIG--JANUARY 1988
C
C  REVISED FROM LEVWND MARCH 1997 TO JUST GET SFC LEVEL WINDS AT 
C  SPECIFIED GRID POINTS SO THAT THEY CAN BE COMPARED WITH THE 
C  OBSERVATIONS THAT WERE NOT USED IN CALCULATING THE WINDS.
C
C  MAKE SURE EVERYTHING IS STILL HERE ON SUBSEQUENT CALLS
C
	DATA NCALLS /0/
C
	SAVE
C		
	CALL LEVWND
C
C  FOR CHECKING, WE WILL COMPARE OBSERVATIONS WITH NEAREST GRID VALUES
C  FOR STATIONS ON GRID
C
	KASE=0
C	IF (NCALLS .EQ.0) THEN
C	   NCALLS=1
C	   WRITE (33,6001)
C	END IF
	DO 75 IT=1,NUMNWS
C
C  GETTING NEAREST GRID POINT FOR EACH OBS
C
	   KLX=NINT(XG(IT))
           KLY=NINT(YG(IT))
C
C  SKIP IF OUTSIDE CALCULATION GRID, OR OBSERVATION WAS MISSING
C
	   IF (KLX.GT.0 .AND. KLY.GT.0 .AND.
     $		KLX.LE.NCOL .AND. KLY.LE.NROW .AND.
     $                  NINT(UCOMP(IT)) .NE. -9999) THEN
     	      KASE=KASE+1
	      DIFDST=DSCRS*SQRT((FLOAT(KLX)-XG(IT))**2+
     $                    (FLOAT(KLY)-YG(IT))**2)
	      ZTST=SFCHT(KLX,KLY)
C
C CONVERTING COMPONENTS BACK TO SPD & DIRECTION FOR OBS 
C
              WSOB=SP(UCOMP(IT),VCOMP(IT))
              WDOB=DD(UCOMP(IT),VCOMP(IT))
C
C  GETTING CALCULATED WINDS AT Z10 HT  
C
	      ULXLY=0.01*FLOAT(IUGRAF(KLX,KLY,1))
	      VLXLY=0.01*FLOAT(IVGRAF(KLX,KLY,1))
              WSTST=SP(ULXLY,VLXLY)
              WDTST=DD(ULXLY,VLXLY)
C
C  IF OBSERVED WIND WAS CALM DIRECTION DIFFERENCE IS UNDEFINED
C
	      IF (WSOB .GT. 0.0) THEN
	         DELDIR=DEGDIF(WDOB,WDTST)
	      ELSE
	         DELDIR=-999.
	      END IF
C	      WRITE(33,6002)IT,CHSTID(IT),WSOB,WSTST,WDOB,WDTST,
C     $            WSOB-WSTST,DELDIR,DIFDST,XG(IT),YG(IT),CHMMDDTTTT
	   END IF
75   	CONTINUE
C
6001	FORMAT ('  NUM  ID        SDPOB    SPDWOX  DIROB    DIRWOX ',
     $       '    SPDIF   DIRDIF   DISTDIF  XKM    YKM     DATE')
6002	FORMAT(1X,I4,1X,A5,2X,6F9.2,3F7.2,4X,A8)
C
      	RETURN
C
      	END

