//
//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import Firebase
import UIKit

class numberCell: UITableViewCell{
    @IBOutlet weak var numberImage: UIImageView!
    @IBOutlet weak var labelText: UILabel!
}

class SosViewController: UIViewController, UITableViewDelegate {
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    let langStr: String = Locale.current.languageCode!
    // Vehicle information (If it exists)
    var LicensePlate = Int()
    var VehicleName = String()
    // To know if it has insurance
    var hasInsurance: Bool = false
    var currentOption: Int = 0 // To know if it is the sinester or a ****  0 -> STOLE, 1 -> SINESTER ****
    
    var insurance = String()
    var insuranceNumber = String()
    var phone = String()
    
    // current color for text
    var currentColorForText = UIColor()
    
    // Texts
    var textOne = NSMutableAttributedString()
    var textTwo = NSMutableAttributedString()
    var textThree = NSMutableAttributedString()
    var textFour = NSMutableAttributedString()
    var textFive = NSMutableAttributedString()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sinesterBar: UIView!
    @IBOutlet weak var stoleBar: UIView!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehiclePlates: UILabel!
    @IBOutlet weak var serialNumber: UILabel!
    @IBOutlet weak var carCrashLabel: UIButton!
    @IBOutlet weak var stoleLabel: UIButton!
    
    
    // Structs to fill with data
    struct Response: Codable{
        var success: Bool
        var items: item
    }
    
    struct item: Codable{
        var id: Int
        var insurance: String?
        var insuranceNumber: String?
        var phone: String?
        var dueDate: String
        var leasing: String
        var contractNumber: String
        var nextPayment: String?
        var monthlyPay: String?
        var cuentaDomiciliar: String
        var fechaPago: String
        var monto: Float?
        var EmergencyName: String?
        var EmergencyPhone: String?
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("protocol_SOS_title", comment: "protocol_SOS_title")
        stoleLabel.setTitle( NSLocalizedString("protocol_SOS_stole_Title", comment: "protocol_SOS_stole_Title"), for: .normal)
        carCrashLabel.setTitle( NSLocalizedString("protocol_SOS_carCrash_Title", comment: "protocol_SOS_carCrash_Title"), for: .normal)
        sinesterBar.isHidden = true
        
        print("==== DID LOAD =====")
        
        if #available(iOS 12.0, *) {
            
            // 1 -> Light mode, 2 -> Dark Mode
            print(traitCollection.userInterfaceStyle.rawValue)
            
            DispatchQueue.main.async {
                
                if( self.traitCollection.userInterfaceStyle.rawValue == 1 ){
                    self.setLightModeSettings()
                    self.getInsuranceInfo()
                } else {
                    self.setDarkModeSettings()
                    self.getInsuranceInfo()
                }

            }
                        
        }
        
        
        
