Typst ist eine moderne alternative zu LaTeX.

Die CLI ist mit Rust implementiert und kann über

```sh
cargo install --git https://github.com/typst/typst --locked typst-cli
```

installiert werden.
Evtl. müssen noch Build-Dependencies installiert werden. (Auf Linux/WSL: `libssl-dev` und `pkg-config`)

Danach wird Typst im Watch-Mode gestartet mit

```sh
typst w main.typ
```

Dies erstellt eine `main.pdf`
