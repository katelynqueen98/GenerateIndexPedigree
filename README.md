
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
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

## Simulating many pedigrees

Average family sizes can be recapitulated by simulating large numbers of
pedigrees. Here, we simulate 10,000 pedigrees from 30-year-olds with a
BRCA1 mutation. We can also track the number of positive cascade tests
generated in family members of testing age, 20 - 65.

``` r

# simulation - 10K pedigrees of given age, random sex
PedigreeSimulation <- function(indexAge,
                               nsim = 10000,
                               verbose = FALSE) {
  # set up 
  pedigreeSummary <- data.frame(indexAge = numeric(nsim),
                                indexVariant = character(nsim),
                                indexSex = character(nsim),
                                DNM = logical(nsim),
                                numKids = numeric(nsim),
                                possibleNumCascadeTests = numeric(nsim),
                                numCascadeTests = numeric(nsim),
                                numCascadePositives = numeric(nsim))
  
  # simulate
  for (i in 1:nsim) {
    variant <- "BRCA1"
    
    # simulate pedigree
    sex <- sample(c("M", "F"), 1)
    ped <- GenerateIndexPedigree(age = indexAge,
                                 sex = sex,
                                 variant = variant,
                                 denovo_rate = 0.005)
    
    # fix data type
    ped$Age <- as.numeric(ped$Age)
    
    # summary stats - index
    pedigreeSummary$indexAge[i]     <- indexAge
    pedigreeSummary$indexVariant[i] <- variant
    pedigreeSummary$indexSex[i]     <- sex
    pedigreeSummary$numKids[i]      <- sum(grepl("Child", ped$RelationshipToIndex))
    pedigreeSummary$DNM[i]          <- ifelse(isTRUE(ped$DeNovo[which(ped$RelationshipToIndex == "Self")]), TRUE, FALSE)
    
    # summary stats - pedigree
    ped_inAgeRange <- ped[which(ped$Age >= (indexAge - 10) & 
                                  ped$Age <= (indexAge + 35)), ]
    pedigreeSummary$possibleNumCascadeTests[i] <- nrow(ped_inAgeRange) - 1
    pedigreeSummary$numCascadeTests[i] <- max(nrow(ped_inAgeRange[which(ped_inAgeRange$UptakeTesting == "Yes"), ]) - 1, 0)
    pedigreeSummary$numCascadePositives[i] <- max(nrow(ped_inAgeRange[which(ped_inAgeRange$UptakeTesting == "Yes" 
                                            & ped_inAgeRange$Variant == variant), ]) - 1, 0)
  }
  
  # fix class of de novo
  pedigreeSummary$DNM <- as.logical(pedigreeSummary$DNM)
  
  # to return...
  pedigreeSummary
  print(paste0("**************** ", format(nsim, big.mark = ",", scientific = FALSE),
               " pedigrees of 30 year old index case born in ", 
               2026 - indexAge, " ****************"))
  print("Number of Children of Index:")
  print(summary(pedigreeSummary$numKids))
  print("Number of Relatives of testable age:")
  print(summary(pedigreeSummary$possibleNumCascadeTests))
  print("Number of Cascade Tests:")
  print(summary(pedigreeSummary$numCascadeTests))
  print("Number of Cascade Positives:")
  print(summary(pedigreeSummary$numCascadePositives))
  print("Index case de novo mutation rate:")
  print(round(sum(pedigreeSummary$DNM)/nsim, 4))
}

PedigreeSimulation(30)
#> [1] "**************** 10,000 pedigrees of 30 year old index case born in 1996 ****************"
#> [1] "Number of Children of Index:"
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   0.000   0.000   2.000   1.581   2.000   6.000 
#> [1] "Number of Relatives of testable age:"
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   1.000   6.000   8.000   7.974  10.000  27.000 
#> [1] "Number of Cascade Tests:"
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   0.000   0.000   2.000   2.488   4.000  13.000 
#> [1] "Number of Cascade Positives:"
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>  0.0000  0.0000  0.0000  0.7414  1.0000  8.0000 
#> [1] "Index case de novo mutation rate:"
#> [1] 0.0061
```
