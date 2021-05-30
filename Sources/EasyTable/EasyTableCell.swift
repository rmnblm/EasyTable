// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

protocol EasyCellDelegate: AnyObject {
    func easyCell(_ cell: EasyTableCell, didToggleSwitch isOn: Bool)
    func easyCell(_ cell: EasyTableCell, didEndEditingTextField value: String?)
}

public class EasyTableCell: UITableViewCell {

    weak var delegate: EasyCellDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, tvOS 13.0, *) {
            label.textColor = .label
        }
        else {
            label.textColor = .black
        }
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, tvOS 13.0, *) {
            label.textColor = .secondaryLabel
        }
        else {
            label.textColor = .gray
        }
        label.numberOfLines = 0
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
        stackView.spacing = 2.0
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
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public lazy var switchControl: EasyTableSwitchControl = {
        let control = DefaultSwitchControl()
        control.didToggleSwitch = didToggleSwitch
        return control
    }()

    private var stackViewTrailingConstraint: NSLayoutConstraint?

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let contentStack = UIStackView()
        contentStack.axis = .horizontal

        contentView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        stackViewTrailingConstraint = contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        stackViewTrailingConstraint?.isActive = true
        contentStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor).isActive = true
        contentStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true
        contentStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(stackView)

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
        resetCell()
    }

    func setRow(_ row: EasyRow) {
        resetCell()

        if let icon = row.icon {
            iconImageView.image = icon.image
            iconImageView.highlightedImage = icon.highlightedImage
            iconImageView.isHidden = false
        }

        switch row.style {
        case .text(let text, let numberOfLines):
            titleLabel.text = text
            titleLabel.numberOfLines = numberOfLines
            subtitleLabel.isHidden = true
        case .value(let title, let subtitle):
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.textAlignment = .right
        case .subtitle(let title, let subtitle):
            stackView.axis = .vertical
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.textAlignment = .left
            if subtitle == nil {
                subtitleLabel.isHidden = true
            }
        case .button(let title):
            stackView.isHidden = true
            tapTitleLabel.isHidden = false
            tapTitleLabel.text = title
            selectionStyle = .none
        case .userInput(let title, let value, let placeholder, _):
            titleLabel.text = title
            stackView.addArrangedSubview(textField)
            textField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true
            textField.placeholder = placeholder
            textField.text = value
        case .view:
            fatalError("Should not come here because .view(UIView) is handled by EasyTableHostCell")
        }

        switch row.accessory {
        case .none:
            break
        case .disclosure:
            accessoryType = .disclosureIndicator
        #if os(iOS)
        case .info:
            accessoryType = .detailButton
        case .infoDisclosure:
            accessoryType = .detailDisclosureButton
        #endif
        case .toggle(let value, _):
            accessoryView = switchControl
            switchControl.isOn = value
            stackViewTrailingConstraint?.constant = -32
        }
    }
    
    private func resetCell() {
        accessoryType = .none
        accessoryView = nil
        selectionStyle = .default

        stackView.isHidden = false
        stackView.axis = .horizontal

        iconImageView.image = nil
        iconImageView.highlightedImage = nil
        iconImageView.isHidden = true

        titleLabel.text = nil
        titleLabel.numberOfLines = 1
        subtitleLabel.text = nil
        subtitleLabel.isHidden = false

        tapTitleLabel.text = nil
        tapTitleLabel.isHidden = true

        textField.removeFromSuperview()

        stackViewTrailingConstraint?.constant = -20
    }

    private func didToggleSwitch() {
        delegate?.easyCell(self, didToggleSwitch: switchControl.isOn)
    }

    @objc private func didTriggerPrimaryActionInTextField(_ textField: UITextField) {
        textField.resignFirstResponder()
        delegate?.easyCell(self, didEndEditingTextField: textField.text)
    }
}
