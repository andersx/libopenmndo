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

module readinput

    implicit none

    
contains

function get_atomtype(atomname) result(atomtype)

    implicit none

    character(len=2) :: atomname
    integer :: atomtype

    atomtype = -1

    select case (atomname)
        case ("H "); atomtype = 1
        case ("He"); atomtype = 2
        case ("Li"); atomtype = 3
        case ("Be"); atomtype = 4
        case ("B "); atomtype = 5
        case ("C "); atomtype = 6
        case ("N "); atomtype = 7
        case ("O "); atomtype = 8
        case ("F "); atomtype = 9
        case ("Ne"); atomtype = 10
        case ("S "); atomtype = 16
        case default; atomtype = -1
    end select

end function get_atomtype

subroutine parse_xyz(filename, n, coordinates , atomtypes)
    
    implicit none

    character(len=32), intent(in) :: filename

    integer, intent(out) :: n
    double precision, dimension(:,:), allocatable, intent(out) :: coordinates
    integer, dimension(:), allocatable, intent(out) :: atomtypes 

    integer :: i
    character :: title
    character(len=2) :: atom_type
    double precision :: x, y, z

    open(unit=1, file=filename)
    read(1,*) n
    read(1,'(a)') title

    allocate(coordinates(3,n))
    allocate(atomtypes(n))

    do i=1, n
    
        read(1,*) atom_type, x, y, z

        coordinates(1,i) = x
        coordinates(2,i) = y
        coordinates(3,i) = z

        atomtypes(i) = get_atomtype(atom_type)

    enddo


end subroutine parse_xyz

end module readinput
