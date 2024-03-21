
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
set.seed(5)
lengths <- sample(1:3, size = 100, replace = TRUE, prob = c(0.5, 0.2, 0.3))
pref <- lapply(lengths, function(n) sample(1:10, size = n))

prefio <- new_prefio(
  pref,
  levels = letters[1:10]
)

prefio
```

    ## <prefio[100]>
    ##   [1] f     b<e<d i<j   a     f     a<f<e b<g<h f<h   h<a   a     d     i    
    ##  [13] g     d<e<g j     g     c     i<j   j<g<i e<i   j<d   j<c<a b     f    
    ##  [25] d     h     f     e<h   b     c<j   e     c     c     c     g     f    
    ##  [37] c<i<d i<d<j e     d     i<f   e     e<a   j<g<a i<j   a<h<g a<h<f i    
    ##  [49] b<j<h h<b<d h     c<j<h a<f   b<j   b<c   i     c     a     i     i    
    ##  [61] e<h<b e     i<d   g<i   b<a   b<j   a<c   g     a<j   i<b   j<e   f<b<g
    ##  [73] j     g<j   g     e<g   a     g<h<b h     d     b<f   d<i   d     d    
    ##  [85] h     e     b<d   g<i<d g     a<g<e j<g<a f     c     i     f     i<j  
    ##  [97] g     a<g<b f     j

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
    ##   [1] F     B<E<D I<J   A     F     A<F<E B<G<H F<H   H<A   A     D     I    
    ##  [13] G     D<E<G J     G     C     I<J   J<G<I E<I   J<D   J<C<A B     F    
    ##  [25] D     H     F     E<H   B     C<J   E     C     C     C     G     F    
    ##  [37] C<I<D I<D<J E     D     I<F   E     E<A   J<G<A I<J   A<H<G A<H<F I    
    ##  [49] B<J<H H<B<D H     C<J<H A<F   B<J   B<C   I     C     A     I     I    
    ##  [61] E<H<B E     I<D   G<I   B<A   B<J   A<C   G     A<J   I<B   J<E   F<B<G
    ##  [73] J     G<J   G     E<G   A     G<H<B H     D     B<F   D<I   D     D    
    ##  [85] H     E     B<D   G<I<D G     A<G<E J<G<A F     C     I     F     I<J  
    ##  [97] G     A<G<B F     J

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
tibble(prefio)
```

    ## # A tibble: 100 x 1
    ##      prefio
    ##    <prefio>
    ##  1        F
    ##  2    B<E<D
    ##  3      I<J
    ##  4        A
    ##  5        F
    ##  6    A<F<E
    ##  7    B<G<H
    ##  8      F<H
    ##  9      H<A
    ## 10        A
    ## # i 90 more rows

``` r
tibble(prefio) |> 
  count(prefio, sort = TRUE)
```

    ## # A tibble: 54 x 2
    ##      prefio     n
    ##    <prefio> <int>
    ##  1        F     8
    ##  2        G     7
    ##  3        D     6
    ##  4        I     6
    ##  5        C     6
    ##  6        E     5
    ##  7      I<J     4
    ##  8        A     4
    ##  9        H     4
    ## 10        J     3
    ## # i 44 more rows

``` r
letter_prefs <- tibble(
  prefio, 
  timestamp = as.POSIXct(rnorm(100, sd = 1e5), origin = "2024-03-21")
)
letter_prefs
```

    ## # A tibble: 100 x 2
    ##      prefio timestamp          
    ##    <prefio> <dttm>             
    ##  1        F 2024-03-21 11:18:47
    ##  2    B<E<D 2024-03-21 01:40:12
    ##  3      I<J 2024-03-22 15:31:41
    ##  4        A 2024-03-20 17:20:55
    ##  5        F 2024-03-20 22:54:24
    ##  6    A<F<E 2024-03-21 09:04:03
    ##  7    B<G<H 2024-03-23 02:01:30
    ##  8      F<H 2024-03-22 20:18:13
    ##  9      H<A 2024-03-22 13:46:32
    ## 10        A 2024-03-22 11:34:57
    ## # i 90 more rows

Can do useful operations/calculations on the vector…

`pref_fp()` obtains the first preference, and `pref_tcp()` obtains the
preference between the two most frequent first preferences.

``` r
letter_prefs <- letter_prefs |> 
  mutate(fp = pref_fp(prefio), tcp = pref_tcp(prefio))

letter_prefs
```

    ## # A tibble: 100 x 4
    ##      prefio timestamp           fp    tcp  
    ##    <prefio> <dttm>              <fct> <fct>
    ##  1        F 2024-03-21 11:18:47 F     <NA> 
    ##  2    B<E<D 2024-03-21 01:40:12 B     <NA> 
    ##  3      I<J 2024-03-22 15:31:41 I     I    
    ##  4        A 2024-03-20 17:20:55 A     A    
    ##  5        F 2024-03-20 22:54:24 F     <NA> 
    ##  6    A<F<E 2024-03-21 09:04:03 A     A    
    ##  7    B<G<H 2024-03-23 02:01:30 B     <NA> 
    ##  8      F<H 2024-03-22 20:18:13 F     <NA> 
    ##  9      H<A 2024-03-22 13:46:32 H     A    
    ## 10        A 2024-03-22 11:34:57 A     A    
    ## # i 90 more rows

``` r
# Count most common first preferences
letter_prefs |> 
  count(fp, sort = TRUE)
```

    ## # A tibble: 10 x 2
    ##    fp        n
    ##    <fct> <int>
    ##  1 I        14
    ##  2 A        12
    ##  3 B        11
    ##  4 G        11
    ##  5 E        10
    ##  6 F        10
    ##  7 C         9
    ##  8 J         9
    ##  9 D         8
    ## 10 H         6

``` r
# Count most frequent two candidate preferences
letter_prefs |> 
  count(tcp, sort = TRUE)
```

    ## # A tibble: 3 x 2
    ##   tcp       n
    ##   <fct> <int>
    ## 1 <NA>     62
    ## 2 I        20
    ## 3 A        18

``` r
# Count the interaction between fp and tcp, to see how they compare
letter_prefs |> 
  count(fp, tcp, sort = TRUE)
```

    ## # A tibble: 19 x 3
    ##    fp    tcp       n
    ##    <fct> <fct> <int>
    ##  1 I     I        14
    ##  2 A     A        12
    ##  3 B     <NA>     10
    ##  4 F     <NA>     10
    ##  5 G     <NA>      9
    ##  6 C     <NA>      8
    ##  7 E     <NA>      8
    ##  8 D     <NA>      7
    ##  9 H     <NA>      5
    ## 10 J     <NA>      5
    ## 11 J     A         3
    ## 12 G     I         2
    ## 13 B     A         1
    ## 14 C     I         1
    ## 15 D     I         1
    ## 16 E     A         1
    ## 17 E     I         1
    ## 18 H     A         1
    ## 19 J     I         1

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
