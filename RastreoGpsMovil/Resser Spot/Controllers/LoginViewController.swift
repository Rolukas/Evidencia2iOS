//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //** Variables **//
    var userVersion: String!
    
    //** Outlets **//
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var recoverPasswordButton: UIButton!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var subBackgroundView: UIView!
    
    var userDefault = String()
    var passDefault = String()
    
    //** Structs to fill with the JSON data **//
    struct Login: Codable {
        let success: Bool
        let items: item
    }
    
    struct item: Codable {
        let EmailMobile: String?
        let Version: String?
        let EmailUser: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        // setGlobal instances
        userDefault = UserDefaults.standard.string(forKey: "user") ?? ""
        passDefault = UserDefaults.standard.string(forKey: "pass") ?? ""

        //Background Video Configuration
        setupView()
        mainView.bringSubviewToFront(subBackgroundView)
        
        // Underline TextFields
        userTextField.underlinedGreen()
        passwordTextField.underlinedGreen()
        
        userTextField.delegate = self
        passwordTextField.delegate = self
        
        //Placeholders
        userTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("login_User_Placeholder", comment: "login_User_Placeholder"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("login_Pass_Placeholder", comment: "login_Pass_Placeholder"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        // Set texts
        recoverPasswordButton.setTitle(NSLocalizedString("recover_Password_Tittle", comment: "recover_Password_Tittle"), for: .normal)
     
        loginButton.setTitle(NSLocalizedString("login_button_title", comment: "login_button_title"), for: .normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        userVersion = nsObject as? String
        print(userVersion ?? "")
     
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 200
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.tag == 1){
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            checkLogin()
        }
        
        return true
    }
    
    
    
    //** Setup the video in the background **//
    private func setupView(){
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mov")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.mainView.frame
        self.mainView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.play()
        // Loop video
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector:  #selector(LoginViewController.videoDidPlayToEnd(_:)), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }
    
    //** Loop video **//
    @objc func videoDidPlayToEnd(_ notification: Notification){
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    //** Touch on Login Button **//
    @IBAction func onLogin(_ sender: Any) {
        loadIndicator.startAnimating()
        
        // Check internet connection
        if CheckInternet.Connection(){
            checkLogin() // check all the data to login
        } else {
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            loadIndicator.stopAnimating()
        }
        
    }
    
    //** Make the get with user credentials **//
    func checkLogin(){
        
        let user =  userTextField.text! as String // User from textfield
        var pass = passwordTextField.text! as String // Password from textfield
        // trimm last whitespaces
        pass = pass.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        //** Login **//
        let loginString = NSString(format: "%@:%@", user, pass)
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
                    CurrentVehicleInfo.EmailUser = login.items.EmailUser ?? ""
                    // Check user version
                    
                    // NEEDS UPDATE
                    var lastUpdate: Bool = true
                    let versionInGet = login.items.Version?.components(separatedBy: ".") // 2.0.0 -> Version in petition
                    let userVersionDevice = self.userVersion.components(separatedBy: ".") // 3.0.0 -> Version in device
                    
                    let firstGet = Int(versionInGet?[0] ?? "3")
                    let firstDevice = Int(userVersionDevice[0])
                    
                    let secondGet = Int(versionInGet?[1] ?? "0")
                    let secondDevice = Int(userVersionDevice[1])
                    
                    let thirdGet = Int(versionInGet?[2] ?? "0")
                    let thirdDevice = Int(userVersionDevice[2])
                    
                    // Compara el primero
                    if(firstGet! < firstDevice!){
                        
                        lastUpdate = true
                        
                    } else if (firstGet! == firstDevice!){
                        
                        // Compara el segundo
                        if( (secondGet ?? 0) < (secondDevice ?? 0) ){
                            
                            lastUpdate = true
                            
                        } else if((secondGet ?? 0) == (secondDevice ?? 0)){
                            
                            // Compara el tercero
                            if((thirdGet ?? 0) < (thirdDevice ?? 0)){
                                lastUpdate = true
                            } else if((thirdGet ?? 0) == (thirdDevice ?? 0)){
                                lastUpdate = true
                            } else {
                                lastUpdate = false
                            }
                            
                        } else {
                            
                            lastUpdate = false
                            
                        }
                        
                    } else {
                        
                        lastUpdate = false
                        
                    }
                    
                    if(!lastUpdate){
                        
                        
                        //** Options alert **//
                        let refreshAlert = UIAlertController(title: NSLocalizedString("update_title", comment: "update_title"), message: NSLocalizedString("update_body", comment: "update_body"), preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("update_AppStore_Button", comment: "update_AppStore_Button"), style: .default, handler: { (action: UIAlertAction!) in
                            guard let url = URL(string: "itms-apps://itunes.apple.com/us/app/resser-spot/id1054244668?l=es&ls=1&mt=8") else { return }
                            Analytics.logEvent("app_update", parameters: nil)
                            UIApplication.shared.openURL(url)
                            
                        }))
                        
                        self.present(refreshAlert, animated: true, completion: nil)

                    } else {
                        
                        if(login.success == true){
                            DispatchQueue.main.async {
                                // Check for "remeber me" option
                                
                                    // Set to the storage
                                    UserDefaults.standard.set(user, forKey: "user")
                                    UserDefaults.standard.set(pass, forKey: "pass")
                                    UserDefaults.standard.set(true, forKey: "rememberMe") // Always rememberMe
                                    UserDefaults.standard.synchronize()
                                
                            }
                            
                            // Device Id handled on previous request
                            let deviceId = UserDefaults.standard.string(forKey: "pushNotificationsDeviceId")
                            
                            if(deviceId != ""){
                                self.registerDeviceId()
                            }
                            
                            DispatchQueue.main.async {
                                self.loadIndicator.stopAnimating()
                                self.loadIndicator.isHidden = true
                                Analytics.logEvent("login", parameters: nil)
                                // Go to map
                                self.performSegue(withIdentifier: "toMap", sender: self)
                            }
                            
                        }
                        
                    }
                    
                    
                } catch {

                    self.onError() // Invalid credentials
                    
                }
            }
            }.resume()
        
    }
    
    func registerDeviceId(){
        
        let user = UserDefaults.standard.string(forKey: "user") ?? ""
        let pass = UserDefaults.standard.string(forKey: "pass") ?? ""
        let deviceId = UserDefaults.standard.string(forKey: "pushNotificationsDeviceId") ?? ""
        
        if CheckInternet.Connection(){
            
            let dictonarySub = [
                "Id":       1,
                "idPushDeviceId": 0,
                "Key":      deviceId,
                "Os":       2,
                "Active":   true
            ] as [String : Any]
            
            
            
            let url = "https://rastreo.resser.com/api/PushNotification"
            let URL: Foundation.URL = Foundation.URL(string: url)!
            let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
            request.httpMethod = "POST"
            
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
                    print("====ERROR IN POST REGISTER DEVICE====")
                    print(error ?? "NOT ERROR IN POST REGISTER DEVICE")
                    self.Alert(Title: NSLocalizedString("error_on_petition_title", comment: "error_on_petition_title"), Message: NSLocalizedString("error_on_petition_message", comment: "error_on_petition_message") + "\(String(describing: error))")
                    
                } else {
                    
                    print("====RESPONSE IN POST REGISTER DEVICE====")
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8)! as String
                    
                    print(outputStr)
                    
                    if let data = data, let stringResponse = String(data: data, encoding: .utf8) {
                        print("Response VALID \(stringResponse)")
                    }
                    
                }
                
            }
            dataTask.resume()
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    // Present invalid credentials
    func onError(){
        DispatchQueue.main.async {
            self.Alert(Title: "Error", Message: NSLocalizedString("login_error_message", comment: "login_error_message"))
            self.loadIndicator.stopAnimating()
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
