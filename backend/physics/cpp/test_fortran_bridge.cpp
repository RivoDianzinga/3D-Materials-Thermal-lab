// Ici, on fait le test de la routine solver_thermal_c, pour s'assurer que
// cette routine donne les mèmes résultats que son équivalent en fortran
// "champ_thermique". Ce test a pour responsabilité de vérifier
// l'interface.
#include <iostream>
#include <iomanip>
#include <vector>

extern "C"
{
    // les inputs n'ont pas de *, alors que les outputs ont des *

    void solve_thermal_c(
        int nombre_points,
        double longueur,
        double conductivite,
        double source_volumique,
        double temperature_bord,
        double tolerance,
        int max_iterations,
        double *temperature,
        double *temperature_minimale,
        double *temperature_maximale,
        double *temperature_moyenne,
        int *position_maximum,
        int *nombre_iterations,
        double *erreur_convergence,
        int *statut);
}

// fonction pour afficher le tableau temperature 3D
std::size_t index_fortran(
    int i,
    int j,
    int k,
    int n)
{
    return static_cast<std::size_t>(i) + static_cast<std::size_t>(n) * j + static_cast<std::size_t>(n) * n * k;
}

int main() // programme principal
{
    const int n = 11;
    const double longueur = 0.01;
    const double conductivite = 50.0;
    const double source_volumique = 1.0e8;
    const double temperature_bord = 300.0;
    const double tolerance = 1.0e-8;
    const int max_iterations = 10000;

    double temperature_minimale;
    double temperature_maximale;
    double temperature_moyenne;
    double erreur_convergence;

    int position_maximum[3];
    int nombre_iterations;
    int statut;

    const int centre = (n - 1) / 2;

    const std::size_t nombre_valeurs =
        static_cast<std::size_t>(n) * n * n;

    std::vector<double> temperature(nombre_valeurs);

    solve_thermal_c(
        n,
        longueur,
        conductivite,
        source_volumique,
        temperature_bord,
        tolerance,
        max_iterations,
        temperature.data(),
        &temperature_minimale,
        &temperature_maximale,
        &temperature_moyenne,
        position_maximum,
        &nombre_iterations,
        &erreur_convergence,
        &statut);

    // std:: count permet d'imprimer à l'écran
    std::cout << std::setprecision(15);

    std::cout << "Statut : " << statut << '\n';
    std::cout << "Iterations : " << nombre_iterations << '\n';
    std::cout << "Erreur de convergence : "
              << erreur_convergence << '\n';

    std::cout << "Temperature minimale : "
              << temperature_minimale << " K\n";

    std::cout << "Temperature maximale : "
              << temperature_maximale << " K\n";

    std::cout << "Temperature moyenne : "
              << temperature_moyenne << " K\n";

    // Attention, en C++, l'indice commence par 0
    // alors qu'en fotran, l'indice commence par 1
    std::cout << "Position maximum : ("
              << position_maximum[0] << ", "
              << position_maximum[1] << ", "
              << position_maximum[2] << ")\n";

    std::cout << "Temperature centre : "
              << temperature[index_fortran(centre, centre, centre, n)]
              << " K\n";

    std::cout << "Temperature bord : "
              << temperature[index_fortran(0, 0, 0, n)]
              << " K\n";

    std::cout << "Voisin x+ : "
              << temperature[index_fortran(centre + 1, centre, centre, n)]
              << " K\n";

    return 0;
}