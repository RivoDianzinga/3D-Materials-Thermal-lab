# Compilateur Fortran
FC = gfortran

# Options de compilation pour le développement
FFLAGS = -Wall -Wextra -fcheck=all -fbacktrace -g

# Exécutable final
TARGET = test_thermal_solver.exe

# Fichiers objets
OBJS = thermal_solver_module.o \
       test_thermal_solver.o


# Cible par défaut
all: $(TARGET)


# Édition de liens
$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) -o $(TARGET) $(OBJS)


# Compilation du module scientifique
thermal_solver_module.o: thermal_solver_module.f90
	$(FC) $(FFLAGS) -c thermal_solver_module.f90


# Le programme de test dépend du module
test_thermal_solver.o: test_thermal_solver.f90 thermal_solver_module.o
	$(FC) $(FFLAGS) -c test_thermal_solver.f90


# Exécuter le test
run: $(TARGET)
	./$(TARGET)


# Nettoyage des artefacts de compilation
clean:
	rm -f *.o *.mod $(TARGET)


.PHONY: all run clean