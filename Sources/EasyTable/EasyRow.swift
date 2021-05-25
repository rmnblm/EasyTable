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

    public let identifier: String
    public var style: Style
    public var accessory: Accessory
    public var icon: Icon?
    public var action: TapActionHandler?
    public var height: CGFloat?

    public init(identifier: String? = nil, style: Style, accessory: Accessory = .none, icon: Icon? = nil, height: CGFloat? = nil, action: TapActionHandler? = nil) {
        self.identifier = identifier ?? UUID().uuidString
        self.style = style
        self.accessory = accessory
        self.icon = icon
        self.action = action
        self.height = height ?? style.defaultHeight
    }

    public enum Style {
        case text(String, numberOfLines: Int = 1)
        case subtitle(title: String, subtitle: String?)
        case value(title: String, value: String?)
        case button(title: String)
        case userInput(title: String, value: String?, placeholder: String, TextFieldEndEditingHandler)
        case view(UIView, insets: UIEdgeInsets = .zero)

        var defaultHeight: CGFloat? {
            switch self {
                case .text(_, let numberOfLines):
                    return numberOfLines == 1 ? 56 : nil
                case .view: 
                    return nil
                default:
                    return 56
            }
        }
    }

    public enum Accessory {
        case none
        case disclosure
        case toggle(value: Bool, SwitchActionHandler)
        #if os(iOS)
        case info(TapActionHandler?)
        case infoDisclosure(TapActionHandler?)
        #endif
    }
}
