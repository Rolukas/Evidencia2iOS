//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit

class GuardModeAlertPopupViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var desactivateButton: UIButton!
    @IBOutlet weak var callCabinButton: UIButton!
    @IBOutlet weak var vehicleDescriptionLabel: UILabel!
    @IBOutlet weak var isOnMovingLabel: UILabel!
    @IBOutlet weak var guardModeTitleLabel: UILabel!
    
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    var arrayOfVehicleId = [Int]()
    var arrayOfVehicleName = [String]()
    
    // Structs
    struct Response: Codable {
        var success: Bool
        var items: [item]?
    }
    
    struct item: Codable {
        var vehicleId: Int
        var vehicleName: String
    }
    
    override func viewDidLoad() {
        
        DispatchQueue.main.async {
            self.mainView.alpha = 0
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainView.addGestureRecognizer(tap)
        
        getAllGuardModePendingAlerts()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    func getAllGuardModePendingAlerts(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/guardianalertmobile" as NSString
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
                        
                        self.arrayOfVehicleName.removeAll()
                        self.arrayOfVehicleId.removeAll()
                        
                        // get JSON
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        // Set the dictionary with the data
                        let guardModeInfo = try JSONDecoder().decode(Response.self, from: data)
                       
                        if(guardModeInfo.items != nil){
                            
                            for alarm in guardModeInfo.items!{
                                self.arrayOfVehicleId.append(alarm.vehicleId)
                                self.arrayOfVehicleName.append(alarm.vehicleName)
                            }
                            
                        }

                        if(self.arrayOfVehicleName.count == 0){
                            
                            DispatchQueue.main.async{
                               self.dismiss(animated: true)
                            }
                            
                            
                        } else {
                            
                            self.setInfo()
                            
                        }
                        
                        // Error on get
                    } catch {
                        
                        print("Error on Guard Mode Alert Popup: ")
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
    
    func setInfo(){
        
        DispatchQueue.main.async {
            
            let langStr: String = Locale.current.languageCode!
            if( langStr == "en" ){
                
                self.vehicleDescriptionLabel.text = "The vehicle"
                self.vehicleNameLabel.text = self.arrayOfVehicleName[self.arrayOfVehicleName.count - 1]
                self.isOnMovingLabel.text = "is on moving"
                self.desactivateButton.setTitle("Desactivate", for: .normal)
                self.callCabinButton.setTitle("Call to Resser cabin", for: .normal)
                
            }else{
                
                self.vehicleDescriptionLabel.text = "El vehículo"
                self.vehicleNameLabel.text = self.arrayOfVehicleName[self.arrayOfVehicleName.count - 1]
                self.isOnMovingLabel.text = "está en movimiento"
                self.desactivateButton.setTitle("Desactivar", for: .normal)
                self.callCabinButton.setTitle("Llamar a cabina resser", for: .normal)
                
            }
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.mainView.alpha = 1
            })
            
        }
        
        
    }
    
    @IBAction func desactivate(_ sender: Any) {
        
        let dictionarySub = [
            "vehicleId": self.arrayOfVehicleId[self.arrayOfVehicleId.count - 1]
        ] as [String : Any]
        
        
        let url = "https://rastreo.resser.com/api/GuardianAlertMobile"
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
                print("==== desactivateGuardMode ERROR====")
                print(error ?? "LOL")
                
            } else {
                
                self.getAllGuardModePendingAlerts()
                
            }
            
        }
        dataTask.resume()
        
        
    }
    
    
    
    @IBAction func callCabin(_ sender: Any) {
        "(33)-2300-6904".makeAColl()
    }
    
    
    //** Function to create alerts **//
    func Alert (Title: String, Message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    

}
