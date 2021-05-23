// Copyright © 2021 Roman Blum. All rights reserved.

import Foundation
import UIKit

public struct EasySection {

    public typealias ConfigurationHandler = (UITableViewHeaderFooterView) -> Void

    public let identifier: String
    public var header: Style?
    public var rows: [EasyRow]
    public var footer: Style?

    public init(identifier: String? = nil, header: Style = .none, rows: [EasyRow], footer: Style = .none) {
        self.identifier = identifier ?? UUID().uuidString
        self.header = header
        self.rows = rows
        self.footer = footer
    }

    public enum Style {
        case none
        case title(String, configuration: ConfigurationHandler? = nil, height: CGFloat? = nil)
    }
}
