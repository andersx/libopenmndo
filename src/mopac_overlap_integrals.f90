module mopac_overlap_integrals

    implicit none
      
    integer, parameter :: double = kind(1.0d0)      
    ! from analyt_C  
    real(double) :: cutof1 = 100.d0, cutof2 = 100.d0 
    
    real(double), dimension(6,6,2) :: allc, allz 
    integer :: isp, ips 
    real(double), dimension(7) :: a, b 
    real(double) :: sa, sb 
    real(double), dimension(0:17) :: fact    ! Factorials:  fact(n) = n!
    data fact/ 1.d0, 1.D0, 2.D0, 6.D0, 24.D0, 120.D0, 720.D0, 5040.D0, 40320.D0, &
      362880.D0, 3628800.D0, 39916800.D0, 479001600.D0, 6227020800.D0, &
        8.71782912D10, 1.307674368D12, 2.092278989D13, 3.556874281D14/  
    
    real(double), parameter :: pi = 3.14159265358979323846d0
    real(double), parameter :: twopi = 2.0d0 * pi
    real(double), parameter :: a0 = 0.5291772083d0

    real(double), dimension(107) :: zs, zp, zd, zsn, zpn, zdn
    ! integer, dimension (107) :: natorb
     integer, dimension(107) :: nztype 
    
    integer, dimension (107,3) :: npq
    integer, dimension (107) :: iod, iop, ios
    integer, dimension (107) :: natsp, natorb, natspd
    logical, dimension (107) :: main_group
   
    save
!              H           Initial "s" Orbital Occupancies                     He
!              Li Be                                            B  C  N  O  F  Ne
!              Na Mg                                            Al Si P  S  Cl Ar
!              K  Ca Sc            Ti V  Cr Mn Fe Co Ni Cu Zn   Ga Ge As Se Br Kr
!              Rb Sr Y             Zr Nb Mo Tc Ru Rh Pd Ag Cd   In Sn Sb Te I  Xe
!              Cs Ba La Ce-Lu      Hf Ta W  Re Os Ir Pt Au Hg   Tl Pb Bi Po At Rn
!              Fr Ra Ac Th Pa U    Np Pu Am Cm Bk Cf            Cb ++ +  -- -  Tv
!                                      "s" shell
    data ios &
        &/ 1,                                                                2, &!    2
        &  1, 2,                                              2, 2, 2, 2, 2, 0, &!   10
        &  1, 2,                                              2, 2, 2, 2, 2, 0, &!   18
        &  1, 2, 2,              2, 2, 1, 2, 2, 2, 2, 1, 2,   2, 2, 2, 2, 2, 0, &!   36
        &  1, 2, 2,              2, 1, 1, 2, 1, 1, 0, 1, 2,   2, 2, 2, 2, 2, 0, &!   54
        &  1, 2, 2, 5*0,3*2,6*2, 2, 2, 1, 2, 2, 2, 1, 1, 2,   2, 2, 2, 2, 2, 0, &!   86
        &  1, 1, 2, 4, 2, 2,     2, 2, 2, 2, 2, 2, 0, 3,-3,   1, 2, 1,-2,-1, 0 /
!                                  /
!
!              H           Initial "p" Orbital Occupancies                   He
!              Li Be                                          B  C  N  O  F  Ne
!              Na Mg                                          Al Si P  S  Cl Ar
!              K  Ca Sc          Ti V  Cr Mn Fe Co Ni Cu Zn   Ga Ge As Se Br Kr
!              Rb Sr Y           Zr Nb Mo Tc Ru Rh Pd Ag Cd   In Sn Sb Te I  Xe
!              Cs Ba La Ce-Lu    Hf Ta W  Re Os Ir Pt Au Hg   Tl Pb Bi Po At Rn
!              Fr Ra Ac Th Pa U  Np Pu Am Cm Bk Cf (The rest are reserved for MOPAC)
!                                      "p" shell
    data iop / 0 ,                                                           0, &!    2
            &  0, 0,                                          1, 2, 3, 4, 5, 6, &!   10
            &  0, 0,                                          1, 2, 3, 4, 5, 6, &!   18
            &  0, 0, 0,          0, 0, 0, 0, 0, 0, 0, 0, 0,   1, 2, 3, 4, 5, 6, &!   36
            &  0, 0, 0,          0, 0, 0, 0, 0, 0, 0, 0, 0,   1, 2, 3, 4, 5, 6, &!   54
            &  0, 0, 0,  14*0,   0, 0, 0, 0, 0, 0, 0, 0, 0,   1, 2, 3, 4, 5, 6, &!   86
            &  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9*0                        /
!
!              H           Initial "d" Orbital Occupancies                   He
!              Li Be                                          B  C  N  O  F  Ne
!              Na Mg                                          Al Si P  S  Cl Ar
!              K  Ca Sc          Ti V  Cr Mn Fe Co Ni Cu Zn   Ga Ge As Se Br Kr
!              Rb Sr Y           Zr Nb Mo Tc Ru Rh Pd Ag Cd   In Sn Sb Te I  Xe
!              Cs Ba La Ce-Lu    Hf Ta W  Re Os Ir Pt Au Hg   Tl Pb Bi Po At Rn
!              Fr Ra Ac Th Pa U  Np Pu Am Cm Bk Cf (The rest are reserved for MOPAC)
!                                      "d" shell
    data iod / 0,                                                           0, &!    2
             & 0, 0,                                         0, 0, 0, 0, 0, 0, &!   10
             & 0, 0,                                         0, 0, 0, 0, 0, 0, &!   18
             & 0, 0, 1,          2, 3, 5, 5, 6, 7, 8, 10, 0, 0, 0, 0, 0, 0, 0, &!   36
             & 0, 0, 1,          2, 4, 5, 5, 7, 8,10, 10, 0, 0, 0, 0, 0, 0, 0, &!   54
             & 0, 0, 1,13*0,  1, 2, 3, 5, 5, 6, 7, 9, 10, 0, 0, 0, 0, 0, 0, 0, &!   86
             & 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9*0                     /
