//
//  Underline.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit

//**  Green underlined  **//

extension UITextField {
    func underlinedGreen(){
        let border = CALayer()
        let width = CGFloat(1.0)
        let color = UIColor(named: "spotGreen")?.cgColor
        border.borderColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func underlinedGray(){
        let border = CALayer()
        let width = CGFloat(1.0)
        let color = UIColor(named: "grayBackground")?.cgColor
        border.borderColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


extension UILabel {
    func underlinedGray(){
        let border = CALayer()
        let width = CGFloat(1.0)
        let color = UIColor(named: "grayBackground")?.cgColor
        border.borderColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func underlinedGreen(){
        let border = CALayer()
        let width = CGFloat(1.0)
        let color = UIColor(named: "spotGreen")?.cgColor
        border.borderColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension UIButton {
    func underlinedGreen(){
        let border = CALayer()
        let width = CGFloat(1.0)
        let color = UIColor(named: "spotGreen")?.cgColor
        border.borderColor = color
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func underlinedQuit(){
        
    }
}
