
# Tracking individual air pollution exposure

## Introduction
Air pollution remains a major health hazard in urban environments all over the globe.
The four most common air pollutants are Particulate matter (PM), Nitrogen Oxide
(NO2), Sulfur Dioxide (SO2) and ozone (O3). Air pollution emerges from a variety of
sources such as vehicle exhaust, industry, power generation, domestic fuel burning
and construction activities (1). Research suggests that both PM and NO2 can cause or
aggravate asthma and impair lung development (2). In response to the adverse effects
of air pollution on humans, the European Union has specified standards for the
amount of pollutants in the air (3). Despite congestion charging and a citywide lowemission
zone, the administration of London has failed to lower its air pollution levels
to the EU limit values (4).
At the same time, the emerging trend of the ‘Quantified Self’ has a big impact on
health consciousness and self-optimization. Self-tracking data streams such as
wearables, mobile phones and cloud-based services are booming (5).
By using self-tracking, this tool aims to overlay data about pollutants in London’s air
with the positions from daily commutes and to visualize air pollution exposure at a
given place and time within one day.


## Data
The following datasets are used to model air pollution exposure along different paths.
London Air Quality Network (LAQN):     
### Air pollution measurements
- Source: The Files are imported from a remote server operated by King's
College London through the package Openair in R (6).
- Chosen variables: Date / time of measurement, coordinates and hourly mean
NO2 measurements for 73 measurement stations.  
### LAQN Measurement stations: Metadata
- Source: From King's College London through the Openair package in R.
- Chosen variables: Codes of 55 measurement stations in the LAQN.  
### Google location history
- Source: If enabled, the Google Maps location history records the position of a
cell phone. It can be downloaded as JSON through Google Takeouts (7).
- Chosen variables: Date, time and coordinates for all positions in one day.

(1) World Health Organization. (2005). WHO Air Quality Guidelines for particulate matter, ozone,
nitrogen sulfur dioxide. Geneva dioxide and, page 5.  
(2) Royal College of Physicians. (2016). Every breath we take: The lifelong impact of air pollution.  
(3) See footnote 1  
(4) Kelly, F.J., Zhu, T., 2016. Transport solutions for cleaner air. Science 352, 934–936.  
(5) Swan, M., 2013. The Quantified Self: Fundamental Disruption in Big Data Science and Biological
Discovery. Big Data 1, 85–99.  
(6) The openair project is led by the Environmental Research Group at King's College London and is
available under http://www.openair-project.org/  
(7) Google takeouts is available under https://takeout.google.com/settings/takeout
