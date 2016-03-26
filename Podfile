platform :ios, '9.0'
use_frameworks!

target 'WeatherAlert' do
pod 'TIPBadgeManager'
pod "TTRangeSlider"
pod "AKPickerView"
pod 'ReactKit'
pod 'Charts'
pod 'Alamofire'
pod 'Ono'
pod 'Fuzi'
pod 'SlideMenuControllerSwift'
pod 'RealmSwift'
pod 'MBProgressHUD'
pod 'UIColor+FlatColors'
pod 'VTAcknowledgementsViewController'
end

target 'WeatherAlertTests' do
    pod 'Quick'
    pod 'Nimble'
end

target 'WeatherAlertUITests' do
    pod 'Quick'
    pod 'Nimble'
end


target 'Wind Times' do
end

target 'Wind Times Extension' do
    pod 'NKWatchChart'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-WeatherAlert/Pods-WeatherAlert-acknowledgements.plist', 'Pods-acknowledgements.plist', :remove_destination => true)
end