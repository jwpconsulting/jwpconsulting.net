# JWP Consulting GK Landing Page

This is the landing page for JWP Consulting GK. It can be accessed
[here](https://www.jwpconsulting.net).

# How to build

We use [Hugo](https://gohugo.io/) to build this site. The current version at
the time of writing is

> hugo v0.120.3+extended darwin/arm64 BuildDate=unknown VendorInfo=nixpkgs

Hugo can be installed using the nix flake in this repository.

Node version 20.9.0 is used.

Install postCSS and other dependencies using `npm i`, then run

```bash
hugo
```

to build the site.

# Create a new blog post

If you want to write a new blog post, use `hugo new content`. To write a new
Projectify dev log, run the following:

```fish
# Used in fish, bash etc. invocation might be similar.
hugo new content content/blog/(date -Idate)-projectify-development-log-(read).md
```

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
