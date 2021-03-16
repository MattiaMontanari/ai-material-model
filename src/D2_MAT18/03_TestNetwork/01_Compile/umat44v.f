      subroutine umat44v(cm,d1,d2,d3,d4,d5,d6,sig1,sig2,
     . sig3,sig4,sig5,sig6,epsps,hsvs,lft,llt,dt1siz,capa,
     . etype,tt,temps,failels,nlqa,crv,nnpcrv,cma,qmat,elsizv,idelev,
     . reject,cb)
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
      !integer user_iform
      !character*10 vendor
      !common /usermat_vendor/ user_iform,vendor
      !common/bk02/iburn,dt1,dt2,isdo
      dimension d1(*),d2(*),d3(*),d4(*),d5(*),d6(*)
      dimension sig1(*),sig2(*),sig3(*),sig4(*),sig5(*),sig6(*)
      dimension cm(*),epsps(*),hsvs(nlq,*),dt1siz(*)
      dimension temps(*),crv(lq1,2,*),cma(*),qmat(nlq,3,3),elsizv(*)
      integer nnpcrv(*)
      integer*8 idelev(*)
      logical failels(*),reject
      character*5 etype
      REAL cb(*)
      REAL da1(nlq),da2(nlq),da3(nlq),deps(nlq),ak2(nlq) 
      REAL aj2(nlq),depn(nlq),scle(nlq)
      REAL t1(nlq),t2(nlq),t3(nlq),t4(nlq),t5(nlq),t6(nlq),ak(nlq)
      REAL ym,pr,qk,qm,q1,g,ss,epi,qmqk,qm1,sigy
      REAL davg(nlq),p(nlq),epx(nlq),aj1(nlq)
      REAL blk(nlq),gdt(nlq),gd2(nlq)
      REAL dd1(nlq),dd2(nlq),dd3(nlq),dd4(nlq),dd5(nlq),dd6(nlq)
c
      REAL, dimension (:,:,:), allocatable :: weights
      REAL, dimension (:,:,:), allocatable :: a          ! a(nlq,4,20)
      REAL, dimension (:,:,:), allocatable :: z          ! z(nlq,4,21)
      REAL, dimension (:), allocatable :: inputreg
      REAL, dimension (:), allocatable :: outputreg
      !REAL, dimension (:), allocatable :: inputmean
      !REAL, dimension (:), allocatable :: inputstd
      !REAL, dimension (:), allocatable :: outputmean
      !REAL, dimension (:), allocatable :: outputstd
      INTEGER k,m,n,nh,nl,lv(8),af(8) 
      REAL epseff(nlq)    
      
      REAL depi(nlq)      
c
      data third /-.333333333333333/
      data iter /20/
      PARAMETER (twothird=0.666666666666667)
c
      !WRITE(iotty,*)dt1,dt1siz(i)
      
      ym=cm(1)
      pr=cm(2)
      qk=cm(3)
      qm=cm(4)
      sigy = ABS(cm(5))
      q1=ym*pr/((1.0+pr)*(1.0-2.0*pr))
      g=ym/(1.+pr)
      ss=q1+g
      !blk=-dt1*ym/(1.-2.*pr)
      IF(sigy.ge.0.0)THEN
      epi=(sigy/qk)**(1./qm)
      ELSE
      epi=(ym/qk)**(1./(qm-1.0))
      ENDIF
      qmqk=qm*qk
      qm1=qm-1.
      !gdt=dt1*g
      !gd2=.5*gdt
c
c
      IF(ncycle.eq.0)THEN
        DO i=lft,llt
          hsvs(i,1)=sigy
        ENDDO
      ENDIF
