all: test

test: src/test.f90 readinput.o mopac_overlap_integrals.o
	gfortran -O3 src/test.f90 -o test readinput.o mopac_overlap_integrals.o

readinput.o: src/readinput.f90
	gfortran -O3 -c src/readinput.f90

mopac_overlap_integrals.o: src/mopac_overlap_integrals.f90
	gfortran -O3 -c src/mopac_overlap_integrals.f90
clean:
	rm -f *.mod
	rm -f *.o
	rm -f test

# test:
# 	./test water.xyz
