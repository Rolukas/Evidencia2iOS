//
//  MapViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import MapKit
import Foundation

// Set the vehicle status
enum StatusType: Int {
    case vehicleOff = 0
    case vehicleOn
    case vehicleMove
    case vehicleSpeed
}

// Table Cell SearchBar
class searchBarItem: UITableViewCell{
    @IBOutlet var vehicleInSearchBarLabel: UILabel!
}

// Annotation of the different vehicles
class VehicleAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?
    dynamic var subtitle: String?
    var type: StatusType
    var vehicleId: Int
    var selected: Bool
    var orientation: Float
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: StatusType, vehicleId: Int,orientation: Float) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.vehicleId = vehicleId
        self.selected = false
        self.orientation = orientation
    }
}

// AnnotationView of the different vehicles (this can be touched)
class VehicleAnnotationView: MKAnnotationView {
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    //override init(frame: CGRect) {
    //  super.init(frame: frame)
    //}
    
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let vehicleAnnotation = self.annotation as! VehicleAnnotation
        switch (vehicleAnnotation.type) {
        case .vehicleOff:
            image = UIImage(named: "ic_marker_red")
        case .vehicleOn:
            image = UIImage(named: "ic_marker_green_test")
        case .vehicleMove:
            image = UIImage(named: "ic_marker_green_test")
        case .vehicleSpeed:
            image = UIImage(named: "ic_marker_green_test")
        default:
            image = UIImage(named: "ic_marker_green_test")
        }
        
        var annotationViewImage = ResizeImage(image!, targetSize: CGSize(width: 22.0, height: 38.0))
        annotationViewImage = imageRotatedByangles( annotationViewImage,angles:CGFloat(vehicleAnnotation.orientation), flip: false)
        image = annotationViewImage
        
    }
    
    
    func repaint(_ zoomLevel: Double){
        let vehicleAnnotation = self.annotation as! VehicleAnnotation
        
        switch (vehicleAnnotation.type) {
        case .vehicleOff:
            image = UIImage(named: "ic_marker_red")
        case .vehicleOn:
            image = UIImage(named: "ic_marker_green")
        case .vehicleMove:
            image = UIImage(named: "ic_marker_green")
        case .vehicleSpeed:
            image = UIImage(named: "ic_marker_green")
        default:
            image = UIImage(named: "ic_marker_green")
        }
        // 3 is LEss 14 medium 20 more
        let factor : CGFloat = CGFloat(zoomLevel)/17
        
        var annotationViewImage = ResizeImage(image!, targetSize: CGSize(width: 25.0*factor, height: 41.0*factor))
        annotationViewImage = imageRotatedByangles( annotationViewImage,angles:CGFloat(vehicleAnnotation.orientation), flip: true)
        image = annotationViewImage
        
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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
    
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    
    open func imageRotatedByangles(_ image:UIImage, angles: CGFloat, flip: Bool) -> UIImage {
        let anglesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: image.size))
        let t = CGAffineTransform(rotationAngle: anglesToRadians(angles));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        bitmap?.rotate(by: anglesToRadians(angles));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap?.scaleBy(x: yFlip, y: -1.0)
        bitmap?.interpolationQuality = .high
        bitmap?.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        
        return newImage!
    }
    
}




class MapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate  {
    
    //** Credentials stored **//
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    //** Variables **//
    var userVersion: String!
    var timer: Timer = Timer()
    let timerLastPositionTime : Double = 10 // How many seconds the get is repeating
    var FirstTimeEntryPoint: Bool = true // First load of vehicles
    var FirstTimeTimerEntryPoint: Bool = true // First load of timer
    var vehicleWasTapped: Bool = false // If a vehicle was selected
    var lastNil: Int = 0 // Which vehicle was the nil
    var timer2: Timer = Timer() // Timer to progress bar
    var stopTimerProgress:Bool = false // Stop the timer of progress bar
    var currentMapRegion : MKCoordinateRegion = MKCoordinateRegion() // current region of the map
    var currentZoomFactor: Double = 0.0 // Zoom factor
    var zoomLevel: Double = 1.0 // Zoom level
    
