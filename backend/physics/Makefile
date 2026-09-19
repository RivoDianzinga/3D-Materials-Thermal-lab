# ============================================================
# Compilateurs
# ============================================================

FC  = gfortran
CXX = g++


# ============================================================
# Options de compilation
# ============================================================

FFLAGS   = -Wall -Wextra -fcheck=all -fbacktrace -g
CXXFLAGS = -Wall -Wextra -g


# ============================================================
# Répertoires où se trouvent les fichiers à compiler
# ============================================================

FORTRAN_DIR = fortran
CPP_DIR     = cpp


# ============================================================
# Exécutables qu'on veut créer, chacun des exécutables étant 
# un target et étant un programme main
# ============================================================

TEST_TARGET   = test_fortran_bridge.exe
ENGINE_TARGET = thermal_engine.exe


# ============================================================
# Objets communs qui sont toutes les routines nécessaires 
# aux programmes main. Ces routines sont ici en format *.o.
# On les classe par ordre de dépendance : celle d'en bas 
# dépend de celle d'en haut.
# ============================================================

COMMON_OBJS = thermal_solver_module.o \
              thermal_c_interface.o


# ============================================================
# Cible par défaut : on cible tous les target des exécutables
# ============================================================

all: $(TEST_TARGET) $(ENGINE_TARGET)


# ============================================================
# Exécutable de test
# ============================================================

$(TEST_TARGET): $(COMMON_OBJS) test_fortran_bridge.o
	$(FC) $(COMMON_OBJS) test_fortran_bridge.o \
	-lstdc++ -o $(TEST_TARGET)


# ============================================================
# Exécutable applicatif
# ============================================================

$(ENGINE_TARGET): $(COMMON_OBJS) thermal_engine.o
	$(FC) $(COMMON_OBJS) thermal_engine.o \
	-lstdc++ -o $(ENGINE_TARGET)


# ============================================================
# Compilation Fortran
# ============================================================

thermal_solver_module.o: $(FORTRAN_DIR)/thermal_solver_module.f90
	$(FC) $(FFLAGS) -c $<


thermal_c_interface.o: \
$(FORTRAN_DIR)/thermal_c_interface.f90 \
thermal_solver_module.o
	$(FC) $(FFLAGS) -c $<


# ============================================================
# Compilation C++
# ============================================================

test_fortran_bridge.o: $(CPP_DIR)/test_fortran_bridge.cpp
	$(CXX) $(CXXFLAGS) -c $<


thermal_engine.o: $(CPP_DIR)/thermal_engine.cpp
	$(CXX) $(CXXFLAGS) -c $<


# ============================================================
# Exécution : on exécute chaque exécutable par sa commande
# ============================================================

run-test: $(TEST_TARGET)
	./$(TEST_TARGET)

# Paramétrisation avec valeurs de référence, l'exécutable est 
# créé avec des valeurs par défauts pour un cas de référence, 
# toutefois pouvant calculer avec d'autres valeurs
N ?= 11
L ?= 0.01
K ?= 50.0
Q ?= 1e8
TBORD ?= 300.0
TOL ?= 1e-8
MAX_ITERATIONS ?= 10000

run-engine: $(ENGINE_TARGET)
	./$(ENGINE_TARGET) $(N) $(L) $(K) $(Q) $(TBORD) $(TOL) $(MAX_ITERATIONS)


# ============================================================
# Nettoyage
# ============================================================

clean:
	rm -f *.o *.mod *.exe


# ============================================================
# Rebuild complet
# ============================================================

rebuild: clean all


.PHONY: all clean rebuild run-test run-engine