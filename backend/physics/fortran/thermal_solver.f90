program thermal_solver

    use iso_fortran_env, only: real64
    implicit none

    ! Dimensions du maillage
    integer, parameter :: nx = 11
    integer, parameter :: ny = 11
    integer, parameter :: nz = 11
    ! Paramètres numériques
    integer, parameter :: max_iterations = 10000
    real(real64), parameter :: tolerance = 1.0e-8_real64

    ! Paramètres physiques
    real(real64), parameter :: longueur = 0.01_real64
    real(real64), parameter :: conductivite = 50.0_real64
    !real(real64), parameter :: conductivite = 100.0_real64 ! test 3 : doubler la conductivité
    real(real64), parameter :: temperature_bord = 300.0_real64
    real(real64), parameter :: puissance_source = 1.0e8_real64
    !real(real64), parameter :: puissance_source = 0.0_real64 ! test 1 : aucune source
    !real(real64), parameter :: puissance_source = 2.0e8_real64 ! test 2 : doubler la source

    ! Champs 3D
    real(real64) :: temperature(nx, ny, nz)
    real(real64) :: temperature_precedente(nx, ny, nz)
    real(real64) :: source_chaleur(nx, ny, nz)

    ! Variables de calcul
    real(real64) :: h
    real(real64) :: erreur
    real(real64) :: temperature_moyenne

    integer :: i, j, l, voc(3)
    integer :: iteration
    integer :: iterations_effectuees

    integer :: ic, jc, lc


    ! Pas spatial
    h = longueur / real(nx - 1, real64)


    ! Initialisation du matériau à 300 K
    temperature = temperature_bord


    ! Pas de source thermique au départ
    source_chaleur = 0.0_real64


    ! Position centrale du cube
    ic = (nx + 1) / 2
    jc = (ny + 1) / 2
    lc = (nz + 1) / 2

    Voc = 0

    ! Source thermique placée au centre
    source_chaleur(ic, jc, lc) = puissance_source


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


    ! Calcul de quelques résultats synthétiques
    temperature_moyenne = &
        sum(temperature) / real(nx * ny * nz, real64)

    Voc = maxloc(temperature)
    print *, "Iterations :", iterations_effectuees
    print *, "Erreur finale :", erreur
    print *, "Temperature minimale :", minval(temperature), "K"
    print *, "Temperature maximale :", maxval(temperature), "K"
    print *, "Temperature moyenne :", temperature_moyenne, "K"
    print *, "Position du maximum :", Voc

    ! Validation des propriétés de symétrie
    ! Le cube, la conductivité et la source centrale étant 
    ! parfaitement symétriques, les six voisins immédiats
    ! du centre devraient avoir pratiquement la mème 
    ! température suivant, x, y et z.

    print *, "Temperature au centre :", &
    temperature(ic, jc, lc), "K"

    print *, "Voisin x- :", &
    temperature(ic - 1, jc, lc), "K"

    print *, "Voisin x+ :", &
    temperature(ic + 1, jc, lc), "K"

    print *, "Voisin y- :", &
    temperature(ic, jc - 1, lc), "K"

    print *, "Voisin y+ :", &
    temperature(ic, jc + 1, lc), "K"

    print *, "Voisin z- :", &
    temperature(ic, jc, lc - 1), "K"

    print *, "Voisin z+ :", &
    temperature(ic, jc, lc + 1), "K"

end program thermal_solver