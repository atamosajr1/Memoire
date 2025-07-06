//
//  UIColor.swift
//  EventVideo
//
//  Created by JayR Atamosa on 1/14/25.
//
import UIKit

extension UIColor {
    static func fromRGBString(_ rgbString: String) -> UIColor? {
            let components = rgbString
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            if components.count == 4,
               let red = Float(components[0]),
               let green = Float(components[1]),
               let blue = Float(components[2]),
               let alpha = Float(components[3]) {
                
                return UIColor(
                    red: CGFloat(red / 255.0),
                    green: CGFloat(green / 255.0),
                    blue: CGFloat(blue / 255.0),
                    alpha: CGFloat(alpha)
                )
            }
            
            if rgbString == "transparent" {
                return UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            }
            
            return nil
        }
    
    func toRGBString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(Int(red * 255)),\(Int(green * 255)),\(Int(blue * 255)),\(alpha)"
    }
}
