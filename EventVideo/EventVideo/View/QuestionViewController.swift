//
//  QuestionViewController.swift
//  EventVideo
//
//  Created by JayR Atamosa on 1/2/25.
//

import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet var vwGradient: UIView!
    @IBOutlet var imgBG: UIImageView!
    @IBOutlet var lblInstruction: AutoShrinkLabel!
    @IBOutlet var lblQuestion: AutoShrinkLabel!
    @IBOutlet var lblLeaveMessage: AutoShrinkLabel!
    @IBOutlet var lblQuestionPageTitle: AutoShrinkLabel!
    let appConfig = AppConfig.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            lblInstruction.text = settings.questionInstruction
            lblInstruction.font = settings.questionInstructionFont
            let combinedString = settings.questions.map { "• \($0)" }.joined(separator: "\n")
            lblQuestion.text = combinedString
            lblQuestion.font = settings.questionsFont
            if settings.questionScreenWallpaperURL.count > 0 {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let adminFolderURL = documentDirectory.appendingPathComponent("admin", isDirectory: true)
                print("welcomeScreenWallpaperURL :\(settings.questionScreenWallpaperURL)")
                
                let url = adminFolderURL.appendingPathComponent(settings.questionScreenWallpaperURL)
                if FileManager.default.fileExists(atPath: url.path) {
                    do {
                        
                        let imageData = try Data(contentsOf: url)
                        imgBG.image = UIImage(data: imageData)
                        print("Image loaded successfully.")
                    } catch {
                        print("Failed to load image data: \(error.localizedDescription)")
                    }
                }
                
            }
            lblLeaveMessage.text = settings.questionButtonTitle
            lblLeaveMessage.font = settings.questionButtonTitleFont
            lblQuestionPageTitle.text = settings.questionTitle
            lblQuestionPageTitle.font = settings.questionTitleFont
            vwGradient.backgroundColor = UIColor.fromRGBString(settings.overAllGradientColor)
            vwGradient.alpha = settings.welcomeScreenGradient
            lblLeaveMessage.textColor = UIColor.fromRGBString(settings.overAllButtonTextColor)
        }
    }
    
    @IBAction func leaveMessage(_sender: UIButton) {
        performSegue(withIdentifier: "toCapture", sender: nil)
    }
}
