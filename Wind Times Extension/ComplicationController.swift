//
//  ComplicationController.swift
//  Wind Times Extension
//
//  Created by EDGARDO AGNO on 25/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource, DataSourceChangedDelegate {
    
    // MARK: - Properties
    
    let forecastDuration = NSTimeInterval( 3 * 60 * 60 )
    var current : CurrentObject? = nil // = getCurrentObject()
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let start = current?.forecasts.first?.timefrom
        handler(start)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let end = current?.forecasts.last?.timefrom?.dateByAddingTimeInterval(forecastDuration)
        handler(end)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry

        getTimelineEntriesForComplication(complication, afterDate: NSDate().dateByAddingTimeInterval(-forecastDuration), limit: 1) { (entries) -> Void in
            handler(entries?.first)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        
        var entries = [CLKComplicationTimelineEntry]()
        var forecast = current?.forecasts.first
        
        guard let _ = forecast else {
            let tmpl = templateForForecast(nil)
            let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: tmpl)
            entries.append(entry)
            handler(entries)
            return
        }
        
        while let thisForecast = forecast {
            if let thisEntryDate = thisForecast.timefrom where date.compare(thisEntryDate) == .OrderedAscending {
                let tmpl = templateForForecast(thisForecast)
                let entry = CLKComplicationTimelineEntry(date: thisEntryDate, complicationTemplate: tmpl)
                entries.append(entry)
                if (entries.count == limit) { break }
            }
            forecast = forecast?.next
        }
        
        handler(entries)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let next = current?.forecasts.last?.timefrom
        //let next = NSDate().dateByAddingTimeInterval(NSTimeInterval(60))
        //NSLog("log-getNextRequestedUpdateDateWithHandler(\(next))")
        handler(next)
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        var template : CLKComplicationTemplate? = nil
        
        switch complication.family {
        case .ModularLarge :
            let tmpl = CLKComplicationTemplateModularLargeColumns()
            tmpl.row1ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "N-white")!)
            tmpl.row1Column1TextProvider = CLKSimpleTextProvider(text: "Wind speed")
            tmpl.row1Column2TextProvider = CLKSimpleTextProvider(text: "00h")
            tmpl.row2ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "N-white")!)
            tmpl.row2Column1TextProvider = CLKSimpleTextProvider(text: "Wind speed")
            tmpl.row2Column2TextProvider = CLKSimpleTextProvider(text: "03h")
            tmpl.row3ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "N-white")!)
            tmpl.row3Column1TextProvider = CLKSimpleTextProvider(text: "Wind speed")
            tmpl.row3Column2TextProvider = CLKSimpleTextProvider(text: "06h")
            template = tmpl
        default :
            template = nil
        }
        
        handler(template)
    }
    
    func requestedUpdateDidBegin() {
        //NSLog("log-requestedUpdateDidBegin")
        if WatchSessionManager.sharedManager.isStale {
            WatchSessionManager.sharedManager.session?.sendMessage(["command" : "getFavourites"], replyHandler: { (data : [String : AnyObject]) -> Void in
                NSLog("log-replyHandler \(data)") }, errorHandler: nil)
        }
    }
    
    // MARK: - Data Source

    private func templateForForecast(forecast : ForecastObject?) -> CLKComplicationTemplate {
        //NSLog("log-templateForForecast \(forecast)")
        
        guard let forecast = forecast else {
            let tmpl = CLKComplicationTemplateModularLargeColumns()
            tmpl.row1ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "N-white")!)
            tmpl.row1Column1TextProvider = CLKSimpleTextProvider(text: "Wind speed")
            tmpl.row1Column2TextProvider = CLKSimpleTextProvider(text: "00h")
            tmpl.row2ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "N-white")!)
            tmpl.row2Column1TextProvider = CLKSimpleTextProvider(text: "Wind speed")
            tmpl.row2Column2TextProvider = CLKSimpleTextProvider(text: "03h")
            tmpl.row3ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "N-white")!)
            tmpl.row3Column1TextProvider = CLKSimpleTextProvider(text: "Wind speed")
            tmpl.row3Column2TextProvider = CLKSimpleTextProvider(text: "06h")
            return tmpl
        }
        
        var speed = ""
        if let c = current {
            speed = c.units.speed
        }
        
        let tmpl = CLKComplicationTemplateModularLargeColumns()
        if let d = forecast.direction {
            tmpl.row1ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "\(d.inverse.rawValue)-white")!)
        }
        tmpl.row1Column1TextProvider = CLKSimpleTextProvider(text: "\(forecast.speedvalue) \(speed)")
        tmpl.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(forecast.hour)h")
        
        if let next = forecast.next {
            if let d = next.direction {
                tmpl.row2ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "\(d.inverse.rawValue)-white")!)
            }
            tmpl.row2Column1TextProvider = CLKSimpleTextProvider(text: "\(next.speedvalue) \(speed)")
            tmpl.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(next.hour)h")
            
            if let nextOfNext = next.next {
                if let d = nextOfNext.direction {
                    tmpl.row3ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "\(d.inverse.rawValue)-white")!)
                }
                tmpl.row3Column1TextProvider = CLKSimpleTextProvider(text: "\(nextOfNext.speedvalue) \(speed)")
                tmpl.row3Column2TextProvider = CLKSimpleTextProvider(text: "\(nextOfNext.hour)h")
            }
        }
        
        return tmpl
    }    
    
    func dataSourceDidUpdate(dataSource: DataSource) {
        guard let currents = dataSource.currentObjects else { return }
        self.current = currents.first
        let server = CLKComplicationServer.sharedInstance()
        
        for comp in (server.activeComplications) {
            server.reloadTimelineForComplication(comp)
        }
    }
    
    override init() {
        super.init()
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
    }
    
    deinit {
        WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
    }
    
}
