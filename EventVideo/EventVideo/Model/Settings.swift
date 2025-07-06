import Foundation
import UIKit

struct Settings: Codable {
    // WELCOME SCREEN
    var welcomeScreenWallpaperURL: String
    var splitImageURL: String
    var welcomeScreenGradient: Double
    var eventTitle: String
    var eventMessage: String
    var eventSplitMessage: String
    var welcomeScreenBackgroundTheme: String
    var eventDetails: String
    var eventSplitTitle: String
    var eventSplitDetails: String
    var welcomeInstruction: String
    var leaveMessageButtonText: String
    var questionButtonTopText: String
    var questionButtonBottomText: String
    var rightSideWelcomeTextColor: String
    var rightSideArrowColor: String
    var whatShouldIsayBGColor: String
    var whatShouldIsayTextColor: String
    var letsGetStartBGColor: String
    var splitLetsGetStartBGColor: String
    private var eventTitleFontName: String
    private var eventTitleFontSize: CGFloat
    private var eventMessageFontName: String
    private var eventMessageFontSize: CGFloat
    private var eventDetailsFontName: String
    private var eventDetailsFontSize: CGFloat
    private var welcomeInstructionFontName: String
    private var welcomeInstructionFontSize: CGFloat
    private var leaveMessageFontName: String
    private var leaveMessageFontSize: CGFloat
    private var questionButtonTopFontName: String
    private var questionButtonTopFontSize: CGFloat
    private var questionButtonBottomFontName: String
    private var questionButtonBottomFontSize: CGFloat

    // Question Screen
    var questionScreenWallpaperURL: String
    var questionScreenGradient: Double
    var questionInstruction: String
    var questionTitle: String
    var questionButtonTitle: String
    private var questionTitleFontName: String
    private var questionTitleFontSize: CGFloat
    private var questionInstructionFontName: String
    private var questionInstructionFontSize: CGFloat
    private var questionsFontName: String
    private var questionsFontSize: CGFloat
    private var questionButtonTitleFontName: String
    private var questionButtonTitleFontSize: CGFloat
    var questions: [String]

    // Recording Screen
    var recordingScreenBackgroundTheme: String
    var recordingScreenGradient: Double
    var getReadyButtonTitle: String
    var doneButtonTitle: String
    var recordingHeaderTitle: String
    var themeColor: String
    private var recordingQuestionsFontName: String
    private var recordingQuestionsFontSize: CGFloat
    private var getReadyButtonTitleFontName: String
    private var getReadyButtonTitleFontSize: CGFloat
    private var doneButtonTitleFontName: String
    private var doneButtonTitleFontSize: CGFloat
    private var recordingHeaderTitleFontName: String
    private var recordingHeaderTitleFontSize: CGFloat
    private var nextAndRetakeTitleFontName: String
    private var nextAndRetakeTitleFontSize: CGFloat
    

    // Thanks Screen
    var thanksScreenWallpaperURL: String
    var thanksScreenGradient: Double
    var thanksScreenMessage: String
    var thanksScreenTitle: String
    var thanksScreenButtonTitle: String
    private var thanksScreenTitleFontName: String
    private var thanksScreenTitleFontSize: CGFloat
    private var thanksScreenMessageFontName: String
    private var thanksScreenMessageFontSize: CGFloat
    private var thanksScreenButtonTitleFontName: String
    private var thanksScreenButtonTitleFontSize: CGFloat
    
    var overAllGradientColor: String
    var overAllButtonTextColor: String
    var overAllButtonBackgroundColor: String
    var cameraZoom: String

    // Computed properties to get/set UIFont
    var eventTitleFont: UIFont {
        get { UIFont(name: eventTitleFontName, size: eventTitleFontSize) ?? UIFont.systemFont(ofSize: eventTitleFontSize) }
        set {
            eventTitleFontName = newValue.fontName
            eventTitleFontSize = newValue.pointSize
        }
    }

    var eventMessageFont: UIFont {
        get { UIFont(name: eventMessageFontName, size: eventMessageFontSize) ?? UIFont.systemFont(ofSize: eventMessageFontSize) }
        set {
            eventMessageFontName = newValue.fontName
            eventMessageFontSize = newValue.pointSize
        }
    }

    var eventDetailsFont: UIFont {
        get { UIFont(name: eventDetailsFontName, size: eventDetailsFontSize) ?? UIFont.systemFont(ofSize: eventDetailsFontSize) }
        set {
            eventDetailsFontName = newValue.fontName
            eventDetailsFontSize = newValue.pointSize
        }
    }

    var welcomeInstructionFont: UIFont {
        get { UIFont(name: welcomeInstructionFontName, size: welcomeInstructionFontSize) ?? UIFont.systemFont(ofSize: welcomeInstructionFontSize) }
        set {
            welcomeInstructionFontName = newValue.fontName
            welcomeInstructionFontSize = newValue.pointSize
        }
    }
    
    var leaveMessageFont: UIFont {
        get { UIFont(name: leaveMessageFontName, size: leaveMessageFontSize) ?? UIFont.systemFont(ofSize: leaveMessageFontSize) }
        set {
            leaveMessageFontName = newValue.fontName
            leaveMessageFontSize = newValue.pointSize
        }
    }
    
