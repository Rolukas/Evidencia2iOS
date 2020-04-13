//
//  RemindersViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 6/13/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import Firebase

class reminderCell: UITableViewCell{
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var nextMaintenance: UILabel!
    @IBOutlet weak var concept: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet var mainView: UIView!
    
    
}

class todayCell: UITableViewCell{
    @IBOutlet weak var date: UILabel!
    @IBOutlet var mainView: UIView!
}

class noItemsCell: UITableViewCell{
    
}

class RemindersViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    // Structures
    struct Response: Codable{
        var success: Bool?
        var items:[item]?
    }
    
    struct item: Codable{
        var MaintenanceId: Int
        var Name: String
        var `Type`: Int
        var Date: String
        var Odometer: Float
        var Email: String
        var Progress: Float
    }
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    var currentContext: String = "None"
    var maintenanceContext: String = "None"
    var arraysAreFilled: Bool = false
    var month = [String]()
    var arrayOfMaintenanceId = [Int]()
    var arrayOfName = [String]()
    var arrayOfType = [Int]()
    var arrayOfDates = [String]()
    var arrayOfOdometer = [Float]()
    var arrayOfEmail = [String]()
    var arrayOfProgress = [Float]()
    var arrayPositionInTime = [String]()
    var TotalOfItems: Int = 0
    
    // Handlers data
    var isEditingEmail: Bool = false
    var handleKilometers = Int() // Handle the kilometers
    var handleEmail = String() // Handle the Email (Optional)
    var handleName = String() // Handle the item name (Only Maintenance)
    var handleDateW = String() // Handle date without change anything
    var handleDate = String() // Handle the date
    var handleDateToSend = String() // Date to send: Format 01/05/2019T00:00:00
    var didEditKilometers: Bool = false // Flag to change the alert (From kilometers to email)
    var didEditName: Bool = false // Flag to fill the name (Only Maintenance)
    var didEditDate: Bool = false // Flag to fill de the date
    var timeZoneUser = Int()
    // Edit (PUT)
    var isEditingReminder: Bool = false
    var editingName: String = ""
    var editingType: Int = 0
    var editingId: Int = 0
    var editingDate: String = ""
    var editingProgress: Float = 0.0
    var editingEmail: String = ""
    var editingOdometer: Float = 0.0
    //Layout
    var currentColorForText = UIColor()
    var currentColorForCells = UIColor()
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var principalButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    
    // Options from the menu
    @IBOutlet weak var maintenanceOptionView: UIView!
    @IBOutlet weak var verificationOptionView: UIView!
    @IBOutlet weak var tenureOptionView: UIView!
    
    // Labels Menu
    @IBOutlet var maintenanceOptionLabel: UILabel!
    @IBOutlet var verificationOptionLabel: UILabel!
    @IBOutlet var tenureOptionLabel: UILabel!
    
    //Title
    @IBOutlet weak var currentVehicleTitle: UILabel!
    @IBOutlet weak var alertTextfield: UITextField!
    // Alerts
    @IBOutlet weak var textFieldAlert: UIView!
    @IBOutlet weak var radioButtonAlert: UIView!
    @IBOutlet weak var labelTextFieldAlert: UILabel!
    @IBOutlet weak var viewAlertTextField: UIView! // View with shadow
    @IBOutlet weak var remindersTitleTwo: UILabel!
    // Radio Buttons
    @IBOutlet weak var kilometersButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var alertDescriptionLabel: UILabel!
    @IBOutlet weak var remindersTitleOne: UILabel!
    @IBOutlet weak var cancelButtonAlertRadio: UIButton!
    @IBOutlet weak var nextButtonAlertRadio: UIButton!
    @IBOutlet weak var kilometersOptionLabel: UILabel!
    @IBOutlet weak var dateOptionLabel: UILabel!
    // Picker View
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    // Label View
    @IBOutlet weak var labelAlert: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var labelAlertDescription: UILabel!
    @IBOutlet weak var cancelButtonLabelAlert: UIButton!
    @IBOutlet weak var saveButtonLabelAlert: UIButton!
    // Edit View Date
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderNameTextField: UITextField!
    @IBOutlet weak var reminderDateLabel: UILabel!
    @IBOutlet weak var reminderEmailTextField: UITextField!
    @IBOutlet weak var saveButtonDatePicker: UIButton!
    @IBOutlet weak var cancelButtonDatePicker: UIButton!
    
    // Edit View Kilometers
    @IBOutlet weak var editKilometersView: UIView!
    @IBOutlet weak var reminderKilometersName: UITextField!
    @IBOutlet weak var reminderKilometersTextField: UITextField!
    @IBOutlet weak var reminderKilometersEmail: UITextField!
    @IBOutlet weak var cancelButtonSomeAlert: UIButton!
    @IBOutlet weak var saveButtonSomeAlert: UIButton!
    @IBOutlet weak var cancelButtonSomAlertTwo: UIButton!
    @IBOutlet weak var saveButtonSomeAlertTwo: UIButton!
    @IBOutlet weak var saveButtonSomeAlertThree: UIButton!
    @IBOutlet weak var cancelButtonSomeAlertThree: UIButton!
    @IBOutlet weak var reminderKilometerNameTwo: UILabel!
    
    override func viewDidLoad() {
        
        // DarkMode iOS 13
        if #available(iOS 12.0, *) {
           
               // 1 -> Light mode, 2 -> Dark Mode
               print(traitCollection.userInterfaceStyle.rawValue)
               
               DispatchQueue.main.async {
                   
                   if( self.traitCollection.userInterfaceStyle.rawValue == 1 ){
                       self.setLightModeSettings()
                   } else {
                       self.setDarkModeSettings()
                   }

               }
                               
        }
        
        // Layout
        currentVehicleTitle.text = CurrentVehicleInfo.VehicleName
        datePicker.setValue( UIColor.white , forKeyPath: "textColor")
        alertTextfield.delegate = self
        reminderDateLabel.isUserInteractionEnabled = true
        alertTextfield.underlinedGray()
        dateLabel.underlinedGreen()
        reminderNameTextField.underlinedGray()
        reminderEmailTextField.underlinedGray()
        reminderDateLabel.underlinedGray()
        reminderKilometersName.underlinedGray()
        reminderKilometersEmail.underlinedGray()
        reminderKilometersTextField.underlinedGray()
        hideKeyboardWhenTappedAround()
        
        // Add value changed for date picker
        datePicker.addTarget(self, action: #selector(self.pickerChanged), for: .valueChanged)
        // Min Date of picker
        datePicker.minimumDate = Date()
        
        let langStr: String = Locale.current.languageCode!
        
        if( langStr == "en" ){
            month = ["","January","February","March","April","May","Jun","July","August","September","October","November","December"]
        } else {
            month = ["","Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
        }
        
        // Menu view tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.menuViewTapped(_:)))
        menuView.addGestureRecognizer(tap)
        
        // timeZone
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        timeZoneUser = (secondsFromGMT/3600)
        setText()
        addGesturesRecognizers()
        getReminders()
        Analytics.logEvent("function_maintenance", parameters: nil)
    }
    
    func setText(){
        reminderNameTextField.placeholder = NSLocalizedString("services_Alert_Name_Title", comment: "services_Alert_Name_Title")
        reminderEmailTextField.placeholder = NSLocalizedString("services_Alert_Email_Title", comment: "services_Alert_Email_Title")
        reminderKilometersEmail.placeholder = NSLocalizedString("services_Alert_Email_Title", comment: "services_Alert_Email_Title")
        reminderKilometersName.text = NSLocalizedString("services_Alert_Name_Title", comment: "services_Alert_Name_Title")
        alertDescriptionLabel.text = NSLocalizedString("services_alert_description", comment: "services_alert_description")
        saveButtonDatePicker.setTitle(NSLocalizedString("services_save_button", comment: "services_save_button"), for: .normal)
        cancelButtonDatePicker.setTitle(NSLocalizedString("services_cancel_button", comment: "services_cancel_button"), for: .normal)
        cancelButtonAlertRadio.setTitle(NSLocalizedString("services_cancel_button", comment: "services_cancel_button"), for: .normal)
        kilometersOptionLabel.text = NSLocalizedString("services_kilometers_option", comment: "services_kilometers_option")
        dateOptionLabel.text = NSLocalizedString("services_date_option", comment: "services_date_option")
        nextButtonAlertRadio.setTitle(NSLocalizedString("services_save_button", comment: "services_save_button"), for: .normal)
        labelAlertDescription.text = NSLocalizedString("services_date_label", comment: "services_date_label")
        cancelButtonSomeAlert.setTitle(NSLocalizedString("services_cancel_button", comment: "services_cancel_button"), for: .normal)
        cancelButtonSomAlertTwo.setTitle(NSLocalizedString("services_cancel_button", comment: "services_cancel_button"), for: .normal)
        cancelButtonSomeAlertThree.setTitle(NSLocalizedString("services_cancel_button", comment: "services_cancel_button"), for: .normal)
        saveButtonSomeAlert.setTitle(NSLocalizedString("services_save_button", comment: "services_save_button"), for: .normal)
        saveButtonSomeAlertTwo.setTitle(NSLocalizedString("services_save_button", comment: "services_save_button"), for: .normal)
        saveButtonSomeAlertThree.setTitle(NSLocalizedString("services_save_button", comment: "services_save_button"), for: .normal)
        maintenanceOptionLabel.text = NSLocalizedString("services_Menu_option_Maintenance", comment: "services_Menu_option_Maintenance")
        verificationOptionLabel.text = NSLocalizedString("services_Menu_option_Verfication", comment: "services_Menu_option_Verfication")
        tenureOptionLabel.text = NSLocalizedString("services_Menu_option_Tenure", comment: "services_Menu_option_Tenure")
    }
    
    //** iOS 13 dark mode **//
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
          
          print("===== Cambio Dark/Light Mode =====")
          // Trait collection has already changed
          if #available(iOS 13.0, *) {
              
              print(previousTraitCollection?.userInterfaceStyle)
              DispatchQueue.main.async {
                  
                   // Light Mode
                   if( previousTraitCollection?.userInterfaceStyle == .dark ){
                      
                      self.setLightModeSettings()
                      
                   // Dark Mode
                   } else {
                      
                      self.setDarkModeSettings()
                   }

                   self.tableView.reloadData()
              }
              
          } else {
              // Fallback on earlier versions
          }
    }
    
    func setLightModeSettings(){
       currentColorForText = UIColor(named: "grayBackground")!
       currentColorForCells = .white
       self.view.backgroundColor = .white
    }
       
    func setDarkModeSettings(){
       currentColorForText = .white
       currentColorForCells = UIColor(hexString: "#1B1C20")!
       self.view.backgroundColor = UIColor(hexString: "#1B1C20")!
    }
    
    @objc func menuViewTapped(_ sender: UITapGestureRecognizer){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.menuView.alpha = 0
            })
        }
    }
    
    // Value changed in the date picker
    @objc func pickerChanged(sender: UIDatePicker){
        //** Format of value **//
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        
        // Save the Date selected - String in "01-12-2019" format
        let StringDate = formater.string(from: sender.date)
        handleDateW = StringDate
    }
    
    //** Get All Reminders **//
    func getReminders(){
        
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get loads
            let url : NSString  = "https://rastreo.resser.com/api/ReminderMobile?VehicleID=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        
                        self.arrayOfName.removeAll()
                        self.arrayOfType.removeAll()
                        self.arrayOfDates.removeAll()
                        self.arrayOfEmail.removeAll()
                        self.arrayOfOdometer.removeAll()
                        self.arrayOfProgress.removeAll()
                        self.arrayOfMaintenanceId.removeAll()
                        self.arrayPositionInTime.removeAll()
                        var isTodayFilled: Bool = false
                        self.TotalOfItems = 0
                        
                        
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        // Set the dictionary with the data
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        
                        // Fill arrays
                        for item in response.items ?? [] {
                            // Date of the current item
                            let dateWithT = item.Date.split(separator: "T")
                            let dateStr = dateWithT[0].split(separator: "-")
                            let dayOfItem = Int(dateStr[2]) ?? 1
                            let monthOfItem = Int(dateStr[1]) ?? 1
                            let yearOfItem = Int(dateStr[0]) ?? 1900
                            
                            let numberOfItemDate = dayOfItem + monthOfItem + yearOfItem
                            
                            // Current date
                            let date = Date()
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day], from: date)
                            let year =  components.year ?? 1
                            let month = components.month ?? 1
                            let day = components.day ?? 1990
                            
                            let numberOfCurrentDate = day + month + year
                            
                            // Compare the addition between the components of the current date and the date of the item (Magic!)
                            
                            // Item is in current date
                            if( numberOfItemDate == numberOfCurrentDate ){
                                
                                // Current day is filled when a coincidence appears
                                if( !isTodayFilled ){
                                    
                                    self.arrayOfName.append("Today")
                                    self.arrayOfMaintenanceId.append(0)
                                    self.arrayOfProgress.append(1)
                                    self.arrayOfOdometer.append(1.0)
                                    self.arrayOfEmail.append("")
                                    self.arrayOfDates.append("Today")
                                    self.arrayOfType.append(2)
                                    self.arrayPositionInTime.append("Today")
                                    
                                    self.TotalOfItems = self.TotalOfItems + 1
                                    var positionOfTodayCell = self.TotalOfItems + 1 // Know in which cell is for cellForRowAt function
                                    isTodayFilled = true
                                }
                                
                                self.arrayOfName.append(item.Name)
                                self.arrayOfMaintenanceId.append(item.MaintenanceId)
                                self.arrayOfProgress.append(item.Progress)
                                self.arrayOfOdometer.append(item.Odometer)
                                self.arrayOfEmail.append(item.Email)
                                self.arrayOfDates.append(item.Date)
                                self.arrayOfType.append(item.Type)
                                self.arrayPositionInTime.append("Future")
                                
                                // Date is in the future
                            } else if (
                                    ( dayOfItem >= day && monthOfItem >= month && yearOfItem >= year ) ||
                                    ( yearOfItem > year ) ||
                                    ( dayOfItem == day && monthOfItem > month  && year == yearOfItem ) ||
                                    ( monthOfItem > month && yearOfItem >= year )
                                ){
                                
                                // Current day is filled before add the future items
                                if( !isTodayFilled ){
                                    
                                    self.arrayOfName.append("Today")
                                    self.arrayOfMaintenanceId.append(0)
                                    self.arrayOfProgress.append(1)
                                    self.arrayOfOdometer.append(1.0)
                                    self.arrayOfEmail.append("")
                                    self.arrayOfDates.append("Today")
                                    self.arrayOfType.append(2)
                                    self.arrayPositionInTime.append("Today")
                                    
                                    self.TotalOfItems = self.TotalOfItems + 1
                                    var positionOfTodayCell = self.TotalOfItems + 1 // Know in which cell is for cellForRowAt function
                                    isTodayFilled = true
                                }
                                
                                
                                self.arrayOfName.append(item.Name)
                                self.arrayOfMaintenanceId.append(item.MaintenanceId)
                                self.arrayOfProgress.append(item.Progress)
                                self.arrayOfOdometer.append(item.Odometer)
                                self.arrayOfEmail.append(item.Email)
                                self.arrayOfDates.append(item.Date)
                                self.arrayOfType.append(item.Type)
                                self.arrayPositionInTime.append("Future")
                                
                                // Date is in the past
                            } else {
                                
                                self.arrayOfName.append(item.Name)
                                self.arrayOfMaintenanceId.append(item.MaintenanceId)
                                self.arrayOfProgress.append(item.Progress)
                                self.arrayOfOdometer.append(item.Odometer)
                                self.arrayOfEmail.append(item.Email)
                                self.arrayOfDates.append(item.Date)
                                self.arrayOfType.append(item.Type)
                                self.arrayPositionInTime.append("Past")
                                
                                
                            }
                            
                            self.TotalOfItems = self.TotalOfItems + 1
                        }
                        
                        // Current day is filled when there is no items in current date or future date (Only past items)
                        if( !isTodayFilled ){
                            
                            self.arrayOfName.append("Today")
                            self.arrayOfMaintenanceId.append(0)
                            self.arrayOfProgress.append(1)
                            self.arrayOfOdometer.append(1.0)
                            self.arrayOfEmail.append("")
                            self.arrayOfDates.append("Today")
                            self.arrayOfType.append(2)
                            self.arrayPositionInTime.append("Today")
                            var positionOfTodayCell = self.TotalOfItems + 1 // Know in which cell is for cellForRowAt function
                            
                            self.TotalOfItems = self.TotalOfItems + 1
                            
                            isTodayFilled = true
                        }
                        
                        
                        DispatchQueue.main.async {
                            self.arraysAreFilled = true
                            self.tableView.reloadData()
                            
                            self.menuView.alpha = 0
                            self.textFieldAlert.alpha = 0
                            self.pickerView.alpha = 0
                            self.radioButtonAlert.alpha = 0
                            self.labelAlert.alpha = 0
                            self.editView.alpha = 0
                            self.editKilometersView.alpha = 0
                        }
                        
                    } catch {
                        
                        print("Error on getReminders: ")
                        print(error)
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                        
                        DispatchQueue.main.async {
                            self.menuView.alpha = 0
                            self.textFieldAlert.alpha = 0
                            self.pickerView.alpha = 0
                            self.radioButtonAlert.alpha = 0
                            self.labelAlert.alpha = 0
                            self.editView.alpha = 0
                            self.editKilometersView.alpha = 0
                        }
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    // Cancel on Alert
    @IBAction func cancelAlertButton(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.menuView.alpha = 0
                self.radioButtonAlert.alpha = 0
                self.textFieldAlert.alpha = 0
            })
            self.clearAllCurrentContext()
        }
    }
    
    //** Add gestures recognizers to menu options **//
    func addGesturesRecognizers(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.createMaintenance(_:)))
        maintenanceOptionView.addGestureRecognizer(tap)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.createVerification(_:)))
        verificationOptionView.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(self.createTenure(_:)))
        tenureOptionView.addGestureRecognizer(tap4)
        
    }
    
    //** Menu Options Events **//
    
    // Create Maintenance
    @objc func createMaintenance(_ sender: UITapGestureRecognizer){
        currentContext = "Maintenance"
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.menuView.alpha = 0
                self.radioButtonAlert.alpha = 1
            })
        }
        
    }
    
    // Create Renewal
    @objc func createRenewal(_ sender: UITapGestureRecognizer){
        currentContext = "Renewal"
        
        // CHANGE TEXT
        let openForPick = UITapGestureRecognizer(target: self, action: #selector(self.openPicker(_:)))
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(openForPick)
        labelTextFieldAlert.text = "Ingrese la fecha"
        
        // Prepare textfield alert for show (By Date Info)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.radioButtonAlert.alpha = 0
                self.labelAlert.alpha = 1
            })
        }
        
    }
    
    // Create Verification
    @objc func createVerification(_ sender: UITapGestureRecognizer){
        currentContext = "Verification"
        
        // CHANGE TEXT
        let openForPick = UITapGestureRecognizer(target: self, action: #selector(self.openPicker(_:)))
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(openForPick)
        labelTextFieldAlert.text = "Ingrese la fecha"
        
        // Prepare textfield alert for show (By Date Info)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.radioButtonAlert.alpha = 0
                self.labelAlert.alpha = 1
            })
        }
    }
    
    // Create Ternure
    @objc func createTenure(_ sender: UITapGestureRecognizer){
        currentContext = "Ternure"
        
        // CHANGE TEXT
        let openForPick = UITapGestureRecognizer(target: self, action: #selector(self.openPicker(_:)))
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(openForPick)
        labelTextFieldAlert.text = "Ingrese la fecha"
        
        // Prepare textfield alert for show (By Date Info)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.radioButtonAlert.alpha = 0
                self.labelAlert.alpha = 1
            })
        }
        
    }
    
    // Hide/Show Menu
    @IBAction func openMenu(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.menuView.alpha = 1
            })
        }
    }
    
    @IBAction func hideMenu(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.menuView.alpha = 0
            })
        }
    }
    
    //** Radio Button Alert Events **//
    
    // Kilometers Button
    @IBAction func kilometersButton(_ sender: Any) {
        maintenanceContext = "Kilometers"
        kilometersButton.setImage(UIImage(named: "grayCircle"), for: .normal)
        dateButton.setImage(UIImage(named: "grayBorderCircle"), for: .normal)
    }
    
    // Date Button
    @IBAction func dateButton(_ sender: Any) {
        maintenanceContext = "Date"
        dateButton.setImage(UIImage(named: "grayCircle"), for: .normal)
        kilometersButton.setImage(UIImage(named: "grayBorderCircle"), for: .normal)
    }
    
    //** ===== Events of next steps ===== **//
    @IBAction func alertRadioButtonNext(_ sender: Any) {
        
        // The user don't select any option (Kilometers or date)
        if(maintenanceContext != "None"){
            
            //** ========== Create Maintenance ========== **//
            if(currentContext == "Maintenance"){
                
                // By Kilometers
                if(maintenanceContext == "Kilometers"){
                    
                    // CHANGE TEXT
                    alertTextfield.placeholder = NSLocalizedString("services_Alert_Kilometers_Title", comment: "services_Alert_Kilometers_Title")
                    alertTextfield.keyboardType = UIKeyboardType.numberPad
                    labelTextFieldAlert.text = NSLocalizedString("services_Alert_Kilometers_Message", comment: "services_Alert_Kilometers_Message")
                    
                    
                    // Prepare textfield alert for show (By kilometers Info)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            self.radioButtonAlert.alpha = 0
                            self.textFieldAlert.alpha = 1
                        })
                    }
                    
                    // By Date
                } else {
                    
                    // CHANGE TEXT
                    let openForPick = UITapGestureRecognizer(target: self, action: #selector(self.openPicker(_:)))
                    dateLabel.isUserInteractionEnabled = true
                    dateLabel.addGestureRecognizer(openForPick)
                    labelTextFieldAlert.text = NSLocalizedString("services_Alert_Date_Kilometers", comment: "services_Alert_Date_Kilometers")
                    
                    // Prepare textfield alert for show (By Date Info)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            self.radioButtonAlert.alpha = 0
                            self.labelAlert.alpha = 1
                        })
                    }
                    
                }
                
            } else if( currentContext == "Renewal" ){
                
                
                if(handleDate != ""){
                    
                } else {
                    Alert(Title: "Oops!", Message: "escoja")
                }
                
                
            }
            
            
            
        } else {
            
            Alert(Title: "Oops!", Message: NSLocalizedString("services_error_date", comment: "services_error_date"))
            
        }
        
    }
    
    //** Label Alert **//
    @IBAction func alertLabelNextButton(_ sender: Any) {
        
        if(currentContext == "Maintenance"){
            
            if(handleDate != ""){
                
                // CHANGE TEXT
                alertTextfield.placeholder = NSLocalizedString("services_Alert_Name_Title", comment: "services_Alert_Name_Title")
                alertTextfield.keyboardType = UIKeyboardType.default
                labelTextFieldAlert.text = NSLocalizedString("services_Alert_Name_Message", comment: "services_Alert_Name_Message")
                
                // Prepare textfield alert for show (By name Info)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.7, animations: { () -> Void in
                        self.labelAlert.alpha = 0
                        self.textFieldAlert.alpha = 1
                    })
                }
                
                
            } else {
                Alert(Title: "Oops!", Message: NSLocalizedString("services_error_option", comment: "services_error_option"))
            }
            
            
        } else {
            
            if(!isEditingEmail){
                
                // Prepare textfield alert for show (Email)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        self.labelAlert.alpha = 0
                    })
                }
                
                // CHANGE TEXT
                alertTextfield.placeholder = NSLocalizedString("services_Alert_Email_Title", comment: "services_Alert_Email_Title")
                alertTextfield.keyboardType = UIKeyboardType.default
                labelTextFieldAlert.text = NSLocalizedString("services_Alert_Email_Message", comment: "services_Alert_Email_Message")
                didEditDate = true
                
                
                // Prepare textfield alert for show (Email)
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        //                            self.alertTextfield.alpha = 1
                        self.textFieldAlert.alpha = 1
                    })
                }
                
                
                
                
            } else {
                Alert(Title: "Oops!", Message: NSLocalizedString("services_error_date", comment: "services_error_date"))
            }
        }
        
    }
    
    //** Open Picker Function **//
    @objc func openPicker(_ sender: UITapGestureRecognizer){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.pickerView.alpha = 1
            })
        }
    }
    
    //** Text Field alert **//
    
    //** ===== Events of next steps ===== **//
    @IBAction func textFieldAlertNextButton(_ sender: Any) {
        
        var textAlert = alertTextfield.text!
        
        //** Create Maintenance **//
        if(currentContext == "Maintenance"){
            
            //** ===== KILOMETERS ===== **//
            if(maintenanceContext == "Kilometers"){
                
                var textAlert = alertTextfield.text!
                
                // The user is editing kilometers, not email
                if(!didEditKilometers && !didEditName){
                    
                    if(textAlert != "" ){
                        
                        //** ===== The user has already edited kilometers ===== **//
                        
                        //** Change the alert format **//
                        handleKilometers = Int(textAlert) ?? 0 // Save Kilometers
                        alertTextfield.text! = ""
                        didEditKilometers = true
                        // Hide and show alert with different info
                        self.viewAlertTextField.alpha = 0
                        // CHANGE TEXT
                        alertTextfield.placeholder = NSLocalizedString("services_Alert_Name_Title", comment: "services_Alert_Name_Message")
                        alertTextfield.keyboardType = UIKeyboardType.default
                        labelTextFieldAlert.text = NSLocalizedString("services_Alert_Name_Message", comment: "services_Alert_Name_Message")
                        
                        // Prepare textfield alert for show (Name)
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.viewAlertTextField.alpha = 1
                            })
                        }
                        
                    } else {
                        Alert(Title: "Oops!", Message: NSLocalizedString("services_error_fields", comment: "services_error_fields"))
                    }
                    
                    
                    // The user is editing name, not kilometers
                } else if( didEditKilometers && !didEditName ){
                    
                    
                    if(textAlert != "" ){
                        
                        //** ===== The user has already edited name ===== **//
                        
                        //** Change the alert format **//
                        handleName = textAlert // Save Name
                        alertTextfield.text! = ""
                        didEditName = true
                        // Hide and show alert with different info
                        self.viewAlertTextField.alpha = 0
                        
                        // CHANGE TEXT
                        alertTextfield.placeholder = NSLocalizedString("services_Alert_Email_Title", comment: "services_Alert_Email_Title")
                        alertTextfield.keyboardType = UIKeyboardType.default
                        labelTextFieldAlert.text = NSLocalizedString("services_Alert_Email_Message", comment: "services_Alert_Email_Message")
                        
                        // Prepare textfield alert for show (Email)
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.viewAlertTextField.alpha = 1
                            })
                        }
                        
                    } else {
                        Alert(Title: "Oops!", Message: NSLocalizedString("services_error_fields", comment: "services_error_fields"))
                    }
                    
                    
                    
                    
                    // The user is editing email, not kilometers or name
                } else if ( didEditName && didEditKilometers ){
                    
                    //** ===== The user has already edited email ===== **//
                    
                    // Save Email
                    handleEmail = alertTextfield.text!
                    
                    // Create Reminder
                    createNewReminder(type: "Maintenance")
                    
                }
                
                //** ===== DATE ===== **//
            } else {
                
                
                if(!didEditName){
                    
                    if(textAlert != ""){
                        
                        //** ===== The user has already edited name ===== **//
                        
                        //** Change the alert format **//
                        handleName = textAlert // Save Name
                        alertTextfield.text! = ""
                        didEditName = true
                        // Hide and show alert with different info
                        // Prepare textfield alert for show (Email)
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                self.viewAlertTextField.alpha = 0
                            })
                        }
                        
                        // CHANGE TEXT
                        alertTextfield.placeholder = NSLocalizedString("services_Alert_Email_Title", comment: "services_Alert_Email_Title")
                        alertTextfield.keyboardType = UIKeyboardType.default
                        labelTextFieldAlert.text = NSLocalizedString("services_Alert_Email_Message", comment: "services_Alert_Email_Message")
                        
                        // Prepare textfield alert for show (Email)
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.viewAlertTextField.alpha = 1
                            })
                        }
                        
                    } else {
                        
                    }
                    
                } else {
                    
                    // Save Email
                    handleEmail = alertTextfield.text!
                    
                    // Create Reminder
                    createNewReminder(type: "Maintenance")
                }
                
            }
            
        } else {
            if(!isEditingEmail){
                isEditingEmail = true
            } else {
                // Save Email
                handleEmail = alertTextfield.text!
                
                // Create Reminder
                createNewReminder(type: "Other")
            }
        }
        
    }
    
    func createNewReminder(type: String){
        
        var dictionarySub = [:] as [String : Any]
        
        switch(type){
            
        //** Maintenance **//
        case "Maintenance":
            
            if(maintenanceContext == "Kilometers"){
                
                dictionarySub = [
                    "VehicleId": CurrentVehicleInfo.VehicleId,
                    "TimeZone": timeZoneUser,
                    "Name": handleName,
                    "Type": 0, // 0 odometro, 1 tiempo
                    "Odometer": handleKilometers,
                    "Date": "2019-10-23", // 0 odometro(fecha del telefono), 1 fecha(fecha del usuario)
                    "Email": handleEmail
                    ] as [String : Any]
                
                break
                
            } else {
                
                dictionarySub = [
                    "VehicleId": CurrentVehicleInfo.VehicleId,
                    "TimeZone": timeZoneUser,
                    "Name": handleName,
                    "Type": 1, //0 odometro, 1 tiempo
                    "Odometer": handleKilometers,
                    "Date": handleDateToSend, //0 odometro(fecha del telefono), 1 fecha(fecha del usuario)
                    "Email": handleEmail
                    ] as [String : Any]
                
                break
            }
            
        case "Other":
            
            let langStr: String = Locale.current.languageCode!
            var concept = ""
            if(currentContext == "Renewal"){
                
                if( langStr == "en" ){
                    concept = "License Renewal"
                } else {
                    concept = "Renovar Licencia"
                }
                
            } else if( currentContext == "Ternure" ){
                
                if( langStr == "en" ){
                    concept = "Vehicle Tenure"
                } else {
                    concept = "Tenencia Vehicular"
                }
                
                
            } else if( currentContext == "Verification" ){
                
                if( langStr == "en" ){
                    concept = "Vehicle Verification"
                } else {
                    concept = "Verificacion Vehicular"
                }
                
            }
            
            
            dictionarySub = [
                "VehicleId": CurrentVehicleInfo.VehicleId,
                "TimeZone": timeZoneUser,
                "Name": concept,
                "Type": 1, //0 odometro, 1 tiempo
                "Odometer": 0,
                "Date": handleDateToSend, //0 odometro(fecha del telefono), 1 fecha(fecha del usuario)
                "Email": handleEmail
                ] as [String : Any]
            
            break
            
            
        default:
            break
        }
        
        
        if CheckInternet.Connection(){
            
            print(dictionarySub)
            
            let url = "https://rastreo.resser.com/api/ReminderMobile?VehicleID=\(CurrentVehicleInfo.VehicleId)"
            let URL: Foundation.URL = Foundation.URL(string: url)!
            let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
            request.httpMethod = "POST"
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionarySub)
            
            let theJSONText = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            
            request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
            let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            
            let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                
                
                if error != nil {
                    
                    //handle error
                    print("====ERROR FROM REMINDERS POST====")
                    print(error ?? "LOL")
                    
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                    
                } else {
                    
                    self.Alert(Title: "Éxito!", Message: "Reminder creado")
                    self.clearAllCurrentContext()
                    self.getReminders()
                    
                }
                
                
            }
            
            dataTask.resume()
        } else {
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
        }
        
    }
    
    // Clear All Current Context
    func clearAllCurrentContext(){
        
        DispatchQueue.main.async {
            // TextFields/ labels
            self.currentContext = ""
            self.maintenanceContext = "None"
            self.alertTextfield.text = ""
            self.labelTextFieldAlert.text = ""
            self.dateLabel.text = ""
            self.reminderNameLabel.text = ""
            self.reminderEmailTextField.text = ""
            self.reminderNameTextField.text = ""
            self.reminderDateLabel.text = ""
            // Common variables
            self.handleKilometers = 0
            self.handleEmail = ""
            self.handleDate = ""
            self.handleName = ""
            self.handleDateToSend = ""
            self.handleDateW = ""
            self.handleDate = ""
            self.didEditKilometers = false
            self.didEditDate = false
            self.didEditName = false
            self.isEditingEmail = false
            // Editing
            self.isEditingReminder = false
            self.editingName = ""
            self.editingType = 0
            self.editingId = 0
            self.editingDate = ""
            self.editingProgress = 0.0
            self.editingEmail = ""
            self.editingOdometer = 0.0
            // Layout
            self.menuView.alpha = 0
            self.radioButtonAlert.alpha = 0
            self.labelAlert.alpha = 0
            self.textFieldAlert.alpha = 0
            self.pickerView.alpha = 0
            self.kilometersButton.setImage(UIImage(named: "grayBorderCircle"), for: .normal)
            self.dateButton.setImage(UIImage(named: "grayBorderCircle"), for: .normal)
        }
    }
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func returnToMenu(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //** Delete reminder by id **//
    func deleteReminder(id: Int){
        
        // Check internet connection
        if CheckInternet.Connection(){
            let maintenanceId = arrayOfMaintenanceId[id] //Id de la carga
            // Get loads
            let url : NSString  = "https://rastreo.resser.com/api/ReminderMobile?MaintenanceId=\(maintenanceId)&VehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            var request = URLRequest(url: searchURL as URL)
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            
            // Request
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let Session = URLSession.shared
            Session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        
                        self.Alert(Title:NSLocalizedString("services_success_title", comment: "services_success_title") ,Message: NSLocalizedString("services_success_delete", comment: "services_success_delete"))
                        self.getReminders()
                        
                    } catch {
                        
                        print("Error on deleteReminder: ")
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
    
    func editDateReminder(id: Int){
        
        //** You cannot change a common name **//
        let arrayOfCommonNames = ["License Renewal","Renovar Licencia","Vehicle Ternure","Tenencia Vehicular", "Vehicle Verification","Verificación Vehicular", "License_Renewal","Renovar_Licencia","Vehicle_Ternure","Tenencia_Vehicular", "Vehicle_Verification","Verificación_Vehicular"]
        
        for name in arrayOfCommonNames{
            if(name == arrayOfName[id]){
                self.reminderNameTextField.isUserInteractionEnabled = false
                break
            } else {
                self.reminderNameTextField.isUserInteractionEnabled = true
            }
        }
        
        editingName = arrayOfName[id]
        editingType = arrayOfType[id]
        editingId = arrayOfMaintenanceId[id]
        editingProgress = arrayOfProgress[id]
        editingOdometer = arrayOfOdometer[id]
        editingEmail = arrayOfEmail[id]
        
        
        // Menu view tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openDatePickerToEdit(_:)))
        reminderDateLabel.addGestureRecognizer(tap)
        
        
        self.reminderEmailTextField.text = self.arrayOfEmail[id]
        self.reminderNameLabel.text = self.arrayOfName[id]
        self.reminderNameTextField.text = self.arrayOfName[id].replacingOccurrences(of: "_", with: " ")
        
        let dateWithT = arrayOfDates[id].split(separator: "T")
        let dateStr = dateWithT[0].split(separator: "-")
        let dayOfItem = Int(dateStr[2]) ?? 1
        let monthOfItem = Int(dateStr[1]) ?? 1
        let yearOfItem = Int(dateStr[0]) ?? 1999
        
        let langStr: String = Locale.current.languageCode!
        
        if( langStr == "en" ){
            handleDateW = "\(yearOfItem)-\(monthOfItem)-\(dayOfItem)"
            self.reminderDateLabel.text = "\(month[monthOfItem]) \(dayOfItem), \(yearOfItem)"
        } else {
            handleDateW = "\(yearOfItem)-\(monthOfItem)-\(dayOfItem)"
            self.reminderDateLabel.text = "\(dayOfItem) de \(month[monthOfItem]), \(yearOfItem)"
        }
        
        
    }
    
    func editKilometersReminder(id: Int){
        
        editingName = arrayOfName[id]
        editingType = arrayOfType[id]
        editingId = arrayOfMaintenanceId[id]
        editingProgress = arrayOfProgress[id]
        editingOdometer = arrayOfOdometer[id]
        editingDate = arrayOfDates[id]
        editingEmail = arrayOfEmail[id]
        
        print(arrayOfMaintenanceId)
        print(editingId)
        
        reminderKilometersTextField.text = "\(editingOdometer)"
        reminderKilometersEmail.text = editingEmail
        reminderKilometersName.text = editingName
        
    }
    
    func reminderDatePut(){
        
        let dictionarySub = [
            "MaintenanceId": editingId,
            "VehicleId": CurrentVehicleInfo.VehicleId,
            "Name": reminderNameTextField.text!,
            "Odometer": editingOdometer,
            "Date": handleDateW,
            "Email": reminderEmailTextField.text!,
            ] as [String : Any]
        
        
        if CheckInternet.Connection(){
            let url = "https://rastreo.resser.com/api/ReminderMobile?VehicleID=\(CurrentVehicleInfo.VehicleId)"
            let URL: Foundation.URL = Foundation.URL(string: url)!
            let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
            request.httpMethod = "PUT"
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionarySub)
            
            let theJSONText = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            
            request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
            let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            
            let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                
                
                if error != nil {
                    
                    //handle error
                    print("====ERROR FROM reminderDatePut====")
                    print(error ?? "LOL")
                    
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                } else {
                    self.Alert(Title: NSLocalizedString("services_success_title", comment: "services_success_title"), Message: NSLocalizedString("services_success_message", comment: "services_success_message"))
                    self.getReminders()
                }
                
                
            }
            dataTask.resume()
        } else {
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
        }
        
    }
    
    func reminderKilometersPut(){
        let dictionarySub = [
            "MaintenanceId": editingId,
            "VehicleId": CurrentVehicleInfo.VehicleId,
            "Name": reminderKilometersName.text!,
            "Odometer": reminderKilometersTextField.text!,
            "Date": editingDate,
            "Email": reminderKilometersEmail.text!
            ] as [String : Any]
        
        print(dictionarySub)
        if CheckInternet.Connection(){
            let url = "https://rastreo.resser.com/api/ReminderMobile?VehicleID=\(CurrentVehicleInfo.VehicleId)"
            let URL: Foundation.URL = Foundation.URL(string: url)!
            let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
            request.httpMethod = "PUT"
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionarySub)
            
            let theJSONText = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            
            request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
            let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            
            let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                
                
                if error != nil {
                    
                    //handle error
                    print("====ERROR FROM reminderDatePut====")
                    print(error ?? "LOL")
                    
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                } else {
                    self.Alert(Title: NSLocalizedString("services_success_title", comment: "services_success_title"), Message: NSLocalizedString("services_success_message", comment: "services_success_message"))
                    self.getReminders()
                }
                
                
            }
            dataTask.resume()
        } else {
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
        }
    }
    
    @objc func openDatePickerToEdit(_ sender: UITapGestureRecognizer){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.pickerView.alpha = 1
            })
        }
    }
    
    @IBAction func saveButtonDatePicker(_ sender: Any) {
        
        if(isEditingReminder){
            
            let dateStr = handleDateW.split(separator: "-")
            let dayOfItem = Int(dateStr[2]) ?? 1
            let monthOfItem = Int(dateStr[1]) ?? 1
            let yearOfItem = Int(dateStr[0]) ?? 1999
            
            let langStr: String = Locale.current.languageCode!
            
            if( langStr == "en" ){
                self.reminderDateLabel.text = "\(month[monthOfItem]) \(dayOfItem), \(yearOfItem)"
            } else {
                self.reminderDateLabel.text = "\(dayOfItem) de \(month[monthOfItem]), \(yearOfItem)"
            }

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.pickerView.alpha = 0
                })
            }
            
        } else {
            
            handleDate = handleDateW
            handleDateToSend = "\(handleDate)"
            dateLabel.text = handleDate
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.pickerView.alpha = 0
                })
            }
            
        }
        
        
    }
    
    @IBAction func cancelLabelAlert(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.labelAlert.alpha = 0
                self.dateLabel.text = ""
            })
            
            self.clearAllCurrentContext()
        }
    }
    
    @IBAction func cancelButtonDatePicker(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.pickerView.alpha = 0
            })
        }
    }
    
    @IBAction func cancelButtonEdit(_ sender: Any) {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.editView.alpha = 0
            })
            self.clearAllCurrentContext()
        }
        
    }
    
    @IBAction func nextButtonEdit(_ sender: Any) {
        reminderDatePut()
    }
    
    @IBAction func cancelButtonEditKilometers(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.editKilometersView.alpha = 0
            })
            self.clearAllCurrentContext()
        }
    }
    
    @IBAction func nextButtonEditKilometers(_ sender: Any) {
        reminderKilometersPut()
    }
}

