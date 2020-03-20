//
//  MenuViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 5/2/19.
//  Copyright © 2019 Rolando. All rights reserved.
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
    
   
}
