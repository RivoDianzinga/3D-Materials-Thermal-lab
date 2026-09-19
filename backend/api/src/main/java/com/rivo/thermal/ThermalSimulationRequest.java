// La class java des inputs
package com.rivo.thermal;

public class ThermalSimulationRequest {
    private int nombrePoints;
    private double longueur;
    private double conductivite;
    private double sourceVolumique;
    private double temperatureBord;
    private double tolerance;
    private int maxIterations;

    public ThermalSimulationRequest(
            int nombrePoints,
            double longueur,
            double conductivite,
            double sourceVolumique,
            double temperatureBord,
            double tolerance,
            int maxIterations) {

        this.nombrePoints = nombrePoints;
        this.longueur = longueur;
        this.conductivite = conductivite;
        this.sourceVolumique = sourceVolumique;
        this.temperatureBord = temperatureBord;
        this.tolerance = tolerance;
        this.maxIterations = maxIterations;
    }

    public int getNombrePoints() {
        return nombrePoints;
    }

    public double getLongueur() {
        return longueur;
    }

    public double getConductivite() {
        return conductivite;
    }

    public double getSourceVolumique() {
        return sourceVolumique;
    }

    public double getTemperatureBord() {
        return temperatureBord;
    }

    public double getTolerance() {
        return tolerance;
    }

    public int getMaxIterations() {
        return maxIterations;
    }

}
