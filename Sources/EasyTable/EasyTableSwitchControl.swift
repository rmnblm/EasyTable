// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

public protocol EasyTableSwitchControl: UIView {
    var isOn: Bool { get set }
    var didToggleSwitch: (() -> Void)? { get set }
}


#if os(iOS)
final class DefaultSwitchControl: UISwitch, EasyTableSwitchControl {
    init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) { nil }
    
    @objc private func valueChanged() {
        didToggleSwitch?()
    }
    
    var didToggleSwitch: (() -> Void)?
}
#else
final class DefaultSwitchControl: UILabel, EasyTableSwitchControl {
    var isOn: Bool = false {
        didSet { text = isOn ? "On" : "Off" } // TODO: Must be localized
    }
    var didToggleSwitch: (() -> Void)?
}
#endif
