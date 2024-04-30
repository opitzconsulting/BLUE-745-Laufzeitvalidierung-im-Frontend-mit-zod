package org.acme.dtos;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public class SumResponseDTO {

    @NotNull
    @DecimalMin("00.00")
    private final double totalProfit;
    @NotNull
    @DecimalMin("00.00")
    private final double totalExpenses;
    @NotNull
    private final double total;


    public SumResponseDTO(double totalProfit, double totalExpenses, double total) {
        this.totalProfit = totalProfit;
        this.totalExpenses = totalExpenses;
        this.total = total;
    }

    public double getTotal() {
        return total;
    }

    public double getTotalExpenses() {
        return totalExpenses;
    }

    public double getTotalProfit() {
        return totalProfit;
    }
}