!
!                     Principal Quantum Numbers for all shells.
!
!              H                 "s"  shell                                  He
!              Li Be                                          B  C  N  O  F  Ne
!              Na Mg                                          Al Si P  S  Cl Ar
!              K  Ca Sc          Ti V  Cr Mn Fe Co Ni Cu Zn   Ga Ge As Se Br Kr
!              Rb Sr Y           Zr Nb Mo Tc Ru Rh Pd Ag Cd   In Sn Sb Te I  Xe
!              Cs Ba La Ce-Lu    Hf Ta W  Re Os Ir Pt Au Hg   Tl Pb Bi Po At Rn
!              Fr Ra Ac Th-Lr    ?? ?? ?? ??
!
data npq(1:107,1) / &
             & 1,                                                             1, &!  2
             & 2, 2,                                           2, 2, 2, 2, 2, 3, &! 10
             & 3, 3,                                           3, 3, 3, 3, 3, 4, &! 18
             & 4, 4,             4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, &! 36
             & 5, 5,             5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, &! 54
             & 6, 6, 14 * 6,     6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, &! 86
             & 15 * 0, 3, 5 * 0 /
!
!              H                "p"  shell                                   He
!              Li Be                                          B  C  N  O  F  Ne
!              Na Mg                                          Al Si P  S  Cl Ar
!              K  Ca Sc          Ti V  Cr Mn Fe Co Ni Cu Zn   Ga Ge As Se Br Kr
!              Rb Sr Y           Zr Nb Mo Tc Ru Rh Pd Ag Cd   In Sn Sb Te I  Xe
!              Cs Ba La Ce-Lu    Hf Ta W  Re Os Ir Pt Au Hg   Tl Pb Bi Po At Rn
!              Fr Ra Ac Th-Lr    ?? ?? ?? ??
!
data npq(1:107,2) / &
             & 1,                                                             2, &!  2
             & 2, 2,                                           2, 2, 2, 2, 2, 2, &! 10
             & 3, 3,                                           3, 3, 3, 3, 3, 3, &! 18
             & 4, 4,             4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, &! 36
             & 5, 5,             5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, &! 54
             & 6, 6, 14 * 6,     6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, &! 86
             & 21 * 0 /
!
!              H                 "d"  shell                                  He
!              Li Be                                          B  C  N  O  F  Ne
!              Na Mg                                          Al Si P  S  Cl Ar
!              K  Ca Sc          Ti V  Cr Mn Fe Co Ni Cu Zn   Ga Ge As Se Br Kr
!              Rb Sr Y           Zr Nb Mo Tc Ru Rh Pd Ag Cd   In Sn Sb Te I  Xe
!              Cs Ba La Ce-Lu    Hf Ta W  Re Os Ir Pt Au Hg   Tl Pb Bi Po At Rn
!              Fr Ra Ac Th-Lr    ?? ?? ?? ??
!
data npq(1:107,3) / &
             & 0,                                                             3, &!  2
             & 0, 0,                                           0, 0, 0, 0, 0, 3, &! 10
             & 3, 3,                                           3, 3, 3, 3, 3, 4, &! 18
             & 3, 3,             3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, &! 36
             & 4, 4,             4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, &! 54
             & 5, 5, 14 * 5,     5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, &! 86
             & 21 * 0 /
!
!   NATSP IS THE NUMBER OF ATOMIC ORBITALS PER ATOM
!
!                               Group
!             1 2  Transition Metals    3 4 5 6 7         8
!
!    H                                                  He
!    Li Be                               B  C  N  O  F  Ne
!    Na Mg                               Al Si P  S  Cl Ar
!    K  Ca Sc Ti V  Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr
!    Rb Sr Y  Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I  Xe
!    Cs Ba
!             La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb
!          Lu Hf Ta W  Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn
!    Fr Ra
!          Ac Th Pa U  Np Pu Am Cm Bk Cf
!    XX ?? ?? Cb
!
  data natsp / &
   & 1,                                                 4, & ! H  - He
   & 4, 4,                               4, 4, 4, 4, 4, 4, & ! Li - Ne
   & 0, 4,                               4, 4, 4, 4, 4, 4, & ! Na - Ar
   & 0, 4, 9, 9, 9, 9, 9, 9, 9, 9, 9, 4, 4, 4, 4, 4, 4, 4, & ! K  - Kr
   & 0, 4, 9, 9, 9, 9, 9, 9, 9, 9, 9, 4, 4, 4, 4, 4, 4, 4, & ! Rb - Xe
   & 0, 4,                                                 & ! Cs - Ba
   &          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    & ! The Lanthanides
   &       0, 9, 9, 9, 9, 9, 9, 9, 9, 4, 4, 4, 4, 4, 4, 4, & ! Lu - Rn
   & 0, 4,                                                 & ! Fr - Ra
   &       4, 0, 4, 4, 4, 4, 4, 4, 4, 4,                   & ! The Actinides
   & 0, 0, 0, 1, 0,                                        & ! XX, ??, ??, Cb, ++
   & 0, 0, 0, 0                                            / ! +,  --,  -, Tv 
!    
!     LIST OF ELEMENTS WITH MNDO/d PARAMETERS.
!
!   NATSPD IS THE NUMBER OF ATOMIC ORBITALS PER ATOM FOR MNDO-D.
!
!                               Group
!                 1 2  Transition Metals    3 4 5 6 7         8
       data natspd / &
     &            1,                                          0,        &
     &            4,4,                      4,4,4,4,4,        0,        &
     &            4,4,                      9,9,9,9,9,        0,        &
     &            4,4, 9,9,9,9,9,9,9,9,9,4, 9,9,9,9,9,        0,        &
     &            4,4, 9,9,9,9,9,9,9,9,9,4, 9,9,9,9,9,        0,        &
     &            0,0,                                                  &
     &              0,0,0,0,0,0,0,0,0,0,0,0,0,0,                        &
     &                 9,9,9,9,9,9,9,9,9,4, 0,0,0,0,0,        0,        &
     &            0,0,                                                  &
     &              0,0,0,0,0,0,0,0,0,0,0,0,0,0,                        &
     &                                      0,0,0,0,0/
      real(double), dimension(107) :: ussm, uppm, uddm, zsm, zpm, zdm, betasm, &
        betapm, alpm, gssm, gspm, gppm, gp2m, hspm, polvom 

 !                    DATA FOR ELEMENT  1        HYDROGEN
   data alpm(1)/2.5441341d0/
   data betasm(1)/-6.9890640d0/
   data gssm(1)/12.848d00/
   data polvom(1)/0.2287d0/
   data ussm(1)/-11.9062760d0/
   data zsm(1)/1.3319670d0/
!                    DATA FOR ELEMENT  3        LITHIUM
   data alpm(3)/1.2501400d0/
   data betapm(3)/-1.3500400d0/
   data betasm(3)/-1.3500400d0/
   data gp2m(3)/4.5200000d0/
   data gppm(3)/5.0000000d0/
   data gspm(3)/5.4200000d0/
   data gssm(3)/7.3000000d0/
   data hspm(3)/0.8300000d0/
   data uppm(3)/-2.7212000d0/
   data ussm(3)/-5.1280000d0/
   data zpm(3)/0.7023800d0/
   data zsm(3)/0.7023800d0/
