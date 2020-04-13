//
//  ConfigurationsViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 6/6/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import Firebase

//MARK: Clase para secciones con switch.
class TableViewCellOptions: UITableViewCell {
    
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var switchOption: UISwitch!
    
}

class TableViewCellLabel: UITableViewCell{
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var helpButton: UIButton!
    
}

class TableViewCellButton: UITableViewCell{
    
    @IBOutlet weak var portalLabel: UILabel!
    @IBOutlet weak var portalButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
}

class TableViewCellTitle: UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
}


class ConfigurationsViewController: UIViewController, UITableViewDelegate {
    
   
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleConfigurations: UILabel!
    @IBOutlet var behindView: UIView!
    
    //Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    //** Alertas Bool **//
    var activeAlerts: Int?
    
    var pushIgnitionOnOff: Bool = false
    var pushSpeedLimit: Bool = false
    var pushBatteryDisconnected: Bool = false
    var pushBatteryVehicle: Bool = false
    var pushSupportButton: Bool = false
    var pushTowedUnit: Bool = false
    var pushValetMode: Bool = false
    var notificationsActive: Int = 0
    var finish: Bool = true
    
    var notificationActive: Bool = false
    var correoActivo: Bool = false
    var limiteVelocidad: Bool = false
    // Put vatriables handler
    var HasPush: Bool = false
    var HasEmail: Bool = false
    var Email: String = ""
    var Max_Speed: Float = 0.0
    var mailValue: String = ""
    var Valet: Bool = false
    var NotificationType: Int = 0
    var Notifications: Bool = false
    
    // DarkMode/LightMode
    var currentColorForText = UIColor()
    
    override func viewDidLoad() {
        
        //** language **//
        let langStr: String = Locale.current.languageCode!
        // english
        if( langStr == "en" ){
            titleConfigurations.text = "Configurations"
            // spanish
        } else {
            titleConfigurations.text = "Configuraciones"
        }
        
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
        
        hideKeyboardWhenTappedAround()
        getConfigurationsInfo()
        
        // SHOW/HIDE KEYBOARD
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        Analytics.logEvent("function_configuration", parameters: nil)
    }
    
    func setLightModeSettings(){
        self.view.backgroundColor = .white
        self.behindView.backgroundColor = .white
        self.tableView.backgroundColor = .white
        
        currentColorForText = UIColor(named: "grayBackground")!
    }
    
