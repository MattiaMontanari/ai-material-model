      subroutine umat47v(cm,d1,d2,d3,d4,d5,d6,sig1,sig2,
     . sig3,sig4,sig5,sig6,epsps,hsvs,lft,llt,dt1siz,capa,
     . etype,tt,temps,failels,nlqa,crv,nnpcrv,cma,qmat,elsizv,idelev,
     . reject)
c
c******************************************************************
c|  Livermore Software Technology Corporation  (LSTC)             |
c|  ------------------------------------------------------------  |
c|  Copyright 1987-2008 Livermore Software Tech. Corp             |
c|  All rights reserved                                           |
c******************************************************************
c
      include 'nlqparm'
      include 'nhisparm.inc'
      INCLUDE 'bk06.inc'           ! needed for ncycle
      INCLUDE 'iounits.inc'
c
c
      integer user_iform
      character*10 vendor
      common /usermat_vendor/ user_iform,vendor
      dimension d1(*),d2(*),d3(*),d4(*),d5(*),d6(*)
      dimension sig1(*),sig2(*),sig3(*),sig4(*),sig5(*),sig6(*)
      dimension cm(*),epsps(*),hsvs(nlq,*),dt1siz(*)
      dimension temps(*),crv(lq1,2,*),cma(*),qmat(nlq,3,3),elsizv(*)
      integer nnpcrv(*)
      integer*8 idelev(*)
      logical failels(*),reject
      character*5 etype
c
      REAL, dimension (:,:,:), allocatable :: Nweights
      REAL, dimension (:,:,:), allocatable :: a          ! a(nlq,4,20)
      REAL, dimension (:,:,:), allocatable :: z          ! z(nlq,4,21)
      REAL, dimension (:), allocatable :: Ninputreg
      REAL, dimension (:), allocatable :: Noutputreg
      REAL, dimension (:,:,:), allocatable :: Sweights
      REAL, dimension (:,:,:), allocatable :: a4          ! a(nlq,4,20)
      REAL, dimension (:,:,:), allocatable :: z4          ! z(nlq,4,21)
      REAL, dimension (:,:,:), allocatable :: a5          ! a(nlq,4,20)
      REAL, dimension (:,:,:), allocatable :: z5          ! z(nlq,4,21)
      REAL, dimension (:,:,:), allocatable :: a6          ! a(nlq,4,20)
      REAL, dimension (:,:,:), allocatable :: z6          ! z(nlq,4,21)
      REAL, dimension (:), allocatable :: Sinputreg
      REAL, dimension (:), allocatable :: Soutputreg
      INTEGER k,m,n,nh,nln,nls,nlv(8),naf(8),slv(8),saf(8)
