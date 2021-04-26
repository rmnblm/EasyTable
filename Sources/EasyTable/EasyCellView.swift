// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

protocol EasyCellDelegate: class {
    func easyCell(_ cell: EasyCellView, didToggleSwitch isOn: Bool)
    func easyCell(_ cell: EasyCellView, didEndEditingTextField value: String?)
}

public class EasyCellView: UITableViewCell {

    weak var delegate: EasyCellDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(didTriggerPrimaryActionInTextField), for: .primaryActionTriggered)
        return textField
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var tapTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.addTarget(self, action: #selector(didToggleSwitch), for: .valueChanged)
        return control
    }()

    private var stackViewTrailingConstraint: NSLayoutConstraint?
    private var stackViewLeadingToIconConstraint: NSLayoutConstraint?
    private var stackViewLeadingToContentConstraint: NSLayoutConstraint?

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        let iconTopAnchor = iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        iconTopAnchor.priority = .defaultLow
        iconTopAnchor.isActive = true

        let iconBottomAnchor = iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        iconBottomAnchor.priority = .defaultLow
        iconBottomAnchor.isActive = true

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackViewLeadingToContentConstraint = stackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor)
        stackViewLeadingToContentConstraint?.isActive = true
        stackViewLeadingToIconConstraint = stackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8)
        stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor)
        stackViewTrailingConstraint?.isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        contentView.addSubview(tapTitleLabel)
        tapTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        tapTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        tapTitleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        tapTitleLabel.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
    }

    required public init?(coder: NSCoder) { nil }

    override public func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        accessoryView = nil
        selectionStyle = .default

        stackView.isHidden = false
        stackView.axis = .horizontal

        iconImageView.image = nil
        iconImageView.highlightedImage = nil

        titleLabel.text = nil
        subtitleLabel.text = nil

        tapTitleLabel.text = nil
        tapTitleLabel.isHidden = true

        textField.removeFromSuperview()

        stackViewTrailingConstraint?.constant = 0
        stackViewLeadingToIconConstraint?.isActive = false
        stackViewLeadingToContentConstraint?.isActive = true
    }

    func setRow(_ row: EasyRow) {

        if let icon = row.icon {
            iconImageView.image = icon.image
            iconImageView.highlightedImage = icon.highlightedImage
            stackViewLeadingToIconConstraint?.isActive = true
            stackViewLeadingToContentConstraint?.isActive = false
        }

        switch row.style {
        case .title(let title):
            titleLabel.text = title
        case .value(let title, let subtitle):
            titleLabel.text = title
            subtitleLabel.text = subtitle
        case .subtitle(let title, let subtitle):
            stackView.axis = .vertical
            titleLabel.text = title
            subtitleLabel.text = subtitle
        case .button(let title):
            stackView.isHidden = true
            tapTitleLabel.isHidden = false
            tapTitleLabel.text = title
            selectionStyle = .none
        case .userInput(let value, let placeholder, _):
            stackView.addArrangedSubview(textField)
            textField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true
            textField.placeholder = placeholder
            textField.text = value
        case .view:
            fatalError("Should not come here because .view(UIView) is handled by EasyCellHostView")
        }

        switch row.accessory {
        case .none:
            break
        case .disclosure:
            accessoryType = .disclosureIndicator
            stackViewTrailingConstraint?.constant = -16
        case .toggle(let value, _):
            accessoryView = switchControl
            switchControl.isOn = value
            stackViewTrailingConstraint?.constant = -32
        }
    }

    @objc private func didToggleSwitch(_ sender: UISwitch) {
        delegate?.easyCell(self, didToggleSwitch: sender.isOn)
    }

    @objc private func didTriggerPrimaryActionInTextField(_ textField: UITextField) {
        textField.resignFirstResponder()
        delegate?.easyCell(self, didEndEditingTextField: textField.text)
    }
}
