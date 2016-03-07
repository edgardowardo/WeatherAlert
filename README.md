# WeatherAlert
For Sky contract position on Feb 2016

Minimum deployment requirement : iOS 9.2

Using Swift 2.1.1 on Xcode 7.2

#Test results
![alt tag](https://github.com/edgardowardo/WeatherAlert/blob/master/c.png)

The test cases show basic unit tests for reading and writing the realm objects which include the AppObject, CityObject, CurrentObject and ForecastObject. Test specs for the MainViewController searches the local datastore internally as well as end-to-end query to the OpenWeatherAPI server and eventually saving the Current and detailed Forecasts XML results on the local datastore.

The UI tests are limited to 5 test cases because there is an issue in UISearchController result-set being voice-over in-accessible. Since XCUI is based on UI elements being voice over accessible, testing is impossible unless the whole search function is re-written by not using UISearchController. This holds true to Apple specific apps such as Mail that employs UISearchController. Even WhatsApp search bar results is voice over un-accessible!

The issue in stackoverflow regarding voice over in-accessible search controller is ![alt tag](http://stackoverflow.com/questions/33056324/uisearchcontroller-in-accessible)
