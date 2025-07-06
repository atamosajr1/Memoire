//
//  CustomUITableViewCell.swift
//  EventVideo
//
//  Created by JayR Atamosa on 1/15/25.
//

import UIKit

class TextViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtValue: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtValue.layer.borderColor = UIColor.gray.cgColor
        txtValue.layer.borderWidth = 1
    }

    func configure(title: String, value: String) {
        lblTitle.text = title
        txtValue.text = value
    }
}

class ImagePickerViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelect: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String) {
        lblTitle.text = title
    }
}

class ColorPickerViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var vwSelectedColor: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String, selectedColor: String) {
        lblTitle.text = title
        vwSelectedColor.backgroundColor = UIColor.fromRGBString(selectedColor)
    }
}

class SliderViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String, value: Double) {
        lblTitle.text = title
        slider.value = Float(value)
        lblValue.text = String(format: "%.2f", value)
    }
}

class FontPickerViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String, font: String) {
        lblTitle.text = title
        lblValue.text = font
    }
}

class ZoomPickerViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String, zoom: String) {
        lblTitle.text = title
        lblValue.text = zoom
    }
}

class AddQuestionViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String) {
        lblTitle.text = title
    }
}
