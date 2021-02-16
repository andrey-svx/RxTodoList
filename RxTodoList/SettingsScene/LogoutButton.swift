import UIKit

@IBDesignable
class LogoutButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            if let cgColor = layer.borderColor {
                return UIColor(cgColor: cgColor)
            } else {
                return .clear
            }
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }

}