    var questionButtonTopFont: UIFont {
        get { UIFont(name: questionButtonTopFontName, size: questionButtonTopFontSize) ?? UIFont.systemFont(ofSize: questionButtonTopFontSize) }
        set {
            questionButtonTopFontName = newValue.fontName
            questionButtonTopFontSize = newValue.pointSize
        }
    }
    
    var questionButtonBottomFont: UIFont {
        get { UIFont(name: questionButtonBottomFontName, size: questionButtonBottomFontSize) ?? UIFont.systemFont(ofSize: questionButtonBottomFontSize) }
        set {
            questionButtonBottomFontName = newValue.fontName
            questionButtonBottomFontSize = newValue.pointSize
        }
    }
    
    //QUESTION SCREEN
    var questionInstructionFont: UIFont {
        get { UIFont(name: questionInstructionFontName, size: questionInstructionFontSize) ?? UIFont.systemFont(ofSize: questionInstructionFontSize) }
        set {
            questionInstructionFontName = newValue.fontName
            questionInstructionFontSize = newValue.pointSize
        }
    }
    
    var questionTitleFont: UIFont {
        get { UIFont(name: questionTitleFontName, size: questionTitleFontSize) ?? UIFont.systemFont(ofSize: questionTitleFontSize) }
        set {
            questionTitleFontName = newValue.fontName
            questionTitleFontSize = newValue.pointSize
        }
    }
    
    var questionsFont: UIFont {
        get { UIFont(name: questionsFontName, size: questionsFontSize) ?? UIFont.systemFont(ofSize: questionsFontSize) }
        set {
            questionsFontName = newValue.fontName
            questionsFontSize = newValue.pointSize
        }
    }
    
    var questionButtonTitleFont: UIFont {
        get { UIFont(name: questionButtonTitleFontName, size: questionButtonTitleFontSize) ?? UIFont.systemFont(ofSize: questionButtonTitleFontSize) }
        set {
            questionButtonTitleFontName = newValue.fontName
            questionButtonTitleFontSize = newValue.pointSize
        }
    }
    //RECORDING SCREEN
    var recordingQuestionsFont: UIFont {
        get { UIFont(name: recordingQuestionsFontName, size: recordingQuestionsFontSize) ?? UIFont.systemFont(ofSize: recordingQuestionsFontSize) }
        set {
            recordingQuestionsFontName = newValue.fontName
            recordingQuestionsFontSize = newValue.pointSize
        }
    }
    
    var getReadyButtonTitleFont: UIFont {
        get { UIFont(name: getReadyButtonTitleFontName, size: getReadyButtonTitleFontSize) ?? UIFont.systemFont(ofSize: getReadyButtonTitleFontSize) }
        set {
            getReadyButtonTitleFontName = newValue.fontName
            getReadyButtonTitleFontSize = newValue.pointSize
        }
    }
    
    var doneButtonTitleFont: UIFont {
        get { UIFont(name: doneButtonTitleFontName, size: doneButtonTitleFontSize) ?? UIFont.systemFont(ofSize: doneButtonTitleFontSize) }
        set {
            doneButtonTitleFontName = newValue.fontName
            doneButtonTitleFontSize = newValue.pointSize
        }
    }
    
    var recordingHeaderTitleFont: UIFont {
        get { UIFont(name: recordingHeaderTitleFontName, size: recordingHeaderTitleFontSize) ?? UIFont.systemFont(ofSize: recordingHeaderTitleFontSize) }
        set {
            recordingHeaderTitleFontName = newValue.fontName
            recordingHeaderTitleFontSize = newValue.pointSize
        }
    }
    
    var nextRetakeFont: UIFont {
        get { UIFont(name: nextAndRetakeTitleFontName, size: nextAndRetakeTitleFontSize) ?? UIFont.systemFont(ofSize: nextAndRetakeTitleFontSize) }
        set {
            nextAndRetakeTitleFontName = newValue.fontName
            nextAndRetakeTitleFontSize = newValue.pointSize
        }
    }
    
    //THANKS SCREEN
    var thanksScreenMessageFont: UIFont {
        get { UIFont(name: thanksScreenMessageFontName, size: thanksScreenMessageFontSize) ?? UIFont.systemFont(ofSize: thanksScreenMessageFontSize) }
        set {
            thanksScreenMessageFontName = newValue.fontName
            thanksScreenMessageFontSize = newValue.pointSize
        }
    }
    
    var thanksScreenTitleFont: UIFont {
        get { UIFont(name: thanksScreenTitleFontName, size: thanksScreenTitleFontSize) ?? UIFont.systemFont(ofSize: thanksScreenTitleFontSize) }
        set {
            thanksScreenTitleFontName = newValue.fontName
            thanksScreenTitleFontSize = newValue.pointSize
        }
    }
    
    var thanksScreenButtonTitleFont: UIFont {
        get { UIFont(name: thanksScreenButtonTitleFontName, size: thanksScreenButtonTitleFontSize) ?? UIFont.systemFont(ofSize: thanksScreenButtonTitleFontSize) }
        set {
            thanksScreenButtonTitleFontName = newValue.fontName
            thanksScreenButtonTitleFontSize = newValue.pointSize
        }
    }
}
