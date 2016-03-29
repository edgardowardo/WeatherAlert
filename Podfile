platform :ios, '9.0'
use_frameworks!

def shared_pods
end

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
    pod 'VTAcknowledgementsViewController'
    pod 'UIColor+FlatColors'
    shared_pods
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
    platform :watchos, '2.1'
    pod 'NKWatchChart'
    shared_pods
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-WeatherAlert/Pods-WeatherAlert-acknowledgements.plist', 'Pods-acknowledgements.plist', :remove_destination => true)
end