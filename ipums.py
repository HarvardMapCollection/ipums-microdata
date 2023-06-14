import pandas as pd

#Read data
data=pd.read_csv("{filepath}/usa_00004.csv.gz")

#We only need to keep columns PLACENHG, SEX, and RACE so let's do that and overwrite because it's huge. 
data = data.filter(items=['PLACENHG', 'SEX', 'RACE'])

#Create a row for each unique combination of NHGIS code, sex and race, and then 
#create a new column summing up how many people there are with that unique combo
data = data.groupby(['PLACENHG', 'SEX', 'RACE']).agg(POP=('SEX', 'count'))

#Groupby messes up the column headers, this fixes it
data = data.reset_index()

#Rename the values based on the codebook info so there are legibile headers in the pivot table
data = data.replace({'SEX' : { 1 : 'Male', 2 : "Female"}})
data = data.replace({'RACE' : { 1 : 'White', 2 : "Black/African American", 3 : "American Indian or Alaska Native", 4 : "Chinese", 5 : "Japanese", 6 : "Other Asian or Pacific Islander"}})


#pivot to create something joinable with placenhg.geojson
data = data.pivot_table(index='PLACENHG', columns='RACE', values='POP', aggfunc='sum')

#add a total population field
data['TOTALPOP'] = data[list(data.columns)].sum(axis=1)

#preview
print(data.head())

#write output
data.to_csv("{filepath}/output.csv")
