//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import SafariServices

// Set the vehicle status
enum StatusType: Int {
    case vehicleOff = 0
    case vehicleOn
    case vehicleMove
    case vehicleSpeed
    case vehicleExpired
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
            image = UIImage(named: "ic_marker_green")
        case .vehicleMove:
            image = UIImage(named: "ic_marker_green")
        case .vehicleSpeed:
            image = UIImage(named: "ic_marker_green")
        case .vehicleExpired:
            image = UIImage(named: "ic_marker_gray")
        default:
            image = UIImage(named: "ic_marker_green")
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
        case .vehicleExpired:
            image = UIImage(named: "ic_marker_gray")
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
    var isAllLocked: Bool = false
    
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
    @IBOutlet var expiredPopup: UIView!
    @IBOutlet var expiredLabel: UILabel!
    
    
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
        var Status: String?
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
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.alpha = 0
        // Delegates of the search bar
        searchBar.delegate = self
        // SearchBar placeholder
        searchBar.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search_Bar_Placeholder", comment: "search_Bar_Placeholder"), attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "grayBackground")!])
        // Hide the compass of the map
        mapView.showsCompass = false
        // The keyboard hides when tapped around
        hideKeyboardWhenTappedAround()
        // Hide the layout components (table, blue background, logo) before doing anything else
        tableView.alpha = 0
        blueBackground.alpha = 0
        spotLogoImage.alpha = 0
        blueInformationBackground.alpha = 0
        expiredPopup.alpha = 0
        // User device version of the app
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        userVersion = nsObject as? String
        // OnChange Search Bar
        searchBar.addTarget(self, action: Selector(("textFieldDidChange:")), for: UIControl.Event.editingChanged)
        // Add property touch map when user taps the map
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchMap(_:)))
        mapView.addGestureRecognizer(tap)

        // ==== Entry point *** Start of the main process *** ===== //
        checkUserVersion()
        
    }

    // To access through a push notification
    class func instantiate() -> MapViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(MapViewController.self)") as! MapViewController
        
        return viewController
    }
    
    //** iOS 13 dark mode **//
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       
           print("===== Cambio Dark/Light Mode =====")
           // Trait collection has already changed
           if #available(iOS 13.0, *) {
            
            DispatchQueue.main.async {
                self.hideAllComponents()
                self.isAllHidden = true
                self.searchBar.isHidden = false
            }
            
            
           } else {
               // Fallback on earlier versions
           }
    }
    
    // Check the user version
    func checkUserVersion(){
        
        let loginString = NSString(format: "%@:%@", user, pass)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        
        let jsonUrlRequest = "https://rastreo.resser.com/api/login?code=4&OS=2"
        let url = URL(string: jsonUrlRequest)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let Session = URLSession.shared
        Session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    // Set the dictionary with the data
                    let login = try JSONDecoder().decode(Login.self, from: data)
                    
                    // Check user version
                    
                    
                    var lastUpdate: Bool = true // If the user have the last update
                    let versionInGet = login.items.Version?.components(separatedBy: ".") // 2.0.0 -> Version in petition
                    let userVersionDevice = self.userVersion.components(separatedBy: ".") // 3.0.0 -> Version in device
                    
                    print("Current version in data base \(versionInGet)")
                    print("Current version in device \(userVersionDevice)")
                    
                    let firstGet = Int(versionInGet?[0] ?? "3")
                    let firstDevice = Int(userVersionDevice[0])
                    
                    let secondGet = Int(versionInGet?[1] ?? "0")
                    let secondDevice = Int(userVersionDevice[1])
                    
                    let thirdGet = Int(versionInGet?[2] ?? "0")
                    let thirdDevice = Int(userVersionDevice[2])
                    
                    // Compare the first
                    if(firstGet! < firstDevice!){
                        
                        lastUpdate = true
                        
                    } else if (firstGet! == firstDevice!){
                        
                        // Compare the second
                        if( (secondGet ?? 0) < (secondDevice ?? 0) ){
                            
                            lastUpdate = true
                            
                        } else if((secondGet ?? 0) == (secondDevice ?? 0)){
                            
                            // Compare the third
                            if((thirdGet ?? 0) < (thirdDevice ?? 0)){
                                lastUpdate = true
                            } else if((thirdGet ?? 0) == (thirdDevice ?? 0)){
                                lastUpdate = true
                            } else {
                                lastUpdate = false
                            }
                            
                        } else {
                            
                            lastUpdate = false
                            
                        }
                        
                    } else {
                        
                        lastUpdate = false
                        
                    }
                    
                    // The user doesn't have the last update
                    if(!lastUpdate){
                        
                        DispatchQueue.main.async{
                            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                self.mapView.alpha = 1
                            })
                            
                            // Go to AppStore (Force update)
                            let refreshAlert = UIAlertController(title: NSLocalizedString("update_title", comment: "update_title"), message: NSLocalizedString("update_body", comment: "update_body"), preferredStyle: UIAlertController.Style.alert)
                            
                            refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("update_AppStore_Button", comment: "update_AppStore_Button"), style: .default, handler: { (action: UIAlertAction!) in
                                guard let url = URL(string: "itms-apps://itunes.apple.com/us/app/resser-spot/id1054244668?l=es&ls=1&mt=8") else { return }
                                UIApplication.shared.openURL(url)
                                
                            }))
                            
                            self.present(refreshAlert, animated: true, completion: nil)
                        }
                        
                        
                    // The user is up to date
                    } else {
                        
                        DispatchQueue.main.async{
                            // get all the vehicles
                            self.getAllVehicles()
                        }
                       
                    }
                    
                    
                } catch {
                    
                    self.onError() // Invalid credentials
                    
                }
            }
            }.resume()
        
    }
    
    // start timer of the loading bar
    func startTimer(){
         DispatchQueue.main.async {
            
            // invalidate the timer from the loading bar
            self.timer2.invalidate()
            // Don't stop the timer flag
            self.stopTimerProgress = false
            // Don't hide the progress bar yet
            self.progressBar.isHidden = false
            
            /*
                UPDATE ANIMATION OF THE PROGRESS BAR
            */
            
             // If it's the first time loading, make faster the loading of the progress bar
            if( !self.FirstTimeTimerEntryPoint ){
                self.progressBar.progress = 0.3
            } else {
                self.progressBar.progress = 0
            }
            
            // Restart the timer and make the process again
            self.timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MapViewController.update), userInfo: nil, repeats: true)
            
        }
    }
    
    // Get the information and positions from all the vehicles
    @objc func getAllVehicles(){

        // Start the progress bar
        startTimer()
        
        // Check internet connection
        if CheckInternet.Connection(){
            
            let url : NSString  = "https://rastreo.resser.com/api/lastpositionmobile" as NSString
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            var request = URLRequest(url: searchURL as URL)
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            
            // Request
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let Session = URLSession.shared
            Session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        // Set the dictionary with the data
                        let vehicles = try JSONDecoder().decode(MapInfo.self, from: data)
                        
                        DispatchQueue.main.async {

                            // Remove last markers and annotiations (Clean the map)
                            let annotationsToRemove = self.mapView.annotations
                            self.mapView.removeAnnotations(annotationsToRemove)
                            let overlaysToRemove = self.mapView.overlays
                            self.mapView.removeOverlays(overlaysToRemove)
                            
                            // Empty the arrays to the new information
                            self.arrayVehicleLongitude.removeAll()
                            self.arrayVehicleLatitude.removeAll()
                            self.arrayVehicleId.removeAll()
                            self.arrayVehicleName.removeAll()
                            self.arrayVehicleStatus.removeAll()
                            self.arrayOfVehiclesNull.removeAll()
                            
                            // Set each vehicle information and marker into the map
                            for item in vehicles.items{
                                
                                // If the values of the latitude and longitude are not nil, then add it to the map
                                if( item.Longitude != nil && item.Latitude != nil ){
                                    
                                    // Last Time Report
                                    let dateStr = item.DateTime ?? "2019-11-11T20:13:54.96"
                                    var DateTime : Date = Date() // "2015-05-12T20:13:54.96"
                                    let dateFormatter = DateFormatter()
                                    var dateStringProcessed = dateStr.replacingOccurrences(of: "T", with: " ")
                                    let range = dateStringProcessed.range(of: ".")
                                    
                                    if range != nil {
                                        
                                        dateStringProcessed = dateStringProcessed.substring(to: range!.lowerBound)
                                        
                                    }
                                    
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                    dateFormatter.locale = Locale(identifier: "us")
                                    dateStringProcessed += " "+NSTimeZone.local.abbreviation()!
                                    
                                    var diffInDays = Int()
                                    
                                    if let date : Date = dateFormatter.date(from: dateStringProcessed){
                                        
                                        DateTime = date
                                        DateTime = DateTime.addingTimeInterval((TimeInterval)(NSTimeZone.local.secondsFromGMT()))
                                        
                                        diffInDays = Calendar.current.dateComponents([.day], from: date, to: Date()).day!
                                    }
                                    
                                    let lat = item.Latitude ?? 0.0
                                    let lng = item.Longitude ?? 0.0
                                    let orientation = item.Orientation ?? 0
                                    let id = item.VehicleId ?? 0
                                    let type: StatusType
                                    let name = item.Description ?? ""
                                    
                                    

                                    // Vehicle status
                                    if( item.Status == "En movimiento" ){
                                        
                                        type = StatusType.vehicleMove
                                        
                                    } else if ( item.Status == "Encendido sin movimiento" ){
                                        
                                        type = StatusType.vehicleOn
                                        
                                    } else if( item.Status == "Expirado"){
                                        
                                        type = StatusType.vehicleExpired
                                        
                                    } else {
                                        
                                        type = StatusType.vehicleOff
                                        
                                    }
                                    
                                    // Append in the arrays to get info
                                    self.arrayVehicleId.append(id)
                                    self.arrayVehicleName.append(name)
                                    self.arrayVehicleLatitude.append(lat)
                                    self.arrayVehicleLongitude.append(lng)
                                    self.arrayVehicleStatus.append(type)
                                    
                                    // Location of the vehicle
                                    let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
                                    
                                    // Pin of the map
                                    let pin = VehicleAnnotation(coordinate: location, title: String(id), subtitle: "", type: type , vehicleId: id, orientation: Float(orientation)) as MKAnnotation?
                                    
                                    /*
                                        ADD THE MARKER INTO THE MAP
                                     */
        
                                    self.mapView.addAnnotation(pin!)
                                    self.mapView.delegate = self
                                    
                                    if( diffInDays > 2 ){
                                       self.arrayOfVehiclesNull.append(item.VehicleId ?? 0)
                                    }
                                    
                               
                                } else {
                                    
                                    // If the vehicle is not reporting (latitude or longitude are null) then add it to the null vehicles array
                                    self.arrayOfVehiclesNull.append(item.VehicleId ?? 0)
                                    
                                }
                                
                            }
                            
                           
                            
                          
                            // Show the alert of the null vehicles only the first time loading the map
                            if( self.FirstTimeEntryPoint && self.arrayOfVehiclesNull.count > 0 ){
                                
                                // The default last date isnt saved
                                if(UserDefaults.standard.object(forKey: "lastDateNullVehiclesReport") == nil){
                                    
                                     print("NO EXISTE LA ÚLTIMA FECHA DE REPORTE DE ROJOS POR LO TANTO SE MUESTRA")
                                     self.presentVehicleNullAlert()
                                    
                                                              
                                } else {
                                    
                                   print("LA FECHA DE REPORTE DE ROJOS NO ES NULA")
                                    
                                   var diffInDays = Int()
                                   if(UserDefaults.standard.object(forKey: "lastDateNullVehiclesReport") != nil){
                                   let currentDate = Date()
                                   let dateFormatter = DateFormatter()
                                   let userCalendar = Calendar.current
                                   let requestedComponent: Set<Calendar.Component> = [.month,.day,.hour,.minute,.second]
                                   dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                                   let startTime = UserDefaults.standard.object(forKey: "lastDateNullVehiclesReport") as! Date
                                   let endTime = Date()
                                    //let endTime = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                                    let timeDifference = userCalendar.dateComponents(requestedComponent, from: startTime , to: endTime)
                                    print(endTime)
                                    
                                    print("DIFERENCIA DE DÍAS REPORTE DE ROJOS: \(timeDifference.day!) días")
                                    if(timeDifference.day! >= 30){
                                        self.presentVehicleNullAlert()
                                    }

                                       print(timeDifference.day!)
                                   }
                                    
                                }
    
                               

                            }
                            

                            // THE USER ENTERS THROUGH A NOTIFICATION (BY VEHICLE ID)
                            if( NotificationInfo.vehicleId != 0 ){
                              
                                    var i: Int = 0 // loop control
                                    var idFound: Bool = false // to verify if the vehicleId was found
                                    
                                    // Search into the array of the id vehicles
                                    for id in self.arrayVehicleId{
        
                                        // Match vehicle id of the notification
                                        if( NotificationInfo.vehicleId == id && !idFound ){
                                            
                                            print("Entra desde una push notification con id: \(id)")
                                            
                                            // Set vehicle Info
                                            self.setCurrentVehicleInfo(id: id)
                                            // Function to center the map into the current vehicle position
                                            self.centerMap(lat: self.arrayVehicleLatitude[i], lng: self.arrayVehicleLongitude[i])
                                            // Flag controls
                                            self.vehicleWasTapped = true

                                            DispatchQueue.main.async {
                                                // Save the UI components position
                                                self.saveUIComponentsPosition()
                                                // Hide table
                                                self.tableView.frame.origin = CGPoint(x: self.tableViewX, y: self.tableViewY - 1000)
                                                // Show after fit all the vehicles into the map
                                                self.tableView.alpha = 1
                                                self.blueBackground.alpha = 1
                                                self.spotLogoImage.alpha = 1
                                                self.blueInformationBackground.alpha = 1
                                            }
                                            
                                            idFound = true
                                            NotificationInfo.vehicleId = 0 // Set zero
                                        }

                                        i += 1
                                    }
                                
                                // Doesn't found a coincidence, set all normally
                                if(!idFound){
                                    NotificationInfo.vehicleId = 0 // Set zero
                                    self.getAllVehicles()
                                }
                                
                            // THE USER ENTERS NORMALLY
                            } else {
                                
                                // FIRST TIME ENTRY
                                if( self.FirstTimeEntryPoint ){
                                    
                                    // LOOP to get all vehicles position and set into the map
                                    var timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector(("getAllVehicles")), userInfo: nil, repeats: true)
                                    
                                    // Center the map on ALL the vehicles
                                    self.mapView.fitAll()
                                    
                                    UIView.animate(withDuration: 0.7, animations: { () -> Void in
                                        self.mapView.alpha = 1
                                    })
                                    
                                    // First time false flags
                                    self.FirstTimeEntryPoint = false
                                    self.FirstTimeTimerEntryPoint = false
                                    
                                    
                                    DispatchQueue.main.async {
                                        
                                        // Save the UI components position
                                        self.saveUIComponentsPosition()
                                        
                                        // Hide all
                                        self.hideAllComponents()
                                        
                                        // Show after fit all the vehicles into the map
                                        self.tableView.alpha = 1
                                        self.blueBackground.alpha = 1
                                        self.spotLogoImage.alpha = 1
                                        self.blueInformationBackground.alpha = 1
                                        
                                        self.isAllHidden = true
                                        self.performSegue(withIdentifier: "toGuardModeAlert", sender: self)
                                    }
                                    
                                    
                                    
                                } else {
                                    
                                    
                                    // If a vehicle was tapped, then get the position and information about it
                                    if( self.vehicleWasTapped && !self.isAllLocked ){
                                        
                                        self.setCurrentVehicleInfo(id: CurrentVehicleInfo.VehicleId)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            // Stop the timer (Before doing anything else)
                            self.stopTimerProgress = true
                            self.tableView.reloadData()
                        }
                        
                    // Error on get
                    } catch {
                        
                        print("Error on getAllVehicles Map: ")
                        print(error)
                        
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                        // Stop the timer
                        self.stopTimerProgress = true
                    }
                }
                
                }.resume()
            
        // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
        }
    }
    
    // Save the components position in the UI to manipulate it later (Move it or animate it)
    func saveUIComponentsPosition(){
        
            self.buttonPositionX = self.principalButton.frame.origin.x
            self.buttonPositionY = self.principalButton.frame.origin.y
            
            self.bottomViewX = self.blueInformationBackground.frame.origin.x
            self.bottomViewY = self.blueInformationBackground.frame.origin.y
            
            self.blueTopViewX = self.blueBackground.frame.origin.x
            self.blueTopViewY = self.blueBackground.frame.origin.y
            
            self.spotLogoX = self.spotLogoImage.frame.origin.x
            self.spotLogoY = self.spotLogoImage.frame.origin.y
            
            self.tableViewX = self.tableView.frame.origin.x
            self.tableViewY = self.tableView.frame.origin.y
        
    }
    
    // Hide all the components in the layout when the user touches the map
    func hideAllComponents(){
        self.principalButton.frame.origin = CGPoint( x: self.buttonPositionX, y: self.buttonPositionY + 110)
        self.blueInformationBackground.frame.origin = CGPoint(x: self.bottomViewX, y: self.bottomViewY + 1000)
        self.blueBackground.frame.origin = CGPoint(x: self.blueTopViewX, y: self.blueTopViewY - 1000)
        self.spotLogoImage.frame.origin = CGPoint(x: self.spotLogoX, y: self.spotLogoY - 1000)
        self.tableView.frame.origin = CGPoint(x: self.tableViewX, y: self.tableViewY  - 1000)
    }
    
    // Clear the global information, when user touches the map
    func clearGlobalInformation(){
        // Set Global Info
        CurrentVehicleInfo.VehicleId = 0
        CurrentVehicleInfo.VehicleName = ""
        CurrentVehicleInfo.Latitude = 0.0
        CurrentVehicleInfo.Longitude = 0.0
        CurrentVehicleInfo.VehiclePosition = ""
        CurrentVehicleInfo.Notifications = false
        CurrentVehicleInfo.Max_Speed = 0
        CurrentVehicleInfo.Email = ""
        CurrentVehicleInfo.Valet = false
        CurrentVehicleInfo.HasEmail = false
        CurrentVehicleInfo.NotificationType = 0
        CurrentVehicleInfo.HasPush = false
    }
    
    @objc func touchMap(_ sender: UITapGestureRecognizer){
           
           DispatchQueue.main.async {
            
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                   self.expiredPopup.alpha = 0
                })
                
                // Disable lock flag
                self.isAllLocked = false
                // Resign the responder of the textfield
                self.searchBar.resignFirstResponder()
                // Flag to know if a vehicle was tapped
                self.vehicleWasTapped = false
                // Move the loading bar
                self.progressBar.frame.origin = CGPoint(x: 26, y: 25)
                // Set button icon
                self.principalButton.setImage(UIImage(named: "cog_icon_menu"), for: .normal)
            
                // If the user tap repeteadly the map, only the first time hide all the UI components
                if(!self.isAllHidden){
                    UIView.animate(withDuration: 0.5, animations: {
                        self.hideAllComponents()
                        self.searchBar.isHidden = false
                   })
                    
                    // Flag to know if all is hidden
                    self.isAllHidden = true
                }
               
               // The table is not hidden, then hide it
               if( self.tableView.frame.origin.x != (self.tableViewX - 1000) ){
                   DispatchQueue.main.async {
                       UIView.animate(withDuration: 0.5, animations: {
                           self.tableView.frame.origin = CGPoint(x: self.tableViewX, y: self.tableViewY  - 1000)
                       })
                   }
               }
               
                // There is not vehicle selected, the erase all the information
                self.clearGlobalInformation()
           }
   }
    
    // Null vehicles alert
    func presentVehicleNullAlert() {

        DispatchQueue.main.async {
            let message = "\(NSLocalizedString("map_AlertNull_title1", comment: "map_AlertNull_title1")) \(self.arrayOfVehiclesNull.count) \(NSLocalizedString("map_AlertNull_title2", comment: "map_AlertNull_title2")) \n\n \(NSLocalizedString("map_AlertNull_title3", comment: "map_AlertNull_title3"))"
            
            let newAlert = UIAlertController(title: NSLocalizedString("map_AlertNull_title", comment: "map_AlertNull_title"), message: message, preferredStyle: UIAlertController.Style.alert)
         
            //** Request Support **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("map_AlertNull_Option1", comment: "map_AlertNull_Option1"), style: .destructive, handler: { (action: UIAlertAction!) in
                
                //** Request support proccess **//
                self.sendVehiclesNullReport()
                newAlert.dismiss(animated: true, completion: nil)
            }))
            
            //** Agree **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("map_AlertNull_Option2", comment: "map_AlertNull_Option2"), style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            newAlert.view.tintColor = UIColor(named: "spotGreen")
            
            self.present(newAlert, animated: true, completion: nil)
        }
    }
    
    //** Send Null Vehicles Report **//
    func sendVehiclesNullReport() {
        
        if(UserDefaults.standard.object(forKey: "lastDateNullVehiclesReport") == nil){
            
            print("NO EXISTE LA ÚLTIMA FECHA DE REPORTE DE ROJOS POR LO TANTO SE GUARDA")
            //save as Date
            UserDefaults.standard.set(Date(), forKey: "lastDateNullVehiclesReport")

            //read
            let date = UserDefaults.standard.object(forKey: "lastDateNullVehiclesReport") as! Date
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy HH:mm"
            
            print("LA FECHA ES:")
            print(df.string(from: date))
                                      
        } else {
            
            print("YA EXISTE FECHA GUARDADA DE REPORTE DE ROJOS, SE ACTUALIZA")
            //save as Date
            UserDefaults.standard.set(Date(), forKey: "lastDateNullVehiclesReport")

            //read
            let date = UserDefaults.standard.object(forKey: "lastDateNullVehiclesReport") as! Date
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy HH:mm"
            
            print("LA FECHA ES:")
            print(df.string(from: date))
            
        }
        
        
        
        // Make the string to report the vehicles id Ex. vehicles=19457,19461,19441
        var StringOfVehicles: String = ""
        var i: Int = 0
        for vehicle in arrayOfVehiclesNull{
            if(i == 0){
                StringOfVehicles += "\(vehicle)"
            } else {
                StringOfVehicles += ",\(vehicle)"
            }
            i += 1
        }
        
        
        // Check internet connection
        if CheckInternet.Connection(){
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/VehiclesReportMobile?vehicles=\(StringOfVehicles)" as NSString
            
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            var request = URLRequest(url: searchURL as URL)
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            
            // Request
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let Session = URLSession.shared
            Session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                       self.Alert(Title: NSLocalizedString("map_AlertReportNull_Title", comment: "map_AlertReportNull_Title"), Message: NSLocalizedString("map_AlertReportNull_Message", comment: "map_AlertReportNull_Message"))
                        // Error on get
                    } catch {
                        
                        print("Error on getConfigurationsInfo: ")
                        print(error)
                        
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }

    // Update the progress bar
    @objc func update(){
        // The timer is stopped
        if(stopTimerProgress){
            progressBar.isHidden = true
            timer2.invalidate()
        // Restart the timer
        } else if( progressBar.progress == 1 && !stopTimerProgress ){
            startTimer()
        // Add progress
        } else {
            if( FirstTimeTimerEntryPoint ){
                progressBar.progress += 0.01
            } else {
                progressBar.progress += 0.1
            }
        }
    }

    //** Search Bar INTRO event **//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        // Text in the search bar
        let vehicleSearched = searchBar.text!
        // Flag to know if the vehicle match
        var vehicleFound: Bool = false
        // Array of coincidences between textfield text and vehicle name array
        let arrayOfCoincidence = arrayVehicleName.filter({$0.lowercased().contains(vehicleSearched.lowercased())})
        
        
        if(arrayOfCoincidence.count != 0){
            var i: Int = 0
            for name in arrayVehicleName{
                if(arrayOfCoincidence[0] == name && !vehicleFound){
                    setCurrentVehicleInfo(id: arrayVehicleId[i]) // Set vehicle matched info
                    vehicleFound = true // vehicle matched flag
                }
                i += 1
            }
        }
        
        searchBar.resignFirstResponder()

        if(!vehicleFound){
            Alert(Title: "Oops!", Message: NSLocalizedString("map_Menu_AlertSearch", comment: "map_Menu_AlertSearch"))
        }

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.frame.origin = CGPoint(x: self.tableViewX, y: self.tableViewY  - 1000)
            })
        }
        
        searchBar.text = ""
        return true
    }
    
    // ** The user tap the searchBar **//
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin = CGPoint(x: self.tableViewX, y: self.tableViewY )
            })
        }
    }
    
    // onChange SearchBar
    @objc func textFieldDidChange(_ textField: UITextField) {
        arrayCoincidences.removeAll()
        let vehicleSearched = searchBar.text!
        
        arrayCoincidences = arrayVehicleName.filter({$0.lowercased().contains(vehicleSearched.lowercased())})
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // center the map in some position
    func centerMap( lat: Float, lng: Float ){
        DispatchQueue.main.async {
            
            let regionRadius: CLLocationDistance = 1000
            let initialLocation = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
            let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    // Return a markerView to could know which one was tapped
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // AnnotationView Object
        let markerView = VehicleAnnotationView(annotation: annotation, reuseIdentifier: annotation.title ?? "no value")
        markerView.canShowCallout = false
        // Repaint marker
        let aView = markerView
        aView.repaint(self.currentZoomFactor)
        

        return markerView
    }
    
    // function returns current zoom of the map
    func getZoom(_ mapView: MKMapView) -> Double {
        
        var angleCamera = mapView.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180 // camera heading in radians
        let width = Double(mapView.frame.size.width)
        let height = Double(mapView.frame.size.height)
        let heightOffset : Double = 20 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
        // calculating Longitude span corresponding to normal (non-rotated) width
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1;
    }
    
    //MARK: Tells the delegate when the zooms change.
    func mapView( _ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        currentMapRegion = mapView.region;
        
    }
    
    //MARK: Tells the delegate when the zooms change.
    func mapView( _ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        var newRegion: MKCoordinateRegion = mapView.region
        var zFactor: NSInteger
        
        currentZoomFactor = getZoom(mapView)
        zoomLevel = currentZoomFactor
        var aO: VehicleAnnotation
        for aO in mapView.annotations {
            let aView = mapView.view(for: aO) as! VehicleAnnotationView?
            if(aView != nil)
            {
                aView!.repaint(currentZoomFactor)
            }
        }
        
    }
    
    // Vehicle tapped event
    func mapView( _ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        DispatchQueue.main.async {
            let idVehicleTapped = view.reuseIdentifier ?? "0000" //VehicleId tapped on String
            let idVehicleToInt = Int(idVehicleTapped) ?? 0 //VehicleId tapped on Id
            self.vehicleWasTapped = true
           
            
            var vehicleFound: Bool = false
            var i: Int = 0
            for id in self.arrayVehicleId{
                if( id == idVehicleToInt && !vehicleFound){
                    // Function to center the map into the vehicle position
                    self.centerMap(lat: self.arrayVehicleLatitude[i], lng: self.arrayVehicleLongitude[i])
                    
                    //CHECK IF THE CAR IS EXPIRED
                    if(self.arrayVehicleStatus[i] == StatusType.vehicleExpired){
                        self.isAllLocked = true
                        self.expiredLabel.text = self.arrayVehicleName[i]
                        print(self.arrayVehicleName)
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.expiredPopup.alpha = 1
                        })
                    } else {
                        self.setCurrentVehicleInfo(id: idVehicleToInt)
                    }
                    
                    vehicleFound = true
                }
                i += 1
            }
        }
    }
    
    
    
    /*
     * When a vehicle is tapped, set the current info to display
     * Like: Address, Id, Name, Location (Lat, Lng)
     */
    func setCurrentVehicleInfo(id: Int){
        print("ENTRA SET CURRENT")
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/vehiclesmobile?VehicleId=\(id)" as NSString
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            var request = URLRequest(url: searchURL as URL)
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            
            // Request
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let Session = URLSession.shared
            Session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        
                        // Stop the timer (Before doing anything else)
                        self.stopTimerProgress = true
                        
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
    
                        // Set the dictionary with the data
                        let vehicleInfo = try JSONDecoder().decode(SpecificVehicleInfo.self, from: data)

                        // Set vehicle tapped Info
                        DispatchQueue.main.async {
                            
                            var i = 0
                            var handlerSince: String = ""
                            var handlerSpeed: Float = 0.0
                            
                            for idInThisArray in self.arrayVehicleId{
                                if (id == idInThisArray){
                                    
                                    CurrentVehicleInfo.Latitude = self.arrayVehicleLatitude[i]
                                    CurrentVehicleInfo.Longitude = self.arrayVehicleLongitude[i]
                                    CurrentVehicleInfo.VehicleName = self.arrayVehicleName[i]
                                    CurrentVehicleInfo.VehicleId = self.arrayVehicleId[i]
                                    
                                    // APPLE WATCH
                                    
                                    UserDefaults.standard.set(self.arrayVehicleId[i], forKey: "VehicleId")
                                    UserDefaults.standard.set(self.arrayVehicleName[i], forKey: "VehicleName")
                                    UserDefaults.standard.synchronize()
                                    
                                    
                                    for item in vehicleInfo.items {
                                        // Current Address
                                        CurrentVehicleInfo.VehiclePosition = item.Address ?? "N/A"
                                        // Plates
                                        CurrentVehicleInfo.LicensePlate = item.LicensePlate ?? ""
                                        // Speed
                                        handlerSpeed = item.Speed
                                        // Last Time Report
                                        let dateStr = item.LastReport
                                        
                                        var DateTime : Date = Date() // "2015-05-12T20:13:54.96"
                                        let dateFormatter = DateFormatter()
                                        var dateStringProcessed = dateStr.replacingOccurrences(of: "T", with: " ")
                                        let range = dateStringProcessed.range(of: ".")
                                        
                                        if range != nil {
                                            
                                            dateStringProcessed = dateStringProcessed.substring(to: range!.lowerBound)
                                            
                                        }
                                        
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                                        dateFormatter.locale = Locale(identifier: "us")
                                        dateStringProcessed += " " + NSTimeZone.local.abbreviation()!
                                        
                                        if let date : Date = dateFormatter.date(from: dateStringProcessed){
                                            
                                            DateTime = date
                                            DateTime = DateTime.addingTimeInterval((TimeInterval)(NSTimeZone.local.secondsFromGMT()))
                                            
                                            handlerSince = ResserDateTime.timeAgoString(DateTime)
                                        }
                                    }
                                }
                                i = i + 1
                            }
                            
                            self.vehicleNameLabel.text = CurrentVehicleInfo.VehicleName // Set vehicle name
                            
                            let vehicleInformationString = "\(CurrentVehicleInfo.VehiclePosition) " + "\(handlerSince)" + " - \(handlerSpeed) km/h"
                            
                         
                            self.vehiclePositionLabel.text = vehicleInformationString// Set vehicle current address, last report and speed
                            
                            self.searchBar.isHidden = true
                            self.principalButton.setImage(UIImage(named: "menu_icon"), for: .normal)
                            
                            if(self.isAllHidden){
                                
                                UIView.animate(withDuration: 0.5, animations: {
                                    
                                    self.progressBar.frame.origin = CGPoint(x: 26, y: 126) // 25 - 126
                                    self.principalButton.frame.origin = CGPoint( x: self.buttonPositionX, y: self.buttonPositionY)
                                    self.blueInformationBackground.frame.origin = CGPoint(x: self.bottomViewX, y: self.bottomViewY)
                                    self.blueBackground.frame.origin = CGPoint(x: self.blueTopViewX, y: self.blueTopViewY)
                                    self.spotLogoImage.frame.origin = CGPoint(x: self.spotLogoX, y: self.spotLogoY)
                                })
                                
                                self.isAllHidden = false
                            }
                            
                            
                            self.getCurrentVehicleGlobalInfo()
                            
                        }
                        
                    // Error on get
                    } catch {
                        
                        // Stop the timer (Before doing anything else)
                        self.stopTimerProgress = true
                        
                        print("Error on setCurrentVehicleInfo: ")
                        print(error)
                        
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                    }
                }
                
                }.resume()
            
        // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
        

    }
    
    // Set global info of that vehicle
    func getCurrentVehicleGlobalInfo(){

        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            //vehiclesmobile?VehcileId=
            let url : NSString  = "https://rastreo.resser.com/api/alertsmobile?id=\(CurrentVehicleInfo.VehicleId)" as NSString
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            var request = URLRequest(url: searchURL as URL)
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            
            // Request
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let Session = URLSession.shared
            Session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                       
                        
                        //Set the dictionary with the data
                        let vehicleInfo = try JSONDecoder().decode(vehicleGlobal.self, from: data)
                        
                        DispatchQueue.main.async {
                            // Set Global Info
                            CurrentVehicleInfo.Notifications = vehicleInfo.items?.Notifications ?? false
                            CurrentVehicleInfo.Max_Speed = vehicleInfo.items?.Max_Speed ?? 0
                            CurrentVehicleInfo.Email = vehicleInfo.items?.Email ?? ""
                            CurrentVehicleInfo.Valet = vehicleInfo.items?.Valet ?? false
                            CurrentVehicleInfo.HasEmail = vehicleInfo.items?.HasEmail ?? false
                            CurrentVehicleInfo.NotificationType = vehicleInfo.items?.NotificationType ?? 0
                            CurrentVehicleInfo.HasPush = vehicleInfo.items?.HasPush ?? false
                        }
                        
                        
                        // Error on get
                    } catch {
                        
                        print("Error on getCurrentVehicleGlobalInfo: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    // Present invalid credentials
    func onError(){
        DispatchQueue.main.async {
            self.Alert(Title: "Error", Message: NSLocalizedString("login_error_message", comment: "login_error_message"))
        }
    }
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Main button pressed
    @IBAction func onPrincipalButtonPress(_ sender: Any) {
        
        if( isAllHidden ){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLogout", sender: self)
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toOptions", sender: self)
            }
        }
        
    }
    
    func onDismiss(){
        dismiss(animated: true)
    }
    
    @IBAction func onRenewVehicle(_ sender: Any) {
        if #available(iOS 9.0, *) {
               let safariVC = SFSafariViewController(url: NSURL(string: "https://spot.resser.com/admin/suscriptions")! as URL)
               self.present(safariVC, animated: true, completion: nil)
           } else {
               // Fallback on earlier versions
               UIApplication.shared.openURL(URL(string: "https://spot.resser.com/admin/suscriptions")!)
           }
    }
    
    
}


