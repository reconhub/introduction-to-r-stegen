#' # Report of stegen outbreak
#'
#' ## Loading Packages and data
#' 
#' loading all of the packages at the beginning
library("here")      # find data/script files
library("readxl")    # read xlsx files
library("incidence") # make epicurves
library("epitrix")   # clean labels and variables
library("dplyr")     # general data handling
library("ggplot2")   # advanced graphics
library("epitools")  # statistics for epi data
library("sf")        # shapefile handling
library("leaflet")   # interactive maps
#'
#' load the raw data from the `data/` directory:
path_to_data <- here("data", "stegen_raw.xlsx")
path_to_data
stegen <- read_excel(path_to_data)


