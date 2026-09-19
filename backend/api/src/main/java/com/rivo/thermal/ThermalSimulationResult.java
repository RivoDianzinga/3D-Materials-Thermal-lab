// La class java des outputs
package com.rivo.thermal;

public class ThermalSimulationResult {
    private int status;
    private int iterations;
    private double convergenceError;

    private double minTemperature;
    private double maxTemperature;
    private double meanTemperature;

    private int[] maxPosition;
    private int[] shape;

    private String temperatureOrder;
    private double[] temperature;

    public ThermalSimulationResult() {
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getIterations() {
        return iterations;
    }

    public void setIterations(int iterations) {
        this.iterations = iterations;
    }

    public double getConvergenceError() {
        return convergenceError;
    }

    public void setConvergenceError(double convergenceError) {
        this.convergenceError = convergenceError;
    }

    public double getMinTemperature() {
        return minTemperature;
    }

    public void setMinTemperature(double minTemperature) {
        this.minTemperature = minTemperature;
    }

    public double getMaxTemperature() {
        return maxTemperature;
    }

    public void setMaxTemperature(double maxTemperature) {
        this.maxTemperature = maxTemperature;
    }

    public double getMeanTemperature() {
        return meanTemperature;
    }

    public void setMeanTemperature(double meanTemperature) {
        this.meanTemperature = meanTemperature;
    }

    public int[] getMaxPosition() {
        return maxPosition;
    }

    public void setMaxPosition(int[] maxPosition) {
        this.maxPosition = maxPosition;
    }

    public int[] getShape() {
        return shape;
    }

    public void setShape(int[] shape) {
        this.shape = shape;
    }

    public String getTemperatureOrder() {
        return temperatureOrder;
    }

    public void setTemperatureOrder(String temperatureOrder) {
        this.temperatureOrder = temperatureOrder;
    }

    public double[] getTemperature() {
        return temperature;
    }

    public void setTemperature(double[] temperature) {
        this.temperature = temperature;
    }
}