    // Positions UI
    var isAllHidden: Bool = true
    // Button
    var buttonPositionX: CGFloat = 0.0
    var buttonPositionY: CGFloat = 0.0
    //TabBar
    var tabBarPositionX: CGFloat = 0.0
    var tabBarPositionY: CGFloat = 0.0
    //Blue Bottom
    var bottomViewX: CGFloat = 0.0
    var bottomViewY: CGFloat = 0.0
    // Blue Top Background
    var blueTopViewX: CGFloat = 0.0
    var blueTopViewY: CGFloat = 0.0
    // Spot Logo
    var spotLogoX: CGFloat = 0.0
    var spotLogoY: CGFloat = 0.0
    // Table View For Search Bar
    var tableViewX: CGFloat = 0.0
    var tableViewY: CGFloat = 0.0
    
    // Arrays
    var arrayVehicleId = [Int]()
    var arrayVehicleName = [String]()
    var arrayVehicleLatitude = [Float]()
    var arrayVehicleLongitude = [Float]()
    var arrayVehicleStatus = [StatusType]()
    var arrayCoincidences = [String]()
    var arrayOfVehiclesNull = [Int]()
    
    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()
    var notificationObsever: NSObjectProtocol?
    
    //** End of Variables **//
    //** Outlets **//
    @IBOutlet weak var principalButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var vehiclePositionLabel: UILabel!
    @IBOutlet weak var blueBackground: UIImageView!
    @IBOutlet weak var spotLogoImage: UIImageView!
    @IBOutlet weak var blueInformationBackground: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet var tableView: UITableView!
    
    
    //** Structs to fill with the JSON data **//
    
    // Map Vehicles
    struct MapInfo: Codable {
        let success: Bool
        let lastDate: String
        let items: [item] // Array of vehicles
    }
    
    struct item: Codable {
        let DateTime: String?
        let Description: String?
        let Latitude: Float?
        let Longitude: Float?
        let Orientation: Int?
        let Speed: Float?
        let Status: String?
        let VehicleId: Int?
    }
    
    // By Login
    struct SpecificVehicleInfo: Codable{
        let success: Bool
        let items: [vehicleItem]
    }
    
    struct vehicleItem: Codable{
        let id: Int
        let Description: String
        let Performance: Float
        let Fuel: Float?
        let Kilometers: Float?
        let Speed: Float
        let Address: String?
        let LastReport: String
        let LicensePlate: String?
        let FuelTypeId: Int
    }
    
    // Global Info of vehicle
    struct vehicleGlobal: Codable{
        let success: Bool
        let items: globalInfo?
    }
    
    struct globalInfo: Codable{
        let id: Int
        let Notifications: Bool
        let Max_Speed: Int
        let Email: String
        let Valet: Bool
        let NotificationType: Int?
        let HasEmail: Bool
        let HasPush: Bool
    }
    
    // Login petition
    struct Login: Codable {
        let success: Bool
        let items: itemLogin
    }
    
    struct itemLogin: Codable {
        let EmailMobile: String?
        let Version: String?
    }
    
    struct LastPositionVehicle {
        var vehicleAnnotation : VehicleAnnotation
        
        func setAnnotation(_ title: String, subTitle: String, coordinate:CLLocationCoordinate2D, type: StatusType, VehicleId: Int, Orientation: Float){
            
            self.vehicleAnnotation.title = title
            self.vehicleAnnotation.subtitle = subTitle
            self.vehicleAnnotation.coordinate = coordinate
            self.vehicleAnnotation.vehicleId = VehicleId
            self.vehicleAnnotation.type = type
            self.vehicleAnnotation.orientation = Orientation
        }
    }
   
    
    
}


// Controllers of MapKit
extension MKMapView {
    
    
    
}
