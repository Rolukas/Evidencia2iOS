//
//  GuardModeViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/24/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import Firebase

//** Activity Cell Components **//
class activityCell: UITableViewCell, UITextFieldDelegate{
    
    // Outlets
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var activitySwitch: UISwitch!
    @IBOutlet weak var mondayLabelActivity: UILabel!
    @IBOutlet weak var tuesdayLabelActivity: UILabel!
    @IBOutlet weak var wednesdayLabelActivity: UILabel!
    @IBOutlet weak var thursdayLabelActivity: UILabel!
    @IBOutlet weak var fridayLabelActivity: UILabel!
    @IBOutlet weak var saturdayLabelActivity: UILabel!
    @IBOutlet weak var sundayLabelActivity: UILabel!
    
}

class guardModeNoItemsCell: UITableViewCell{
    @IBOutlet var noItemsText: UILabel!
}

class GuardModeViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    //**** Outlets ****//
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var guardModeTitleLabel: UILabel!
    @IBOutlet weak var alertNewAlarm: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var guardModeTitle: UILabel!
    //** Alert **//
    @IBOutlet weak var firstHourButton: UIButton!
    @IBOutlet weak var secondHourButton: UIButton!
    @IBOutlet weak var labelNameLabel: UITextField!
    @IBOutlet weak var newAlarmButton: UIButton!
    // Circle Buttons of Alert
    @IBOutlet weak var mondayCircle: UIButton!
    @IBOutlet weak var tuesdayCircle: UIButton!
    @IBOutlet weak var wednesdayCircle: UIButton!
    @IBOutlet weak var thursdayCircle: UIButton!
    @IBOutlet weak var fridayCircle: UIButton!
    @IBOutlet weak var saturdayCircle: UIButton!
    @IBOutlet weak var sundayCircle: UIButton!
    // Letters inside circles
    @IBOutlet weak var mondayAlertLabel: UILabel!
    @IBOutlet weak var tuesdayAlertLabel: UILabel!
    @IBOutlet weak var wednesdayAlertLabel: UILabel!
    @IBOutlet weak var thursdayAlertLabel: UILabel!
    @IBOutlet weak var fridayAlertLabel: UILabel!
    @IBOutlet weak var saturdayAlertLabel: UILabel!
    @IBOutlet weak var sundayAlertLabel: UILabel!
    
    //** Pickers **//
    
    // Picker One
    @IBOutlet weak var pickerOneView: UIView! // View
    @IBOutlet weak var datePickerHourOne: UIDatePicker! // Picker
    @IBOutlet weak var startHourLabelPicker: UILabel! // Label
    @IBOutlet weak var saveButtonHourOnePicker: UIButton! // Save Button
    @IBOutlet weak var cancelButtonHourOnePicker: UIButton! // Cancel Button
    
    // Picker Two
    @IBOutlet weak var pickerTwoView: UIView! // View
    @IBOutlet weak var datePickerHourTwo: UIDatePicker! // Picker
    @IBOutlet weak var endHourLabelPicker: UILabel! // Label
    @IBOutlet weak var saveButtonHourTwoPicker: UIButton! // Save Button
    @IBOutlet weak var cancelButtonHourTwoPicker: UIButton! // Cancel Button
    
    // Alert labels
    @IBOutlet weak var scheduleLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var saveAlertButton: UIButton!
    @IBOutlet weak var cancelAlertButton: UIButton!
    @IBOutlet weak var labelLabel: UILabel!
    
    
    
    // Structs
    struct Response: Codable {
        var items: [item]
        var message: String
        var success: Bool
    }
    
    struct item: Codable {
        var configId: Int
        var days: String
        var endHour: String
        var isActive: Bool
        var label: String
        var offset: Int
        var position: Int?
        var startHour: String
        var timeZone: String
        var vehicleId: Int
    }
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    //** Cycle Manage **//
    var i: Int = 0
    //** Total items in array **//
    var TotalItemsInArray: Int = 0
    //** VehicleID **//
    var vehicleId: Int = 0
    //** Arrays of data **//
    var days = [String]()
    var daysOnString = [String]()
    var ArrayConcepts = [String?]()
    var ArrayIsActive = [Bool?]()
    var ArrayActiveDays = [String?]()
    var ArrayConfigId = [Int?]()
    var ArrayWithEachActiveDay = [[String]]()
    var ArrayStartHours = [String?]()
    var ArrayEndHours = [String?]()
    var stringSelectedDays = String()
    var currentConfigId = Int()
    //Alert days selected
    var ArraySelectedDaysOnAlarm = [Bool]()
    
    //Hours Selected
    var HourOneSelected: String = "12:00"// Hour saved on picker ONE
    var HourTwoSelected: String = "23:00" // Hour saved on picker TWO
    var Context: String = "Create" // Is Editing or creating
    // Separator to translate
    var andSeparator: String = ""
    var toSeparator: String = ""
    
    // iOS 13 DarkMode
    var currentColorForText = UIColor()
    
    // GET/POST/DELETE data
    var currentTimeZone: String = ""
    var timeZoneOffset = Double() // Hours between current Zone and UTC
    var localTimeZoneName = String() // Local time zone name Example: "America/Mexico_City"
    
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
        
        //Hide the alert and pickers
        alertNewAlarm.alpha = 0
        pickerOneView.alpha = 0
        pickerTwoView.alpha = 0
        transparentView.alpha = 0
        labelNameLabel.delegate = self
        
        setText()
        //** current time zone **//
        currentTimeZone = Calendar.current.timeZone.abbreviation()!
       
        // Local time zone
        var localTimeZoneNameHandler: String { return TimeZone.current.identifier }
        localTimeZoneName = localTimeZoneNameHandler
        
        // timeZoneOffSet
        let date = Date()
        timeZoneOffset = ((Double(TimeZone.current.secondsFromGMT(for: date)))/60)/60 // Hours between current time zone and UTC
        
        // Initialize the process to get the alarms
        getAlarms()
        
        //** Pickers Text Color and Format **//
        
        //** DENMARK HAS A 24 HOUR TIME FORMAT **//
        datePickerHourOne.setValue( UIColor.white , forKeyPath: "textColor")
        datePickerHourOne.datePickerMode = UIDatePicker.Mode.time
        datePickerHourOne.locale = NSLocale(localeIdentifier: "da_DK") as Locale // Denmark 24 hrs format
        
        datePickerHourTwo.setValue( UIColor.white , forKeyPath: "textColor")
        datePickerHourTwo.datePickerMode = UIDatePicker.Mode.time
        datePickerHourTwo.locale = NSLocale(localeIdentifier: "da_DK") as Locale // Denmark 24 hrs format
        
        //** Set functions to value changed in pickers **//
        datePickerHourOne.addTarget(self, action: #selector(GuardModeViewController.pickerOneChanged), for: .valueChanged)
        
        datePickerHourTwo.addTarget(self, action: #selector(GuardModeViewController.pickerTwoChanged), for: .valueChanged)
        
        //** language **//
        let langStr: String = Locale.current.languageCode!
        
        // Days on english
        if( langStr == "en" ){
            guardModeTitle.text = "Guard Mode"
            days = ["M","T","W","Th","F","S","Su"]
            daysOnString = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            andSeparator = "and"
            toSeparator = "to"
            // Days on spanish
        } else {
            guardModeTitle.text = "Modo Guardia"
            days = ["L","M","Mi","J","V","S","D"]
            daysOnString = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
            andSeparator = "y"
            toSeparator = "a"
        }
        
        //** Set title **//
        guardModeTitleLabel.text = NSLocalizedString("guardMode_Title", comment: "guardMode_Title")
        
        //** Underline Labels **//
        labelNameLabel.underlinedGreen()
        firstHourButton.underlinedGreen()
        secondHourButton.underlinedGreen()
        
        //** Button Add Alarm **//
        let tap = UITapGestureRecognizer(target:self, action: #selector(GuardModeViewController.openAlert))
        newAlarmButton.addGestureRecognizer(tap)
        newAlarmButton.isUserInteractionEnabled = true
        
        let ButtonAdd = UIImage(named:"add")
        newAlarmButton.setImage(ButtonAdd, for: .normal)
        newAlarmButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
        setAlarmInitialValues() // Set the inital status of the Alarm Alert
        
        // When the user taps another item, hide the keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Keyboard Observers to Show/Hide the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(GuardModeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GuardModeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        print("GUARD MODE FIREBASE")
        Analytics.logEvent("guardian_mode_activity", parameters: nil)
    }
    
    func setLightModeSettings(){
        currentColorForText = UIColor(named: "grayBackground")!
        
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .white
        alertNewAlarm.backgroundColor = .white
//        alertNewAlarm.layer.shadowColor = UIColor.black.cgColor
        self.scheduleLabel.textColor = self.currentColorForText
        self.toLabel.textColor = self.currentColorForText
        self.startLabel.textColor = self.currentColorForText
        self.endLabel.textColor = self.currentColorForText
        self.daysLabel.textColor = self.currentColorForText
        self.labelLabel.textColor = self.currentColorForText
        self.cancelAlertButton.setTitleColor(self.currentColorForText, for: .normal)
    }
       
   func setDarkModeSettings(){
        currentColorForText = .white
    
        self.view.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.tableView.backgroundColor = UIColor(hexString: "#1B1C20")!
        alertNewAlarm.backgroundColor = UIColor(hexString: "#1B1C20")!
//        alertNewAlarm.layer.shadowColor = UIColor.white.cgColor
        self.scheduleLabel.textColor = self.currentColorForText
        self.toLabel.textColor = self.currentColorForText
        self.startLabel.textColor = self.currentColorForText
        self.endLabel.textColor = self.currentColorForText
        self.daysLabel.textColor = self.currentColorForText
        self.labelLabel.textColor = self.currentColorForText
        self.cancelAlertButton.setTitleColor(self.currentColorForText, for: .normal)
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
    
    func setText(){
        scheduleLabel.text = NSLocalizedString("guard_Mode_schedule", comment: "guard_Mode_schedule")
        startLabel.text = NSLocalizedString("guard_Mode_startLabel", comment: "guard_Mode_startLabel")
        endLabel.text = NSLocalizedString("guard_Mode_endLabel", comment: "guard_Mode_endLabel")
        daysLabel.text = NSLocalizedString("guard_Mode_daysLabel", comment: "guard_Mode_daysLabel")
        labelLabel.text = NSLocalizedString("guard_Mode_labelLabel", comment: "guard_Mode_labelLabel")
        cancelAlertButton.setTitle(NSLocalizedString("guard_Mode_cancelButton", comment: "guard_Mode_cancelButton"), for: .normal)
        saveAlertButton.setTitle(NSLocalizedString("guard_Mode_saveButton", comment: "guard_Mode_saveButton"), for: .normal)
        saveButtonHourOnePicker.setTitle(NSLocalizedString("guard_Mode_saveButton", comment: "guard_Mode_saveButton"), for: .normal)
        saveButtonHourTwoPicker.setTitle(NSLocalizedString("guard_Mode_saveButton", comment: "guard_Mode_saveButton"), for: .normal)
        cancelButtonHourOnePicker.setTitle(NSLocalizedString("guard_Mode_cancelButton", comment: "guard_Mode_cancelButton"), for: .normal)
        cancelButtonHourTwoPicker.setTitle(NSLocalizedString("guard_Mode_cancelButton", comment: "guard_Mode_cancelButton"), for: .normal)
        startHourLabelPicker.text = NSLocalizedString("guard_Mode_startHourLabel", comment: "guard_Mode_startHourLabel")
        endHourLabelPicker.text = NSLocalizedString("guard_Mode_endHourLabel", comment: "guard_Mode_endHourLabel")
    }
    
    // Max length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 15
    }
    
    //** Value changed in picker ONE **//
    @objc func pickerOneChanged(sender: UIDatePicker){
        
        //** Format of value **//
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm"
        
        // String in "14:53" format
        let StringHourOneSelected = formater.string(from: sender.date)
        let time = StringHourOneSelected.components(separatedBy: ":")
        let hour = time[0]
        let minutes = time[1]
        
        // Save the Hour selected
        if(hour == "00"){
            HourOneSelected = "00:\(minutes)"
        } else {
            HourOneSelected = StringHourOneSelected
        }

    }
    
    //** Value changed in picker TWO **//
    @objc func pickerTwoChanged(sender: UIDatePicker){
        
        //** Format of value **//
        let formater = DateFormatter()
        formater.dateFormat = "HH:mm"
        
        // String in "14:53" format
        let StringHourTwoSelected = formater.string(from: sender.date)
        
        // Save the Hour selected
        HourTwoSelected = StringHourTwoSelected
    
    }
    
    // Show the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // Hide the keyboard
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // Set Alarm Values
    func setAlarmInitialValues(){
        
        // days of the week
        mondayAlertLabel.text = days[0]
        tuesdayAlertLabel.text = days[1]
        wednesdayAlertLabel.text = days[2]
        thursdayAlertLabel.text = days[3]
        fridayAlertLabel.text = days[4]
        saturdayAlertLabel.text = days[5]
        sundayAlertLabel.text = days[6]
        
        // Selected days all off
        ArraySelectedDaysOnAlarm = [
            false, // Monday
            false, // Tuesday
            false, // Wednesday
            false, // Thursday
            false, // Friday
            false, // Saturday
            false  // Sunday
        ]
        
        // Placeholder of alarm name
        labelNameLabel.placeholder = NSLocalizedString("guard_Label_placeholder", comment: "guard_Label_placeholder")
    }
    
    //** Open the alert **//
    @objc func openAlert() {
    
        if(Context != "Edit"){
            firstHourButton.setTitle("12:00", for: .normal)
            secondHourButton.setTitle("23:00", for: .normal)
        }
        
        //Show the alert
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alertNewAlarm.alpha = 1
            self.transparentView.alpha = 1
        })
    }
    
    // Get all the alarms
    func getAlarms(){
        
        // Check internet connection
        if CheckInternet.Connection(){
            
            //** Remove all the data for new information **//
            ArrayConcepts.removeAll()
            ArrayIsActive.removeAll()
            ArrayActiveDays.removeAll()
            ArrayConfigId.removeAll()
            ArrayWithEachActiveDay.removeAll()
            ArrayStartHours.removeAll()
            ArrayEndHours.removeAll()
            
            // Get loads
            let url : NSString  = "https://rastreo.resser.com/api/guardianalertmobile?vehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        // Response
                        let response = try JSONDecoder().decode(Response.self, from: data)
                        // Items in response
                        let alarms = response.items
                        // Total of items
                        self.TotalItemsInArray = alarms.count
                       
                        if(self.TotalItemsInArray > 0){
                            
                            self.i = 0  // control cycle
                            
                            for alarm in alarms{
                                self.ArrayConcepts.append(alarm.label)
                                self.ArrayIsActive.append(alarm.isActive)
                                self.ArrayActiveDays.append(alarm.days)
                                self.ArrayConfigId.append(alarm.configId)
                                self.ArrayStartHours.append(alarm.startHour)
                                self.ArrayEndHours.append(alarm.endHour)
                                
                                self.i = self.i + 1
                            }
                            
                            // Convert the days string to separated strings
                            self.getDaysOfEachItem()
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    } catch {
                        
                        print("Error on GuardMode Get: ")
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
    
    // Function executed when a day is selected on the alert
    //** TouchInside Functions to detect the selected day **//
    func onSelectDay(day: Int){
        // Change the status of the day, the image, and text color
        switch day {
        // Monday
        case 0:
            
            if( !ArraySelectedDaysOnAlarm[0] ){
                
                mondayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                mondayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[0] = true
                
            } else {
                
                mondayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                mondayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[0] = false
                
            }
            
            break
        // Tuesday
        case 1:
            
            if( !ArraySelectedDaysOnAlarm[1] ){
                
                tuesdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                tuesdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[1] = true
                
            } else {
                
                tuesdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                tuesdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[1] = false
                
            }
            
            break
        // Wednesday
        case 2:
            
            if( !ArraySelectedDaysOnAlarm[2] ){
                
                wednesdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                wednesdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[2] = true
                
            } else {
                
                wednesdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                wednesdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[2] = false
                
            }
            
            break
        // Thursday
        case 3:
            
            if( !ArraySelectedDaysOnAlarm[3] ){
                
                thursdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                thursdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[3] = true
                
            } else {
                
                thursdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                thursdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[3] = false
                
            }
            
            break
        // Friday
        case 4:
            
            if( !ArraySelectedDaysOnAlarm[4] ){
                
                fridayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                fridayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[4] = true
                
            } else {
                
                fridayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                fridayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[4] = false
            }
            
            break
        // Saturday
        case 5:
            
            if( !ArraySelectedDaysOnAlarm[5] ){
                
                saturdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                saturdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[5] = true
                
            } else {
                
                saturdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                saturdayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[5] = false
            }
            
            break
        // Sunday
        case 6:
            
            if( !ArraySelectedDaysOnAlarm[6] ){
                
                sundayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                sundayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[6] = true
                
            } else {
                
                sundayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
                sundayAlertLabel.textColor = UIColor.white
                ArraySelectedDaysOnAlarm[6] = false
            }
            
            break
            
        default:
            break
        }
    
    }
    
    //** Convert string of Days to Array "1,2,5,7" -> [1,2,4,7] **//
    func getDaysOfEachItem(){
        
        for string in ArrayActiveDays{
            let StringSeparated = string?.components(separatedBy: ",") ?? [""]
            ArrayWithEachActiveDay.append(StringSeparated)
        }
        
    }
    
    //** Clear the context if the user closes the modal or in a complete function **//
    func clearAllAlarmContext(){
        
        DispatchQueue.main.async {
            //Close the alert
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alertNewAlarm.alpha = 0
                self.transparentView.alpha = 0
            })
        }
        
        // Selected days all off
        ArraySelectedDaysOnAlarm = [
            false, // Monday
            false, // Tuesday
            false, // Wednesday
            false, // Thursday
            false, // Friday
            false, // Saturday
            false  // Sunday
        ]
        
        labelNameLabel.text = ""
        
        //** PUT ALL THE DAYS OFF **//
        mondayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        mondayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[0] = false
        tuesdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        tuesdayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[1] = false
        wednesdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        wednesdayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[2] = false
        thursdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        thursdayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[3] = false
        fridayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        fridayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[4] = false
        saturdayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        saturdayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[5] = false
        sundayCircle.setImage(UIImage(named: "grayCircle"), for: .normal)
        sundayAlertLabel.textColor = UIColor.white
        ArraySelectedDaysOnAlarm[6] = false
        
        HourOneSelected = "12:00"
        HourTwoSelected = "23:00"
        stringSelectedDays = ""
        currentConfigId = 0
        Context = "Create"
    }
    
    //** Save Current Alarm  and show the alert in human language **//
    @IBAction func onSaveAlarm(_ sender: Any) {
        
        DispatchQueue.main.async {
            // Is editing or creating
            if( self.Context == "Create" ){
                // POST
                self.postAlarm()
                
            } else {
                // PUT
                self.putAlarm()
                
            }
            
        }
    
    }
    
    // Switches changed
    @objc func switchChanged(_ sender : UISwitch!){
        DispatchQueue.main.async {
            self.putAlarmSwitch(id: sender.tag)
        }
    }
    
    //** Put to alarm when switch is tapped **//
    func putAlarmSwitch(id: Int){
        DispatchQueue.main.async {
            if CheckInternet.Connection(){
                
                // Make the string based on selected days -> Example "1,2,3,4"
                
                self.stringSelectedDays = ""
                self.i = 0
                
                for day in self.ArraySelectedDaysOnAlarm {
                    if( self.ArraySelectedDaysOnAlarm[self.i] == true ){
                        if(self.i == 0){
                            
                            self.stringSelectedDays += String(self.i + 1)
                            
                        } else {
                            
                            self.stringSelectedDays += ("," + String(self.i + 1))
                            
                        }
                    }
                    
                    self.i += 1
                }

                var set = Bool()
                if(self.ArrayIsActive[id] == true){
                    set = false
                } else {
                    set = true
                }
                
                let dictionary = [
                    "vehicleId": CurrentVehicleInfo.VehicleId,
                    "configId": self.ArrayConfigId[id] ?? "",
                    "label": self.ArrayConcepts[id] ?? "N/A",
                    "isActive": set,
                    "startHour": self.ArrayStartHours[id] ?? "10:00",
                    "endHour": self.ArrayEndHours[id] ?? "23:59",
                    "days": self.ArrayActiveDays[id] ?? "1,5",
                    "offset": self.timeZoneOffset,
                    "timeZone": self.localTimeZoneName
                ] as [String : Any]
                
                let url = "https://rastreo.resser.com/api/guardianalertmobile"
                let URL: Foundation.URL = Foundation.URL(string: url)!
                let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
                request.httpMethod = "PUT"
                
                let jsonData = try! JSONSerialization.data(withJSONObject: dictionary)
                
                let theJSONText = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                
                request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
                let loginString = NSString(format: "%@:%@", self.user, self.pass)
                let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
                let base64LoginString = loginData.base64EncodedString(options: [])
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
                let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
                
                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                    
                    if error != nil {
                        
                        //handle error
                        print("====ERROR FROM GUARD MODE POST====")
                        print(error ?? "LOL")
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                    } else {
                        DispatchQueue.main.async {
                            self.Alert(Title: "Success", Message: "Alarma actualizada")
                        }
                        
                        self.getAlarms() // reload the data
                    }
                    
                    
                }
                dataTask.resume()
                // No internet connection
            } else {
                
                self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
                
            }
            
        }
        
    }
    
    //** Put to alarm **//
    func putAlarm(){
        DispatchQueue.main.async {
            if CheckInternet.Connection(){
                
                // Make the string based on selected days -> Example "1,2,3,4"
                
                self.stringSelectedDays = ""
                self.i = 0
                
                for day in self.ArraySelectedDaysOnAlarm {
                    if( self.ArraySelectedDaysOnAlarm[self.i] == true ){
                        if(self.i == 0){
                            
                            self.stringSelectedDays += String(self.i + 1)
                            
                        } else {
                            
                            self.stringSelectedDays += ("," + String(self.i + 1))
                            
                        }
                    }
                    
                    self.i += 1
                }

                let dictionary = [
                    "vehicleId": CurrentVehicleInfo.VehicleId,
                    "configId": self.currentConfigId,
                    "label": self.labelNameLabel.text ?? "",
                    "isActive": true,
                    "startHour": self.HourOneSelected,
                    "endHour": self.HourTwoSelected,
                    "days": self.stringSelectedDays,
                    "offset": self.timeZoneOffset,
                    "timeZone": self.localTimeZoneName
                ] as [String : Any]
                
                
                let url = "https://rastreo.resser.com/api/guardianalertmobile"
                let URL: Foundation.URL = Foundation.URL(string: url)!
                let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
                request.httpMethod = "PUT"
                
                let jsonData = try! JSONSerialization.data(withJSONObject: dictionary)
                
                let theJSONText = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                
                request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
                let loginString = NSString(format: "%@:%@", self.user, self.pass)
                let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
                let base64LoginString = loginData.base64EncodedString(options: [])
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
                let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
                
                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                    
                    if error != nil {
                        
                        //handle error
                        print("====ERROR FROM GUARD MODE POST====")
                        print(error ?? "LOL")
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                    } else {
                        self.successOnSaveAlarm() // Present the alert in human language
                        self.getAlarms() // reload the data
                    }
                    
                    
                }
                dataTask.resume()
                // No internet connection
            } else {
                
                self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
                
            }
            
        }
        
    }
    
    //** Post to alarm **//
    func postAlarm(){
        DispatchQueue.main.async {
            if CheckInternet.Connection(){
                
                // Make the string based on selected days -> Example "1,2,3,4"
                
                self.stringSelectedDays = ""
                self.i = 0
                
                for day in self.ArraySelectedDaysOnAlarm {
                    if( self.ArraySelectedDaysOnAlarm[self.i] == true ){
                        if(self.i == 0){
                            
                            self.stringSelectedDays += String(self.i + 1)
                            
                        } else {
                            
                            self.stringSelectedDays += ("," + String(self.i + 1))
                            
                        }
                    }
                    
                    self.i += 1
                }
                
                
                let dictionary = [
                    "vehicleId": CurrentVehicleInfo.VehicleId,
                    "label": self.labelNameLabel.text ?? "",
                    "isActive": true,
                    "startHour": self.HourOneSelected,
                    "endHour": self.HourTwoSelected,
                    "days": self.stringSelectedDays,
                    "offset": self.timeZoneOffset,
                    "timeZone": self.localTimeZoneName
                ] as [String : Any]
                
                print(dictionary)
                
                let url = "https://rastreo.resser.com/api/guardianalertmobile"
                let URL: Foundation.URL = Foundation.URL(string: url)!
                let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
                request.httpMethod = "POST"
                
                let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: JSONSerialization.WritingOptions(rawValue: 0))
                let theJSONText = NSString(data: theJSONData!,
                                           encoding: String.Encoding.ascii.rawValue)
                
                request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
                let loginString = NSString(format: "%@:%@", self.user, self.pass)
                let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
                let base64LoginString = loginData.base64EncodedString(options: [])
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
                let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
                
                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                    
                    if error != nil {
                        
                        //handle error
                        print("====ERROR FROM GUARD MODE POST====")
                        print(error ?? "LOL")
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                        
                    } else {
                        self.successOnSaveAlarm() // Present the alert in human language
                        self.getAlarms() // reload the data
                    }
                    
                    
                }
                dataTask.resume()
                // No internet connection
            } else {
                
                self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
                
            }
            
        }
        
    }
    
    //** Present the success on the alarm **//
    func successOnSaveAlarm(){
        // Hours and minutes of the first hour
        let HourOneString = HourOneSelected.split(separator: ":")[0]
        let MinutesOneString = HourOneSelected.split(separator: ":")[1]
        // Hours and minutes of the second hour
        let HourTwoString = HourTwoSelected.split(separator: ":")[0]
        let MinutesTwoString = HourTwoSelected.split(separator: ":")[1]
        
        // To Int
        let HourOne: Int = Int(HourOneString) ?? 0
        let MinutesOne: Int = Int(MinutesOneString) ?? 0
        let HourTwo: Int = Int(HourTwoString) ?? 0
        let MinutesTwo: Int = Int(MinutesTwoString) ?? 0
        
        //** Human Language **//
        var stringDaysSelected: String = ""
        var numberOfFirstDaySelected: Int = 0
        var alertString = ""
        
        DispatchQueue.main.async {
            //** Label cannot be empty **//
            if( (self.labelNameLabel.text)?.trimmingCharacters(in: .whitespaces) == ""){
                
                let info = UIAlertController(title: NSLocalizedString("guard_ErrorTitleAlert", comment: "guard_ErrorTitleAlert"),
                                             message: NSLocalizedString("guard_EmptyLabel_alert", comment: "guard_EmptyLabel_alert"),
                                             preferredStyle: .alert)
                
                self.present(info, animated: true, completion:  nil)
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    info.dismiss(animated: true, completion: nil)
                }
                
                //** Week cannot be empty **//
            } else if(
                
                !self.ArraySelectedDaysOnAlarm[0] &&
                    !self.ArraySelectedDaysOnAlarm[1] &&
                    !self.ArraySelectedDaysOnAlarm[2] &&
                    !self.ArraySelectedDaysOnAlarm[3] &&
                    !self.ArraySelectedDaysOnAlarm[4] &&
                    !self.ArraySelectedDaysOnAlarm[5] &&
                    !self.ArraySelectedDaysOnAlarm[6]
                ){
                
                let info = UIAlertController(title: NSLocalizedString("guard_ErrorTitleAlert", comment: "guard_ErrorTitleAlert"),
                                             message: NSLocalizedString("guard_EmptyDays_alert", comment: "guard_EmptyDays_alert"),
                                             preferredStyle: .alert)
                
                self.present(info, animated: true, completion:  nil)
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    info.dismiss(animated: true, completion: nil)
                }
                
                
                
                //** Workweek **//
            }else if(
                self.ArraySelectedDaysOnAlarm[0] &&
                    self.ArraySelectedDaysOnAlarm[1] &&
                    self.ArraySelectedDaysOnAlarm[2] &&
                    self.ArraySelectedDaysOnAlarm[3] &&
                    self.ArraySelectedDaysOnAlarm[4] &&
                    !self.ArraySelectedDaysOnAlarm[5] &&
                    !self.ArraySelectedDaysOnAlarm[6]
                ) {
                
                alertString = "\(NSLocalizedString("guard_HumanMessage_workweek", comment: "guard_HumanMessage_workweek")) \(self.HourOneSelected) \(self.toSeparator) \(self.HourTwoSelected)"
                
                
                self.clearAllAlarmContext()
                
                let refreshAlert = UIAlertController(title: NSLocalizedString("guard_Success_Title", comment: "guard_Success_Title"), message: alertString, preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                
                //** Weekend **//
            } else if(
                !self.ArraySelectedDaysOnAlarm[0] &&
                    !self.ArraySelectedDaysOnAlarm[1] &&
                    !self.ArraySelectedDaysOnAlarm[2] &&
                    !self.ArraySelectedDaysOnAlarm[3] &&
                    !self.ArraySelectedDaysOnAlarm[4] &&
                    self.ArraySelectedDaysOnAlarm[5] &&
                    self.ArraySelectedDaysOnAlarm[6]
                ){
                
                
                alertString = "\(NSLocalizedString("guard_HumanMessage_weekend", comment: "guard_HumanMessage_weekend")) \(self.HourOneSelected) \(self.toSeparator) \(self.HourTwoSelected)"
                
                self.clearAllAlarmContext()
                
                let refreshAlert = UIAlertController(title: NSLocalizedString("guard_Success_Title", comment: "guard_Success_Title"), message: alertString, preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                
                // All week
            } else if(
                     self.ArraySelectedDaysOnAlarm[0] &&
                    self.ArraySelectedDaysOnAlarm[1] &&
                    self.ArraySelectedDaysOnAlarm[2] &&
                    self.ArraySelectedDaysOnAlarm[3] &&
                    self.ArraySelectedDaysOnAlarm[4] &&
                    self.ArraySelectedDaysOnAlarm[5] &&
                    self.ArraySelectedDaysOnAlarm[6]
                ){
                
                alertString = "\(NSLocalizedString("guard_HumanMessage_week", comment: "guard_HumanMessage_week")) \(self.HourOneSelected) \(self.toSeparator) \(self.HourTwoSelected)"
                
                self.clearAllAlarmContext()
                
                let refreshAlert = UIAlertController(title: NSLocalizedString("guard_Success_Title", comment: "guard_Success_Title"), message: alertString, preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                
            } else {
                
                
                self.i = 0 // cycle control
                
                for day in self.ArraySelectedDaysOnAlarm{
                    
                    // Search the first day selected
                    if( self.ArraySelectedDaysOnAlarm[self.i] ){
                        
                        // See which day is but in String format
                        if( self.i == 0 ){
                            
                            stringDaysSelected.append(self.daysOnString[0])
                            numberOfFirstDaySelected = 0
                            
                        } else if( self.i == 1 ){
                            
                            stringDaysSelected.append(self.daysOnString[1])
                            numberOfFirstDaySelected = 1
                            
                        } else if( self.i == 2 ){
                            
                            stringDaysSelected.append(self.daysOnString[2])
                            numberOfFirstDaySelected = 2
                            
                        } else if( self.i == 3 ){
                            
                            stringDaysSelected.append(self.daysOnString[3])
                            numberOfFirstDaySelected = 3
                            
                        } else if( self.i == 4 ){
                            
                            stringDaysSelected.append(self.daysOnString[4])
                            numberOfFirstDaySelected = 4
                            
                        } else if( self.i == 5 ){
                            
                            stringDaysSelected.append(self.daysOnString[5])
                            numberOfFirstDaySelected = 5
                            
                        } else if( self.i == 6 ){
                            
                            stringDaysSelected.append(self.daysOnString[6])
                            numberOfFirstDaySelected = 6
                            
                        }
                        
                        
                        break // the first day has been found, then exit.
                    }
                    
                    self.i = self.i + 1
                }
                
                self.i = 0 // cycle control
                
                // Last day
                for day in self.ArraySelectedDaysOnAlarm{
                    
                    // Search the first day selected
                    if( self.ArraySelectedDaysOnAlarm[self.i] ){
                        
                        // See which day is but in String format
                        if( self.i == 0  && numberOfFirstDaySelected != self.i ){
                            
                            stringDaysSelected.append(", \(self.daysOnString[0])")
                            
                        } else if( self.i == 1 && numberOfFirstDaySelected != self.i ){
                            
                            if( !self.ArraySelectedDaysOnAlarm[2] && !self.ArraySelectedDaysOnAlarm[3] && !self.ArraySelectedDaysOnAlarm[4] && !self.ArraySelectedDaysOnAlarm[5] && !self.ArraySelectedDaysOnAlarm[6] ){
                                stringDaysSelected.append(" \(self.andSeparator) \(self.daysOnString[1])")
                            } else {
                                stringDaysSelected.append(", \(self.daysOnString[1])")
                            }
                            
                        } else if( self.i == 2 && numberOfFirstDaySelected != self.i ){
                            
                            if( !self.ArraySelectedDaysOnAlarm[3] && !self.ArraySelectedDaysOnAlarm[4] && !self.ArraySelectedDaysOnAlarm[5] && !self.ArraySelectedDaysOnAlarm[6] ){
                                stringDaysSelected.append(" \(self.andSeparator) \(self.daysOnString[2])")
                            } else {
                                stringDaysSelected.append(", \(self.daysOnString[2])")
                            }
                            
                        } else if( self.i == 3 && numberOfFirstDaySelected != self.i ){
                            
                            if( !self.ArraySelectedDaysOnAlarm[4] && !self.ArraySelectedDaysOnAlarm[5] && !self.ArraySelectedDaysOnAlarm[6] ){
                                stringDaysSelected.append(" \(self.andSeparator) \(self.daysOnString[3])")
                            } else {
                                stringDaysSelected.append(", \(self.daysOnString[3])")
                            }
                            
                        } else if( self.i == 4 && numberOfFirstDaySelected != self.i ){
                            
                            if( !self.ArraySelectedDaysOnAlarm[5] && !self.ArraySelectedDaysOnAlarm[6] ){
                                stringDaysSelected.append(" \(self.andSeparator) \(self.daysOnString[4])")
                            } else {
                                stringDaysSelected.append(", \(self.daysOnString[4])")
                            }
                            
                        } else if( self.i == 5 && numberOfFirstDaySelected != self.i ){
                            
                            if( !self.ArraySelectedDaysOnAlarm[6] ){
                                stringDaysSelected.append(" \(self.andSeparator) \(self.daysOnString[5])")
                            } else {
                                stringDaysSelected.append(", \(self.daysOnString[5])")
                            }
                            
                        } else if( self.i == 6 && numberOfFirstDaySelected != self.i ){
                            
                            stringDaysSelected.append(" \(self.andSeparator) \(self.daysOnString[6])")
                            
                        }
                        // the last day to be selected is the lastDaySelectedString variable
                    }
                    
                    self.i = self.i + 1
                }
                
                // Hour one is greater than hour two
                if( HourOne > HourTwo || ( HourOne == HourTwo && MinutesOne == MinutesTwo ) ){
                    
                    alertString = "\(NSLocalizedString("guard_HumanMessage_HourOneGreater", comment: "guard_HumanMessage_HourOneGreater")) \(self.HourOneSelected) \(NSLocalizedString("guard_HumanMessage_HourOneGreater_Part2", comment: "guard_HumanMessage_HourOneGreater_Part2")) \(self.HourTwoSelected) \(NSLocalizedString("guard_HumanMessage_HourOneGreater_Part3", comment: "guard_HumanMessage_HourOneGreater_Part3")) \(stringDaysSelected)"
                    
                    self.clearAllAlarmContext()
                    
                    let refreshAlert = UIAlertController(title: NSLocalizedString("guard_Success_Title", comment: "guard_Success_Title"), message: alertString, preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                    }))
                    
                    self.present(refreshAlert, animated: true, completion: nil)
                    
                    // Hour two is greater than hour one
                } else {
                    
                    alertString = "\(NSLocalizedString("guard_HumanMessage_HourTwoGreater", comment: "guard_HumanMessage_HourTwoGreater")) \(self.HourOneSelected) \(NSLocalizedString("guard_HumanMessage_HourTwoGreater_Part2", comment: "guard_HumanMessage_HourTwoGreater_Part2")) \(self.HourTwoSelected) \(NSLocalizedString("guard_HumanMessage_HourTwoGreater_Part3", comment: "guard_HumanMessage_HourTwoGreater_Part3")) \(stringDaysSelected)"
                    
                    self.clearAllAlarmContext()
                    
                    let refreshAlert = UIAlertController(title: NSLocalizedString("guard_Success_Title", comment: "guard_Success_Title"), message: alertString, preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                    }))
                    
                    self.present(refreshAlert, animated: true, completion: nil)
                }
            }
        }
        
        
        
    }
    
    func deleteAlarm(id: Int){
        // Check internet connection
        if CheckInternet.Connection(){
            let idAlarm = ArrayConfigId[id] ?? 0
            // Get loads
            let url : NSString  = "https://rastreo.resser.com/api/guardianalertmobile?vehicleId=\(CurrentVehicleInfo.VehicleId)&configId=\(idAlarm)" as NSString
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
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        self.Alert(Title: "Eliminado", Message: "Alarma eliminada")
                        self.getAlarms()
                    } catch {
                        
                        print("Error on Delete alarm: ")
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
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //** Pickers functions **//
    
    // Open Picker One
    @IBAction func openPickerOne(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerOneView.alpha = 1
        })
    }
    
    // Cancel Picker One
    @IBAction func onCancelPickerOne(_ sender: Any) {
        HourOneSelected = "00:00" // default value
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerOneView.alpha = 0
        })
    }
    
    // Save Picker One
    @IBAction func onSavePickerOne(_ sender: Any) {
        firstHourButton.setTitle(HourOneSelected, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerOneView.alpha = 0
        })
    }
    
    // Open Picker Two
    @IBAction func openPickerTwo(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerTwoView.alpha = 1
        })
    }
    
    // Cancel Picker Two
    @IBAction func cancelPickerTwo(_ sender: Any) {
        HourTwoSelected = "00:00" // default value
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerTwoView.alpha = 0
        })
    }
    
    // Save Picker Two
    @IBAction func savePickerTwo(_ sender: Any) {
        secondHourButton.setTitle(HourTwoSelected, for: .normal)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerTwoView.alpha = 0
        })
    }
    
    //** Alarm circles touch events **//
    
    // Monday
    @IBAction func mondayCircleTouch(_ sender: Any) {
        onSelectDay(day: 0)
    }
    
    // Tuesday
    @IBAction func tuesdayCircleTouch(_ sender: Any) {
        onSelectDay(day: 1)
    }
    
    // Wednesday
    @IBAction func wednesdayCircleTouch(_ sender: Any) {
        onSelectDay(day: 2)
    }
    
    // Thursday
    @IBAction func thursdayCircleTouch(_ sender: Any) {
        onSelectDay(day: 3)
    }
    
    // Friday
    @IBAction func fridayCircleTouch(_ sender: Any) {
        onSelectDay(day: 4)
    }
    
    // Saturday
    @IBAction func saturdayCircleTouch(_ sender: Any) {
        onSelectDay(day: 5)
    }
    
    // Sunday
    @IBAction func sundayCircleTouch(_ sender: Any) {
        onSelectDay(day: 6)
    }
    
    // Close the alert
    @IBAction func closeAlert(_ sender: Any) {
        clearAllAlarmContext()
    }
    
    // Return to menu
    @IBAction func returnToMenu(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Help Button
    @IBAction func onHelpButtonPress(_ sender: Any) {
        self.Alert(Title: NSLocalizedString("guard_Message_Title_Notificacion", comment: "guard_Message_Title_Notificacion"), Message: NSLocalizedString("guard_Message_Body_Notificacion", comment: "guard_Message_Body_Notificacion"))
      
    }
    
    
    
}

