//
//  MyVehicleViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/28/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import Firebase

class MyVehicleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    var arrayFuelType = ["Magna", "Premium", "Disel"]
    
    // To send data
    var id = Int()
    var Description = String()
    var Performance = Float()
    var Fuel = Int()
    var Kilometers = Float()
    var Speed = Int()
    var Address = String()
    var LastReport = String()
    var LicensePlate = String()
    var FuelTypeId = Int()
    var pickerData: [String] = [String]()
    var handlerFuelType = Int()
    // Engine Block
    var timesExecutedEngineBlock = Int()
    var isEngineBlockEnabled: Bool = false
    var timerBlockCheck : Timer = Timer()
    let timerBlockCheckTime : Double = 10
    
    //Structs
    
    // Vehicle Info
    struct Response: Codable {
        var success: Bool
        var items: [item]
        var serialNumber: String?
    }
    
    struct item: Codable {
        var id: Int
        var Description: String
        var Performance: Float
        var Fuel: Int
        var Kilometers: Float
        var Speed: Int
        var Address: String?
        var LastReport: String
        var LicensePlate: String?
        var FuelTypeId: Int
        var timesExecutedEngineBlock: Int
    }
    
    // Engine Block Response
    struct ResponseEngineBlock: Codable {
        var success: Bool
        var id: Int
        var prevState: String
        var mssg: String
        var queue: Bool
    }
    
    // Outlets
    @IBOutlet weak var fuelTypeLabel: UILabel!
    @IBOutlet weak var odometerLabel: UILabel!
    @IBOutlet weak var platesLabel: UILabel!
    @IBOutlet weak var vehicleNameLabel: UIButton!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var optionPicker: UIPickerView!
    @IBOutlet weak var cancelButtonPicker: UIButton!
    @IBOutlet weak var saveButtonPicker: UIButton!
    @IBOutlet weak var platesInfoLabel: UILabel!
    @IBOutlet weak var kilometersInfoLabel: UILabel!
    @IBOutlet weak var fuelTypeInfoLabel: UILabel!
    @IBOutlet weak var myVehicleTitle: UILabel!
    @IBOutlet var engineBlockLabel: UILabel!
    @IBOutlet var engineBlockSwitch: UISwitch!
    @IBOutlet var helpButtonEngineBlock: UIButton!
    @IBOutlet var seriesNumber: UILabel!
    @IBOutlet var seriesNumberInformation: UILabel!
    @IBOutlet var scrollableView: UIView!
    @IBOutlet var odometerIcon: UIImageView!
    @IBOutlet var fuelIcon: UIImageView!
    @IBOutlet var serialNumberIcon: UIImageView!
    @IBOutlet var platesIcon: UIImageView!
    @IBOutlet var platesBtn: UIButton!
    @IBOutlet var odometerBtn: UIButton!
    @IBOutlet var fuelTypeBtn: UIButton!
    
    
    
    
    override func viewDidLoad() {
        
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
        
        // When the user taps another item, hide the keyboard
        self.hideKeyboardWhenTappedAround()
        
        getMyVehicleInfo()
        pickerView.alpha = 0
        self.optionPicker.delegate = self as! UIPickerViewDelegate
        self.optionPicker.dataSource = self as! UIPickerViewDataSource
        pickerData = ["Magna", "Premium", "Diesel"]
        optionPicker.setValue( UIColor.white , forKeyPath: "textColor")
        //** language **//
        let langStr: String = Locale.current.languageCode!
        // english
        if( langStr == "en" ){
           myVehicleTitle.text = "My Vehicle"
            // spanish
        } else {
          myVehicleTitle.text = "Mi Vehículo"
        }
        
        // Texts
        platesInfoLabel.text = NSLocalizedString("Vehicle_Section_Placas", comment: "Vehicle_Section_Placas")
        kilometersInfoLabel.text = NSLocalizedString("vehicle_Section_Km", comment: "vehicle_Section_Km")
        fuelTypeInfoLabel.text = NSLocalizedString("vehicle_Section_Gas", comment: "vehicle_Section_Gas")
        cancelButtonPicker.setTitle(NSLocalizedString("vehicle_Block_Button_Cancel", comment: "vehicle_Block_Button_Cancel"), for: .normal)
        saveButtonPicker.setTitle(NSLocalizedString("vehicle_Block_Button_Accept", comment: "vehicle_Block_Button_Accept"), for: .normal)
        seriesNumber.text = NSLocalizedString("vehicle_Section_SeriesNumber", comment: "vehicle_Section_SeriesNumber")
        engineBlockSwitch.isEnabled = false
        
        Analytics.logEvent("my_vehicle_activity", parameters: nil)
    }
    
    func setLightModeSettings(){
        self.view.backgroundColor = .white
        self.scrollableView.backgroundColor = .white
           
        self.platesInfoLabel.textColor = UIColor(named:"grayBackground")
        self.kilometersInfoLabel.textColor = UIColor(named:"grayBackground")
        self.fuelTypeInfoLabel.textColor = UIColor(named:"grayBackground")
        self.seriesNumber.textColor = UIColor(named:"grayBackground")
       
        self.odometerIcon.image = UIImage(named:"ic_odometer")
        self.platesIcon.image = UIImage(named:"ic_plates")
        self.serialNumberIcon.image = UIImage(named:"ic_plates")
        self.fuelIcon.image = UIImage(named: "ic_gas")
        
        self.odometerBtn.setImage(UIImage(named: "ic_pencil"), for: .normal)
        self.fuelTypeBtn.setImage(UIImage(named: "ic_pencil"), for: .normal)
        self.platesBtn.setImage(UIImage(named: "ic_pencil"), for: .normal)
    }
       
    func setDarkModeSettings(){
        self.view.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.scrollableView.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.platesInfoLabel.textColor = .white
        self.kilometersInfoLabel.textColor = .white
        self.fuelTypeInfoLabel.textColor = .white
        self.seriesNumber.textColor = .white
        
        self.odometerIcon.image = UIImage(named:"ic_odometer_white")
        self.platesIcon.image = UIImage(named:"ic_plates_white")
        self.serialNumberIcon.image = UIImage(named:"ic_plates_white")
        self.fuelIcon.image = UIImage(named: "ic_gas_white")
        self.odometerBtn.setImage(UIImage(named: "ic_pencil_white"), for: .normal)
        self.fuelTypeBtn.setImage(UIImage(named: "ic_pencil_white"), for: .normal)
        self.platesBtn.setImage(UIImage(named: "ic_pencil_white"), for: .normal)
        
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

              }
              
          } else {
              // Fallback on earlier versions
          }
      }
    
    // Engine block help button
    @IBAction func engineBlockHelp(_ sender: Any) {
     
        Alert(Title: NSLocalizedString("vehicle_Section_EngineBlockTitle_New", comment: "vehicle_Section_EngineBlockTitle_New"), Message: NSLocalizedString("vehicle_Section_EngineBlockMessage_New", comment: "vehicle_Section_EngineBlockMessage_New"))
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        handlerFuelType = (row + 1)
    }
    
    @IBAction func updateFuelType(_ sender: Any) {
        FuelTypeId = handlerFuelType
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerView.alpha = 0
        })
        
        makePut()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerData[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
    
    @IBAction func closePickerView(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerView.alpha = 0
        })
    }
    
    func getMyVehicleInfo(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/vehiclesmobile?VehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
            print(url)
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
                        let vehicleInformation = try JSONDecoder().decode(Response.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            self.seriesNumberInformation.text = vehicleInformation.serialNumber ?? "N/R"
                            
                            var device = String()
                            
                            if((UIDevice.modelName).contains("Simulator ")){
                                device = (UIDevice.modelName).replacingOccurrences(of: "Simulator ", with: "")
                            } else {
                                device = UIDevice.modelName
                            }
                            
                            if ( device == "iPhone 5" || device == "iPhone 5s" || device == "iPhone SE" || device == "iPhone 5C" || device == "iPhone 5c" ){
                                self.seriesNumberInformation.font = self.seriesNumberInformation.font.withSize(14)
                            }
                            
                            for item in vehicleInformation.items {
                                self.vehicleNameLabel.setTitle(item.Description, for: .normal)
                                self.platesLabel.text = item.LicensePlate
                                let textOdometer = NSString(format: "%.2f", item.Kilometers) as String
                                self.odometerLabel.text = textOdometer
                                self.fuelTypeLabel.text = self.arrayFuelType[item.FuelTypeId - 1]
                                
                                // Fill variables
                                self.id = item.id
                                self.Description = item.Description
                                self.Performance = item.Performance
                                self.Fuel = item.Fuel
                                self.Kilometers = item.Kilometers
                                self.Speed = item.Speed
                                self.Address = item.Address ?? "N/A"
                                self.LastReport = item.LastReport
                                self.LicensePlate = item.LicensePlate ?? ""
                                self.FuelTypeId = item.FuelTypeId
                                self.timesExecutedEngineBlock = item.timesExecutedEngineBlock
                            }
                            
                            // No Engine Block
                            if( self.timesExecutedEngineBlock <= 0 ){
                                
                                self.engineBlockLabel.isHidden = true
                                self.engineBlockSwitch.isHidden = true
                                self.helpButtonEngineBlock.isHidden = true
                                
                            } else {
                                
                                self.getEngineBlockStatus()
                                
                            }
                            
                        }
                        
                        print("======= ENGINE BLOCK: \(self.timesExecutedEngineBlock) ============")
                        
                        // Error on get
                    } catch {
                        
                        print("Error on Valet Popup: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    // Activate/Desactivate Engine Block
    @IBAction func engineBlockPut(_ sender: Any) {
        //** El bloqueo esta inactivo **//
        if(isEngineBlockEnabled == true) {
            
            let notification = UIAlertController(title: NSLocalizedString("config_Unblock_Title_Ask", comment: "config_Unblock_Title_Ask"), message:NSLocalizedString("config_Unblock_Message_Ask", comment: "config_Unblock_Message_Ask"), preferredStyle:UIAlertController.Style.alert)
            notification.addAction(UIAlertAction(title:NSLocalizedString("config_Block_Cancel_Button", comment: "config_Block_Cancel_Button"), style:UIAlertAction.Style.cancel, handler: handleCancelBlockUnlock))
            notification.addAction(UIAlertAction(title:NSLocalizedString("config_Block_Accept_Button", comment: "config_Block_Accept_Button"), style:UIAlertAction.Style.default, handler:handleBlockUnlockEngine))
            
            self.present(notification, animated: true, completion: {
                print("Completion Block")
            })
            
        //** El bloqueo esta activo **//
        } else {
            
            let notification = UIAlertController(title: NSLocalizedString("config_Block_Title_Ask", comment: "config_Block_Title_Ask"), message: NSLocalizedString("config_Block_Message_Ask", comment: "config_Block_Message_Ask"), preferredStyle:UIAlertController.Style.alert)
            notification.addAction(UIAlertAction(title: NSLocalizedString("config_Block_Cancel_Button", comment: "config_Block_Cancel_Button"), style:UIAlertAction.Style.cancel, handler: handleCancelBlockUnlock))
            notification.addAction(UIAlertAction(title: NSLocalizedString("config_Block_Accept_Button", comment: "config_Block_Accept_Button"), style:UIAlertAction.Style.default, handler:handleBlockUnlockEngine))
            
            self.present(notification, animated: true, completion: {
                print("Completion Block")
            })
            
        }
    }
    
    // Cancel (Return to original status)
    func handleCancelBlockUnlock(_ alertView:UIAlertAction!) {
        DispatchQueue.main.async {
            if( self.engineBlockSwitch.isOn ){
                self.engineBlockSwitch.isOn = false
            } else {
                self.engineBlockSwitch.isOn = true
            }
        }
    }
    
    func handleBlockUnlockEngine(_ alertView:UIAlertAction!) {
        engineBlock()
    }
    
    func getEngineBlockStatus(){
        
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/AdvancedFunctionsBlockUnblock?vehicle=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        print("JSON ENGINE BLOCK RESPONSE")
                        print(json)
                        //Set the dictionary with the data
                        let engineBlockInfo = try JSONDecoder().decode(ResponseEngineBlock.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            // MARK: No tiene bloqueo de motor
                            if( (engineBlockInfo.mssg == "Usuario no tiene el equipo" && engineBlockInfo.success == false) || engineBlockInfo.mssg == "Error" ){
                                
                                self.engineBlockLabel.isHidden = true
                                self.engineBlockSwitch.isHidden = true
                                self.helpButtonEngineBlock.isHidden = true
                                
                            } else {
                                
                                //MARK: no se quedo pendiente ningun bloqueo o desbloqueo de motor
                                if( engineBlockInfo.mssg == "" || engineBlockInfo.mssg.isEmpty ) {
                                    
                                    self.engineBlockSwitch.isEnabled = true
                                    
                                    if( engineBlockInfo.prevState == "ENCENDER MOTOR" ){
                                        print("SE PUEDE APAGAR EL MOTOR:\(CurrentVehicleInfo.VehicleId)")
                                        self.isEngineBlockEnabled = false
                                        self.engineBlockSwitch.isOn = false
                                        self.engineBlockLabel.textColor = UIColor(named: "grayBackground")
                                    }
                                       
                                    
                                    if( engineBlockInfo.prevState ==  "APAGAR MOTOR" ){
                                        print("SE PUEDE ENCENDER EL MOTOR:\(CurrentVehicleInfo.VehicleId)")
                                        self.isEngineBlockEnabled = true
                                        self.engineBlockSwitch.isOn = true
                                        self.engineBlockLabel.textColor = UIColor(named: "spotGreen")
                                    }
                                    
                                    
                                } else {
                                    
                                    // Check the status recurrently after engine block/unblock
                                    self.timerBlockCheck = Timer.scheduledTimer(timeInterval: self.timerBlockCheckTime, target: self, selector: #selector(MyVehicleViewController.checkStatusEngineAfterFunction), userInfo: nil, repeats: true)
                                    
                                    //MARK: El motor esta activo y se encuentra en proceso de bloqueo.
                                    if( engineBlockInfo.prevState == "ENCENDER MOTOR" && engineBlockInfo.mssg == "APAGAR MOTOR" ){
                                        
                                        self.isEngineBlockEnabled = true
                                        self.engineBlockSwitch.isEnabled = false
                                        
                                        self.ShowAlert(NSLocalizedString("engine_Block_title_pending", comment: "engine_Block_title_pending"),
                                                       message: NSLocalizedString("engine_Block_body_pending", comment: "engine_Block_body_pending"),
                                                       dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                        
                                       
                                        
                                    //MARK: El motor esta desactivado y se encuentra en proceso de desbloqueo.
                                    } else if ( engineBlockInfo.prevState == "APAGAR MOTOR" && engineBlockInfo.mssg == "ENCENDER MOTOR" ){
                                        
                                        self.isEngineBlockEnabled = false
                                        self.engineBlockSwitch.isEnabled = false
                                        
                                        self.ShowAlert(NSLocalizedString("engine_Unlock_title_pending", comment: "engine_Unlock_title_pending"),
                                                       message: NSLocalizedString("engine_Unlock_body_pending", comment: "engine_Unlock_body_pending"),
                                                       dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
        
                    // Error on get
                    } catch {
                        
                        print("Error on getEngineBlockStatus: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
        
    }
    
    // Check the status recurrently after engine block/unblock
    @objc func checkStatusEngineAfterFunction(){
        
        print("ENTRA A CHECAR")
        
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/AdvancedFunctionsBlockUnblock?vehicle=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        print("JSON ENGINE BLOCK RESPONSE")
                        print(json)
                        //Set the dictionary with the data
                        let engineBlockInfo = try JSONDecoder().decode(ResponseEngineBlock.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            // MARK: No tiene bloqueo de motor
                            if( (engineBlockInfo.mssg == "Usuario no tiene el equipo" && engineBlockInfo.success == false) || engineBlockInfo.mssg == "Error" ){
                                
                                self.engineBlockLabel.isHidden = true
                                self.engineBlockSwitch.isHidden = true
                                self.helpButtonEngineBlock.isHidden = true
                                
    
                            } else {
                                
                                //MARK: no se quedo pendiente ningun bloqueo o desbloqueo de motor
                                if( engineBlockInfo.mssg == "" || engineBlockInfo.mssg.isEmpty ) {
                                    
                                    self.engineBlockSwitch.isEnabled = true
                                    self.timerBlockCheck.invalidate()
                                    
                                    if( engineBlockInfo.prevState == "ENCENDER MOTOR" && engineBlockInfo.mssg == "Función exitosa" ){
                                        
                                        
                                        self.isEngineBlockEnabled = false
                                        self.engineBlockSwitch.isOn = false
                                        self.engineBlockLabel.textColor = UIColor(named: "grayBackground")
                                        
                                        self.ShowAlert(NSLocalizedString("config_Engine_On_Success_Title", comment: "config_Engine_On_Success_Title"),
                                                       message: NSLocalizedString("config_Engine_On_Success_Body", comment: "config_Engine_On_Success_Body"),
                                                       dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                        
                                    }
                                    
                                    if( engineBlockInfo.prevState ==  "APAGAR MOTOR" && engineBlockInfo.mssg == "Función exitosa" ){
                                        
                                        self.isEngineBlockEnabled = true
                                        self.engineBlockSwitch.isOn = true
                                        self.engineBlockLabel.textColor = UIColor(named: "spotGreen")
                                        
                                        self.ShowAlert(NSLocalizedString("config_Engine_Off_Success_Title", comment: "config_Engine_Off_Success_Title"),
                                                       message: NSLocalizedString("config_Engine_Off_Success_Body", comment: "config_Engine_Off_Success_Body"),
                                                       dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                    }
                                    
                                    if( engineBlockInfo.prevState == "ENCENDER MOTOR" && engineBlockInfo.mssg == "" ){
                                        
                                        
                                        self.isEngineBlockEnabled = true
                                        self.engineBlockSwitch.isOn = false
                                        self.engineBlockLabel.textColor = UIColor(named: "grayBackground")
                                        
                                        self.ShowAlert(NSLocalizedString("config_Engine_On_Success_Title", comment: "config_Engine_On_Success_Title"),
                                                       message: NSLocalizedString("config_Engine_On_Success_Body", comment: "config_Engine_On_Success_Body"),
                                                       dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                        
                                    }
                                    
                                    if( engineBlockInfo.prevState ==  "APAGAR MOTOR" && engineBlockInfo.mssg == "" ){
                                        
                                        self.isEngineBlockEnabled = true
                                        self.engineBlockSwitch.isOn = true
                                        self.engineBlockLabel.textColor = UIColor(named: "spotGreen")
                                        
                                        self.ShowAlert(NSLocalizedString("config_Engine_Off_Success_Title", comment: "config_Engine_Off_Success_Title"),
                                                       message: NSLocalizedString("config_Engine_Off_Success_Body", comment: "config_Engine_Off_Success_Body"),
                                                       dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                    }
                                    
                                    
                                } else {
                                    
                                    //MARK: El motor esta activo y se encuentra en proceso de bloqueo.
                                    if( engineBlockInfo.prevState == "ENCENDER MOTOR" && engineBlockInfo.mssg == "APAGAR MOTOR" ){
                                        
                                        self.isEngineBlockEnabled = true
                                        self.engineBlockSwitch.isEnabled = false
                                        self.engineBlockSwitch.isOn = true
                                        self.engineBlockLabel.textColor = UIColor(named: "spotGreen")
                                     
                                
                                        
                                        //MARK: El motor esta desactivado y se encuentra en proceso de desbloqueo.
                                    } else if ( engineBlockInfo.prevState == "APAGAR MOTOR" && engineBlockInfo.mssg == "ENCENDER MOTOR" ){
                                        
                                        self.isEngineBlockEnabled = false
                                        self.engineBlockSwitch.isEnabled = false
                                        self.engineBlockSwitch.isOn = false
                                        self.engineBlockLabel.textColor = UIColor(named: "grayBackground")
                                        
                                     
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        // Error on get
                    } catch {
                        
                        print("Error on getEngineBlockStatus: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
        
    }
    
    
    func engineBlock(){
        
        
        /*
         0 -> Apagar
         1 -> Encender
         */
        
        DispatchQueue.main.async {
            if CheckInternet.Connection(){
        
                var dictionarySub = [:] as [String : Any]
                
                // BLOCK
                if( self.isEngineBlockEnabled ){
                    
                    dictionarySub = [
                        "vehicle": CurrentVehicleInfo.VehicleId,
                        "blockUnblock": 1
                    ] as [String : Any]
                    
                // UNBLOCK
                } else {
                    
                    dictionarySub = [
                        "vehicle": CurrentVehicleInfo.VehicleId,
                        "blockUnblock": 0
                    ] as [String : Any]
                    
                }
                
                print("POST ENGINE BLOCK: \(dictionarySub)")
                
                let url = "https://rastreo.resser.com/api/AdvancedFunctionsBlockUnblock"
                let URL: Foundation.URL = Foundation.URL(string: url)!
                let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
                request.httpMethod = "POST"
                
                let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionarySub,
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
                    
                    // ERROR
                    if error != nil {
                        
                        //handle error
                        print("====ERROR FROM EngineBlock====")
                        print(error ?? "LOL")
                        
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message") + "\(String(describing: error))")
                        
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            self.engineBlockSwitch.isEnabled = false
                        
                            if( self.isEngineBlockEnabled ){
                                
                                self.ShowAlert(NSLocalizedString("config_Engine_On_Title_Message", comment: "config_Engine_On_Title_Message"),
                                               message: NSLocalizedString("config_Engine_On_Body_Message", comment: "config_Engine_On_Body_Message"),
                                               dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                
                            } else {
                                
                                self.ShowAlert(NSLocalizedString("config_Engine_Off_Title_Message", comment: "config_Engine_Off_Title_Message"),
                                               message: NSLocalizedString("config_Engine_Off_Body_Message", comment: "config_Engine_Off_Body_Message"),
                                               dismiss: NSLocalizedString("close_button_Engine", comment: "close_button_Engine"))
                                
                            }
                            
                            // Check the status recurrently after engine block/unblock
                            self.timerBlockCheck = Timer.scheduledTimer(timeInterval: self.timerBlockCheckTime, target: self, selector: #selector(MyVehicleViewController.checkStatusEngineAfterFunction), userInfo: nil, repeats: true)
                            
                        }
                    }
                    
                }
                dataTask.resume()
                // No internet connection
            } else {
                
                self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
                
            }
            
        }
        
        
        
    }
    
    func makePut(){
    
        let dictionarySub = [
            "Address":  Address,
            "Description": Description,
            "Fuel": Fuel,
            "Kilometers": Kilometers,
            "LastReport": LastReport,
            "Performance": Performance,
            "Speed": Speed,
            "LicensePlate": LicensePlate,
            "FuelTypeId": FuelTypeId,
            "id": id
        ] as [String : AnyObject]
        
        let url = "https://rastreo.resser.com/api/vehiclesmobile/\(id)"
        let URL: Foundation.URL = Foundation.URL(string: url)!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
        request.httpMethod = "PUT"
        
        let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionarySub,
            options: JSONSerialization.WritingOptions(rawValue: 0))
        let theJSONText = NSString(data: theJSONData!,
                                   encoding: String.Encoding.ascii.rawValue)
        
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
                print("====ERROR FROM makePut====")
                print(error ?? "LOL")
                
                self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                
            } else {
                
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                self.getMyVehicleInfo()
                CurrentVehicleInfo.LicensePlate = self.LicensePlate // Fill the data
                self.Alert(Title: "Exito", Message: "Datos Actualizados")
                
            }
            
        }
        dataTask.resume()
    }
    
    @IBAction func editVehicleName(_ sender: Any) {
        DispatchQueue.main.async {
            let newAlert = UIAlertController(title: NSLocalizedString("vehicle_edit_name_title", comment: "vehicle_edit_name_title"), message: NSLocalizedString("vehicle_edit_name_message", comment: "vehicle_edit_name_message"), preferredStyle: UIAlertController.Style.alert)
            
            newAlert.addTextField { txtField in
                txtField.placeholder = NSLocalizedString("vehicle_edit_name_placeholder", comment: "vehicle_edit_name_placeholder")
                txtField.text = self.Description
            }
            
            //** Cancel Button **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("oil_Cancel_Option", comment: "oil_Cancel_Option"), style: .destructive, handler: { (action: UIAlertAction!) in
                
                newAlert.dismiss(animated: true, completion: nil)
            }))
            
            //** Save Button **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("oil_Save_Option", comment: "oil_Save_Option"), style: .default, handler: { (action: UIAlertAction!) in
                
                let textField = newAlert.textFields![0]
                let newVehicleName: String = textField.text ?? ""
                
                if (newVehicleName != ""){
                    self.Description = "\(newVehicleName)-\(self.id)"
                    self.makePut()
                    newAlert.dismiss(animated: true, completion: nil)
                } else {
                    newAlert.dismiss(animated: true, completion: nil)
                    self.Alert(Title: "ERROR", Message: "Cannot be Empty")
                }
                
            }))
            
            newAlert.view.tintColor = UIColor(named: "spotGreen")
            
            self.present(newAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func editPlates(_ sender: Any) {
        DispatchQueue.main.async {
            let newAlert = UIAlertController(title: NSLocalizedString("vehicle_edit_plates_title", comment: "vehicle_edit_plates_title"), message: NSLocalizedString("vehicle_edit_plates_message", comment: "vehicle_edit_plates_message"), preferredStyle: UIAlertController.Style.alert)
            
            newAlert.addTextField { txtField in
                txtField.placeholder = NSLocalizedString("vehicle_edit_name_placeholder", comment: "vehicle_edit_name_placeholder")
                txtField.text = self.LicensePlate
            }
            
            //** Cancel Button **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("oil_Cancel_Option", comment: "oil_Cancel_Option"), style: .destructive, handler: { (action: UIAlertAction!) in
                
                newAlert.dismiss(animated: true, completion: nil)
            }))
            
            //** Save Button **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("oil_Save_Option", comment: "oil_Save_Option"), style: .default, handler: { (action: UIAlertAction!) in
                let textField = newAlert.textFields![0]
                let newVehiclePlates: String = textField.text ?? ""
                
                if(newVehiclePlates != ""){
                    self.LicensePlate = "\(newVehiclePlates)"
                    self.makePut()
                    newAlert.dismiss(animated: true, completion: nil)
                } else {
                    newAlert.dismiss(animated: true, completion: nil)
                    self.Alert(Title: "ERROR", Message: "Cannot be Empty")
                }
    
            }))
            
            newAlert.view.tintColor = UIColor(named: "spotGreen")
            self.present(newAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func editOdometer(_ sender: Any) {
        DispatchQueue.main.async {
            let newAlert = UIAlertController(title: NSLocalizedString("vehicle_edit_odometer_title", comment: "vehicle_edit_odometer_title"), message: NSLocalizedString("vehicle_edit_odometer_message", comment: "vehicle_edit_odometer_message"), preferredStyle: UIAlertController.Style.alert)
            
            newAlert.addTextField { txtField in
                txtField.placeholder = NSLocalizedString("vehicle_edit_odometer_title", comment: "vehicle_edit_odometer_title")
                txtField.keyboardType = .numberPad
                txtField.text = "\(self.Kilometers)"
            }
            
            //** Cancel Button **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("oil_Cancel_Option", comment: "oil_Cancel_Option"), style: .destructive, handler: { (action: UIAlertAction!) in
                
                newAlert.dismiss(animated: true, completion: nil)
            }))
            
            //** Save Button **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("oil_Save_Option", comment: "oil_Save_Option"), style: .default, handler: { (action: UIAlertAction!) in
                let textField = newAlert.textFields![0]
                let newOdometer: String = textField.text ?? ""
                
                if(newOdometer != ""){
                    self.Kilometers = Float(newOdometer) as! Float
                    self.makePut()
                    newAlert.dismiss(animated: true, completion: nil)
                } else {
                    newAlert.dismiss(animated: true, completion: nil)
                    self.Alert(Title: "ERROR", Message: "Cannot be Empty")
                }
                
                newAlert.dismiss(animated: true, completion: nil)
            }))
            
            newAlert.view.tintColor = UIColor(named: "spotGreen")
            
            self.present(newAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func returnToMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editFuelType(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerView.alpha = 1
        })
    }
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    //** Alert **//
    func ShowAlert(_ title: String, message: String, dismiss: String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: dismiss, style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
