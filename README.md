# 3D-Materials-Thermal-lab

3D Materials Thermal Lab est une application scientifique, qui se veut de résoudre la diffusion de la chaleur dans un matériau. Ce dernier est considéré
avoir une structure cubique, et on suppose que la chaleur évolue dans cette
structure de façon statique.

## Objectif du modèle scientifique

Cette application repose sur l'équation stationnaire de la chaleur,
définie par :

```text
∇²T = −k / Q​ ​,
```

Cette équation est discrétisée de la manière suivante :

```text
T(i,j,l) = (T(i+1,j,l) T(i-1,j,l) T(i,j+1,l) T(i,j-1,l) T(i,j,l+1) T(i,j,l+1) + (h²Q(i,j,l)/k))/6
```

L'application calcule la température qui est le champ 3D `T(i,j,l)`, avec les paramètres suivants:

### Paramètres numériques

- le nombre de points du domaine de calcul ;
- la tolérance de convergence numérique ;
- le nombre maximum d'itérations.

### Paramètres physiques

- la longueur du maillage de la structure cubique ;
- la conductivité `k` du matériau ;
- la source volumique de chaleur `Q`;
- la température de bord.

## Validation scientifique

Le domaine de calcul repose sur les constraintes suivantes :

### Contraintes numériques

- `n_points` >= 3 et `n_points` impair ;
- `tolerance` > 0 ;
- `max_iterations` > 0.

### Contraintes numériques

- `L` > 0 ;
- `k` > 0 ;
- `Q` >= 0 ;
- `Tbord` > 0.

avec `n_points`, le nombre de points du domaine de calcul, `tolerance` la tolérance de convergence numérique, `max_iterations` le nombre maximum d'itérations, `L` la longeur du maillage de la structure, et `Tbord` la température de bord.

Ces validations permettent de garantir la cohérence
physique d'entrée et de limiter la propagation de valeurs non finies ou numériquement instables.

## Application

À compléter...

## Fonctionnalités

À compléter...

## Technologies

### Frontend

À compléter...

### Backend

- Fortran
- C++
- Java
- Maven

### Base de données

À compléter...

## Tests et CI/CD

À compléter...

## Déploiement

À compléter...

## Architecture

À compléter...

## Arborescence

```text
3D-Materials-Thermal-lab/
├── .github/
│   └── workflows/
│       ├── pages.yml
│       └── tests.yml
├── backend/
│   ├── api/
|   |    ├── scr/
|   |    ├── target/
|   |    └── pom.xml
|   └── physics/
|       ├── cpp/
|       └── fortran/
|       └── Makefile
|── database/
├── frontend/
│   ├── assets/
│   ├── index.html
│   ├── script.js
│   └── style.css
├── .env
├── .gitignore
└── README.md
```
