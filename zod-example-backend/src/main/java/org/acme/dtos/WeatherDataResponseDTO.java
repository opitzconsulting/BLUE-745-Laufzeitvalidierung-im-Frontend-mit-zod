package org.acme.dtos;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.*;

@JsonClassDescription("List of Weather Station Measurements")
public class WeatherDataResponseDTO {

    @NotNull
    @Size(max = 20)
    private final List<WeatherDataEntry> weatherStations = new ArrayList<>();

    public List<WeatherDataEntry> getWeatherStations() {
        return this.weatherStations;
    }

    @NotNull
    @Min(1)
    public String nonce;

    public static WeatherDataResponseDTO buildExampleData(int count) {

        var returnData = new WeatherDataResponseDTO();
        returnData.nonce = UUID.randomUUID().toString();

        for (int i = 0; i < count; i++) {
            String name = String.format("station-%d", i+1);

            var entry = new WeatherDataEntry(
                    name,
                    (float) Math.random() * 40f,
                    (float) Math.random(),
                    (float) Math.random() * 40f
            );

            returnData.weatherStations.add(entry);

        }

        return returnData;
    }
}
