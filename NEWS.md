# govdown (development version)

* Support warning text (#30, #29)
* Don't accidentally use New Transport font in tables (#31)

# govdown 0.4.1

* Upgrade to GOV.UK Frontend release v2.12.0. No user-facing changes.

# govdown 0.4.0

* Overhauled yaml configuration to make websites and standalone pages more
    consistent.
* `favicon = "none"` by default to avoid inadvertently using the GOV.UK crown
    logo.
* Phase banner wording no longer mentions "services".
* The New Transport font isn't embedded unless it is used.
* The "skip to main content" link appears above the banner (press Tab to find
    it).

# govdown 0.3.0

* Implemented bold according to the GOV.UK Design System.
* Disabled italics and strike-through, which are not supported by the GOV.UK
    Design System.

# govdown 0.2.0

* Added implementation of the `Details` component from the GOV.UK Design System.
* Added implementation of the `Table` component from the GOV.UK Design System.
* Defaults to sans-serif font and no logo, because most documents won't be
    hosted on GOV.UK.
* Added Google Analytics.
* Updated the embedded GOV.UK Design System.
* Minor tweaks and bugfixes.

# govdown 0.1.0

First release.

# govdown 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
