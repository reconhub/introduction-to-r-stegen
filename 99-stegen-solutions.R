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

#' ## Initial summaries
#'
#' Here, we inspect the data to determine what needs cleaning
#'
dim(stegen)
names(stegen)
summary(stegen)

#' ## Data Cleaning
#'
#' Here we need to do a few things
#'
#' 1. standardize labels
#' 2. recode sex and illness
#' 3. recods date of onset as date
#' 4. mark 9 as NA for binary variables
#'
#' ### Cleaning labels
#'
new_labels <- clean_labels(names(stegen)) # generate standardised labels
new_labels # check the result
names(stegen) <- new_labels
#' ### Recoding data
#'
stegen$unique_key <- as.character(stegen$unique_key)
stegen$sex <- factor(stegen$sex)
stegen$ill <- factor(stegen$ill)
stegen$date_onset <- as.Date(stegen$date_onset)
stegen$sex <- recode_factor(stegen$sex, "0" = "male", "1" = "female")
stegen$ill <- recode_factor(stegen$ill, "0" = "non case", "1" = "case")
#' ### Fixing missing data
#'
stegen$pork[stegen$pork == 9] <- NA
stegen$salmon[stegen$salmon == 9] <- NA
stegen$horseradish[stegen$horseradish == 9] <- NA
#' ### Saving clean data
#'
clean_dir <- here("data", "cleaned")
dir.create(clean_dir)

# as a csv
stegen_clean_file <- here("data", "cleaned", "stegen_clean.csv")
write.csv(stegen, file = stegen_clean_file, row.names = FALSE)

# as a binary file 
stegen_clean_rds <- here("data", "cleaned", "stegen_clean.rds")
saveRDS(stegen, file = stegen_clean_rds)

#' ## Data Exploration
#'
#' Now we can explore the data
#'
summary(stegen$age) # age stats
summary(stegen$sex) # gender distribution
tapply(stegen$age, INDEX = stegen$sex, FUN = summary) # age stats by gender     
#' 
#' ### Plotting distribution by age
#'
ggplot(stegen) + geom_histogram(aes(x = age, fill = sex), binwidth = 1)
#'
#' ## Epidemic incidence
#' 
i_ill <- incidence(stegen$date_onset, group = stegen$ill)
i_ill
plot(i_ill, show_cases = TRUE, color = c("non case" = "#66cc99", "case" = "#990033"))

#' ### Age and gender by illness

ggplot(stegen) +
  geom_histogram(aes(x = age, fill = ill), binwidth = 1) +
  scale_fill_manual("Illness", values = c("non case" = "#66cc99", "case" = "#990033")) +
  facet_grid(sex ~ .) +
  labs(title = "Cases by age and gender") +
  theme_light()

#' # Statistical tests
#'
#' We want to run a risk ratio test for each variable. Here, we define our risk
#' ratio function:
single_risk_ratio <- function(predictor, outcome) { # ingredients defined here
  et  <- epitools::epitable(predictor, outcome) # ingredients used here
  rr  <- epitools::riskratio(et)
  estimate <- rr$measure[2, ]
  res <- data.frame(estimate = estimate["estimate"],
                    lower    = estimate["lower"],
                    upper    = estimate["upper"],
                    p.value  = rr$p.value[2, "fisher.exact"]
                   )
  return(res) # return the data frame
}

#' Now that we have the function, we can extract our predictors
#'
to_keep <- c('tiramisu', 'wmousse', 'dmousse', 'mousse', 'beer', 'redjelly',
             'fruit_salad', 'tomato', 'mince', 'salmon', 'horseradish',
             'chickenwin', 'roastbeef', 'pork')
to_keep
food <- stegen[to_keep]
food

#' ### Calculating risk ratios
#'
all_rr <- lapply(food, FUN = single_risk_ratio, outcome = stegen$ill)
all_food_df <- bind_rows(all_rr, .id = "predictor")
all_food_df <- arrange(all_food_df, desc(estimate))
# first, make sure the predictors are factored in the right order
all_food_df$predictor <- factor(all_food_df$predictor, unique(all_food_df$predictor))
# plot
p <- ggplot(all_food_df, aes(x = estimate, y = predictor, color = p.value)) +
  geom_point() +
  geom_errorbarh(aes(xmin = lower, xmax = upper)) +
  geom_vline(xintercept = 1, linetype = 2) +
  scale_x_log10() +
  scale_color_viridis_c() +
  labs(x = "Risk Ratio (log scale)",
       y = "Predictor",
       title = "Risk Ratio for gastroenteritis in Stegen, Germany")
p

#' # Mapping
#'
#' A very basic outline of the data

ggplot(stegen) +
  geom_point(aes(x = longitude, y = latitude, color = ill)) +
  coord_map()

#' ## With shapefiles
#'
stegen_shp <- read_sf(here("data", "stegen-map", "stegen_households.shp"))
ggplot(stegen) +
  geom_sf(data = stegen_shp) +
  geom_point(aes(x = longitude, y = latitude, color = ill))

#' ## Interactive map
#'
#'
stegen_sub <- stegen[!is.na(stegen$longitude), ]
# create the map
lmap <- leaflet()
# add open street map tiles
lmap <- addTiles(lmap)
# set the coordinates for Stegen
lmap <- setView(lmap, lng = 7.963, lat = 47.982, zoom = 15)
# Add the shapefile
lmap <- addPolygons(lmap, data = st_transform(stegen_shp, '+proj=longlat +ellps=GRS80'))
# Add the cases
lmap <- addMarkers(lmap, label = ~ill, data = stegen_sub)
# show the map
lmap
