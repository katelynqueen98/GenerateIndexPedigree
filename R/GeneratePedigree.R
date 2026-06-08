#' GeneratePedigree
#'
#' @description Function to simulate pedigree of given individual to first cousins and back to grandparents
#'
#' @param age numeric, age of index case
#' @param sex character, patient sex; either "M" or "F"
#' @param keep_future_children logical, whether to keep (TRUE) or remove (FALSE) children not yet born; default is TRUE
#'
#' @return a data frame representing the family, where each row represents a person and columns represent attributes:
#'
#' \describe{
#' \item{Age}{numeric, person age}
#' \item{Sex}{character, person sex; either "M" or "F"}
#' \item{RelationshipToIndex}{character, person's relationship to index}
#' \item{ChildOf}{character, which family member person is child of; NA for grandparents}
#' }
#'
#' @examples
#' GeneratePedigree(age = 35, sex = "M")
#'
#' @details
#' This function simulates pedigrees of individuals given age and sex. Family sizes are based on appropriate US census data, and due to correlation between number of children within pedigrees, this starts with assigning overall pedigree size to small, average, or large.
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
GeneratePedigree <- function(age,
                             sex,
                             keep_future_children = TRUE) {

  # check parameter inputs
  if (is.na(age) | !is.numeric(age)) stop("age must be numeric")
  if (!(sex %in% c("M", "F"))) stop("sex must be either M or F")
  if (!(isTRUE(keep_future_children) | isFALSE(keep_future_children))) {
    stop("keep_future_children must be either TRUE or FALSE")
  }

  # use given parameters to call GenerateIndexPedigree
  family <- GenerateIndexPedigree(age = age,
                                  sex = sex,
                                  keep_future_children = keep_future_children,
                                  variant = "None")

  # remove columns related to variants
  family$DeNovo <- NULL
  family$Variant <- NULL
  family$Told <- NULL
  family$UptakeTesting <- NULL

  # to return...
  family
}
