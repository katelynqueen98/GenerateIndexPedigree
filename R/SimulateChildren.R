#' SimulateChildren
#'
#' @description Function to simulate number and ages of children given age of mother or father
#'
#' @param mother_age numeric, age of mother
#' @param father_age numeric, age of father, if known; only required if simulating children based on father; default is NA
#' @param pedigree_size character, one of "Small", "Average", or "Large"; indicates average size of family in pedigree; default is "Average"
#' @param variant character, name of variant for index case; default is "None" for unaffected index
#' @param has_children logical, represents whether is known if parent has children; default is FALSE
#' @param known_child_age numeric, age of known child; only used if has_children is TRUE
#' @param current_year numeric, year to age individuals to; default is 2026
#'
#' @return a dataframe representing the children of indicated parent, where each row represents a person and columns represent attributes:
#'
#' \describe{
#' \item{Age}{numeric, person age}
#' \item{Sex}{character, person sex; either "M" or "F"}
#' \item{Variant}{character, person's variant status; either NA or same as parameter}
#' \item{Father}{character, denotes which father child came from; accounts for complex family structures}
#' }
#'
#' @examples
#' SimulateChildren(mother_age = 35, pedigree_size = "Small", variant = "BRCA1")
#'
#' @details
#' This function generates children given parental ages, pedigree size, variant status, and current year has_children and known_child_age are for generating past generations where we know there is at least one child of age X. If father_age given, calls .GenerateChildrenFromFather
#'
#' @references
#' Guzzo KB. New Partners, More Kids: Multiple-Partner Fertility in the United States. Ann Am Acad Pol Soc Sci. 2014 Jul;654(1):66-86. doi: 10.1177/0002716214525571.
#'
#' Monte and Knop, United States Census Bureau. Men's Fertility and Fatherhood: 2014 (2019); https://www.census.gov/content/dam/Census/library/publications/2019/demo/P70-162.pdf
#'
#' Pew Research Center. The Modern American Family (2023); https://www.pewresearch.org/social-trends/2023/09/14/the-modern-american-family/
#'
#' Schwartz, Doren, and Li, The Springer Series on Demographic Methods and Population Analysis, vol 51 (2020), DOI: 10.1007/978-3-030-48519-1_10
#'
#' Schweizer. 30 Years of Change in Men's Entry into Fatherhood, 1987-2017 (2019); https://www.bgsu.edu/ncfmr/resources/data/family-profiles/schweizer-years-change-mens-entry-fatherhood-fp-19-28.html
#'
#' Schweizer and Guzzo. Distributions of Age at First Birth, 1960-2018 (2020); https://www.bgsu.edu/ncfmr/resources/data/family-profiles/schweizer-guzzo-distribution-age-first-birth-fp-20-11.html
#'
#' United States Census Bureau. Annual Social and Economic Supplements; https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html
#'
#' @author Katelyn Queen \email{kqueen@@mednet.ucla.edu}
#'
#' @export
SimulateChildren <- function(mother_age,
                             father_age = NA,
                             pedigree_size = "Average",
                             variant = "None",
                             has_children = FALSE,
                             known_child_age = NA,
                             current_year = 2026) {

  # parameter checks
  if (!(pedigree_size %in% c("Small", "Average", "Large"))) {
    stop("pedigree_size must be one of Small, Average, or Large")
  }
  if (!is.character(variant)) {
    stop("variant is not an acceptable input; should be a character")
  }
  if(!is.logical(has_children)) {
    stop("has_children is not an acceptable input; should be logical")
  }
  if(!is.numeric(current_year)) stop("current_year must be numeric")

  # if variant = NA, change to "None" to avoid errors
  if (is.na(variant)) variant <- "None"

  # use .GenerateChildrenFromFather if given father's age
  if(!is.na(father_age)) {
    return(.GenerateChildrenFromFather(father_age = father_age,
                                      variant = variant,
                                      pedigree_size = pedigree_size,
                                      current_year = current_year))
  }

  # fix data types
  mother_age      <- as.numeric(mother_age)
  known_child_age <- as.numeric(known_child_age)

  # more parameter checks
  if (!is.numeric(mother_age)) {
    stop("mother_age must be numeric")
  }
  if(!is.na(known_child_age) & (mother_age - known_child_age < 15)) {
    stop("known_child_age is not an acceptable value; known_child must be at least fifteen years younger than mother")
  }

  # mother birth year
  motherBY <- current_year - mother_age

  # number of children distribution based on mothers age
  ## Number of children -- "The Modern American Family" and US Census Bureau
  pre1940    <- c(0.1, 0.1, 0.22, 0.23, 0.2, 0.08, 0.06)
  x1941_1970 <- c(0.17, 0.18, 0.35, 0.19, 0.08, 0.02, 0.01)
  x1971_1990 <- c(0.25, 0.19, 0.32, 0.14, 0.07, 0.02, 0.01)
  post1991   <- c(0.38, 0.21, 0.27, 0.09, 0.03, 0.01, 0.001)

  # apply weights based on pedigree size
  if(pedigree_size == "Small") {
    small_weights <- c(1.75, 1.75, 1.25, 0.75, 0.75, 0.5, 0.25)

    pre1940    <- small_weights * pre1940
    x1941_1970 <- small_weights * x1941_1970
    x1971_1990 <- small_weights * x1971_1990
    post1991   <- small_weights * post1991
  }
  if (pedigree_size == "Large") {
    large_weights <- c(0.25, 0.5, 0.75, 0.75, 1.25, 1.75, 1.75)

    pre1940    <- large_weights * pre1940
    x1941_1970 <- large_weights * x1941_1970
    x1971_1990 <- large_weights * x1971_1990
    post1991   <- large_weights * post1991
  }

  # distributions knowing that there is at least one child
  pre1940_has_children    <- pre1940[2:7]/(1-pre1940[1])
  x1941_1970_has_children <- x1941_1970[2:7]/(1-x1941_1970[1])
  x1971_1990_has_children <- x1971_1990[2:7]/(1-x1971_1990[1])
  post1991_has_children   <- post1991[2:7]/(1-post1991[1])

  # calculate number of children based on birth year
  numchildren <- NA
  if(isFALSE(has_children)) {
    numchildren <- dplyr::case_when(motherBY <= 1940 ~ sample(0:6, 1, prob = pre1940),
                                    motherBY <= 1970 ~ sample(0:6, 1, prob = x1941_1970),
                                    motherBY <= 1990 ~ sample(0:6, 1, prob = x1971_1990),
                                    .default = sample(0:6, 1, prob = post1991))
  } else {
    numchildren <- dplyr::case_when(motherBY <= 1940 ~ sample(1:6, 1, prob = pre1940_has_children),
                                    motherBY <= 1970 ~ sample(1:6, 1, prob = x1941_1970_has_children),
                                    motherBY <= 1990 ~ sample(1:6, 1, prob = x1971_1990_has_children),
                                    .default = sample(1:6, 1, prob = post1991_has_children))
  }

  # stop and return if no children
  if(numchildren == 0) {
    return(data.frame(Age = numeric(),
                      Sex = character(),
                      Variant = character(),
                      Father = character()))
  }

  # oldest child's age based on mothers age
  ## minimum age of childbirth is 15 -- assumption
  ## Distributions of age at first birth -- Schweizer and Guzzo (2020)
  oldestChildAge <- dplyr::case_when(motherBY <= 1970 ~ mother_age - max(15, round(stats::rnorm(mean = 21, sd = sqrt(5), n = 1))),
                                     motherBY <= 1990 ~ mother_age - max(15, round(stats::rnorm(mean = 24, sd = sqrt(7), n = 1))),
                                     .default = mother_age - max(15, round(stats::rnorm(mean = 26, sd = sqrt(8.5), n = 1))))
  if(isTRUE(has_children)) oldestChildAge <- max(oldestChildAge, known_child_age)

  # determine if all children with same father
  ## 19% of women with children have children with more than one partner - Guzzo (2014)
  allSameFather_prob <- dplyr::case_when(motherBY <= 1940 ~ 0.19/(1-pre1940[1]),
                                         motherBY <= 1970 ~ 0.19/(1-x1941_1970[1]),
                                         motherBY <= 1990 ~ 0.19/(1-x1971_1990[1]),
                                         .default = 0.19/(1-post1991[1]))
  allSameFather <- sample(c(TRUE, FALSE), size = 1,
                          prob = c(allSameFather_prob, 1-allSameFather_prob))

  # determine fathers for each child
  breakpoint <- NA
  fathers    <- rep("Father1", numchildren)
  if(isFALSE(allSameFather)) {
    breakpoint <- sample(1:(numchildren - 1), size = 1)
    fathers    <- c(rep("Father1", breakpoint),
                    rep("Father2", numchildren-breakpoint))
  }

  # age of subsequent children via years between births
  ## Schwartz, Doren, and Li (2020)
  ageGaps <- NA
  ageGaps_mean <- dplyr::case_when(motherBY <= 1940 ~ 3.25,
                                   motherBY <= 1970 ~ 4.25,
                                   .default = 4.75)
  ageGaps <- round(stats::rnorm(mean = ageGaps_mean, sd = 1.5, n = numchildren - 1))

  # for multiple fathers, lengthen age gap between fathers
  if(isFALSE(allSameFather)) {
    ageGaps[breakpoint] <- dplyr::case_when(motherBY <= 1940 ~ round(stats::rnorm(mean = 5.25, sd = 1.5, n = 1)),
                                            motherBY <= 1970 ~ round(stats::rnorm(mean = 6.25, sd = 1.5, n = 1)),
                                            .default = round(stats::rnorm(mean = 6.75, sd = 1.5, n = 1)))
  }

  # if any gaps less than 1, set to 1
  if(numchildren >= 2) {
    for(i in 1:length(ageGaps)) {
      if(ageGaps[i] < 1) ageGaps[i] <- 1
    }
  }

  # to return... data frame where each row is one child
  children <- data.frame(Age = oldestChildAge,
                         Sex = sample(c("M", "F"),
                                      replace = TRUE,
                                      size = numchildren),
                         Variant = sample(c("No Variant", variant),
                                          replace = TRUE,
                                          size = numchildren),
                         Father = fathers)
  # apply age gaps
  if(numchildren >= 2) {
    for (i in 2:nrow(children)) {
      children$Age[i] <- children$Age[i-1] - ageGaps[i-1]
    }
  }

  # to return
  children
}

