! Il est question d'utiliser Java dans la partie application.
! Toutefois, Java ne communique pas confortablement avec Fortran.
! Il faut donc une interface C/C++ : Java <---> C/C++ <---> Fortran.
! Ce module permet de convertir la routine fortran "champ_thermique"
! en une routine écrite en C. C'est le step 2 de notre application.
! Autrement dit, "champ_thermique" est la routine en fortran, et 
! "solver_thermal_c" est son équivalent en langage C.
! C++ et Fortran étant liés dans le mème exécutable, leur 
! communication repose sur l'interface native 
! iso_c_binding 

module thermal_c_interface_module

    use iso_c_binding, only: c_int, c_double
    use iso_fortran_env, only: real64
    use thermal_solver_module, only: champ_thermique

    ! use iso_c_binding nous fournit les types compatibles :
    ! Fortran                   C/C++
    ! integer(c_int)  <------>  int
    ! real(c_double)  <------>  double
    
    implicit none
    private

    public :: solve_thermal_c

contains

    subroutine solve_thermal_c( &
        nombre_points_c, longueur_c, conductivite_c, source_volumique_c, &
        temperature_bord_c, tolerance_c, max_iterations_c, &
        temperature_c, &
        temperature_minimale_c, temperature_maximale_c, &
        temperature_moyenne_c, position_maximum_c, &
        nombre_iterations_c, erreur_convergence_c, statut_c) &
        bind(C, name="solve_thermal_c")
        ! ce bind dit au compilateur Fortran : Cette routine doit pouvoir être 
        ! appelée selon les conventions du langage C, sous le nom stable 
        ! solve_thermal_c.

        ! -----------------------------
        ! Entrées compatibles C
        ! -----------------------------

        integer(c_int), value, intent(in) :: nombre_points_c
        integer(c_int), value, intent(in) :: max_iterations_c

        real(c_double), value, intent(in) :: longueur_c
        real(c_double), value, intent(in) :: conductivite_c
        real(c_double), value, intent(in) :: source_volumique_c
        real(c_double), value, intent(in) :: temperature_bord_c
        real(c_double), value, intent(in) :: tolerance_c

        ! le mot "value est également important pour les inputs
        ! il permet à C++ de considérer les valeurs plutot que 
        ! leur adresse

        ! -----------------------------
        ! Sorties compatibles C
        ! -----------------------------

        real(c_double), intent(out) :: temperature_minimale_c
        real(c_double), intent(out) :: temperature_maximale_c
        real(c_double), intent(out) :: temperature_moyenne_c
        real(c_double), intent(out) :: erreur_convergence_c

        integer(c_int), intent(out) :: position_maximum_c(3)
        integer(c_int), intent(out) :: nombre_iterations_c
        integer(c_int), intent(out) :: statut_c

        real(c_double), intent(out) :: temperature_c(*)
        ! (*) signifie ici qu'il reçoit l'adresse du premier élément du 
        ! tableau, mais sa taille est déterminée par notre contrat.

        ! -----------------------------
        ! Variables Fortran internes
        ! -----------------------------

        integer :: n
        integer :: max_iterations

        integer :: position_maximum(3)
        integer :: nombre_iterations
        integer :: statut

        real(real64) :: temperature_minimale
        real(real64) :: temperature_maximale
        real(real64) :: temperature_moyenne
        real(real64) :: erreur_convergence

        real(real64), allocatable :: temperature(:, :, :)

        integer :: i, j, l 
        integer :: index

        ! -----------------------------
        ! Conversion C -> Fortran
        ! -----------------------------

        n = int(nombre_points_c)
        max_iterations = int(max_iterations_c)

        ! Protection minimale avant allocation
        if (n < 1) then
            temperature_minimale_c = 0.0_c_double
            temperature_maximale_c = 0.0_c_double
            temperature_moyenne_c = 0.0_c_double
            erreur_convergence_c = 0.0_c_double

            position_maximum_c = 0_c_int
            nombre_iterations_c = 0_c_int
            statut_c = -1_c_int

            return
        end if

        allocate(temperature(n, n, n))

        ! -----------------------------
        ! Appel du vrai moteur
        ! -----------------------------

        call champ_thermique( &
            n, &
            real(longueur_c, real64), &
            real(conductivite_c, real64), &
            real(source_volumique_c, real64), &
            real(temperature_bord_c, real64), &
            real(tolerance_c, real64), &
            max_iterations, &
            temperature, &
            temperature_minimale, &
            temperature_maximale, &
            temperature_moyenne, &
            position_maximum, &
            nombre_iterations, &
            erreur_convergence, &
            statut)

        ! on reshape la temperature NxNxN en un tableau 1D 
        ! N au cube par ordre colonne
        do l = 1, n
            do j = 1, n
                do i = 1, n
                    index = i &
                        + (j - 1) * n &
                        + (l - 1) * n * n
                    temperature_c(index) = &
                        real(temperature(i, j, l), c_double)
                end do
            end do
        end do
    
        ! -----------------------------
        ! Conversion Fortran -> C
        ! -----------------------------

        temperature_minimale_c = real(temperature_minimale, c_double)
        temperature_maximale_c = real(temperature_maximale, c_double)
        temperature_moyenne_c = real(temperature_moyenne, c_double)
        erreur_convergence_c = real(erreur_convergence, c_double)

        position_maximum_c = int(position_maximum, c_int)
        nombre_iterations_c = int(nombre_iterations, c_int)
        statut_c = int(statut, c_int)

        deallocate(temperature)

    end subroutine solve_thermal_c

end module thermal_c_interface_module