        Analytics.logEvent("function_help", parameters: nil)
    }
    
    func setDarkModeSettings(){
        currentColorForText = .white
        
        self.view.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.tableView.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.vehicleName.textColor = .white
        self.vehiclePlates.textColor = .white
        self.serialNumber.textColor = .white
    }
    
    func setLightModeSettings(){
        currentColorForText = UIColor(named: "grayBackground")!
        
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .white
        self.vehicleName.textColor = UIColor(named: "grayBackground")
        self.vehiclePlates.textColor = UIColor(named: "grayBackground")
        self.serialNumber.textColor = UIColor(named: "grayBackground")
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
                
                self.setTexts()
                self.tableView.reloadData()
            }
            
        } else {
            // Fallback on earlier versions
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
                        
                        //Set the dictionary with the data
                        let vehicleInformation = try JSONDecoder().decode(Response.self, from: data)
                        
                        // Flag to know if it has insurance
                        let insuranceName = vehicleInformation.items.insurance ?? ""
                        let vehicleNameOpt: String = CurrentVehicleInfo.VehicleName
                        let vehiclePlatesOpt: String = CurrentVehicleInfo.LicensePlate
                        let vehicleSerialNumber: String = CurrentVehicleInfo.SerialNumber
                        
                        print("name: \(vehicleNameOpt)")
                        print("plates: \(vehiclePlatesOpt)")
                        print("serial: \(vehicleSerialNumber)")
                        
                        DispatchQueue.main.async {
                            
                            if( self.langStr == "en" ){
                                
                                if(vehicleNameOpt.trimmingCharacters(in: .whitespaces) == ""){
                                    self.vehicleName.text = "N/A"
                                } else {
                                    self.vehicleName.text = vehicleNameOpt
                                }
                                
                                if(vehiclePlatesOpt.trimmingCharacters(in: .whitespaces) == ""){
                                    self.vehiclePlates.text = "Plates: N/A"
                                } else {
                                    self.vehiclePlates.text = "Plates: \(String(describing: vehiclePlatesOpt))"
                                }
                                
                                if(vehicleSerialNumber.trimmingCharacters(in: .whitespaces) == ""){
                                    self.serialNumber.text = "Serial Number: N/A"
                                } else {
                                    self.serialNumber.text = "Serial Number: \(String(describing: vehicleSerialNumber))"
                                }
                                
                            } else {
                                
                                if(vehicleNameOpt.trimmingCharacters(in: .whitespaces) == ""){
                                    self.vehicleName.text = "N/D"
                                } else {
                                    self.vehicleName.text = vehicleNameOpt
                                }
                                
                                if(vehiclePlatesOpt.trimmingCharacters(in: .whitespaces) == ""){
                                    self.vehiclePlates.text = "Placas: N/D"
                                } else {
                                    self.vehiclePlates.text = "Placas: \(String(describing: vehiclePlatesOpt))"
                                }
                                
                                if(vehicleSerialNumber.trimmingCharacters(in: .whitespaces) == ""){
                                    self.serialNumber.text = "Número de serie: N/D"
                                } else {
                                    self.serialNumber.text = "Número de serie: \(String(describing: vehicleSerialNumber))"
                                }
                                
                            }
                            
                            
                        }
                        
                        
                        if( insuranceName == "" || insuranceName == "Ninguno" ){
                            self.hasInsurance = false
                        } else {
                            self.hasInsurance = true
                            self.phone = vehicleInformation.items.phone ?? ""
                            self.insurance = vehicleInformation.items.insurance ?? ""
                            self.insuranceNumber = vehicleInformation.items.insuranceNumber ?? ""
                        }
                        
                        DispatchQueue.main.async{
                            self.setTexts()
                            self.tableView.reloadData()
                        }
                        
                        
                        // Error on get
                    } catch {
                        
                        
                        print("Error on Insurance GET: ")
                        print(error)
                        
                        DispatchQueue.main.async{
                            self.hasInsurance = false
                            self.setTexts()
                            self.setInfoOnError()
                            self.tableView.reloadData()
                        }
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
            DispatchQueue.main.async{
                self.hasInsurance = false
                self.setTexts()
                self.setInfoOnError()
                self.tableView.reloadData()
            }
            
        }
    }
    
    func setInfoOnError(){
        DispatchQueue.main.async {
            
            if( self.langStr == "en" ){
                
                self.vehicleName.text = "Vehicle: N/A"
                self.vehiclePlates.text = "Plates: N/A"
                self.serialNumber.text = "Serial Number: N/A"
                
            } else {
                
                self.vehicleName.text = "Vehículo: N/D"
                self.vehiclePlates.text = "Placas: N/D"
                self.serialNumber.text = "Número de serie: N/D"
                
            }
            
            
        }
    }
    
    func setTexts(){
        
        // Robo
        if( currentOption == 0 ){
            
            // English settings
            if( langStr == "en" ){
                
                //****** Text label One ******//
                let myString:NSString = "Report to our cabin 24H at (33)2300-6904 or you can also contact the (33)2620-8416"
                // Green Numbers
                var myMutableString = NSMutableAttributedString()
                
                
                // DarkMode/LightMode
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableString.length))
                
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:27,length:13))
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:69,length:13))
                textOne = myMutableString
                
                //****** Text label Two ******//
                let myStringTwo:NSString = "Communicate to emergencies and report theft at 911"
                // Green Numbers
                var myMutableStringTwo = NSMutableAttributedString()
                
                // DarkMode/LightMode
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringTwo.length))
                
                myMutableStringTwo = NSMutableAttributedString(string: myStringTwo as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:47,length:3))
                textTwo = myMutableStringTwo
                
                //****** Text label Three ******//
                let myStringThree:NSString = "Call to (33)2300-6904 o (33)3620-8416 and provide the report number"
                // Green Numbers
                var myMutableStringThree = NSMutableAttributedString()
                
                // DarkMode/LightMode
                myMutableStringThree.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringThree.length))
                
                myMutableStringThree = NSMutableAttributedString(string: myStringThree as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                myMutableStringThree.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:8,length:13))
                myMutableStringThree.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:24,length:13))
                textThree = myMutableStringThree
                
                
                //****** If the user has insurance ******//
                if( hasInsurance ){
                    
                    //****** Text label Four ******//
                    let myStringFour = "Contact \(self.insurance) to the number \(self.phone) your policy number is  \(self.insuranceNumber)."
                    var myMutableStringFour = NSMutableAttributedString()
                    
                    // DarkMode/LightMode
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFour.length))
                    
                    myMutableStringFour = NSMutableAttributedString(string: myStringFour as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textFour = myMutableStringFour
                    
                    //****** Text label Five ******//
                    let myStringFive:NSString = "The 24H cabin will continue the operation, remain localizable during its duration."
                    var myMutableStringFive = NSMutableAttributedString()
                    
                    // DarkMode/LightMode
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFive.length))
                    
                    myMutableStringFive = NSMutableAttributedString(string: myStringFive as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textFive = myMutableStringFive
                    
                } else {
                    
                    //****** Text label Four ******//
                    let myStringFour = "The 24H cabin will continue the operation, remain localizable during its duration."
                    var myMutableStringFour = NSMutableAttributedString()
                    
                    // DarkMode/LightMode
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFour.length))
                    
                    myMutableStringFour = NSMutableAttributedString(string: myStringFour as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textFour = myMutableStringFour
                    
                }
                
            } else {
                
                //****** Text label One ******//
                let myString:NSString = "Reporta a nuestra cabina 24Hrs al (33)2300-6904 o también puedes comunicarte al (33)2620-8416"
                // Green Numbers
                var myMutableString = NSMutableAttributedString()
                
                print(myMutableString)
                print(myMutableString.length)
                
              
                
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                
                // DarkMode/LightMode
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableString.length))
                
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:34,length:13))
                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:80,length:13))
                
                textOne = myMutableString
                
                //****** Text label Two ******//
                let myStringTwo:NSString = "Comunícate a emergencias al 911 y realiza el reporte de robo"
                // Green Numbers
                var myMutableStringTwo = NSMutableAttributedString()
                

                myMutableStringTwo = NSMutableAttributedString(string: myStringTwo as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                
                // DarkMode/LightMode
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringTwo.length))
                
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:28,length:3))
                textTwo = myMutableStringTwo
                
                //****** Text label Three ******//
                let myStringThree:NSString = "Llama al (33)2300-6904 o (33)3620-8416 y proporciona el número de reporte"
                // Green Numbers
                var myMutableStringThree = NSMutableAttributedString()
                

                myMutableStringThree = NSMutableAttributedString(string: myStringThree as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                
                // DarkMode/LightMode
                myMutableStringThree.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringThree.length))
                
                myMutableStringThree.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:9,length:13))
                myMutableStringThree.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:25,length:13))
                textThree = myMutableStringThree
                
                if( hasInsurance ){
                    
                    //****** Text label Four ******//
                    let myStringFour = "Contacta a \(self.insurance) al número \(self.phone) tú póliza es \(self.insuranceNumber)"
                    var myMutableStringFour = NSMutableAttributedString()
                    
                    myMutableStringFour = NSMutableAttributedString(string: myStringFour as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFour.length))
                    
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textFour = myMutableStringFour
                    
                    //****** Text label Five ******//
                    let myStringFive:NSString = "La cabina 24Hrs continuará el operativo. Mantente alerta durante este periodo"
                    // Green Numbers
                    var myMutableStringFive = NSMutableAttributedString()
                    
                    myMutableStringFive = NSMutableAttributedString(string: myStringFive as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFive.length))
                    
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textFive = myMutableStringFive
                    
                } else {
                    
                    //****** Text label Four ******//
                    let myStringFour = "La cabina 24Hrs continuará el operativo. Mantente alerta durante este periodo"
                    // Green Numbers
                    var myMutableStringFour = NSMutableAttributedString()
                    
                    myMutableStringFour = NSMutableAttributedString(string: myStringFour as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFour.length))
                    
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textFour = myMutableStringFour
                    
                }
                
            }
            
            
        } else {
            
            
            // English settings
            if( langStr == "en" ){
                
                //****** Text label One ******//
                let myStringTwo:NSString = "Communicate to emergencies at 911"
                // Green Numbers
                var myMutableStringTwo = NSMutableAttributedString()
                
                myMutableStringTwo = NSMutableAttributedString(string: myStringTwo as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                
                // DarkMode/LightMode
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringTwo.length))
                
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:30,length:3))
                textOne = myMutableStringTwo
                
                if ( hasInsurance ){
                    
                    //****** Text label Four ******//
                    let myStringFour = "Contact \(self.insurance) to the number \(self.phone) your policy number is  \(self.insuranceNumber)."
                    var myMutableStringFour = NSMutableAttributedString()

                    myMutableStringFour = NSMutableAttributedString(string: myStringFour as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFour.length))
                    
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textTwo = myMutableStringFour
                    
                    //****** Text label Three ******//
                    let myStringFive = "In case of total loss, contact our 24 hours cabin at (33) 2300-6904 or (33) 2620-8416 to continue with the corresponding procedure."
                    // Green Numbers
                    var myMutableStringFive = NSMutableAttributedString()
                    
                    myMutableStringFive = NSMutableAttributedString(string: myStringFive as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                   myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFive.length))
                    
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:53,length:14))
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:71,length:14))
                    textThree = myMutableStringFive
                    
                    
                } else {
                    
                    //****** Text label Three ******//
                    let myStringFive = "In case of total loss, contact our 24 hours cabin at (33) 2300-6904 or (33) 2620-8416 to continue with the corresponding procedure."
                    // Green Numbers
                    var myMutableStringFive = NSMutableAttributedString()
                    
                    myMutableStringFive = NSMutableAttributedString(string: myStringFive as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFive.length))
                    
                    
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:53,length:14))
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:71,length:14))
                    textTwo = myMutableStringFive
                    
                }
                
                
            } else {
                
                //****** Text label Two ******//
                let myStringTwo:NSString = "Comunícate a emergencias al 911"
                // Green Numbers
                var myMutableStringTwo = NSMutableAttributedString()
                
                myMutableStringTwo = NSMutableAttributedString(string: myStringTwo as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                
                // DarkMode/LightMode
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringTwo.length))
                
                myMutableStringTwo.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:28,length:3))
                textOne = myMutableStringTwo
                
                if( hasInsurance ){
                    
                    //****** Text label Four ******//
                    let myStringFour = "Contacta a \(self.insurance) al número \(self.phone) tú póliza es \(self.insuranceNumber)"
                    var myMutableStringFour = NSMutableAttributedString()
                    

                    myMutableStringFour = NSMutableAttributedString(string: myStringFour as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                   myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFour.length))
                    
                    myMutableStringFour.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:0,length:0))
                    textTwo = myMutableStringFour
                    
                    //****** Text label Three ******//
                    let myStringFive = "En caso de ser pérdida total, comunícate a nuestra cabina 24 horas al (33)2300-6904 o al (33)2620-8416 para reportar el equipo."
                    // Green Numbers
                    var myMutableStringFive = NSMutableAttributedString()
                    
                    myMutableStringFive = NSMutableAttributedString(string: myStringFive as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFive.length))
                    
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:70,length:13))
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:89,length:13))
                    textThree = myMutableStringFive
                    
                } else {
                    
                    //****** Text label Three ******//
                    let myStringFive = "En caso de ser pérdida total, comunícate a nuestra cabina 24 horas al (33)2300-6904 o al (33)2620-8416 para reportar el equipo."
                    // Green Numbers
                    var myMutableStringFive = NSMutableAttributedString()

                    myMutableStringFive = NSMutableAttributedString(string: myStringFive as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.5)])
                    
                    // DarkMode/LightMode
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: currentColorForText, range: NSRange(location:0,length:myMutableStringFive.length))
                    
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:70,length:13))
                    myMutableStringFive.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "spotGreen") ?? UIColor.green, range: NSRange(location:89,length:13))
                    textTwo = myMutableStringFive
                    
                }
                
                
                
                
            }
            
        }
        
    }
    
    @IBAction func stoleOption(_ sender: Any) {
        DispatchQueue.main.async {
            self.sinesterBar.isHidden = true
            self.stoleBar.isHidden = false
            self.currentOption = 0
            self.setTexts()
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func sinesterOption(_ sender: Any) {
        DispatchQueue.main.async {
            self.sinesterBar.isHidden = false
            self.stoleBar.isHidden = true
            self.currentOption = 1
            self.setTexts()
            self.tableView.reloadData()
        }
    }
    
    
    // Make cabin phone call
    func callCabin() {
        "(33)-2300-6904".makeAColl()
        print("Entra")
        Analytics.logEvent("function_contact_us", parameters: nil)
    }
    
    // Make cabin phone call
    func Call911() {
        DispatchQueue.main.async{
            print("Entra")
            if let url = URL(string: "tel://\(911)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    // Phone call to insurance carrier phone
    func callInsurance() {
        DispatchQueue.main.async{
            if let url = URL(string: "tel://\(self.phone)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
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
}

extension SosViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if( hasInsurance && currentOption == 0 ){
            
            return 5
            
        } else if( !hasInsurance && currentOption == 0){
            
            return 4
            
            
        } else if( hasInsurance && currentOption == 1 ){
            
            return 3
            
        } else if ( !hasInsurance && currentOption == 1 ){
            
            return 2
            
        }
        
        return 2 // never execute
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if( (!hasInsurance && currentOption == 1 && indexPath.row == 1) || (hasInsurance && currentOption == 1 && indexPath.row == 2) ){
            return 160
        }
        
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
         0 -> STOLE
         1 -> SINESTER
         */
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "numberCell", for: indexPath) as! numberCell // Cell
        
        switch( indexPath.row ){
            
        case 0:
            cell.labelText.attributedText = textOne
            cell.numberImage.image = UIImage(named: "numberOne")
        case 1:
            cell.labelText.attributedText = textTwo
            cell.numberImage.image = UIImage(named: "numberTwo")
        case 2:
            cell.labelText.attributedText = textThree
            cell.numberImage.image = UIImage(named: "numberThree")
        case 3:
            cell.labelText.attributedText = textFour
            cell.numberImage.image = UIImage(named: "numberFour")
        case 4:
            cell.labelText.attributedText = textFive
            cell.numberImage.image = UIImage(named: "numberFive")
        default:
            break
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stole
        if(currentOption == 0){
            
            if( hasInsurance ){
                
                switch(indexPath.row){
                    
                case 0:
                    callCabin()
                    break
                    
                case 1:
                    Call911()
                    break
                    
                case 2:
                    callCabin()
                    break
                    
                case 3:
                    callInsurance()
                    break
                    
                default:
                    break
                }
                
            } else {
                
                switch(indexPath.row){
                    
                case 0:
                    callCabin()
                    break
                    
                case 1:
                    Call911()
                    break
                    
                case 2:
                    callCabin()
                    break
                    
                default:
                    break
                }
                
            }
            
            // Sinester
        } else {
            
            if( hasInsurance ){
                
                switch(indexPath.row){
                    
                case 0:
                    Call911()
                    break
                    
                case 1:
                    callInsurance()
                    break
                    
                case 2:
                    callCabin()
                    break
                    
                default:
                    break
                    
                }
                
            } else {
                
                switch(indexPath.row){
                    
                case 0:
                    Call911()
                    break
                    
                case 1:
                    callCabin()
                    break
                    
                default:
                    break
                    
                }
                
            }
            
        }
        
    }
    
    
}