// Controllers of MapKit
extension MKMapView {
    
    /// When we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 70.0, left: 70.0, bottom: 50.0, right: 50.0), animated: false)
    }
    
    /// We call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
        
        for annotation in annotations {
            let aPoint = MKMapPoint(annotation.coordinate)
            let rect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
            
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 20.0, left: 20.0, bottom:  20.0, right:  20.0), animated: false)
    }
    
}

// ** Searchbar Table View **//
extension MapViewController: UITableViewDataSource{
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchBar.text! == ""){
            return arrayVehicleName.count // Number of vehicles
        } else {
            return arrayCoincidences.count
        }
        
    }
    
    // Rows Information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(searchBar.text! == ""){
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "searchBarItem", for: indexPath) as! searchBarItem
            cell.vehicleInSearchBarLabel.text = arrayVehicleName[indexPath.row]
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "searchBarItem", for: indexPath) as! searchBarItem
            cell.vehicleInSearchBarLabel.text = arrayCoincidences[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
    
    }
    
    // Height of rows
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Can edit rows
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Row tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(searchBar.text! == ""){
            let rowSelected: Int = indexPath.row
            setCurrentVehicleInfo(id: arrayVehicleId[rowSelected])
            // Function to center the map into the vehicle position
            self.centerMap(lat: self.arrayVehicleLatitude[rowSelected], lng: self.arrayVehicleLongitude[rowSelected])
        } else {
            
            let rowSelected: Int = indexPath.row
            let vehicleSelected = arrayCoincidences[rowSelected]
            
            var i: Int = 0
            var vehicleFound: Bool = false
            for name in arrayVehicleName{
                
                if(name == vehicleSelected && !vehicleFound){
                    setCurrentVehicleInfo(id: arrayVehicleId[i])
                    // Function to center the map into the vehicle position
                    self.centerMap(lat: self.arrayVehicleLatitude[i], lng: self.arrayVehicleLongitude[i])
                    vehicleFound = true
                }
                
                i += 1
            }
            
        }
        
        
        DispatchQueue.main.async {
            self.searchBar.text! = ""
            self.searchBar.resignFirstResponder()
            // The table is not Hidden
            if( self.tableView.frame.origin.x != (self.tableViewX - 1000) ){
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.tableView.frame.origin = CGPoint(x: self.tableViewX, y: self.tableViewY  - 1000)
                    })
                }
            }
            
        }
        
        
    }
    
}
