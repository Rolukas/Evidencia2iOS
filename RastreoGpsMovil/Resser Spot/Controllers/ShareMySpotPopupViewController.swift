//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import Firebase

class ShareMySpotPopupViewController: UIViewController {
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    var isShareMySpotActive = Bool()
    var hashOfShareMySpot = String()
    var hadTriedPost: Bool = false
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var switchShare: UISwitch!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // Struct Share My Spot
    struct Response: Codable{
        var success: Bool
        var item: item
    }
    
    struct item: Codable{
        var hash: String
        var active: Bool
    }
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainView.addGestureRecognizer(tap)
        checkForShareMySpot()
        Analytics.logEvent("function_share_my_spot_more", parameters: nil)
    }
    
    @IBAction func onSwitchChanged(_ sender: Any) {
        if(isShareMySpotActive){
            putShareMySpot(option: "Desactivate")
        } else {
            putShareMySpot(option: "Activate")
        }
    }
    
    @IBAction func shareButton(_ sender: Any) {
        print("Prev state: \(isShareMySpotActive)")
        if(!isShareMySpotActive){
            putShareMySpot(option: "toShare")
        } else {
            shareMySpot()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        dismiss(animated: true)
    }
    
    @IBAction func controlButton(_ sender: Any) {
        if(isShareMySpotActive){
            putShareMySpot(option: "Desactivate")
        } else {
            putShareMySpot(option: "Activate")
        }
    }
    
    func shareMySpot(){
        let StringToShare = "http://sharemyspot.resser.com/?\(hashOfShareMySpot)"
        
        let activityController = UIActivityViewController(activityItems: [StringToShare], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error)
            in
            if completed{
              
            } else {
                
            }
            
        }
        
        present(activityController, animated: true){
            
        }
    }
    
    func checkForShareMySpot(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/sharepositionmobile?vehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        let shareMySpotInformation = try JSONDecoder().decode(Response.self, from: data)
                        // is active or not
                        self.isShareMySpotActive = shareMySpotInformation.item.active
                        self.hashOfShareMySpot = shareMySpotInformation.item.hash
                        
                        DispatchQueue.main.async {
                            if(self.isShareMySpotActive){
                                
                                self.switchShare.isOn = true
                                self.activateButton.setTitle(NSLocalizedString("shareMySpot_popup_desactivate", comment: "shareMySpot_popup_desactivate"), for: .normal)
                                self.activateButton.setTitleColor(UIColor.red, for: .normal)
                                
                            } else {
                                
                                self.switchShare.isOn = false
                                self.activateButton.setTitle(NSLocalizedString("shareMySpot_popup_activate", comment: "shareMySpot_popup_activate"), for: .normal)
                                self.activateButton.setTitleColor(UIColor(named: "spotGreen"), for: .normal)
                                
                            }
                            
                            self.shareButton.setTitle(NSLocalizedString("shareMySpot_popup_share", comment: "shareMySpot_popup_share"), for: .normal)
                            self.cancelButton.setTitle(NSLocalizedString("shareMySpot_popup_cancel", comment: "shareMySpot_popup_cancel"), for: .normal)
                        }
                        
                        
                    // Error on get
                    } catch {
                        
                        if(!self.hadTriedPost){
                            
                            print("FALLA Y HACE EL POST")
                            self.postToCreateIt()
                            self.hadTriedPost = true
                            
                        } else {
                            
                            print("Error checkForShareMySpot: ")
                            print(error)
                            
                            self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                            
                        }
                        
                       
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    func checkForShareMySpotToShare(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/sharepositionmobile?vehicleId=\(CurrentVehicleInfo.VehicleId)" as NSString
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
                        let shareMySpotInformation = try JSONDecoder().decode(Response.self, from: data)
                        // is active or not
                        self.isShareMySpotActive = shareMySpotInformation.item.active
                        self.hashOfShareMySpot = shareMySpotInformation.item.hash
                        
                        DispatchQueue.main.async {
                            if(self.isShareMySpotActive){
                                
                                self.switchShare.isOn = true
                                self.activateButton.setTitle(NSLocalizedString("shareMySpot_popup_desactivate", comment: "shareMySpot_popup_desactivate"), for: .normal)
                                self.activateButton.setTitleColor(UIColor.red, for: .normal)
                                
                            } else {
                                
                                self.switchShare.isOn = false
                                self.activateButton.setTitle(NSLocalizedString("shareMySpot_popup_activate", comment: "shareMySpot_popup_activate"), for: .normal)
                                self.activateButton.setTitleColor(UIColor(named: "spotGreen"), for: .normal)
                                
                            }
                            
                            self.shareButton.setTitle(NSLocalizedString("shareMySpot_popup_share", comment: "shareMySpot_popup_share"), for: .normal)
                            self.cancelButton.setTitle(NSLocalizedString("shareMySpot_popup_cancel", comment: "shareMySpot_popup_cancel"), for: .normal)
                            
                            
                            self.shareMySpot()
                        }
                        
                        
                    // Error on get
                    } catch {
                        
                        if(!self.hadTriedPost){
                            
                            self.postToCreateIt()
                            self.hadTriedPost = true
                            
                        } else {
                            
                            print("Error checkForShareMySpot: ")
                            print(error)
                            
                            self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
                            
                        }
                        
                       
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    //** If the user doesn't have an insurance data, then create it **//
    func postToCreateIt(){
       print("=====PUT SHARE MY SPOT BUTTON MAP POPUP=====")
              var dictionarySub = [String : Any]()
              
            
                  
              dictionarySub = [
                  "vehicleId": CurrentVehicleInfo.VehicleId,
                  "active": true
              ] as [String : Any]
                  
          
              
              let url = "https://rastreo.resser.com/api/sharepositionmobile?vehicleId=\(CurrentVehicleInfo.VehicleId)"
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
                      print("==== putShareMySpot ====")
                      print(error ?? "LOL")
                      
                      self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message") + "\(String(describing: error))")
                      
                  } else {
                    self.checkForShareMySpot()
                  }
                  
              }
          dataTask.resume()
    }
    
    func shareMySpotIsActive(){
        shareMySpot()
    }
    
    func shareMySpotIsNotActive(){
        putShareMySpot(option: "Activate")
    }
    
    func putShareMySpot(option: String){
        
        print("option: \(option)")
        
        print("=====PUT SHARE MY SPOT======")
        
        var dictionarySub = [String : Any]()
        
        if(option == "Desactivate"){
            
            dictionarySub = [
                "vehicleId": CurrentVehicleInfo.VehicleId,
                "active": false
                ] as [String : Any]
            
        } else if(option == "Activate") {
            
            dictionarySub = [
                "vehicleId": CurrentVehicleInfo.VehicleId,
                "active": true
                ] as [String : Any]
            
        } else {
            dictionarySub = [
                "vehicleId": CurrentVehicleInfo.VehicleId,
                "active": true
                ] as [String : Any]
        }
        
        let url = "https://rastreo.resser.com/api/sharepositionmobile?vehicleId=\(CurrentVehicleInfo.VehicleId)"
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
                print("==== putShareMySpot ====")
                print(error ?? "LOL")
                self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))
            } else {
                
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                DispatchQueue.main.async {
                    if(option == "Desactivate"){
                       self.Alert(Title: NSLocalizedString("SMS_alert_message_SuccessTitle", comment: "SMS_alert_message_SuccessTitle"), Message: NSLocalizedString("SMS_alert_message_SuccessMessageDesactivated", comment: "SMS_alert_message_SuccessMessageDesactivated"))
                        self.checkForShareMySpot()
                    } else if(option == "toShare"){
                        print("Entra a toShare")
                        self.checkForShareMySpotToShare()
                    } else {
                        self.Alert(Title: NSLocalizedString("SMS_alert_message_SuccessTitle", comment: "SMS_alert_message_SuccessTitle"), Message: NSLocalizedString("SMS_alert_message_SuccessMessageActivated", comment: "SMS_alert_message_SuccessMessageActivated"))
                        self.checkForShareMySpot()
                    }
                }
                
            }
            
        }
        dataTask.resume()
    }

    func Alert (Title: String, Message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
