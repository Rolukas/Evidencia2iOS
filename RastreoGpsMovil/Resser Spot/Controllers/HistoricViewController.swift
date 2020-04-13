//
//  launcherViewController.swift
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Hide Picker
        UIView.animate(withDuration: 0.5, animations: {
            self.datePicker.alpha = 0
            self.pickerView.alpha = 0
        })
        
        setTexts()
        
        // Max Date of picker (Min set in stroyboard)
        datePicker.maximumDate = Date()
        
        // White picker
        datePicker.setValue( UIColor.white , forKeyPath: "textColor")
        
        // Add value changed for picker
        datePicker.addTarget(self, action: #selector(HistoricViewController.pickerChanged), for: .valueChanged)
        
        // First date is current Date
        let formater = DateFormatter()
        formater.dateFormat = "dd-MM-yyyy"
        StringDate = formater.string(from: Date()) // String in "01-12-2019" format
        
        // Separate date
        let dateSeparated = StringDate.components(separatedBy: "-")
        year = dateSeparated[2]
        month = dateSeparated[1]
        day = dateSeparated[0]
        
        handleDay = dateSeparated[0]
        handleYear = dateSeparated[2]
        handleMonth = dateSeparated[1]
        
        // Current language
        let langStr: String = Locale.current.languageCode!
        
        // Months in english/spanish
        if( langStr == "en" ){
            months = ["","January","February","March","April","May","Jun","July","August","September","October","November","December"]
            dateLabel.text = "\(months[Int(month) ?? 1]) \(day), \(year)"
        } else {
            months = ["","Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
            dateLabel.text = "\(day) de \(months[Int(month) ?? 1]), \(year)"
        }
        
        // Green range slider
        rangeSlider.trackHighlightTintColor = UIColor(named: "polylineColor") ?? UIColor.green
        
        // Add the rangeSlider
        Footer.addSubview(rangeSlider)
        rangeSlider.lowerValue = 0.0
        rangeSlider.upperValue = 1.0
        
        // Set the initial values of the range slider
        highDateHours = 23
        highDateMinutes = 59
        lowDateHours = 0
        lowDateMinutes = 0
        
        firstHourLabel.text = "0:00"
        secondHourLabel.text = "24:00"
        
        // Add the function to execute on the change of picker
        rangeSlider.addTarget(self, action: #selector(HistoricViewController.rangeSliderValueChanged(_:)), for: .valueChanged)
        // Hours between current time zone and UTC
        let timeZoneOffsetHandler = ((Double(TimeZone.current.secondsFromGMT(for: Date())))/60)/60
        timeZoneOffset = Int(timeZoneOffsetHandler)
        
        
        // DarkMode iOS 13
        if #available(iOS 12.0, *) {
             
             // 1 -> Light mode, 2 -> Dark Mode
             
             DispatchQueue.main.async {
                 
                 if( self.traitCollection.userInterfaceStyle.rawValue == 1 ){
                    self.isDarkModeEnabled = false
                 } else {
                    self.isDarkModeEnabled = true
                 }

             }
                         
         }
        
        
        // Historics of this day
        GetHistorics(dayC: day, monthC: month, yearC: year)
        
        Analytics.logEvent("function_historic", parameters: nil)
    }
    
    //** iOS 13 dark mode **//
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        
          // Trait collection has already changed
          if #available(iOS 13.0, *) {
              
              DispatchQueue.main.async {
                  
                   // Light Mode
                   if( previousTraitCollection?.userInterfaceStyle == .dark ){
                      
                    self.isDarkModeEnabled = false
                      
                   // Dark Mode
                   } else {
                      
                    self.isDarkModeEnabled = true
                    
                   }
                
                // Reload polyline
                self.GetHistorics(dayC: self.day, monthC: self.month, yearC: self.year)

              }
              
          } else {
              // Fallback on earlier versions
          }
      }
    
    func setTexts(){
        odometerLabel.text = NSLocalizedString("historic_Label_Km", comment: "historic_Label_Km")
        maxSpeedLabel.text = NSLocalizedString("historic_Label_Vl", comment: "historic_Label_Vl")
        timeLabel.text = NSLocalizedString("historic_Time_LabelC", comment: "historic_Time_LabelC")
        cancelDatePickerButton.setTitle(NSLocalizedString("historic_Button_Cancel_Date", comment: "historic_Button_Cancel_Date"), for: .normal)
        saveDatePickerButton.setTitle(NSLocalizedString("historic_Button_Accept_Date", comment: "historic_Button_Accept_Date"), for: .normal)
    }
    
    // Value changed in the date picker
    @objc func pickerChanged(sender: UIDatePicker){
        
        //** Format of value **//
        let formater = DateFormatter()
        formater.dateFormat = "dd-MM-yyyy"
        
        // Save the Date selected - String in "01-12-2019" format
        StringDate = formater.string(from: sender.date)
        
        // only handle the date if the user doesn't want to show it
        let dateSeparated = StringDate.components(separatedBy: "-")
        handleDay = dateSeparated[0]
        handleMonth = dateSeparated[1]
        handleYear = dateSeparated[2]
    }
    
    // Tap on "Save Button" when the picker is showed
    @IBAction func onSaveDate(_ sender: Any) {
        day = handleDay
        month = handleMonth
        year = handleYear
        
        GetHistorics(dayC: day, monthC: month, yearC: year)
        
        // Hide Picker
        UIView.animate(withDuration: 0.5, animations: {
            self.datePicker.alpha = 0
            self.pickerView.alpha = 0
        })
    }
    
    // Add the layout the range slider
    override func viewDidLayoutSubviews() {
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        rangeSlider.frame = CGRect(x:55, y: 120, width: width * 0.7246, height: 25.0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function to execute when the slider change it value
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timerSlideDecide, target: self, selector: #selector(HistoricViewController.loadHistorics), userInfo: nil, repeats: false)
        setDateTimeWithSlider()
    }
    
    // Load historics when the slider changes
    @objc func loadHistorics(){
        timer.invalidate()
        self.GetHistorics(dayC: day, monthC: month, yearC: year)
    }
    
    func getZoom(_ mapView: MKMapView) -> Double {
        // function returns current zoom of the map
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
        
        var aO: HistoryAnnotation
        for aO in mapView.annotations {
            let aView = mapView.view(for: aO) as! HistoryAnnotationView?
            if(aView != nil)
            {
                if(isDarkModeEnabled){
                    aView!.repaintDarkMode(currentZoomFactor)
                } else {
                    aView!.repaint(currentZoomFactor)
                }
                
            }
        }
        
    }
    
    // get the history to create the polyline based in the hours and date selected
    func GetHistorics(dayC: String, monthC: String, yearC: String){
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        
        // Remove last markers
        let annotationsToRemove = self.mapView.annotations
        self.mapView.removeAnnotations(annotationsToRemove)
        let overlaysToRemove = self.mapView.overlays
        self.mapView.removeOverlays(overlaysToRemove)
        
        // Check internet connection
        if CheckInternet.Connection(){

            // Round to 23:59 when the max hour is 24:00 (Generates error with 24:00)
            if(highDateHours == 24 && highDateMinutes == 0){
                highDateHours = 23
                highDateMinutes = 59
            }
            
            // Check language for date format
            let langStr: String = Locale.current.languageCode!
            let monthInt: Int = Int(monthC) ?? 1 // Number of the month selected (1-12)
            // Change the date according to the date
            if( langStr == "en" ){
                dateLabel.text = "\(months[monthInt]) \(dayC), \(yearC)"
            } else {
                dateLabel.text = "\(dayC) de \(months[Int(monthC) ?? 1]), \(yearC)"
            }
            
            // Date with format "12-31-2019"
            let dateToCorrectString = "\(Int(monthC) ?? 1)-\(Int(dayC) ?? 1)-\(yearC)"
            
            // Get the vehicle positions to fill polyline
            let url : NSString  = "https://rastreo.resser.com/api/messages?vehicleId=\(CurrentVehicleInfo.VehicleId)&startDate=\(dateToCorrectString)%20\(lowDateHours)%3A\(lowDateMinutes)%20\(timeZoneOffset)&endDate=\(dateToCorrectString)%20\(highDateHours)%3A\(highDateMinutes)%20\(timeZoneOffset)&lite=true" as NSString

            
            let searchURL : NSURL = NSURL(string: url as String)!
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
                        
                        // Get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        // Array of new positions must be empty
                        self.ArrayOfPositions.removeAll()
                        
                        // Remove previous polyline
                        self.mapView.removeOverlays(self.mapView.overlays)
                        
                        // Set the dictionary with the data
                        let positions = try JSONDecoder().decode(Positions.self, from: data)
                        
                        // If has positions
                        if(positions.items.count != 0){
                            
                            // Make positions array (CLLocationCoordinate2D type) and make the annotation view
                            
                            var i: Int = 0 // Loop control
                            var vehicleOff: Bool = false // vehicle Off control
                            var lastCordOfVehicleOff = CLLocationCoordinate2D() // Handle coordinate when the vehicle is off
                            var speedLimit: Int = 0
                            var speedLimitCoords = CLLocationCoordinate2D() // Handle coordinate for maxSpeed
                            var speedLimitTime = String()
                            
                            for position in positions.items{
                                
                                // Position of current marker
                                let point = CLLocationCoordinate2D(latitude: CLLocationDegrees(position.la), longitude: CLLocationDegrees(position.lo))
                                // Position of last parking coordinate
                                var firstCoordinateParking = CLLocation(latitude: lastCordOfVehicleOff.latitude, longitude: lastCordOfVehicleOff.longitude)
                                var secondCoordinateParking = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                var distanceInMetersParking = firstCoordinateParking.distance(from: secondCoordinateParking) // result is in meters
                                
                                // First item (start point)
                                if( i == 0 ){
                                    
                                    DispatchQueue.main.async {
                                        self.AddIndicator(point, title: NSLocalizedString("historic_Info_Start_Interval", comment: "historic_Info_Start_Interval"), subtitle: NSLocalizedString("historic_Info_Start/End_Subtitle", comment: "historic_Info_Start/End_Subtitle") + " \(position.ti)", type: HistoryStatusType.first)
                                    }

                                // Last item (end point)
                                } else if( i == (positions.items.count - 1) )  {
                                    
                                    DispatchQueue.main.async {
                                        self.AddIndicator(point, title: NSLocalizedString("historic_Info_End_Interval", comment: "historic_Info_End_Interval"), subtitle: NSLocalizedString("historic_Info_Start/End_Subtitle", comment: "historic_Info_Start/End_Subtitle") + " \(position.ti)", type: HistoryStatusType.end)
                                    }
                                    
                                }

                                
                                // The vehicle was off, then start to handle the positions to find the last when the car was off (Parking generates of = 1)
                                if( position.of == 1 && vehicleOff == false && position.sp == 0 ){
                                    
                                    let strDate = "\(position.da)T\(position.ti)Z"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd'-'MM'-'yyyy'T'HH':'mm':'ssZ"
                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                  
                                    let date = dateFormatter.date(from: strDate)
                                    self.firstHour = date!
                                    
                                    vehicleOff = true // Vehicle off
                                    lastCordOfVehicleOff = point // Handle the last position of the vehicle off
                                    
                                }
                                
                                // When the status of the vehicle changes to on from off, set again the vehicleOff is false because it is moving
                                else if( position.of == 0 && vehicleOff == true && position.sp != 0 && distanceInMetersParking > 20){
                                    
                                    let strDate = "\(position.da)T\(position.ti)Z"
                                    let calendar = NSCalendar.current as NSCalendar
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd'-'MM'-'yyyy'T'HH':'mm':'ssZ"
                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                
                                    let date = dateFormatter.date(from: strDate)
                                    self.secondHour = date!
                                    
                                    let horas = NSCalendar.Unit.hour
                                    let minutos = NSCalendar.Unit.minute
                                    
                                    let componentsH = calendar.components(horas, from: self.firstHour!, to: self.secondHour!)
                                    let componentsM = calendar.components(minutos, from: self.firstHour!, to: self.secondHour!)
                                    
                                    let formatterFirstHour = DateFormatter()
                                    formatterFirstHour.dateStyle = DateFormatter.Style.none
                                    formatterFirstHour.timeStyle = DateFormatter.Style.short
                                    formatterFirstHour.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                    
                                    // Add Hours (Hour Error)
                                    var timeToAdd = (self.timeZoneOffset * -1) // Hours
                                    timeToAdd = timeToAdd * 60 // Minutes
                                    timeToAdd = timeToAdd * 60 // Seconds

                                    let firstHourString = formatterFirstHour.string(from: self.firstHour!.addingTimeInterval(TimeInterval(timeToAdd)))
                                    let secondHourString = formatterFirstHour.string(from: self.secondHour!)
                                    
                                    let hours = componentsH.hour!
                                    let hoursToMinutes = hours * 60
                                    let restantMinutes = componentsM.minute! - hoursToMinutes
                                    
                                    // Horas y minutos
                                    if( hours > 0 ){
                                        
                                        // Singular
                                        if(hours == 1){
                                            
                                            self.AddIndicator(
                                                lastCordOfVehicleOff,
                                                title:
                                                NSLocalizedString("historic_Info_VehicleOff_Title",
                                                                  comment: "historic_Info_VehicleOff_Title"),
                                                subtitle:
                                                    NSLocalizedString("Historic_info_VehicleOff_Subtitle", comment: "Historic_info_VehicleOff_Subtitle") + // Por
                                                    " \(hours)" + // 1
                                                    NSLocalizedString("historic_Info_VehicleOff_Hour_&", comment: "historic_Info_VehicleOff_Hour_&") + // Hora y
                                                    " \(restantMinutes)" +
                                                    NSLocalizedString("historic_Info_VehicleOff_Hour_Minutes", comment: "historic_Info_VehicleOff_Hour_Minutes") +
                                                    " \(firstHourString)",
                                                type: HistoryStatusType.parking
                                            )
                                            
                                        // Plural
                                        } else {
                                            
                                           self.AddIndicator(
                                               lastCordOfVehicleOff,
                                               title:
                                               NSLocalizedString("historic_Info_VehicleOff_Title",
                                                                 comment: "historic_Info_VehicleOff_Title"),
                                               subtitle:
                                                    NSLocalizedString("Historic_info_VehicleOff_Subtitle", comment: "Historic_info_VehicleOff_Subtitle") + // Por
                                                    " \(hours)" + // n
                                                    NSLocalizedString("historic_Info_VehicleOff_Hours_&", comment: "historic_Info_VehicleOff_Hours_&") + // Horas y
                                                    " \(restantMinutes)" +
                                                    NSLocalizedString("historic_Info_VehicleOff_Hour_Minutes", comment: "historic_Info_VehicleOff_Hour_Minutes") + // Minutos a las
                                                    " \(firstHourString)",
                                               type: HistoryStatusType.parking
                                           )
                                            
                                        }
                                        
                                    // Minutos
                                    } else {
                                        
                                        self.AddIndicator(
                                            lastCordOfVehicleOff,
                                            title:
                                            NSLocalizedString("historic_Info_VehicleOff_Title",
                                                              comment: "historic_Info_VehicleOff_Title"),
                                            subtitle:
                                                NSLocalizedString("Historic_info_VehicleOff_Subtitle", comment: "Historic_info_VehicleOff_Subtitle") + // Por
                                                " \(restantMinutes)" +
                                                NSLocalizedString("historic_Info_VehicleOff_Hour_Minutes", comment: "historic_Info_VehicleOff_Hour_Minutes") + // Minutos a las
                                                " \(firstHourString)",
                                            type: HistoryStatusType.parking
                                        )
                                        
                                        
                                    }
                                    
                                   
                                    vehicleOff = false
                                }
                                
                                // Get directions with MKDirections (Generate exact route)
                                func createDirection(){
                                    let lastPos = self.ArrayOfPositions.count - 1
                                    let request = MKDirections.Request()
                                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.ArrayOfPositions[lastPos], addressDictionary: nil))
                                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: point, addressDictionary: nil))
                                    request.requestsAlternateRoutes = false
                                    request.transportType = .automobile
                                    let directions = MKDirections(request: request)
                                    
                                    directions.calculate { [unowned self] response, error in
                                        guard let unwrappedResponse = response else { return }

                                        for route in unwrappedResponse.routes {
                                            
                                                self.mapView.addOverlay(route.polyline)
                                                
                                                if(i == (positions.items.count - 1)){
                                                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: false)
                                                }
                                            
                                        }
                                    }
                                }
                                
                                // Validate positions
                                if( i != 0 ){
                                    
                                    let lastPos = self.ArrayOfPositions.count - 1
                                    let firstCoordinate = CLLocation(latitude: self.ArrayOfPositions[lastPos].latitude, longitude: self.ArrayOfPositions[lastPos].longitude)
                                    let secondCoordinate = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                    let distanceInMeters = firstCoordinate.distance(from: secondCoordinate) // result is in meters
                                    
                                    
                                    if(vehicleOff){
                                        
                                        // The minimum distance to add the point into the polyline is 20 metters from the lastPosition
                                        if(distanceInMeters > 20){
                                            // Array of positions to polyline
                                            self.ArrayOfPositions.append(point)
                                        }
                                        
                                    } else {
                                        
                                        if(distanceInMeters > 10){
                                            // Array of positions to polyline
                                            self.ArrayOfPositions.append(point)
                                        }
                                        
                                    }
                                    
                                    
                                } else {
                                    // Inital point position
                                    self.ArrayOfPositions.append(point)
                                }
                                
                               
                                // Speed limit (Sumatory)
                                if(position.sp > speedLimit){
                                    speedLimit = position.sp
                                    speedLimitCoords = point
                                    speedLimitTime = position.ti
                                }
                                
                                
                                i = i + 1
                            }
                            
                            // When the process ends, then set maxSpeed info and set map
                            DispatchQueue.main.async {
                                
                                // Vehicle maxSpeed
                                // Some vehicles, report 10 when they are stopped
                                if( speedLimit > 20){
                                    self.speedNumberLabel.text = "\(speedLimit) km/hr"
                                    self.AddIndicator(speedLimitCoords, title: NSLocalizedString("historic_Info_VMR_Title", comment: "historic_Info_VMR_Title"), subtitle: "\(speedLimit)" + NSLocalizedString("historic_Info_VMR_Km_Subtitle", comment: "historic_Info_VMR_Km_Subtitle") + " \(speedLimitTime)", type: HistoryStatusType.speedLimit)
                                } else {
                                    self.speedNumberLabel.text = "-- km/hr"
                                }
                                
                                // Change the layout
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                
                                // New polyline
                                let testline = MKPolyline(coordinates: self.ArrayOfPositions, count: self.ArrayOfPositions.count)
                                // Add new polyline
                                self.mapView.addOverlay(testline)
                                // Delegate
                                self.mapView.delegate = self
                                // Center on the new polyline
                                self.setVisibleMapArea(polyline: testline, edgeInsets: UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0))
                                    
                            }
                            
                            // Get the odometer after make the polyline
                            self.getOdometer(dayC: dayC, monthC: monthC, yearC: yearC) // Get the odometer of the current vehicle
                        
                        // Doesn`t have positions
                        } else {

                            DispatchQueue.main.async {
                                // Change the layout
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.mapView.removeOverlays(self.mapView.overlays)
                                self.Alert(Title: NSLocalizedString("histroic_Tittle_ErrorP", comment: "histroic_Tittle_ErrorP"), Message: NSLocalizedString("historic_Body_ErrorP", comment: "historic_Body_ErrorP"))
                            }
                            
                        }
                        
                        
                        
                    // Error on get polyline
                    } catch {
                        
                        DispatchQueue.main.async {
                           // Change the layout
                           self.activityIndicator.isHidden = true
                           self.activityIndicator.stopAnimating()
                           self.mapView.removeOverlays(self.mapView.overlays)
                        }
                        
                        self.Alert(Title: NSLocalizedString( "error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message") + "\(error)")
                        
                    }
                }
                
                }.resume()
            
        // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))

        }
    }
    
    // get the odometer based in the hours and date selected
    func getOdometer(dayC: String, monthC: String, yearC: String){
        // Check internet connection
        if CheckInternet.Connection(){
        
            if(highDateHours == 24 && highDateMinutes == 0){
                highDateHours = 23
                highDateMinutes = 59
            }
            
            
            let dateToCorrectString = "\(Int(monthC) ?? 1)-\(Int(dayC) ?? 1)-\(yearC)"
            
            // Get the vehicle odometer
            let url : NSString  = "https://rastreo.resser.com/api/odometerindicator?GroupId=0&VehicleId=\(CurrentVehicleInfo.VehicleId)&StartDate=\(dateToCorrectString)%20\(lowDateHours)%3A\(lowDateMinutes)%20-5&EndDate=\(dateToCorrectString)%20\(highDateHours)%3A\(highDateMinutes)%20-5&page=1&start=0&limit=50" as NSString
            
            let searchURL : NSURL = NSURL(string: url as String)!
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
                        // Fill the struct with the info
                        let odometer = try JSONDecoder().decode(Odometer.self, from: data)
                        
                        for information in odometer.items{
                            
                            let odometerToString = NSString(format: "%.2f", information.Odometer) as String
                            
                            DispatchQueue.main.async {
                                self.odometerNumberLabel.text = "\(odometerToString) km"
                            }
                        }
                        
                    // Error on get
                    } catch {
                        
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    // Tap on calendar button
    @IBAction func showDatePicker(_ sender: Any) {
        // Hide Picker
        UIView.animate(withDuration: 0.5, animations: {
            self.datePicker.alpha = 1
            self.pickerView.alpha = 1
        })
    }
    
    func AddIndicator(_ coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: HistoryStatusType) {
        
        let historyAnnotation = HistoryAnnotation(coordinate:coordinate,title:title,subtitle:subtitle,type:type,orientation:0.0)
        mapView.addAnnotation(historyAnnotation)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = HistoryAnnotationView(annotation: annotation, reuseIdentifier: "History")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    // Function to render the Polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            var newColor = UIColor(named: "polylineColor")
            testlineRenderer.strokeColor = newColor
            testlineRenderer.lineWidth = 4.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
    }
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Center on the current polyline
    func setVisibleMapArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
    
    // Change the data with the slider
    func setDateTimeWithSlider(){
        let userCalendar = Calendar.current
        let components: NSCalendar.Unit = [.second, .minute, .hour, .day,.month, .year, .timeZone]
        
        let dateNowComponents = (userCalendar as NSCalendar).components(components, from: currentDateL)
        let lowDateComponents = (userCalendar as NSCalendar).components(components, from: currentDateL)
        
        
        let minutes: Double = rangeSlider.lowerValue * 24 * 60
        let minutesInt: Int = Int(minutes)
        
        var newlowDateComponents    = DateComponents()
        newlowDateComponents.year   = dateNowComponents.year
        newlowDateComponents.month  = dateNowComponents.month
        newlowDateComponents.day    = dateNowComponents.day
        newlowDateComponents.hour   = minutesInt/60
        newlowDateComponents.minute = minutesInt%60
        newlowDateComponents.second = 0
        (newlowDateComponents as NSDateComponents).timeZone = (dateNowComponents as NSDateComponents).timeZone
        
        let newLowDate = userCalendar.date(from: newlowDateComponents)!
        let highDateComponents = (userCalendar as NSCalendar).components(components, from: currentDateH)
        
        
        let minutesH: Double = rangeSlider.upperValue * 24 * 60
        let minutesHInt: Int = Int(minutesH)
        
        var newhighDateComponents = DateComponents()
        newhighDateComponents.year = dateNowComponents.year
        newhighDateComponents.month = dateNowComponents.month
        newhighDateComponents.day =   dateNowComponents.day
        newhighDateComponents.hour = minutesHInt/60
        newhighDateComponents.minute = minutesHInt%60
        newhighDateComponents.second = 59
        (newhighDateComponents as NSDateComponents).timeZone = (dateNowComponents as NSDateComponents).timeZone
        
        let newHighDate = userCalendar.date(from: newhighDateComponents)!
        
        currentDateL = newLowDate
        currentDateH = newHighDate
        
        // Max Hours
        highDateHours = newhighDateComponents.hour!
        highDateMinutes = newhighDateComponents.minute!
        // Min Hours
        lowDateHours = newlowDateComponents.hour!
        lowDateMinutes = newlowDateComponents.minute!
        
        
        if(lowDateMinutes < 10){
            firstHourLabel.text = "\(lowDateHours):0\(lowDateMinutes)"
        } else {
            firstHourLabel.text = "\(lowDateHours):\(lowDateMinutes)"
        }
        
        if(highDateMinutes < 10){
            secondHourLabel.text = "\(highDateHours):0\(highDateMinutes)"
        } else {
            secondHourLabel.text = "\(highDateHours):\(highDateMinutes)"
        }
        
    }
    
    
    // Tap on Cancel of the date picker
    @IBAction func onCloseDatePickerModal(_ sender: Any) {
        // Hide Picker
        UIView.animate(withDuration: 0.5, animations: {
            self.datePicker.alpha = 0
            self.pickerView.alpha = 0
        })
    }
    
    // Return to menu
    @IBAction func onReturnToMenu(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
