program test_thermal_solver

    use iso_fortran_env, only: real64
    use thermal_solver_module

    implicit none

    ! inputs numériques
    integer :: nombre_points, max_iterations
    real(real64) :: tolerance 

    ! inputs physiques
    real(real64) :: conductivite, temperature_bord, longueur, &
                                source_volumique

    ! outputs numériques
    integer :: nombre_iterations, position_maximum(3), &
               statut
    real(real64) :: erreur_convergence

    ! outputs physiques
    real(real64), allocatable :: temperature(:, :, :)
    real(real64) :: temperature_minimale, temperature_maximale, &
                    temperature_moyenne    
    
    ! Paramètres
    nombre_points = 11
    longueur = 0.01_real64
    conductivite = 50.0_real64
    source_volumique = 1.0e8_real64
    temperature_bord = 300.0_real64
    tolerance = 1.0e-8_real64
    max_iterations = 100000

    allocate(temperature(nombre_points,nombre_points,nombre_points))
    temperature = 0.0_real64

    call champ_thermique(nombre_points, longueur, conductivite, & 
        source_volumique, temperature_bord, tolerance, max_iterations, & 
        temperature, temperature_minimale, temperature_maximale, & 
        temperature_moyenne, position_maximum, nombre_iterations, &
        erreur_convergence, statut)
    
    ! Variables résultats
    print*, "Statut :", statut
    print *, "Iterations :", nombre_iterations
    print *, "Erreur convergence :", erreur_convergence
    print *, "Temperature minimale :", temperature_minimale, "K"
    print *, "Temperature maximale :", temperature_maximale, "K"
    print *, "Temperature moyenne :", temperature_moyenne, "K"
    print *, "Position du maximum :", position_maximum
    
    deallocate(temperature)
    
end program test_thermal_solver