!                    DATA FOR ELEMENT  4        BERYLLIUM
   data alpm(4)/1.6694340d0/
   data betapm(4)/-4.0170960d0/
   data betasm(4)/-4.0170960d0/
   data gp2m(4)/6.22d00/
   data gppm(4)/6.97d00/
   data gspm(4)/7.43d00/
   data gssm(4)/9.00d00/
   data hspm(4)/1.28d00/
   data uppm(4)/-10.7037710d0/
   data ussm(4)/-16.6023780d0/
   data zpm(4)/1.0042100d0/
   data zsm(4)/1.0042100d0/
!                    DATA FOR ELEMENT  5        BORON
   data alpm(5)/2.1349930d0/
   data betapm(5)/-8.2520540d0/
   data betasm(5)/-8.2520540d0/
   data gp2m(5)/7.86d00/
   data gppm(5)/8.86d00/
   data gspm(5)/9.56d00/
   data gssm(5)/10.59d00/
   data hspm(5)/1.81d00/
   data uppm(5)/-23.1216900d0/
   data ussm(5)/-34.5471300d0/
   data zpm(5)/1.5068010d0/
   data zsm(5)/1.5068010d0/
!                    DATA FOR ELEMENT  6        CARBON
   data alpm(6)/2.5463800d0/
   data betapm(6)/-7.9341220d0/
   data betasm(6)/-18.9850440d0/
   data gp2m(6)/9.84d00/
   data gppm(6)/11.08d00/
   data gspm(6)/11.47d00/
   data gssm(6)/12.23d00/
   data hspm(6)/2.43d00/
   data polvom(6)/0.2647d0/
   data uppm(6)/-39.2055580d0/
   data ussm(6)/-52.2797450d0/
   data zpm(6)/1.7875370d0/
   data zsm(6)/1.7875370d0/
!                    DATA FOR ELEMENT  7        NITROGEN
   data alpm(7)/2.8613420d0/
   data betapm(7)/-20.4957580d0/
   data betasm(7)/-20.4957580d0/
   data gp2m(7)/11.59d00/
   data gppm(7)/12.98d00/
   data gspm(7)/12.66d00/
   data gssm(7)/13.59d00/
   data hspm(7)/3.14d00/
   data polvom(7)/0.3584d0/
   data uppm(7)/-57.1723190d0/
   data ussm(7)/-71.9321220d0/
   data zpm(7)/2.2556140d0/
   data zsm(7)/2.2556140d0/
!                    DATA FOR ELEMENT  8        OXYGEN
   data alpm(8)/3.1606040d0/
   data betapm(8)/-32.6880820d0/
   data betasm(8)/-32.6880820d0/
   data gp2m(8)/12.98d00/
   data gppm(8)/14.52d00/
   data gspm(8)/14.48d00/
   data gssm(8)/15.42d00/
   data hspm(8)/3.94d00/
   data polvom(8)/0.2324d0/
   data uppm(8)/-77.7974720d0/
   data ussm(8)/-99.6443090d0/
   data zpm(8)/2.6999050d0/
   data zsm(8)/2.6999050d0/
   data alpm(9)/3.4196606d0/
!                    DATA FOR ELEMENT  9        FLUORINE
   data betapm(9)/-36.5085400d0/
   data betasm(9)/-48.2904660d0/
   data gp2m(9)/14.91d00/
   data gppm(9)/16.71d00/
   data gspm(9)/17.25d00/
   data gssm(9)/16.92d00/
   data hspm(9)/4.83d00/
   data polvom(9)/0.1982d0/
   data uppm(9)/-105.7821370d0/
   data ussm(9)/-131.0715480d0/
   data zpm(9)/2.8484870d0/
   data zsm(9)/2.8484870d0/
      
   real(double), dimension(107) :: ussd, uppd, zsd, zpd, betasd, betapd, &
        alpd, gssd, gppd, gspd, gp2d, hspd, uddd, zdd, betadd, zsnd, zpnd, zdnd&
        , poc_mndod
      data zsm(16)/ 2.22585050D0/  
      data zpm(16)/ 2.09970560D0/  
      data zdm(16)/ 1.23147250D0/  
   
!     DATA FOR ELEMENT 16        SULFUR
      data ussd(16)/  - 56.88912800D0/  
      data uppd(16)/  - 47.27474500D0/  
      data zsd(16)/ 2.22585050D0/  
      data zpd(16)/ 2.09970560D0/  
      data betasd(16)/  - 10.99954500D0/  
      data betapd(16)/  - 12.21543700D0/  
      data alpd(16)/ 2.02305950D0/  
      data gssd(16)/ 12.19630200D0/  
      data gppd(16)/ 8.54023240D0/  
      data gspd(16)/ 8.85390090D0/  
      data gp2d(16)/ 7.54254650D0/  
      data hspd(16)/ 2.64635230D0/  
      data uddd(16)/  - 25.09511800D0/  
      data betadd(16)/  - 1.88066950D0/  
      data zsnd(16)/ 1.73639140D0/  
      data zpnd(16)/ 1.12118170D0/  
      data zdnd(16)/ 1.05084670D0/  
      data poc_mndod(16)/ 1.11550210D0/  
contains
      
    subroutine bintgs(x, k) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      ! USE vast_kind_param, ONLY:  double 
      ! USE overlaps_C, only : b, fact
!...Translated by Pacific-Sierra Research 77to90  4.4G  09:20:17  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer , intent(in) :: k 
      real(double) , intent(in) :: x 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: io, last, i, m  
      real(double) :: absx, expx, expmx, y, xf 