c     
      !cm(1): Bulk modulus
      !cm(2): Shear modulus
      nln = INT(cm(3)) ! number of layers for normal stress response (max 8)
      nls = INT(cm(4)) ! number of layers for shear stress response (max 8)
      ! Network properties for normal response
      ! Units
      nlv(1) = INT(cm(9))  ! Units in layer 1 (input)
      nlv(2) = INT(cm(10)) ! Units in layer 2 
      nlv(3) = INT(cm(11)) ! Units in layer 3 
      nlv(4) = INT(cm(12)) ! Units in layer 4 
      nlv(5) = INT(cm(13)) ! Units in layer 5 
      nlv(6) = INT(cm(14)) ! Units in layer 6 
      nlv(7) = INT(cm(15)) ! Units in layer 7 
      nlv(8) = INT(cm(16)) ! Units in layer 8 (output)
      ! Activation
      naf(1) = INT(cm(17)) ! Activation function in layer 1 (not actually used)
      naf(2) = INT(cm(18)) ! Activation function in layer 2
      naf(3) = INT(cm(19)) ! Activation function in layer 3
      naf(4) = INT(cm(20)) ! Activation function in layer 4
      naf(5) = INT(cm(21)) ! Activation function in layer 5
      naf(6) = INT(cm(22)) ! Activation function in layer 6
      naf(7) = INT(cm(23)) ! Activation function in layer 7
      naf(8) = INT(cm(24)) ! Activation function in layer 8
      
      ! Network properties for shear response
      ! Units
      slv(1) = INT(cm(9))  ! Units in layer 1 (input)
      slv(2) = INT(cm(10)) ! Units in layer 2 
      slv(3) = INT(cm(11)) ! Units in layer 3 
      slv(4) = INT(cm(12)) ! Units in layer 4 
      slv(5) = INT(cm(13)) ! Units in layer 5 
      slv(6) = INT(cm(14)) ! Units in layer 6 
      slv(7) = INT(cm(15)) ! Units in layer 7 
      slv(8) = INT(cm(16)) ! Units in layer 8 (output)
      ! Activation
      saf(1) = INT(cm(17)) ! Activation function in layer 1 (not actually used)
      saf(2) = INT(cm(18)) ! Activation function in layer 2
      saf(3) = INT(cm(19)) ! Activation function in layer 3
      saf(4) = INT(cm(20)) ! Activation function in layer 4
      saf(5) = INT(cm(21)) ! Activation function in layer 5
      saf(6) = INT(cm(22)) ! Activation function in layer 6
      saf(7) = INT(cm(23)) ! Activation function in layer 7
      saf(8) = INT(cm(24)) ! Activation function in layer 8
      
      
      ! allocate arrays
      ALLOCATE(Nweights(nln -1,MAXVAL(nlv)+1,MAXVAL(nlv)+1))
      ALLOCATE(a(nlq,nln ,MAXVAL(nlv)))
      ALLOCATE(z(nlq,nln ,MAXVAL(nlv)+1))
      ALLOCATE(Ninputreg(nlv(1)))
      ALLOCATE(Noutputreg(nlv(nln )))
      ! allocate arrays
      ALLOCATE(Sweights(nls -1,MAXVAL(slv)+1,MAXVAL(slv)+1))
      ALLOCATE(a4(nlq,nls ,MAXVAL(slv)))
      ALLOCATE(z4(nlq,nls ,MAXVAL(slv)+1))
      ALLOCATE(a5(nlq,nls ,MAXVAL(slv)))
      ALLOCATE(z5(nlq,nls ,MAXVAL(slv)+1))
      ALLOCATE(a6(nlq,nls ,MAXVAL(slv)))
      ALLOCATE(z6(nlq,nls ,MAXVAL(slv)+1))
      ALLOCATE(Sinputreg(slv(1)))
      ALLOCATE(Soutputreg(slv(nls )))
