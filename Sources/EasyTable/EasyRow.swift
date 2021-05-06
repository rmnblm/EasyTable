// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

public class EasyRow {

    public struct Icon {
        public let image: UIImage
        public let highlightedImage: UIImage?
        
        public init(image: UIImage, highlightedImage: UIImage? = nil) {
            self.image = image
            self.highlightedImage = highlightedImage
        }
    }

    public typealias TapActionHandler = () -> Void
    public typealias SwitchActionHandler = (Bool) -> Void
    public typealias TextFieldEndEditingHandler = (String?) -> Void

    public var style: Style
    public var accessory: Accessory
    public var icon: Icon?
    public var action: TapActionHandler?
    public var height: CGFloat?

    public init(style: Style, accessory: Accessory = .none, icon: Icon? = nil, action: TapActionHandler? = nil, height: CGFloat? = 56) {
        self.style = style
        self.accessory = accessory
        self.icon = icon
        self.action = action
        self.height = height
    }

    public enum Style {
        case title(String)
        case subtitle(title: String, subtitle: String?)
        case value(title: String, value: String?)
        case button(title: String)
        case userInput(title: String, value: String?, placeholder: String, TextFieldEndEditingHandler)
        case view(UIView, insets: UIEdgeInsets = .zero)
    }

    public enum Accessory {
        case none
        case disclosure
        case toggle(value: Bool, SwitchActionHandler)
    }
}
