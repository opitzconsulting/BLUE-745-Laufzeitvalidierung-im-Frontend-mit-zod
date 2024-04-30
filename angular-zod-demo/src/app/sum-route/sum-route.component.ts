import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { BehaviorSubject, filter, map, tap } from 'rxjs';
import { SumRequestDTO, SumRequestDTOZod, SumResponseDTO, SumResponseDTOZod } from '../../generated/backendTypes';
import { AsyncPipe, NgIf } from '@angular/common';
import { SafeParseReturnType } from 'zod';

@Component({
  selector: 'app-sum-route',
  standalone: true,
  imports: [RouterModule, NgIf, AsyncPipe],
  templateUrl: './sum-route.component.html',
  styleUrl: './sum-route.component.scss'
})
export class SumRouteComponent implements OnInit {

  protected bodyPayload$ = new BehaviorSubject<unknown>(undefined)

  protected apiResponse$ = new BehaviorSubject<SafeParseReturnType<any,SumResponseDTO> | undefined>(undefined)
  protected apiResponseJsonString$ = this.apiResponse$.pipe(
    map( e => {
      if(e?.data === undefined) {
        return undefined
      }
      return JSON.stringify(e, undefined, 2)
    })
  )
  protected apiResponseStatus$ = this.apiResponse$.pipe(
    map( e => {
      if(e === undefined) {
        return "missing"
      }
      return e.success ? "success" : "failed"
    })
  )

  public ngOnInit(): void {
    this.parsedBody$.subscribe({next: (payload) => {
      if(payload === undefined) {

        this.apiResponse$.next(undefined)
        return
      }


      fetch(`http://localhost:8080/sum`, {
        method: "POST",
        body: JSON.stringify(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
      })
        .then( e => e.json())
        .then( e => {
          this.apiResponse$.next(SumResponseDTOZod.safeParse(e)) })
        .catch( error => this.apiResponse$.next({success: false, error}))
    }})
  }


  protected bodyStatus$ = this.bodyPayload$.pipe(
    map(e => {
      if(e === undefined) {
        return "missing"
      }
      return SumRequestDTOZod.safeParse(e).success ? "parsed" : "failed"
    })
  )

  protected bodyPayloadJsonString$ = this.bodyPayload$.pipe(
    map( e => JSON.stringify(e, undefined, 2))
  )

  protected parsedBody$ = this.bodyPayload$.pipe(
    map(e => {
      try {
        return SumRequestDTOZod.parse(e)
      }
      catch {
        return undefined
      }
    })
  )

  protected failedParseBodyError$ = this.bodyPayload$.pipe(
    map( e => {
      try {
        SumRequestDTOZod.parse(e)
        return undefined
      }
      catch (err) {
        return err
      }
    })
  )

  protected createCorrectBody() {
    // Typ wurde aus JSON Schema generiert
    //          vvvvvvvvvvvvv
    const body: SumRequestDTO = {
      entries: [
        {
          amount: 10 + Math.random() * 20,
          type: "Expense",
          timestamp: (new Date()).toUTCString()
        },
        {
          amount: 20 + Math.random() * 30,
          type: "Profit",
          timestamp: (new Date()).toUTCString()
        }
      ]
    }

    return body
  }

  protected createWrongBody() {
    return {
      wrongKey: this.createCorrectBody().entries
    }
  }



}

