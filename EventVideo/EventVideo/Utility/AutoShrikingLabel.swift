//
//  AutoShrikingLabel.swift
//  EventVideo
//
//  Created by JayR Atamosa on 6/12/25.
//

import UIKit

class AutoShrinkLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustFontSizeToFitMultiline()
    }

    private func adjustFontSizeToFitMultiline() {
        guard let text = self.text, !text.isEmpty else { return }

        let maxFontSize: CGFloat = self.font.pointSize
        let minFontSize: CGFloat = 10
        let constraintSize = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)

        for fontSize in stride(from: maxFontSize, to: minFontSize, by: -1) {
            let font = self.font.withSize(fontSize)
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let boundingBox = text.boundingRect(with: constraintSize,
                                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                attributes: attributes,
                                                context: nil)

            if boundingBox.height <= self.bounds.height {
                self.font = font
                break
            }
        }
    }
}
