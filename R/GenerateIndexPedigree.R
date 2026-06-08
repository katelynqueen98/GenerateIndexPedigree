#' GenerateIndexPedigree
#'
#' @description Function to simulate pedigree of index case to first cousins and back to grandparents; Genetic mutation of index is permeated through pedigree, and if the family members are told about mutation and if they uptake genetic testing is tracked
#'
#' @param age numeric, age of index case
#' @param sex character, index case sex; either "M" or "F"
#' @param keep_future_children logical, whether to keep (TRUE) or remove (FALSE) children not yet born; default is TRUE
#' @param variant character, name of variant; default is "None" for unaffected index
#' @param denovo_rate numeric, between 0 and 1; rate of denovo mutation in given variant; default is 1/500000 or 2x10^(-6)
#' @param is_denovo logical, index mutation is de novo (TRUE) or inherited (FALSE); NA indicates denovo status is unknown and will be simulated; default is NA
#' @param tell_family_prob numeric, between 0 and 1; probability that an index case tells their family about their mutation; default is 0.70
#' @param tell_children_prob numeric, between 0 and 1; probability that an index case tells their children about their mutation, assumed this is <= tell_family_prob; default is 0.80
#' @param uptake_test_prob numeric, between 0 and 1; probability that a family member who is told about index mutation will get a genetic test; default is 0.45
#' @param verbose logical, whether to print messages during function; default is FALSE
#'
#' @return a data frame representing the family, where each row represents a person and columns represent attributes:
#'
#' \describe{
#' \item{Age}{numeric, person age}
#' \item{Sex}{character, person sex; either "M" or "F"}
#' \item{RelationshipToIndex}{character, person's relationship to index}
#' \item{ChildOf}{character, which family member person is child of; NA for grandparents}
#' \item{DeNovo}{logical, NA/True whether mutation is de novo; only possible to be true for index and parent}
#' \item{Variant}{character, person's variant status; either NA or same as parameter}
#' \item{Told}{character, Yes/No, whether person was informed of index case}
#' \item{UptakeTesting}{character, Yes/No, on whether person chose to receive genetic health screening}
#' }
#'
#' @examples
#' GenerateIndexPedigree(age = 35, variant = "BRCA1", sex = "M", is_denovo = NA)
#'
#' @details
#' This function simulates pedigrees of individuals with a genetic mutation of interest, tracking family structure, variant permeation, and uptake of genetic testing. Family sizes are based on appropriate US census data, and due to correlation between number of children within pedigrees, this starts with assigning overall pedigree size to small, average, or large.
#'
#' Children for each adult are generated using the SimulateChildren function.
#'
#' @references
#' Schweizer and Guzzo. Distributions of Age at First Birth, 1960-2018 (2020); https://www.bgsu.edu/ncfmr/resources/data/family-profiles/schweizer-guzzo-distribution-age-first-birth-fp-20-11.html
#'
#' Khandwala, Zhang, Lu, and Eisenberg. The age of fathers in the USA is rising: an analysis of 168 867 480 births from 1972 to 2015, Human Reproduction, Volume 32, Issue 10, October 2017, Pages 2110–2116, https://doi.org/10.1093/humrep/dex267
#'
#' @author Katelyn Queen \email{kqueen@@mednet.ucla.edu}
#'
#' @export
GenerateIndexPedigree <- function(age,
                                  sex,
                                  keep_future_children = TRUE,
                                  variant = "None",
                                  denovo_rate = 2e-06,
                                  is_denovo = NA,
                                  tell_family_prob = 0.70,
                                  tell_children_prob = 0.80,
                                  uptake_test_prob = 0.45,
                                  verbose = FALSE) {

  # check parameter inputs
  if (is.na(age) | !is.numeric(age)) stop("age must be numeric")
  if (!(sex %in% c("M", "F"))) stop("sex must be either M or F")
  if (!(isTRUE(keep_future_children) | isFALSE(keep_future_children))) {
    stop("keep_future_children must be either TRUE or FALSE")
  }
  if (!is.character(variant)) {
    stop("variant is not an acceptable input; should be a character")
  }
  if (is.na(denovo_rate) | !is.numeric(denovo_rate) | denovo_rate < 0 | denovo_rate > 1) {
    stop("denovo_rate must be a numeric between 0 and 1")
  }
  if (!is.logical(is_denovo)) {
    stop("is_denovo is not an acceptable input; should be NA or a logical")
  }
  if (is.na(tell_family_prob) | !is.numeric(tell_family_prob) | tell_family_prob < 0 | tell_family_prob > 1) {
    stop("tell_family_prob must be a numeric between 0 and 1")
  }
  if (is.na(tell_children_prob) | !is.numeric(tell_children_prob) | tell_children_prob < 0 | tell_children_prob > 1) {
    stop("tell_children_prob must be a numeric between 0 and 1")
  }
  if (is.na(uptake_test_prob) | !is.numeric(uptake_test_prob) | uptake_test_prob < 0 | uptake_test_prob > 1) {
    stop("tell_family_prob must be a numeric between 0 and 1")
  }
  if (!is.logical(verbose)) stop("verbose is not a logical")

  # if variant = NA, change to "None" to avoid errors
  if (is.na(variant)) variant <- "None"

  # message if unaffected index
  if(variant == "None" & verbose) {
    message("No variant of index reported. GeneratePedigree can be used to simulate pedigrees without variant information.")
  }

  # generate pedigree size of index
  pedSize <- sample(c("Small", "Average", "Large"), size = 1,
                    prob = c(0.25, 0.5, 0.25))

  ### children
  family <- SimulateChildren(mother_age = age,
                             father_age = ifelse(sex == "M", age, NA),
                             pedigree_size = pedSize,
                             variant = variant)
  if(nrow(family) != 0)  {
    family         <- .NumberRelatives(family, "Child")
    family$ChildOf <- "Index"
    family$DeNovo  <- NA
  }

  # add index case to family
  if(nrow(family) != 0) {
    family <- rbind(family, c(age, sex, variant, NA, "Self", "Parents", NA))
  } else {
    family <- data.frame(Age = age,
                         Sex = sex,
                         Variant = variant,
                         Father = NA,
                         RelationshipToIndex = "Self",
                         ChildOf = "Parents",
                         DeNovo = is_denovo)
  }

  ### parents
  # generate mother -- Schweizer and Guzzo (2020)
  mother <- c(age + max(15, round(stats::rnorm(mean = 22, sd = sqrt(6), n = 1))), # age
              "F",                                                         # sex
              sample(c("No Variant", variant), 1),                         # variant status
              NA,                                                          # father
              "Mother",                                                    # relationship to index
              "MaternalGrandparents",                                      # child of
              NA)                                                          # de novo
  family <- rbind(family, mother)

  # generate father with inverse variant status to mother
  ## fathers age at child's birth -- Khandwala et al, Human Reproduction (2017)
  father <- c(age + max(14, round(stats::rnorm(mean = 28, sd = sqrt(8), n = 1))),
              "M",
              ifelse(mother[3] == variant, "No Variant", variant),
              NA,
              "Father",
              "PaternalGrandparents",
              NA)
  family <- rbind(family, father)

  ### siblings
  sibs <- SimulateChildren(mother_age = family$Age[which(family$RelationshipToIndex == "Mother")],
                           father_age = NA,
                           pedigree_size = pedSize,
                           variant = variant,
                           has_children = TRUE,
                           known_child_age = age)

  # if siblings...
  if(nrow(sibs) != 0) {
    # relationships
    sibs$ChildOf             <- "Parents"
    sibs$RelationshipToIndex <- "Brother"
    sibs$RelationshipToIndex[which(sibs$Sex == "F")] <- "Sister"

    # de novo
    sibs$DeNovo <- NA

    # remove index row
    sibs <- .RemoveSelf(self_age = age,
                       children = sibs)

    # if siblings
    if(nrow(sibs) != 0) {
      sibs <- .NumberRelatives(sibs, NA)

      # add to family
      family <- rbind(family, sibs)
    }
  }

  ### nieces/nephews
  family <- .GenerateMultipleFamilies(adults = sibs,
                                      family = family,
                                      pedSize = pedSize,
                                      male_RTI = "Nephew",
                                      female_RTI = "Niece")

  ### maternal side
  family <- .GenerateParentalSide(family = family,
                                  parent = "Mother",
                                  variant = variant,
                                  pedSize = pedSize)

  ### paternal side
  family <- .GenerateParentalSide(family = family,
                                  parent = "Father",
                                  variant = variant,
                                  pedSize = pedSize)

  # remove Father column
  family$Father <- NULL

  # does index tell family?
  tell_prob    <- stats::runif(1)
  family$Told  <- "No"
  family$UptakeTesting <- "No"
  if(tell_prob < tell_family_prob) {
    family$Told <- "Yes"
    family$UptakeTesting <- sample(c("Yes", "No"), replace = TRUE,
                                   prob = c(uptake_test_prob, 1 - uptake_test_prob),
                                   size = nrow(family))
  }

  # does index tell child?
  if(tell_prob < tell_children_prob) {
    family$Told[which(grepl("Child", family$RelationshipToIndex))] <- "Yes"
    family$UptakeTesting[which(grepl("Child", family$RelationshipToIndex))] <- sample(c("Yes", "No"),
                                                                                      replace = TRUE,
                                                                                      prob = c(uptake_test_prob, 1 - uptake_test_prob),
                                                                                      size = sum(grepl("Child", family$RelationshipToIndex)))
  }

  # is de novo status known?
  family$DeNovo <- as.logical(family$DeNovo)
  if(is.na(is_denovo)) {
    # if unknown, check against de novo rate
    is_denovo <- ifelse(stats::runif(1) < denovo_rate, TRUE, FALSE)
  }

  # if index is de novo...
  if (is_denovo) {
    # update all previous family members to no variant
    if(verbose == TRUE) message("Index case had a de novo mutation. All cascade tests of previous generations are negative.")
    family$Variant[which(!grepl("Child", family$RelationshipToIndex))] <- "No Variant"
    family$Variant[which(family$RelationshipToIndex == "Self")] <- variant

    # notate de novo mutation
    family$DeNovo[which(family$RelationshipToIndex == "Self")] <- TRUE
  } else {
    # notate lack of de novo mutation
    family$DeNovo[which(family$RelationshipToIndex == "Self")] <- FALSE
  }

  # if parent's mutation is de novo...
  if (isFALSE(is_denovo) & stats::runif(1) < denovo_rate) {
    # update all previous family members to no variant
    if (verbose == TRUE) message("Parent case was a de novo mutation. All cascade tests of previous generations are negative.")
    family$Variant[which(grepl("Aunt|Uncle|Cousin|Grandfather|Grandmother",
                               family$RelationshipToIndex))] <- "No Variant"

    # notate de novo mutation
    family$DeNovo[which(family$RelationshipToIndex %in% c("Mother", "Father") &
                          family$Variant == variant)] <- TRUE
  } else {
    # notate lack of de novo mutation
    family$DeNovo[which(family$RelationshipToIndex %in% c("Mother", "Father") &
                          family$Variant == variant)] <- FALSE
  }

  # if grandparent's mutation is de novo...
  if (sum(family$DeNovo, na.rm = TRUE) == 0 & stats::runif(1) < denovo_rate) {
    # notate de novo mutation
    if (verbose == TRUE) message("Grandparent case was a de novo mutation.")
    family$DeNovo[which(grepl("Grandfather|Grandmother", family$RelationshipToIndex) &
                          family$Variant == variant)] <- TRUE
  } else {
    # notate lack of de novo mutation
    family$DeNovo[which(grepl("Grandfather|Grandmother", family$RelationshipToIndex) &
                          family$Variant == variant)] <- FALSE
  }

  # fix rownames
  rownames(family) <- c(1:nrow(family))

  # index row is always told and always uptakes testing
  family$Told[which(family$RelationshipToIndex == "Self")] <- "Yes"
  family$UptakeTesting[which(family$RelationshipToIndex == "Self")] <- "Yes"

  # remove children not born yet based on user choice
  if (isFALSE(keep_future_children)) {
    family <- family[which(family$Age >= 0), ]
  }

  # to return...
  family
}

