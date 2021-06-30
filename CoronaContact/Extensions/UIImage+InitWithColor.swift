//
//  UIImage+InitWithColor.swift
//  CoronaContact
//

import Foundation
import UIKit

public extension UIImage {
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 32, height: 32)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
