# Scraping Google API for international supermarkets

from googleplaces import GooglePlaces, types, lang
import time
import csv, os, sys
import io, re

#YOUR_API_KEY = 'AIzaSyCl2pAFtslb_Ke92FhjPl8lHggIycBk2iI' #[unaiza]
#YOUR_API_KEY = 'AIzaSyDvVlBVxGivnZlUN-StQK0gLjSBddNos64' #[munzir]
#YOUR_API_KEY = 'AIzaSyClj7B2rRaSceMF6HdVlumV1WOjDQKXPNs' #[sasha] 
#YOUR_API_KEY = 'AIzaSyAgJRxFynA_lkFFA7Ne9qsMzQNZclEccck' #mahdi's
#YOUR_API_KEY = 'AIzaSyCdthWJmRz0Fip5IxMZ_kFuTGUgM_nkbfk' #Yeji's
#YOUR_API_KEY = 'AIzaSyA20lqIBOh8uzRLAgU7zy_1COkNCNl8WGA' #Wes's
YOUR_API_KEY = 'AIzaSyBX7_T6viNbSG7PtfvmtnTi_madw3rX0LY' #Firaz's
google_places = GooglePlaces(YOUR_API_KEY)

data_path = 'C:\Users\uahsan3\Dropbox\DSSG-ATL2016\data\\'
file_zip_fulton = open(data_path + 'zipcodes_fulton.txt', 'r')
file_zip_dekalb = open(data_path + 'zipcodes_dekalb.txt', 'r')

zipcodes_fulton = file_zip_fulton.readlines()
zipcodes_dekalb = file_zip_dekalb.readlines()

to_run = 'dekalb'

if to_run == 'fulton':
    zipcodes = zipcodes_fulton
    op_file = open(data_path + 'results_fulton_supermarkets.csv', 'a')
    csv_writer =  csv.writer(op_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
else:
    zipcodes = zipcodes_dekalb
    op_file = open(data_path + 'results_dekalb_supermarkets.csv', 'a')
    csv_writer = csv.writer(op_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)

fieldnames = ['place_id', 'zipcode', 'supermarket_type', 'market_name', 'latitude', 'longitude', 'website_url', \
              'property_address', 'map_url', 'phone']

#supermarket_type = 'international_grocery_stores'
api_location = 'Georgia, United States'
api_radius = 4000   # kept the radius 4000 metres by trial and error

for i in range(65,len(zipcodes)):
    zipcode = zipcodes[i].strip()
    print(i)
    api_query = 'international grocery stores in ' + zipcode
    
    # Call the API
    query_result = google_places.text_search(query=api_query, location=api_location, radius=api_radius)
    
    j = 1
    # Results
    for place in query_result.places:
        # Returned places from a query are place summaries.
        market_name = place.name
        
        if type(market_name) == unicode:
            market_name = re.sub(r'[^\x00-\x7f]',r'', market_name) 
        
        geo_info_dict = place.geo_location
        latitude = str(geo_info_dict['lat'])
        longitude = str(geo_info_dict['lng'])
        place_id = place.place_id
        place.get_details()
                                
        # Referencing any of the attributes below, prior to making a call to
        # get_details() will raise a googleplaces.GooglePlacesAttributeError.
        dict1 = place.details # A dict matching the JSON response from Google.
        
        # Check if the place is permanently closed (as Google returns those places too)
        if 'permanently_closed' in dict1:
            break

        if 'formatted_phone_number' in dict1:
            phone = dict1['formatted_phone_number']
        else:
            phone = ''
        website_url = place.website
        map_url = dict1['url']
        property_address = (dict1['formatted_address'])
        
        if type(property_address ) == unicode:
            property_address = re.sub(r'[^\x00-\x7f]',r'', property_address) 
        supermarket_type = str(dict1['types'][0])
        #opening_hours = '\n'.join(dict1['opening_hours']['weekday_text'])
        
         # Writing the field names in both files only in first iteration
        if i == 0 and j == 1:
            csv_writer.writerow(fieldnames)
        
        # Write all to csv file
        row = [place_id, zipcode, supermarket_type, market_name, latitude, longitude, website_url, property_address, map_url, phone]
        csv_writer.writerow(row)      
        time.sleep(3)
               
        j = j + 1
op_file.flush()
op_file.close()