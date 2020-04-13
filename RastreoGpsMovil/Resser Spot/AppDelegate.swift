//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//

import UIKit
import WatchConnectivity
import UserNotifications
import Foundation
import AppCenter
import AppCenterAnalytics
import PushKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    
    var window: UIWindow?
    var PushNotificationToken : String = ""
    let VehicleSelectedOnWatch = "VehicleSelectedOnWatch"
    let notificationDataHandler: String = ""
    
    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(UserDefaults.standard.string(forKey: "pushNotificationsDeviceId") ?? "")
        if(UserDefaults.standard.string(forKey: "pushNotificationsDeviceId") != ""){
            registerForRemoteNotification(application: application)
        }
        
        // Firebase
        FirebaseApp.configure()
        
//        setupWatchConnectivity()
        return true
    }
    
    //***************************************************************************************************************** Push Notifications

    //MARK: Function to config the Push notifications
    func registerForRemoteNotification(application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                
                if(granted){
                    print("granted")
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                } else {
                    
                    print("not granted")
                    print(granted)
                    
                    UserDefaults.standard.set("", forKey: "pushNotificationsDeviceId")
                    UserDefaults.standard.synchronize()
                }
                
                if((error) != nil){
                    print("Error registerForRemoteNotification")
                    print(error)
                }
                    

            }
        } else {
            
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings( types:[.sound, .alert, .badge], categories: nil ))
            UIApplication.shared.registerForRemoteNotifications()
            
        }
    }
    
    //MARK: Create the token for push notifications.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //Convert Token to String
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //Print it to console
        let pushNotificationsDeviceId = deviceTokenString
        print("APNs device token: \(pushNotificationsDeviceId)")
        
        UserDefaults.standard.set(pushNotificationsDeviceId, forKey: "pushNotificationsDeviceId")
        UserDefaults.standard.synchronize()
        
        PushNotificationToken = deviceTokenString
    }
    
    //MARK: Error registration failed
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    

    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // tell the app that we have finished processing the user’s action / response
        do {
           
            let notificationBody = response.notification.request.content.body
            // Ej. RESSER BLANCO-2012-57039,ignición prendido 9:08pm,av volcan del colli 1129
            let notificationSeparated = notificationBody.split(separator: ",")
            
            let notificationVehicleData = notificationSeparated[0] // Info of current vehicle Ej. RESSER BLANCO-2012-57039
            let notificationNotificationTypeData = notificationSeparated[1] // Info of notification Ej. ignición prendido 9:08pm
            let notificationVehicleId = notificationVehicleData.split(separator: "-") // vehicle id Ej. 19350
            let vehicleId = String(notificationVehicleId[2])
            print("VEHICLE ID \(vehicleId)")
            // Get the notification data
            let notificationNotificationTypeDataArray = notificationNotificationTypeData.split(separator: " ")
            
            var i: Int = 0
            var stringToMake: String = "" // Catch the string without hour (hour is in the last position)
            let numberOfComponentsInString = notificationNotificationTypeDataArray.count // How many components are in the string Ej. ignición prendido 9:08pm = 3 components [ignición,prendido,9:08pm]
            
            // Get notification type info without hour
            for string in notificationNotificationTypeDataArray{
                if(i < (numberOfComponentsInString - 1) ){
                    if(i == (numberOfComponentsInString - 2) ){
                        stringToMake += "\(string)" // With whitespace
                    } else {
                        stringToMake += "\(string) " // Without whitespace
                    }
                }
                
                i += 1
            }
            
            // Without special characters
            let stringWithoutSpecialCharacters = stringToMake.folding(options: .diacriticInsensitive, locale: .current)
            // Uppercased
            let stringToIdentify = stringWithoutSpecialCharacters.uppercased()
            
            // Identify case
            if(stringToIdentify != "ALERTA ACTIVADA" && stringToIdentify != "ALERTA PENDIENTE"){
                NotificationInfo.vehicleId = Int(vehicleId) ?? 0
                window?.rootViewController = MapViewController.instantiate()
            }
            
            
            //** Response actions (Rich push notifications) **//
            if response.actionIdentifier == "cabin" {
                "(33)-2300-6904".makeAColl()
            }
            
            if response.actionIdentifier == "desactivate" {
                desactivateGuardMode(id: vehicleId)
            }
            
        } catch {
            print("error \(error)")
        }
        
       
        
        completionHandler()
    }
    
    // When the user pressed "Desactivate" option on guard mode push notification
    func desactivateGuardMode(id: String){
        
        let user: String = UserDefaults.standard.string(forKey: "user") ?? ""
        let pass: String = UserDefaults.standard.string(forKey: "pass") ?? ""

        let dictionarySub = [
            "vehicleId": Int(id) ?? 0
        ] as [String : Any]
        
        
        let url = "https://rastreo.resser.com/api/GuardianAlertMobile"
        let URL: Foundation.URL = Foundation.URL(string: url)!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:URL)
        request.httpMethod = "PUT"
        
        let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionarySub,
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
                print("==== desactivateGuardMode ERROR====")
                print(error ?? "LOL")
                
            } else {
                
               
            }
            
        }
        dataTask.resume()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notifiación recibida")
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    //***************************************************************************************************************** Push Notifications
    
    
    
    //***************************************************************************************************************** Restore Account
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let urlString = url.absoluteString
        var urlArr = urlString.components(separatedBy: "?")
        
        let urlGet = ("https://rastreo.resser.com/api/restoreaccountspot?" + urlArr[1] + "&i=0")
        
        UserDefaults.standard.set(urlGet, forKey: "statusGet")
        UserDefaults.standard.synchronize()
        
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "restore") as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
        
        return true
    }
    //***************************************************************************************************************** Restore Account
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.set(false, forKey: "bActive")
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UserDefaults.standard.set(true, forKey: "bActive")
        UserDefaults.standard.synchronize()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //Esta funcione se activa cuando se termina el proceso de la app.
        UserDefaults.standard.set(true, forKey: "ShowSlider")
        UserDefaults.standard.set(false, forKey: "loginSucces")
        UserDefaults.standard.set(false, forKey: "recuerdame")
        UserDefaults.standard.synchronize()
    }
    
    //**********************************************************************************************Apple Watch
    func setupWatchConnectivity() {
//        print("SETUP")
//        if #available(iOS 9.0, *) {
//            if WCSession.isSupported() {
//                let session = WCSession.default
//                session.delegate = self as? WCSessionDelegate
//                session.activate()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
    }
    //**********************************************************************************************
    
}


extension AppDelegate: WCSessionDelegate {
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @available(iOS 9.0, *)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    @available(iOS 9.0, *)
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    @available(iOS 9.0, *)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("SESSION")
        
        
        let user = UserDefaults.standard.string(forKey: "user")
        let password = UserDefaults.standard.string(forKey: "pass")
        let vehicleIdS = UserDefaults.standard.string(forKey: "VehicleId")
        let vehicleName = UserDefaults.standard.string(forKey: "VehicleName")
        print(message.values)
        
        var replyValues = Dictionary<String, AnyObject>()
        
        replyValues["user"] = user as AnyObject
        replyValues["password"] = password as AnyObject
        replyValues["vehicleIdS"] = vehicleIdS as AnyObject
        replyValues["vehicleName"] = vehicleName as AnyObject
        
        
        // Using the block to send back a message to the Watch
        replyHandler(replyValues)
    }
    
}











