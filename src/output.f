C********************************************************************
	SUBROUTINE PUTOUT(CHDDHR,CHFNAM,MINJUL,NCALL)
C********************************************************************
C
C  WRITES OUTPUT FILES IN CM/SEC BINARY INTEGER FORM (DOBIN=.TRUE.), 
C  ONE FILE FOR EACH LEVEL OR ASCII FORM (DOBIN=.FALSE) -- ALSO INTEGER 
C  CM/SEC.  IF ASCII, GRID POINTS MAY BE SKIPPED.  FOR NSKIP=1, ALL
C  VALUES ARE WRITTEN, NSKIP =2, EVERY SECOND ROW AND COLUMN ETC.
C
C  AS OF 2/02, THE OUTPUT CODE WAS REVISED TO BE IN A SEPARATE 
C  SUBROUTINE AND TO INCLUDE THE OPTION OF PROVIDING FILES THAT GIVE 
C  WIND PROFILES AT UP TO 10 SEPARATE LOCATIONS.
C
C	FLUDWIG, 2/02
C
	INCLUDE 'NGRIDS.PAR'
C
	INCLUDE 'ANCHOR.CMM'
	INCLUDE 'FLOWER.CMM'
	INCLUDE 'LIMITS.CMM'
	INCLUDE 'STALOC.CMM'
	INCLUDE 'TSONDS.CMM'
C
        CHARACTER*2  CHPRO(NHORIZ)
	CHARACTER*3  CHDIR,CHSPD,CHRIC
        CHARACTER*6  CHDDHR
	CHARACTER*12 CHFNAM
C
	INTEGER*4 NCALL,MINUTZ(111)
	INTEGER*4 IUTMP1(NXGRD,NYGRD),IVTMP1(NXGRD,NYGRD)
	INTEGER*4 IPTMP1(NXGRD,NYGRD),ITTMP1(NXGRD,NYGRD)
C
	LOGICAL DOTOPO
C
	SAVE
C
	DATA DOTOPO /.TRUE./
	DATA CHPRO,CHDIR,CHSPD,CHRIC /'01','02','03','04','05','06',
     $            '07','08','09','10','11','12','13','14','15','16',
     $            '17','18','19','20','21','22','23','24','25','26',
     $            '27', '28','29','30','DIR','SPD',' RI'/
C
	IF (NCALL.GE.0) THEN
	   MINUTZ(NCALL)=MINJUL
C	   
	   IF (DOBIN) THEN
C
C  BINARY OUTPUT FILES -- EACH COMPONENT IN SEPARATE FILE
C
C
C  HORIZONTAL COMPONENTS (CM/S)
C
C	WRITE (*,*) CHPVEX//'U'//CHMESH//'KM.'//CHDDHR
C
	      OPEN(35,FILE='U'//CHMESH//'KM.'//CHDDHR,
     $	                   STATUS='UNKNOWN')
C
	      WRITE (35) IUGRAF  
	      CLOSE (35)
C
	      OPEN(35,FILE='V'//CHMESH//'KM.'//CHDDHR,
     $	                   STATUS='UNKNOWN')
	      WRITE (35) IVGRAF
	      CLOSE (35)
C
C  VERTICAL COMPONENT (CM/S)
C
	      IF (DOWCMP) THEN
	         OPEN(35,FILE='W'//CHMESH//'KM.'//CHDDHR,
     $	                   FORM='UNFORMATTED', STATUS='UNKNOWN')
C
	         WRITE (35) IWGRAF 
	         CLOSE (35) 
	      END IF
C
C  10*(POTENTIAL TEMPERATURE) K
C
	      IF (DOTHET) THEN
	         OPEN(35,FILE='PT'//CHMESH//'KM.'//CHDDHR,
     $	                   FORM='UNFORMATTED', STATUS='UNKNOWN')
C
	         WRITE (35) IPTGRF
		 CLOSE (35) 
	      END IF
C
C  PRESSURE (MB, HP)
C
	      IF (DOPRES) THEN
	         OPEN(35,FILE='PR'//CHMESH//'KM.'//CHDDHR,
     $	                   FORM='UNFORMATTED', STATUS='UNKNOWN')
C
	         WRITE (35) IPRGRF
		 CLOSE (35)
	      END IF
