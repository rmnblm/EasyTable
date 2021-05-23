// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

final class EasyHeaderFooterHostView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView = UIView()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }

    func setView(_ view: UIView, insets: UIEdgeInsets) {
        resetCell()
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)
        bottomConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            bottomConstraint
        ])
    }

    private func resetCell() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}
