import UIKit

class AdminViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIFontPickerViewControllerDelegate {
    
    let sections = ["Welcome Screen", "Question Screen", "Recording Screen", "Thanks Screen", "Over All"]
    var settings: Settings?
    var selectedImageSection: Int = 0
    var selectedImageRow: Int = 0
    
    @IBOutlet var tableView: UITableView!
    
    var expandedCells: Set<IndexPath> = [] // Tracks expanded cells
    
    // Add property to track which font we're updating
    private var currentFontTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 20
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArrayAddCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArrayRemoveCell")
        tableView.isEditing = true
        createDefaultSettingsIfNeeded()
        readSettingsFromAdminFolder()
        
        // Magdagdag ng close button
        setupCloseButton()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        
        // I-setup ang position ng button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func closePage() {
        navigationController?.popViewController(animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    @IBAction func save() {
        self.saveSettingsToAdminFolder()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 3, 4, 6, 7, 8, 9, 10, 23: // Text view cells
                return 220
            default:
                return 60
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 2, 3, 4: // Text view cells
                return 220
            default:
                return 60
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 2, 3, 4: // Text view cells
                return 220
            default:
                return 60
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 2, 3, 4: // Text view cells
                return 220
            default:
                return 60
            }
        } else if indexPath.section == 4 {
            return 60
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 27
        case 1: return 10 + (settings?.questions.count ?? 0)
        case 2: return 11
        case 3: return 8
        case 4: return 4
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            // Enable swipe to delete for the second cell (index 1)
        if indexPath.section == 1 && indexPath.row > 9 {
                let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                    // Handle delete action
                    guard var settings = self.settings else { return }
                    
                    // Remove the question at the index specified in the button's tag
                    let row = indexPath.row - 10
                    settings.questions.remove(at: row)
                    self.settings = settings
                    // Save updated settings to the admin folder
                    self.saveSettingsToAdminFolder()

                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    completionHandler(true)
                }
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            
            // Return nil for other cells to disable swipe actions
            return nil
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 2, 3, 4:
            return configureBasicCell(indexPath: indexPath)
        case 1:
            if indexPath.row < 9 {
                return configureBasicCell(indexPath: indexPath)
            } else {
                return configureArrayCell(indexPath: indexPath)
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView,
                       editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return (indexPath.section == 1 && indexPath.row > 9) ? .delete : .none
        }
    
    // Allow row reordering
        func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return indexPath.section == 1 && indexPath.row > 9
        }
    
        // Update data after a row has been moved
        func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            
            guard var settings = settings else { return }
            guard sourceIndexPath.section == 1, sourceIndexPath.row > 9,
                      destinationIndexPath.section == 1 else { return }
            
