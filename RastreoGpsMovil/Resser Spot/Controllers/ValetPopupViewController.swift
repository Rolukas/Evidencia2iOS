//
//  ValetPopupViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/2/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import Foundation

class ValetPopupViewController: UIViewController {
    
    // Global Info of vehicle
    struct vehicleInfo: Codable{
        let success: Bool
        let items: item
    }
    
    struct item: Codable{
        let id: Int
        let Notifications: Bool
        let Max_Speed: Int
        let Email: String
        let Valet: Bool
        let NotificationType: Int?
        let HasEmail: Bool
        let HasPush: Bool
    }
    
    // Variables
    var username: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var password: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    var valetIsActive: Bool = true
    
    // set the UIAlerController property
    var alert: UIAlertController!
    
    // Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var valetImage: UIImageView!
    @IBOutlet weak var valetTitle: UILabel!
    @IBOutlet weak var valetDescription: UILabel!
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainView.addGestureRecognizer(tap)
        
        getValetModeInformation()
    }
    
    
    // Get the info to Display the context of the valet mode
    func getValetModeInformation(){
        
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            //vehiclesmobile?VehcileId=
            let url : NSString  = "https://rastreo.resser.com/api/alertsmobile?id=\(CurrentVehicleInfo.VehicleId)" as NSString
            let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
            let searchURL : NSURL = NSURL(string: urlStr as String)!
            var request = URLRequest(url: searchURL as URL)
            let loginString = NSString(format: "%@:%@", username, password)
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
                        let vehicleInformation = try JSONDecoder().decode(vehicleInfo.self, from: data)
                        // Set Global Info
                        self.valetIsActive = vehicleInformation.items.Valet
                        // Set the context of the popup
                        self.setValetContext()
                        
                        // Error on get
                    } catch {
                        
                        print("Error on getValetModeInformation: ")
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
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    // When the data load is done, the set the context o the popup (Is Active/Inactive)
    func setValetContext(){
        
        DispatchQueue.main.async {
            // Context to desactivate the valet mode
            if(self.valetIsActive){
                self.valetImage.image = UIImage(named: "valet_inactive")
                self.valetTitle.textColor = UIColor.red
                self.onOffButton.setTitleColor(UIColor.red, for: .normal)
                self.valetDescription.text = NSLocalizedString("valet_desactivate_message", comment: "valet_desactivate_message")
                self.onOffButton.setTitle(NSLocalizedString("valet_desactivate_button", comment: "valet_desactivate_button"), for: .normal)
                // Context to activate the valet mode
            } else {
                self.valetImage.image = UIImage(named: "valet_active")
                self.valetTitle.textColor = UIColor(named: "spotGreen")
                self.onOffButton.setTitleColor(UIColor(named: "spotGreen"), for: .normal)
                self.valetDescription.text = NSLocalizedString("valet_activate_message", comment: "valet_activate_message")
                self.onOffButton.setTitle(NSLocalizedString("valet_activate_button", comment: "valet_activate_button"), for: .normal)
            }
            
            self.cancelButton.setTitle(NSLocalizedString("valet_cancel_button", comment: "valet_cancel_button"), for: .normal)
        }
        
    }
    
    @IBAction func onValetPress(_ sender: Any) {
        configValet()
    }
    
    func configValet(){
        
        if(valetIsActive){
            
            let dictionary = [
                "id": CurrentVehicleInfo.VehicleId,
                "Email": CurrentVehicleInfo.Email,
                "Max_Speed": CurrentVehicleInfo.Max_Speed,
                "Notifications": true,
                "Valet": false,
                "HasEmail": CurrentVehicleInfo.HasEmail,
                "HasPush": CurrentVehicleInfo.HasPush,
                "NotificationType": CurrentVehicleInfo.NotificationType - 16
                ] as [String : Any]
            
            putValetMode(dictionary: dictionary)
            
        } else {
            
            let dictionary = [
            "id": CurrentVehicleInfo.VehicleId,
            "Email": CurrentVehicleInfo.Email,
            "Max_Speed": CurrentVehicleInfo.Max_Speed,
            "Notifications": true,
            "Valet": true,
            "HasEmail": CurrentVehicleInfo.HasEmail,
            "HasPush": CurrentVehicleInfo.HasPush,
            "NotificationType": CurrentVehicleInfo.NotificationType + 16
            ] as [String : Any]
            
            putValetMode(dictionary: dictionary)
            
        }
    }
    
    func putValetMode(dictionary: Any){
        let url = "https://rastreo.resser.com/api/alertsmobile/\(CurrentVehicleInfo.VehicleId)"
        let URL: Foundation.URL = Foundation.URL(string: url)!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
        request.httpMethod = "PUT"
        
        let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: JSONSerialization.WritingOptions(rawValue: 0))
        let theJSONText = NSString(data: theJSONData!,
                                   encoding: String.Encoding.ascii.rawValue)
        
        request.httpBody = theJSONText!.data(using: String.Encoding.utf8.rawValue);
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")//   application/x-www-form-urlencoded
        let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
                
                //handle error
                print("====ERROR FROM VALET PUT====")
                print(error ?? "LOL")
                
                self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
            } else {
                
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                DispatchQueue.main.async{
                    self.dismiss(animated: true)
                }
                
                
            }
            
        }
        dataTask.resume()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}
