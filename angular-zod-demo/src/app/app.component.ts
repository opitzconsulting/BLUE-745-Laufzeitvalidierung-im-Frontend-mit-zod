import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HealthComponent } from './health/health.component';
import { IndexRouteComponent } from './index-route/index-route.component';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, HealthComponent, ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'angular-zod-demo';

  readonly #backendHost = "http://localhost:8080"

  get backendHost() {
    return this.#backendHost
  }

}
