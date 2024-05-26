---
title: "Projectify Development Log #3"
tags:
  - Projectify
params:
  author: Justus Perlwitz
---

Here are some of the things that have happened since [last week's
update](/blog/projectify-development-log-2).

# Password policy implemented

The Projectify sign-up page now implements a password policy.
Passwords are checked against a number of rules that [Django
ships with by
default](https://docs.djangoproject.com/en/dev/topics/auth/passwords/#module-django.contrib.auth.password_validation).

The rules at the time of writing are as follows:

> Your password can’t be too similar to your other personal
> information.

Passwords are compared to the user's email. If they are too similar,
the password is rejected.

> Your password must contain at least 8 characters.

> Your password can’t be a commonly used password.

> Your password can’t be entirely numeric.

Short passwords, or passwords using only a small variety of symbols
can be brute forced easily and do not contain enough entropy. [See
here for an
overview](https://en.wikipedia.org/w/index.php?title=Password_strength&oldid=1218849407#Random_passwords)
of password length and how much information entropy it contains.

Passwords can't be set to popularly used passwords, such as _qwerty_,
_12345678_, _lol123_, and so on. While users are ultimately
responsible for setting a safe password themselves, the Projectify
software should at least make some effort to guide users to choose
better passwords. [Commonly used passwords are used quite
commonly](https://www.bbc.com/news/technology-47974583).

I recommend using a reputable password manager to create and manage
random passwords. You can set long passwords containing special
characters on Projectify without any worries that it will be truncated
or rejected. Many websites have frustrating password complexity
restrictions that lead users to choosing weak passwords and ultimately
worsen their overall security.

# Help pages updated

I've rewritten most of the help pages to better reflect the current
state of the UI. The previous version of the Projectify help was
written with an older UI design and hasn't been updated since then. A
lot of UI component labels have changed, and many times the general
layout of the UI has changed as well. [You can find the help pages here](https://www.projectifyapp.com/help) (external link).

Should you have any questions about how to use Projectify, you can
always [contact us here](https://www.projectifyapp.com/contact-us)
(external link).

# Task create and update improved

The frontend will now ask users to confirm before they navigate away
from a task that they have started creating or updating to prevent accidentally discarding changes.

# Technical updates

Here are some of the technical changes to Projectify that improve the
behind the scenes functionality of the Projectify software:

The WebSocket API now properly [validates HTTP origin
headers](https://github.com/jwpconsulting/projectify/pull/491) to
prevent [cross site request
forgeries](https://owasp.org/www-community/attacks/csrf). This was not
implemented correctly in the beginning, and a [subsequent pull request
on GitHub](https://github.com/jwpconsulting/projectify/pull/495) fixed
a configuration issue.

A few modules in the frontend and backend have been simplified and
refactored for readability. Two model admins in the Django admin pages
have been improved for better usability as well.

An OpenAPI schema for the backend API is now [created
semi-automatically](https://github.com/jwpconsulting/projectify/pull/486)
and I have [started using
it](https://github.com/jwpconsulting/projectify/pull/488) to validate
requests made by the frontend.

When viewing different tasks in the frontend, the previously viewed
task would briefly be visible due to a bug in the custom WebSocket
store implemented in the frontend. This issue was discovered and fixed
in a [pull
request](https://github.com/jwpconsulting/projectify/pull/492).

[Python was
updated](https://github.com/jwpconsulting/projectify/pull/489) on
Heroku and CircleCI to use Python version 3.11.6.

The size of the ProjectReadUpdateDelete GET response [was
reduced](https://github.com/jwpconsulting/projectify/pull/483) to
improve dashboard load times when viewing a project.
