import { CommonModule } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { Component, Input, OnInit } from '@angular/core';
import { Observable, catchError, map, of, tap } from 'rxjs';

@Component({
  selector: 'app-health',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './health.component.html',
  styleUrl: './health.component.scss'
})
export class HealthComponent implements OnInit {

  constructor(){}

  @Input({required: true}) public hostUrl!: string

  protected connected: boolean | undefined = undefined
  protected contextOverride?: string

  public get context() {
    if(this.contextOverride) {
      return this.contextOverride
    }

    if(this.connected === undefined) {
      return "Loading..."
    }
    if(this.connected) {
      return "Connected"
    }
    return "Failed to connect. Is backend running?"

  }

  public ngOnInit(): void {
    fetch(`${this.hostUrl}/status`).then(e => {
      this.connected = e.ok
    }).catch(e => {this.connected = false; this.contextOverride = e})
  }
}