c network here
      INCLUDE  'weightsNormal.txt'
      INCLUDE  'weightsShear.txt'
      
      ! update and store strain tensor
      DO i=lft,llt 
         hsvs(i,1)= hsvs(i,1)+d1(i)
         hsvs(i,2)= hsvs(i,2)+d2(i)
         hsvs(i,3)= hsvs(i,3)+d3(i)
         hsvs(i,4)= hsvs(i,4)+d4(i)
         hsvs(i,5)= hsvs(i,5)+d5(i)
         hsvs(i,6)= hsvs(i,6)+d6(i)
      ENDDO
      
      ! Predict normal response
      ! forward propagate neural network
      ! normalise strain
      DO i=lft,llt 
         a(i,1,1) = hsvs(i,1)/Ninputreg(1)
         a(i,1,2) = hsvs(i,2)/Ninputreg(2)
         a(i,1,3) = hsvs(i,3)/Ninputreg(3)
      ENDDO  
      ! Feedforward network
      DO i=lft,llt
        DO k=2,nln 
          ! loop through nodes
          DO m=1,nlv(k)
            z(i,k,m)=Nweights(k-1,m,1) ! Bias
            ! sum across previous layers
            DO n=2,(nlv(k-1)+1)
              z(i,k,m) = z(i,k,m)+Nweights(k-1,m,n)*a(i,k-1,n-1)
              
            ENDDO 
              
            ! activation functions
            IF (naf(k).eq.1)THEN
              ! purelin
              a(i,k,m) = z(i,k,m)
            ELSEIF (naf(k).eq.2)THEN
              ! tansig
              a(i,k,m) = 2./(1.+exp(-2.*z(i,k,m)))-1.
            ELSEIF (naf(k).eq.3)THEN
              ! sigmoid
              a(i,k,m) = 1.0/(1.0 + exp(-z(i,k,m)))
            ELSEIF (naf(i).eq.4)THEN
              ! relu
              a(i,k,m) = max(0.,z(i,k,m))
            ELSE
              a(i,k,m) = 0.           
            ENDIF
          ENDDO  
        ENDDO
      ENDDO
      
      ! reverse normalisation
      DO i=lft,llt 
         sig1(i) = a(i,nln ,1)*Noutputreg(1)
         sig2(i) = a(i,nln ,2)*Noutputreg(2)
         sig3(i) = a(i,nln ,3)*Noutputreg(3)
      ENDDO

      ! Predict shear response
      ! forward propagate neural network
      ! normalise strain
      DO i=lft,llt 
         a4(i,1,1) = hsvs(i,4)/Sinputreg(1)
         a5(i,1,1) = hsvs(i,5)/Sinputreg(1)
         a6(i,1,1) = hsvs(i,6)/Sinputreg(1)
      ENDDO  
      ! Feedforward network
      DO i=lft,llt
        DO k=2,nls 
          ! loop through nodes
          DO m=1,slv(k)
            z4(i,k,m)=Sweights(k-1,m,1) ! Bias
            z5(i,k,m)=Sweights(k-1,m,1) ! Bias
            z6(i,k,m)=Sweights(k-1,m,1) ! Bias
            ! sum across previous layers
            DO n=2,(slv(k-1)+1)
              z4(i,k,m) = z4(i,k,m)+Sweights(k-1,m,n)*a4(i,k-1,n-1)
              z5(i,k,m) = z5(i,k,m)+Sweights(k-1,m,n)*a5(i,k-1,n-1)
              z6(i,k,m) = z6(i,k,m)+Sweights(k-1,m,n)*a6(i,k-1,n-1)
            ENDDO 
              
            ! activation functions
            IF (saf(k).eq.1)THEN
              ! purelin
              a4(i,k,m) = z4(i,k,m)
              a5(i,k,m) = z5(i,k,m)
              a6(i,k,m) = z6(i,k,m)
            ELSEIF (saf(k).eq.2)THEN
              ! tansig
              a4(i,k,m) = 2./(1.+exp(-2.*z4(i,k,m)))-1.
              a5(i,k,m) = 2./(1.+exp(-2.*z5(i,k,m)))-1.
              a6(i,k,m) = 2./(1.+exp(-2.*z6(i,k,m)))-1.
            ELSEIF (saf(k).eq.3)THEN
              ! sigmoid
              a4(i,k,m) = 1.0/(1.0 + exp(-z4(i,k,m)))
              a5(i,k,m) = 1.0/(1.0 + exp(-z5(i,k,m)))
              a6(i,k,m) = 1.0/(1.0 + exp(-z6(i,k,m)))
            ELSEIF (saf(i).eq.4)THEN
              ! relu
              a4(i,k,m) = max(0.,z4(i,k,m))
              a5(i,k,m) = max(0.,z5(i,k,m))
              a6(i,k,m) = max(0.,z6(i,k,m))
            ELSE
              a4(i,k,m) = 0. 
              a5(i,k,m) = 0.
              a6(i,k,m) = 0.
            ENDIF
          ENDDO  
        ENDDO
      ENDDO
      
      ! reverse normalisation
      DO i=lft,llt 
         sig4(i) = a4(i,nls ,1)*Soutputreg(1)
         sig5(i) = a5(i,nls ,1)*Soutputreg(1)
         sig6(i) = a6(i,nls ,1)*Soutputreg(1)
      ENDDO

      
c     IF(ncycle.eq.3325)THEN
c     DO i=lft,llt 
c        WRITE(iotty,*)hsvs(i,1),hsvs(i,2),hsvs(i,3),hsvs(i,4),
c    1   hsvs(i,5),hsvs(i,6)
c                 WRITE(iotty,*)sig1(i),sig2(i),sig3(i),sig4(i),
c    1                          sig5(i),sig6(i)
c     ENDDO
c     ENDIF
c     
c     OPEN(113,file='debuglog.csv')
c     DO i=lft,llt 
c     WRITE(113,113)ncycle,hsvs(i,1),hsvs(i,2),hsvs(i,3),hsvs(i,4),
c    1   hsvs(i,5),hsvs(i,6),sig1(i),sig2(i),sig3(i),sig4(i),
c    1                          sig5(i),sig6(i)
c     ENDDO
c 113 FORMAT(I10,',',F12.10,',',F12.10,',',F12.10,',',
c    1               F12.10,',',F12.10,',',F12.10,',', 
c    1               F12.5,',',F12.5,',',F12.5,',',
c    1               F12.5,',',F12.5,',',F12.5)
      
      !WRITE(iotty,*)ncycle
      
      ! Free memory
      DEALLOCATE(Nweights)   
      DEALLOCATE(Sweights)   
      DEALLOCATE(a)   
      DEALLOCATE(z)   
      DEALLOCATE(a4)   
      DEALLOCATE(z4)   
      DEALLOCATE(a5)   
      DEALLOCATE(z5)   
      DEALLOCATE(a6)   
      DEALLOCATE(z6)   
      DEALLOCATE(Ninputreg)   
      DEALLOCATE(Noutputreg)     
      DEALLOCATE(Sinputreg)   
      DEALLOCATE(Soutputreg)     
      
      
      RETURN
      END
