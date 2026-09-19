/* A l'entrée pour les inputs
Java
  │
  │ arguments texte
  ▼
thermal_engine.exe
  │
  │ conversions texte → nombres
  ▼
C++
  │
  │ int, double, pointeurs
  ▼
Fortran
Au retour pour les outputs
Fortran
  │
  │ valeurs numériques
  ▼
C++
  │
  │ construit du JSON
  ▼
stdout : texte JSON
  │
  ▼
Java
Java appartient à un processus distinct,
car le backend Java lance l'exécutable "thermal_engine.exe"
comme programme externe via ProcessBuilder. Ce qui explique
que la communication entre Java et C/C++ comme décrite
ci-dessus, différente de la communication entre C/C++ et
Fortran.
*/

#include <iostream>
#include <iomanip>
#include <vector>
#include <string>

extern "C"
{
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

int main(int argc, char *argv[])
{
    // --------------------------------------------------------
    // Vérification du nombre d'arguments
    // --------------------------------------------------------

    if (argc != 8)
    {
        std::cerr
            << "Usage : thermal_engine.exe "
            << "<N> <longueur> <conductivite> <source_volumique> "
            << "<temperature_bord> <tolerance> <max_iterations>\n";

        return 1;
    }

    // --------------------------------------------------------
    // Conversion des arguments texte -> valeurs numériques
    // --------------------------------------------------------

    int n;
    double longueur;
    double conductivite;
    double source_volumique;
    double temperature_bord;
    double tolerance;
    int max_iterations;
    /*
    Il y'a 2 niveaux d'erreurs qui apparaissent : le code
    de sortie processus et le statut scientifique. La valeur
    du return est justement le exit code
    exit code = 1
    → erreur d'utilisation du programme

    exit code = 2
    → le moteur a été appelé,
      mais le solveur a retourné une erreur

    exit code = 0
    → calcul terminé normalement
    */
    try
    {
        n = std::stoi(argv[1]);
        longueur = std::stod(argv[2]);
        conductivite = std::stod(argv[3]);
        source_volumique = std::stod(argv[4]);
        temperature_bord = std::stod(argv[5]);
        tolerance = std::stod(argv[6]);
        max_iterations = std::stoi(argv[7]);
    }
    catch (const std::exception &e)
    {
        std::cerr
            << "Erreur : impossible de convertir les arguments numeriques.\n";

        return 1;
        // return 1, signifie : le programme C++ n'a même
        // pas pu comprendre ses arguments
    }

    // --------------------------------------------------------
    // Protection technique avant allocation
    // --------------------------------------------------------

    if (n <= 0)
    {
        std::cerr << "Erreur : N doit etre strictement positif.\n";
        return 1;
    }

    // --------------------------------------------------------
    // Allocation du champ thermique
    // --------------------------------------------------------

    const std::size_t nombre_valeurs =
        static_cast<std::size_t>(n) * n * n;

    std::vector<double> temperature(nombre_valeurs);

    // --------------------------------------------------------
    // Résultats du solveur
    // --------------------------------------------------------

    double temperature_minimale;
    double temperature_maximale;
    double temperature_moyenne;
    double erreur_convergence;

    int position_maximum[3];
    int nombre_iterations;
    int statut;

    // --------------------------------------------------------
    // Appel du moteur Fortran
    // --------------------------------------------------------

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

    // --------------------------------------------------------
    // Sortie JSON
    // --------------------------------------------------------

    std::cout << std::setprecision(17);

    std::cout << "{\n";

    std::cout << "  \"status\": " << statut << ",\n";
    std::cout << "  \"iterations\": " << nombre_iterations << ",\n";
    std::cout << "  \"convergenceError\": "
              << erreur_convergence << ",\n";

    std::cout << "  \"minTemperature\": "
              << temperature_minimale << ",\n";

    std::cout << "  \"maxTemperature\": "
              << temperature_maximale << ",\n";

    std::cout << "  \"meanTemperature\": "
              << temperature_moyenne << ",\n";

    std::cout << "  \"maxPosition\": ["
              << position_maximum[0] << ", "
              << position_maximum[1] << ", "
              << position_maximum[2] << "],\n";

    std::cout << "  \"shape\": ["
              << n << ", "
              << n << ", "
              << n << "],\n";

    std::cout << "  \"temperatureOrder\": "
              << "\"fortran-column-major\",\n";

    std::cout << "  \"temperature\": [";

    for (std::size_t i = 0; i < temperature.size(); ++i)
    {
        std::cout << temperature[i];

        if (i + 1 < temperature.size())
        {
            std::cout << ", ";
        }
    }

    std::cout << "]\n";

    std::cout << "}\n";

    // --------------------------------------------------------
    // Code de sortie du processus
    // --------------------------------------------------------

    if (statut != 0)
    {
        return 2;
    }

    return 0;
}