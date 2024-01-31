# JWP Consulting GK Landing Page

This is the landing page for JWP Consulting GK. It can be accessed
[here](https://www.jwpconsulting.net).

# How to build

We use [Hugo](https://gohugo.io/) to build this site. The current version at
the point of writing is

```
hugo v0.110.0+extended darwin/arm64 BuildDate=unknown
```

installed using [Homebrew](https://brew.sh/) on macOS Ventura.

# Spellchecking

Use the [Nix flake](https://nixos.wiki/wiki/Flakes) in this repository to
quickly spin up a spellchecker. Then, for the file that you would like to
check, run:

```
bin/spellcheck $THE_NAME_OF_THE_FILE
```

# License

This project is licensed under the GPL. Please refer to the exact terms in the
`LICENSE` file.
