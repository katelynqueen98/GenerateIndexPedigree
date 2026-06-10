
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version-ago/modACDC)](https://cran.r-project.org/package=modACDC)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/modACDC)](https://cran.r-project.org/package=modACDC)
[![status](https://tinyverse.netlify.com/badge/modACDC)](https://CRAN.R-project.org/package=modACDC)
<!-- badges: end -->

# GenerateIndexPedigree

A series of functions to generate a pedigree around a given person with
a known genetic mutation, based on US census data. Pedigree will also
track mutation status of all members. Pedigree is built down to
children, back to grandparents, and out to cousins. There is also a
function to generate pedigrees without genetic mutations.

## Installation

You can install the development, GitHub version of this package with:

``` r
install.packages("remotes")
remotes::install_github("katelynqueen98/GenerateIndexPedigree")
```

## Examples

The main functions of the package, `GenerateIndexPedigree()` and
`GeneratePedigree()` provide many parameter options. Here is a basic
pedigree of a 30-year-old female with a mutation in BRCA1, which has a
*de novo* mutation rate of 0.005.

``` r
library(GenerateIndexPedigree)
set.seed(123)
GenerateIndexPedigree(age = 30,
                      sex = "F",
                      variant = "BRCA1",
                      denovo_rate = 0.005)
#>    Age Sex    Variant RelationshipToIndex                   ChildOf DeNovo Told
#> 1    4   M      BRCA1             Child_1                     Index     NA  Yes
#> 2   -1   M      BRCA1             Child_2                     Index     NA  Yes
#> 3   -9   M No Variant             Child_3                     Index     NA  Yes
#> 4   30   F      BRCA1                Self                   Parents  FALSE  Yes
#> 5   49   F      BRCA1              Mother      MaternalGrandparents  FALSE  Yes
#> 6   59   M No Variant              Father      PaternalGrandparents     NA  Yes
#> 7   23   M No Variant           Brother_1                   Parents     NA  Yes
#> 8   19   F      BRCA1            Sister_2                   Parents     NA  Yes
#> 9   -8   F No Variant             Niece_1                  Sister_2     NA  Yes
#> 10  70   F      BRCA1 MaternalGrandmother MaternalGreatGrandparents  FALSE  Yes
#> 11  79   M No Variant MaternalGrandfather MaternalGreatGrandparents     NA  Yes
#> 12  41   F      BRCA1      MaternalAunt_1      MaternalGrandparents     NA  Yes
#> 13  18   F      BRCA1    MaternalCousin_1            MaternalAunt_1     NA  Yes
#> 14   9   F      BRCA1    MaternalCousin_2            MaternalAunt_1     NA  Yes
#> 15  82   F No Variant PaternalGrandmother PaternalGreatGrandparents     NA  Yes
#> 16  85   M No Variant PaternalGrandfather PaternalGreatGrandparents     NA  Yes
#> 17  63   F No Variant      PaternalAunt_1      PaternalGrandparents     NA  Yes
#>    UptakeTesting
#> 1            Yes
#> 2            Yes
#> 3            Yes
#> 4            Yes
#> 5            Yes
#> 6            Yes
#> 7             No
#> 8             No
#> 9            Yes
#> 10           Yes
#> 11           Yes
#> 12            No
#> 13           Yes
#> 14            No
#> 15           Yes
#> 16            No
#> 17            No
```

By default, all children that will ever be born from an individual are
included, regardless of if they have been born yet. This is shown by
negative ages, indicating the child will be born in a future year. These
individuals can be excluded by setting parameter `keep_future_children`
to `FALSE`

``` r
set.seed(123)
GenerateIndexPedigree(age = 30,
                      sex = "F",
                      variant = "BRCA1",
                      denovo_rate = 0.005,
                      keep_future_children = FALSE)
#>    Age Sex    Variant RelationshipToIndex                   ChildOf DeNovo Told
#> 1    4   M      BRCA1             Child_1                     Index     NA  Yes
#> 4   30   F      BRCA1                Self                   Parents  FALSE  Yes
#> 5   49   F      BRCA1              Mother      MaternalGrandparents  FALSE  Yes
#> 6   59   M No Variant              Father      PaternalGrandparents     NA  Yes
#> 7   23   M No Variant           Brother_1                   Parents     NA  Yes
#> 8   19   F      BRCA1            Sister_2                   Parents     NA  Yes
#> 10  70   F      BRCA1 MaternalGrandmother MaternalGreatGrandparents  FALSE  Yes
#> 11  79   M No Variant MaternalGrandfather MaternalGreatGrandparents     NA  Yes
#> 12  41   F      BRCA1      MaternalAunt_1      MaternalGrandparents     NA  Yes
#> 13  18   F      BRCA1    MaternalCousin_1            MaternalAunt_1     NA  Yes
#> 14   9   F      BRCA1    MaternalCousin_2            MaternalAunt_1     NA  Yes
#> 15  82   F No Variant PaternalGrandmother PaternalGreatGrandparents     NA  Yes
#> 16  85   M No Variant PaternalGrandfather PaternalGreatGrandparents     NA  Yes
#> 17  63   F No Variant      PaternalAunt_1      PaternalGrandparents     NA  Yes
#>    UptakeTesting
#> 1            Yes
#> 4            Yes
#> 5            Yes
#> 6            Yes
#> 7             No
#> 8             No
#> 10           Yes
#> 11           Yes
#> 12            No
#> 13           Yes
#> 14            No
#> 15           Yes
#> 16            No
#> 17            No
```

Additionally, the *de novo* status of each generational mutation (index,
parent, grandparent) is simulated using either the default rate of 2e-06
or the rate given in parameter `denovo_rate`. If the *de novo* status of
the index case is known, it can be supplied in parameter `is_denovo`.

``` r
set.seed(123)
GenerateIndexPedigree(age = 30,
                      sex = "F",
                      variant = "BRCA1",
                      keep_future_children = FALSE,
                      is_denovo = TRUE,
                      verbose = TRUE)
#> Index case had a de novo mutation. All cascade tests of previous generations are negative.
#>    Age Sex    Variant RelationshipToIndex                   ChildOf DeNovo Told
#> 1    4   M      BRCA1             Child_1                     Index     NA  Yes
#> 4   30   F      BRCA1                Self                   Parents   TRUE  Yes
#> 5   49   F No Variant              Mother      MaternalGrandparents     NA  Yes
#> 6   59   M No Variant              Father      PaternalGrandparents     NA  Yes
#> 7   23   M No Variant           Brother_1                   Parents     NA  Yes
#> 8   19   F No Variant            Sister_2                   Parents     NA  Yes
#> 10  70   F No Variant MaternalGrandmother MaternalGreatGrandparents     NA  Yes
#> 11  79   M No Variant MaternalGrandfather MaternalGreatGrandparents     NA  Yes
#> 12  41   F No Variant      MaternalAunt_1      MaternalGrandparents     NA  Yes
#> 13  18   F No Variant    MaternalCousin_1            MaternalAunt_1     NA  Yes
#> 14   9   F No Variant    MaternalCousin_2            MaternalAunt_1     NA  Yes
#> 15  82   F No Variant PaternalGrandmother PaternalGreatGrandparents     NA  Yes
#> 16  85   M No Variant PaternalGrandfather PaternalGreatGrandparents     NA  Yes
#> 17  63   F No Variant      PaternalAunt_1      PaternalGrandparents     NA  Yes
#>    UptakeTesting
#> 1            Yes
#> 4            Yes
#> 5            Yes
#> 6            Yes
#> 7             No
#> 8             No
#> 10           Yes
#> 11           Yes
#> 12            No
#> 13           Yes
#> 14            No
#> 15           Yes
#> 16            No
#> 17            No
```

Finally, a pedigree without any mutation information can be generated
using the `GeneratePedigree()` function.

``` r
set.seed(123)
GeneratePedigree(age = 30,
                 sex = "F",
                 keep_future_children = FALSE)
#>    Age Sex RelationshipToIndex                   ChildOf
#> 1    4   M             Child_1                     Index
#> 4   30   F                Self                   Parents
#> 5   49   F              Mother      MaternalGrandparents
#> 6   59   M              Father      PaternalGrandparents
#> 7   23   M           Brother_1                   Parents
#> 8   19   F            Sister_2                   Parents
#> 10  70   F MaternalGrandmother MaternalGreatGrandparents
#> 11  79   M MaternalGrandfather MaternalGreatGrandparents
#> 12  41   F      MaternalAunt_1      MaternalGrandparents
#> 13  18   F    MaternalCousin_1            MaternalAunt_1
#> 14   9   F    MaternalCousin_2            MaternalAunt_1
#> 15  82   F PaternalGrandmother PaternalGreatGrandparents
#> 16  85   M PaternalGrandfather PaternalGreatGrandparents
#> 17  63   F      PaternalAunt_1      PaternalGrandparents
```
