# this script applies hand-off coefficients from John Gardener's lab to the 
# GSL data

# script by B. Steele (b.steele@colostate.edu), ROSSyndicate, Colorado State University

# last modified 14Aug2024

# note the correction coefficients used in this file were dated Sept 2023, and may
# have been updated since that time. 

library(tidyverse)
library(feather)

# read in data
rrs <- read_feather("data_out/Landsat_C2_GSL_collated_DSWE1_center_meta_v2024-08-14.feather") %>% 
  filter(all_of(!is.na(names(rrs))))

# do a quick reality filter, we shouldn't loose any data since these are filters within the data itself
rrs_filter <- rrs %>% 
  filter(if_all(c(med_Blue:med_Swir2),
                ~ . < 1 & . > -0.01))%>% 
  # filter out LS7 after end of science mission
  filter(!(mission == "LANDSAT_7" & date > ymd("2019-12-31")))

# read in the correction coefficients - these are from sept of 2023, so might need to grab updated from JG
correction_coefficients <- read_csv("data_in/LC02_Corr_Coef.csv") %>% 
  # pivot for easier application
  pivot_longer(cols = c(intercept, coef1, coef2), 
               names_to = "int_coef", 
               values_to = "value") %>%
  mutate(new_column = paste(band, int_coef, sep = "_")) %>%
  select(-band, -int_coef) %>%
  pivot_wider(names_from = new_column, 
              values_from = value)

# apply coefficients to timeseries data
rrs_corrected <- rrs_filter %>% 
  mutate(sat = case_when(mission == "LANDSAT_4" ~ "LT05", # landsat 4 is rought=ly the same as 5
                         mission == "LANDSAT_5" ~ "LT05",
                         mission == "LANDSAT_7" ~ "LE07",
                         mission == "LANDSAT_8" ~ "LC08",
                         mission == "LANDSAT_9" ~ "LC08", # landsat 9 is roughly the same as 8
                         TRUE ~ NA_character_)) %>% 
  left_join(., correction_coefficients) %>% 
  mutate(red_corr7 = Red_intercept + Red_coef1*med_Red + Red_coef2*med_Red^2,
         green_corr7 = Green_intercept + Green_coef1*med_Green + Green_coef2*med_Green^2,
         blue_corr7 = Blue_intercept + Blue_coef1*med_Blue + Blue_coef2*med_Blue^2,
         nir_corr7 = Nir_intercept + Nir_coef1*med_Nir + Nir_coef2*med_Nir^2,
         swir1_corr7 = Swir1_intercept + Swir1_coef1*med_Swir1 + Swir1_coef2*med_Swir1^2,
         swir2_corr7 = Swir2_intercept + Swir2_coef1*med_Swir2 + Swir2_coef2*med_Swir2^2) 



ggplot(rrs_corrected, aes(x = med_Red, y = red_corr7, color = mission)) +
  geom_point() +
  theme_bw() +
  labs(title = "red polynomial correction") +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = med_Green, y = green_corr7, color = mission)) +
  geom_point() +
  theme_bw()+
  labs(title = "green polynomial correction") +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = med_Blue, y = blue_corr7, color = mission)) +
  geom_point() +
  theme_bw()+
  labs(title = "blue polynomial correction") +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = med_Nir, y = nir_corr7, color = mission)) +
  geom_point() +
  theme_bw()+
  labs(title = "nir polynomial correction") +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = med_Swir1, y = swir1_corr7, color = mission)) +
  geom_point() +
  theme_bw()+
  labs(title = "swir1 polynomial correction") +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = med_Swir2, y = swir2_corr7, color = mission)) +
  geom_point() +
  theme_bw()+
  labs(title = "swir2 polynomial correction") +
  scale_color_viridis_d()


# and a quick peek at the timeseries

ggplot(rrs_corrected, aes(x = date, y = red_corr7, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(title = "red band timeseries") +
  theme_bw() +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = date, y = green_corr7, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(title = "green band timeseries") +
  theme_bw() +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = date, y = blue_corr7, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(title = "blue band timeseries") +
  theme_bw() +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = date, y = nir_corr7, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(title = "NIR band timeseries") +
  theme_bw() +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = date, y = swir1_corr7, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(main = "SWIR1 band timeseries") +
  theme_bw() +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = date, y = swir2_corr7, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(main = "SWIR2 band timeseries") +
  theme_bw() +
  scale_color_viridis_d()

ggplot(rrs_corrected, aes(x = date, y = med_SurfaceTemp, color = mission)) +
  geom_point(alpha = 0.5) +
  facet_grid(r_id ~ ., scales = 'free_y') +
  labs(main = "surface temperature timeseries") +
  theme_bw() +
  scale_color_viridis_d()

write_csv(rrs_corrected, "data_out/Landsat_C2_SRST_GSL_rrs_corrected_v2024-08-13.csv")



