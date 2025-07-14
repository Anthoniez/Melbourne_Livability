install.packages(c("sf", "tmap", "ggplot2", "dplyr", "readr", "tidyr", "spdep", "leaflet", "ggmap"))
install.packages("readxl")

# Load libraries
library(sf)
library(dplyr)
library(ggplot2)
library(tmap)
library(readr)
library(readxl)
library(stringr)

# Load Melbourne suburb boundaries (replace path with yours)
suburbs <- st_read("/Users/mariaanthoniez/Documents/MelbourneLivability/data/victoria/GDA94/vic_lga.shp")  

# Check structure
plot(st_geometry(suburbs))


# Load Crownlands and Parks in Victoria
parks <- st_read("/Users/mariaanthoniez/Documents/MelbourneLivability/data/victoria/CROWNLAND/PARKRES.shp")

# Make sure it's in the same CRS as suburbs
parks <- st_transform(parks, crs = st_crs(suburbs))

# Intersect parks with suburbs
parks_in_suburbs <- st_intersection(parks, suburbs)

# Calculate area (in square meters)
parks_in_suburbs$area_m2 <- st_area(parks_in_suburbs)

# Sum park area per suburb
green_area_summary <- parks_in_suburbs %>%
  group_by(ABB_NAME) %>%
  summarise(total_green_m2 = sum(area_m2))

# Merge with suburbs
# Drop geometry to make it a regular data frame
green_area_summary_df <- st_drop_geometry(green_area_summary)

# Now join safely
suburbs <- suburbs %>%
  left_join(green_area_summary_df, by = "ABB_NAME") %>%
  mutate(total_green_m2 = ifelse(is.na(total_green_m2), 0, total_green_m2))

#Visualize Green Space per Suburb
tmap_mode("view")  # Interactive map
tm_shape(suburbs) +
  tm_polygons("total_green_m2", 
              palette = "Greens", 
              title = "Green Space (m²)",
              style = "quantile")

#Visualize Green Space per Suburb as a static plot
tmap_mode("plot")
tm_shape(suburbs) +
  tm_polygons("total_green_m2", palette = "Greens", title = "Green Space (m²)")



# ----------------------------------------
# Step 1: Read the Schools CSV
# ----------------------------------------
schools_df <- read_csv("/Users/mariaanthoniez/Documents/MelbourneLivability/data/victoria/SCHOOLS/schoolLocations2021.csv")

# ----------------------------------------
# Step 2: Convert the CSV to an sf (spatial) object
# Using 'X' as longitude and 'Y' as latitude
# ----------------------------------------
schools <- st_as_sf(schools_df, coords = c("X", "Y"), crs = 4326)  # WGS84

# ----------------------------------------
# Step 3: Transform CRS to match the suburbs layer
# This ensures spatial operations work correctly
# ----------------------------------------
schools <- st_transform(schools, st_crs(suburbs))

# ----------------------------------------
# Step 4: Spatially join each school to the suburb it falls within
# Using st_within() so each school is matched to a suburb polygon
# ----------------------------------------
schools_in_suburbs <- st_join(schools, suburbs, join = st_within)

# ----------------------------------------
# Step 5: Count the number of schools per suburb
# Group by LGA_NAME (which contains suburb names)
# ----------------------------------------
school_counts <- schools_in_suburbs %>%
  count(ABB_NAME)

# ----------------------------------------
# Step 6: Merge the school counts back into the suburb spatial object
# Rename the count column and fill NAs with 0 (suburbs with no schools)
# Drop geometry from school_counts before joining
school_counts_df <- st_drop_geometry(school_counts)

# Join and clean up
suburbs <- suburbs %>%
  left_join(school_counts_df, by = "ABB_NAME") %>%
  rename(school_count = n) %>%
  mutate(school_count = ifelse(is.na(school_count), 0, school_count))
# ----------------------------------------
# Step 7: (Optional) Visualize using an interactive map
# View how many schools each suburb has
# ----------------------------------------
tmap_mode("view")
tm_shape(suburbs) +
  tm_polygons("school_count", 
              palette = "Blues", 
              title = "Schools per Suburb")






# Adjust the file path as needed
crime_data <- read_csv("/Users/mariaanthoniez/Documents/MelbourneLivability/data/victoria/CRIME/LGA_Criminal_Incidents.csv")

# View the column names
names(crime_data)

# Group by suburb and calculate total incidents
crime_summary <- crime_data %>%
  group_by(Suburb) %>%
  summarise(total_crimes = sum(`Incidents Recorded`, na.rm = TRUE))


# Check if the suburb name fields match
head(crime_summary$Suburb)
head(suburbs$ABB_NAME)



# Clean and standardize LGA names
suburbs <- suburbs %>%
  mutate(ABB_NAME_CLEAN = str_to_upper(str_trim(ABB_NAME)))

crime_summary <- crime_summary %>%
  mutate(Suburb_CLEAN = str_to_upper(str_trim(Suburb)))

# Now join using the cleaned versions
suburbs <- suburbs %>%
  left_join(crime_summary, by = c("ABB_NAME_CLEAN" = "Suburb_CLEAN")) %>%
  mutate(total_crimes = ifelse(is.na(total_crimes), 0, total_crimes))


tmap_mode("view")
tm_shape(suburbs) +
  tm_polygons("total_crimes", palette = "Reds", title = "Total Crimes per LGA")



# Normalize each component (0–1 scale)
suburbs <- suburbs %>%
  mutate(
    green_norm = scale(as.numeric(total_green_m2), center = FALSE),
    school_norm = scale(school_count, center = FALSE),
    crime_norm = scale(-total_crimes, center = FALSE)  # Lower crime is better
  ) %>%
  mutate(
    livability_score = green_norm + school_norm + crime_norm
  )


tmap_mode("view")
tm_shape(suburbs) +
  tm_polygons("livability_score", 
              palette = "YlGnBu", 
              title = "Livability Score")


top_suburbs <- suburbs %>%
  arrange(desc(livability_score)) %>%
  select(ABB_NAME, livability_score) %>%
  st_drop_geometry() %>%
  head(10)
print(top_suburbs)


tmap_mode("plot")
tm_shape(suburbs) +
  tm_polygons("livability_score", palette = "YlGnBu", title = "Livability Score") +
  tm_layout(title = "Melbourne Suburb Livability Index")
