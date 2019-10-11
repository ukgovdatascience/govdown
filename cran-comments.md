## Resubmission

* Added \value to .Rd files.

* Rewrote examples to use a small file in inst/extdata.  But did not remove
    \dontrun{} as requested because the examples require Pandoc version 2, which
    is not available on CRAN (checked with winbuilder with R devel).

## Test environments

### Local
* Arch Linux 4.19.75-1-lts         R-release 3.6.1

### Win-builder
* x86_64-w64-mingw32               R-release 3.6.1
* x86_64-w64-mingw32               R-devel   2019-10-05 r77257

### Travis

* Ubuntu Linux 16.04.6 LTS x64     R-release 3.6.1 (2017-01-27)

### Rhub
* Ubuntu Linux 16.04 LTS GCC       R-release 3.6.1
* Fedora Linux, clang, gfortran    R-devel   2019-10-05 r77257
* Windows Server 2008 R2 SP1       R-devel


## R CMD check results

0 errors | 0 warnings | 1 note

* New submission