c     
      !cm(1): Bulk modulus
      !cm(2): Shear modulus
      nl = INT(cm(9)) ! number of layers (max 8)
      ! Units
      lv(1) = INT(cm(17))  ! Units in layer 1 (input)
      lv(2) = INT(cm(18)) ! Units in layer 2 
      lv(3) = INT(cm(19)) ! Units in layer 3 
      lv(4) = INT(cm(20)) ! Units in layer 4 
      lv(5) = INT(cm(21)) ! Units in layer 5 
      lv(6) = INT(cm(22)) ! Units in layer 6 
      lv(7) = INT(cm(23)) ! Units in layer 7 
      lv(8) = INT(cm(24)) ! Units in layer 8 (output)
      ! Activation
      af(1) = INT(cm(25)) ! Activation function in layer 1 (not actually used)
      af(2) = INT(cm(26)) ! Activation function in layer 2
      af(3) = INT(cm(27)) ! Activation function in layer 3
      af(4) = INT(cm(28)) ! Activation function in layer 4
      af(5) = INT(cm(29)) ! Activation function in layer 5
      af(6) = INT(cm(30)) ! Activation function in layer 6
      af(7) = INT(cm(31)) ! Activation function in layer 7
      af(8) = INT(cm(32)) ! Activation function in layer 8

      ! allocate arrays
      ALLOCATE(weights(nl-1,MAXVAL(lv)+1,MAXVAL(lv)+1))
      ALLOCATE(a(nlq,nl,MAXVAL(lv)))
      ALLOCATE(z(nlq,nl,MAXVAL(lv)+1))
      ALLOCATE(inputreg(lv(1)))
      ALLOCATE(outputreg(lv(nl)))
      
      ! Weights for trained neural network 
      INCLUDE 'weights.txt'


c
      ! calculate strain rates
      IF(ncycle.gt.0)THEN
      DO i=lft,llt
        dd1(i)=d1(i)/dt1siz(i)
        dd2(i)=d2(i)/dt1siz(i)
        dd3(i)=d3(i)/dt1siz(i)
        dd4(i)=d4(i)/dt1siz(i)
        dd5(i)=d5(i)/dt1siz(i)
        dd6(i)=d6(i)/dt1siz(i)
      ENDDO      
      ELSE
      DO i=lft,llt
        dd1(i)=d1(i)
        dd2(i)=d2(i)
        dd3(i)=d3(i)
        dd4(i)=d4(i)
        dd5(i)=d5(i)
        dd6(i)=d6(i)
      ENDDO   
      ENDIF
      
      DO i=lft,llt
        blk(i)=-dt1siz(i)*ym/(1.-2.*pr)
        gdt(i)=dt1siz(i)*g
        gd2(i)=.5*gdt(i)
        
        cb(i) =ss
        davg(i)=third*(dd1(i)+dd2(i)+dd3(i))  !(remember-> third is negative)
        epx(i) = epsps(i)
        p(i)=blk(i)*davg(i)
      ENDDO
      DO i=lft,llt
