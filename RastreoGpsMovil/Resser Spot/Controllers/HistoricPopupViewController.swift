//
//  HistoricPopupViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza on 5/17/19.
//  Copyright © 2019 Resser. All rights reserved.
//

import UIKit

class HistoricPopupViewController: UIViewController {
    
    var histType = HistoricViewController() // variable to handle HistoricFunctions
    var StringDate = String() // String in "01-12-2019" format
    
    var year = String()
    var month = String()
    var day = String()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        datePicker.addTarget(self, action: #selector(HistoricPopupViewController.pickerChanged), for: .valueChanged)
    }
    
    //** Value changed in picker ONE **//
    @objc func pickerChanged(sender: UIDatePicker){
        
        
        //** Format of value **//
        let formater = DateFormatter()
        formater.dateFormat = "dd-MM-yyyy"
        
        // String in "01-12-2019" format
        StringDate = formater.string(from: sender.date)
        
        
        let dateSeparated = StringDate.components(separatedBy: "-")
        year = dateSeparated[2]
        month = dateSeparated[1]
        day = dateSeparated[0]
                
        // Save the Date selected
        print(StringDate)
    }
    
    @IBAction func onSaveDate(_ sender: Any) {
        dismiss(animated: true)
        histType.GetHistorics(dayC: day, monthC: month, yearC: year)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
