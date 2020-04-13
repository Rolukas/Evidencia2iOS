//
//  MyInsuranceViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/30/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import Firebase

class MyInsuranceViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
   
    // Outlets
    @IBOutlet weak var backgroundImageInsurance: UIView!
    @IBOutlet weak var insuranceLogo: UIImageView!
    @IBOutlet weak var insuranceNameLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var emergencyNumberLabel: UITextField!
    @IBOutlet weak var policyNumberLabel: UITextField!
    @IBOutlet weak var emergencyContactNameLabel: UITextField!
    @IBOutlet weak var emergencyContactPhoneLabel: UITextField!
    @IBOutlet weak var optionPicker: UIPickerView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var insuranceLabel: UILabel!
    @IBOutlet weak var policyNumberInfo: UILabel!
    @IBOutlet weak var expirationInfo: UILabel!
    @IBOutlet weak var emergencyNumberInfo: UILabel!
    @IBOutlet weak var emergencyContactLabelInfo: UILabel!
    @IBOutlet weak var emergencyContactNameInfo: UILabel!
    @IBOutlet weak var emergencyContactPhoneInfo: UILabel!
    @IBOutlet weak var policyInfo: UILabel!
    @IBOutlet weak var saveButtonFuelPicker: UIButton!
    @IBOutlet weak var cancelButtonFuelPicker: UIButton!
    @IBOutlet weak var saveButtonPicker: UIButton!
    @IBOutlet weak var cancelButtonPicker: UIButton!
    @IBOutlet weak var myInsuranceTitle: UILabel!
    @IBOutlet var emergencyContactSubview: UIView!
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    var handleOptionSelected: String = "Ninguno"
    var handleOptionNumberSelected: Int = 0
    
    var StringDate = String()
    var day = String()
    var month = String()
    var year = String()
    
    var handleDay = String()
    var handleMonth = String()
    var handleYear = String()
    var handleNewDateWithFormat = String()
    
    var hadMakePost: Bool = false
    
    // Arrays
    var arrayOfInsurances = [String]()
    var arrayOfImagesURL = [String]()
    var arrayPhone = [String]()
    var arrayColors = [String]()
    var arrayInsurance = ["Ninguno","ABA Seguros", "AIG Seguros", "Allianz Seguros", "Atlas Seguros", "AXA Seguros", "Banamex Seguros", "Banorte Seguros", "BBVA Seguros", "General de Seguros", "GNP Seguros","HDI Seguros","HSBC Seguros","Inbursa Seguros", "Mapfre Seguros", "Qualitas Seguros", "Zurich Seguros", "Otro"]
    
    
    /*
     
     ABA Seguros - 01 800 712 2828
     AIG Seguros - 01 800 0011 300
     Allianz México Seguros - 01 (800) 1111 200
     Atlas Seguros - 1 800 849 39 16
     AXA Seguros - 01800 900 1292
     Banamex Seguros - 0155 1226 8100
     Banorte Seguros - 01 800 500 15 00
     BBVA Bancomer seguros - 01 800 874 3683
     General de seguros - 01800.47.27696
     GNP Seguros - 01 (55) 5227 9000
     HDI Seguros - 01 800 0000 434
     HSBC Seguros - (01 55) 5721 3322
     Inbursa Seguros -  01 800 90 90000
     Mapfre Seguros - 01 800 849 8585
     Qualitas Seguros - 01-800-288-6700
     Zurich Seguros - 01 800 288 6911
     
     */
    
