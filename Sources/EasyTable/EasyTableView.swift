// Copyright © 2021 Roman Blum. All rights reserved.

import UIKit

public class EasyTableView: UIView {

    public var sections: [EasySection] = [] {
        didSet { tableView.reloadData() }
    }
    
    public var tableHeaderView: UIView? {
        get { tableView.tableHeaderView }
        set { tableView.tableHeaderView = newValue }
    }
    
    public var tableFooterView: UIView? {
        get { tableView.tableFooterView }
        set { tableView.tableFooterView = newValue }
    }

    private let style: UITableView.Style
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: style)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.register(EasyCellView.self, forCellReuseIdentifier: "EasyCellView")
        tableView.register(EasyCellHostView.self, forCellReuseIdentifier: "EasyCellHostView")
        return tableView
    }()

    public var defaultRowHeight: CGFloat?

    public override var backgroundColor: UIColor? {
        didSet { tableView.backgroundColor = backgroundColor }
    }

    public var separatorColor: UIColor? {
        get { tableView.separatorColor }
        set { tableView.separatorColor = newValue }
    }

    public init(style: UITableView.Style = .grouped) {
        self.style = style
        super.init(frame: .zero)
        setupView()
        #if os(iOS)
        setupObservers()
        #endif
    }

    required public init?(coder: NSCoder) { nil }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func reloadRow(identifier: String, style: EasyRow.Style, with animation: UITableView.RowAnimation = .automatic) {
        for (i, section) in sections.enumerated() {
            for (j, row) in section.rows.enumerated() {
                if row.identifier == identifier {
                    let indexPath = IndexPath(row: j, section: i)
                    sections[i].rows[j].style = style
                    tableView.reloadRows(at: [indexPath], with: animation)
                    return
                }
            }
        }
    }
    
    private func setupView() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    #if os(iOS)
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) { self.tableView.contentInset = .zero }
    }
    #endif
}

extension EasyTableView: EasyCellDelegate {
    public func easyCell(_ cell: EasyCellView, didToggleSwitch isOn: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let row = sections[indexPath.section].rows[indexPath.row]
        if case let .toggle(_, action) = row.accessory {
            action(isOn)
            row.accessory = .toggle(value: isOn, action)
        }
    }

    public func easyCell(_ cell: EasyCellView, didEndEditingTextField value: String?) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let row = sections[indexPath.section].rows[indexPath.row]
        if case let .userInput(title, _, placeholder, action) = row.style {
            action(value)
            row.style = .userInput(title:  title, value: value, placeholder: placeholder, action)
        }
    }
}

extension EasyTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].rows[indexPath.row].action?()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].rows[indexPath.row]
        return row.height ?? defaultRowHeight ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let hasHeader = sections[section].header != nil
        return hasHeader ? UITableView.automaticDimension : .leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let hasFooter = sections[section].footer != nil
        return hasFooter ? UITableView.automaticDimension : .leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.font = .systemFont(ofSize: 14)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        footerView.textLabel?.font = .systemFont(ofSize: 13)
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? EasyCellView)?.delegate = nil
    }
}

extension EasyTableView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        switch row.style {
        case .view(let view, let insets):
            guard let cellView = tableView.dequeueReusableCell(withIdentifier: "EasyCellHostView", for: indexPath) as? EasyCellHostView else {
                fatalError("Did not register `EasyCellHostView`.")
            }
            cellView.setView(view, insets: insets)
            return cellView
        default:
            guard let cellView = tableView.dequeueReusableCell(withIdentifier: "EasyCellView", for: indexPath) as? EasyCellView else {
                fatalError("Did not register `EasyCellView`.")
            }
            cellView.delegate = self
            cellView.setRow(row)
            return cellView
        }
    }
}
