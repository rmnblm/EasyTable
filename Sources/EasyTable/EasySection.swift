// Copyright © 2021 Roman Blum. All rights reserved.

import Foundation

public struct EasySection {
    public let header: String?
    public let rows: [EasyRow]
    public let footer: String?

    public init(header: String? = nil, rows: [EasyRow], footer: String? = nil) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }
}
