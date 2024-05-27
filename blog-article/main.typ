
#set text(lang: "de")
#set text(font: "Roboto")
#show heading: set text(navy)
#show figure.caption: emph
#show link: underline
#set page(
  header: align(left)[
    #text(size: 9pt, fill: gray)[
      #link("https://jira.opitz-consulting.de/browse/BLUE-745")[BLUE-745] - Laufzeitvalidierung im Frontend mit zod, Blog-Draft
    ]
  ],
  footer: align(right)[
    #text(size: 9pt, fill: gray)[
        | #counter(page).display()
    ]
  ],
  numbering: "1",
  number-align: right
)

#include "zod.typ"

#pagebreak()

#include "zod-frontend-backend.typ"