C
C  100*(BULK RICHARDSON NUMBER)
C
	      IF (DOBRI) THEN
	         OPEN(35,FILE='RI'//CHMESH//'KM.'//CHDDHR,
     $	                   FORM='UNFORMATTED', STATUS='UNKNOWN')
C
	         WRITE (35) IRNGRF
		 CLOSE (35)
	      END IF
C
	      IF (DOBVPD) THEN
	         OPEN(35,FILE='BV'//CHMESH//'KM.'//CHDDHR,
     $	                   FORM='UNFORMATTED', STATUS='UNKNOWN')
C
	         WRITE (35) IBVGRF
		 CLOSE (35)
	      END IF
	   ELSE
C
C  ASCII OUTPUT FILES
C
	      IF (.NOT.DOWVSZ) THEN
C
C
C  GETTING FIELD OF OBSERVED U,V PRESS AND THETA -- 0 WHERE NO OBS
C
		 CALL SETINT(0,IUTMP1,NXGRD,NYGRD)
		 CALL SETINT(0,IVTMP1,NXGRD,NYGRD)
		 CALL SETINT(0,IPTMP1,NXGRD,NYGRD)
		 CALL SETINT(0,ITTMP1,NXGRD,NYGRD)
C
C  FILL IN OBS WHERE AVAILABLE
C
		 DO 115 IOB=1,NUMNWS
		    IF (NINT(UCOMP(IOB)) .NE. -9999) THEN
		       KX=NINT(XG(IOB))
		       KY=NINT(YG(IOB))
		       IF (KX.GT.0 .AND. KX.LE. NXGRD 
     $                      .AND. KY.GT.0 .AND. KY.LE. NYGRD) THEN
		          IUTMP1(KX,KY)=NINT(100.0*UCOMP(IOB))
		          IVTMP1(KX,KY)=NINT(100.0*VCOMP(IOB))
		       END IF
		    END IF
		    IF (NINT(TEMPC(IOB)).NE.-9999) THEN
		       KX=NINT(XG(IOB))
		       KY=NINT(YG(IOB))
		       IF (KX.GT.0 .AND. KX.LE. NXGRD 
     $                      .AND. KY.GT.0 .AND. KY.LE. NYGRD) THEN
		          IF (NINT(ALTIM(IOB)) .NE. -9999) THEN
			     PPP=CVT2P(ALTIM(IOB),SFCHT(KX,KY))
		          ELSE
			     PPP=FLOAT(IPRGRF(KX,KY,1))
			  END IF
		          TTT=TEMPC(IOB)
		          ITTMP1(KX,KY)=NINT(10.0*TPOT (PPP,TTT))
		       END IF
		    END IF
		    IF (NINT(ALTIM(IOB)).NE.-9999) THEN
		       KX=NINT(XG(IOB))
		       KY=NINT(YG(IOB))
		       IF (KX.GT.0 .AND. KX.LE. NXGRD
     $                      .AND. KY.GT.0 .AND. KY.LE. NYGRD) THEN
		          IPTMP1(KX,KY)=
     $                         NINT(CVT2P(ALTIM(IOB),SFCHT(KX,KY)))
		       END IF
		    END IF
115		 CONTINUE
C
C  THE FOLLOWING CODE IS DISABLED.  IT IS USED TO OUTPUT INPUT 
C  VALUES FOR COMPARISON WITH THE ANALYSIS
C***************************
	DOOBS=.FALSE.
	         IF (DOOBS) THEN
		    WRITE (*,*) CHPVEX//'UFOBS'//CHMESH//'KM-ALLZ.'//
     $	                 CHDDHR
C
	            OPEN (50,FILE='UFOBS'//CHMESH//'KM-ALLZ.'//
     $	                 CHDDHR,FORM='FORMATTED',STATUS='UNKNOWN')
C
	            OPEN (51,FILE='VFOBS'//CHMESH//'KM-ALLZ.'//
     $	                CHDDHR,FORM='FORMATTED',STATUS='UNKNOWN')
C
                    OPEN(40,FILE='PTOBS'//CHMESH//'KM-ALLZ.'//
     $	                 CHDDHR,FORM='FORMATTED',STATUS='UNKNOWN')
C
                    OPEN(41,FILE='PROBS'//CHMESH//'KM-ALLZ.'//
     $	                CHDDHR,FORM='FORMATTED',STATUS='UNKNOWN')