!-----------------------------------------------
!**********************************************************************
!
!     BINTGS FORMS THE "B" INTEGRALS FOR THE OVERLAP CALCULATION.
!
!**********************************************************************
      io = 0 
      absx = abs(x) 
      if (absx > 3.D00) go to 40 
      if (absx > 2.D00) then 
        if (k <= 10) go to 40 
        last = 15 
        go to 60 
      endif 
      if (absx > 1.D00) then 
        if (k <= 7) go to 40 
        last = 12 
        go to 60 
      endif 
      if (absx > 0.5D00) then 
        if (k <= 5) go to 40 
        last = 7 
        go to 60 
      endif 
      if (absx <= 1.D-6) go to 90 
      last = 6 
      go to 60 
   40 continue 
      expx = exp(x) 
      expmx = 1.D00/expx 
      b(1) = (expx - expmx)/x 
      do i = 1, k 
        b(i+1) = (i*b(i)+(-1.D00)**i*expx-expmx)/x 
      end do 
      go to 110 
   60 continue 
      do i = io, k 
        y = 0.0D00 
        do m = io, last 
          xf = 1.0D00 
          if (m /= 0) xf = fact(m) 
          y = y + (-x)**m*(2*mod(m + i + 1,2))/(xf*(m + i + 1)) 
        end do 
        b(i+1) = y 
      end do 
      go to 110 
   90 continue 
      do i = io, k 
        b(i+1) = (2*mod(i + 1,2))/(i + 1.D0) 
      end do 
  110 continue 
      return  
!
      end subroutine bintgs 
      
    subroutine aintgs(x, k) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      !USE vast_kind_param, ONLY:  double 
      !USE overlaps_C, only : a
!...Translated by Pacific-Sierra Research 77to90  4.4G  08:27:09  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer , intent(in) :: k 
      real(double) , intent(in) :: x 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: i 
      real(double) :: c 
!-----------------------------------------------
!***********************************************************************
!
!    AINTGS FORMS THE "A" INTEGRALS FOR THE OVERLAP CALCULATION.
!
!***********************************************************************
      c = exp((-x)) 
      a(1) = c/x 
      do i = 1, k 
        a(i+1) = (a(i)*i+c)/x 
      end do 
      return  
!
      end subroutine aintgs 
      
      subroutine set(s1, s2, na, nb, rab, ii) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      ! USE vast_kind_param, ONLY:  double 
      ! USE overlaps_C, only : isp, ips, sa, sb
!...Translated by Pacific-Sierra Research 77to90  4.4G  08:35:52  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
!-----------------------------------------------
!   I n t e r f a c e   B l o c k s
!-----------------------------------------------
      !use aintgs_I 
      !use bintgs_I 
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer , intent(in) :: na 
      integer , intent(in) :: nb 
      integer , intent(in) :: ii 
      real(double) , intent(in) :: s1 
      real(double) , intent(in) :: s2 
      real(double) , intent(in) :: rab 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: j, jcall 
      real(double) :: alpha, beta 
!-----------------------------------------------
!***********************************************************************
!
!     SET IS PART OF THE OVERLAP CALCULATION, CALLED BY OVERLP.
!         IT CALLS AINTGS AND BINTGS
!
!***********************************************************************
      if (na <= nb) then 
        isp = 1 
        ips = 2 
        sa = s1 
        sb = s2 
      else 
        isp = 2 
        ips = 1 
        sa = s2 
        sb = s1 
      endif 
      j = ii + 2 
      if (ii > 3) j = j - 1 
      alpha = 0.5D00*rab*(sa + sb) 
      beta = 0.5D00*rab*(sb - sa) 
      jcall = j - 1 
      call aintgs (alpha, jcall) 
      call bintgs (beta, jcall) 
      return  
!
      end subroutine set 

      subroutine coe(x2, y2, z2, norbi, norbj, c, r) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      ! USE vast_kind_param, ONLY:  double 
!...Translated by Pacific-Sierra Research 77to90  4.4G  10:47:04  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer , intent(in) :: norbi 
      integer , intent(in) :: norbj 
      real(double) , intent(in) :: x2 
      real(double) , intent(in) :: y2 
      real(double) , intent(in) :: z2 
      real(double) , intent(out) :: r 
      real(double) , intent(out) :: c(75) 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: nij 
      real(double) :: rt34, rt13, xy, ca, cb, sa, sb, c2a, c2b, s2a, s2b 
!-----------------------------------------------
      data rt34/ 0.86602540378444D0/  
      data rt13/ 0.57735026918963D0/  
      xy = x2**2 + y2**2 
      r = sqrt(xy + z2**2) 
      xy = sqrt(xy) 
      if (xy >= 1.D-10) then 
        ca = x2/xy 
        cb = z2/r 
        sa = y2/xy 
        sb = xy/r 
      else 
        if (z2 <= 0.D0) then 
          if (z2 /= 0.D0) then 
            ca = -1.D0 
            cb = -1.D0 
            sa = 0.D0 
            sb = 0.D0 
            go to 50 
          endif 
          ca = 0.D0 
          cb = 0.D0 
          sa = 0.D0 
          sb = 0.D0 
          go to 50 
        endif 
        ca = 1.D0 
        cb = 1.D0 
        sa = 0.D0 
        sb = 0.D0 
      endif 
   50 continue 
      c = 0.D0 
      nij = max(norbi,norbj) 
      c(37) = 1.D0 
      if (nij >= 2) then 
        c(56) = ca*cb 
        c(41) = ca*sb 
        c(26) = -sa 
        c(53) = -sb 
        c(38) = cb 
        c(23) = 0.D0 
        c(50) = sa*cb 
        c(35) = sa*sb 
        c(20) = ca 
        if (nij >= 5) then 
          c2a = 2*ca*ca - 1.D0 
          c2b = 2*cb*cb - 1.D0 
          s2a = 2*sa*ca 
          s2b = 2*sb*cb 
          c(75) = c2a*cb*cb + 0.5D0*c2a*sb*sb 
          c(60) = 0.5D0*c2a*s2b 
          c(45) = rt34*c2a*sb*sb 
          c(30) = -s2a*sb 
          c(15) = -s2a*cb 
          c(72) = -0.5D0*ca*s2b 
          c(57) = ca*c2b 
          c(42) = rt34*ca*s2b 
          c(27) = -sa*cb 
          c(12) = sa*sb 
          c(69) = rt13*sb*sb*1.5D0 
          c(54) = -rt34*s2b 
          c(39) = cb*cb - 0.5D0*sb*sb 
          c(66) = -0.5D0*sa*s2b 
          c(51) = sa*c2b 
          c(36) = rt34*sa*s2b 
          c(21) = ca*cb 
          c(6) = -ca*sb 
          c(63) = s2a*cb*cb + 0.5D0*s2a*sb*sb 
          c(48) = 0.5D0*s2a*s2b 
          c(33) = rt34*s2a*sb*sb 
          c(18) = c2a*sb 
          c(3) = c2a*cb 
        endif 
      endif 
      return  
end subroutine coe 

