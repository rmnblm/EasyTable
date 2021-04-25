// Copyright © 2021 Homebrew GmbH. All rights reserved.

import UIKit

final class EasyCellHostView: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom),
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top)
        ])
    }

    private func resetCell() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}
