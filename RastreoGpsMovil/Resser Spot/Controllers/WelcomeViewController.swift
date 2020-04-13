//
//  launcherViewController.swift
//  RastreoGpsMovil
//
//  Created by Rolando Sumoza Rivas on 11/03/20.
//  Copyright © 2019 Rolando. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation
import SafariServices

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageText: NSArray!
    var pageImages: NSArray!
    
    var player: AVPlayer?
    var firstTime: Bool!
    
    // Outlets
    @IBOutlet weak var contractButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Set Texts        
        contractButton.setTitle(NSLocalizedString("Contrata_Button", comment: "Contrata_Button"), for: .normal)
        loginButton.setTitle(NSLocalizedString("Login_Button", comment: "Login_Button"), for: .normal)
        
        //MARK: Load the video from the app bundle.
        let videoURL: URL = Bundle.main.url(forResource: "background", withExtension: "mov")!
        player = AVPlayer(url: videoURL)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        
        player?.play()
        
        let langStr: String = Locale.current.languageCode!
        
        //MARK: loop video
        NotificationCenter.default.addObserver(self, selector: #selector(WelcomeViewController.loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        /*
         * PageTitles: it's a array and contain the titles for the slider.
         * pageText: it's a array and contain the info for the slider.
         Notes:
         NSLocalizedString its used to change the lenguage for the app, to see te text check (Localizabe.strings),
         the only lenguages supported are English and Spanish.
         */
        self.pageTitles = NSArray(objects: NSLocalizedString("Tittle_info_one", comment: "Tittle_info_one"),
                                  NSLocalizedString("Tittle_info_two", comment:"Tittle_info_two"),
                                  NSLocalizedString("Tittle_info_trhee", comment: "Tittle_info_trhee"))
        
        self.pageText = NSArray(objects: NSLocalizedString("Contrata_info_one", comment: "Contrata_info_one"),
                                NSLocalizedString("Contrata_info_two", comment: "Contrata_info_dos"),
                                NSLocalizedString("Contrata_info_three", comment: "Contrata_info_tres"))
        
        //MARK: the chat balloons are images because the app is English and Spanish, this "if" checks the language of the phone and creates an arrangement with the corresponding images
        
        if(langStr == "en"){
            self.pageImages = NSArray(objects: "chatE2","chatE1","chatE3")
            
        }else{
            self.pageImages = NSArray(objects: "chat1","chat2","chat3")
            
        }
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(index: 0) as ContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height - 80)
        
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //MARK: Function to send the info from the arrays to "ContentViewController".
    func viewControllerAtIndex( index: Int) -> ContentViewController {
        if (self.pageTitles.count == 0 || (index >= self.pageTitles.count)){
            return ContentViewController()
        }
        
        if (self.pageText.count == 0 || (index >= self.pageText.count)){
            
            return ContentViewController()
        }
        
        let VC: ContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        VC.imageFile = self.pageImages[index] as! String
        VC.titleText = self.pageTitles[index] as! String
        VC.contentText = self.pageText[index] as! String
        VC.pageIndex = index
        
        return VC
        
    }
    
    /*
     ** Returns the view controller before the given view controller.
     ** Return Value: The view controller before the given view controller, or nil to indicate that there is no previous view controller.
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let VC = viewController as! ContentViewController
        var index = VC.pageIndex as Int
        if( index == 0 || index == NSNotFound ){
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }
    
    /*
     ** Returns the view controller after the given view controller.
     ** Return Value: The view controller after the given view controller, or nil to indicate that there is no next view controller.
     */
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let VC = viewController as! ContentViewController
        var index = VC.pageIndex as Int
        
        if(index == NSNotFound){
            return nil
        }
        
        index += 1
        
        if(index == self.pageTitles.count){
            return nil
        }
        
        if(index == self.pageText.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    //MARK: Function to know how many sections to add for the slider.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    //MARK: Function to set the slider in index 0.
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    //MARK: Function to make the loop for the video.
    @objc func loopVideo() {
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    //Mark: Button to send the user to web page.
    @IBAction func Contract(_ sender: Any) {
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(url: NSURL(string: "https://spot.resser.com/tienda")! as URL)
            self.present(safariVC, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: "https://spot.resser.com/tienda")!)
        }
    }
    
    //MARK: Button to perform segue to login.
    @IBAction func Login(_ sender: Any) {
        UserDefaults.standard.set(false, forKey:"ShowSlider")
        self.performSegue(withIdentifier: "toLogin", sender: self)
        
    }
    
}
