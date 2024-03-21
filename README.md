
# [prefio](https://fleverest.github.io/prefio/)

<!-- badges: start -->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/prefio)](https://cran.r-project.org/package=prefio)
[![R-CMD-check](https://github.com/fleverest/prefio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/fleverest/prefio/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/fleverest/prefio/branch/main/graph/badge.svg)](https://app.codecov.io/gh/fleverest/prefio?branch=main)
<!-- badges: end -->

## Overview

Ordinal Preference datasets are used by many research communities
including, but not limited to, those who work with recommender systems,
computational social choice, voting systems and combinatorial
optimization.

The **prefio** R package provides a set of functions which enable users
to perform a wide range of preference analysis tasks, including
preference aggregation, pairwise comparison summaries and convenient IO
operations. This makes it easier for researchers and other professionals
to perform common data analysis and preprocessing tasks with such
datasets.

## Installation

The package may be installed from CRAN via

``` r
install.packages("prefio")
```

The development version can be installed via

``` r
# install.packages("remotes")
remotes::install_github("fleverest/prefio")
```

## Usage

**prefio** provides a convenient interface for processing data from
tabular formats as well as sourcing data from one of the unified
[PrefLib formats](https://www.preflib.org/format/), including a
convenient method for downloading data files directly from PrefLib to
your R session.

#### Processing tabular data

Preference data can come in many forms. Commonly preference data will be
either represented in either *long*-format with each row corresponding
to a particular *ranking* chosen for a single *item*:, e.g:

|  ID | ItemName | Rank |
|----:|:---------|-----:|
|   1 | A        |    1 |
|   1 | B        |    2 |
|   1 | C        |    3 |
|   2 | A        |    3 |
|   2 | B        |    2 |
|   2 | C        |    1 |
|   3 | A        |    2 |
|   3 | B        |    1 |
|   3 | C        |    3 |

Three orderings on items {A, B, C} in long-format.

This data can be converted from a `data.frame` into a `preferences`
object:

``` r
long <- data.frame(
  ID = rep(1:3, each = 3),
  ItemName = LETTERS[rep(1:3, 3)],
  Rank = c(1, 2, 3, 3, 2, 1, 2, 1, 3)
)
prefs <- preferences(long,
  format = "long",
  id = "ID",
  item = "ItemName",
  rank = "Rank"
)
print(prefs)
```

    ## [1] [A > B > C] [C > B > A] [B > A > C]

Another way of tabulating orderings is with each unique ordering on a
single row, with each column representing the rank given to a particular
item:

|   A |   B |   C |
|----:|----:|----:|
|   1 |   2 |   3 |
|   3 |   2 |   1 |
|   2 |   1 |   3 |

Three orderings on items {A, B, C} in a “rankings” format.

This data can be converted from a `data.frame` into a `preferences`
object:

``` r
rankings <- matrix(
  c(
    1, 2, 3,
    3, 2, 1,
    2, 1, 3
  ),
  nrow = 3,
  byrow = TRUE
)
colnames(rankings) <- LETTERS[1:3]
prefs <- preferences(rankings,
  format = "ranking"
)
print(prefs)
```

    ## [1] [A > B > C] [C > B > A] [B > A > C]

#### Reading from PrefLib

The [Netflix Prize](https://en.wikipedia.org/wiki/Netflix_Prize) was a
competition devised by Netflix to improve the accuracy of its
recommendation system. To facilitate this they released ratings about
movies from the users of the system that have been transformed to
preference data and are available from
[PrefLib](https://www.preflib.org/data/ED/00004/), (Bennett and Lanning
2007). Each data set comprises rankings of a set of 3 or 4 movies
selected at random. Here we consider rankings for just one set of movies
to illustrate the functionality of **prefio**.

PrefLib datafiles such as these can be downloaded on-the-fly by
specifying the argument `from_preflib = TRUE` in the `read_preflib`
function:

``` r
netflix <- read_preflib("netflix/00004-00000138.soc", from_preflib = TRUE)
head(netflix)
```

    ##                                preferences frequencies
    ## 1 [Beverly Hills Cop > Mean Girls > M ...]          68
    ## 2 [Mean Girls > Beverly Hills Cop > M ...]          53
    ## 3 [Beverly Hills Cop > Mean Girls > T ...]          49
    ## 4 [Mean Girls > Beverly Hills Cop > T ...]          44
    ## 5 [Beverly Hills Cop > Mission: Impos ...]          39
    ## 6 [The Mummy Returns > Beverly Hills  ...]          37

Each row corresponds to a unique ordering of the four movies in the
dataset. The number of Netflix users that assigned each ordering is
given in the `frequencies` column. In this case, the most common
ordering (with 68 voters specifying the same preferences) is the
following:

``` r
print(netflix$preferences[1], width = 100)
```

    ## [1] [Beverly Hills Cop > Mean Girls > Mission: Impossible II > The Mummy Returns]

#### Writing to Preflib formats

**prefio** provides a convenient interface for writing preferential
datasets to PrefLib formats. To aid the user, the `preferences()`
function automatically calculates metrics of the dataset which are
required for producing valid PrefLib files. For example, we can write
our `prefs` from earlier:

``` r
write_preflib(prefs)
```

    ## Warning in write_preflib(prefs): Missing `title`: the PrefLib format requires a
    ## title to be specified. Using `NA`.

    ## Warning in write_preflib(prefs): Missing `publication_date`, using today's
    ## date(2024-03-21).

    ## Warning in write_preflib(prefs): Missing `modification_date`, using today's
    ## date(2024-03-21).

    ## Warning in write_preflib(prefs): Missing `modification_type`: the PrefLib
    ## format requires this to be specified. Using `NA`.

    ## # FILE NAME: NA
    ## # TITLE: NA
    ## # DESCRIPTION: 
    ## # DATA TYPE: soc
    ## # MODIFICATION TYPE: NA
    ## # RELATES TO: 
    ## # RELATED FILES: 
    ## # PUBLICATION DATE: 2024-03-21
    ## # MODIFICATION DATE: 2024-03-21
    ## # NUMBER ALTERNATIVES: 3
    ## # NUMBER VOTERS: 3
    ## # NUMBER UNIQUE ORDERS: 3
    ## # ALTERNATIVE NAME 1: A
    ## # ALTERNATIVE NAME 2: B
    ## # ALTERNATIVE NAME 3: C
    ## 1: 1,2,3
    ## 1: 3,2,1
    ## 1: 2,1,3

Note that this produces four warnings. Each warning corresponds to a
field which is required by the official PrefLib format, but may not be
necessary for internal use-cases. If your goal is to publish some data
to PrefLib, these warnings must be resolved.

## vctrs prototype

Construct a prefio vector with `new_prefio()`

``` r
lengths <- sample(1:3, size = 100, replace = TRUE, prob = c(0.5, 0.2, 0.3))
pref <- lapply(lengths, function(n) sample(1:10, size = n))

prefio <- new_prefio(
  pref,
  levels = letters[1:10]
)

prefio
```

    ## <prefio[100]>
    ##   [1] d     b<h   h     i<h<c i<h<g c<b<g e<d<j j<i   h     a     e<h   i<b<e
    ##  [13] d     d<h   j<f   g<f<d f     j<g<d j<e   h<f<c d     e     f     c    
    ##  [25] a<c   g     a<b<f d<c   f     h     a     d     d     d     j     i    
    ##  [37] b     j     h<a<d h<b   g<b<c f<h   h<f<e j<c   a     d<j<g d     b<e  
    ##  [49] d<b<g b     b<h<g e     a     i<c<e j     d<h<e f<e   g<i<e a     h<c  
    ##  [61] a<e   d     g     d     j<e   h<g<a g     d     a<h   f     i<a<d d    
    ##  [73] b<i   d<c   c     c<j<f c     e     e     j     c     c     g     b<g<j
    ##  [85] b<g<f i     i     j<h<e i     d     g<c<f g     b     e     j     d<b<i
    ##  [97] b<a<e b     f<a<e g<e

Obtain all options and change the labelling by modifying the levels

``` r
levels(prefio)
```

    ##  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j"

``` r
levels(prefio) <- LETTERS[1:10]
prefio
```

    ## <prefio[100]>
    ##   [1] D     B<H   H     I<H<C I<H<G C<B<G E<D<J J<I   H     A     E<H   I<B<E
    ##  [13] D     D<H   J<F   G<F<D F     J<G<D J<E   H<F<C D     E     F     C    
    ##  [25] A<C   G     A<B<F D<C   F     H     A     D     D     D     J     I    
    ##  [37] B     J     H<A<D H<B   G<B<C F<H   H<F<E J<C   A     D<J<G D     B<E  
    ##  [49] D<B<G B     B<H<G E     A     I<C<E J     D<H<E F<E   G<I<E A     H<C  
    ##  [61] A<E   D     G     D     J<E   H<G<A G     D     A<H   F     I<A<D D    
    ##  [73] B<I   D<C   C     C<J<F C     E     E     J     C     C     G     B<G<J
    ##  [85] B<G<F I     I     J<H<E I     D     G<C<F G     B     E     J     D<B<I
    ##  [97] B<A<E B     F<A<E G<E

Works well with the tidyverse

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
tibble(prefio) |> 
  count(prefio, sort = TRUE)
```

    ## # A tibble: 56 x 2
    ##      prefio     n
    ##    <prefio> <int>
    ##  1        D    12
    ##  2        A     5
    ##  3        E     5
    ##  4        C     5
    ##  5        G     5
    ##  6        J     5
    ##  7        F     4
    ##  8        I     4
    ##  9        B     4
    ## 10        H     3
    ## # i 46 more rows

``` r
letter_prefs <- tibble(
  prefio, 
  timestamp = as.POSIXct(rnorm(100, sd = 1e5), origin = Sys.Date())
)
```

Can do useful operations/calculations on the vector…

`pref_fp()` obtains the first preference, and `pref_tcp()` obtains the
preference between the two most frequent first preferences.

``` r
letter_prefs <- letter_prefs |> 
  mutate(fp = pref_fp(prefio), tcp = pref_tcp(prefio))

letter_prefs |> 
  count(fp, sort = TRUE)
```

    ## # A tibble: 10 x 2
    ##    fp        n
    ##    <fct> <int>
    ##  1 D        19
    ##  2 J        12
    ##  3 B        11
    ##  4 G        10
    ##  5 A         9
    ##  6 H         9
    ##  7 I         9
    ##  8 C         7
    ##  9 E         7
    ## 10 F         7

``` r
letter_prefs |> 
  count(tcp, sort = TRUE)
```

    ## # A tibble: 3 x 2
    ##   tcp       n
    ##   <fct> <int>
    ## 1 <NA>     63
    ## 2 D        23
    ## 3 J        14

``` r
letter_prefs |> 
  count(fp, tcp, sort = TRUE)
```

    ## # A tibble: 16 x 3
    ##    fp    tcp       n
    ##    <fct> <fct> <int>
    ##  1 D     D        19
    ##  2 J     J        12
    ##  3 B     <NA>     10
    ##  4 A     <NA>      9
    ##  5 G     <NA>      9
    ##  6 H     <NA>      8
    ##  7 I     <NA>      8
    ##  8 F     <NA>      7
    ##  9 C     <NA>      6
    ## 10 E     <NA>      6
    ## 11 B     J         1
    ## 12 C     J         1
    ## 13 E     D         1
    ## 14 G     D         1
    ## 15 H     D         1
    ## 16 I     D         1

## Projects using **prefio**

The [New South Wales Legislative Assembly Election
Dataset](https://github.com/fleverest/nswla_preflib) uses **prefio** to
process the public election datasets into PrefLib formats.

The R package
[elections.dtree](https://github.com/fleverest/elections.dtree) uses
**prefio** for tracking ballots observed by the Dirichlet-tree model.

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-Bennett2007" class="csl-entry">

Bennett, J., and S. Lanning. 2007. “The Netflix Prize.” In
*<span class="nocase">Proceedings of the KDD Cup Workshop 2007</span>*,
3–6. ACM.

</div>

</div>
