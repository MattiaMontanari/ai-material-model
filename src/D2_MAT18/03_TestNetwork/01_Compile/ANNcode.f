      DO i=lft,llt
        z(i,2,1) = weights(1,1,1)
     1           + weights(1,1,2)*a(i,1,1)
     1           + weights(1,1,3)*a(i,1,2)
     1           + weights(1,1,4)*a(i,1,3)
        z(i,2,2) = weights(1,2,1)
     1           + weights(1,2,2)*a(i,1,1)
     1           + weights(1,2,3)*a(i,1,2)
     1           + weights(1,2,4)*a(i,1,3)
        z(i,2,3) = weights(1,3,1)
     1           + weights(1,3,2)*a(i,1,1)
     1           + weights(1,3,3)*a(i,1,2)
     1           + weights(1,3,4)*a(i,1,3)
        z(i,2,4) = weights(1,4,1)
     1           + weights(1,4,2)*a(i,1,1)
     1           + weights(1,4,3)*a(i,1,2)
     1           + weights(1,4,4)*a(i,1,3)
        z(i,2,5) = weights(1,5,1)
     1           + weights(1,5,2)*a(i,1,1)
     1           + weights(1,5,3)*a(i,1,2)
     1           + weights(1,5,4)*a(i,1,3)
        z(i,2,6) = weights(1,6,1)
     1           + weights(1,6,2)*a(i,1,1)
     1           + weights(1,6,3)*a(i,1,2)
     1           + weights(1,6,4)*a(i,1,3)
        z(i,2,7) = weights(1,7,1)
     1           + weights(1,7,2)*a(i,1,1)
     1           + weights(1,7,3)*a(i,1,2)
     1           + weights(1,7,4)*a(i,1,3)
        z(i,2,8) = weights(1,8,1)
     1           + weights(1,8,2)*a(i,1,1)
     1           + weights(1,8,3)*a(i,1,2)
     1           + weights(1,8,4)*a(i,1,3)
        z(i,2,9) = weights(1,9,1)
     1           + weights(1,9,2)*a(i,1,1)
     1           + weights(1,9,3)*a(i,1,2)
     1           + weights(1,9,4)*a(i,1,3)
        z(i,2,10) = weights(1,10,1)
     1           + weights(1,10,2)*a(i,1,1)
     1           + weights(1,10,3)*a(i,1,2)
     1           + weights(1,10,4)*a(i,1,3)
        z(i,2,11) = weights(1,11,1)
     1           + weights(1,11,2)*a(i,1,1)
     1           + weights(1,11,3)*a(i,1,2)
     1           + weights(1,11,4)*a(i,1,3)
        z(i,2,12) = weights(1,12,1)
     1           + weights(1,12,2)*a(i,1,1)
     1           + weights(1,12,3)*a(i,1,2)
     1           + weights(1,12,4)*a(i,1,3)
        z(i,2,13) = weights(1,13,1)
     1           + weights(1,13,2)*a(i,1,1)
     1           + weights(1,13,3)*a(i,1,2)
     1           + weights(1,13,4)*a(i,1,3)
        z(i,2,14) = weights(1,14,1)
     1           + weights(1,14,2)*a(i,1,1)
     1           + weights(1,14,3)*a(i,1,2)
     1           + weights(1,14,4)*a(i,1,3)
        z(i,2,15) = weights(1,15,1)
     1           + weights(1,15,2)*a(i,1,1)
     1           + weights(1,15,3)*a(i,1,2)
     1           + weights(1,15,4)*a(i,1,3)
        z(i,2,16) = weights(1,16,1)
     1           + weights(1,16,2)*a(i,1,1)
     1           + weights(1,16,3)*a(i,1,2)
     1           + weights(1,16,4)*a(i,1,3)
        z(i,2,17) = weights(1,17,1)
     1           + weights(1,17,2)*a(i,1,1)
     1           + weights(1,17,3)*a(i,1,2)
     1           + weights(1,17,4)*a(i,1,3)
        z(i,2,18) = weights(1,18,1)
     1           + weights(1,18,2)*a(i,1,1)
     1           + weights(1,18,3)*a(i,1,2)
     1           + weights(1,18,4)*a(i,1,3)
        z(i,2,19) = weights(1,19,1)
     1           + weights(1,19,2)*a(i,1,1)
     1           + weights(1,19,3)*a(i,1,2)
     1           + weights(1,19,4)*a(i,1,3)
        z(i,2,20) = weights(1,20,1)
     1           + weights(1,20,2)*a(i,1,1)
     1           + weights(1,20,3)*a(i,1,2)
     1           + weights(1,20,4)*a(i,1,3)
      ENDDO
      DO i=lft,llt
        ! tansig activation
        a(i,2,1) = 2./(1.+exp(-2.*z(i,2,1)))-1.
        a(i,2,2) = 2./(1.+exp(-2.*z(i,2,2)))-1.
        a(i,2,3) = 2./(1.+exp(-2.*z(i,2,3)))-1.
        a(i,2,4) = 2./(1.+exp(-2.*z(i,2,4)))-1.
        a(i,2,5) = 2./(1.+exp(-2.*z(i,2,5)))-1.
        a(i,2,6) = 2./(1.+exp(-2.*z(i,2,6)))-1.
        a(i,2,7) = 2./(1.+exp(-2.*z(i,2,7)))-1.
        a(i,2,8) = 2./(1.+exp(-2.*z(i,2,8)))-1.
        a(i,2,9) = 2./(1.+exp(-2.*z(i,2,9)))-1.
        a(i,2,10) = 2./(1.+exp(-2.*z(i,2,10)))-1.
        a(i,2,11) = 2./(1.+exp(-2.*z(i,2,11)))-1.
        a(i,2,12) = 2./(1.+exp(-2.*z(i,2,12)))-1.
        a(i,2,13) = 2./(1.+exp(-2.*z(i,2,13)))-1.
        a(i,2,14) = 2./(1.+exp(-2.*z(i,2,14)))-1.
        a(i,2,15) = 2./(1.+exp(-2.*z(i,2,15)))-1.
        a(i,2,16) = 2./(1.+exp(-2.*z(i,2,16)))-1.
        a(i,2,17) = 2./(1.+exp(-2.*z(i,2,17)))-1.
        a(i,2,18) = 2./(1.+exp(-2.*z(i,2,18)))-1.
        a(i,2,19) = 2./(1.+exp(-2.*z(i,2,19)))-1.
        a(i,2,20) = 2./(1.+exp(-2.*z(i,2,20)))-1.
      ENDDO
      DO i=lft,llt
        z(i,3,1) = weights(2,1,1)
     1           + weights(2,1,2)*a(i,2,1)
     1           + weights(2,1,3)*a(i,2,2)
     1           + weights(2,1,4)*a(i,2,3)
     1           + weights(2,1,5)*a(i,2,4)
     1           + weights(2,1,6)*a(i,2,5)
     1           + weights(2,1,7)*a(i,2,6)
     1           + weights(2,1,8)*a(i,2,7)
     1           + weights(2,1,9)*a(i,2,8)
     1           + weights(2,1,10)*a(i,2,9)
     1           + weights(2,1,11)*a(i,2,10)
     1           + weights(2,1,12)*a(i,2,11)
     1           + weights(2,1,13)*a(i,2,12)
     1           + weights(2,1,14)*a(i,2,13)
     1           + weights(2,1,15)*a(i,2,14)
     1           + weights(2,1,16)*a(i,2,15)
     1           + weights(2,1,17)*a(i,2,16)
     1           + weights(2,1,18)*a(i,2,17)
     1           + weights(2,1,19)*a(i,2,18)
     1           + weights(2,1,20)*a(i,2,19)
     1           + weights(2,1,21)*a(i,2,20)
        z(i,3,2) = weights(2,2,1)
     1           + weights(2,2,2)*a(i,2,1)
     1           + weights(2,2,3)*a(i,2,2)
     1           + weights(2,2,4)*a(i,2,3)
     1           + weights(2,2,5)*a(i,2,4)
     1           + weights(2,2,6)*a(i,2,5)
     1           + weights(2,2,7)*a(i,2,6)
     1           + weights(2,2,8)*a(i,2,7)
     1           + weights(2,2,9)*a(i,2,8)
     1           + weights(2,2,10)*a(i,2,9)
     1           + weights(2,2,11)*a(i,2,10)
     1           + weights(2,2,12)*a(i,2,11)
     1           + weights(2,2,13)*a(i,2,12)
     1           + weights(2,2,14)*a(i,2,13)
     1           + weights(2,2,15)*a(i,2,14)
     1           + weights(2,2,16)*a(i,2,15)
     1           + weights(2,2,17)*a(i,2,16)
     1           + weights(2,2,18)*a(i,2,17)
     1           + weights(2,2,19)*a(i,2,18)
     1           + weights(2,2,20)*a(i,2,19)
     1           + weights(2,2,21)*a(i,2,20)
        z(i,3,3) = weights(2,3,1)
     1           + weights(2,3,2)*a(i,2,1)
     1           + weights(2,3,3)*a(i,2,2)
     1           + weights(2,3,4)*a(i,2,3)
     1           + weights(2,3,5)*a(i,2,4)
     1           + weights(2,3,6)*a(i,2,5)
     1           + weights(2,3,7)*a(i,2,6)
     1           + weights(2,3,8)*a(i,2,7)
     1           + weights(2,3,9)*a(i,2,8)
     1           + weights(2,3,10)*a(i,2,9)
     1           + weights(2,3,11)*a(i,2,10)
     1           + weights(2,3,12)*a(i,2,11)
     1           + weights(2,3,13)*a(i,2,12)
     1           + weights(2,3,14)*a(i,2,13)
     1           + weights(2,3,15)*a(i,2,14)
     1           + weights(2,3,16)*a(i,2,15)
     1           + weights(2,3,17)*a(i,2,16)
     1           + weights(2,3,18)*a(i,2,17)
     1           + weights(2,3,19)*a(i,2,18)
     1           + weights(2,3,20)*a(i,2,19)
     1           + weights(2,3,21)*a(i,2,20)
        z(i,3,4) = weights(2,4,1)
     1           + weights(2,4,2)*a(i,2,1)
     1           + weights(2,4,3)*a(i,2,2)
     1           + weights(2,4,4)*a(i,2,3)
     1           + weights(2,4,5)*a(i,2,4)
     1           + weights(2,4,6)*a(i,2,5)
     1           + weights(2,4,7)*a(i,2,6)
     1           + weights(2,4,8)*a(i,2,7)
     1           + weights(2,4,9)*a(i,2,8)
     1           + weights(2,4,10)*a(i,2,9)
     1           + weights(2,4,11)*a(i,2,10)
     1           + weights(2,4,12)*a(i,2,11)
     1           + weights(2,4,13)*a(i,2,12)
     1           + weights(2,4,14)*a(i,2,13)
     1           + weights(2,4,15)*a(i,2,14)
     1           + weights(2,4,16)*a(i,2,15)
     1           + weights(2,4,17)*a(i,2,16)
     1           + weights(2,4,18)*a(i,2,17)
     1           + weights(2,4,19)*a(i,2,18)
     1           + weights(2,4,20)*a(i,2,19)
     1           + weights(2,4,21)*a(i,2,20)
        z(i,3,5) = weights(2,5,1)
     1           + weights(2,5,2)*a(i,2,1)
     1           + weights(2,5,3)*a(i,2,2)
     1           + weights(2,5,4)*a(i,2,3)
     1           + weights(2,5,5)*a(i,2,4)
     1           + weights(2,5,6)*a(i,2,5)
     1           + weights(2,5,7)*a(i,2,6)
     1           + weights(2,5,8)*a(i,2,7)
     1           + weights(2,5,9)*a(i,2,8)
     1           + weights(2,5,10)*a(i,2,9)
     1           + weights(2,5,11)*a(i,2,10)
     1           + weights(2,5,12)*a(i,2,11)
     1           + weights(2,5,13)*a(i,2,12)
     1           + weights(2,5,14)*a(i,2,13)
     1           + weights(2,5,15)*a(i,2,14)
     1           + weights(2,5,16)*a(i,2,15)
     1           + weights(2,5,17)*a(i,2,16)
     1           + weights(2,5,18)*a(i,2,17)
     1           + weights(2,5,19)*a(i,2,18)
     1           + weights(2,5,20)*a(i,2,19)
     1           + weights(2,5,21)*a(i,2,20)
        z(i,3,6) = weights(2,6,1)
     1           + weights(2,6,2)*a(i,2,1)
     1           + weights(2,6,3)*a(i,2,2)
     1           + weights(2,6,4)*a(i,2,3)
     1           + weights(2,6,5)*a(i,2,4)
     1           + weights(2,6,6)*a(i,2,5)
     1           + weights(2,6,7)*a(i,2,6)
     1           + weights(2,6,8)*a(i,2,7)
     1           + weights(2,6,9)*a(i,2,8)
     1           + weights(2,6,10)*a(i,2,9)
     1           + weights(2,6,11)*a(i,2,10)
     1           + weights(2,6,12)*a(i,2,11)
     1           + weights(2,6,13)*a(i,2,12)
     1           + weights(2,6,14)*a(i,2,13)
     1           + weights(2,6,15)*a(i,2,14)
     1           + weights(2,6,16)*a(i,2,15)
     1           + weights(2,6,17)*a(i,2,16)
     1           + weights(2,6,18)*a(i,2,17)
     1           + weights(2,6,19)*a(i,2,18)
     1           + weights(2,6,20)*a(i,2,19)
     1           + weights(2,6,21)*a(i,2,20)
        z(i,3,7) = weights(2,7,1)
     1           + weights(2,7,2)*a(i,2,1)
     1           + weights(2,7,3)*a(i,2,2)
     1           + weights(2,7,4)*a(i,2,3)
     1           + weights(2,7,5)*a(i,2,4)
     1           + weights(2,7,6)*a(i,2,5)
     1           + weights(2,7,7)*a(i,2,6)
     1           + weights(2,7,8)*a(i,2,7)
     1           + weights(2,7,9)*a(i,2,8)
     1           + weights(2,7,10)*a(i,2,9)
     1           + weights(2,7,11)*a(i,2,10)
     1           + weights(2,7,12)*a(i,2,11)
     1           + weights(2,7,13)*a(i,2,12)
     1           + weights(2,7,14)*a(i,2,13)
     1           + weights(2,7,15)*a(i,2,14)
     1           + weights(2,7,16)*a(i,2,15)
     1           + weights(2,7,17)*a(i,2,16)
     1           + weights(2,7,18)*a(i,2,17)
     1           + weights(2,7,19)*a(i,2,18)
     1           + weights(2,7,20)*a(i,2,19)
     1           + weights(2,7,21)*a(i,2,20)
        z(i,3,8) = weights(2,8,1)
     1           + weights(2,8,2)*a(i,2,1)
     1           + weights(2,8,3)*a(i,2,2)
     1           + weights(2,8,4)*a(i,2,3)
     1           + weights(2,8,5)*a(i,2,4)
     1           + weights(2,8,6)*a(i,2,5)
     1           + weights(2,8,7)*a(i,2,6)
     1           + weights(2,8,8)*a(i,2,7)
     1           + weights(2,8,9)*a(i,2,8)
     1           + weights(2,8,10)*a(i,2,9)
     1           + weights(2,8,11)*a(i,2,10)
     1           + weights(2,8,12)*a(i,2,11)
     1           + weights(2,8,13)*a(i,2,12)
     1           + weights(2,8,14)*a(i,2,13)
     1           + weights(2,8,15)*a(i,2,14)
     1           + weights(2,8,16)*a(i,2,15)
     1           + weights(2,8,17)*a(i,2,16)
     1           + weights(2,8,18)*a(i,2,17)
     1           + weights(2,8,19)*a(i,2,18)
     1           + weights(2,8,20)*a(i,2,19)
     1           + weights(2,8,21)*a(i,2,20)
        z(i,3,9) = weights(2,9,1)
     1           + weights(2,9,2)*a(i,2,1)
     1           + weights(2,9,3)*a(i,2,2)
     1           + weights(2,9,4)*a(i,2,3)
     1           + weights(2,9,5)*a(i,2,4)
     1           + weights(2,9,6)*a(i,2,5)
     1           + weights(2,9,7)*a(i,2,6)
     1           + weights(2,9,8)*a(i,2,7)
     1           + weights(2,9,9)*a(i,2,8)
     1           + weights(2,9,10)*a(i,2,9)
     1           + weights(2,9,11)*a(i,2,10)
     1           + weights(2,9,12)*a(i,2,11)
     1           + weights(2,9,13)*a(i,2,12)
     1           + weights(2,9,14)*a(i,2,13)
     1           + weights(2,9,15)*a(i,2,14)
     1           + weights(2,9,16)*a(i,2,15)
     1           + weights(2,9,17)*a(i,2,16)
     1           + weights(2,9,18)*a(i,2,17)
     1           + weights(2,9,19)*a(i,2,18)
     1           + weights(2,9,20)*a(i,2,19)
     1           + weights(2,9,21)*a(i,2,20)
        z(i,3,10) = weights(2,10,1)
     1           + weights(2,10,2)*a(i,2,1)
     1           + weights(2,10,3)*a(i,2,2)
     1           + weights(2,10,4)*a(i,2,3)
     1           + weights(2,10,5)*a(i,2,4)
     1           + weights(2,10,6)*a(i,2,5)
     1           + weights(2,10,7)*a(i,2,6)
     1           + weights(2,10,8)*a(i,2,7)
     1           + weights(2,10,9)*a(i,2,8)
     1           + weights(2,10,10)*a(i,2,9)
     1           + weights(2,10,11)*a(i,2,10)
     1           + weights(2,10,12)*a(i,2,11)
     1           + weights(2,10,13)*a(i,2,12)
     1           + weights(2,10,14)*a(i,2,13)
     1           + weights(2,10,15)*a(i,2,14)
     1           + weights(2,10,16)*a(i,2,15)
     1           + weights(2,10,17)*a(i,2,16)
     1           + weights(2,10,18)*a(i,2,17)
     1           + weights(2,10,19)*a(i,2,18)
     1           + weights(2,10,20)*a(i,2,19)
     1           + weights(2,10,21)*a(i,2,20)
        z(i,3,11) = weights(2,11,1)
     1           + weights(2,11,2)*a(i,2,1)
     1           + weights(2,11,3)*a(i,2,2)
     1           + weights(2,11,4)*a(i,2,3)
     1           + weights(2,11,5)*a(i,2,4)
     1           + weights(2,11,6)*a(i,2,5)
     1           + weights(2,11,7)*a(i,2,6)
     1           + weights(2,11,8)*a(i,2,7)
     1           + weights(2,11,9)*a(i,2,8)
     1           + weights(2,11,10)*a(i,2,9)
     1           + weights(2,11,11)*a(i,2,10)
     1           + weights(2,11,12)*a(i,2,11)
     1           + weights(2,11,13)*a(i,2,12)
     1           + weights(2,11,14)*a(i,2,13)
     1           + weights(2,11,15)*a(i,2,14)
     1           + weights(2,11,16)*a(i,2,15)
     1           + weights(2,11,17)*a(i,2,16)
     1           + weights(2,11,18)*a(i,2,17)
     1           + weights(2,11,19)*a(i,2,18)
     1           + weights(2,11,20)*a(i,2,19)
     1           + weights(2,11,21)*a(i,2,20)
        z(i,3,12) = weights(2,12,1)
     1           + weights(2,12,2)*a(i,2,1)
     1           + weights(2,12,3)*a(i,2,2)
     1           + weights(2,12,4)*a(i,2,3)
     1           + weights(2,12,5)*a(i,2,4)
     1           + weights(2,12,6)*a(i,2,5)
     1           + weights(2,12,7)*a(i,2,6)
     1           + weights(2,12,8)*a(i,2,7)
     1           + weights(2,12,9)*a(i,2,8)
     1           + weights(2,12,10)*a(i,2,9)
     1           + weights(2,12,11)*a(i,2,10)
     1           + weights(2,12,12)*a(i,2,11)
     1           + weights(2,12,13)*a(i,2,12)
     1           + weights(2,12,14)*a(i,2,13)
     1           + weights(2,12,15)*a(i,2,14)
     1           + weights(2,12,16)*a(i,2,15)
     1           + weights(2,12,17)*a(i,2,16)
     1           + weights(2,12,18)*a(i,2,17)
     1           + weights(2,12,19)*a(i,2,18)
     1           + weights(2,12,20)*a(i,2,19)
     1           + weights(2,12,21)*a(i,2,20)
        z(i,3,13) = weights(2,13,1)
     1           + weights(2,13,2)*a(i,2,1)
     1           + weights(2,13,3)*a(i,2,2)
     1           + weights(2,13,4)*a(i,2,3)
     1           + weights(2,13,5)*a(i,2,4)
     1           + weights(2,13,6)*a(i,2,5)
     1           + weights(2,13,7)*a(i,2,6)
     1           + weights(2,13,8)*a(i,2,7)
     1           + weights(2,13,9)*a(i,2,8)
     1           + weights(2,13,10)*a(i,2,9)
     1           + weights(2,13,11)*a(i,2,10)
     1           + weights(2,13,12)*a(i,2,11)
     1           + weights(2,13,13)*a(i,2,12)
     1           + weights(2,13,14)*a(i,2,13)
     1           + weights(2,13,15)*a(i,2,14)
     1           + weights(2,13,16)*a(i,2,15)
     1           + weights(2,13,17)*a(i,2,16)
     1           + weights(2,13,18)*a(i,2,17)
     1           + weights(2,13,19)*a(i,2,18)
     1           + weights(2,13,20)*a(i,2,19)
     1           + weights(2,13,21)*a(i,2,20)
        z(i,3,14) = weights(2,14,1)
     1           + weights(2,14,2)*a(i,2,1)
     1           + weights(2,14,3)*a(i,2,2)
     1           + weights(2,14,4)*a(i,2,3)
     1           + weights(2,14,5)*a(i,2,4)
     1           + weights(2,14,6)*a(i,2,5)
     1           + weights(2,14,7)*a(i,2,6)
     1           + weights(2,14,8)*a(i,2,7)
     1           + weights(2,14,9)*a(i,2,8)
     1           + weights(2,14,10)*a(i,2,9)
     1           + weights(2,14,11)*a(i,2,10)
     1           + weights(2,14,12)*a(i,2,11)
     1           + weights(2,14,13)*a(i,2,12)
     1           + weights(2,14,14)*a(i,2,13)
     1           + weights(2,14,15)*a(i,2,14)
     1           + weights(2,14,16)*a(i,2,15)
     1           + weights(2,14,17)*a(i,2,16)
     1           + weights(2,14,18)*a(i,2,17)
     1           + weights(2,14,19)*a(i,2,18)
     1           + weights(2,14,20)*a(i,2,19)
     1           + weights(2,14,21)*a(i,2,20)
        z(i,3,15) = weights(2,15,1)
     1           + weights(2,15,2)*a(i,2,1)
     1           + weights(2,15,3)*a(i,2,2)
     1           + weights(2,15,4)*a(i,2,3)
     1           + weights(2,15,5)*a(i,2,4)
     1           + weights(2,15,6)*a(i,2,5)
     1           + weights(2,15,7)*a(i,2,6)
     1           + weights(2,15,8)*a(i,2,7)
     1           + weights(2,15,9)*a(i,2,8)
     1           + weights(2,15,10)*a(i,2,9)
     1           + weights(2,15,11)*a(i,2,10)
     1           + weights(2,15,12)*a(i,2,11)
     1           + weights(2,15,13)*a(i,2,12)
     1           + weights(2,15,14)*a(i,2,13)
     1           + weights(2,15,15)*a(i,2,14)
     1           + weights(2,15,16)*a(i,2,15)
     1           + weights(2,15,17)*a(i,2,16)
     1           + weights(2,15,18)*a(i,2,17)
     1           + weights(2,15,19)*a(i,2,18)
     1           + weights(2,15,20)*a(i,2,19)
     1           + weights(2,15,21)*a(i,2,20)
        z(i,3,16) = weights(2,16,1)
     1           + weights(2,16,2)*a(i,2,1)
     1           + weights(2,16,3)*a(i,2,2)
     1           + weights(2,16,4)*a(i,2,3)
     1           + weights(2,16,5)*a(i,2,4)
     1           + weights(2,16,6)*a(i,2,5)
     1           + weights(2,16,7)*a(i,2,6)
     1           + weights(2,16,8)*a(i,2,7)
     1           + weights(2,16,9)*a(i,2,8)
     1           + weights(2,16,10)*a(i,2,9)
     1           + weights(2,16,11)*a(i,2,10)
     1           + weights(2,16,12)*a(i,2,11)
     1           + weights(2,16,13)*a(i,2,12)
     1           + weights(2,16,14)*a(i,2,13)
     1           + weights(2,16,15)*a(i,2,14)
     1           + weights(2,16,16)*a(i,2,15)
     1           + weights(2,16,17)*a(i,2,16)
     1           + weights(2,16,18)*a(i,2,17)
     1           + weights(2,16,19)*a(i,2,18)
     1           + weights(2,16,20)*a(i,2,19)
     1           + weights(2,16,21)*a(i,2,20)
        z(i,3,17) = weights(2,17,1)
     1           + weights(2,17,2)*a(i,2,1)
     1           + weights(2,17,3)*a(i,2,2)
     1           + weights(2,17,4)*a(i,2,3)
     1           + weights(2,17,5)*a(i,2,4)
     1           + weights(2,17,6)*a(i,2,5)
     1           + weights(2,17,7)*a(i,2,6)
     1           + weights(2,17,8)*a(i,2,7)
     1           + weights(2,17,9)*a(i,2,8)
     1           + weights(2,17,10)*a(i,2,9)
     1           + weights(2,17,11)*a(i,2,10)
     1           + weights(2,17,12)*a(i,2,11)
     1           + weights(2,17,13)*a(i,2,12)
     1           + weights(2,17,14)*a(i,2,13)
     1           + weights(2,17,15)*a(i,2,14)
     1           + weights(2,17,16)*a(i,2,15)
     1           + weights(2,17,17)*a(i,2,16)
     1           + weights(2,17,18)*a(i,2,17)
     1           + weights(2,17,19)*a(i,2,18)
     1           + weights(2,17,20)*a(i,2,19)
     1           + weights(2,17,21)*a(i,2,20)
        z(i,3,18) = weights(2,18,1)
     1           + weights(2,18,2)*a(i,2,1)
     1           + weights(2,18,3)*a(i,2,2)
     1           + weights(2,18,4)*a(i,2,3)
     1           + weights(2,18,5)*a(i,2,4)
     1           + weights(2,18,6)*a(i,2,5)
     1           + weights(2,18,7)*a(i,2,6)
     1           + weights(2,18,8)*a(i,2,7)
     1           + weights(2,18,9)*a(i,2,8)
     1           + weights(2,18,10)*a(i,2,9)
     1           + weights(2,18,11)*a(i,2,10)
     1           + weights(2,18,12)*a(i,2,11)
     1           + weights(2,18,13)*a(i,2,12)
     1           + weights(2,18,14)*a(i,2,13)
     1           + weights(2,18,15)*a(i,2,14)
     1           + weights(2,18,16)*a(i,2,15)
     1           + weights(2,18,17)*a(i,2,16)
     1           + weights(2,18,18)*a(i,2,17)
     1           + weights(2,18,19)*a(i,2,18)
     1           + weights(2,18,20)*a(i,2,19)
     1           + weights(2,18,21)*a(i,2,20)
        z(i,3,19) = weights(2,19,1)
     1           + weights(2,19,2)*a(i,2,1)
     1           + weights(2,19,3)*a(i,2,2)
     1           + weights(2,19,4)*a(i,2,3)
     1           + weights(2,19,5)*a(i,2,4)
     1           + weights(2,19,6)*a(i,2,5)
     1           + weights(2,19,7)*a(i,2,6)
     1           + weights(2,19,8)*a(i,2,7)
     1           + weights(2,19,9)*a(i,2,8)
     1           + weights(2,19,10)*a(i,2,9)
     1           + weights(2,19,11)*a(i,2,10)
     1           + weights(2,19,12)*a(i,2,11)
     1           + weights(2,19,13)*a(i,2,12)
     1           + weights(2,19,14)*a(i,2,13)
     1           + weights(2,19,15)*a(i,2,14)
     1           + weights(2,19,16)*a(i,2,15)
     1           + weights(2,19,17)*a(i,2,16)
     1           + weights(2,19,18)*a(i,2,17)
     1           + weights(2,19,19)*a(i,2,18)
     1           + weights(2,19,20)*a(i,2,19)
     1           + weights(2,19,21)*a(i,2,20)
        z(i,3,20) = weights(2,20,1)
     1           + weights(2,20,2)*a(i,2,1)
     1           + weights(2,20,3)*a(i,2,2)
     1           + weights(2,20,4)*a(i,2,3)
     1           + weights(2,20,5)*a(i,2,4)
     1           + weights(2,20,6)*a(i,2,5)
     1           + weights(2,20,7)*a(i,2,6)
     1           + weights(2,20,8)*a(i,2,7)
     1           + weights(2,20,9)*a(i,2,8)
     1           + weights(2,20,10)*a(i,2,9)
     1           + weights(2,20,11)*a(i,2,10)
     1           + weights(2,20,12)*a(i,2,11)
     1           + weights(2,20,13)*a(i,2,12)
     1           + weights(2,20,14)*a(i,2,13)
     1           + weights(2,20,15)*a(i,2,14)
     1           + weights(2,20,16)*a(i,2,15)
     1           + weights(2,20,17)*a(i,2,16)
     1           + weights(2,20,18)*a(i,2,17)
     1           + weights(2,20,19)*a(i,2,18)
     1           + weights(2,20,20)*a(i,2,19)
     1           + weights(2,20,21)*a(i,2,20)
      ENDDO
      DO i=lft,llt
        ! tansig activation
        a(i,3,1) = 2./(1.+exp(-2.*z(i,3,1)))-1.
        a(i,3,2) = 2./(1.+exp(-2.*z(i,3,2)))-1.
        a(i,3,3) = 2./(1.+exp(-2.*z(i,3,3)))-1.
        a(i,3,4) = 2./(1.+exp(-2.*z(i,3,4)))-1.
        a(i,3,5) = 2./(1.+exp(-2.*z(i,3,5)))-1.
        a(i,3,6) = 2./(1.+exp(-2.*z(i,3,6)))-1.
        a(i,3,7) = 2./(1.+exp(-2.*z(i,3,7)))-1.
        a(i,3,8) = 2./(1.+exp(-2.*z(i,3,8)))-1.
        a(i,3,9) = 2./(1.+exp(-2.*z(i,3,9)))-1.
        a(i,3,10) = 2./(1.+exp(-2.*z(i,3,10)))-1.
        a(i,3,11) = 2./(1.+exp(-2.*z(i,3,11)))-1.
        a(i,3,12) = 2./(1.+exp(-2.*z(i,3,12)))-1.
        a(i,3,13) = 2./(1.+exp(-2.*z(i,3,13)))-1.
        a(i,3,14) = 2./(1.+exp(-2.*z(i,3,14)))-1.
        a(i,3,15) = 2./(1.+exp(-2.*z(i,3,15)))-1.
        a(i,3,16) = 2./(1.+exp(-2.*z(i,3,16)))-1.
        a(i,3,17) = 2./(1.+exp(-2.*z(i,3,17)))-1.
        a(i,3,18) = 2./(1.+exp(-2.*z(i,3,18)))-1.
        a(i,3,19) = 2./(1.+exp(-2.*z(i,3,19)))-1.
        a(i,3,20) = 2./(1.+exp(-2.*z(i,3,20)))-1.
      ENDDO
      DO i=lft,llt
        z(i,4,1) = weights(3,1,1)
     1           + weights(3,1,2)*a(i,3,1)
     1           + weights(3,1,3)*a(i,3,2)
     1           + weights(3,1,4)*a(i,3,3)
     1           + weights(3,1,5)*a(i,3,4)
     1           + weights(3,1,6)*a(i,3,5)
     1           + weights(3,1,7)*a(i,3,6)
     1           + weights(3,1,8)*a(i,3,7)
     1           + weights(3,1,9)*a(i,3,8)
     1           + weights(3,1,10)*a(i,3,9)
     1           + weights(3,1,11)*a(i,3,10)
     1           + weights(3,1,12)*a(i,3,11)
     1           + weights(3,1,13)*a(i,3,12)
     1           + weights(3,1,14)*a(i,3,13)
     1           + weights(3,1,15)*a(i,3,14)
     1           + weights(3,1,16)*a(i,3,15)
     1           + weights(3,1,17)*a(i,3,16)
     1           + weights(3,1,18)*a(i,3,17)
     1           + weights(3,1,19)*a(i,3,18)
     1           + weights(3,1,20)*a(i,3,19)
     1           + weights(3,1,21)*a(i,3,20)
      ENDDO
      DO i=lft,llt
        ! linear activation
        a(i,4,1) = z(i,4,1)
      ENDDO