            let movedItem = settings.questions.remove(at: sourceIndexPath.row - 10)
            settings.questions.insert(movedItem, at: destinationIndexPath.row - 10)
            self.settings = settings
            self.settings = settings
            self.saveSettingsToAdminFolder()
            self.tableView.reloadData()
        }
    
        func tableView(_ tableView: UITableView,
                       shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            return indexPath.section == 1 && indexPath.row > 9
        }

    // MARK: - Configure Cells
    
    func configureBasicCell(indexPath: IndexPath) -> UITableViewCell {
        guard let settings = settings else { return UITableViewCell() }
        
        let (settingName, settingValue) = getSettingDetails(for: indexPath, settings: settings)
        
        switch determineCellType(for: indexPath) {
        case .textField:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextViewCell
            cell.configure(title: settingName, value: settingValue as! String)
            cell.txtValue.delegate = self
            cell.txtValue.tag = generateTag(for: indexPath)
            return cell
        case .imagePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImagePickerCell", for: indexPath) as! ImagePickerViewCell
            cell.btnSelect.tag = (indexPath.section * 100) + indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(pickImage(_:)), for: .touchUpInside)
            cell.configure(title: settingName)
            return cell
        case .colorPicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorPickerCell", for: indexPath) as! ColorPickerViewCell
            cell.btnSelect.addTarget(self, action: #selector(pickColor(_:)), for: .touchUpInside)
            cell.btnSelect.tag = (indexPath.section * 100) + indexPath.row
            cell.configure(title: settingName, selectedColor: settingValue as! String)
            return cell
        case .slider:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell", for: indexPath) as! SliderViewCell
            cell.slider.tag = indexPath.section * 100
            cell.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            cell.configure(title: settingName, value: settingValue as! Double)
            return cell
        case .fontPicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FontPickerCell", for: indexPath) as! FontPickerViewCell
            cell.btnSelect.tag =  (indexPath.section * 100) + indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(pickFont(_:)), for: .touchUpInside)
            let font = getFont(for: indexPath, settings: settings)
            cell.configure(title: settingName, font: "\(font.fontName) - \(Int(font.pointSize))pt")
            return cell
        case .dropdown:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ZoomPickerViewCell", for: indexPath) as! ZoomPickerViewCell
            cell.btnSelect.tag =  (indexPath.section * 100) + indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(pickZoomOption(_:)), for: .touchUpInside)
            cell.configure(title: settingName, zoom: settingValue as! String)
            return cell
        case .defaultCell:
            return UITableViewCell()
        }
    }

    // MARK: - Helper Methods

    private func getSettingDetails(for indexPath: IndexPath, settings: Settings) -> (String, Any) {
        switch indexPath.section {
        case 0: return (getWelcomeScreenSettingName(for: indexPath.row), getWelcomeScreenSettingValue(for: indexPath.row, settings: settings))
        case 1: return (getQuestionScreenSettingName(for: indexPath.row), getQuestionScreenSettingValue(for: indexPath.row, settings: settings))
        case 2: return (getRecordingScreenSettingName(for: indexPath.row), getRecordingScreenSettingValue(for: indexPath.row, settings: settings))
        case 3: return (getThanksScreenSettingName(for: indexPath.row), getThanksScreenSettingValue(for: indexPath.row, settings: settings))
        case 4: return (getOverallSettingName(for: indexPath.row), getOverallSettingValue(for: indexPath.row, settings: settings))
        default: return ("", "")
        }
    }

    private func determineCellType(for indexPath: IndexPath) -> CellType {
        switch indexPath.section {
            case 0:
                if indexPath.row == 0 || indexPath.row == 1 {
                    return .imagePicker
                }
                else if indexPath.row == 2 {
                    return .slider
                }
                else if (indexPath.row >= 3 &&  indexPath.row <= 4) || (indexPath.row >= 6 &&  indexPath.row <= 10) || (indexPath.row >= 22 &&  indexPath.row <= 24){
                    return .textField
                }
                else if (indexPath.row == 5 || indexPath.row == 18 || indexPath.row == 19 || indexPath.row == 20 || indexPath.row == 21 || indexPath.row == 25 || indexPath.row == 26) {
                    return .colorPicker
                } else {
                    return .fontPicker
                }
            case 1:
                if indexPath.row == 0 {
                    return .imagePicker
                }
                else if indexPath.row == 1 {
                    return .slider
                }
                else if indexPath.row >= 2 &&  indexPath.row <= 4{
                    return .textField
                } else {
                    return .fontPicker
                }
            case 2:
                if indexPath.row == 0 {
                    return .colorPicker
                }
                else if indexPath.row == 1 {
                    return .slider
                }
                else if indexPath.row >= 2 &&  indexPath.row <= 4{
                    return .textField
                } else if indexPath.row == 5 {
                    return .colorPicker
                } else {
                    return .fontPicker
                }
            case 3:
                if indexPath.row == 0 {
                    return .imagePicker
                }
                else if indexPath.row == 1 {
                    return .slider
                }
                else if indexPath.row >= 2 &&  indexPath.row <= 4{
                    return .textField
                } else {
                    return .fontPicker
                }
            case 4:
                if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
                    return .colorPicker
                } else if indexPath.row == 3 {
                    return .dropdown
                }
            default:
                return .defaultCell
        }
        return .defaultCell
    }

    private func getFont(for indexPath: IndexPath, settings: Settings) -> UIFont {
        let fontMap: [String: KeyPath<Settings, UIFont>] = [
            "0-11": \Settings.eventTitleFont,
            "0-12": \Settings.eventMessageFont,
            "0-13": \Settings.eventDetailsFont,
            "0-14": \Settings.welcomeInstructionFont,
            "0-15": \Settings.leaveMessageFont,
            "0-16": \Settings.questionButtonTopFont,
            "0-17": \Settings.questionButtonBottomFont,
            "1-5": \Settings.questionTitleFont,
            "1-6": \Settings.questionInstructionFont,
            "1-7": \Settings.questionsFont,
            "1-8": \Settings.questionButtonTitleFont,
            "2-6": \Settings.recordingQuestionsFont,
            "2-7": \Settings.getReadyButtonTitleFont,
            "2-8": \Settings.doneButtonTitleFont,
            "2-9": \Settings.recordingHeaderTitleFont,
            "3-5": \Settings.thanksScreenTitleFont,
            "3-6": \Settings.thanksScreenMessageFont,
            "3-7": \Settings.thanksScreenButtonTitleFont
        ]
        
        let key = "\(indexPath.section)-\(indexPath.row)"
        if let keyPath = fontMap[key] {
            return settings[keyPath: keyPath]
        }
        return .systemFont(ofSize: 17)
    }

    private func generateTag(for indexPath: IndexPath) -> Int {
        return (indexPath.section * 100) + indexPath.row
    }

    private enum CellType {
        case textField, imagePicker, colorPicker, slider, fontPicker, dropdown, defaultCell
    }

    
    func configureArrayCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddQuestionViewCell", for: indexPath) as! AddQuestionViewCell
            cell.configure(title: "Add Question")
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.btnAdd.addTarget(self, action: #selector(addArrayItem(_:)), for: .touchUpInside)
            cell.btnAdd.tag = indexPath.row
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArrayRemoveCell", for: indexPath)
            let questionIndex = indexPath.row - 10 // Adjust index based on fixed rows
            cell.textLabel?.text = settings?.questions[questionIndex] ?? "Question \(questionIndex + 1)"
            cell.textLabel?.font = .systemFont(ofSize: 24)
            
            cell.gestureRecognizers?.forEach { cell.removeGestureRecognizer($0) }

            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            cell.addGestureRecognizer(doubleTap)
            return cell
        }
    }
    
    func createAddButton(for indexPath: IndexPath) -> UIButton {
        let button = UIButton(type: .contactAdd)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(addArrayItem(_:)), for: .touchUpInside)
        button.tag = indexPath.row
        return button
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell),
              indexPath.section == 1,
              indexPath.row > 9 else { return }

        let questionIndex = indexPath.row - 10
        
        // Present an alert to edit the value
        let alert = UIAlertController(title: "Edit Item",
                                      message: "Enter a new value for this item.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.settings?.questions[questionIndex]
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let newText = alert.textFields?.first?.text {
                self.settings?.questions[questionIndex] = newText
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }))

        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc func addArrayItem(_ sender: UIButton) {
        guard var settings = settings else { return }

        // Present an alert with a text field to enter a new question
        let alert = UIAlertController(title: "Add Question", message: "Enter your question:", preferredStyle: .alert)

        // Add a text field to the alert
        alert.addTextField { textField in
            textField.placeholder = "Type your question here"
        }

        // Add "Add" action to the alert
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            // Retrieve the input from the text field
            if let questionText = alert.textFields?.first?.text, !questionText.isEmpty {
                settings.questions.append(questionText) // Add the new question to the settings
                self.settings = settings
                self.saveSettingsToAdminFolder()
                self.tableView.reloadData()
            }
        }

        // Add "Cancel" action to the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    @objc func pickImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        selectedImageSection = sender.tag / 100
        selectedImageRow =  sender.tag - (selectedImageSection * 100)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func pickColor(_ sender: UIButton) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.selectedColor = sender.backgroundColor ?? .white // Pre-select current color
        colorPicker.view.tag = sender.tag
        present(colorPicker, animated: true)
    }
    
    @objc func pickZoomOption(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Zoom Option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "0.5x", style: .default, handler: { _ in
            self.settings?.cameraZoom = "0.5x"
            self.saveSettingsToAdminFolder()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "1x", style: .default, handler: { _ in
            self.settings?.cameraZoom = "1x"
            self.saveSettingsToAdminFolder()
            self.tableView.reloadData()
        }))

                // iPad fix — configure popoverPresentationController
                if let popover = alert.popoverPresentationController {
                    popover.sourceView = sender
                    popover.sourceRect = sender.bounds
                    popover.permittedArrowDirections = .any
                }

                present(alert, animated: true, completion: nil)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        guard var settings = settings else { return }
        let selectedColor = viewController.selectedColor
        let section = viewController.view.tag / 100
        let row = viewController.view.tag - (section * 100)

        // Convert selected color to RGB string
        let rgbString = selectedColor.toRGBString()

        switch section {
        case 0: // Welcome Screen
            if row == 5 {
                settings.welcomeScreenBackgroundTheme = rgbString
            } else if row == 18 {
                settings.rightSideWelcomeTextColor = rgbString
            } else if row == 19 {
                settings.rightSideArrowColor = rgbString
            } else if row == 20 {
                settings.whatShouldIsayBGColor = rgbString
            } else if row == 21 {
                settings.whatShouldIsayTextColor = rgbString
            } else if row == 25 {
                settings.letsGetStartBGColor = rgbString
            } else if row == 26 {
                settings.splitLetsGetStartBGColor = rgbString
            }
        case 2: // Recording Screen
            if row == 0 {
                settings.recordingScreenBackgroundTheme = rgbString
            } else {
                settings.themeColor = rgbString
            }
        case 4: // Recording Screen
            if row == 0 {
                settings.overAllGradientColor = rgbString
            } else if row == 1 {
                settings.overAllButtonTextColor = rgbString
            } else {
                settings.overAllButtonBackgroundColor = rgbString
            }
        default:
            break
        }

        self.settings = settings
        saveSettingsToAdminFolder() // Save the updated settings
        tableView.reloadData() // Reload the table view to reflect changes
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        print("Slider Value Changed: \(sender.value)")
        guard let cell = sender.superview?.superview as? UITableViewCell,
                  let valueLabel = cell.viewWithTag(3) as? UILabel else { return }
            
            // Update the label with the new slider value
            valueLabel.text = String(format: "%.2f", sender.value)
            
        guard var settings = settings else { return }
        let tag = sender.tag
        let section = tag / 100
        
        if section == 0 {
            settings.welcomeScreenGradient = Double(sender.value)
        } else if section == 1 {
            settings.questionScreenGradient = Double(sender.value)
        } else if section == 2 {
            settings.recordingScreenGradient = Double(sender.value)
        } else if section == 3 {
            settings.thanksScreenGradient = Double(sender.value)
        }
        self.settings = settings
        self.tableView.reloadData()
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        var section: Int
        var row: Int
        let tag = textView.tag
        section = tag / 100
        row = tag - (section * 100)
        print("textViewDidChange in section: \(section) row: \(row)")
        guard var settings = settings else { return }
        if section == 0 {
            switch row {
            case 3: settings.eventTitle = textView.text
            case 4: settings.eventMessage = textView.text
            case 6: settings.eventDetails = textView.text
            case 7: settings.welcomeInstruction = textView.text
            case 8: settings.leaveMessageButtonText = textView.text
            case 9: settings.questionButtonTopText = textView.text
            case 10: settings.questionButtonBottomText = textView.text
            case 22: settings.eventSplitTitle = textView.text
            case 23: settings.eventSplitDetails = textView.text
            case 24: settings.eventSplitMessage = textView.text
            default: break
            }
        } else if section == 1 {
            switch row {
            case 2: settings.questionInstruction = textView.text
            case 3: settings.questionTitle = textView.text
            case 4: settings.questionButtonTitle = textView.text
            default: break
            }
        } else if section == 2 {
            switch row {
            case 2: settings.getReadyButtonTitle = textView.text
            case 3: settings.doneButtonTitle = textView.text
            case 4: settings.recordingHeaderTitle = textView.text
            default: break
            }
        } else if section == 3 {
            switch row {
            case 2: settings.thanksScreenMessage = textView.text
            case 3: settings.thanksScreenTitle = textView.text
            case 4: settings.thanksScreenButtonTitle = textView.text
            default: break
            }
        }
        self.settings = settings
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker
        
        // Retrieve the selected image
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // Get the Documents directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let adminFolderURL = documentDirectory.appendingPathComponent("admin", isDirectory: true)
        
        // Create the "admin" folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: adminFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: adminFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create 'admin' folder: \(error)")
                return
            }
        }
        
        // Create a unique file name for the image
        var uniqueFileName = ""
        if selectedImageSection == 0 {
            if selectedImageRow == 0 {
                uniqueFileName = "welcomeScreenWallpaper.jpg"
            } else {
                uniqueFileName = "splitImage.jpg"
            }
        } else if selectedImageSection == 1 {
            uniqueFileName = "questionScreenWallpaper.jpg"
        } else if selectedImageSection == 3 {
            uniqueFileName = "thanksScreenWallpaper.jpg"
        }
        let imageFileURL = adminFolderURL.appendingPathComponent(uniqueFileName)
        
        // Save the image as JPEG data
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: imageFileURL)
                print("Image saved successfully at: \(imageFileURL)")
                
                if selectedImageSection == 0 {
                    if selectedImageRow == 0 {
                        self.settings?.welcomeScreenWallpaperURL = uniqueFileName
                    } else {
                        self.settings?.splitImageURL = uniqueFileName
                    }
                } else if selectedImageSection == 1 {
                    self.settings?.questionScreenWallpaperURL = uniqueFileName
                } else if selectedImageSection == 3 {
                    self.settings?.thanksScreenWallpaperURL = uniqueFileName
                }
            } catch {
                print("Failed to save image: \(error)")
            }
        } else {
            print("Failed to convert image to JPEG data")
        }
    }
    
    // MARK: - Utility Functions for Settings

        func getWelcomeScreenSettingName(for row: Int) -> String {
            switch row {
            case 0: return "Wallpaper URL"
            case 1: return "Split Image URL"
            case 2: return "Gradient"
            case 3: return "Event Title"
            case 4: return "Event Message"
            case 5: return "Background Theme"
            case 6: return "Event Details"
            case 7: return "Instruction"
            case 8: return "Leave Message Button Text"
            case 9: return "Question Top Text"
            case 10: return "Question Bottom Text"
            case 11: return "Event Title Font"
            case 12: return "Event Message Font"
            case 13: return "Event Details Font"
            case 14: return "Right Side Welcome Instruction Font"
            case 15: return "Leave Message Font"
            case 16: return "Question Top Font"
            case 17: return "Question Bottom Font"
            case 18: return "Right Side Welcome Instruction Color"
            case 19: return "Right Side Arrow Button Color"
            case 20: return "What Should I Say Button Color"
            case 21: return "What Should I Say Text Color"
            case 22: return "Event Split Title"
            case 23: return "Event Split Details"
            case 24: return "Event Split Message"
            case 25: return "Let's Get Started Button Background Color"
            case 26: return "Split Let's Get Started Button Background Color"
            default: return ""
            }
        }

    func getWelcomeScreenSettingValue(for row: Int, settings: Settings) -> Any {
        switch row {
        case 0: return settings.welcomeScreenWallpaperURL
        case 1: return settings.splitImageURL
        case 2: return settings.welcomeScreenGradient
        case 3: return settings.eventTitle
        case 4: return settings.eventMessage
        case 5: return settings.welcomeScreenBackgroundTheme
        case 6: return settings.eventDetails
        case 7: return settings.welcomeInstruction
        case 8: return settings.leaveMessageButtonText
        case 9: return settings.questionButtonTopText
        case 10: return settings.questionButtonBottomText
        case 11: return settings.eventTitleFont
        case 12: return settings.eventMessageFont
        case 13: return settings.eventDetailsFont
        case 14: return settings.welcomeInstructionFont
        case 15: return settings.leaveMessageFont
        case 16: return settings.questionButtonTopFont
        case 17: return settings.questionButtonBottomFont
        case 18: return settings.rightSideWelcomeTextColor
        case 19: return settings.rightSideArrowColor
        case 20: return settings.whatShouldIsayBGColor
        case 21: return settings.whatShouldIsayTextColor
        case 22: return settings.eventSplitTitle
        case 23: return settings.eventSplitDetails
        case 24: return settings.eventSplitMessage
        case 25: return settings.letsGetStartBGColor
        case 26: return settings.splitLetsGetStartBGColor
        default: return ""
        }
    }

        func getQuestionScreenSettingName(for row: Int) -> String {
            switch row {
            case 0: return "Wallpaper URL"
            case 1: return "Gradient"
            case 2: return "Instruction"
            case 3: return "Question Page Title"
            case 4: return "Question Button Title"
            case 5: return "Question Page Title Font"
            case 6: return "Instruction Font"
            case 7: return "Questions Font"
            case 8: return "Question Button Title Font"
            case 9: return "Questions"
            default: return ""
            }
        }

        func getQuestionScreenSettingValue(for row: Int, settings: Settings) -> Any {
            switch row {
            case 0: return settings.questionScreenWallpaperURL
            case 1: return settings.questionScreenGradient
            case 2: return settings.questionInstruction
            case 3: return settings.questionTitle
            case 4: return settings.questionButtonTitle
            case 5: return settings.questionTitleFont
            case 6: return settings.questionInstructionFont
            case 7: return settings.questionsFont
            case 8: return settings.questionButtonTitleFont
            case 9: return settings.questions
            default: return ""
            }
        }

        func getRecordingScreenSettingName(for row: Int) -> String {
            switch row {
            case 0: return "Background Theme"
            case 1: return "Gradient"
            case 2: return "Get Ready Button Title"
            case 3: return "Done Button Title"
            case 4: return "Header Title"
            case 5: return "Page Theme Color"
            case 6: return "Questions Font"
            case 7: return "Get Ready Button Font"
            case 8: return "Done Button Font"
            case 9: return "Header Font"
            case 10: return "Next/Retake Button Font"
            default: return ""
            }
        }

        func getRecordingScreenSettingValue(for row: Int, settings: Settings) -> Any {
            switch row {
            case 0: return settings.recordingScreenBackgroundTheme
            case 1: return settings.recordingScreenGradient
            case 2: return settings.getReadyButtonTitle
            case 3: return settings.doneButtonTitle
            case 4: return settings.recordingHeaderTitle
            case 5: return settings.themeColor
            case 6: return settings.questionsFont
            case 7: return settings.getReadyButtonTitleFont
            case 8: return settings.doneButtonTitleFont
            case 9: return settings.recordingHeaderTitleFont
            case 10: return settings.nextRetakeFont
            default: return ""
            }
        }

        func getThanksScreenSettingName(for row: Int) -> String {
            switch row {
            case 0: return "Wallpaper URL"
            case 1: return "Gradient"
            case 2: return "Message"
            case 3: return "Page Title"
            case 4: return "Button Title"
            case 5: return "Page Title Font"
            case 6: return "Message Font"
            case 7: return "Button Title Font"
            default: return ""
            }
        }

        func getThanksScreenSettingValue(for row: Int, settings: Settings) -> Any {
            switch row {
            case 0: return settings.thanksScreenWallpaperURL
            case 1: return settings.thanksScreenGradient
            case 2: return settings.thanksScreenMessage
            case 3: return settings.thanksScreenTitle
            case 4: return settings.thanksScreenButtonTitle
            case 5: return settings.thanksScreenTitleFont
            case 6: return settings.thanksScreenMessageFont
            case 7: return settings.thanksScreenButtonTitleFont
            default: return ""
            }
        }

        func getOverallSettingName(for row: Int) -> String {
            switch row {
            case 0: return "OverAll Gradient Color"
            case 1: return "OverAll Button Text Color"
            case 2: return "OverAll Button Background Color"
            case 3: return "Camera Zoom Option"
            default: return ""
            }
        }

        func getOverallSettingValue(for row: Int, settings: Settings) -> Any {
            switch row {
            case 0: return settings.overAllGradientColor
            case 1: return settings.overAllButtonTextColor
            case 2: return settings.overAllButtonBackgroundColor
            case 3: return settings.cameraZoom
            default: return ""
            }
        }
    func createDefaultSettingsIfNeeded() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to find document directory")
            return
        }

        let adminFolderURL = documentDirectory.appendingPathComponent("admin")
        let settingsFileURL = adminFolderURL.appendingPathComponent("settings.json")

        // Check if the file already exists
        if fileManager.fileExists(atPath: settingsFileURL.path) {
            print("Settings file already exists.")
            return
        }

        // Create the admin folder if it doesn't exist
        if !fileManager.fileExists(atPath: adminFolderURL.path) {
            do {
                try fileManager.createDirectory(at: adminFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create admin folder: \(error)")
                return
            }
        }

        // Define the default settings
        let defaultSettings: [String: Any] = [
            "welcomeScreenWallpaperURL": "",
            "splitImageURL": "",
            "welcomeScreenGradient": 0.32,
            "eventTitle": "WELCOME",
            "eventMessage": "LEAVE A MESSAGE FOR THE EVENT",
            "welcomeScreenBackgroundTheme": "237,223,206,1.0",
            "eventDetails": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae consectetur nisi, non posuere sem. Donec molestie posuere erat nec egestas.",
            "welcomeInstruction": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae consectetur nisi, non posuere sem. Donec molestie posuere erat nec egestas.",
            "leaveMessageButtonText": "LEAVE A MESSAGE",
            "questionButtonTopText": "WHAT SHOULD I SAY?",
            "questionButtonBottomText": "HERE’S THE LIST OF MESSAGES YOU CAN LEAVE!",
            "rightSideWelcomeTextColor": "0,0,0,1.0",
            "rightSideArrowColor": "94,24,0,1.0",
            "whatShouldIsayBGColor": "230,210,186,1.0",
            "whatShouldIsayTextColor": "94,24,0,1.0",
            "eventTitleFontName": "PlayfairDisplay-Bold",
            "eventTitleFontSize": 120.0,
            "eventMessageFontName": "Rosario-Regular",
            "eventMessageFontSize": 35.0,
            "eventDetailsFontName": "Montserrat-Regular",
            "eventDetailsFontSize": 24.0,
            "welcomeInstructionFontName": "Montserrat-Regular",
            "welcomeInstructionFontSize": 24.0,
            "leaveMessageFontName": "PlayfairDisplay-Bold",
            "leaveMessageFontSize": 22.0,
            "questionButtonTopFontName": "Montserrat-Bold",
            "questionButtonTopFontSize": 20.0,
            "questionButtonBottomFontName": "Montserrat-Regular",
            "questionButtonBottomFontSize": 12.0,
            "eventSplitMessage": "LEAVE A MESSAGE FOR THE EVENT",
            "eventSplitTitle": "WELCOME",
            "eventSplitDetails": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae consectetur nisi, non posuere sem. Donec molestie posuere erat nec egestas.",
            "letsGetStartBGColor": "255,255,255,1.0",
            "splitLetsGetStartBGColor": "255,255,255,1.0",
            
            "questionScreenWallpaperURL": "",
            "questionScreenGradient": 0.32,
            "questionInstruction": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae consectetur nisi, non posuere sem. Donec molestie posuere erat nec egestas.",
            "questions": [],
            "questionTitle": "Questions",
            "questionButtonTitle": "LEAVE A MESSAGE",
            "questionTitleFontName": "PlayfairDisplay-Bold",
            "questionTitleFontSize": 100,
            "questionInstructionFontName": "Rosario-Regular",
            "questionInstructionFontSize": 35,
            "questionsFontName": "Montserrat-Regular",
            "questionsFontSize": 24,
            "questionButtonTitleFontName": "PlayfairDisplay-Bold",
            "questionButtonTitleFontSize": 22,
            
            "recordingScreenBackgroundTheme": "94,24,255,1.0",
            "recordingScreenGradient": 0.32,
            "getReadyButtonTitle": "GET READY!",
            "doneButtonTitle": "DONE!",
            "recordingHeaderTitle": "Now Recording. Leave a Message.",
            "themeColor": "94,24,0,1.0",
            "recordingQuestionsFontName": "Rosario-Regular",
            "recordingQuestionsFontSize": 32,
            "getReadyButtonTitleFontName": "PlayfairDisplay-Bold",
            "getReadyButtonTitleFontSize": 24,
            "doneButtonTitleFontName": "PlayfairDisplay-Bold",
            "doneButtonTitleFontSize": 24,
            "recordingHeaderTitleFontName": "PlayfairDisplay-Bold",
            "recordingHeaderTitleFontSize": 36,
            "nextAndRetakeTitleFontName": "PlayfairDisplay-Bold",
            "nextAndRetakeTitleFontSize": 12,
            
            "thanksScreenWallpaperURL": "",
            "thanksScreenGradient": 0.32,
            "thanksScreenMessage": "THE PEEPS APPRECIATE Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur vitae consectetur nisi, non posuere sem. Donec molestie posuere erat nec egestas. non posuere sem. Donec molestie posuere erat nec egestas.You can record another video,etc,",
            "thanksScreenTitle": "Thank you for your message!",
            "thanksScreenButtonTitle": "LEAVE A MESSAGE!",
            "thanksScreenTitleFontName": "PlayfairDisplay-Bold",
            "thanksScreenTitleFontSize": 80,
            "thanksScreenMessageFontName": "Montserrat-Regular",
            "thanksScreenMessageFontSize": 24,
            "thanksScreenButtonTitleFontName": "PlayfairDisplay-Bold",
            "thanksScreenButtonTitleFontSize": 24,
            
            "overAllGradientColor": "0,0,0,1.0",
            "overAllButtonTextColor": "94,24,0,1.0",
            "overAllButtonBackgroundColor": "255,255,255,1.0",
            "cameraZoom": "0.5x",
        ]

        // Save the settings to the file
        do {
            let data = try JSONSerialization.data(withJSONObject: defaultSettings, options: .prettyPrinted)
            try data.write(to: settingsFileURL)
            print("Default settings file created at \(settingsFileURL.path)")
        } catch {
            print("Failed to save default settings: \(error)")
        }
    }
    
        // MARK: - Read and Save Settings

        func readSettingsFromAdminFolder() {
            let fileManager = FileManager.default
            guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to find document directory")
                return
            }

            let adminFolderURL = documentDirectory.appendingPathComponent("admin")
            let settingsFileURL = adminFolderURL.appendingPathComponent("settings.json")

            if fileManager.fileExists(atPath: settingsFileURL.path) {
                do {
                    let data = try Data(contentsOf: settingsFileURL)
                    let decoder = JSONDecoder()
                    settings = try decoder.decode(Settings.self, from: data)
                    print("Settings loaded successfully")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Failed to decode settings: \(error)")
                }
            } else {
                print("Settings file does not exist.")
            }
        }

        func saveSettingsToAdminFolder() {
            guard let settings = settings else { return }
            
            let fileManager = FileManager.default
            guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to find document directory")
                return
            }

            let adminFolderURL = documentDirectory.appendingPathComponent("admin")
            let settingsFileURL = adminFolderURL.appendingPathComponent("settings.json")

            if !fileManager.fileExists(atPath: adminFolderURL.path) {
                do {
                    try fileManager.createDirectory(at: adminFolderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Failed to create admin folder: \(error)")
                    return
                }
            }

            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(settings)
                try data.write(to: settingsFileURL)
                print("Settings saved successfully.")
            } catch {
                print("Failed to save settings: \(error)")
            }
        }

    @objc func pickFont(_ sender: UIButton) {
        currentFontTag = sender.tag
        
        let configuration = UIFontPickerViewController.Configuration()
        configuration.includeFaces = true
        
        let fontPicker = UIFontPickerViewController(configuration: configuration)
        fontPicker.delegate = self
        
        let fontSection =  self.currentFontTag / 100
        let fontRow = self.currentFontTag - (fontSection * 100)
        
        // Get current font
        let currentFont: UIFont = {
            guard let settings = settings else { return .systemFont(ofSize: 17) }
            switch fontSection {
                case 0:
                    switch fontRow {
                    case 11: return settings.eventTitleFont
                    case 12: return settings.eventMessageFont
                    case 13: return settings.eventDetailsFont
                    case 14: return settings.welcomeInstructionFont
                    case 15: return settings.leaveMessageFont
                    case 16: return settings.questionButtonTopFont
                    case 17: return settings.questionButtonBottomFont
                    default: return .systemFont(ofSize: 17)
                    }
                case 1:
                    switch fontRow {
                    case 5: return settings.questionTitleFont
                    case 6: return settings.questionInstructionFont
                    case 7: return settings.questionsFont
                    case 8: return settings.questionButtonTitleFont
                    default: return .systemFont(ofSize: 17)
                    }
                case 2:
                    switch fontRow {
                    case 6: return settings.recordingQuestionsFont
                    case 7: return settings.getReadyButtonTitleFont
                    case 8: return settings.doneButtonTitleFont
                    case 9: return settings.recordingHeaderTitleFont
                    case 10: return settings.nextRetakeFont
                    default: return .systemFont(ofSize: 17)
                    }
                case 3:
                    switch fontRow {
                    case 5: return settings.thanksScreenTitleFont
                    case 6: return settings.thanksScreenMessageFont
                    case 7: return settings.thanksScreenButtonTitleFont
                    default: return .systemFont(ofSize: 17)
                    }
                default: return .systemFont(ofSize: 17)
            }
        }()
        
        // Pre-select current font if possible
        if let descriptor = currentFont.fontDescriptor.matchingFontDescriptors(withMandatoryKeys: nil).first {
            fontPicker.selectedFontDescriptor = descriptor
        }
        
        present(fontPicker, animated: true)
    }
    
    // Add UIFontPickerViewControllerDelegate methods
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let descriptor = viewController.selectedFontDescriptor,
              var settings = settings else { return }

        let currentFont = UIFont(descriptor: descriptor, size: 0)
        let fontSection =  self.currentFontTag / 100
        let fontRow = self.currentFontTag - (fontSection * 100)
        
        // Show size picker after font is selected
        let alert = UIAlertController(title: "Font Size", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Font Size"
            
            // Get current font size
            let currentSize: CGFloat = {
                
                switch fontSection {
                    case 0:
                        switch fontRow {
                        case 11: return settings.eventTitleFont.pointSize
                        case 12: return settings.eventMessageFont.pointSize
                        case 13: return settings.eventDetailsFont.pointSize
                        case 14: return settings.welcomeInstructionFont.pointSize
                        case 15: return settings.leaveMessageFont.pointSize
                        case 16: return settings.questionButtonTopFont.pointSize
                        case 17: return settings.questionButtonBottomFont.pointSize
                        default: return 17
                        }
                    case 1:
                        switch fontRow {
                        case 5: return settings.questionTitleFont.pointSize
                        case 6: return settings.questionInstructionFont.pointSize
                        case 7: return settings.questionsFont.pointSize
                        case 8: return settings.questionButtonTitleFont.pointSize
                        default: return 17
                        }
                    case 2:
                        switch fontRow {
                        case 6: return settings.recordingQuestionsFont.pointSize
                        case 7: return settings.getReadyButtonTitleFont.pointSize
                        case 8: return settings.doneButtonTitleFont.pointSize
                        case 9: return settings.recordingHeaderTitleFont.pointSize
                        case 10: return settings.nextRetakeFont.pointSize
                        default: return 17
                        }
                    case 3:
                        switch fontRow {
                        case 5: return settings.thanksScreenTitleFont.pointSize
                        case 6: return settings.thanksScreenMessageFont.pointSize
                        case 7: return settings.thanksScreenButtonTitleFont.pointSize
                        default: return 17
                        }
                    default: return 17
                }
            }()
            textField.text = String(format: "%.0f", currentSize)
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            var fontSize = 0.0
            var text = ""
            if let text = alert.textFields?.first?.text {
                let size = NumberFormatter().number(from: text)
                fontSize = CGFloat(truncating: size ?? 0.0)
            } else {
                return
            }
            // Create new font with selected family and size
            let newFont = UIFont(descriptor: descriptor, size: fontSize)
            
            switch fontSection {
                case 0:
                    switch fontRow {
                    case 11: settings.eventTitleFont = newFont
                    case 12: settings.eventMessageFont = newFont
                    case 13: settings.eventDetailsFont = newFont
                    case 14: settings.welcomeInstructionFont = newFont
                    case 15: settings.leaveMessageFont = newFont
                    case 16: settings.questionButtonTopFont = newFont
                    case 17: settings.questionButtonBottomFont = newFont
                    default: break
                    }
                case 1:
                    switch fontRow {
                    case 5: settings.questionTitleFont = newFont
                    case 6: settings.questionInstructionFont = newFont
                    case 7: settings.questionsFont = newFont
                    case 8: settings.questionButtonTitleFont = newFont
                    default: break
                    }
                case 2:
                    switch fontRow {
                    case 6: settings.recordingQuestionsFont = newFont
                    case 7: settings.getReadyButtonTitleFont = newFont
                    case 8: settings.doneButtonTitleFont = newFont
                    case 9: settings.recordingHeaderTitleFont = newFont
                    case 10: settings.nextRetakeFont = newFont
                    default: break
                    }
                case 3:
                    switch fontRow {
                    case 5: settings.thanksScreenTitleFont = newFont
                    case 6: settings.thanksScreenMessageFont = newFont
                    case 7: settings.thanksScreenButtonTitleFont = newFont
                    default: break
                    }
                default: break
            }
            
            self?.settings = settings
            self?.saveSettingsToAdminFolder()
            self?.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // Dismiss font picker and show size picker
        viewController.dismiss(animated: true) {
            self.present(alert, animated: true)
        }
    }
    
    func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
        viewController.dismiss(animated: true)
    }
}
