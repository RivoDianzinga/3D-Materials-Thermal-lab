//package backend.api; // package important et décidé par VS Code
package com.rivo.thermal;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import com.fasterxml.jackson.databind.ObjectMapper;

public class ThermalEngineRunner { // programme principale

        public static void main(String[] args) // le main qui exécute
                        throws IOException, InterruptedException {

                // Paramètres de notre cas de référence
                // int nombrePoints = 11;
                // double longueur = 0.01;
                // double conductivite = 50.0;
                // double sourceVolumique = 1e8;
                // double temperatureBord = 300.0;
                // double tolerance = 1e-8;
                // int maxIterations = 10000;
                ThermalSimulationRequest request = new ThermalSimulationRequest(
                                11,
                                0.01,
                                50.0,
                                1e8,
                                300.0,
                                1e-8,
                                10000);

                // Chemin vers le moteur scientifique natif
                // Chemin depuis la racine des sources java
                Path enginePath = Path.of(
                                "..",
                                "physics",
                                "thermal_engine.exe").toAbsolutePath().normalize();

                System.out.println("Moteur : " + enginePath);
                // System.out.println() permet d'afficher à l'écran

                // processbuilder convertit les données en textes que
                // java utilisera. ces textes sont envoyés dans
                // processbuilder
                // ProcessBuilder processBuilder = new ProcessBuilder(
                // enginePath.toString(),
                // Integer.toString(nombrePoints),
                // Double.toString(longueur),
                // Double.toString(conductivite),
                // Double.toString(sourceVolumique),
                // Double.toString(temperatureBord),
                // Double.toString(tolerance),
                // Integer.toString(maxIterations));

                ProcessBuilder processBuilder = new ProcessBuilder(
                                enginePath.toString(),
                                Integer.toString(request.getNombrePoints()),
                                Double.toString(request.getLongueur()),
                                Double.toString(request.getConductivite()),
                                Double.toString(request.getSourceVolumique()),
                                Double.toString(request.getTemperatureBord()),
                                Double.toString(request.getTolerance()),
                                Integer.toString(request.getMaxIterations()));
                // stderr reste visible dans le terminal.
                // stdout est réservé au JSON que Java va récupérer.
                processBuilder.redirectError(ProcessBuilder.Redirect.INHERIT);

                // processbuilder envoie les textes dans process
                Process process = processBuilder.start();

                // Java récupère le stdout du processus sous forme de texte JSON
                String json = new String(
                                process.getInputStream().readAllBytes(),
                                StandardCharsets.UTF_8);

                int exitCode = process.waitFor();

                ObjectMapper objectMapper = new ObjectMapper();

                ThermalSimulationResult result = objectMapper.readValue(json, ThermalSimulationResult.class);

                // System.out.println("Code de sortie du processus : " + exitCode);
                // System.out.println("Réponse du moteur :");
                // System.out.println(json);
                System.out.println("Code processus : " + exitCode);
                System.out.println("Statut scientifique : " + result.getStatus());
                System.out.println("Itérations : " + result.getIterations());
                System.out.println(
                                "Température maximale : "
                                                + result.getMaxTemperature()
                                                + " K");
                System.out.println(
                                "Nombre de températures : "
                                                + result.getTemperature().length);
        }
}