subroutine bfn(x, bf) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
!...Translated by Pacific-Sierra Research 77to90  4.4G  10:47:01  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      real(double) , intent(in) :: x 
      real(double) , intent(out) :: bf(13) 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: k, io, last, i, m 
      real(double) :: absx, expx, expmx, y, xf 
!-----------------------------------------------
!**********************************************************************
!
!     BINTGS FORMS THE "B" INTEGRALS FOR THE OVERLAP CALCULATION.
!
!**********************************************************************
      k = 12 
      io = 0 
      absx = abs(x) 
      if (absx <= 3.D00) then 
        if (absx > 2.D00) then 
          last = 15 
          go to 60 
        endif 
        if (absx > 1.D00) then 
          last = 12 
          go to 60 
        endif 
        if (absx > 0.5D00) then 
          last = 7 
          go to 60 
        endif 
        if (absx <= 1.D-6) go to 90 
        last = 6 
        go to 60 
      endif 
      expx = exp(x) 
      expmx = 1.D00/expx 
      bf(1) = (expx - expmx)/x 
      do i = 1, k 
        bf(i+1) = (i*bf(i)+(-1.D00)**i*expx-expmx)/x 
      end do 
      go to 110 
   60 continue 
      do i = io, k 
        y = 0.0D00 
        do m = io, last 
          xf = 1.0D00 
          if (m /= 0) xf = fact(m) 
          y = y + (-x)**m*(2*mod(m + i + 1,2))/(xf*(m + i + 1)) 
        end do 
        bf(i+1) = y 
      end do 
      go to 110 
   90 continue 
      do i = io, k 
        bf(i+1) = (2*mod(i + 1,2))/(i + 1.D0) 
      end do 
  110 continue 
      return  
!
end subroutine bfn 



real(double) function ss (na, nb, la1, lb1, m1, ua, ub, r1, a0) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      ! USE vast_kind_param, ONLY:  double 
      ! use overlaps_C, only : fact
!...Translated by Pacific-Sierra Research 77to90  4.4G  11:05:02  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
!-----------------------------------------------
!   I n t e r f a c e   B l o c k s
!-----------------------------------------------
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer , intent(in) :: na 
      integer , intent(in) :: nb 
      integer , intent(in) :: la1 
      integer , intent(in) :: lb1 
      integer , intent(in) :: m1 
      real(double) , intent(in) :: ua 
      real(double) , intent(in) :: ub 
      real(double) , intent(in) :: r1 
      real(double) , intent(in) :: a0 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: m, lb, la, i, i1, j, n, lam1, lbm1, ia, ic, ib, id, iab, k1, &
        k2, k3, k4, k5, iaf, k6, ibf 
      real(double), dimension(0:2,0:2,0:2) :: aff 
      real(double), dimension(0:19) :: af, bf 
      real(double), dimension(0:12,0:12) :: bi 
      real(double) :: r, p, b, quo, sum, sum1 
      logical :: first 

      save first, aff, bi 
!-----------------------------------------------
      data first/ .TRUE./  
      data aff/ 27*0.D0/   
      m = m1 - 1 
      lb = lb1 - 1 
      la = la1 - 1 
      r = r1/a0 
      if (first) then 
        first = .FALSE. 
!
!           INITIALISE SOME CONSTANTS
!
!                  BINOMIALS
!
        do i = 0, 12 
          bi(i,0) = 1.D0 
          bi(i,i) = 1.D0 
        end do 
        do i = 0, 11 
          i1 = i - 1 
          bi(i+1,1:i1+1) = bi(i,1:i1+1) + bi(i,:i1) 
        end do 
        aff(0,0,0) = 1.D0 
        aff(1,0,0) = 1.D0 
        aff(1,1,0) = sqrt(0.5D0) 
        aff(2,0,0) = 1.5D0 
        aff(2,1,0) = sqrt(1.5D0) 
        aff(2,2,0) = sqrt(0.375D0) 
!
!   AFF(2,0,2) CORRESPONDS TO C(2,0,1) IN THE MANUAL
!
        aff(2,0,2) = -0.5D0 
      endif 
      p = (ua + ub)*r*0.5D0 
      b = (ua - ub)*r*0.5D0 
      quo = 1/p 
      af(0) = quo*exp((-p)) 
      do n = 1, 19 
        af(n) = n*quo*af(n-1) + af(0) 
      end do 
      call bfn (b, bf) 
      sum = 0.D0 
      lam1 = la - m 
      lbm1 = lb - m 
!
!          START OF OVERLAP CALCULATION PROPER
!
      do i = 0, lam1, 2 
        ia = na + i - la 
        ic = la - i - m 
        do j = 0, lbm1, 2 
          ib = nb + j - lb 
          id = lb - j - m 
          sum1 = 0.D0 
          iab = ia + ib 
!
!   In the Manual ka = K6
!                 kb = K5
!                 Pa = K1
!                 Pb = K2
!                 qa = K3
!                 qb = K4
!
          do k1 = 0, ia 
            do k2 = 0, ib 
              do k3 = 0, ic 
                do k4 = 0, id 
                  do k5 = 0, m 
                    iaf = iab - k1 - k2 + k3 + k4 + 2*k5 
                    do k6 = 0, m 
                      ibf = k1 + k2 + k3 + k4 + 2*k6 
                      sum1 = sum1 + bi(id,k4)*bi(ic,k3)*bi(ib,k2)*bi(ia,k1)*bi(&
                        m,k5)*bi(m,k6)*(1 - 2*mod(m + k2 + k4 + k5 + k6,2))*af(&
                        iaf)*bf(ibf) 
                    end do 
                  end do 
                end do 
              end do 
            end do 
          end do 
          sum = sum + sum1*aff(la,m,i)*aff(lb,m,j) 
        end do 
      end do 
      ss = sum*r**(na + nb + 1)*ua**na*ub**nb/2.D0*sqrt(ua*ub/(fact(na+na)*fact(nb+&
        nb))*((la+la+1)*(lb+lb+1))) 
      return  
end function ss 

subroutine diat(ni, nj, xj, di) 
      
      ! use coe_I 
      ! use gover_I 
      ! use diat2_I 
      ! use ss_I 
      ! use molkst_C, only : numcal, keywrd
      ! use funcon_C, only : a0
      ! use overlaps_C, only : cutof1
      ! use parameters_C, only : natorb, zs, zp, zd

      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer  :: ni 
      integer  :: nj 
      double precision :: xj(3) 
      double precision :: di(9,9) 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: a, pq2, b, pq1 
      integer , dimension(107,3) :: npq 
      integer , dimension(3,5) :: ival 
      ! integer :: icalcn 
      integer :: i, j, ia, ib, newk, nk1, iss, jss, k, kss, kmin, kmax, lmin, &
        lmax, l, ii, jj, pi, pj
      double precision, dimension(3,3,3) :: s 
      double precision, dimension(3) :: ul1, ul2 
      double precision, dimension(3,5,5) :: c 
      double precision, dimension(27) :: slin 
      double precision, dimension(3,5) :: c1, c2, c3, c4, c5 
      double precision, dimension(3,3) :: s1, s2, s3 
      double precision :: x2, y2, z2, r, aa, bb 
      logical :: analyt 

      ! save npq, ival, analyt, icalcn 
