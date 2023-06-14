# IPUMS microdata 

Included find `ipums.R` by Jess Cohen-Tanugi via Harvard Library [Visualization Support Services](https://library.harvard.edu/services-tools/visualization-support).

The goals of this project were to recreate summarized tables from 1940s census publications. This project approximates real data support requests submitted to the Harvard Map Collection from scholars interested in working with historic microdata.

Source data comes from [https://www.ipums.org/](https://www.ipums.org/). The demographic tables include over 3 million records and are not included, but extracts were prepared by selecting for `RACE`, `SEX`, and field `PLACENHG`, which provides a unique ID for historic census "places", which correspond to towns in 1940. This `PLACENHG` field joins with [NHGIS](https://data2.nhgis.org) `Place (Points)` dataset from 1940, included in this repository as `placenhg.geoJSON`. 

The script, `ipums.R` takes the 3 million records for indiviudals in Massachusetts and pivots and then summarizes them into a mappable dataset, aggregated by place and various combinations of the demographic variables of interest. Rather than a strict data cleaning script, Jess has created this script as a teaching object to walk through various ways one could use R to make sense of IPUMS microdata. There are numerous ways to do the same task for teachability, as well as "concise" vs. "tedious" approaches to working with the `codebook.txt` data. Belle adapted Jess's R script for Python, `ipums.py`.

Outputs can be joined with `placenhg.geoJSON` for use with mapping, and this script can be adapted to prepare other extracts from IPUMS. 

If you are interested in learning more about how to do this yourself, or would like us to teach it as a workshop, get in touch via `maps@harvard.edu`. 

