F90= ifort
FLAGS = -O2 -W0 -assume byterecl -traceback
#swch = -unix -f95 -timg -impi

SWAN_EXE = swan.exe

SWAN_OBJS = \
swmod1.o swmod2.o swmod3.o swanmain.o swanpre1.o swanpre2.o swancom1.o \
swancom2.o swancom3.o swancom4.o swancom5.o swanout1.o swanout2.o swanser.o \
swanparll.o ocpids.o ocpcre.o ocpmix.o addlmean.o  restorem.o backupm.o \
Dispersion_Relations.o EnDissTerms.o SWMUD.o Roots.o

ser: $(SWAN_OBJS)
	$(F90)  $(SWAN_OBJS) -o swan.exe

%.o: %.for
	$(F90) -c $(FLAGS) $<
%.o: %.f90
	$(F90) -c $(FLAGS) $<
clean:
	rm -rf *.o *.mod swan.exe