!-----------------------------------------------
!***********************************************************************
!
!   DIAT CALCULATES THE DI-ATOMIC OVERLAP INTEGRALS BETWEEN ATOMS
!        OF ATOMIC NUMBER NI AND NJ, WHERE NJ IS AT POSITION
!        XJ RELATIVE TO NI.
!
!   ON INPUT NI  = ATOMIC NUMBER OF THE FIRST ATOM.
!            NJ  = ATOMIC NUMBER OF THE SECOND ATOM.
!            XJ  = CARTESIAN COORDINATES OF THE SECOND ATOM,
!                  RELATIVE TO THE FIRST ATOM.
!
!  ON OUTPUT DI  = DIATOMIC OVERLAP, IN A 9 * 9 MATRIX. LAYOUT OF
!                  ATOMIC ORBITALS IN DI IS
!                  1   2   3   4   5            6     7       8     9
!                  S   PX  PY  PZ  D(X**2-Y**2) D(XZ) D(Z**2) D(YZ)D(XY)
!
!   LIMITATIONS:  IN THIS FORMULATION, NI AND NJ MUST BE LESS THAN 107
!         EXPONENTS ARE ASSUMED TO BE PRESENT IN COMMON BLOCK EXPONT.
!
!***********************************************************************
      equivalence (slin(1), s(1,1,1)) 
      equivalence (c1(1,1), c(1,1,1)), (c2(1,1), c(1,1,2)), (c3(1,1), c(1,1,3))&
        , (c4(1,1), c(1,1,4)), (c5(1,1), c(1,1,5)), (s1(1,1), s(1,1,1)), (s2(1,&
        1), s(1,1,2)), (s3(1,1), s(1,1,3)) 
      data npq(:,1)/ 1, 0, 2, 2, 2, 2, 2, 2, 2, 0, 3, 3, 3, 3, 3, 3, 3, 0, 4, 4, 4&
        , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 5, 5, 5, 5, 5, 5, 5, 5, &
        5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 6, 6, 14*6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6&
        , 6, 6, 6, 6, 6, 0, 15*0, 3, 5*0/  
!
!   Principal Quantum Numbers for the "p" shell
!
      data npq(:,2)/ 1, 0, 2, 2, 2, 2, 2, 2, 2, 0, 3, 3, 3, 3, 3, 3, 3, 0, 4, 4, 4&
        , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 5, 5, 5, 5, 5, 5, 5, 5, &
        5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 6, 6, 14*6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6&
        , 6, 6, 6, 6, 6, 0, 21*0/  
!
!   Principal Quantum Numbers for the "d" shell
!
      data npq(:,3)/ 1, 0, 2, 2, 2, 2, 2, 2, 2, 0, 3, 3, 3, 3, 3, 3, 3, 0, 3, 3, 3&
        , 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 0, 4, 4, 4, 4, 4, 4, 4, 4, &
        4, 4, 4, 5, 5, 5, 5, 5, 5, 0, 5, 5, 14*5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6&
        , 6, 6, 6, 6, 6, 0, 21*0/  
      data ival/ 1, 0, 9, 1, 3, 8, 1, 4, 7, 1, 2, 6, 0, 0, 5/  
        zs = zsm
        zp = zpm
        zd = zdm
      ! ta icalcn/ 0/  
      !ASC if (icalcn /= numcal) then  
      !ASC   analyt = index(keywrd,'ANALYT') /= 0 
      !ASC   icalcn = numcal 
      !ASC endif 
      analyt = .false. 
      x2 = xj(1) 
      y2 = xj(2) 
      z2 = xj(3) 
      pq1 = npq(ni,1) 
      pq2 = npq(nj,1) 
      di = 0.0D0 
      r = x2**2 + y2**2 + z2**2 
      if (pq1==0 .or. pq2==0 .or. r>=cutof1) return  
      if (natorb(ni)==0 .or. natorb(nj)==0) return  
      call coe (x2, y2, z2, natorb(ni), natorb(nj), c, r) 
      if (r < 0.001D0) return  
      ia = min(pq1 + 1,3) 
      ib = min(pq2 + 1,3) 
      a = ia - 1 
      b = ib - 1 
      if (ni<18 .and. nj<18 .and. natorb(ni)<5 .and. natorb(nj)<5) then 
        ! write (*,*) "DIAT1", zs(ni), zp(ni),natorb(ni),natorb(nj)
          call diat2 (ni, zs(ni), zp(ni), r, nj, zs(nj), zp(nj), s, a0) 
      else 
        ! write (*,*) "DIAT2"
        ul1(1) = zs(ni) 
        ul2(1) = zs(nj) 
        ul1(2) = zp(ni) 
        ul2(2) = zp(nj) 
        ul1(3) = max(zd(ni),0.3D0) 
        ul2(3) = max(zd(nj),0.3D0)
       ! write (*,*) "UL", ul1(:3) 
       ! write (*,*) "UL", ul2(:3) 
        slin = 0.0D0 
        newk = min(a,b) 
        nk1 = newk + 1 
        do i = 1, ia 
          iss = i 
          ib = b + 1 
          pq1 = npq(ni,i) 
          do j = 1, ib 
            jss = j 
            pq2 = npq(nj,j) 
            do k = 1, nk1 
              if (k>i .or. k>j) cycle  
              kss = k
              pi = max(pq1,iss)
              pj = max(pq2,jss)
              s(i,j,k) = ss(pi,pj,iss,jss,kss,ul1(i),ul2(j)&
                ,r,a0) 
            end do 
          end do 
        end do 
      endif 
      do i = 1, ia 
        kmin = 4 - i 
        kmax = 2 + i 
        do j = 1, ib 
          if (j == 2) then 
            aa = -1.D0 
            bb = 1.D0 
          else 
            aa = 1.D0 
            if (j == 3) then 
              bb = -1.D0 
            else 
              bb = 1.D0 
            endif 
          endif 
          lmin = 4 - j 
          lmax = 2 + j 
          do k = kmin, kmax 
            do l = lmin, lmax 
              ii = ival(i,k) 
              jj = ival(j,l) 
              di(ii,jj) = s1(i,j)*(c3(i,k)*c3(j,l))*aa + (c4(i,k)*c4(j,l)+c2(i,&
                k)*c2(j,l))*bb*s2(i,j) + (c5(i,k)*c5(j,l)+c1(i,k)*c1(j,l))*s3(i&
                ,j) 
            end do 
          end do 
        end do 
      end do 
      return  
      end subroutine diat 

      subroutine diat2(na, esa, epa, r12, nb, esb, epb, s, a0) 
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      ! USE vast_kind_param, ONLY:  double 
      ! USE overlaps_C, only : sa, sb, a, b, isp, ips
