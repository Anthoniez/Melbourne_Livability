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
library(sf)
suburbs <- st_read("data/victoria/suburb_boundaries.shp")
plot(suburbs$geometry)
