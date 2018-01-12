! MIT License
!
! Copyright (c) 2017 Anders Steen Christensen
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.

program test

    use readinput, only: parse_xyz
    use mopac_overlap_integrals, only: get_overlaps
    implicit none
    
    character(len=32) :: arg
    
    double precision, dimension(:,:), allocatable :: coordinates
    integer, dimension(:), allocatable :: atomtypes 
    integer :: n, i
    integer :: atom_i, atom_j
    double precision, dimension(3) :: rij

    double precision, dimension(9,9) :: smat
    CALL getarg(1, arg)
    open(unit=1, file=arg)

    call parse_xyz(arg, n, coordinates, atomtypes)

    rij(:) = coordinates(:,1) - coordinates(:,3)
    write (*,*) n 
    do i = 1, n
    write (*,*) atomtypes(i), coordinates(:,i)
    enddo 
    
    do atom_i = 1, n
        do atom_j = atom_i + 1, n 
    
            rij(:) = coordinates(:,atom_i)- coordinates(:,atom_j)
            
            call get_overlaps(atomtypes(atom_i), atomtypes(atom_j), rij, smat)
        
            write (*,*) "==================="
            write (*,*) "OVERLAPS", atomtypes(atom_i), atomtypes(atom_j), atom_i, atom_j, rij

            do i = 1, 9
                write (*,"(9F8.5)") smat(:,i)
            enddo
            write (*,*) "==================="
        enddo
    enddo

    

end program test

