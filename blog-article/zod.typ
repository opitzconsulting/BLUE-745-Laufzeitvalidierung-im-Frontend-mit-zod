= Laufzeitvalidierung mit zod

TypeScript baut ein Typen-System um JavaScript, der Programmiersprache des Webs, auf. Mit diesem Typen-System kann ein konkretes Interface für Objekte und Funktionen definiert werden. Versucht man, einer Funktion, welche eine Zahl erwartet, beispielsweise einen String mitzugeben, dann wirft TypeScripts Compiler, `tsc`, einen Fehler beim Konvertieren - unter der Voraussetzung, dass TypeScript sich sicher ist, dass dort ein String übergeben wurde.

Wichtig dabei ist jedoch, dass diese Überprüfungen nur zur Compile-Zeit passieren. Nachdem `tsc` die TypeScript-Datei nach JavaScript konvertiert hat gehen alle Typ-Informationen verloren. JavaScript hat kein Konzept von Typen. Dementsprechend wird auch das Program zur Laufzeit, anders als bei beispielsweise Java oder C\#, keinen Fehler werfen, wenn bspw. statt einer Zahl ein String übergeben wird.

Solange man seine TypeScript-Anwendung nicht mit `any`s beschmückt, sollte das bei "statischen" Daten zu keinen Problemen führen; wenn in eine Variable beispielsweise eine Zahl geschrieben wird, dann darf davon ausgegangen Werden, dass die Variable zur Laufzeit auch eine Zahl beinhaltet.

Dieselbe Aussage kann jedoch nicht für "dynamische" Daten - also alles, dessen Struktur nicht zur Compile-Zeit garantiert ist - gemacht werden. 
Wenn man beispielsweise von einer API eine JSON mit einer bestimmten Struktur erwartet, kann man nicht TypeScripts Typen-System zur validierung verwenden. Denn, wie schon oben erwähnt, ist das Typen-System nur während der Entwicklung verfügbar.

Hier ein kleines Beispiel eines Aufrufs mit `fetch`.
```ts
interface Body {
  name: string,
  id: number
}

const result: Body = await fetch("...").then( e => e.json())
          //  ^^^^- hier wird der Body explizit definiert
          // ob hier wirklich ein Body zurückgegeben wird wissen
          // wir erst zur Laufzeit und müssen es auch zur Laufzeit
          // überprüfen 
console.log(result.name) 
//                 ^^^^ Dadurch, dass oben result als Body gesetzt ist
// geht TS davon aus, dass Result ein Body ist. Würde hier etwas anderes
// als id oder name stehen, würde es zu einem Kompile-Fehler kommen.

```
Nachdem `tsc` diese Eingabe nach JavaScript konvertiert gehen die Typ-Informationen verloren:
```js
const result = await fetch("...").then( e => e.json())
console.log(result.name) 
```
Ob `fetch` hier ein JSON-Objekt mit der korrekten Struktur zurückgibt kann man nur wissen, indem man zur Laufzeit den Inhalt überprüft, beispielsweise über eine Funktion wie:

```ts
function isBody(body: unknown): body is Body {

    if(typeof body !== "object" || body === null) {
        return false
    }
    if("name" in body) {
        if(typeof body.name !== "string") {
            return false
        }
    } else {
        return false
    }
    if("id" in body) {
        if(typeof body.id !== "number") {
            return false
        }
    } else {
        return false
    }

    return true
}
```


== Zod

Statt solche Validierungs-Funktionen "von Hand" zu schreiben kann Zod verwendet werden. 
Zod ist eine Bibliothek, mit welcher mit TS-Objekten ein Schema definiert, und Variablen gegen dieses Schema validiert werden können.

Die oben gezeigte Funktion lässt sich beispielsweise mit Zod wie gefolgt ausdrücken:

```ts
import {z} from "zod"

const BodyZod = z.object({
  name: z.string(),
  id: z.number()
});
```
Das erstellte Schema kann dann gegen ein unbekanntes Objekt angewandt werden:
```ts
const responseUnchecked: unknown = await fetch("...").then(e => e.json());
try {
  const response = BodyZod.parse(responseUnchecked);
  console.log("validated", response)
}
catch(err) {
  console.error("failed validation", err)
}
```
Bei der Validierung mit der `.parse()` Methode gibt Zod auch automatisch aus dem Schema abgeleitete Typen ab. Man erhält mit Zod somit Typen-Überprüfungen zur Laufzeit *und* zur Compilezeit.

Beispielsweise weist `tsc` folgenden Code-Block zurück:

```ts
const response = BodyZod.parse(responseUnchecked);
response.test = 42; // ! Fehler
// Property 'test' does not exist on type '{ name: string; id: number; }'
```

Man kann die Typ-Definitionen auch direkt aus dem Schema extrahieren:
```ts
type Body = z.infer<typeof BodyZod>;
// identisch zu 
type Body2 = {
  name: string,
  id: number
}
```

Neben den Typen können auch weitere Beschränkungen definiert werden. 
Ein Validator, welcher ein Enum oder eine ganze, positive Zahl, welche nicht größer als 42 ist, kann wie gefolgt definiert werden:
```ts
const ExampleZod = 
    z.enum(["value1", "value2"])
    .or(
        z.number().int().positive().max(42)
    );
type Example = z.infer<typeof ExampleZod> // = number | "value1" | "value2"
```

Eine Auflistung aller Typen und Beschränkungen können der #link("https://zod.dev/")[Dokuseite entnommen werden].