!...Translated by Pacific-Sierra Research 77to90  4.4G  10:47:08  03/09/06  
!...Switches: -rl INDDO=2 INDIF=2 
!-----------------------------------------------
!   I n t e r f a c e   B l o c k s
!-----------------------------------------------
      ! use set_I 
      implicit none
!-----------------------------------------------
!   D u m m y   A r g u m e n t s
!-----------------------------------------------
      integer  :: na 
      integer  :: nb 
      real(double)  :: esa 
      real(double)  :: epa 
      real(double) , intent(in) :: r12 
      real(double)  :: esb 
      real(double)  :: epb 
      real(double) , intent(in) :: a0 
      real(double) , intent(inout) :: s(3,3,3) 
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer , dimension(17) :: inmb 
      integer , dimension(78) :: iii 
      integer :: jmax, jmin, nbond, ii
      real(double) :: rab, rab4, w, rt3, d, e, rab6 

      save inmb, iii 
!-----------------------------------------------
!***********************************************************************
!
! OVERLP CALCULATES OVERLAPS BETWEEN ATOMIC ORBITALS FOR PAIRS OF ATOMS
!        IT CAN HANDLE THE ORBITALS 1S, 2S, 3S, 2P, AND 3P.
!
!***********************************************************************
      data inmb/ 1, 0, 2, 2, 3, 4, 5, 6, 7, 0, 8, 8, 8, 9, 10, 11, 12/  
!     NUMBERING CORRESPONDS TO BOND TYPE MATRIX GIVEN ABOVE
!      THE CODE IS
!
!     III=1      FIRST - FIRST  ROW ELEMENTS
!        =2      FIRST - SECOND
!        =3      FIRST - THIRD
!        =4      SECOND - SECOND
!        =5      SECOND - THIRD
!        =6      THIRD - THIRD
      data iii/ 1, 2, 4, 2, 4, 4, 2, 4, 4, 4, 2, 4, 4, 4, 4, 2, 4, 4, 4, 4, 4, &
        2, 4, 4, 4, 4, 4, 4, 3, 5, 5, 5, 5, 5, 5, 6, 3, 5, 5, 5, 5, 5, 5, 6, 6&
        , 3, 5, 5, 5, 5, 5, 5, 6, 6, 6, 3, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 3, 5, &
        5, 5, 5, 5, 5, 6, 6, 6, 6, 6/  
!
!      ASSIGNS BOND NUMBER
!
      jmax = max0(inmb(na),inmb(nb)) 
      jmin = min0(inmb(na),inmb(nb)) 
      nbond = (jmax*(jmax - 1))/2 + jmin 
      ii = iii(nbond) 
      s = 0.D0 
      rab = r12/a0 
      select case (ii)  
!
!     ------------------------------------------------------------------
! *** THE ORDERING OF THE ELEMENTS WITHIN S IS
! *** S(1,1,1)=(S(B)/S(A))
! *** S(1,2,1)=(P-SIGMA(B)/S(A))
! *** S(2,1,1)=(S(B)/P-SIGMA(A))
! *** S(2,2,1)=(P-SIGMA(B)/P-SIGMA(A))
! *** S(2,2,2)=(P-PI(B)/P-PI(A))
!     ------------------------------------------------------------------
! *** FIRST ROW - FIRST ROW OVERLAPS
!
      case default 
        ! write (*,*) esa, esb, na, nb, rab, ii
        call set (esa, esb, na, nb, rab, ii) 
        s(1,1,1) = .25D0*sqrt((sa*sb*rab*rab)**3)*(a(3)*b(1)-b(3)*a(1)) 
        
        ! write (*,*) sa, sb, rab, a(1), a(3), b(1), b(3)
        return  
!
! *** FIRST ROW - SECOND ROW OVERLAPS
!
      case (2)  
        call set (esa, esb, na, nb, rab, ii) 
        rab4 = rab**4*0.125D00 
        w = sqrt(sa**3*sb**5)*rab4 
        s(1,1,1) = sqrt(1.D00/3.D00) 
        s(1,1,1) = w*s(1,1,1)*(a(4)*b(1)-b(4)*a(1)+a(3)*b(2)-b(3)*a(2)) 
        if (na > 1) call set (epa, esb, na, nb, rab, ii) 
        if (nb > 1) call set (esa, epb, na, nb, rab, ii) 
        w = sqrt(sa**3*sb**5)*rab4 
        s(isp,ips,1) = w*(a(3)*b(1)-b(3)*a(1)+a(4)*b(2)-b(4)*a(2)) 
        return  
!
! *** FIRST ROW - THIRD ROW OVERLAPS
!
      case (3)  
        call set (esa, esb, na, nb, rab, ii) 
        rab4 = rab**5*0.0625D00 
        w = sqrt(sa**3*sb**7/22.5D00)*rab4 
        s(1,1,1) = w*(a(5)*b(1)-b(5)*a(1)+(a(4)*b(2)-b(4)*a(2))*2.D0) 
        if (na > 1) call set (epa, esb, na, nb, rab, ii) 
        if (nb > 1) call set (esa, epb, na, nb, rab, ii) 
        w = sqrt(sa**3*sb**7/7.5D00)*rab4 
        s(isp,ips,1) = w*(a(4)*(b(1)+b(3))-b(4)*(a(1)+a(3))+b(2)*(a(3)+a(5))-a(&
          2)*(b(3)+b(5))) 
        return  
