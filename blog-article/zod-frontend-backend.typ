= Zod als Validierungsschnittstelle zwischen Front- und Backend
Für Fullstack-Anwendungen ist es im Business-Kontext üblich, ein REST-Backend mit Spring Boot / Quarkus, sowie ein Single-Page-Application Frontend (bspw. mit Angular) zu verknüpfen. 
Das Frontend sendet und empfängt JSON-Daten über die REST-Schnittstelle mit dem Backend. 

Im letzte Blogeintrag wurde Zod, eine Bibliothek zur Laufzeitvalidierung im TypeScript-Ökosystem, vorgestellt. In diesem Blogeintrag wird ein Anwendungsbeispiel zur effektiven Absicherung der Kommunikation zwischen Front- und Backend vorgestellt.

Man kann im Frontend die Zod-Schemas "manuell" definieren. Für Backends, welche nur sehr selten aktualisiert werden, ist das eine valide Lösung. 
Doch für Anwendungen, welche aktiv entwickelt werden, ist diese Herangehensweise fehleranfällig. 

Wie wäre es, wenn man die Zod Schemas automatisch aus dem Backend ableiten kann?

== Von Java POJOs zum Zod Schema

Es gibt keine direkte Lösung, um von einer Java Klassendefinitionen ein Zod Schema abzuleiten. Es gibt jedoch ein Plugin zur Generierung eines JSON Schemas im Java Kontext, sowie eine Bibliothek zum Erstellen von Zod Schemas aus JSON Schemas im TypeScript-Kontext. Man kommt also über einen indirekten Weg zu Lösung.

=== Exkurs: JSON Schema
Das JSON Schema ist eine Spezifikation mit welcher die erwartete Struktur einer JSON (oder YAML) Datei definiert wird. Das Schema wird als JSON definiert.

Das JSON Schema, welches `{"name": "Waldemar", "id": 1234}` validiert könnte beispielsweise wie gefolgt aussehen:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
      "minLength": 1
    },
    "id": {
      "type": "int",
      "minimum": 0
    }
  },
  "required": [
    "name",
    "id"
  ]
}
```

Das JSON Schema hat somit eine ähnliche Aufgabe wie eine OpenAPI Spec. Das JSON Schema beschränkt sich auf ein JSON-Objekt, während die OpenAPI Spec den Vertrag für eine ganze API abbildet. 

== Von Java POJOs zum JSON Schema
Mithilfe eines Maven-Plugins (`jsonschema-maven-plugin` aus der `com.github.victools` Gruppe) werden zum `generate`-Step für alle DTOs JSON-Schema Definitionen generiert.

Für das Beispiel wurden folgenden Dependencies eingebunden:
```xml
<!-- JSON Schema Dependencies -->
<dependency>
    <groupId>com.github.victools</groupId>
    <artifactId>jsonschema-generator</artifactId>
    <version>4.31.1</version>
</dependency>
<dependency>
    <groupId>com.github.victools</groupId>
    <artifactId>jsonschema-module-jackson</artifactId>
    <version>4.31.1</version>
</dependency>
<dependency>
    <groupId>com.github.victools</groupId>
    <artifactId>jsonschema-module-jakarta-validation</artifactId>
    <version>4.31.1</version>
</dependency>
```

Die zwei letzten Dependencies sorgen dafür, dass Informationen aus den Annotationen von Jackson und Jakarta auch in das JSON Schema abgebildet werden.

```java
import com.fasterxml.jackson.annotation.JsonClassDescription;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

@JsonClassDescription("A very helpful description!")
public class SumResponseDTO {

  @NotNull
  @DecimalMin("00.00")
  private final double totalProfit;
  // ...
}
```
wird somit beispielsweise in folgendes Schema umgewandelt:

```json
{
  "type" : "object",
  "properties" : {
    "totalProfit" : {
      "type" : "number",
      "minimum" : 0.00
    },
    // ...
  },
  "required" : [ "totalProfit" ],
  "additionalProperties" : false,
  "description" : "A very helpful description!",
}
```

Die genaue Konfiguration findet sich im Git Repo unter #link("")[TODO]. #link("https://www.baeldung.com/java-json-schema-create-automatically")[Eine Anleitung auf Baeldung] geht hier nochmal genauer in die einzelnen Konfigurationsmöglichkeiten. Die Anleitung wurde auch für unser Beispiel als Grundlage genommen. 

== Von JSON Schema zum Zod Schema

Für diesen Schritt wurde die `json-schema-to-zod`-Bibliothek verwendet.
Die Bibliothek konsumiert das JSON Schema und gibt einen String zurück, welcher das Zod Schema abbildet und in eine Datei geschrieben werden kann.

```ts
const zodifiedData = jsonFiles.map( filePath => ([
  basename(filePath).replace(".json", ""), 
  jsonSchemaToZod(JSON.parse(readFileSync(filePath, "utf8")))
]));

const moduleText = [
  "import {z} from 'zod';",
  ...zodifiedData.map( ([name, content]) => `
  export const ${name}Zod = ${content}; 
  export type ${name} = z.infer<typeof ${name}Zod>;
  `)
].join("\n")
```

Der Inhalt wird mithilfe eines Build-Skriptes in eine TypeScript-Datei geschrieben.
Das Frontend kann dann die Schemas einfach Importieren.

```ts
import { WeatherDataResponseDTOZod } from '../../generated/backendTypes';
// ...
const result = await fetch("...")
  .then(e => e.json())
  .then(e => WeatherDataResponseDTOZod.parse(e))
  .catch(err => console.log(err));
```

Die vollständige Implementation des Build-Skriptes #link("TODO")[kann dem Github Repository entnommen werden].

== Verhalten bei Updates

Wird das Interface des Backends angepasst, werden bei nächsten Bauen die JSON Schema-Dateien neu generiert.
So lange das Build-Skript nicht getriggert wurde, wird das Frontend für die geänderten Endpunkte Fehler werfen, weil die Antwort nicht dem erwarteten Schema entspricht.

Nachdem das Build-Skript durchlaufen, und dadurch die Zod Schemas angepasst wurden, hören die Fehler wegen dem unerwarteten Schema auf. Ggf. kommt es durch die Anpassung zu Compile-Zeit Fehlern durch `tsc`. Dadurch wird das neue aktualisierte Schema auch automatisch auf die generierten TypeScript-Typen abgebildet. Man bekommt also auch für die neuen Änderungen Autovervollständigungen durch die Entwicklungsumgebung.