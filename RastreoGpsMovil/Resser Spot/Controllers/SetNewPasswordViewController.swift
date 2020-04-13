//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//
//
//import UIKit
//
//class SetNewPasswordViewController: UIViewController, UITextFieldDelegate {
//
//
//    //** Principal view **//
//
//    @IBOutlet weak var TittleViewLabel: UILabel!
//    @IBOutlet weak var UserEmailTextField: UITextField!
//    @IBOutlet weak var NewPassTextField: UITextField!
//    @IBOutlet weak var RepeatNewPassTextField: UITextField!
//    @IBOutlet weak var ChangePassButton: UIButton!
//    @IBOutlet weak var ErrorLabel: UILabel!
//    @IBOutlet weak var LoadActivate: UIActivityIndicatorView!
//
//    //** Success view **//
//    @IBOutlet weak var CenterPopupSuccess: NSLayoutConstraint!
//    @IBOutlet weak var SuccessLabel: UILabel!
//
//    //** User Info **//
//    var userMail: String = ""
//    var newPassword: String = ""
//    var confirmPassword: String = ""
//    var samePasswords: Bool = false
//    var passDecode: String = ""
//    var urlUser: String? = ""
//    var statusLink: Int?
//
//    var recoreMyPass: recoverPassword = recoverPassword()
//    var recoverPass: recoverPassword!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //** Set up for view **//
//        TittleViewLabel.text = NSLocalizedString("set_New_Password_Label_Tittle_View", comment: "set_New_Password_Label_Tittle_View")
//
//        UserEmailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("set_New_Password_Label_Mail_Placeholder", comment: "set_New_Password_Label_Mail_Placeholder"), attributes:[NSForegroundColorAttributeName: UIColor.white])
//
//        NewPassTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("set_New_Password_Label_Pass_Placeholder", comment: "set_New_Password_Label_Pass_Placeholder"), attributes:[NSForegroundColorAttributeName: UIColor.white])
//
//        RepeatNewPassTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("set_New_Password_Label_Confirmpass_Placeholder", comment: "set_New_Password_Label_Confirmpass_Placeholder") , attributes:[NSForegroundColorAttributeName: UIColor.white])
//
//        ChangePassButton.setTitle(NSLocalizedString("set_New_Password_Button_Change", comment: "set_New_Password_Button_Change"), for: .normal)
//
//        ErrorLabel.alpha = 0
//
//
//        //MARK: Show and Hide keyboard observer
//        NotificationCenter.default.addObserver(self, selector: #selector(SetNewPasswordViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(SetNewPasswordViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//
//        //MARK: Check link status
//
//        //MARK: I block the inputs because i need to check if the link it's avaliable.
//        self.UserEmailTextField.isEnabled = false
//        self.NewPassTextField.isEnabled = false
//        self.RepeatNewPassTextField.isEnabled = false
//
//        //MARK: I save the link from the user (i make the link from AppDelegate).
//        urlUser = UserDefaults.standard.string(forKey:"statusGet")
//
//        //MARK: Get to know link status
//        recoverPass = recoreMyPass.getStatusUrl(urlUser!)
//
//        //MARK: Status 2: Avaliable to change password
//        if (recoverPass.myMailCheck[0].Items == "Se puede restablecer la contraseña" && recoverPass.myMailCheck[0].Value == 2) {
//            statusLink = 2
//        }
//
//            //MARK: Status 1: The link its unavaliable
//        else if(recoverPass.myMailCheck[0].Items == "El tiempo para restablecer contraseña expiro." && recoverPass.myMailCheck[0].Value == 1){
//            statusLink = 1
//        }
//
//            //MARK: Status 0: The link was deleted
//        else if(recoverPass.myMailCheck[0].Items == "No se a solicitado un restablecimiento de contraseña" && recoverPass.myMailCheck[0].Value == 0){
//            statusLink = 0
//
//        }
//
//        //MARK: I wait 2 seconds for the view to load
//        let when = DispatchTime.now() + 2
//        DispatchQueue.main.asyncAfter(deadline: when) {
//
//            //MARK: If the status its 0: The link it was deleted and send the user to the login view
//            if(self.statusLink == 0) {
//
//                let info = UIAlertController(title: NSLocalizedString("set_New_Password_Message_Alert_Link_Delete_Title", comment: "set_New_Password_Message_Alert_Link_Delete_Title"),
//                                             message: NSLocalizedString("set_New_Password_Message_Alert_Link_Delete_Message", comment: "set_New_Password_Message_Alert_Link_Delete_Message"),
//                                             preferredStyle: .alert)
//
//                self.present(info, animated: true, completion: nil)
//                let when = DispatchTime.now() + 2
//                DispatchQueue.main.asyncAfter(deadline: when){
//                    info.dismiss(animated: true, completion: nil)
//                    self.performSegue(withIdentifier: "returnLogin", sender: nil)
//                }
//            }
//
//                //MARK: If the status it's 1: The link it was unavaliable and send the user to apply for annother link view
//            else if (self.statusLink == 1) {
//
//                let info = UIAlertController(title: NSLocalizedString("set_New_Password_Message_Alert_Link_Expire_Title", comment: "set_New_Password_Message_Alert_Link_Expire_Title"),
//                                             message:NSLocalizedString("set_New_Password_Message_Alert_Link_Expire_Message", comment: "set_New_Password_Message_Alert_Link_Expire_Message"),
//                                             preferredStyle: .alert)
//
//                self.present(info, animated: true, completion: nil)
//                let when = DispatchTime.now() + 2
//                DispatchQueue.main.asyncAfter(deadline: when){
//                    info.dismiss(animated: true, completion: nil)
//                    self.performSegue(withIdentifier: "returnLogin", sender: nil)
//                }
//
//
//
//            }
//
//                //MARK: If the status it's 2: The link it's avaliable and unlock the inputs for the user
//            else if( self.statusLink == 2 ) {
//
//                self.UserEmailTextField.isEnabled = true
//                self.NewPassTextField.isEnabled = true
//                self.RepeatNewPassTextField.isEnabled = true
//
//                let info = UIAlertController(title: NSLocalizedString("set_New_Password_Message_Alert_Link_Avaliable_Title", comment: "set_New_Password_Message_Alert_Link_Avaliable_Title"),
//                                             message: NSLocalizedString("set_New_Password_Message_Alert_Link_Avaliable_Message", comment: "set_New_Password_Message_Alert_Link_Avaliable_Message"),
//                                             preferredStyle: .alert)
//
//                self.present(info, animated: true, completion: nil)
//                let when = DispatchTime.now() + 2
//                DispatchQueue.main.asyncAfter(deadline: when){
//                    info.dismiss(animated: true, completion: nil)
//                }
//
//            }
//
//        }
//    }
//
//    //MARK: This function add the size of the keyboard
//    func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//
//    //MARK: This function remove the size of the keyboard
//    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
//    }
//
//    //MARK: Function that detects when the user start to edit some textfield
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//    }
//
//    //MARK: Function that detects when the user press the key buton (next, accept..etc).
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//
//        switch textField.tag {
//        case 0:
//
//            if (UserEmailTextField.text != "") {
//
//                userMail = UserEmailTextField.text!
//                NewPassTextField.becomeFirstResponder()
//
//            } else {
//
//                textField.resignFirstResponder()
//
//            }
//
//            break
//
//        case 1:
//
//            if (NewPassTextField.text != "") {
//
//                newPassword = NewPassTextField.text!
//                RepeatNewPassTextField.becomeFirstResponder()
//
//            } else {
//
//                textField.resignFirstResponder()
//
//            }
//
//            break
//
//        case 2:
//
//            if (RepeatNewPassTextField.text != "") {
//
//                confirmPassword = RepeatNewPassTextField.text!
//                textField.resignFirstResponder()
//            } else {
//
//                textField.resignFirstResponder()
//
//            }
//
//            break
//        default:
//            break
//        }
//        return true
//    }
//
//    //MARK: Function to validate the email
//    func isValidEmail(testStr: String) -> Bool {
//
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//
//        return emailTest.evaluate(with: testStr)
//    }
//
//    //MARK: Function to set the new pass
//    @IBAction func changeNewPass(_ sender: Any) {
//        LoadActivate.startAnimating()
//
//        userMail = UserEmailTextField.text!
//        newPassword = NewPassTextField.text!
//        print(newPassword)
//        confirmPassword = RepeatNewPassTextField.text!
//
//        //MARK: algun compo esta vacio
//        if(userMail == "" || newPassword == "" || confirmPassword == "") {
//            //MARK:Error campos vacios
//            LoadActivate.stopAnimating()
//            ErrorLabel.text = NSLocalizedString("set_New_Password_Error_Label_Blanck_Message", comment: "set_New_Password_Error_Label_Blanck_Message")
//
//            UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                self.ErrorLabel.alpha = 1
//            })
//
//            let when = DispatchTime.now() + 2
//            DispatchQueue.main.asyncAfter(deadline: when) {
//
//                UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                    self.ErrorLabel.alpha = 0
//                })
//            }
//
//
//        } else {
//
//            //MARK: check Email
//            let emailValid = isValidEmail(testStr: userMail)
//
//            if (emailValid == true ){
//                //MARK: Check Passwords
//                if(newPassword == confirmPassword) {
//
//                    passDecode = xorWithKey(newPassword, key: "platano")
//                    print(passDecode)
//                    //MARK: Send info
//                    let diccionario = [
//                        "email" : userMail,
//                        "password" : passDecode,
//                        "mobile" : true
//                        ] as [String : Any]
//
//                    userMail = ""
//                    passDecode = ""
//
//                    recoverPass = recoreMyPass.putNewPass(diccionario, callback: self.putRecoverMyPassCallback)
//
//                }else {
//                    //MARK: Error passwords
//                    LoadActivate.stopAnimating()
//                    ErrorLabel.text = NSLocalizedString("set_New_Password_Error_Match_Message", comment: "set_New_Password_Error_Match_Message")
//
//                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                        self.ErrorLabel.alpha = 1
//                    })
//
//                    let when = DispatchTime.now() + 2
//                    DispatchQueue.main.asyncAfter(deadline: when) {
//
//                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                            self.ErrorLabel.alpha = 0
//                        })
//                    }
//
//                }
//            }else {
//                //MARK: Error mail
//                LoadActivate.stopAnimating()
//                ErrorLabel.text = NSLocalizedString("set_New_Password_Error_Invalid_Email_Message", comment: "set_New_Password_Error_Invalid_Email_Message")
//
//                UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                    self.ErrorLabel.alpha = 1
//                })
//
//                let when = DispatchTime.now() + 2
//                DispatchQueue.main.asyncAfter(deadline: when) {
//
//                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                        self.ErrorLabel.alpha = 0
//                    })
//                }
//            }
//        }
//    }
//
//    //MARK: Function to return to the loginView
//    @IBAction func CancelUpadatePass(_ sender: Any) {
//
//        self.performSegue(withIdentifier: "returnLogin", sender: nil)
//
//    }
//
//    //MARK: Function to create alerts with dismiss
//    func ShowAlert(_ title: String, message: String, dismiss: String) {
//        let alertController = UIAlertController(title: title, message:
//            message, preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: dismiss, style: UIAlertActionStyle.default,handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    //MARK: Function to make xor the password
//    func xorWithKey(_ password: String, key: String) -> String {
//
//        //** Convert **//
//        let paswordByte: [UInt8] = Array(password.utf8)
//        let keyByte: [UInt8] = Array(key.utf8)
//        var out: [UInt8] = paswordByte
//        out.removeAll()
//        var i: Int = 0
//
//        //** Xor byte to byte **//
//        while i < paswordByte.count {
//            out.append(UInt8(paswordByte[i] ^ keyByte[i%keyByte.count]))
//            i = i + 1
//        }
//
//        //** Convert byte to String **//
//        let characters = out.map { Character(UnicodeScalar($0)) }
//        let result = String(Array(characters))
//
//        //** String to Base 64 **//
//        let data = (result).data(using: String.Encoding.utf8)
//        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//
//        return base64
//    }
//
//    //MARK:
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    //*************************** Callbacks **********************************//
//
//    //MARK: Callbalck from PUT new password
//    func putRecoverMyPassCallback(_ bodyData: JSON, response: URLResponse) -> Bool {
//
//        let respuesta = recoverPass.putNewPassCallback(bodyData, response: response)
//        LoadActivate.stopAnimating()
//
//        //MARK: Todo terminar de agregar cuando se haga y cuando no. agregar en el modelo cuando e succes sea falso porque truena si no hago eso
//        if (respuesta == true) {
//
//            let info = UIAlertController(title: NSLocalizedString("set_New_Password_Message_Alert_Succes_Title", comment: "set_New_Password_Message_Alert_Succes_Title") ,
//                                         message: NSLocalizedString("set_New_Password_Message_Alert_Succes_Message", comment: "set_New_Password_Message_Alert_Succes_Message") ,
//                                         preferredStyle: .alert)
//
//            self.present(info, animated: true, completion: nil)
//            let when = DispatchTime.now() + 2
//            DispatchQueue.main.asyncAfter(deadline: when){
//                info.dismiss(animated: true, completion: nil)
//                self.performSegue(withIdentifier: "returnLogin", sender: nil)
//            }
//
//        } else {
//
//            let info = UIAlertController(title: NSLocalizedString("set_New_Password_Message_Alert_Error_Title", comment: "set_New_Password_Message_Alert_Error_Title") ,
//                                         message: NSLocalizedString("set_New_Password_Message_Alert_Error_Message", comment: "set_New_Password_Message_Alert_Error_Message"),
//                                         preferredStyle: .alert)
//
//            self.present(info, animated: true, completion: nil)
//            let when = DispatchTime.now() + 2
//            DispatchQueue.main.asyncAfter(deadline: when){
//                info.dismiss(animated: true, completion: nil)
//                self.performSegue(withIdentifier: "returnLogin", sender: nil)
//            }
//
//        }
//
//        return true
//    }
//
//
//}
