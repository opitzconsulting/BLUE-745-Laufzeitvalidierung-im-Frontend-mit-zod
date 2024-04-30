import { Routes } from '@angular/router';
import { IndexRouteComponent } from './index-route/index-route.component';
import { WeatherRouteComponent } from './weather-route/weather-route.component';
import { SumRouteComponent } from './sum-route/sum-route.component';

export const routes: Routes = [

  {
    path: "",
    component: IndexRouteComponent
  },
  {
    path: "weather",
    component: WeatherRouteComponent
  },
  {
    path: "sum",
    component: SumRouteComponent
  }

];
