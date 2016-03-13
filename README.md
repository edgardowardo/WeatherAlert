# WeatherAlert
For Sky contract position on Feb 17, 2016

Minimum deployment requirement : iOS 9.2

Using Swift 2.1.1 on Xcode 7.2

# The Requirements

Build the [app requirements](https://github.com/edgardowardo/WeatherAlert/blob/master/Weather Alert UT - Sky.docx) in a week, as specified in the word document.

# The Solution: Key design and architectural decisions

Why realm? It is the fastest local datastore. City search scans at least 200K records on disk. So performance is important. 

Why save city data on disk in the first place? Open weather map org recommends to query current data using city id to get unambiguous city result. This means storing city id's and name on disk. Search by name on the OpenWeather api is very ambiguous and does not return sensible results for example using "Xxx" returns a croatian city. It should return an error from the server. The word "Manchester" returns no list options and only returns the US city no option for the decadent English city.

Why Alamofire? There is an existing OpenWeatherMapAPI why not use it? OpenWeatherMapAPI cocoa pod only provides JSON data without the direction codes and speed name, whilst the XML data returns more sensible wind info such as speed name, direction code which simplifies plotting of cardinal direction. JSON data does not provide these descriptive data.
 
Why Charts? It's the best and easiest way to plot a radar chart.

![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/a.png)
![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/b.png)

#The Test results
![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/c.png)

The test cases show basic unit tests for reading and writing the realm objects which include the AppObject, CityObject, CurrentObject and ForecastObject. Test specs for the MainViewController searches the local datastore internally as well as end-to-end query to the OpenWeatherAPI server and eventually saving the Current and detailed Forecasts XML results on the local datastore.

The UI tests are limited to 5 test cases because there is an [issue in UISearchController result-set being voice-over in-accessible](http://stackoverflow.com/questions/33056324/uisearchcontroller-in-accessible). Since XCUI is based on UI elements being voice over accessible, testing is impossible unless the whole search function is re-written by not using UISearchController. This holds true to Apple specific apps such as Mail that employs UISearchController. Even WhatsApp search bar results is voice over in-accessible and therefore XCUI un-testable!

