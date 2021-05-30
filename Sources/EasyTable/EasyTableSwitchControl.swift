// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

public protocol EasyTableSwitchControl: UIView {
    var isOn: Bool { get set }
    var didToggleSwitch: (() -> Void)? { get set }
}


#if os(iOS)
public final class DefaultSwitchControl: UISwitch, EasyTableSwitchControl {
    public init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    public required init?(coder: NSCoder) { nil }
    
    @objc private func valueChanged() {
        didToggleSwitch?()
    }
    
    public var didToggleSwitch: (() -> Void)?
}
#else
public final class DefaultSwitchControl: UILabel, EasyTableSwitchControl {
    public var isOn: Bool = false {
        didSet { text = isOn ? "On" : "Off" } // TODO: Must be localized
    }
    public var didToggleSwitch: (() -> Void)?
}
#endif