c       einc(i)=(dd1(i)*sig1(i)+dd2(i)*sig2(i)+dd3(i)*sig3(i)+dd4(i)*sig4(i)
c    1          +dd5(i)*sig5(i)+dd6(i)*sig6(i)+dd(i)*bqs(i))*dt1
        da1(i)=sig1(i)+p(i)+gdt(i)*(dd1(i)+davg(i))
        da2(i)=sig2(i)+p(i)+gdt(i)*(dd2(i)+davg(i))
        da3(i)=sig3(i)+p(i)+gdt(i)*(dd3(i)+davg(i))
        t4(i) =sig4(i)+gd2(i)*dd4(i)
        t5(i) =sig5(i)+gd2(i)*dd5(i)
        t6(i) =sig6(i)+gd2(i)*dd6(i)
      ENDDO
      DO i=lft,llt
        ak(i)=qk*(epi+epx(i))**qm  !yield stress from previous increment
        !ak(i) = hsvs(i,1)
      ENDDO
      DO i=lft,llt
        p(i)=third*(da1(i)+da2(i)+da3(i)) ! pressure (remember-> third is negative)
        t1(i)=p(i)+da1(i) ! deviatoric stress
        t2(i)=p(i)+da2(i) ! deviatoric stress
        t3(i)=p(i)+da3(i) ! deviatoric stress
      ENDDO
      DO i=lft,llt
        aj2(i)=1.5*(t1(i)**2+t2(i)**2+t3(i)**2)
     &    +3.*(t4(i)*t4(i)+t5(i)*t5(i)+t6(i)*t6(i))
      ENDDO
      DO i=lft,llt
        ak2(i)=aj2(i)-ak(i)*ak(i)
      ENDDO
      DO i=lft,llt
        scle(i)=.50+sign(.5,ak2(i)) ! yield criterion
      ENDDO
      
      DO i=lft,llt
        aj1(i)=sqrt(aj2(i))+1.-scle(i) ! this is similar to stress invariant abs(I1)
      ENDDO
      ! effective strain increment
      DO i=lft,llt
        epseff(i) = twothird *
     1  sqrt((1.5*(d1(i)**2+d2(i)**2+d3(i)**2) + 
     1       0.75*(d4(i)**2+d5(i)**2+d6(i)**2 ))
     1      )                    
      ENDDO

      ! effective stress previous time step
      DO i=lft,llt
        sigeff = sqrt(
     1    0.5*((sig1(i)-sig2(i))**2 + (sig2(i)-sig3(i))**2 + 
     1         (sig3(i)-sig1(i))**2 +
     1    6.0*(sig4(i)**2+sig5(i)**2+sig6(i)**2)) 
     1                )      
          
        a(i,1,1) = epsps(i)/inputreg(1)  ! previous plastic strain  
        a(i,1,2) = sigeff/inputreg(2)    ! previous effective stress  
        a(i,1,3) = epseff(i)/inputreg(3) ! effective strain increment
      ENDDO  
      
            
      ! Feedforward network
      DO i=lft,llt
        DO k=2,nl
          ! loop through nodes
          DO m=1,lv(k)
            z(i,k,m)=weights(k-1,m,1) ! Bias
            ! sum across previous layers
            DO n=2,(lv(k-1)+1)
              z(i,k,m) = z(i,k,m)+weights(k-1,m,n)*a(i,k-1,n-1)
            ENDDO 
              
            ! activation functions
            IF (af(k).eq.1)THEN
              ! purelin
              a(i,k,m) = z(i,k,m)
            ELSEIF (af(k).eq.2)THEN
              ! tansig
              a(i,k,m) = 2./(1.+exp(-2.*z(i,k,m)))-1.
            ELSEIF (af(k).eq.3)THEN
              ! sigmoid
              a(i,k,m) = 1.0/(1.0 + exp(-z(i,k,m)))
            ELSEIF (af(i).eq.4)THEN
              ! relu
              a(i,k,m) = max(0.,z(i,k,m))
            ELSEIF (af(i).eq.5)THEN
              ! tanh
              !a(i,k,m) = tanh(z(i,k,m))
              a(i,k,m) = ((exp(z(i,k,m)) - exp(-z(i,k,m)))/
     1                    (exp(z(i,k,m)) + exp(-z(i,k,m))))
            ELSE
              a(i,k,m) = 0.           
            ENDIF
          ENDDO  
        ENDDO
      ENDDO      
      
      
      DO i=lft,llt
        !epx(i)=epx(i)+scle(i)*depi(i)  ! effective plastic strain update
        ! update plastic strain with output from ANN
        !hsvs(i,7) = a(i,nl,1)*outputreg(1)
        
        !epx(i)=(a(i,nl,1)*outputstd(1)) + outputmean(1)  ! update plastic strain with output from ANN
        epx(i)=a(i,nl,1)*outputreg(1)  ! update plastic strain with output from ANN
        
        ! scale factor for stress
        ak(i)=qk*(epi+epx(i))**qm      ! yield stress update
        !ak(i)=a(i,nl,2)*outputreg(2)
        deps(i)=scle(i)*(1.0-ak(i)/aj1(i))
      ENDDO   
      
      
      DO i=lft,llt
        ! return stress to yield surface
        sig1(i)=da1(i)-deps(i)*t1(i)
        sig2(i)=da2(i)-deps(i)*t2(i)
        sig3(i)=da3(i)-deps(i)*t3(i)
        sig4(i)= t4(i)-deps(i)*t4(i)
        sig5(i)= t5(i)-deps(i)*t5(i)
        sig6(i)= t6(i)-deps(i)*t6(i)
c       einc(i)=(dd1(i)*sig1(i)+dd2(i)*sig2(i)+dd3(i)*sig3(i)+dd4(i)*sig4(i)
c    1          +dd5(i)*sig5(i)+dd6(i)*sig6(i))*dt1+einc(i)
        ! updat plastic strain
        epsps(i) = epx(i) 
        ! yield stress
        hsvs(i,1) = MAX(hsvs(i,1),sqrt(
     1    0.5*((sig1(i)-sig2(i))**2 + (sig2(i)-sig3(i))**2 + 
     1         (sig3(i)-sig1(i))**2 +
     1    6.0*(sig4(i)**2+sig5(i)**2+sig6(i)**2)) ))
      ENDDO
      
      ! deallocate arrays
      DEALLOCATE(weights)
      DEALLOCATE(a)
      DEALLOCATE(z)
      DEALLOCATE(inputreg)
      !DEALLOCATE(inputmean)
      !DEALLOCATE(inputstd)
      DEALLOCATE(outputreg)
      !DEALLOCATE(outputmean)
      !DEALLOCATE(outputstd)      
      
      RETURN
      END