C
	            DO 68 IY=NASCY0,NASCY0-1+NRYTY,NSKIP
C
	               WRITE(50,6008) (IUTMP1(IX,IY),
     $                         IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
                       WRITE(51,6008) (IVTMP1(IX,IY),
     $                         IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
                       WRITE(40,6008) (ITTMP1(IX,IY),
     $                         IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
                       WRITE(41,6008) (IPTMP1(IX,IY),
     $                         IX=NASCX0,NASCX0-1+NRYTX,NSKIP) 
68	            CONTINUE
	         END IF
C
C***************************
C
	         CLOSE (40)
	         CLOSE (41)
	         CLOSE (50)
	         CLOSE (51)
C
C  WRITE TOPOGRAPHY AND GRIDDED OBSERVATIONS FOR THIS OUTPUT SET.
C  NORTHENMOST ROWS WRITTEN FIRST FOR PLOTTING PUPOSES WITH TRANSFORM.
C  
C
	         WRITE(*,*) DOTOPO
	         IF (DOTOPO) THEN
C
C	            WRITE (*,*) CHPVEX//'LOCLTOPO'//CHMESH//'KM.DAT'
C
	            OPEN(31,FILE=CHPVEX//'LOCLTOPO'//CHMESH//'KM.DAT',
     $                   STATUS='UNKNOWN')
C                       
	            DO 168 IY=NASCY0-1+NRYTY,NASCY0,-NSKIP
	               WRITE(31,6008) (NINT (SFCHT(IX,IY)),
     $                       IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
168	            CONTINUE
	            CLOSE (31)
	            DOTOPO=.FALSE.
	         END IF
C
C  IF NOT WRITING ASCII WIND PROFILE FILES, WRITE COMPONENTS FOR
C  EACH LEVEL AT EACH TIME.  WRITE TOPOGRAPHY AND GRIDDED OBSERVATIONS 
C  FOR THIS OUTPUT SET.  NORTHENMOST ROWS WRITTEN FIRST FOR PLOTTING 
C  PUPOSES WITH TRANSFORM.
C
C
	         OPEN (46,FILE=CHPVEX//'UF'//
     $	               CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $                   STATUS='UNKNOWN')
C
	         OPEN (47,FILE=CHPVEX//'VF'//
     $	                 CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $                   STATUS='UNKNOWN')
C
	         IF (DOWCMP) THEN
                    OPEN (35,FILE=CHPVEX//'WF'//
     $                   CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $	                  STATUS='UNKNOWN')
                 END IF
                                       
	         IF (DOTHET) THEN
                    OPEN (36,FILE=CHPVEX//'PT'//
     $	                 CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $                   STATUS='UNKNOWN')
                 END IF
C
	         IF (DOPRES) THEN
                    OPEN (37,FILE=CHPVEX//'PR'//
     $	                 CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $                   STATUS='UNKNOWN')
                 END IF
C
	         IF (DOBRI) THEN
	            OPEN (38,FILE=CHPVEX//'RIF'//
     $                   CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $	                 STATUS='UNKNOWN')
                 END IF

	         IF (DOBVPD) THEN
                    OPEN (39,FILE=CHPVEX//'BV'//
     $                   CHMESH//'KM-ALLZ.'//CHDDHR,FORM='FORMATTED',
     $	                 STATUS='UNKNOWN')
                 END IF
C
	         DO 195 IZ=1,NFLAT
C
	            DO 185 IY=NASCY0-1+NRYTY,NASCY0,-NSKIP
C
		       WRITE(46,6008) (IUGRAF(IX,IY,IZ),
     $                       IX=NASCX0,NASCX0-1+NRYTX,NSKIP)                          
		       WRITE(47,6008) (IVGRAF(IX,IY,IZ),
     $                       IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
C
		       IF (DOWCMP) WRITE(35,6008) (IWGRAF(IX,IY,IZ), 
     $                       IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
C
		       IF (DOTHET) WRITE(36,6008) (IPTGRF(IX,IY,IZ),
     $                         IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
C
		       IF (DOPRES) WRITE(37,6008) (IPRGRF(IX,IY,IZ),
     $                          IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
C
		       IF (DOBRI) WRITE(38,6008) (IRNGRF(IX,IY,IZ),
     $                          IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
C
		       IF (DOBVPD) WRITE(39,6008) (IBVGRF(IX,IY,IZ),
     $                          IX=NASCX0,NASCX0-1+NRYTX,NSKIP)
C
185	            CONTINUE
195	         CONTINUE
	         CLOSE (46)
	         CLOSE (47)
	         IF (DOWCMP) CLOSE (35)
	         IF (DOTHET) CLOSE (36)
	         IF (DOPRES) CLOSE (37)
	         IF (DOBRI)  CLOSE (38)
	         IF (DOBVPD) CLOSE (39)
C
	      ELSE
C
C  FILL ARRAYS FOR PROFILE  FILES
C
	         DO 150 IP=1,NPFYLS
		    IPX=JPRYLX(IP)
		    IPY=JPRYLY(IP)
		    DO 140 LL=1,NFLAT
		       IUPRF(IP,LL,NCALL)=IUGRAF(IPX,IPY,LL)
		       IVPRF(IP,LL,NCALL)=IVGRAF(IPX,IPY,LL)
		       RIPRF(IP,LL,NCALL)=FLOAT(IRNGRF(IPX,IPY,LL))                       
140		    CONTINUE
150	         CONTINUE
C	         
	      END IF
C	         
	   END IF
	ELSE
C*************DISABLED CODE**************
C   IF DOING WIND PROFILES, WE ARE DONE CALCULATING AND STORING, NOW 
C   WRITE  
C
	   DO 175 IP=1,NPFYLS
	      OPEN(46,FILE=CHPVEX//'WNDPROF'//CHPRO(IP),
     $              FORM='FORMATTED', STATUS='UNKNOWN')
C
C  WRITE WIND PROFILES (ROW) VS TIME (COL)
C
     	      WRITE (46,6004) (CHDIR,CHPRO(II),CHSPD,
     $                    CHPRO(II),CHRIC,CHPRO(II),II=1,-NCALL)
     	      DO 170 IZ=1,NFLAT
	         WRITE (46,6006) ZCHOOZ(IZ),
     $	            (DD(FLOAT(IUPRF(IP,IZ,IT)),FLOAT(IVPRF(IP,IZ,IT))),
     $               0.01*SP(FLOAT(IUPRF(IP,IZ,IT)),
     $               FLOAT(IVPRF(IP,IZ,IT))),
     $               1000.*RIPRF(IP,IZ,IT),IT=1,-NCALL)
170	      CONTINUE
175	   CONTINUE
	   CLOSE (46)
C
C  WRITE WIND TIME SERIES (COL) VS HEIGHT (ROW)
C
	   DO 275 IP=1,NPFYLS
	      OPEN(47,FILE=CHPVEX//'WNDTSER'// CHPRO(IP),
     $             FORM='FORMATTED', STATUS='UNKNOWN')
     	      WRITE (47,6005) (CHDIR,CHPRO(II),
     $                   CHSPD,CHPRO(II),CHRIC,CHPRO(II),II=1,NFLAT)
	      
     	      DO 270 IT=1,-NCALL
	         WRITE (47,6007) MINUTZ(IT),
     $	           (DD(FLOAT(IUPRF(IP,IZ,IT)),FLOAT(IVPRF(IP,IZ,IT))),
     $              0.01*SP(FLOAT(IUPRF(IP,IZ,IT)),
     $                          FLOAT(IVPRF(IP,IZ,IT))),
     $                              1000.*RIPRF(IP,IZ,IT),IZ=1,NFLAT)
270	      CONTINUE
275	   CONTINUE
	   CLOSE (47)
C*******************END DISABLED CODE*************************
	END IF
C
	WRITE(*,*) ' FINISHED ',CHFNAM
C
	CLOSE (12)
C
6004	FORMAT (1X,'  MSL ',55(1X,A3,A2,1X,A3,A2,1X,A3,A2))
6005	FORMAT (1X,'   MIN  ',55(1X,A3,A2,1X,A3,A2,1X,A3,A2))
6006	FORMAT (1X,F6.0,55(F6.0,2F6.1))
6007	FORMAT (1X,I8,55(F6.0,2F6.1))
6008	FORMAT (1X,111I6)
C
	RETURN
C
	END

