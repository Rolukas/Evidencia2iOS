//
//  MenuViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/2/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit
import StoreKit
import Firebase

class MenuViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var vehicleNameLabel: UILabel!
    
    // Variables
    var user: String = UserDefaults.standard.string(forKey: "user") ?? ""
    var pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""
    @IBOutlet weak var constraintTopMenu: NSLayoutConstraint!
    
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
        let userDefs = UserDefaults.standard.integer(forKey: "timesMenuOpen")
        vehicleNameLabel.text = CurrentVehicleInfo.VehicleName
    
        print(userDefs)
        
        if( UserDefaults.standard.integer(forKey: "timesMenuOpen") == 20 ){
            
            DispatchQueue.main.async {
                let userDefs = UserDefaults.standard.integer(forKey: "timesMenuOpen")
                UserDefaults.standard.set( 0, forKey: "timesMenuOpen")
                UserDefaults.standard.synchronize()
                self.performSegue(withIdentifier: "onReview", sender: self)
            }

        } else {
            let userDefs = UserDefaults.standard.integer(forKey: "timesMenuOpen")
            UserDefaults.standard.set( (userDefs + 1), forKey: "timesMenuOpen")
            UserDefaults.standard.synchronize()
        }
        
        // This constraint allows the menu to expand on all the screen
        setMainConstraint()
        
        Analytics.logEvent("function_more", parameters: nil)
    }
    
    func setMainConstraint(){
        
        /*
            For real devices it returns e.g. "iPad Pro 9.7 Inch", for simulators it returns "Simulator " + Simulator identifier, e.g. "Simulator iPad Pro 9.7 Inch"
         */
        
        
        var device = String()
        
        if((UIDevice.modelName).contains("Simulator ")){
            device = (UIDevice.modelName).replacingOccurrences(of: "Simulator ", with: "")
        } else {
            device = UIDevice.modelName
        }
        
        //self.Alert(Title: "DEVICE", Message: "\(String(describing: UserDefaults.standard.string(forKey: "pushNotificationsDeviceId")))")
        //UIPasteboard.general.string = "\(String(describing: UserDefaults.standard.string(forKey: "pushNotificationsDeviceId")))"
        
        print(device)
        
        switch(device){
            case "iPhone 5", "iPhone 5s", "iPhone SE", "iPhone 5C", "iPhone 5c":
                let constant: CGFloat = -20.0
                constraintTopMenu.constant = constant
                break
            case "iPhone 6s", "iPhone 6":
                let constant: CGFloat = 10.0
                constraintTopMenu.constant = constant
                break
            case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus", "iPhone 8":
                let constant: CGFloat = 20.0
                constraintTopMenu.constant = constant
                break
            case "iPhone 8 Plus":
                let constant: CGFloat = 30.0
                constraintTopMenu.constant = constant
            case "iPhone X", "iPhone Xs", "iPhone Xs Max", "iPhone XS":
                let constant: CGFloat = 105.0
                constraintTopMenu.constant = constant
            case "iPhone XS Max":
                let constant: CGFloat = 145.0
                constraintTopMenu.constant = constant
            case "iPhone Xʀ", "iPhone Xr", "iPhone XR":
                let constant: CGFloat = 140.0
                constraintTopMenu.constant = constant
            default:
                break
        }

        print(constraintTopMenu.constant)
        
    }
    
    @IBAction func onMenuDismiss(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // Go to tickets module
    @IBAction func onTicketsTap(_ sender: Any) {
        
        if((CurrentVehicleInfo.LicensePlate.replacingOccurrences(of: " ", with: "")).isEmpty){
            
            let newAlert = UIAlertController(title: NSLocalizedString("menu_noPlates_title", comment: "menu_noPlates_title"), message: NSLocalizedString("menu_noPlates_message", comment: "menu_noPlates_message"), preferredStyle: UIAlertController.Style.alert)
  
            //** Go to My vehicle **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("menu_noPlates_Option1", comment: "menu_noPlates_Option1"), style: .default, handler: { (action: UIAlertAction!) in
                newAlert.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "toMyVehicle", sender: self)
            }))
            
            //** Cancel **//
            newAlert.addAction(UIAlertAction(title: NSLocalizedString("menu_noPlates_Option2", comment: "menu_noPlates_Option2"), style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            present(newAlert, animated: true, completion: nil)
            
        } else {
            performSegue(withIdentifier: "toTickets", sender: self)
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
