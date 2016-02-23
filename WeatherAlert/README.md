# WeatherAlert

For Sky contract position on Feb 23, 2016

Minimum deployment requirement : iOS 9.0

![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/b.png)


# Key design and architectural decisions

Why realm? It is the fastest local datastore. City search scans at least 200K records on disk. So performance is important. Why save city data on disk  open weather map org recommends to query current data using city id to get unambiguous city result. This means storing city id's and name on disk. Search by name on the OpenWeather api is very ambiguous and does not return sensible results for example use Xxx returns a croatian city. It should return an error instead searching locally from disk is so much better! Manchester returns no list options and only returns the US city.

Why Alamofire? There is an existing OpenWeatherMapAPI why not use it? OpenWeatherMapAPI cocoa pod only provides JSON data without the direction codes and speed name, whilst the XML data returns more sensible wind info such as speed name, direction code which simplifies plotting of cardinal direction. JSON data does not provide these descriptive data.
 
Why Charts? It's the best and easiest way to plot a radar chart.

