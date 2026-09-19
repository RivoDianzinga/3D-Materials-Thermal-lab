! Ce module écrit en fortran : valide d'abord les inputs, 
! calcule ensuite les outputs dont le champ 3D qui la temperature, 
! et valide les outputs. La validation repose sur les contraintes
! physiques et numériques. C'est le step 1 de notre application.

module thermal_solver_module

    use iso_fortran_env, only: real64
    implicit none
    private
    public :: champ_thermique

    ! Paramètres de validation
    integer, parameter :: STATUT_OK = 0
    integer, parameter :: ERREUR_NON_CONVERGENCE = 1
    integer, parameter :: ERREUR_TEMPERATURE = 2

    integer, parameter :: ERREUR_MAILLAGE = -1
    integer, parameter :: ERREUR_LONGUEUR = -2
    integer, parameter :: ERREUR_CONDUCTIVITE = -3
    integer, parameter :: ERREUR_SOURCE = -4
    integer, parameter :: ERREUR_TEMPERATURE_BORD = -5
    integer, parameter :: ERREUR_TOLERANCE = -6
    integer, parameter :: ERREUR_MAX_ITERATIONS = -7       

contains 

    subroutine champ_thermique(nombre_points, longueur, conductivite, & 
        source_volumique, temperature_bord, tolerance, max_iterations, & 
        temperature, temperature_minimale, temperature_maximale, & 
        temperature_moyenne, position_maximum, nombre_iterations, &
        erreur_convergence, statut)
    
        implicit none

        ! inputs numériques
        integer, intent(in) :: nombre_points, max_iterations
        real(real64), intent(in) :: tolerance 

        ! inputs physiques
        real(real64), intent(in) :: conductivite, temperature_bord, longueur, &
                                    source_volumique

        ! outputs numériques
        integer, intent(out) :: nombre_iterations, position_maximum(3), &
                                statut
        real(real64), intent(out) :: erreur_convergence

        ! outputs physiques
        real(real64), intent(out) :: temperature(nombre_points, nombre_points, &
                                     nombre_points)
        real(real64), intent(out) :: temperature_minimale, temperature_maximale, &
                                     temperature_moyenne                    
                       
        ! Variables internes de calcul
        integer :: nx, ny, nz, N 

        real(real64) :: h
        real(real64) :: erreur

        integer :: i, j, l
        integer :: iteration
        integer :: iterations_effectuees

        integer :: ic, jc, lc

        real(real64), allocatable :: temperature_precedente(:, :, :)
        real(real64), allocatable :: source_chaleur(:, :, :)

        ! Initialisation des outputs
        nombre_iterations = 0
        position_maximum = 0
        statut = 0
        erreur_convergence = 0.0_real64
        temperature_maximale = 0.0_real64
        temperature_minimale = 0.0_real64
        temperature_moyenne = 0.0_real64
        temperature = 0.0_real64

        ! Validation toute première des inputs avant le calcul

        if (mod(nombre_points,2) == 0 .or. nombre_points < 3) then
            statut = ERREUR_MAILLAGE
            !print*, "Paramètre invalide: le nombre de points doit être impair et supérieur ou égal 3"
            return
        else if (longueur <= 0.0_real64) then
            statut = ERREUR_LONGUEUR
            !print*, "Paramètre invalide: la longueur doit être strictement positive"
            return
        else if (conductivite <= 0.0_real64) then
            statut = ERREUR_CONDUCTIVITE
            !print*, "Paramètre invalide: la conductivité doit être strictement positive"
            return
        else if (source_volumique < 0.0_real64) then
            statut = ERREUR_SOURCE
            !print*, "Paramètre invalide: la source volumique doit être positive ou nulle"
            return
        else if (temperature_bord <= 0.0_real64) then
            statut = ERREUR_TEMPERATURE_BORD
            !print*, "Paramètre invalide: la température de bord doit être strictement positive"
            return
        else if (tolerance <= 0.0_real64) then
            statut = ERREUR_TOLERANCE
            !print*, "Paramètre invalide: la tolérance doit être strictement positive"
            return
        else if (max_iterations <= 0) then
            statut = ERREUR_MAX_ITERATIONS
            !print*, "Paramètre invalide: le nombre maximal d'itérations doit être strictement positif"
            return 
        end if

        ! Initialisation des paramètres internes
        N = nombre_points
        nx = N 
        ny = N 
        nz = N 
        iterations_effectuees = 0

        ! Allocation de temperature_precedente
        allocate(temperature_precedente(N,N,N))
        allocate(source_chaleur(N,N,N))

        ! Pas de source thermique au départ
        source_chaleur = 0.0_real64
        temperature_precedente = 0.0_real64

        ! Pas spatial
        h = longueur / real(nx - 1, real64)

        ! Initialisation du matériau à la température de bord
        temperature = temperature_bord

        ! Position centrale du cube
        ic = (nx + 1) / 2
        jc = (ny + 1) / 2
        lc = (nz + 1) / 2

        ! Source thermique placée au centre
        source_chaleur(ic, jc, lc) = source_volumique

        ! Résolution itérative par la méthode de Jacobi
        do iteration = 1, max_iterations

            temperature_precedente = temperature

            do l = 2, nz - 1
                do j = 2, ny - 1
                    do i = 2, nx - 1

                        temperature(i, j, l) = ( &
                            temperature_precedente(i + 1, j, l) + &
                            temperature_precedente(i - 1, j, l) + &
                            temperature_precedente(i, j + 1, l) + &
                            temperature_precedente(i, j - 1, l) + &
                            temperature_precedente(i, j, l + 1) + &
                            temperature_precedente(i, j, l - 1) + &
                            h**2 * source_chaleur(i, j, l) / conductivite &
                        ) / 6.0_real64

                    end do
                end do
            end do

            ! Mesure de la différence entre deux itérations
            erreur = maxval(abs(temperature - temperature_precedente))

            iterations_effectuees = iteration

            ! Critère de convergence
            if (erreur < tolerance) exit
        end do

        nombre_iterations = iterations_effectuees ! nombre d'itérations
        erreur_convergence = erreur ! erreur finale

        ! Validation des outputs après calcul
        if (erreur >= tolerance) then
            statut = ERREUR_NON_CONVERGENCE
            !print*, "Erreur: max_iterations atteint sans convergence"
            ! Si la boucle s'est terminée sans satisfaire la tolérance,
            ! max_iterations a été atteint.
        else if (any(temperature <= 0.0_real64)) then
            statut = ERREUR_TEMPERATURE
            !print*, "Erreur: la température doit être strictement positive"
        else
            statut = STATUT_OK
            !print*, "Succès: Convergence réussie" 
        end if

        ! Calcul de quelques résultats synthétiques
        temperature_moyenne = &
            sum(temperature) / real(size(temperature), real64) ! température moyenne

        temperature_minimale = minval(temperature) ! température minimale
        temperature_maximale = maxval(temperature) ! température maximale
        position_maximum = maxloc(temperature) ! position de la température maximale

        deallocate(temperature_precedente)
        deallocate(source_chaleur)
        return

    end subroutine champ_thermique

end module thermal_solver_module