//
//  LoginViewController.swift
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
    
    
}
