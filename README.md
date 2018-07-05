[![Build Status](https://travis-ci.org/madworx/docshell.svg?branch=master)](https://travis-ci.org/madworx/docshell)

# docshell
_A  novel  approach  to  documenting command  line  tools  written  in
shell-script._

## Rationale

Typically in Software development, documentation  has a tendency to be
perceived  as  being  boring  to   do  all  fall  behind  the  regular
development process.

By keeping documentation tightly knit  to the source code, we increase
the  likelihood  of  the  documentation  being  up-to-date;  For  more
advanced  programming   languages,  there's   already  lots   of  good
frameworks for this.

Shell-scripts  prove to  be an  interesting domain  in that  aspect --
shell-scripts are  typically expected to be  portable across operating
systems, shell language variants; There  also, de facto, doesn't exist
a  *single*  authoritative  specification  on  how  the  "language"(s)
actually  works,  and different  vendors  have  over time  implemented
different functionality.

## Goals

Three important  factors are:

  * portability  (_being able  to run  on a  diverse set  of operating
    systems and shell dialects_)

  * low dependency on external  utilities (_not assuming that specific
    tools are  installed in  the environment the  script is  being run
    in_),

   * as well as having a small footprint. (_low SLOC for the framework
    itself_)

By placing the documentation  at the top of the file,  it is the first
thing a  developer sees when  opening up the  script in the  editor --
this will hopefully provide a "hint" as to update the documentation if
details in the script change.

Also, by  attempting to produce  good-looking --help  output, combined
with dynamic  features (such as  default value variable  expansion) we
further hope  that the  developer in  question will  see the  point in
keeping the documentation always-up-to-date.

## Compatability

Compatability   with  various   shells  and   operating  systems   are
automatically tested and  reports are published on  the following Wiki
page:

* [Compatibility matrix](https://github.com/madworx/docshell/wiki/Compatibility-matrix)

## Further reading

* https://en.wikipedia.org/wiki/Literate_programming
