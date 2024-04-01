---
title: "Projectify Development Log #1"
date: 2024-04-01
params:
  author: Justus Perlwitz
---

Projectify is now _ready for public use_. I've been updating and patching the
app for the last few months, after many people gave me helpful feedback.

I've now come to a point where I'm still _slightly_ embarrassed about how much
functionality is still missing, but the core functionality, providing a light
team-based project management software, is there and ready for everyone to use.

Here is a summary of some of the things that changed with Projectify recently.
Among others, I've

- completed an [internal security
  audit](https://www.projectifyapp.com/security/general),
- published [vulnerability disclosure
  information](https://www.projectifyapp.com/security/disclose),
- added a [humans.txt file](https://www.projectifyapp.com/humans.txt),
- properly populated all [third-party
  credits](https://www.projectifyapp.com/credits) for the frontend,
- updated various packages in the backend (Redis, Channels-Redis,
  Django-Anymail)
- added a warning to prevent users from [accidentally leaving
  forms](https://github.com/jwpconsulting/projectify/pull/452),
- improved page load times by [fixing a Svelte Kit routing
  issue](https://github.com/jwpconsulting/projectify/pull/451),
- fixed [various](https://github.com/jwpconsulting/projectify/pull/448)
  [asynchronous](https://github.com/jwpconsulting/projectify/pull/449) API
  fetching issues,
- fixed the [focus trap](https://github.com/jwpconsulting/projectify/pull/447)
  in some overlays,
- and countless more fixes and tweaks.

If you would like to give the Projectify app a try, you can [sign up here](https://www.projectifyapp.com/user/sign-up).