//** Extension for Tables **//
extension GuardModeViewController: UITableViewDataSource{
    
    //** Row Touched **//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var rowTouched: Int = indexPath.row
        
        // number of items in array must be greater than 0
        if(TotalItemsInArray != 0){
            
            Context = "Edit" // variable to know the context of the alert (edit/create alarm)
            // set hour buttons text
            firstHourButton.setTitle(ArrayStartHours[rowTouched], for: .normal)
            secondHourButton.setTitle(ArrayEndHours[rowTouched], for: .normal)
            // set hours
            HourOneSelected = ArrayStartHours[rowTouched] ?? ""
            HourTwoSelected = ArrayEndHours[rowTouched] ?? ""
            // set label
            labelNameLabel.text = ArrayConcepts[rowTouched] ?? ""
            currentConfigId = ArrayConfigId[rowTouched] ?? 0
            
            // Open the alert
            openAlert()
            
            // Set the days selected on that alarm
            for arrayOfDays in ArrayWithEachActiveDay[rowTouched]{
                for day in arrayOfDays{
                    
                    // Monday
                    if( day == "1" ){
                        mondayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        mondayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[0] = true
                        // Tuesday
                    } else if ( day == "2"){
                        tuesdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        tuesdayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[1] = true
                        // Wednesday
                    } else if ( day == "3" ){
                        wednesdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        wednesdayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[2] = true
                        // Thursday
                    } else if ( day == "4" ){
                        thursdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        thursdayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[3] = true
                        // Friday
                    } else if ( day == "5" ){
                        fridayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        fridayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[4] = true
                        // Saturday
                    } else if ( day == "6" ){
                        saturdayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        saturdayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[5] = true
                        // Sunday
                    } else if ( day == "7" ){
                        sundayCircle.setImage(UIImage(named: "greenCircle"), for: .normal)
                        sundayAlertLabel.textColor = UIColor.white
                        ArraySelectedDaysOnAlarm[6] = true
                    }
                    
                }
            }
            
        }
    }
    
    //** Number of sections **//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //** Intern Rows **//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(TotalItemsInArray == 0){
            return 1 // devolvemos la sección de "ingresa horarios"
        } else {
            return TotalItemsInArray // devolvemos los items
        }
        
    }
    
    //** Section sizes of the table **//
    func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //** Return the cell **//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
            
        case 0:
            //** The Array has items **//
            if(TotalItemsInArray > 0){
                
                //** cell type **//
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! activityCell
                
                // Set gray again all the data. (Reloading the data doesn't set on initial values again the labels, switch, etc...)
                cell.mondayLabelActivity.textColor = currentColorForText
                cell.tuesdayLabelActivity.textColor = currentColorForText
                cell.wednesdayLabelActivity.textColor = currentColorForText
                cell.thursdayLabelActivity.textColor = currentColorForText
                cell.fridayLabelActivity.textColor = currentColorForText
                cell.saturdayLabelActivity.textColor = currentColorForText
                cell.sundayLabelActivity.textColor = currentColorForText
                cell.activitySwitch.isOn = false
                
                //** Convert Optional to Specyfic type **//
                let Concept: String = ArrayConcepts[indexPath.row] ?? ""
                let isActive: Bool = ArrayIsActive[indexPath.row] ?? false
                
                
                
                //** Activity Description **//
                cell.activityDescriptionLabel.text = Concept
                //** Switch **//
                cell.activitySwitch.isOn = isActive
                //** Days ** //
                cell.mondayLabelActivity.text = days[0]
                cell.tuesdayLabelActivity.text = days[1]
                cell.wednesdayLabelActivity.text = days[2]
                cell.thursdayLabelActivity.text = days[3]
                cell.fridayLabelActivity.text = days[4]
                cell.saturdayLabelActivity.text = days[5]
                cell.sundayLabelActivity.text = days[6]
                //** Hours **//
                cell.startHourLabel.textColor = currentColorForText
                cell.endHourLabel.textColor = currentColorForText
                cell.startHourLabel.text = ArrayStartHours[indexPath.row]
                cell.endHourLabel.text = ArrayEndHours[indexPath.row]
            
                // This alarm is active
                if(isActive){
                    cell.activityDescriptionLabel.textColor = UIColor(named: "spotGreen")
                    
                    // Set each active day in label green
                    for arrayOfDays in ArrayWithEachActiveDay[indexPath.row]{
                        for day in arrayOfDays{
                            
                            // Monday
                            if( day == "1" ){
                                cell.mondayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                                // Tuesday
                            } else if ( day == "2"){
                                cell.tuesdayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                                // Wednesday
                            } else if ( day == "3" ){
                                cell.wednesdayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                                // Thursday
                            } else if ( day == "4" ){
                                cell.thursdayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                                // Friday
                            } else if ( day == "5" ){
                                cell.fridayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                                // Saturday
                            } else if ( day == "6" ){
                                cell.saturdayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                                // Sunday
                            } else if ( day == "7" ){
                                cell.sundayLabelActivity.textColor = UIColor(red: 124/255, green: 188/255, blue: 68/255, alpha: 1.0) // Green for active
                            }
                            
                        }
                    }
                    
                // This alarm is NOT active
                } else {
                    cell.activityDescriptionLabel.textColor = currentColorForText
                    cell.mondayLabelActivity.textColor = currentColorForText
                    cell.tuesdayLabelActivity.textColor = currentColorForText
                    cell.wednesdayLabelActivity.textColor = currentColorForText
                    cell.thursdayLabelActivity.textColor = currentColorForText
                    cell.fridayLabelActivity.textColor = currentColorForText
                    cell.saturdayLabelActivity.textColor = currentColorForText
                    cell.sundayLabelActivity.textColor = currentColorForText
                }
                
               
                
                cell.activitySwitch.tag = indexPath.row // for detect which row switch Changed
                cell.activitySwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                
                cell.selectionStyle = .none;
                return cell
                break
                
                //** The Array length = 0 **//
            } else {
                //** cell type **//
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "guardModeNoItemsCell", for: indexPath) as! guardModeNoItemsCell
                cell.selectionStyle = .none;
                cell.noItemsText.text = NSLocalizedString("guard_Mode_noAlarms", comment: "guard_Mode_noAlarms")
                
                return cell
                break
            }
            
        default:
            break
        }
        
        //** Add forced return (not executing) **//
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! activityCell
        return cell
    }
    
    //** Set On/Off the Delete option in Rows **//
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(TotalItemsInArray == 0){
            return false // "No alarms" cell cannot be deleted
        } else {
            return true
        }
    }
    
    //** Edit/Delete functions in rows **//
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            deleteAlarm(id: indexPath.row)
        }
    }
}
