//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//
import UIKit
import Firebase

class RecoverPasswordViewController: UIViewController {
    
    //Structs
    struct Response: Codable{
        var success: Bool
        var items: String
        var value: Int
    }
    
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    
    @IBOutlet weak var tittleViewLabel: UILabel!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mailLabel: UITextField!
    @IBOutlet weak var recoverPassButton: UIButton!
    @IBOutlet weak var loadActiviti: UIActivityIndicatorView!
    
    @IBOutlet weak var centerPopupError: NSLayoutConstraint!
    @IBOutlet weak var centerPopupSuccess: NSLayoutConstraint!
    
    var mail: String!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        //** Config buttons an texts **//
        self.tittleViewLabel.text = NSLocalizedString("recover_Password_Tittle", comment: "recover_Password_Tittle")
        
        self.tittleLabel.text = NSLocalizedString("recover_Password_Tittle_Label", comment: "recover_Password_Tittle_Label")
        
        self.bodyLabel.text = NSLocalizedString("recover_Password_Body_Label", comment: "recover_Password_Tittle_Label")
        
        self.mailLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("recover_Password_Placeholder",comment: "recover_Password_Placeholder"),attributes:[NSAttributedString.Key.foregroundColor:UIColor.white])
        
        self.recoverPassButton.setTitle(NSLocalizedString("recover_Password_Button_text", comment: "recover_Password_Button_text"), for: .normal)
        
        Analytics.logEvent("function_recover_pass", parameters: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecoverPasswordViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RecoverPasswordViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    
    
    
    @IBAction func RecoverPassButton(_ sender: Any) {
        self.loadActiviti.startAnimating()
        mail = mailLabel.text
        
        if (mail == ""){
            
            self.loadActiviti.stopAnimating()
            self.ShowAlert( NSLocalizedString("recover_Password_Error_ValidMail_Tittle", comment: "recover_Password_Error_ValidMail_Tittle"), message: NSLocalizedString("recover_Password_Error_ValidMail_Message", comment: "recover_Password_Error_ValidMail_Message"),
                            dismiss: NSLocalizedString("recover_Password_Error_ValidMail_Button", comment: "recover_Password_Error_ValidMail_Button"))
        } else {
            
            getToRecoverPassword()
            
        }
    }
    
    func getToRecoverPassword(){
        // Check internet connection
        if CheckInternet.Connection(){
            
            // Get the vehicles info
            let url : NSString  = "https://rastreo.resser.com/api/restoreaccountspot?email=\(mailLabel.text ?? "")" as NSString
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
                        let responseInfo = try JSONDecoder().decode(Response.self, from: data)
                        DispatchQueue.main.async {
                            if(responseInfo.items == "No se encontro una cuenta asociada al correo proporcionado."){
                                
                                self.loadActiviti.stopAnimating()
                                self.centerPopupError.constant = 0
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.view.layoutIfNeeded()
                                })
                                
                                let when = DispatchTime.now() + 2
                                DispatchQueue.main.asyncAfter(deadline: when) {
                                    
                                    self.centerPopupError.constant = 550
                                    UIView.animate(withDuration: 0.3, animations:{
                                        self.view.layoutIfNeeded()
                                    })
                                }
                                
                            } else {
                                
                                self.loadActiviti.stopAnimating()
                                //Mark: Animacion de view
                                self.centerPopupSuccess.constant = 0
                                UIView.animate(withDuration: 0.3, animations:{
                                    self.view.layoutIfNeeded()
                                })
                                
                                let when = DispatchTime.now() + 2
                                DispatchQueue.main.asyncAfter(deadline: when) {
                                    
                                    self.centerPopupSuccess.constant = -550
                                    UIView.animate(withDuration: 0.3, animations:{
                                        self.view.layoutIfNeeded()
                                    })
                                }
                                
                            }
                        }
                        // Error on get
                    } catch {
                        
                        print("Error on Valet Popup: ")
                        print(error)
                        
                    }
                }
                
                }.resume()
            
            // No internet connection
        } else {
            
            self.Alert(Title: "Error" ,Message: NSLocalizedString("login_noInternet_alert", comment: "login_noInternet_alert"))
            
        }
    }
    
    //** End edit **//
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (mailLabel.text != "" ) {
            
            mail = mailLabel.text
            let check = isValidEmail(testStr: mail)
            
            if (check == true) {
                
                mailLabel.resignFirstResponder()
                
            } else {
                
                self.ShowAlert( NSLocalizedString("recover_Password_Error_ValidMail_Tittle", comment: "recover_Password_Error_ValidMail_Tittle"), message: NSLocalizedString("recover_Password_Error_ValidMail_Message", comment: "recover_Password_Error_ValidMail_Message"),
                                dismiss: NSLocalizedString("recover_Password_Error_ValidMail_Button", comment: "recover_Password_Error_ValidMail_Button"))
                
                mailLabel.text = ""
            }
        }
        return true
    }
    
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: testStr)
    }
    
    func ShowAlert(_ title: String, message: String, dismiss: String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: title, message:
                message, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: dismiss, style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
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
