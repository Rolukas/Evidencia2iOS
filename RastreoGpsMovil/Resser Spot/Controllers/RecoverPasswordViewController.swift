//
//  RecoverPasswordViewController.swift
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
    
    
}