//    var arrayColor = ["2D3E46","0084b5", "008f39", "009fdc", "d90012", "00008b", "053a79", "db1820", "004481", "2D3E46", "023b81", "003285", "f86d08", "00a14e", "e11c1c", "002661", "fc1700", "82167a", "a01318", "2D3E46", "851e7f", "897a39", "48267f", "d61d28", "940b29", "002f9f", "2b4999","2b4999", "2D3E46"]
    
    
    
    // Structs to fill with data
    struct Response: Codable{
        var success: Bool
        var items: item
    }
    
    struct item: Codable{
        var id: Int
        var insurance: String
        var insuranceNumber: String
        var phone: String
        var dueDate: String
        var leasing: String
        var contractNumber: String
        var nextPayment: String
        var monthlyPay: String
        var cuentaDomiciliar: String
        var fechaPago: String
        var monto: Float
        var EmergencyName: String
        var EmergencyPhone: String
    }
    
    // Response Metadata
    struct ResponseMetadata: Codable{
        var success: Bool
        var items: [metadataItems]
    }
    
    struct metadataItems: Codable{
        var InsuranceCatalogId: Int
        var Name: String
        var Image: String
        var Phone: String
        var Color: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide keyboard When Tapped Around
        hideKeyboardWhenTappedAround()
        self.policyNumberLabel.delegate = self
        self.emergencyContactNameLabel.delegate = self
        self.emergencyContactPhoneLabel.delegate = self
        
        optionPicker.setValue( UIColor.white , forKeyPath: "textColor")
        datePicker.setValue( UIColor.white , forKeyPath: "textColor")
        
        pickerView.alpha = 0
        datePickerView.alpha = 0
        
        // Add tags
        self.emergencyNumberLabel.tag = 0
        self.policyNumberLabel.tag = 1
        self.emergencyContactNameLabel.tag = 2
        self.emergencyContactPhoneLabel.tag = 3
        
        // Underlined Green
        insuranceNameLabel.underlinedGreen()
        policyNumberLabel.underlinedGreen()
        emergencyNumberLabel.underlinedGreen()
        expirationLabel.underlinedGreen()
        emergencyContactNameLabel.underlinedGreen()
        emergencyContactPhoneLabel.underlinedGreen()
        
        //Set Texts
        setText()

        // Open Pickers tap label
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showPickerInsurance(_:)))
        tap.numberOfTapsRequired = 1
        insuranceNameLabel.isUserInteractionEnabled = true
        insuranceNameLabel.addGestureRecognizer(tap)
        
        // Open Date Pickers tap label
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.showDatePicker(_:)))
        tap2.numberOfTapsRequired = 1
        expirationLabel.isUserInteractionEnabled = true
        expirationLabel.addGestureRecognizer(tap2)
        
        // Add value changed for date picker
        datePicker.addTarget(self, action: #selector(self.pickerChanged), for: .valueChanged)
        
        // SHOW/HIDE KEYBOARD
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
        // GET ALL THE INSURANCE INFO
        getInsuranceMetadata()
        
        
        //** language **//
        let langStr: String = Locale.current.languageCode!
        // english
        if( langStr == "en" ){
            myInsuranceTitle.text = "My Insurance"
            // spanish
        } else {
            myInsuranceTitle.text = "Mi Seguro"
        }
        
        Analytics.logEvent("function_insurance", parameters: nil)
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
    
    
    func setLightModeSettings(){
        self.view.backgroundColor = .white
        self.emergencyContactSubview.backgroundColor = .white
        self.insuranceLabel.textColor = .black
    }
    
    func setDarkModeSettings(){
        self.view.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.emergencyContactSubview.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.insuranceLabel.textColor = .white
    }
    
    func setText(){
        insuranceLabel.text = NSLocalizedString("insurance_InsuranceCarrier_label", comment: "insurance_InsuranceCarrier_label")
        policyInfo.text = NSLocalizedString("insurance_PolicyNumber_label", comment: "insurance_PolicyNumber_label")
        expirationInfo.text = NSLocalizedString("insurance_Expiration_label", comment: "insurance_Expiration_label")
        emergencyNumberInfo.text = NSLocalizedString("insurance_EmergencyNumber_label", comment: "insurance_EmergencyNumber_label")
        emergencyContactLabelInfo.text = NSLocalizedString("insurance_Header_Contact", comment: "insurance_Header_Contact")
        emergencyContactNameInfo.text = NSLocalizedString("insurance_Table_Nombre_Placeholder", comment: "insurance_Table_Nombre_Placeholder")
        emergencyContactPhoneInfo.text = NSLocalizedString("insurance_Table_Phone_Placeholder", comment: "insurance_Table_Phone_Placeholder")
        policyNumberInfo.text = NSLocalizedString("insurance_PolicyNumber_label", comment: "insurance_PolicyNumber_label")
        saveButtonPicker.setTitle(NSLocalizedString("config_Block_Accept_Button", comment: "config_Block_Accept_Button"), for: .normal)
        cancelButtonPicker.setTitle(NSLocalizedString("config_Block_Cancel_Button", comment: "config_Block_Cancel_Button"), for: .normal)
        saveButtonFuelPicker.setTitle(NSLocalizedString("config_Block_Accept_Button", comment: "config_Block_Accept_Button"), for: .normal)
        cancelButtonFuelPicker.setTitle(NSLocalizedString("config_Block_Cancel_Button", comment: "config_Block_Cancel_Button"), for: .normal)
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
        handleNewDateWithFormat = "\(handleMonth)/\(handleDay)/\(handleYear)"
    }
    
    @objc func showPickerInsurance(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerView.alpha = 1
        })
    }
    
    @objc func showDatePicker(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.datePickerView.alpha = 1
        })
    }
    
    // SET DATA TO PICKER
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: arrayOfInsurances[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
    
    //** Picker Protocols **//
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfInsurances.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOfInsurances[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        handleOptionSelected = arrayOfInsurances[row]
        handleOptionNumberSelected = row
    }
    
    @IBAction func onSaveInsurance(_ sender: Any) {
        print(handleOptionNumberSelected)
        // Basic Info
        if( (self.policyNumberLabel.text != ""  && self.emergencyNumberLabel.text != "" && self.expirationLabel.text != "") || handleOptionNumberSelected == 0 ){
            
            if( handleOptionNumberSelected == 0){
                self.removeInsurance()
            } else {
                self.putVehicleInsurancePicker()
            }
            
        } else {
            
            self.insuranceNameLabel.text = handleOptionSelected
            self.setInsuranceInformation(numberOfInsurance: handleOptionNumberSelected)
            self.Alert(Title: "Oops!", Message: NSLocalizedString("insurance_incomplete_Alert", comment: "insurance_incomplete_Alert"))
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.pickerView.alpha = 0
            })
        }
       
    }
    
    
    @IBAction func saveDatePicker(_ sender: Any) {
        putVehicleInsuranceDatePicker()
    }
    
    
    @IBAction func cancelDatePicker(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.datePickerView.alpha = 0
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //** When the user finished editing textFields **//
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            
            if(self.insuranceNameLabel.text == "Otro"){
                self.emergencyNumberLabel.isUserInteractionEnabled = true
                self.emergencyContactNameLabel.isUserInteractionEnabled = true
                self.emergencyContactPhoneLabel.isUserInteractionEnabled = true
                self.policyNumberLabel.isUserInteractionEnabled = true
            } else {
                self.emergencyNumberLabel.isUserInteractionEnabled = true
                self.emergencyContactNameLabel.isUserInteractionEnabled = true
                self.emergencyContactPhoneLabel.isUserInteractionEnabled = true
            }
            
            
            // Basic Info
            if( self.policyNumberLabel.text != ""  && self.emergencyNumberLabel.text != "" && self.expirationLabel.text != ""){
                self.checkForInsurancePut()
            }
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Add tags        
        DispatchQueue.main.async {
            switch(textField.tag){
            case 1: // Policy Number Label
                self.emergencyNumberLabel.isUserInteractionEnabled = false
                self.emergencyContactNameLabel.isUserInteractionEnabled = false
                self.emergencyContactPhoneLabel.isUserInteractionEnabled = false
                break
            case 0: // Emergency Number Label
                self.policyNumberLabel.isUserInteractionEnabled = false
                self.emergencyContactNameLabel.isUserInteractionEnabled = false
                self.emergencyContactPhoneLabel.isUserInteractionEnabled = false
                break
            case 2: // Emergency Contact Name
                self.policyNumberLabel.isUserInteractionEnabled = false
                self.emergencyNumberLabel.isUserInteractionEnabled = false
                self.emergencyContactPhoneLabel.isUserInteractionEnabled = false
                break
            case 3: // Emergency Contact Phone
                self.policyNumberLabel.isUserInteractionEnabled = false
                self.emergencyNumberLabel.isUserInteractionEnabled = false
                self.emergencyContactNameLabel.isUserInteractionEnabled = false
                break
            default:
                break
            }
        }
    }
    
    //** Validate all the data **//
    func checkForInsurancePut(){
        DispatchQueue.main.async {
            // insurance basic info
            if( self.insuranceNameLabel.text == "" || self.insuranceNameLabel.text == "Ninguno" ){
                
                self.Alert(Title: "Oops!", Message: "La información de seguro debe estar completa para poder actualizarse")
                
            } else {
                
                // Basic Info
                if( self.policyNumberLabel.text != ""  && self.emergencyNumberLabel.text != "" && self.expirationLabel.text != "" ){
                    
                    // Basic Info + Emergency contact info
                    if( self.emergencyContactPhoneLabel.text != "" || self.emergencyContactNameLabel.text != "" ){
                        
                        if( self.emergencyContactPhoneLabel.text != "" && self.emergencyContactNameLabel.text != "" ){
                            self.putVehicleInsurance()
                        } else {
                            self.Alert(Title: "Oops!", Message: "La información del contacto de emergencia debe estar completa")
                        }
                        
                    } else {
                        self.putVehicleInsurance()
                    }
                    
                } else {
                    self.Alert(Title: "Oops!", Message: "La información de seguro debe estar completa para poder actualizarse")
                }
                
            }
            
        }
    }
    
    //** Get to the Insurance Controller to set all the data **//
    func getInsuranceInfo(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/insurance?VehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
            
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
                        print(json)
                        
                        //Set the dictionary with the data
                        let vehicleInformation = try JSONDecoder().decode(Response.self, from: data)
                        // Display the info
                        DispatchQueue.main.async {
                           
                            let currentInsurance = vehicleInformation.items.insurance
                            self.policyNumberLabel.text = vehicleInformation.items.insuranceNumber
                            self.expirationLabel.text = vehicleInformation.items.dueDate
                            self.emergencyContactNameLabel.text = vehicleInformation.items.EmergencyName
                            self.emergencyContactPhoneLabel.text = vehicleInformation.items.EmergencyPhone
                            
                            var i: Int = 0
                            var insuranceFound: Bool = false

                            // Found the insurance selected
                            for insurance in self.arrayOfInsurances{
                                if(currentInsurance == insurance && !insuranceFound){
                                    self.setInsuranceInformation(numberOfInsurance: i)
                                    insuranceFound = true
                                }

                                i += 1
                            }
                            
                            if(!insuranceFound){
                                self.insuranceNameLabel.text = vehicleInformation.items.insurance
                                self.setInsuranceInformation(numberOfInsurance: 1000) // Another one
                            }
                            
                        }
                        // Error on get
                    } catch {
                        
                        if(!self.hadMakePost){
                            self.postToCreateIt()
                            self.hadMakePost = true
                            
                        } else {
                            
                            self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                            
                            print("Error on Insurance GET: ")
                            print(error)
                            
                        }
                        
                       
                        
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    //** get images, phones and names **//
    func getInsuranceMetadata(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/insurance" as NSString
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
                        let insuranceMetadata = try JSONDecoder().decode(ResponseMetadata.self, from: data)

                        self.arrayOfInsurances.removeAll()
                        self.arrayOfImagesURL.removeAll()
                        self.arrayPhone.removeAll()
                        self.arrayColors.removeAll()
                        
                        self.arrayOfInsurances.append("Ninguno")
                        self.arrayOfImagesURL.append("")
                        self.arrayPhone.append("")
                        self.arrayColors.append("#2D3E46")
                        
                        for insurance in insuranceMetadata.items{
                            self.arrayOfInsurances.append(insurance.Name)
                            self.arrayOfImagesURL.append(insurance.Image)
                            self.arrayPhone.append(insurance.Phone)
                            self.arrayColors.append(insurance.Color)
                        }
                        
                        self.arrayOfInsurances.append("Otro")
                        self.arrayOfImagesURL.append("")
                        self.arrayPhone.append("")
                        self.arrayColors.append("#2D3E46")
  
                        DispatchQueue.main.async {
                            self.optionPicker.reloadAllComponents()
                        }
                        
                        self.getInsuranceInfo()
                        
                    // Error on get
                    } catch {
                        
                        print("Error on Insurance METADATA GET: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    
    //** Set the insurance information (Color, Name, Image) **//
    func setInsuranceInformation(numberOfInsurance: Int){

        DispatchQueue.main.async {
          
            self.emergencyNumberLabel.isUserInteractionEnabled = false
            self.emergencyNumberLabel.isUserInteractionEnabled = true
            self.policyNumberLabel.isUserInteractionEnabled = true
            self.expirationLabel.isUserInteractionEnabled = true
            
            if(numberOfInsurance != 1000){
                
                if(!self.arrayOfImagesURL[numberOfInsurance].isEmpty){
                    
                
                       
                    let url = URL(string: self.arrayOfImagesURL[numberOfInsurance])
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async {
                            self.insuranceLogo.image = UIImage(data: data!)
                        }
                    }
                    
                    self.backgroundImageInsurance.backgroundColor = UIColor(hexString: self.arrayColors[numberOfInsurance])
                    self.insuranceNameLabel.text = self.arrayOfInsurances[numberOfInsurance]
                    self.emergencyNumberLabel.text = self.arrayPhone[numberOfInsurance]
                    
                
                // Si la url de la imagen viene vacía
                } else {
                    
                    
                    // Otro o Ninguno
                    if(numberOfInsurance == 0 || numberOfInsurance == (self.arrayOfInsurances.count - 1)){
                        
                        if(numberOfInsurance == (self.arrayOfInsurances.count - 1)){
                            self.emergencyNumberLabel.isUserInteractionEnabled = true
                        } else {
                        
                            self.emergencyNumberLabel.text = ""
                            self.policyNumberLabel.text = ""
                            self.expirationLabel.text = ""
                            
                            self.emergencyNumberLabel.isUserInteractionEnabled = false
                            self.policyNumberLabel.isUserInteractionEnabled = false
                            self.expirationLabel.isUserInteractionEnabled = false
                            
                        }
                        
                        self.insuranceLogo.image = UIImage(named: "transparent")
                        self.backgroundImageInsurance.backgroundColor = UIColor(hexString: self.arrayColors[numberOfInsurance])
                        self.insuranceNameLabel.text = self.arrayOfInsurances[numberOfInsurance]
                        
                        // Aseguradora con toda la información
                    } else {
                        
                        self.insuranceLogo.image = UIImage(named: "transparent")
                        self.backgroundImageInsurance.backgroundColor = UIColor(hexString: self.arrayColors[numberOfInsurance])
                        self.insuranceNameLabel.text = self.arrayOfInsurances[numberOfInsurance]
                        
                    }
                    
                    
                
                }

            // No se encuentra la información y no se coloca imagen
            } else {
                
                self.insuranceLogo.image = UIImage(named: "transparent")
                self.backgroundImageInsurance.backgroundColor = UIColor(hexString: self.arrayColors[0])

            }
        }
       
    }
    
    
    //** If the user doesn't have an insurance data, then create it **//
    func postToCreateIt(){
        if CheckInternet.Connection(){
            
            let dictionarySub = [
                "id": CurrentVehicleInfo.VehicleId,
                "insurance": "Ninguno",
                "insuranceNumber": "",
                "phone": "",
                "dueDate": "01/01/2019",
                "EmergencyName": "",
                "EmergencyPhone": ""
            ] as [String : Any]
            
            print(dictionarySub)
            
            let url = "https://rastreo.resser.com/api/Insurance?vehicleId=\(CurrentVehicleInfo.VehicleId)"
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
                    print("====ERROR FROM VALET PutVehcileInsuranceDatePicker====")
                    print(error ?? "LOL")
                    
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                } else {
                    

                    self.getInsuranceMetadata()
                    
                }
                
                
            }
            dataTask.resume()
        }
        
    }
    
    //** Put the data when the user saves date for expirancy **//
    func putVehicleInsuranceDatePicker(){
        if CheckInternet.Connection(){
            
            let dictionarySub = [
                "id": CurrentVehicleInfo.VehicleId,
                "insurance": insuranceNameLabel.text ?? "",
                "insuranceNumber": policyNumberLabel.text ?? "",
                "phone": emergencyNumberLabel.text ?? "",
                "dueDate": handleNewDateWithFormat,
                "EmergencyName": emergencyContactNameLabel.text ?? "",
                "EmergencyPhone": emergencyContactPhoneLabel.text ?? ""
            ] as [String : Any]
            
            print(dictionarySub)
            
            let url = "https://rastreo.resser.com/api/Insurance?vehicleId=\(CurrentVehicleInfo.VehicleId)"
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
                    print("====ERROR FROM VALET PutVehcileInsuranceDatePicker====")
                    print(error ?? "LOL")
                    
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                    
                } else {
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.datePickerView.alpha = 0
                        })
                    }
                    
                    self.getInsuranceMetadata()
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    self.Alert(Title: "Exito", Message: "Datos Actualizados")
                    
                    
                }
                
                
            }
            dataTask.resume()
        }
        
    }
    
    //** Remove Insurance -> "Ninguno" Option **//
    func removeInsurance() {
        
        // Check internet connection
        if CheckInternet.Connection(){
            // Get loads
            let url : NSString  = "https://rastreo.resser.com/api/insurance?VehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        self.getInsuranceMetadata()
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        self.Alert(Title: "Exito", Message: "Datos Actualizados")
                        
                    } catch {
                        
                        print("Error on removeInsurance: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
        
    }
    
    //** Put the data when the user saves insurance **//
    func putVehicleInsurancePicker(){
        if CheckInternet.Connection(){
            
            let dictionarySub = [
                "id": CurrentVehicleInfo.VehicleId,
                "insurance": handleOptionSelected,
                "insuranceNumber": policyNumberLabel.text ?? "",
                "phone": emergencyNumberLabel.text ?? "",
                "dueDate": expirationLabel.text ?? "",
                "EmergencyName": emergencyContactNameLabel.text ?? "",
                "EmergencyPhone": emergencyContactPhoneLabel.text ?? ""
            ] as [String : Any]
            
            print(dictionarySub)
            
            let url = "https://rastreo.resser.com/api/Insurance?vehicleId=\(CurrentVehicleInfo.VehicleId)"
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
                    print("====ERROR FROM VALET PutVehicleInsurancePicker====")
                    print(error ?? "LOL")
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                    
                } else {
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.pickerView.alpha = 0
                        })
                    }
                    
                    self.getInsuranceMetadata()
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    self.Alert(Title: "Exito", Message: "Datos Actualizados")
                    
                    
                }
                
                
            }
            dataTask.resume()
        }
        
    }
    
    //** Put the data when a textfield is edited**//
    func putVehicleInsurance(){
        if CheckInternet.Connection(){
            
            let dictionarySub = [
                "id": CurrentVehicleInfo.VehicleId,
                "insurance": insuranceNameLabel.text ?? "",
                "insuranceNumber": policyNumberLabel.text ?? "",
                "phone": emergencyNumberLabel.text ?? "",
                "dueDate": expirationLabel.text ?? "",
                "EmergencyName": emergencyContactNameLabel.text ?? "",
                "EmergencyPhone": emergencyContactPhoneLabel.text ?? ""
            ] as [String : Any]
            
            let url = "https://rastreo.resser.com/api/Insurance?vehicleId=\(CurrentVehicleInfo.VehicleId)"
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
                        print("====ERROR FROM VALET PutVehicleInsurance====")
                        print(error ?? "LOL")
                        
                        self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                    } else {
                        
                        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        self.Alert(Title: "Exito", Message: "Datos Actualizados")
                        
                    }
                
                
            }
            dataTask.resume()
        }
        
    }
    
    @IBAction func onHidePicker(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pickerView.alpha = 0
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

    //** Return to menu **//
    @IBAction func returnToMenu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
