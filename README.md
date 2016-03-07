# WeatherAlert
For Sky contract position on Feb 2016

Minimum deployment requirement : iOS 9.2

Using Swift 2.1.1 on Xcode 7.2

![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/a.png)
![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/b.png)


# Key design and architectural decisions

Why realm? It is the fastest local datastore. City search scans at least 200K records on disk. So performance is important. 

Why save city data on disk in the first place? Open weather map org recommends to query current data using city id to get unambiguous city result. This means storing city id's and name on disk. Search by name on the OpenWeather api is very ambiguous and does not return sensible results for example using "Xxx" returns a croatian city. It should return an error from the server. The word "Manchester" returns no list options and only returns the US city no option for the decadent English city.

Why Alamofire? There is an existing OpenWeatherMapAPI why not use it? OpenWeatherMapAPI cocoa pod only provides JSON data without the direction codes and speed name, whilst the XML data returns more sensible wind info such as speed name, direction code which simplifies plotting of cardinal direction. JSON data does not provide these descriptive data.
 
Why Charts? It's the best and easiest way to plot a radar chart.

#Test results
![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/c.png)

The test cases show basic unit tests for reading and writing the realm objects this include the AppObject, CityObject, CurrentObject and ForecastObject. Test specs for the MainViewController searches the local datastore internally as well as end-to-end query to the OpenWeatherAPI server and eventually saving the XML results on the store.

The UI tests are limited to 5 test cases because there is an issue in UISearchController result set being voice-over un-accesible. Since XCUI is based on UI elements being voice over accessible, testing is impossible unless the whole search function is re-written by not using UISearchController. This holds true to Apple specific apps such as Mail that employs UISearchController. Even WhatsApp is voice over un-accessible!
