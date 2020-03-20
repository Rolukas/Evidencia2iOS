//
//  HistoricViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import WARangeSlider
import MapKit
import Firebase
import CoreLocation


enum HistoryStatusType: Int {
    case parking = 0
    case speedLimit
    case first
    case end
    case parkingLarge
}

class HistoryAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?
    dynamic var subtitle: String?
    var type: HistoryStatusType
    var selected: Bool
    var orientation: Float
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: HistoryStatusType,orientation: Float) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.selected = false
        self.orientation = orientation
    }
}

class HistoryAnnotationView: MKAnnotationView {
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let historyAnnotation = self.annotation as! HistoryAnnotation
        
        switch (historyAnnotation.type) {
            
        case .parking:
            
            image = self.ResizeImage(UIImage(named: "ic_parking")!, targetSize: CGSize(width: 20.0, height: 20.0))
        case .speedLimit:
            image = self.ResizeImage(UIImage(named: "ic_speedLimitViolated")!, targetSize: CGSize(width: 27.6, height: 17.6))
        case .first:
            image = self.ResizeImage(UIImage(named: "ic_startPoint")!, targetSize: CGSize(width: 12.0, height: 12.0))
        case .end:
            image = self.ResizeImage(UIImage(named: "ic_flag")!, targetSize: CGSize(width: 24, height: 34.5))
        default:
            image = UIImage(named: "abc_movimiento")
        }
    }
    
    func repaintDarkMode(_ zoomLevel: Double){
        let historyAnnotation = self.annotation as! HistoryAnnotation
        let factor : CGFloat = CGFloat(zoomLevel)/17
        
        switch (historyAnnotation.type) {
        case .parking:
            image = self.ResizeImage(UIImage(named: "ic_parking_white")!, targetSize: CGSize(width: 20.0, height: 20.0))
        case .speedLimit:
            image = self.ResizeImage(UIImage(named: "ic_speedLimitViolated_white")!, targetSize: CGSize(width: 27.6*factor, height: 17.6*factor))
        case .first:
            image = self.ResizeImage(UIImage(named: "ic_startPoint_white")!, targetSize: CGSize(width: 20.0*factor, height: 20.0*factor))
        case .end:
            image = self.ResizeImage(UIImage(named: "ic_flag_white")!, targetSize: CGSize(width: 24*factor, height: 34.5*factor))
        default:
            image = UIImage(named: "abc_movimiento")
        }
    }
    
    
    func repaint(_ zoomLevel: Double){
        let historyAnnotation = self.annotation as! HistoryAnnotation
        let factor : CGFloat = CGFloat(zoomLevel)/17
        
        switch (historyAnnotation.type) {
        case .parking:
            image = self.ResizeImage(UIImage(named: "ic_parking")!, targetSize: CGSize(width: 20.0, height: 20.0))
        case .speedLimit:
            image = self.ResizeImage(UIImage(named: "ic_speedLimitViolated")!, targetSize: CGSize(width: 27.6*factor, height: 17.6*factor))
        case .first:
            image = self.ResizeImage(UIImage(named: "ic_startPoint")!, targetSize: CGSize(width: 20.0*factor, height: 20.0*factor))
        case .end:
            image = self.ResizeImage(UIImage(named: "ic_flag")!, targetSize: CGSize(width: 24*factor, height: 34.5*factor))
        default:
            image = UIImage(named: "abc_movimiento")
        }
    }
    
    
    func ResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

class HistoricViewController: UIViewController, MKMapViewDelegate {
    
    
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    // OUTLETS
    @IBOutlet weak var firstHourLabel: UILabel!
    @IBOutlet weak var Footer: UIView!
    @IBOutlet weak var secondHourLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveDatePickerButton: UIButton!
    @IBOutlet weak var cancelDatePickerButton: UIButton!
    @IBOutlet weak var odometerNumberLabel: UILabel!
    @IBOutlet weak var speedNumberLabel: UILabel!
    @IBOutlet weak var odometerLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    // VARIABLES
    var timer: Timer = Timer()
    let timerSlideDecide: Double = 1
    
    var currentDateL: Date = Date()
    var currentDateH: Date = Date()
    
    var highDateHours = Int()
    var highDateMinutes = Int()
    
    var lowDateHours = Int()
    var lowDateMinutes = Int()
    
    var months = [String]()
    
    var StringDate = String()
    var day = String()
    var month = String()
    var year = String()
    
    var handleDay = String()
    var handleMonth = String()
    var handleYear = String()
    
    //Variables para calcular tiempo de apagado
    var hourVehicleOff: String?
    var firstHour: Date!
    var secondHour: Date!
    var vehicleOff: Bool = false
    var coordVehicleOff: CLLocationCoordinate2D?
    var currentZoomFactor: Double = 0.0 // Zoom factor
    var currentMapRegion : MKCoordinateRegion = MKCoordinateRegion() // current region of the map
    var zoomLevel: Double = 1.0 // Zoom level
    var timeZoneOffset = Int()
    // Array of positions
    var ArrayOfPositions: [CLLocationCoordinate2D] = []
    
    // Range slider: https://iosexample.com/a-simple-range-slider-made-in-swift/
    let rangeSlider = RangeSlider(frame: CGRect.zero)
    
    var isDarkModeEnabled: Bool = false
    
    //****** Structures to fill the data ******//
    
    // Structures of Positions Get
    struct Positions: Codable {
        var items: [item]
    }
    
    struct item: Codable {
        var mId: Int
        var Id: Int
        var da: String
        var ti: String
        var la: Float
        var lo: Float
        var sp: Int
        var of: Int
    }
    
    // Structures of Odometer Get
    struct Odometer: Codable {
        var success: Bool
        var items: [itemOdometer]
        var totalCount: Int
    }
    
    struct itemOdometer: Codable {
        var VehicleId: Int
        var Odometer: Float
        var Description: String
        var FuelCost: Float
        var Performance: Float
        var Liters: Float
        var Price: Float
    }
    
    // Structures of Speed Get
    struct Speed: Codable{
        var success: Bool
        var items: [itemSpeed]
        var totalCount: Int
    }
    
    struct itemSpeed: Codable{
        var VehicleId: Int
        var Description: String
        var MaxSpeed: Int
        var AverageSpeed: Float
        var AvgSpeedNoZero: Float
    }
    
  
}
