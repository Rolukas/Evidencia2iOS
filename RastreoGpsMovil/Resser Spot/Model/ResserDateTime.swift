//
//  ResserDateTime.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright (c) 2020 Rolando. All rights reserved.
//

import Foundation

open class ResserDateTime {
    
    
    open class func ParseDateFriendly(_ date: Date) -> String {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy' 'h:mm a"
        formatter.locale = Locale(identifier: "us")
        formatter.string(from: date)
        
        let localString : String = formatter.string(from: date)
        return localString
    }
    
    open static func ParseDateFriendlyNoHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "us")
        formatter.string(from: date)
        
        let dayOrder = compareDatesOnlyDay(Date(), date2: date)
        var nowString = ""
        if(dayOrder == .orderedSame)
        {
            nowString = ""
        }
        let localString : String = nowString+formatter.string(from: date)
        return localString
    }
    
    open static func compareDatesOnlyDay(_ date1: Date, date2: Date) -> ComparisonResult {
        
        let components: NSCalendar.Unit =
            [.second, .minute, .hour, .day, .year]
        
        let component: DateComponents =  (Calendar.current as NSCalendar).components(components,
                                                                                     from: date1,
                                                                                     to: date2,
                                                                                     options: [] )
        
        if( component.year! < 0 )
        {
            return .orderedAscending
        }
        if( component.year! > 0 )
        {
            return .orderedDescending
        }
        if( component.day! < 0 )
        {
            return .orderedAscending
        }
        if( component.day! > 0 )
        {
            return .orderedDescending
        }
        if component.day == 0 {
            return .orderedSame
        }
        return .orderedSame
        
    }
    
    open static func dateTimeAddDay(_ date: Date, days:Int) -> Date {
        let userCalendar = Calendar.current
        
        
        // (Previous code goes here)
        
        // What will the date and time be be ten days from now?
        let nDaysFromNow = (userCalendar as NSCalendar).date(
            byAdding: [.day],
            value: days,
            to: date,
            options: [])!
        
        return nDaysFromNow
        // http://www.globalnerdy.com/2015/01/29/how-to-work-with-dates-and-times-in-swift-part-two-calculations-with-dates/
        
    }
    
    open class func dateTimeDifference(_ lhs: Date, rhs: Date) -> DateComponents {
        let components: NSCalendar.Unit =
            [.second, .minute, .hour, .day]
        return (Calendar.current as NSCalendar).components(components,
                                                           from: rhs,
                                                           to: lhs,
                                                           options: [])
    }
    
    open class func timeAgoStringBetween(_ date: Date, First: Date) -> String {
        
        let dateComponent : DateComponents = dateTimeDifference(First,rhs: date)
        var timeAgoString : String = NSLocalizedString("time_since", comment: "time_since") + "  \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minutes", comment: "time_Minutes")
        
        if(dateComponent.day! == 0 && dateComponent.hour! == 0 && dateComponent.minute! <= 1)
        {
            timeAgoString  = NSLocalizedString("time_Now", comment: "time_Now")
        }
        else if(dateComponent.day! == 0 && dateComponent.hour! == 0 && dateComponent.minute! > 1)
        {
            timeAgoString  = " \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minutes_Low", comment: "time_Minutes_Low")
        }
        else if(dateComponent.day! == 0 && dateComponent.hour! > 0 )
        {
            if(dateComponent.hour! > 1)
            {
                timeAgoString  = " \(dateComponent.hour! as Int) " + NSLocalizedString("time_Hours", comment: "time_Hours")
            }
            else
            {
                timeAgoString  = " \(dateComponent.hour! as Int) " + NSLocalizedString("time_hour", comment: "time_hour")
            }
            if( dateComponent.minute! > 0)
            {
                if(dateComponent.minute! > 1)
                {
                    timeAgoString  = " y \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minutes_Low", comment: "time_Minutes_Low")
                }
                else
                {
                    timeAgoString  = " y \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minute_Low", comment: "time_Minute_Low")
                }
            }
        }
        else if(dateComponent.day! >= 1)
        {
            timeAgoString  = " \(dateComponent.day! as Int) " + NSLocalizedString("time_days", comment: "time_days")
        }
        return timeAgoString
    }
    
    open class func timeAgoString(_ date: Date) -> String {
                
        let dateComponent : DateComponents = dateTimeDifference(Date(),rhs: date)
        
        
        var timeAgoString : String = NSLocalizedString("time_since", comment: "time_since") + "  \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minutes", comment: "time_Minutes")
        
        if(dateComponent.day! == 0 && dateComponent.hour! == 0 && dateComponent.minute! <= 1)
        {
            timeAgoString  = NSLocalizedString("time_Now", comment: "time_Now")
        }
        else if(dateComponent.day! == 0 && dateComponent.hour! == 0 && dateComponent.minute! > 1)
        {
            timeAgoString  = NSLocalizedString("time_since", comment: "time_since") + "  \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minutes_Low", comment: "time_Minutes_Low")
        }
        else if(dateComponent.day! == 0 && dateComponent.hour! > 0 )
        {
            if(dateComponent.hour! > 1)
            {
                timeAgoString  = NSLocalizedString("time_since", comment: "time_since") + " \(dateComponent.hour! as Int) " + NSLocalizedString("time_Hours", comment: "time_Hours")
            }
            else
            {
                timeAgoString  = NSLocalizedString("time_since", comment: "time_since") + "  \(dateComponent.hour! as Int) " + NSLocalizedString("time_hour", comment: "time_hour")
            }
            if( dateComponent.minute! > 0)
            {
                if(dateComponent.minute! > 1)
                {
                    timeAgoString  = NSLocalizedString("time_and", comment: "time_and") + " \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minutes_Low", comment: "time_Minutes_Low")
                }
                else
                {
                    timeAgoString  = NSLocalizedString("time_and", comment: "time_and") + " \(dateComponent.minute! as Int) " + NSLocalizedString("time_Minute_Low", comment: "time_Minute_Low")
                }
            }
        }
        else if(dateComponent.day! >= 1)
        {
            timeAgoString  = NSLocalizedString("time_since", comment: "time_since") + "  \(dateComponent.day! as Int) " + NSLocalizedString("time_days", comment: "time_days")
        }
        return timeAgoString
    }
    
    
    
}
