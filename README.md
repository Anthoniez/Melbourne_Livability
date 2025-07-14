# ️ Melbourne Suburb Livability Analysis

**Melbourne Livability** is a spatial data science project that maps and analyzes the livability of Melbourne suburbs based on multiple geographic and socioeconomic factors.

Using spatial datasets such as green space coverage, crime incidents, and school access, the project visualizes patterns and creates a foundation for computing a livability score.

---

##  Project Objective

The goal is to develop a **data-driven, map-based evaluation** of Melbourne suburbs to:

- Identify highly livable vs. underserved areas
- Uncover spatial disparities in crime, green space, and school access
- Build an extensible framework for livability scoring using R

This project supports applications in urban planning, real estate research, and community development.

---

## ️ Spatial Data Layers Used

| Layer                 | Source / Format | Description                                         |
|----------------------|------------------|-----------------------------------------------------|
| Suburb Boundaries     | `.shp` / `sf`     | Geographical boundaries of Melbourne suburbs        |
| Green Spaces          | `.shp` / `GeoJSON`| Parks and open spaces mapped to suburb polygons     |
| Crime Incidents       | `.numbers` / `.csv`| Local Government Area-level crime counts (2024)     |
| School Locations      | `.csv` / `sf`     | Geocoded school coordinates and suburb-level counts |

---

## ️ Visual Outputs

Visualizations include:

- Choropleth maps of green space % by suburb
- Crime heatmaps aggregated at suburb or LGA level
- School access mapping using centroid distance
- Composite "livability index" (optional/experimental)

>  Maps were created using `ggplot2`, `tmap`, and `sf`.

---

## ️ Tools & Packages

This project was developed in **R** with the following packages:

- `sf`, `sp` – for spatial vector data manipulation
- `tmap`, `ggplot2` – for thematic mapping and visualization
- `dplyr`, `tidyr` – for data wrangling
- `readr`, `readxl` – for file imports
- `classInt`, `RColorBrewer` – for map styling
- `leaflet` – (optional) for interactive maps

---

##  Example Code Snippets

### Read and plot suburb shapefile
```r

# Load Melbourne suburb boundaries (replace path with yours)
suburbs <- st_read("MelbourneLivability/data/victoria/GDA94/vic_lga.shp")  

# Check structure
plot(st_geometry(suburbs))


# Load Crownlands and Parks in Victoria
parks <- st_read("MelbourneLivability/data/victoria/CROWNLAND/PARKRES.shp")

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



```  




## Author

**Anthoniez Fernando**  
Data Science and AI Automation Enthusiast  
📍 Melbourne, Australia  
🔗 [LinkedIn](https://www.linkedin.com/in/jayamini-anthoniez-fernando/)  
📧 [jayfernandojay@gmail.com](mailto:jayfernandojay@gmail.com)


---
