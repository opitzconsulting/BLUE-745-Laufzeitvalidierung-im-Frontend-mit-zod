package org.acme;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import org.acme.dtos.SumRequestDTO;
import org.acme.dtos.SumResponseDTO;
import org.acme.dtos.WeatherDataResponseDTO;
import org.jboss.resteasy.reactive.common.NotImplementedYet;

import static org.acme.dtos.WeatherDataResponseDTO.buildExampleData;

@Path("/")
public class ExampleResource {

    @GET
    @Path("weather")
    public WeatherDataResponseDTO getWeatherData() {
        return buildExampleData(20);
    }

    @GET
    @Path("bad-weather")
    public WeatherDataResponseDTO getBadWeatherData() {
        // Schema is set to have a max of 20 entries
        return buildExampleData(40);
    }

    @POST
    @Path("sum")
    public SumResponseDTO calculateSum(SumRequestDTO data) {
        double profit = 0d;
        double expenses = 0d;

        for(var entry: data.getEntries()) {
            if (entry.type().equals(SumRequestDTO.Entry.EntryType.Expense)) {
                expenses += entry.amount();
            } else if(entry.type().equals(SumRequestDTO.Entry.EntryType.Profit)) {
                profit += entry.amount();
            } else {
                throw new NotImplementedYet();
            }
        }

        return new SumResponseDTO(profit, expenses, profit - expenses);
    }

    @GET
    @Path("status")
    public String getStatus() {
        return "ok";
    }
}


