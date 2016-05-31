# A simple script to pull data using Google Places API

from googleplaces import GooglePlaces, types, lang
import time
import csv, os, sys

#YOUR_API_KEY = 'AIzaSyCl2pAFtslb_Ke92FhjPl8lHggIycBk2iI' #[unaiza]
#YOUR_API_KEY = 'AIzaSyDvVlBVxGivnZlUN-StQK0gLjSBddNos64' #[munzir]
#YOUR_API_KEY = 'AIzaSyClj7B2rRaSceMF6HdVlumV1WOjDQKXPNs' #[sasha]
#YOUR_API_KEY = 'AIzaSyAgJRxFynA_lkFFA7Ne9qsMzQNZclEccck' #mahdi's
#YOUR_API_KEY = 'AIzaSyCdthWJmRz0Fip5IxMZ_kFuTGUgM_nkbfk' #Yeji's
YOUR_API_KEY = 'AIzaSyA20lqIBOh8uzRLAgU7zy_1COkNCNl8WGA' #Wes's
#YOUR_API_KEY = 'AIzaSyBX7_T6viNbSG7PtfvmtnTi_madw3rX0LY' #Firaz's
google_places = GooglePlaces(YOUR_API_KEY)

# Change the data paths to your own
data_path = '/home/uni/Dropbox/DSSG-ATL2016/data/'
file_zip_fulton = open(data_path + 'zipcodes_fulton.txt', 'r')
file_zip_dekalb = open(data_path + 'zipcodes_dekalb.txt', 'r')

output_fulton = open(data_path + 'results_fulton_google_updated.csv', 'a')
#output_dekalb = open(data_path + 'results_dekalb_google.csv', 'a')

fieldnames = ['place_id', 'zipcode', 'property_type', 'apartment_name', 'latitude', 'longitude', 'website_url', \
              'property_address', 'map_url', 'phone']
writer_fulton = csv.writer(output_fulton, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
#writer_dekalb = csv.writer(output_dekalb, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)

# Writing the field names in both files
#writer_fulton.writerow(fieldnames)
#writer_dekalb.writerow(fieldnames)

zipcodes_fulton = file_zip_fulton.readlines()
zipcodes_dekalb = file_zip_dekalb.readlines()

property_type = 'apartment_complex'
api_location = 'Georgia, United States'
api_radius = 4000   # kept the radius 4000 metres by trial and error

for i in range(156,len(zipcodes_fulton)):
    zipcode = zipcodes_fulton[i].strip()
    print(i)
    api_query = 'apartment complexes in ' + zipcode

    # Call the API
    query_result = google_places.text_search(query=api_query, location=api_location, radius=api_radius)

    # Results
    for place in query_result.places:
        # Returned places from a query are place summaries.
        apartment_name = place.name
        geo_info_dict = place.geo_location
        latitude = str(geo_info_dict['lat'])
        longitude = str(geo_info_dict['lng'])
        place_id = place.place_id
        place.get_details()
        # Referencing any of the attributes below, prior to making a call to
        # get_details() will raise a googleplaces.GooglePlacesAttributeError.
        dict1 = place.details # A dict matching the JSON response from Google.
        phone = place.local_phone_number
        website_url = place.website
        map_url = place.url
        property_address = dict1['formatted_address']
        #opening_hours = '\n'.join(dict1['opening_hours']['weekday_text'])

        # Write all to csv file
        row = [place_id, zipcode, property_type, apartment_name, latitude, longitude, website_url, property_address, map_url, phone]
        writer_fulton.writerow(row)
        #time.sleep(1)
output_fulton.flush()
