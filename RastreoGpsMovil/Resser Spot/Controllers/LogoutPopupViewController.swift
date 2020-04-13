//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit

class LogoutPopupViewController: UIViewController {
    
    weak var timer: Timer?
    weak var mapView: MapViewController?
    
    @IBOutlet weak var principalView: UIView!
    @IBOutlet weak var logoutOption: UIView!
    @IBOutlet weak var logoutLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        
        logoutLabel.text = NSLocalizedString("map_Menu_LogOut", comment: "map_Menu_LogOut")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        principalView.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2(_:)))
        logoutOption.addGestureRecognizer(tap2)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc func handleTap2(_ sender: UITapGestureRecognizer) {
        
        print("LOGOUT")
        
        DispatchQueue.main.async {
            self.deleteDeviceId()
            // Set to the storage
            UserDefaults.standard.set(" ", forKey: "user")
            UserDefaults.standard.set(" ", forKey: "pass")
            UserDefaults.standard.set(false, forKey: "rememberMe")
            UserDefaults.standard.set(0, forKey: "timesMenuOpen")
            if( UserDefaults.standard.array(forKey: "vehiclesNull") != nil ){
                UserDefaults.standard.set([], forKey: "vehiclesNull")
                UserDefaults.standard.set([], forKey: "vehiclesNullDate")
            }
            UserDefaults.standard.synchronize()
            self.timer?.invalidate()
            self.performSegue(withIdentifier: "toLoginOnLogout", sender: self)
        }
        
    }
    
    func deleteDeviceId(){
        
        let user = UserDefaults.standard.string(forKey: "user") ?? ""
        let pass = UserDefaults.standard.string(forKey: "pass") ?? ""
        let deviceId = UserDefaults.standard.string(forKey: "pushNotificationsDeviceId") ?? ""
        
        if CheckInternet.Connection(){
            
            let dictonarySub = [
                "Id":       1,
                "idPushDeviceId": 0,
                "Key":      deviceId,
                "Os":       2,
                "Active":   false
            ] as [String : Any]
            
            print(dictonarySub)
            
            let url = "https://rastreo.resser.com/api/PushNotification"
            let URL: Foundation.URL = Foundation.URL(string: url)!
            let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
            request.httpMethod = "PUT"
            
            let theJSONData = try? JSONSerialization.data(
                withJSONObject: dictonarySub,
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
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message") + "\(String(describing: error))")
                    
                } else {
                    
                    print("====RESPONSE IN POST REGISTER DEVICE====")
                    print(data ?? "")
                    
                }
                
            }
            dataTask.resume()
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
