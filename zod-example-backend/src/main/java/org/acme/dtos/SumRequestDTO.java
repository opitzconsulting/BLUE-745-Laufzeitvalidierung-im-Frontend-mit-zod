package org.acme.dtos;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@JsonClassDescription("Result of summing expenses and profits together")
public class SumRequestDTO {

    @NotNull
    @Size(min = 1)
    private final List<Entry> entries;

    public SumRequestDTO(List<Entry> entries) {
        this.entries = entries;
    }

    public SumRequestDTO(){
        this.entries = new ArrayList<>();
    }

    public List<Entry> getEntries() {
        return entries;
    }


    public record Entry(
            SumRequestDTO.Entry.@NotNull EntryType type,
            @DecimalMin("00.00") @NotNull double amount,
            @NotNull Date timestamp)
    {

            public Entry(EntryType type, double amount, Date timestamp) {
                this.type = type;
                this.amount = amount;
                this.timestamp = timestamp;
            }

            public enum EntryType {
                Expense, Profit
            }


            @Override
            public double amount() {
                return amount;
            }

            @Override
            public EntryType type() {
                return type;
            }
        }

}