    func setDarkModeSettings(){
        self.view.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.behindView.backgroundColor = UIColor(hexString: "#1B1C20")!
        self.tableView.backgroundColor = UIColor(hexString: "#1B1C20")!
        
        currentColorForText = .white
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 250
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    struct Response: Codable{
        var success: Bool
        var items: item
    }
    
    struct item: Codable{
        var id: Int
        var Notifications: Bool
        var Max_Speed: Float
        var Email: String
        var Valet: Bool
        var NotificationType: Int?
        var HasEmail: Bool
        var HasPush: Bool
    }
    
    //** Get all the vehicle configurations info **//
    func getConfigurationsInfo() {
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
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
                        // Set the dictionary with the data
                        let configsInfo = try JSONDecoder().decode(Response.self, from: data)
                      
                        self.HasPush = configsInfo.items.HasPush
                        self.HasEmail = configsInfo.items.HasEmail
                        self.Email = configsInfo.items.Email
                        self.Max_Speed = configsInfo.items.Max_Speed
                        self.Valet = configsInfo.items.Valet
                        self.NotificationType = configsInfo.items.NotificationType ?? 0
                        self.Notifications = configsInfo.items.Notifications
                        
                        self.checkNotifications(alert: configsInfo.items.NotificationType ?? 0)
                        
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
    
    //** Revision de notificaciones activas en binario **//
    func checkNotifications(alert: Int) {
        DispatchQueue.main.async {
            var valueAlerts: [Int] = [1,2,4,8,16,32,64,128]
            var count: Int = 0
            var binario: Int?
            
            
            
            if(alert == 251 || alert == 255){
                
                self.correoActivo = true
                self.limiteVelocidad = true
                
                self.pushIgnitionOnOff = true
                self.pushSpeedLimit = true
                self.pushBatteryDisconnected = true
                self.pushBatteryVehicle = true
                self.pushSupportButton = true
                self.pushTowedUnit = true
                self.pushValetMode = true
                
                self.notificationsActive = self.notificationsActive + 255
                
            }else{
                
                while count < valueAlerts.count {
                    switch count {
                    case 0: //** Igniciones **//
                        binario = alert & valueAlerts[count]
                        if(binario == 1){
                            self.pushIgnitionOnOff = true
                            self.notificationsActive = self.notificationsActive + 1
                        }else{
                            self.pushIgnitionOnOff = false
                        }
                        count += 1
                        break
                        
                    case 1: //** Energia **//
                        binario = alert & valueAlerts[count]
                        if(binario == 2){
                            self.pushBatteryDisconnected = true
                            self.notificationsActive = self.notificationsActive + 2
                        }else{
                            self.pushBatteryDisconnected = false
                        }
                        count += 1
                        break
                        
                    case 2: //** Geocercas **//
                        binario = alert & valueAlerts[count]
                        if(binario == 4){
                            self.notificationsActive = self.notificationsActive + 4
                        }
                        count += 1
                        break
                        
                    case 3: //** velocidad **//
                        binario = alert & valueAlerts[count]
                        if(binario == 8){
                            self.limiteVelocidad = true
                            self.pushSpeedLimit = true
                            self.notificationsActive = self.notificationsActive + 8
                        }else{
                            self.pushSpeedLimit = false
                        }
                        count += 1
                        break
                        
                    case 4: //** Valet **//
                        binario = alert & valueAlerts[count]
                        if(binario == 16){
                            self.pushValetMode = true
                            self.notificationsActive = self.notificationsActive + 16
                        }else{
                            self.pushValetMode = false
                        }
                        count += 1
                        break
                        
                    case 5: //** Botones **//
                        binario = alert & valueAlerts[count]
                        if(binario == 32){
                            self.pushSupportButton = true
                            self.notificationsActive = self.notificationsActive + 32
                        }else{
                            self.pushSupportButton = false
                        }
                        count += 1
                        break
                        
                    case 6: //** remolques **//
                        binario = alert & valueAlerts[count]
                        if(binario == 64){
                            self.pushTowedUnit = true
                            self.notificationsActive = self.notificationsActive + 64
                        }else{
                            self.pushTowedUnit = false
                        }
                        count += 1
                        break
                        
                    case 7: //** Bateria Baja **//
                        binario = alert & valueAlerts[count]
                        if(binario == 128){
                            self.pushBatteryVehicle = true
                            self.notificationsActive = self.notificationsActive + 128
                        }else{
                            self.pushBatteryVehicle = false
                        }
                        count += 1
                        break
                    default:
                        break
                    }
                }
            }
            
            self.tableView.reloadData()
            
            
        }
    }
    
    // Put to change the data
    func putVehicleAlertConfig(){
        
        if CheckInternet.Connection(){
            
            let dictionarySub = [
                "id": CurrentVehicleInfo.VehicleId,
                "Email": Email,
                "Max_Speed": Max_Speed,
                "Notifications": self.Notifications,
                "Valet": Valet,
                "HasEmail": HasEmail,
                "HasPush": HasPush,
                "NotificationType": NotificationType,
            ] as [String : Any]
            
            let url = "https://rastreo.resser.com/api/alertsmobile/\(CurrentVehicleInfo.VehicleId)"
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
                    print("====ERROR putVehicleAlertConfig====")
                    print(error ?? "LOL")
                    
                    DispatchQueue.main.async {
                         self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                    }
                   
                    
                } else {
                   
                    DispatchQueue.main.async {
                        self.Alert(Title: "Exito", Message: "Datos Actualizados")
                    }
                    
                    
                }

            }
            dataTask.resume()
        }
    }
    
