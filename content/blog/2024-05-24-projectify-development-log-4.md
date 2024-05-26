---
title: "Projectify Development Log #4"
tags:
  - Projectify
params:
  author: Justus Perlwitz
---

Here's what's new in the Projectify project management application since the
[last update blog on 2024-04-08](/blog/projectify-development-log-3/).

# Security

## Password validation applied when changing passwords as well

The password validation logic that was added recently for new users is now
[also applied to users changing their current
password](https://github.com/jwpconsulting/projectify/pull/507). To reiterate,
the current validation criteria are:

- The password can't be too similar to other personal information, e.g., email
- The password must contain at least 8 characters
- The password can't be a commonly used password
- The password can't be entirely numeric

Please keep in mind that these criteria only raise the minimum standard for
passwords, and do not guarantee that a password is actually difficult to crack
and therefore safe when brute-forced. At JWP Consulting, we recommend use a
password manager and generating unique and random passwords for each log in
account to stay safe.

# Bug fixes

## Navigation confirmation shown incorrectly when editing tasks

When creating or editing tasks, the Projectify frontend navigates back to a
task's project page, after everything has been saved correctly in the backend. I
have recently added a confirmation dialog to task creation and update screens
which ask the user to confirm whether they want to navigate away from a task
and discard their changes.

Unfortunately, this dialog would also be triggered when the Projectify frontend
successfully saves a task. Akin to: _Error, this operation has succeeded_.

The confirmation logic was not "aware" of whether the navigation was triggered
because of the user wanting to go away and discard their changes, or whether
the app successfully saved, and the user was being redirected back to the
project page.

The solution was to keep track of the form's state and to not show the
confirmation dialog when the form state was "everything has been saved
correctly".

## Preferred name validation

Preferred names ending on periods were falsely rejected. This affect preferred
names such as `Firstname Lastname Jr.`.

The [original preferred name
filtering](https://github.com/jwpconsulting/projectify/pull/476) was introduced
to prevent arbitrary URL content injection. Previously, it was possible to set
a preferred name to be a URL or domain name, which some email clients very
liberally turned into clickable URLs. This happened despite Projectify emails
being plain-text only, and therefore not containing any HTML.

A user could, for example, change their name to a malicious URL and send out
team member invitation emails. These emails would contain clickable links that
could lead a victim to click a link not belonging to the Projectify application. While the
origin of this problem lies beyond the realm of the Projectify application,
we try to prevent content injections like these out of an abundance of caution.

Names ending on a period are not rendered as clickable URLs in an email client,
and therefore do not need to be rejected. I have changed the regular expression
validating preferred emails in [pull request
#509](https://github.com/jwpconsulting/projectify/pull/509).

Input validation remains a challenge, even when using secure frameworks.
Peripheral software, such as email clients, can demonstrate surprising
behavior, and it is up to us software developers to stay on top of this.

## Other bug fixes

Here are some miscellaneous bug fixes added over the last few weeks:

- The error page would not correctly distinguish between 404-like errors and
  other errors, such as page render errors. [This was
  fixed](https://github.com/jwpconsulting/projectify/pull/502).

# New features

Here are some of the small quality-of-life updates that have been added over
the last few weeks:

- Image asset optimization using [Svelte's
  enhanced:img](https://kit.svelte.dev/docs/images#sveltejs-enhanced-img) [was
  added](https://github.com/jwpconsulting/projectify/pull/503). This allows
  pages to be loaded more quickly.
- A [sitemap is now
  rendered](https://github.com/jwpconsulting/projectify/pull/501) to ease
  crawling public facing pages.

# Thank you

Thank you to all the kind people on the internet who have been trying out
the Projectify application over the last few weeks and have reported various
issues.
