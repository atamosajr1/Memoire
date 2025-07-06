//
//  ThankViewController.swift
//  EventVideo
//
//  Created by JayR Atamosa on 1/2/25.
//

import UIKit

class ThankViewController: UIViewController {
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var vwGradient: UIView!
    @IBOutlet var imgBackground: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblButtonTitle: UILabel!
    @IBOutlet var btnMessage: UIButton!
    let appConfig = AppConfig.shared
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var count = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            count -= 1
            
            if count == 0 {
                self.stopTimer()
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let settings = appConfig.settings {
            lblMessage.text = settings.thanksScreenMessage
            if settings.thanksScreenWallpaperURL.count > 0 {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let adminFolderURL = documentDirectory.appendingPathComponent("admin", isDirectory: true)
                print("welcomeScreenWallpaperURL :\(settings.thanksScreenWallpaperURL)")
                
                let url = adminFolderURL.appendingPathComponent(settings.thanksScreenWallpaperURL)
                if FileManager.default.fileExists(atPath: url.path) {
                    do {
                        
                        let imageData = try Data(contentsOf: url)
                        imgBackground.image = UIImage(data: imageData)
                        print("Image loaded successfully.")
                    } catch {
                        print("Failed to load image data: \(error.localizedDescription)")
                    }
                }
                
            }
            lblTitle.text = settings.thanksScreenTitle
            lblButtonTitle.text = settings.thanksScreenButtonTitle
            lblMessage.font = settings.thanksScreenMessageFont
            lblTitle.font = settings.thanksScreenTitleFont
            lblButtonTitle.font = settings.thanksScreenButtonTitleFont
            vwGradient.backgroundColor = UIColor.fromRGBString(settings.overAllGradientColor)
            vwGradient.alpha = settings.thanksScreenGradient
            lblButtonTitle.textColor = UIColor.fromRGBString(settings.overAllButtonTextColor)
            
            var configMessage = UIButton.Configuration.filled()
            configMessage.baseBackgroundColor = UIColor.fromRGBString(settings.overAllButtonBackgroundColor)
            btnMessage.configuration = configMessage
            btnMessage.layer.cornerRadius = 40
            btnMessage.clipsToBounds = true
        }
    }
    
    func stopTimer() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func done(_sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