# Helper function to generate children from fathers age
## used only for children who are terminal in the tree
## @return - dataframe of children
.GenerateChildrenFromFather <- function(father_age,
                                       pedigree_size,
                                       variant,
                                       current_year) {
  # fix data types
  father_age <- as.numeric(father_age)

  # parameter check
  if (!is.numeric(father_age)) {
    if (!is.na(father_age)) stop("father_age must be a numeric or NA")
  }

  # father birth year
  fatherBY <- current_year - father_age

  # number of children distribution based on fathers age
  ## SIPP census data -- Monte and Knop (2019)
  pre1970 <- c(0.243, 0.161, 0.32, 0.166, 0.067, 0.03, 0.013)

  # apply weights based on pedigree size
  if(pedigree_size == "Small") {
    pre1970 <- pre1970 * c(1.75, 1.75, 1.25, 0.75, 0.75, 0.5, 0.25)
  }
  if (pedigree_size == "Large") {
    pre1970 <- pre1970 * c(0.25, 0.5, 0.75, 0.75, 1.25, 1.75, 1.75)
  }

  # calculate number of children based on birth year
  numchildren <- sample(0:6, 1, prob = pre1970)

  # stop and return if no children
  if(numchildren == 0) {
    return(data.frame(Age = numeric(),
                      Sex = character(),
                      Variant = character(),
                      Father = character()))
  }

  # oldest child's age based on fathers age
  ## minimum age of childbirth is 14 -- assumption
  ## distributions of age at first birth -- Schweizer (2019)
  oldestChildAge <- dplyr::case_when(fatherBY <= 1940 ~ father_age - max(14, round(stats::rnorm(mean = 25.3, sd = sqrt(5), n = 1))),
                                     fatherBY <= 1960 ~ father_age - max(14, round(stats::rnorm(mean = 26, sd = sqrt(7), n = 1))),
                                     fatherBY <= 1980 ~ father_age - max(14, round(stats::rnorm(mean = 26.7, sd = sqrt(9), n = 1))),
                                     .default = father_age - max(14, round(stats::rnorm(mean = 27.5, sd = sqrt(12), n = 1))))

  # age of subsequent children via years between births
  ## Schwartz, Doren, and Li (2020)
  ageGaps <- NA
  ageGaps_mean <- dplyr::case_when(fatherBY <= 1940 ~ 3.25,
                                   fatherBY <= 1970 ~ 4.25,
                                   .default = 4.75)
  ageGaps <- round(stats::rnorm(mean = ageGaps_mean, sd = 1.5, n = numchildren - 1))

  # determine if all children with same mother
  ## 13% of men with children have children with more than one partner - Guzzo (2014)
  allSameMother_prob <- 0.13/(1-pre1970[1])
  allSameMother <- sample(c(TRUE, FALSE), size = 1,
                          prob = c(allSameMother_prob, 1-allSameMother_prob))

  # determine fathers for each child
  breakpoint <- NA
  mothers    <- rep("Mother1", numchildren)
  if(isFALSE(allSameMother)) {
    breakpoint <- sample(1:(numchildren - 1), size = 1)
    mothers    <- c(rep("Mother1", breakpoint),
                    rep("Mother2", numchildren-breakpoint))
  }

  # for multiple mothers, lengthen age gap between fathers
  if(isFALSE(allSameMother)) {
    ageGaps[breakpoint] <- dplyr::case_when(fatherBY <= 1940 ~ round(stats::rnorm(mean = 5.25, sd = 1.5, n = 1)),
                                            fatherBY <= 1970 ~ round(stats::rnorm(mean = 6.25, sd = 1.5, n = 1)),
                                            .default = round(stats::rnorm(mean = 6.75, sd = 1.5, n = 1)))
  }

  # if any gaps less than 1, set to 1
  if(numchildren >= 2) {
    for(i in 1:length(ageGaps)) {
      if(ageGaps[i] < 1) ageGaps[i] <- 1
    }
  }

  # to return... data frame where each row is one child
  children <- data.frame(Age = oldestChildAge,
                         Sex = sample(c("M", "F"),
                                      replace = TRUE,
                                      size = numchildren),
                         Variant = sample(c("No Variant", variant),
                                          replace = TRUE,
                                          size = numchildren),
                         Father = mothers)
  # apply age gaps
  if(numchildren >= 2) {
    for (i in 2:nrow(children)) {
      children$Age[i] <- children$Age[i-1] - ageGaps[i-1]
    }
  }

  # to return...
  children
}
