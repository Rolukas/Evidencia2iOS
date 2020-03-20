//
//  ContentViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2016 Martin Duran anguiano. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ContentViewController: UIViewController {
    
    
    @IBOutlet var imagenChange: UIImageView!
    @IBOutlet var Titulo: UILabel!
    @IBOutlet var Description: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var contentText: String!
    var imageFile: String!
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Set the image, title and description, this data came from "WelcomeViewController".
        self.imagenChange.image = UIImage(named: self.imageFile)
        self.Titulo.text = self.titleText
        self.Description.text = self.contentText
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
