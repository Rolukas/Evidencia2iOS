//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import Firebase

class MapPopupViewController: UIViewController {
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    var isShareMySpotActive = Bool()
    var hashOfShareMySpot = String()
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var principalButton: UIButton!
    @IBOutlet weak var shareMySpotButton: UIView!
    
    // Struct Share My Spot
    struct Response: Codable{
        var success: Bool
        var item: item
    }
    
    struct item: Codable {
        var hash: String
        var active: Bool
    }
    
    
    override func viewDidLoad() {
        
        //** Add gesture recognizer to view in case the user want to exit **//
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mainView.addGestureRecognizer(tap)
        
        //** Add gesture recognizer to share my spot option  **//
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.shareMySpot(_:)))
        shareMySpotButton.addGestureRecognizer(tap2)
        
        Analytics.logEvent("function_share_my_spot_more", parameters: nil)
        
    }
    
    @objc func shareMySpot(_ sender: UITapGestureRecognizer) {
        checkForShareMySpot()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    //** Hide Popup **//
    @IBAction func onDismissPopup(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func shareMySpot(){
        let StringToShare = "https://sharemyspot.resser.com/?\(hashOfShareMySpot)"
        
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
                                self.shareMySpotIsActive()
                            } else {
                                self.shareMySpotIsNotActive()
                            }
                        }
                        
                        // Error on get
                    } catch {
                        self.shareMySpotIsNotActive()
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    func shareMySpotIsActive(){
        shareMySpot()
    }
    
    func shareMySpotIsNotActive(){
        putShareMySpot(option: "Activate")
    }
    
    func putShareMySpot(option: String){
        print("=====PUT SHARE MY SPOT BUTTON MAP POPUP=====")
        var dictionarySub = [String : Any]()
        
        if(option == "Desactivate"){
            
            dictionarySub = [
                "vehicleId": CurrentVehicleInfo.VehicleId,
                "active": false
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
                
                self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message") + "\(String(describing: error))")
                
            } else {
                print("===== PUT :( =====")
                
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Parsed JSON from PUT: '\(String(describing: jsonStr))'")
                
                DispatchQueue.main.async {
                    if(option == "Desactivate"){
                        self.Alert(Title: NSLocalizedString("SMS_alert_message_SuccessTitle", comment: "SMS_alert_message_SuccessTitle"), Message: NSLocalizedString("SMS_alert_message_SuccessMessageDesactivated", comment: "SMS_alert_message_SuccessMessageDesactivated"))
                    } else {
                        self.shareMySpot()
                    }
                }
                
            }
            
        }
        dataTask.resume()
    }
    
    
    func checkForLinkShareOfMySpot(){
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
                        self.shareMySpot()
                        
                        // Error on get
                    } catch {
                        
                        print("Error checkForLinkShareOfMySpot: ")
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
}