# Helper function to generate children for each adult in a data frame
## @param adults dataframe where each row represent an adult to generate children for
## @param family family dataframe from main function
## @param pedSize character representing pedigree size
## @param male_RTI character, name of relationship to index for a generated male
## @param female_RTI character, name of relationship to index for a generated female
## @return - full family dataframe after adding all generated children
.GenerateMultipleFamilies <- function(adults,
                                      family,
                                      pedSize,
                                      male_RTI,
                                      female_RTI) {
  # if adults to generate from
  if(nrow(adults) != 0) {
    for (i in 1:nrow(adults)) {
      # generate kids from adult
      kids <- SimulateChildren(mother_age = adults$Age[i],
                               father_age = ifelse(adults$Sex[i] == "M",
                                                   adults$Age[i],
                                                   NA),
                               pedigree_size = pedSize,
                               variant = adults$Variant[i])
      if(nrow(kids) != 0) {
        # relationships
        kids$RelationshipToIndex <- male_RTI
        kids$RelationshipToIndex[which(kids$Sex == "F")] <- female_RTI
        kids$ChildOf <- adults$RelationshipToIndex[i]

        # de novo
        kids$DeNovo <- NA

        # number
        kids <- .NumberRelatives(kids, NA)

        # add to family
        family <- rbind(family, kids)
      }
    }
  }

  # to return...
  family
}

