//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit

class launcherViewController: UIViewController {
    
    //** Structs to fill with the JSON data **//
    struct Login: Codable {
        let success: Bool
        let items: item
    }
    
    struct item: Codable {
        let EmailMobile: String?
        let Version: String?
    }
    
    override func viewDidLoad() {

        if( UserDefaults.standard.bool(forKey: "rememberMe") == true ){
            
            let userDefault = UserDefaults.standard.string(forKey: "user") ?? ""
            let passDefault = UserDefaults.standard.string(forKey: "pass") ?? ""
           
            //** Login **//
            let loginString = NSString(format: "%@:%@", userDefault, passDefault)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            
            let jsonUrlRequest = "https://rastreo.resser.com/api/login?code=4&OS=2"
            let url = URL(string: jsonUrlRequest)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let Session = URLSession.shared
            Session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                            // Set the dictionary with the data
                            let login = try JSONDecoder().decode(Login.self, from: data)
                            
                            print("Login Response: ")
                            print(login.items.Version as! String)
                            
                            if(login.success == true){
                                
                                DispatchQueue.main.async {
                                    // Go to map
                                    self.performSegue(withIdentifier: "toMap", sender: self)
                                }
                                
                            }
                            
                        } catch {
                            
                            self.onError() // Invalid credentials
                            
                            self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message"))

                            DispatchQueue.main.async {
                                // Go to map
                                self.performSegue(withIdentifier: "toLogin", sender: self)
                            }
                        }
                }
            }.resume()
            
        } else {
            
            DispatchQueue.main.async {
                // Go to login
                self.performSegue(withIdentifier: "toLogin", sender: self)
            }
            
            
        }
    }
    
    // Present invalid credentials
    func onError(){
        DispatchQueue.main.async {
            self.Alert(Title: "Error", Message: NSLocalizedString("login_error_message", comment: "login_error_message"))
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