extension RemindersViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(TotalOfItems == 0){
            return 1
        } else {
            return TotalOfItems
        }
    }
    
    //** Cell Size **//
    func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //** Create Each Item Of the table **//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(TotalOfItems > 0){
            
            
            // Cell of Today date
            if( arrayOfName[indexPath.row] == "Today"  && arrayPositionInTime[indexPath.row] == "Today" ){
                
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "todayCell", for: indexPath) as! todayCell
                
                // Current date
                let date = Date()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                let year =  components.year ?? 1
                let monthInt = components.month ?? 1
                let day = components.day ?? 1990
                
                let langStr: String = Locale.current.languageCode!
                
                if( langStr == "en" ){
                    cell.date.text = "Today \(month[monthInt]) \(day), \(year)"
                } else {
                    cell.date.text = "Hoy \(day) de \(month[monthInt]) de \(year)"
                }
                
                cell.mainView.backgroundColor = currentColorForCells
                cell.selectionStyle = .none;
                
                return cell
                
                // Cell of Future Date
            } else if ( arrayPositionInTime[indexPath.row] == "Future" ){
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! reminderCell
                
                let dateWithT = arrayOfDates[indexPath.row].split(separator: "T")
                let dateStr = dateWithT[0].split(separator: "-")
                let dayOfItem = Int(dateStr[2]) ?? 1
                let monthOfItem = Int(dateStr[1]) ?? 1
                
                // Por fecha
                if( arrayOfType[indexPath.row] == 1 ){
                    
                    cell.icon.image = UIImage(named: "clockGray")
                    cell.title.text = arrayOfName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                    
                    let langStr: String = Locale.current.languageCode!
                    
                    if( langStr == "en" ){
                        cell.concept.text = "\(month[monthOfItem]) \(dayOfItem)"
                        cell.nextMaintenance.text = "next maintenance"
                    } else {
                        cell.concept.text = "\(dayOfItem) de \(month[monthOfItem])"
                        cell.nextMaintenance.text = "Próximo mantenimiento"
                    }
                    
                    // Por kilómetros
                } else {
                    cell.icon.image = UIImage(named: "odometerGray")
                    cell.title.text = arrayOfName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                    cell.concept.text = "\(arrayOfOdometer[indexPath.row]) Km"
                    
                    let langStr: String = Locale.current.languageCode!
                    
                    if( langStr == "en" ){
                        cell.nextMaintenance.text = "next maintenance"
                    } else {
                        cell.nextMaintenance.text = "Próximo mantenimiento"
                    }
                }
                
                let langStr: String = Locale.current.languageCode!
                
                if( langStr == "en" ){
                    cell.date.text = "Estimated to \(month[monthOfItem]) \(dayOfItem)"
                } else {
                    cell.date.text = "Estimado para \(dayOfItem) de \(month[monthOfItem])"
                }
                
                
                cell.selectionStyle = .none;
                cell.mainView.backgroundColor = currentColorForCells
                cell.nextMaintenance.textColor = currentColorForText
                cell.title.textColor = currentColorForText
                cell.date.textColor = currentColorForText
                return cell
                
                
                // Cell of Past Date
            } else if ( arrayPositionInTime[indexPath.row] == "Past" ){
                
                // Was completed or not
                
                // Completed
                if( arrayOfProgress[indexPath.row] == 1 ){
                    
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! reminderCell
                    
                    let dateWithT = arrayOfDates[indexPath.row].split(separator: "T")
                    let dateStr = dateWithT[0].split(separator: "-")
                    let dayOfItem = Int(dateStr[2]) ?? 1
                    let monthOfItem = Int(dateStr[1]) ?? 1
                    
                    // Por fecha
                    if( arrayOfType[indexPath.row] == 1 ){
                        
                        cell.icon.image = UIImage(named: "clockGreen")
                        cell.title.text = arrayOfName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                        let langStr: String = Locale.current.languageCode!
                        
                        if( langStr == "en" ){
                            cell.concept.text = "\(month[monthOfItem]) \(dayOfItem)"
                        } else {
                            cell.concept.text = "\(dayOfItem) de \(month[monthOfItem])"
                        }
                        
                        
                        // Por kilómetros
                    } else {
                        cell.icon.image = UIImage(named: "odometerGreen")
                        cell.title.text = arrayOfName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                        cell.concept.text = "\(arrayOfOdometer[indexPath.row]) Km"
                    }
                    
                    let langStr: String = Locale.current.languageCode!
                    
                    if( langStr == "en" ){
                        cell.nextMaintenance.text = "Completed"
                        cell.date.text = "\(month[monthOfItem]) \(dayOfItem)"
                    } else {
                        cell.nextMaintenance.text = "Completo"
                        cell.date.text = "\(dayOfItem) de \(month[monthOfItem])"
                    }
                    
                    cell.nextMaintenance.text = ""
                    cell.selectionStyle = .none;
                    cell.mainView.backgroundColor = currentColorForCells
                    cell.nextMaintenance.textColor = currentColorForText
                    cell.title.textColor = currentColorForText
                    cell.date.textColor = currentColorForText
                    return cell
                    
                    // Not Completed
                } else {
                    
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! reminderCell
                    
                    let dateWithT = arrayOfDates[indexPath.row].split(separator: "T")
                    let dateStr = dateWithT[0].split(separator: "-")
                    let dayOfItem = Int(dateStr[2]) ?? 1
                    let monthOfItem = Int(dateStr[1]) ?? 1
                    
                    // Por fecha
                    if( arrayOfType[indexPath.row] == 1 ){
                        
                        cell.icon.image = UIImage(named: "clockRed")
                        
                        cell.title.text = arrayOfName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                        
                        let langStr: String = Locale.current.languageCode!
                        
                        if( langStr == "en" ){
                            cell.concept.text = "\(month[monthOfItem]) \(dayOfItem)"
                        } else {
                            cell.concept.text = "\(dayOfItem) de \(month[monthOfItem])"
                        }
                        
                        // Por kilómetros
                    } else {
                        
                        cell.icon.image = UIImage(named: "odometerRed")
                        cell.title.text = arrayOfName[indexPath.row].replacingOccurrences(of: "_", with: " ")
                        cell.concept.text = "\(arrayOfOdometer[indexPath.row]) Km"
                        
                    }
                    
                    
                    let langStr: String = Locale.current.languageCode!
                    
                    if( langStr == "en" ){
                        cell.nextMaintenance.text = "Incomplete"
                        cell.date.text = "Expirated since \(month[monthOfItem]) \(dayOfItem)"
                    } else {
                        cell.nextMaintenance.text = "Incompleto"
                        cell.date.text = "Vencido el \(dayOfItem) de \(month[monthOfItem])"
                    }
                    
                    
                    cell.selectionStyle = .none;
                    cell.mainView.backgroundColor = currentColorForCells
                    cell.nextMaintenance.textColor = currentColorForText
                    cell.title.textColor = currentColorForText
                    cell.date.textColor = currentColorForText
                    return cell
                }
                
                
                // No items
            }
            
            
            
        } else {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "noItemsCell", for: indexPath) as! noItemsCell
            
            cell.selectionStyle = .none;
            
            return cell
            
        }
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "reminderCell") as! reminderCell
        cell.selectionStyle = .none;
        return cell
    }
    
    //** Delete Option **//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if(arraysAreFilled){
            if( arrayPositionInTime[indexPath.row] == "Today" || TotalOfItems == 0 ){
                return false
            } else {
                return true
            }
        }
        
        return false
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // The only cell with type 2 is "Today" cell
        if( ( arrayOfType[indexPath.row] != 2 && ( arrayPositionInTime[indexPath.row] == "Past" && arrayOfProgress[indexPath.row] != 1 ) ) || arrayPositionInTime[indexPath.row] == "Future" ){
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    if(self.arrayOfType[indexPath.row] == 1){
                        self.editView.alpha = 1
                        self.isEditingReminder = true
                        self.editDateReminder(id: indexPath.row)
                    } else {
                        self.editKilometersView.alpha = 1
                        self.isEditingReminder = true
                        self.editKilometersReminder(id: indexPath.row)
                    }
                })
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == .delete){
            deleteReminder(id: indexPath.row)
        }
    }
    
}