    //** Desbloqueo de Switchs **//
    func eneableSwitch() {
        
        var count = 6
        
        while count < 13 {
            print(count)
            if(count == 8) {
                
                let indexPath = IndexPath(row: count, section: 0)
                if (self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
                    let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellLabel
                    cell.textField.isUserInteractionEnabled = true
                }
                
                count += 1
                
            }else {
                
                let indexPath = IndexPath(row: count, section: 0)
                if (self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
                    let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellOptions
                    cell.switchOption.isEnabled = true
                }
               
                count += 1
                
            }
        }
        print(count)
    }
    
    //** Bloqueo de Switch **//
    func disableSwitch() {
        
        var count = 6
        print("disable")
        while  count < 13 {
            if(count == 8){
                
                let indexPath = IndexPath(row: count, section: 0)
                if (self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
                    let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellLabel
                    cell.textField.isUserInteractionEnabled = false
                }
                
                count += 1
                
            }else{
                
                let indexPath = IndexPath(row: count, section: 0)
                if (self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
                    let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellOptions
                    cell.switchOption.isEnabled = false
                }
                
                count += 1
              
            }
        }
        print(count)
    }
    
    
    @IBAction func goToPortal(_ sender: Any) {
        guard let url = URL(string: "https://spot.resser.com/admin") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    //** Swich Button **//
    @IBAction func SwitchValueChanged(_ sender: UISwitch) {
        
        DispatchQueue.main.async {
            switch (sender.tag) {
                        
                    //** Recibir push notificaciones **//
                    case 1:
                        if(self.HasPush == false){
                            self.HasPush = true
                            self.Notifications = true
                            self.putVehicleAlertConfig()
                            self.eneableSwitch()
                        } else {
                            
                            self.HasPush = false
                            self.Notifications = false
                            
                            self.putVehicleAlertConfig()
                            
                            if(self.HasPush == false && (self.HasEmail == true)){
                                
                            }else{
                                
                                self.disableSwitch()
                                
                            }
                        }
                        
                        break
                        
                    //** Notificaciones via correo **//
                    case 2:
                        if(self.HasEmail == false){
                            
                            self.correoActivo = true
                            self.HasEmail = true
                            self.putVehicleAlertConfig()
                            self.eneableSwitch()
                            
                        }else{
                            
                            self.correoActivo = false
                            self.HasEmail = false
                            self.putVehicleAlertConfig()
                            
                            let indexPath = IndexPath(row: 5, section: 0)
                            let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellLabel
                            cell.textField.resignFirstResponder()
                            
                            if(self.HasEmail == false && (self.HasPush == true)){
                                
                            }else{
                                
                                self.disableSwitch()
                                
                            }
                        }
                        
                        let indexPath: IndexPath = IndexPath(row: 5, section: 0)
                        let range = NSMakeRange(indexPath.section, 0)
                        let sectionToReload = NSIndexSet(indexesIn: range)
                        self.tableView.reloadSections(sectionToReload as IndexSet, with: UITableView.RowAnimation.fade)
                        
                        break
                        
                    //** Notificación de ignición/apagado **//
                    case 4:
                        if(self.pushIgnitionOnOff == false){
                            
                            self.pushIgnitionOnOff = true
                            self.notificationsActive = self.notificationsActive + 1
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }else{
                            
                            self.pushIgnitionOnOff = false
                            self.notificationsActive = self.notificationsActive - 1
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }
                        
                        break
                        
                    //** Notificación de exceso de velocidad **//
                    case 5:
                        if( self.pushSpeedLimit == false){
                            
                            self.limiteVelocidad = true
                            self.pushSpeedLimit = true
                            self.notificationsActive = self.notificationsActive + 8
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }else{
                            
                            self.limiteVelocidad = false
                            self.pushSpeedLimit = false
                            self.notificationsActive = self.notificationsActive - 8
                            self.NotificationType = self.notificationsActive
                            
                            let indexPath = IndexPath(row: 8, section: 0)
                            let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellLabel
                            cell.textField.resignFirstResponder()
                            
                            self.putVehicleAlertConfig()
                            
                        }
                        
                        let indexPath: IndexPath = IndexPath(row: 8, section: 0)
                        let range = NSMakeRange(indexPath.section, 0)
                        let sectionToReload = NSIndexSet(indexesIn: range)
                        self.tableView.reloadSections(sectionToReload as IndexSet, with: UITableView.RowAnimation.fade)
                        
                        break
                        
                    //** Desconexión de Bateria ** //
                    case 7:
                        
                        if(self.pushBatteryDisconnected == false){
                            
                            self.pushBatteryDisconnected = true
                            self.notificationsActive = self.notificationsActive + 2
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }else{
                            
                            self.pushBatteryDisconnected = false
                            self.notificationsActive = self.notificationsActive - 2
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }
                        break
                        
                    //** Bateria de vehículo **//
                    case 8:
                        
                        if(self.pushBatteryVehicle == false){
                            
                            self.pushBatteryVehicle = true
                            self.notificationsActive = self.notificationsActive + 128
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }else{
                            
                            self.pushBatteryVehicle = false
                            self.notificationsActive = self.notificationsActive - 128
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()
                            
                        }
                        
                        break
                        
                    //** Botón de asistencia **//
                    case 9:

                        if(self.pushSupportButton == false){

                            self.pushSupportButton = true
                            self.notificationsActive = self.notificationsActive + 32
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()

                        }else{

                            self.pushSupportButton = false
                            self.notificationsActive = self.notificationsActive - 32
                            self.NotificationType = self.notificationsActive
                            self.putVehicleAlertConfig()

                        }

                        break
            //        //** Valet **//
            //        case 11:
            //
            //            if(pushValetMode == false){
            ////                Analytics.logEvent("function_activate_valet", parameters: nil)
            //                pushValetMode = true
            //                Valet = true
            //                notificationsActive = notificationsActive + 16
            //                NotificationType = notificationsActive
            //
            //                putVehicleAlertConfig()
            //
            //            }else{
            ////                Analytics.logEvent("function_defuse_valet_fast", parameters: nil)
            //                pushValetMode = false
            //                Valet = false
            //                notificationsActive = notificationsActive - 16
            //                NotificationType = notificationsActive
            //
            //                putVehicleAlertConfig()
            //            }
            //            break
            //
            //        case 12:
            ////            putShare(sender.isOn)
            //            break
            //
            //        //MARK: Bloqueo de motor
            //        case 13:
            ////            preBlockEngine()
            //            break
                        
                    default:
                        break
                    }
                    
        }
        
    }
    
    //** Mensajes de ayuda **//
    func helpMessage(value:Int) {
        
        switch (value) {
        case 1:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Notificaciones", comment: "config_Message_Title_Notificaciones"),
                           message: NSLocalizedString("config_Message_Body_Notificaciones", comment: "config_Message_Body_Notificaciones"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 2:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Email", comment: "config_Message_Title_Email"),
                           message: NSLocalizedString("config_Message_Body_Email", comment: "config_Message_Body_Email"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 3:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Email_Label", comment: "config_Message_Title_Email_Label"),
                           message: NSLocalizedString("config_Message_Body_Email_Label", comment: "config_Message_Body_Email_Label"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 4:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Ignition", comment: "config_Message_Title_Ignition"),
                           message: NSLocalizedString("config_Message_Body_Ignition", comment: "config_Message_Body_Ignition"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 5:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Vel", comment: "config_Message_Title_Vel"),
                           message: NSLocalizedString("config_Message_Body_Vel", comment: "config_Message_Body_Vel"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 6:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Vel_Label", comment: "config_Message_Title_Vel_Label"),
                           message:NSLocalizedString("config_Message_Body_Vel_Label", comment: "config_Message_Body_Vel_Label"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 7:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Batery", comment: "config_Message_Title_Batery"),
                           message: NSLocalizedString("config_Message_Body_Batery", comment: "config_Message_Body_Batery"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 8:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Batery_Status", comment: "config_Message_Title_Batery_Status"),
                           message: NSLocalizedString("config_Message_Body_Batery_Status", comment: "config_Message_Body_Batery_Status"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 9:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Assist", comment: "config_Message_Title_Assist"),
                           message: NSLocalizedString("config_Message_Body_Assist", comment: "config_Message_Body_Assist"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
        case 10:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Valet", comment: "config_Message_Title_Valet"),
                           message: NSLocalizedString("config_Message_Body_Valet", comment: "config_Message_Body_Valet"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            
            break
        case 11:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Share", comment: "config_Message_Title_Share"),
                           message: NSLocalizedString("config_Message_Body_Share", comment: "config_Message_Body_Share"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
            
        case 12:
            self.ShowAlert(NSLocalizedString("config_Message_Title_Block", comment: "config_Message_Title_Block"),
                           message: NSLocalizedString("config_Message_Body_Block", comment: "config_Message_Body_Block"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
            
        case 13:
            self.ShowAlert(NSLocalizedString("portal_Info_Help", comment: "portal_Info_Help"),
                           message: NSLocalizedString("portal_Info_Message", comment: "portal_Info_Message"),
                           dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
            break
            
        default:
            break
        }
        
    }
    
    //** validación de email **//
    func isValidEmail( mail: String) -> Bool {
        
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return emailTest.evaluate(with: mail)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // BLOCK SWITCHES
        DispatchQueue.main.async {
            self.tableView.isScrollEnabled = false
            
            var i: Int = 0
            while( i < 12 ){ // 12 for normal
                if( i != 5 && i != 8 && i != 0 && i != 1 && i != 2 ){
                    
                    let indexPath = IndexPath(row: i, section: 0)
                    if (self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
                        // Your code here
                        let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellOptions
                        cell.switchOption.isEnabled = false
                    }
                    
                }
                
                i += 1
            }
            
        }
    }
    
    //** Finalización de edicion y toma de valores de mail y velocidad **//
    func textFieldDidEndEditing(_ textField: UITextField) {
        // BLOCK SWITCHES
        DispatchQueue.main.async {
                self.tableView.isScrollEnabled = true
                    var i: Int = 0
                    while( i < 9 ){ // 12 for normal
                        if( i != 5 && i != 8 && i != 0 && i != 1 && i != 2 ){
                            let indexPath = IndexPath(row: i, section: 0)
                            let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCellOptions
                            cell.switchOption.isEnabled = true
                        }
                        
                        i += 1
                    }
            
            
            switch (textField.tag) {
            case 3:
                
                self.mailValue = textField.text!
                let correcto = self.isValidEmail(mail: self.mailValue)
                
                //** El usiuario coloca correctamente su Email(formato del email) **//
                if(correcto == true){
                    self.Email = self.mailValue
                    self.putVehicleAlertConfig()
                }else{
                    self.ShowAlert(NSLocalizedString("config_Email_Error_Title", comment: "config_Email_Error_Title"),
                                   message: NSLocalizedString("config_Email_Message_Error", comment: "config_Email_Message_Error"),
                                   dismiss: NSLocalizedString("config_Message_Dissmis", comment: "config_Message_Dissmis"))
                }
                break
                
            case 6:
                
                if(textField.text != ""){
                    self.Max_Speed = NumberFormatter().number(from: textField.text!)!.floatValue
                    self.putVehicleAlertConfig()
                }
                
                break
            default:
                break
            }
        }
        
        textField.resignFirstResponder()
    }
    
    @IBAction func returnToMenu(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func helpButtonTap(_ sender: Any) {
        helpMessage(value: (sender as AnyObject).tag)
    }
    
    @IBAction func helpButtonTap2(_ sender: Any) {
        helpMessage(value: (sender as AnyObject).tag)
    }
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    //** Alertas informativas **//
    func ShowAlert(_ title: String, message: String, dismiss: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: dismiss, style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ConfigurationsViewController: UITableViewDataSource, UITextFieldDelegate {
   
    //** Número de secciones internas **//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12;
    }
    
    //************** Tamaños de las secciones de la tabla *******************//
    func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //** caso en que no se tenga activadas as notificaciones de correo y velocidad **//
        if(HasEmail == false && (indexPath.row == 5)){
            return 0.0
        }
        
        if(limiteVelocidad == false && (indexPath.row == 8)){
            return 0.0
        }
        
        //** caso en que se tenga activadas las notificaciones de correo y velocidad**//
        if(HasEmail == true && (indexPath.row == 5)){
            return 60
        }
        
        //**  **//
        if(limiteVelocidad == true && (indexPath.row == 8)){
            return 60
        }
        
      
        
        return 60
        
    }
    
    //Contenido
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            case 0:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellForTitle", for: indexPath) as! TableViewCellTitle
                cell.titleLabel.text = NSLocalizedString("portal_Info_Label", comment: "portal_Info_Label")
                cell.selectionStyle = .none;
                return cell
            
            case 1:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Portal", for: indexPath) as! TableViewCellButton
                cell.portalLabel.text = NSLocalizedString("portal_Info_Label", comment: "portal_Info_Label")
                cell.portalButton.setTitle(NSLocalizedString("portal_Info_Button", comment: "portal_Info_Button"), for: .normal)
                cell.helpButton.tag = 13
                cell.selectionStyle = .none;
                cell.portalLabel.textColor = currentColorForText
                return cell
            case 2:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellForTitle", for: indexPath) as! TableViewCellTitle
                cell.titleLabel.text = "General"
                cell.selectionStyle = .none;
                return cell
            case 3:
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText?.text = NSLocalizedString("config_Section_Notification", comment: "config_Section_Notification")
                //añadir cambios
                cell.selectionStyle = .none;
                cell.labelText.textColor = currentColorForText
                cell.switchOption.setOn(HasPush, animated: true)
                cell.switchOption.tag = 1
                cell.helpButton.tag = 1
                return cell
                
            case 4://Notificaciones via correo
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText.text = NSLocalizedString("config_Section_Email", comment: "config_Section_Email")
                cell.labelText.textColor = currentColorForText
                cell.switchOption.setOn(HasEmail, animated: true)
                cell.selectionStyle = .none;
                cell.switchOption.tag = 2
                cell.helpButton.tag = 2
                return cell
                
            case 5://Campo de correo
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option2", for: indexPath) as! TableViewCellLabel
//                cell.labelText.text = NSLocalizedString("config_Section_Correo", comment: "config_Section_Correo")
                if(Email == ""){
                    cell.textField.attributedPlaceholder = NSAttributedString(string:"TuCorreo@mail.com", attributes:[NSAttributedString.Key.foregroundColor:UIColor.white])
                }else{
                    cell.textField.text = Email
                }
                cell.selectionStyle = .none;
                cell.textField.textColor = currentColorForText
                cell.textField.delegate = self
                cell.textField.underlinedGreen()
                cell.textField.keyboardType = UIKeyboardType.emailAddress
                cell.textField.tag = 3
                cell.textField.isUserInteractionEnabled = true
                cell.helpButton.tag = 3
                return cell
                
            case 6://Notificaciones de Ignicion/Apagado
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText.text = NSLocalizedString("config_Section_Ignite", comment: "config_Section_Ignite")
                cell.switchOption.setOn(pushIgnitionOnOff, animated: true)
                cell.switchOption.tag = 4
                cell.helpButton.tag = 4
                cell.labelText.textColor = currentColorForText
                cell.selectionStyle = .none;
                //**  **//
                if(HasPush == true || HasEmail == true){
                    cell.switchOption.isEnabled = true
                }else{
                    cell.switchOption.isEnabled = false
                }
                return cell
                
            case 7://Notificacion de exceso de velocidad
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText.text = NSLocalizedString("config_Section_Vl", comment: "config_Section_Vl")
                cell.switchOption.setOn(pushSpeedLimit, animated: true)
                cell.switchOption.tag = 5
                cell.helpButton.tag = 5
                cell.selectionStyle = .none;
                cell.labelText.textColor = currentColorForText
                //**  **//
                if(HasPush == true || HasEmail == true){
                    cell.switchOption.isEnabled = true
                }else{
                    cell.switchOption.isEnabled = false
                }
                return cell
                
            case 8://Campo de limite de velocidad
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option2", for: indexPath) as! TableViewCellLabel
//                cell.labelText.text = NSLocalizedString("config_Section_Max_Vl", comment: "config_Section_Max_Vl")
                if(Max_Speed == 0.0){
                    cell.textField.attributedPlaceholder = NSAttributedString(string:"0.0 KM", attributes:[NSAttributedString.Key.foregroundColor:UIColor.white])
                }else{
                    cell.textField.text = "\(Max_Speed)"
                }
                cell.textField.textColor = currentColorForText
                cell.textField.underlinedGreen()
                cell.textField.delegate = self
                cell.textField.keyboardType = UIKeyboardType.numbersAndPunctuation
                cell.textField.tag = 6
                cell.helpButton.tag = 6
                cell.textField.isUserInteractionEnabled = true
                cell.selectionStyle = .none;
                return cell
                
            case 9://Notificacion de desconexion de bateria
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText.text = NSLocalizedString("config_Section_Disconnection", comment: "config_Section_Disconnection")
                cell.labelText.textColor = currentColorForText
                cell.switchOption.setOn(pushBatteryDisconnected, animated: true)
                cell.switchOption.tag = 7
                cell.helpButton.tag = 7
                cell.selectionStyle = .none;
                //**  **//
                if(HasPush == true || HasEmail == true){
                    cell.switchOption.isEnabled = true
                }else{
                    cell.switchOption.isEnabled = false
                }
                return cell
                
            case 10://Notificacion de Bateria del vehiculo
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText.text = NSLocalizedString("config_Section_Batery", comment: "config_Section_Batery")
                cell.labelText.textColor = currentColorForText
                cell.switchOption.setOn(pushBatteryVehicle, animated: true)
                cell.switchOption.tag = 8
                cell.helpButton.tag = 8
                cell.selectionStyle = .none;
                //**  **//
                if(HasPush == true || HasEmail == true){
                    cell.switchOption.isEnabled = true
                }else{
                    cell.switchOption.isEnabled = false
                }
                return cell
                
            case 11://Notificacion de Asistencia
                //*********************************
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
                cell.labelText.text = NSLocalizedString("config_Section_Assist", comment: "config_Section_Assist")
                
                cell.labelText.textColor = currentColorForText
                
                cell.switchOption.setOn(pushSupportButton, animated: true)
                cell.switchOption.tag = 9
                cell.helpButton.tag = 9
                cell.selectionStyle = .none;
                //**  **//
                if(HasPush == true || HasEmail == true){
                    cell.switchOption.isEnabled = true
                }else{
                    cell.switchOption.isEnabled = false
                }
                return cell
            
           
            
            default:
                break
            }
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Option1", for: indexPath) as! TableViewCellOptions
        return cell
    }
    
}