!
! *** SECOND ROW - SECOND ROW OVERLAPS
!
      case (4)  
        call set (esa, esb, na, nb, rab, ii) 
        rab4 = rab**5*0.0625D00 
        w = sqrt((sa*sb)**5)*rab4 
        s(1,1,1) = w*(a(5)*b(1)+b(5)*a(1)-2.0D00*a(3)*b(3))/3.0D00 
        call set (esa, epb, na, nb, rab, ii) 
        if (na > nb) call set (epa, esb, na, nb, rab, ii) 
        w = sqrt((sa*sb)**5)*rab4 
        rt3 = 1.D00/sqrt(3.D00) 
        d = a(4)*(b(1)-b(3)) - a(2)*(b(3)-b(5)) 
        e = b(4)*(a(1)-a(3)) - b(2)*(a(3)-a(5)) 
        s(isp,ips,1) = w*rt3*(d + e) 
        call set (epa, esb, na, nb, rab, ii) 
        if (na > nb) call set (esa, epb, na, nb, rab, ii) 
        w = sqrt((sa*sb)**5)*rab4 
        d = a(4)*(b(1)-b(3)) - a(2)*(b(3)-b(5)) 
        e = b(4)*(a(1)-a(3)) - b(2)*(a(3)-a(5)) 
        s(ips,isp,1) = w*rt3*(d - e) 
        call set (epa, epb, na, nb, rab, ii) 
        w = sqrt((sa*sb)**5)*rab4 
        s(2,2,1) = -w*(b(3)*(a(5)+a(1))-a(3)*(b(5)+b(1))) 
        s(2,2,2) = 0.5D0*w*(a(5)*(b(1)-b(3))-b(5)*(a(1)-a(3))-a(3)*b(1)+b(3)*a(&
          1)) 
        return  
!
! *** SECOND ROW - THIRD ROW OVERLAPS
!
      case (5)  
        call set (esa, esb, na, nb, rab, ii) 
        rab6 = rab**6*0.03125D0/sqrt(7.5D0) 
        w = sqrt(sa**5*sb**7)*rab6 
        rt3 = 1.D00/sqrt(3.D00) 
        s(1,1,1) = w*(a(6)*b(1)+a(5)*b(2)-2.D0*(a(4)*b(3)+a(3)*b(4))+a(2)*b(5)+&
          a(1)*b(6))/3.D00 
!
        call set (esa, epb, na, nb, rab, ii) 
        if (na > nb) call set (epa, esb, na, nb, rab, ii) 
        w = sqrt(sa**5*sb**7)*rab6 
        s(isp,ips,1) = w*rt3*(a(6)*b(2)+a(5)*b(1)-2.D0*(a(4)*b(4)+a(3)*b(3))+a(&
          2)*b(6)+a(1)*b(5)) 
!
        call set (epa, esb, na, nb, rab, ii) 
        if (na > nb) call set (esa, epb, na, nb, rab, ii) 
        w = sqrt(sa**5*sb**7)*rab6 
        s(ips,isp,1) = -w*rt3*(a(5)*(2.D0*b(3)-b(1))-b(5)*(2.D0*a(3)-a(1))-a(2)&
          *(b(6)-2.D0*b(4))+b(2)*(a(6)-2.D0*a(4))) 
!
        call set (epa, epb, na, nb, rab, ii) 
        w = sqrt(sa**5*sb**7)*rab6 
        s(2,2,1) = -w*(b(4)*(a(1)+a(5))-a(4)*(b(1)+b(5))+b(3)*(a(2)+a(6))-a(3)*&
          (b(2)+b(6))) 
        s(2,2,2) = 0.5D0*w*(a(6)*(b(1)-b(3))-b(6)*(a(1)-a(3))+a(5)*(b(2)-b(4))-&
          b(5)*(a(2)-a(4))-a(4)*b(1)+b(4)*a(1)-a(3)*b(2)+b(3)*a(2)) 
        return  
!
! *** THIRD ROW - THIRD ROW OVERLAPS
!
      case (6)  
        call set (esa, esb, na, nb, rab, ii) 
        rab4 = rab**7/480.D00 
        w = sqrt((sa*sb)**7)*rab4 
        rt3 = 1.D00/sqrt(3.D00) 
        s(1,1,1) = w*(a(7)*b(1)-3.D00*(a(5)*b(3)-a(3)*b(5))-a(1)*b(7))/3.D00 
        call set (esa, epb, na, nb, rab, ii) 
        if (na > nb) call set (epa, esb, na, nb, rab, ii) 
        w = sqrt((sa*sb)**7)*rab4 
        d = a(6)*(b(1)-b(3)) - 2.D00*a(4)*(b(3)-b(5)) + a(2)*(b(5)-b(7)) 
        e = b(6)*(a(1)-a(3)) - 2.D00*b(4)*(a(3)-a(5)) + b(2)*(a(5)-a(7)) 
        s(isp,ips,1) = w*rt3*(d - e) 
        call set (epa, esb, na, nb, rab, ii) 
        if (na > nb) call set (esa, epb, na, nb, rab, ii) 
        w = sqrt((sa*sb)**7)*rab4 
        d = a(6)*(b(1)-b(3)) - 2.D00*a(4)*(b(3)-b(5)) + a(2)*(b(5)-b(7)) 
        e = b(6)*(a(1)-a(3)) - 2.D00*b(4)*(a(3)-a(5)) + b(2)*(a(5)-a(7)) 
        s(ips,isp,1) = -w*rt3*((-d) - e) 
        call set (epa, epb, na, nb, rab, ii) 
        w = sqrt((sa*sb)**7)*rab4 
        d = a(3)*(b(7)+b(3)+b(3)) - a(5)*(b(1)+b(5)+b(5)) - b(5)*a(1) + a(7)*b(&
          3) 
        s(2,2,1) = -w*d 
        d = a(7)*(b(1)-b(3)) + b(7)*(a(1)-a(3)) 
        e = a(5)*(b(5)-b(3)-b(1)) + b(5)*(a(5)-a(3)-a(1)) + 2.D0*a(3)*b(3) 
        s(2,2,2) = 0.5D0*w*(d + e) 
        return  
      end select 
!
      end subroutine diat2 

subroutine get_overlaps(ni, nj, rij, smat)

    implicit none

    integer, intent(in) :: ni
    integer, intent(in) :: nj
    !double precision, dimension(3), intent(in) :: zi
    !double precision, dimension(3), intent(in) :: zj
    double precision, dimension(3), intent(in) :: rij

    double precision, dimension(9,9), intent(out) :: smat
 
    smat = 0.0d0
    natorb = natspd
    ! write (*,*) "DIAT01"
    call diat(ni, nj, rij, smat)
    ! write (*,*) "DIAT02"
end subroutine get_overlaps


end module mopac_overlap_integrals
