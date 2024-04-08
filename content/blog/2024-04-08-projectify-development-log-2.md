---
title: "Projectify Development Log #2"
params:
  author: Justus Perlwitz
---

Here are some of the things that happened since [last week's update](/blog/projectify-updates/).

## Rate limiting

A friendly security researcher pointed out a few issues, that I've since then fixed, as described in the following three sections.

Some API endpoints did not have any rate limiting, making them a
potential target for abuse.

The solution was to use [Django
Ratelimit](https://django-ratelimit.readthedocs.io/en/stable/index.html)
to add sensible defaults especially to API endpoints that send emails,
[as can be seen in this pull request
defaults](https://github.com/jwpconsulting/projectify/pull/478).

Now, the Projectify backend restricts, among other limitations, how many times users can request password resets.

## Prevent Clickjacking

Projectify didn't have any [frame-embedding CSP
(frame-ancestors)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/frame-ancestors)
set, which could lead to [Clickjacking](https://owasp.org/www-community/attacks/Clickjacking).

Despite SvelteKit allowing [setting a
CSP](https://kit.svelte.dev/docs/configuration#csp) in the `svelte.config.js`
configuration file, it does not allow all of the possible headers, such as
`frame-ancestors` as part of `<meta http-equiv>`, as described in its
documentation:

> When pages are prerendered, the CSP header is added via a <meta http-equiv>
> tag (note that in this case, frame-ancestors, report-uri and sandbox
> directives will be ignored).

The solution was to instruct Netlify to return this CSP header instead in the
`netlify.toml` configuration file, as can be seen in [this pull
request](https://github.com/jwpconsulting/projectify/pull/471). The relevant
part in the configuration file is:

```toml
# ...
[[headers]]
  for = "/*"
  [headers.values]
    Content-Security-Policy = "frame-ancestors 'none'"
```

## Possible content injection via user preferred names

Projectify tries to respect user's preferred names, and does not place
a lot of restrictions on what users can enter there, given that it is
only visible inside of a trusted workspace environment and not to the
general public.

On the other hand, a preferred name can show up in some emails, such
as when a user is invited to become a workspace's team member. While
we only send plain text emails and therefore do not have the risk of
XSS injections into email templates, we can not control what an email
client does with plain text emails when it renders them.

If a preferred name contains a domain name or is URL-like, some email
clients automatically turn them into clickable links. We want to
prevent users from linking to external resources where it could be
misleading, especially in emails.

Out of an abundance of caution, a simple filter for _URL-like_ words in
preferred names was added in [this pull
request](https://github.com/jwpconsulting/projectify/pull/476).

# Other changes

I have also taken the time to fix a few smaller issues, such as the page header
[not rendering correctly](https://github.com/jwpconsulting/projectify/pull/472)
after logging in under some circumstances.

Third-party dependencies were updated, and some of the auxiliary tooling used
for the frontend was extracted into separate folders to curb Dependabot
false-positive dependency warnings, such as for Storybook, which pulls in an
extraordinary amount of third-party dependencies that are not used for the
Projectify production frontend.