# Helper function to generate full tree side for mom or dad
## @param family family dataframe from main function
## @param parent "Mother" or "Father"
## @param variant index variant
## @param pedSize character representing pedigree size
## @return full family dataframe after adding all generated family members
.GenerateParentalSide <- function(family,
                                  parent,
                                  variant,
                                  pedSize) {
  ### grandparents
  # is variant on parent's side?
  grand_variants <- c("No Variant", "No Variant")
  if(family$Variant[which(family$RelationshipToIndex == parent)] == variant) {
    grand_variants <- sample(c("No Variant", variant), size = 2, replace = FALSE)
  }

  # generate grandparents
  grandma <- c(as.numeric(family$Age[which(family$RelationshipToIndex == parent)]) +
                 max(15, round(stats::rnorm(mean = 21, sd = sqrt(6), n = 1))),
               "F",
               grand_variants[1],
               NA,
               ifelse(parent == "Mother", "MaternalGrandmother", "PaternalGrandmother"),
               ifelse(parent == "Mother", "MaternalGreatGrandparents", "PaternalGreatGrandparents"),
               NA)
  grandpa <- c(as.numeric(family$Age[which(family$RelationshipToIndex == parent)]) +
                 max(14, round(stats::rnorm(mean = 26, sd = sqrt(8), n = 1))),
               "M",
               grand_variants[2],
               NA,
               ifelse(parent == "Mother", "MaternalGrandfather", "PaternalGrandfather"),
               ifelse(parent == "Mother", "MaternalGreatGrandparents", "PaternalGreatGrandparents"),
               NA)
  family <- rbind(family, grandma, grandpa)

  ### aunts/uncles
  auncles <- SimulateChildren(mother_age = grandma[1],
                              father_age = NA,
                              pedigree_size = pedSize,
                              variant = ifelse(sum(grepl(variant, grand_variants)) == 0,
                                               "No Variant",
                                               variant),
                              has_children = TRUE,
                              known_child_age = family$Age[which(family$RelationshipToIndex == parent)])

  # remove parent
  auncles <- .RemoveSelf(self_age = family$Age[which(family$RelationshipToIndex == parent)],
                        children = auncles)

  if(nrow(auncles) != 0) {
    # relationships
    auncles$RelationshipToIndex <- ifelse(parent == "Mother",
                                          "MaternalUncle",
                                          "PaternalUncle")
    auncles$RelationshipToIndex[which(auncles$Sex == "F")] <- ifelse(parent == "Mother",
                                                                     "MaternalAunt",
                                                                     "PaternalAunt")
    auncles$ChildOf <- ifelse(parent == "Mother",
                              "MaternalGrandparents",
                              "PaternalGrandparents")

    # de novo
    auncles$DeNovo <- NA

    # number
    auncles <- .NumberRelatives(auncles, NA)

    # add to family
    family <- rbind(family, auncles)
  }

  ### cousins
  cousin_RTI <- ifelse(parent == "Mother",
                       "MaternalCousin",
                       "PaternalCousin")
  family <- .GenerateMultipleFamilies(adults = auncles,
                                     family = family,
                                     pedSize = pedSize,
                                     male_RTI = cousin_RTI,
                                     female_RTI = cousin_RTI)

  # to return...
  family
}

# Helper function for removing known child from data frame
.RemoveSelf <- function(self_age,
                        children) {

  # ensure age is numeric
  self_age <- as.numeric(self_age)

  # identify which row is known child
  self <- as.numeric(rownames(children)[which.min(abs(children$Age - self_age))])

  # remove self row
  children <- children[-c(self), ]

  # to return
  children
}

# Helper function to number relatives to track lineage
.NumberRelatives <- function(relatives,
                             relationship_name) {
  # number relatives...
  for(i in 1:nrow(relatives)) {
    # using names already in data frame
    if(is.na(relationship_name)) {
      relatives$RelationshipToIndex[i] <- paste0(relatives$RelationshipToIndex[i],
                                                 "_", i)
    } else {
      # using names passed to function
      relatives$RelationshipToIndex[i] <- paste0(relationship_name, "_", i)
    }
  }

  # to return...
  relatives
}
