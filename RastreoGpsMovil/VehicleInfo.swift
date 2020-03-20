//
//  VehicleInfo.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/7/19.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit

// This structure provides the information of the current vehicle to ALL the controllers
struct CurrentVehicleInfo{
    static var VehicleId = Int()
    static var VehicleName = String()
    static var Latitude = Float()
    static var Longitude = Float()
    static var VehiclePosition = String()
    static var Notifications = Bool()
    static var Max_Speed = Int()
    static var Email = String()
    static var Valet = Bool()
    static var NotificationType = Int()
    static var HasEmail = Bool()
    static var HasPush = Bool()
    static var LicensePlate = String()
    static var EmailUser = String()
    static var SerialNumber = String()
}

// This structure is to catch the vehicle id that is on the notification info (To center the vehicle into this marker)
struct NotificationInfo{
    static var vehicleId = Int()
}
