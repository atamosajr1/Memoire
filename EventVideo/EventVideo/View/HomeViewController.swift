//
//  ViewController.swift
//  EventVideo
//
//  Created by JayR Atamosa on 12/11/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let viewModel = HomeViewModel()
    @IBOutlet var homeScroll: UIScrollView!
    @IBOutlet var splitButton: UIButton!
    @IBOutlet var splitLabel: UILabel!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var lblTitleWidth: NSLayoutConstraint!
    @IBOutlet var lblMessageWidth: NSLayoutConstraint!
    @IBOutlet var lblEventDetailsWidth: NSLayoutConstraint!
    @IBOutlet var lblEventDetailsHeight: NSLayoutConstraint!
    @IBOutlet var vwGradientHeight: NSLayoutConstraint!
    @IBOutlet var mainContent: UIView!
    @IBOutlet var secondContent: UIView!
    let appConfig = AppConfig.shared
    
    @IBOutlet var lblTitle: AutoShrinkLabel!
    @IBOutlet var lblMessage: AutoShrinkLabel!
    @IBOutlet var lblEventDetails: AutoShrinkLabel!
    @IBOutlet var lblInstructions: AutoShrinkLabel!
    @IBOutlet var btnMessage: UIButton!
    @IBOutlet var btnMessageDisplay: UILabel!
    @IBOutlet var btnWhatShouldIsay: UIButton!
    @IBOutlet var lblQuestionTop: UILabel!
    @IBOutlet var lblQuestionBottom: UILabel!
    @IBOutlet var imgWallpaper: UIImageView!
    @IBOutlet var vwGradient: UIView!
    @IBOutlet var vwTopLeft: UIView!
    @IBOutlet var vwTopRight: UIView!
    @IBOutlet var imgArrow: UIImageView!
    
    private var leftTapCount = 0
    private var rightTapCount = 0
    private let requiredTaps = 3
    private let resetDelay: TimeInterval = 10.0  // Reset after 10 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupTapGesture()
        setupAdminTapGestures()
        
        // Observe changes in the ViewModel
        /*
        viewModel.onTapCountReached = { [weak self] in
            self?.showPasswordAlert()
        }
         */
        
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape
        }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reset tap counts only
        leftTapCount = 0
        rightTapCount = 0
        
        let leading = 0.0
        splitButton.isHidden = false
        splitLabel.isHidden = false
        leadingConstraint.constant = leading
        mainContent.layoutIfNeeded()
        homeScroll.setContentOffset(CGPoint(x: leading, y: 0), animated: true)
        
        appConfig.readSettingsFromAdminFolder()
        if let settings = appConfig.settings {
            lblTitle.text = settings.eventTitle
            lblMessage.text = settings.eventMessage
            lblEventDetails.text = settings.eventDetails
            lblInstructions.text = settings.welcomeInstruction
            
            if settings.welcomeScreenWallpaperURL.count > 0 {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let adminFolderURL = documentDirectory.appendingPathComponent("admin", isDirectory: true)
                print("welcomeScreenWallpaperURL :\(settings.welcomeScreenWallpaperURL)")
                
                let url = adminFolderURL.appendingPathComponent(settings.welcomeScreenWallpaperURL)
                if FileManager.default.fileExists(atPath: url.path) {
                    do {
                        
                        let imageData = try Data(contentsOf: url)
                        imgWallpaper.image = UIImage(data: imageData)
                        print("Image loaded successfully.")
                    } catch {
                        print("Failed to load image data: \(error.localizedDescription)")
                    }
                }
            } else {
                imgWallpaper.image = UIImage(named: "forest")
            }
            lblTitle.font = settings.eventTitleFont
            lblMessage.font = settings.eventMessageFont
            lblEventDetails.font = settings.eventDetailsFont
            lblInstructions.font = settings.welcomeInstructionFont
            splitLabel.text = settings.leaveMessageButtonText
            btnMessageDisplay.text = settings.leaveMessageButtonText
            lblQuestionTop.text = settings.questionButtonTopText
            lblQuestionBottom.text = settings.questionButtonBottomText
            splitLabel.font = settings.leaveMessageFont
            btnMessageDisplay.font = settings.leaveMessageFont
            lblQuestionTop.font = settings.questionButtonTopFont
            lblQuestionBottom.font = settings.questionButtonBottomFont
            secondContent.backgroundColor = UIColor.fromRGBString(settings.welcomeScreenBackgroundTheme)
            secondContent.isOpaque = false
            vwGradient.backgroundColor = UIColor.fromRGBString(settings.overAllGradientColor)
            vwGradient.alpha = settings.welcomeScreenGradient
            lblInstructions.textColor = UIColor.fromRGBString(settings.rightSideWelcomeTextColor)
            let templateImage = UIImage(named: "arrow_right")?.withRenderingMode(.alwaysTemplate)
            imgArrow.image = templateImage
            imgArrow.tintColor = UIColor.fromRGBString(settings.rightSideArrowColor)
            splitLabel.textColor = UIColor.fromRGBString(settings.overAllButtonTextColor)
            btnMessageDisplay.textColor = UIColor.fromRGBString(settings.overAllButtonTextColor)
            var config = UIButton.Configuration.filled()
                config.baseBackgroundColor = UIColor.fromRGBString(settings.whatShouldIsayBGColor)
            btnWhatShouldIsay.configuration = config
            btnWhatShouldIsay.layer.cornerRadius = 40
            btnWhatShouldIsay.clipsToBounds = true
            lblQuestionTop.textColor = UIColor.fromRGBString(settings.whatShouldIsayTextColor)
            lblQuestionBottom.textColor = UIColor.fromRGBString(settings.whatShouldIsayTextColor)
            var configSplit = UIButton.Configuration.filled()
            configSplit.baseBackgroundColor = UIColor.fromRGBString(settings.letsGetStartBGColor)
            splitButton.configuration = configSplit
            splitButton.layer.cornerRadius = 40
            splitButton.clipsToBounds = true
            var configMessage = UIButton.Configuration.filled()
            configMessage.baseBackgroundColor = UIColor.fromRGBString(settings.splitLetsGetStartBGColor)
            btnMessage.configuration = configMessage
            btnMessage.layer.cornerRadius = 40
            btnMessage.clipsToBounds = true
            lblInstructions.adjustsFontSizeToFitWidth = true
            lblInstructions.minimumScaleFactor = 0.5
            lblInstructions.lineBreakMode = .byWordWrapping
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let calculatedHeight = calculateLabelHeight(for: lblEventDetails.text ?? "", width: mainContent.frame.width - 100, font: lblEventDetails.font)
        if calculatedHeight > 130 {
            lblEventDetailsHeight.constant = calculatedHeight
            vwGradientHeight.constant = (calculatedHeight - 130) + 405
            mainContent.layoutIfNeeded()
        }
    }
    
    func calculateLabelHeight(for text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        return ceil(boundingBox.height)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        viewModel.incrementTapCount()
    }
    
    private func setupAdminTapGestures() {
        // Remove existing gesture recognizers first
        if let existingGestures = vwTopLeft.gestureRecognizers {
            existingGestures.forEach { vwTopLeft.removeGestureRecognizer($0) }
        }
        if let existingGestures = vwTopRight.gestureRecognizers {
            existingGestures.forEach { vwTopRight.removeGestureRecognizer($0) }
        }
        
        // Add new gesture recognizers
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
        vwTopLeft.addGestureRecognizer(leftTapGesture)
        vwTopLeft.isUserInteractionEnabled = true
        
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))
        vwTopRight.addGestureRecognizer(rightTapGesture)
        vwTopRight.isUserInteractionEnabled = true
    }
    
    @objc private func handleLeftTap() {
        leftTapCount += 1
        
        // Reset count after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) { [weak self] in
            self?.leftTapCount = 0
        }
        
        // Check if left taps are complete and proceed to check right taps
        if leftTapCount >= requiredTaps {
            // Visual feedback (optional)
        }
    }
    
    @objc private func handleRightTap() {
        // Only count right taps if left taps are complete
        guard leftTapCount >= requiredTaps else { return }
        
        rightTapCount += 1
        
        // Reset count after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) { [weak self] in
            self?.rightTapCount = 0
        }
        
        // Check if both conditions are met
        if rightTapCount >= requiredTaps {
            leftTapCount = 0
            rightTapCount = 0
            
            self.performSegue(withIdentifier: "adminSegue", sender: nil)
        }
    }
    
    @IBAction func test(_sender: UIButton) {
        performSegue(withIdentifier: "test", sender: nil)
    }
    
    @IBAction func splitView(_sender: UIButton) {
        let screenWidth = UIScreen.main.bounds.width
        let leading = screenWidth * 0.4
        let titleWidth = (screenWidth - leading) - 100
        let detailsWidth = titleWidth - 56
        //lblTitleWidth.constant = titleWidth
        //lblMessageWidth.constant = titleWidth
        //lblEventDetailsWidth.constant = detailsWidth
        print("Screen width: \(screenWidth)")
        splitButton.isHidden = true
        splitLabel.isHidden = true
        leadingConstraint.constant = leading
        if let settings = appConfig.settings {
            lblTitle.text = settings.eventSplitTitle
            lblMessage.text = settings.eventSplitMessage
            lblEventDetails.text = settings.eventSplitDetails
            if settings.splitImageURL.count > 0 {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let adminFolderURL = documentDirectory.appendingPathComponent("admin", isDirectory: true)
                print("splitImageURL :\(settings.splitImageURL)")
                
                let url = adminFolderURL.appendingPathComponent(settings.splitImageURL)
                if FileManager.default.fileExists(atPath: url.path) {
                    do {
                        
                        let imageData = try Data(contentsOf: url)
                        imgWallpaper.image = UIImage(data: imageData)
                        print("Image loaded successfully.")
                    } catch {
                        print("Failed to load image data: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        mainContent.layoutIfNeeded()
        homeScroll.setContentOffset(CGPoint(x: leading, y: 0), animated: true)
    }
    
    @IBAction func leaveMessage(_sender: UIButton) {
        performSegue(withIdentifier: "toCapture", sender: nil)
    }
    
    @IBAction func viewQuestions(_sender: UIButton) {
        performSegue(withIdentifier: "toQuestion", sender: nil)
    }
    
    private func showPasswordAlert() {
        let alert = UIAlertController(
            title: "Admin Access",
            message: "Please enter password",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let password = alert.textFields?.first?.text else { return }
            
            if password == "admin123" { // Palitan mo ito ng tamang password
                self?.performSegue(withIdentifier: "adminSegue", sender: nil)
            } else {
                self?.showErrorAlert()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Invalid password",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
}

