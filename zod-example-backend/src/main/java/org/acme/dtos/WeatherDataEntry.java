package org.acme.dtos;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@JsonClassDescription("A Weather Station Entry")
public class WeatherDataEntry {

    @NotNull
    @Size(min = 1)
    private final String weatherStationName;

    @NotNull
    @DecimalMin("-273.15")
    private final float temperatureDegreesCelsius;

    @NotNull
    @DecimalMin("0")
    @DecimalMax("1")
    private final float humidityFraction;

    @NotNull
    @DecimalMin("0")
    private final float windMetresPerSecond;

    public WeatherDataEntry(String name, float temperatureDegreesCelsius, float humidityFraction, float windMetresPerSecond) {
        this.weatherStationName = name;
        this.temperatureDegreesCelsius = temperatureDegreesCelsius;
        this.humidityFraction = humidityFraction;
        this.windMetresPerSecond = windMetresPerSecond;
    }

    public float getTemperatureDegreesCelsius() {
        return temperatureDegreesCelsius;
    }

    public float getHumidityFraction() {
        return humidityFraction;
    }

    public float getWindMetresPerSecond() {
        return windMetresPerSecond;
    }

    public String getWeatherStationName() {
        return this.weatherStationName;
    }


    @Override
    public String toString() {
        return "Entry[" +
                "temperatureDegreesCelsius=" + temperatureDegreesCelsius + ", " +
                "humidityFraction=" + humidityFraction + ", " +
                "windMetresPerSecond=" + windMetresPerSecond + ']';
    }
}
