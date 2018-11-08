#' ---
#' title: 'Refresher for R'
#' author: Zhian N. Kamvar
#' date: 2018-11-08
#' ---
#' 
#' # Installing R and Rstudio
#' 
#' - Installing R: go here and follow the instructions <https://cloud.r-project.org/>
#' - Instaling RStudio: go here and follwo the instructions <https://www.rstudio.com/products/rstudio/download/#download>
#'
#' # Navigating RStudio
#'
#' ## Using R projects
#' 
#' Using R projects with RStudio makes sure that you always start in the right
#' folder. 
#'
#' # Entering commands into R

# R is a calculator

sqrt(3^2 + 4^2) # Pythagorean theorem a^2 + b^2 = c^2

# R can test for equality

5 == sqrt(3^2 + 4^2) # == means "is equal to"

# R can do several calculations at once

1:10
1:10 + 2

#' # Creating and changing variables (also known as objects)

my_numbers <- 1:10
my_numbers
my_numbers + 2
my_numbers <- "whee"
my_numbers

#' # Data types

logi <- c(TRUE, FALSE)
logi
int  <- 1:2L
int
num  <- c(1, pi)
num
char <- c("Zhian Namir", "Kamvar")
char

#' ## Data types can be coerced:

c(logi, int)
c(logi, int, num)
c(logi, int, num, char)

#' # Installing and using packages
#' 
#' Packages are an important part of the R ecosystem. There are more than 13,000
#' packages available for download from CRAN (Comprehensive R Archive Network).
#' You can install them on your system by using the function install.packages()

# install.packages("here")
# install.packages("readxl")

#' You need only do this once because these packages will be installed to a
#' special folder on your computer called your Library. You can see where on
#' your computer this is by typing

.libPaths()

#' To use a package, you can load it into your R session by typing library("packagename")

library("readxl") # load the package to read in excel data
library("here")   # load the package that tells R where our project is

#' # Importing data
#' 
#' It's very rare to type your data into R as is. Often, you will import data
#' that's been saved as a spreadsheet or database. These files can live anywhere
#' on your computer, but it's a good idea to keep then in a separate data folder
#' in your project, setting them to read-only. 
#'
#' To read in data, you have to tell R where the file you want to read in lives.
#' For this, you can use the function here() from the "here" package, which first
#' tells R where your PROJECT lives and then allows you to list the path to your
#' file.

stegen_raw <- here("data", "stegen_raw.xlsx")
stegen_raw

#' This is important because it works even if you decide to re-organise your
#' scripts. 
#'
#' ## Importing data from excel
#'
#' To import data from excel, we can use the read_excel() function from the
#' "readxl" package. 
 
stegen <- read_excel(stegen_raw)
stegen

#' The function read_excel() has more arguments and you can read all about them
#' by typing ?read_excel in your R console

#' ## Importing data from a flat file (csv)
#'
#' Excel is not going to be the best way to store your data because it is
#' notorious for "helping out" by converting random cells to dates or
#' even changing the dates based on the system you use. A flat text file called
#' CSV (comma separated values will allow ANY program to read it and save your
#' file for posterity

stegen_clean <- here("data", "cleaned", "stegen_clean.csv") 
stegen_clean
stegen <- read.csv(stegen_clean, stringsAsFactors = FALSE)
stegen

