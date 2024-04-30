import { Component, OnInit } from '@angular/core';
import { BehaviorSubject, map } from 'rxjs';
import { WeatherDataResponseDTO, WeatherDataResponseDTOZod } from '../../generated/backendTypes';
import { SafeParseReturnType } from 'zod';
import { AsyncPipe, DecimalPipe, NgFor, NgIf } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-weather-route',
  standalone: true,
  imports: [NgIf, NgFor, AsyncPipe, DecimalPipe, RouterModule],
  templateUrl: './weather-route.component.html',
  styleUrl: './weather-route.component.scss'
})
export class WeatherRouteComponent implements OnInit {


  protected lastResult$  = new BehaviorSubject<SafeParseReturnType<any, WeatherDataResponseDTO> | undefined>(undefined)
  protected lastDataOrUndefined$ = this.lastResult$.asObservable().pipe(map( e => e?.data ))
  protected lastErrorOrUndefined$ = this.lastResult$.asObservable().pipe(map( e => e?.error ))
  protected lastIsSuccess$ = this.lastResult$.asObservable().pipe(map( e => e?.success ?? false ))

  protected averages$ = this.lastResult$.asObservable().pipe(
    map(e => {
      if(e === undefined || !e.success) {
        return undefined
      }

      const {data} = e

      // ^- typen wurden automatisch mit Zod abgeleitet!
      let sumData: Omit<WeatherDataResponseDTO["weatherStations"][0], "weatherStationName"> = {
        "humidityFraction": 0,
        "temperatureDegreesCelsius": 0,
        "windMetresPerSecond": 0,
      }

      data.weatherStations.forEach( e => {
        sumData.humidityFraction += e.humidityFraction
        sumData.temperatureDegreesCelsius += e.temperatureDegreesCelsius,
        sumData.windMetresPerSecond += e.windMetresPerSecond
      })

      let averageData: typeof sumData = {
        humidityFraction: sumData.humidityFraction / data.weatherStations.length,
        temperatureDegreesCelsius: sumData.temperatureDegreesCelsius / data.weatherStations.length,
        windMetresPerSecond: sumData.windMetresPerSecond / data.weatherStations.length,
      }

      return averageData
    })
  )

  async #fetchWeatherData(route: string) {
    const result = await (await fetch("http://localhost:8080/"+route)).json()
    /**
     *
     * Statt einen Fehler zu Werfen verpackt .safeParse das Ergebnis in ein Objekt,
     * welches - basierend auf dem `success` Bool - entweder den korrekten Payload,
     * oder einen Fehler beinhaltet.
     *
     * Das Interface lässt sich grob wie gefolgt zusammenfassen:
     *
     *  {
     *    success: true,
     *    data: T
     *  } | {
     *    success: false,
     *    error: ZodError<...>
     *  }
     *
     *
     * Alternativ kann man auch .parse verwenden und einen Fehler catchen.
     *
     */
    return WeatherDataResponseDTOZod.safeParse(result)

  }

  protected fetchCorrectWeatherData() {
    this.#fetchWeatherData("weather").then( e => this.lastResult$.next(e)).catch(error => this.lastResult$.next({success: false, error}))
  }

  protected fetchBadWeatherData() {
    this.#fetchWeatherData("bad-weather").then( e => this.lastResult$.next(e)).catch(error => this.lastResult$.next({success: false, error}))
  }

  public ngOnInit(): void {
    this.fetchCorrectWeatherData()
  }





}
