# govdown 0.8.0

* Upgrade to GOV.UK Frontend release v3.4.0.  Some user-facing changes, see the
  [GOV.UK Frontend release
  notes](https://github.com/alphagov/govuk-frontend/releases/tag/v3.4.0)
    * Improved contrast of secondary text
    * Only add underline to back link when href exists
    * Fixed text resize issue with warning text icon
    * Fixed height and alignment issue within header in Chrome 76+
* Prevent highlightjs from highlighting the syntax of plain text.

# govdown 0.7.0

* Upgrade to GOV.UK Frontend release v3.2.0. No user-facing changes.
* Add an accessibility statement
  * Fix a tabbing problem with code blocks (#45)
  * Stop code block text being shrunk (325e71b937f08034ef6ab9b83f0f7c8dc7fd07a9)
  * Fix logo URL config (#44)
  * Add at least two links to each page
* Stop rendering New Transport font by mistake (#38)
* Fix accordion expansion (#36)
* Fix rendering hang with large images (04473a4530e540dfdf96be0f768c0568714ff3d3)

# govdown 0.6.0

* Upgrade to GOV.UK Frontend release v3.1.0. Many user-facing changes. See the
  [GOV.UK Frontend release
  notes](https://github.com/alphagov/govuk-frontend/releases/tag/v3.1.0).  None
  of the changes are breaking for users of govdown.
* Support accordions (#35) @mattkerlogue.

# govdown 0.5.0

## GOV.UK Design System upgrade

Upgrade to GOV.UK Frontend release v2.13.0. One user-facing change.  The crown
logo image in the header now:

* has height and width attributes set
* aligns better with 'GOV.UK' in IE8

(Pull request #1419)

## Govdown changes:

* Support warning text (#30, #29)
* Don't accidentally use New Transport font in tables (#31)
* Support shiny server by passing through args (#33) (#33) @RobinL

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
