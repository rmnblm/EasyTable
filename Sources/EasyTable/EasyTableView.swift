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
        tableView.register(EasyTableCell.self, forCellReuseIdentifier: "EasyTableCell")
        tableView.register(EasyTableHostCell.self, forCellReuseIdentifier: "EasyTableHostCell")
        tableView.register(EasyTableHeaderFooterHostView.self, forHeaderFooterViewReuseIdentifier: "EasyTableHeaderFooterHostView")
        return tableView
    }()

    public var defaultRowHeight: CGFloat?

    public override var backgroundColor: UIColor? {
        didSet { tableView.backgroundColor = backgroundColor }
    }

    #if os(iOS)
    public var separatorColor: UIColor? {
        get { tableView.separatorColor }
        set { tableView.separatorColor = newValue }
    }
    #endif

    public var isScrollEnabled: Bool {
        get { tableView.isScrollEnabled }
        set { tableView.isScrollEnabled = newValue }
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

    public func reloadRow(_ row: EasyRow, with animation: UITableView.RowAnimation = .automatic) {
        reloadSection(identifier: row.identifier, with: animation)
    }
    
    public func reloadRow(identifier: String, with animation: UITableView.RowAnimation = .automatic) {
        for (i, section) in sections.enumerated() {
            for (j, row) in section.rows.enumerated() where row.identifier == identifier {
                let indexPath = IndexPath(row: j, section: i)
                tableView.reloadRows(at: [indexPath], with: animation)
            }
        }
    }

    public func reloadSection(_ section: EasySection, with animation: UITableView.RowAnimation = .automatic) {
        reloadSection(identifier: section.identifier, with: animation)
    }

    public func reloadSection(identifier: String, with animation: UITableView.RowAnimation = .automatic) {
        for (i, section) in sections.enumerated() where section.identifier == identifier {
            tableView.reloadSections(.init(integer: i), with: animation)
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
    public func easyCell(_ cell: EasyTableCell, didToggleSwitch isOn: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let row = sections[indexPath.section].rows[indexPath.row]
        if case let .toggle(_, action) = row.accessory {
            action(isOn)
            row.accessory = .toggle(value: isOn, action)
        }
    }

    public func easyCell(_ cell: EasyTableCell, didEndEditingTextField value: String?) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let row = sections[indexPath.section].rows[indexPath.row]
        if case let .userInput(title, _, placeholder, action) = row.style {
            action(value)
            row.style = .userInput(title: title, value: value, placeholder: placeholder, action)
        }
    }
}

extension EasyTableView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].rows[indexPath.row].action?()
    }

    #if os(iOS)
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        switch row.accessory {
        case .info(let action),
             .infoDisclosure(let action):
            action?()
        default:
            break
        }
    }
    #endif

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].rows[indexPath.row]
        return defaultRowHeight ?? row.height ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].rows[indexPath.row]
        return defaultRowHeight ?? row.height ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = sections[section].header else { return .leastNonzeroMagnitude }
        switch header {
        case .none:
            return .leastNonzeroMagnitude
        case .title(_, _, let height):
            return height ?? UITableView.automaticDimension
        case .view:
            return UITableView.automaticDimension
        }
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = sections[section].footer else { return .leastNonzeroMagnitude }
        switch footer {
        case .none:
            return .leastNonzeroMagnitude
        case .title(_, _, let height):
            return height ?? UITableView.automaticDimension
        case .view:
            return UITableView.automaticDimension
        }
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        switch sections[section].header {
        case .title(_, let configurationHandler, _):
            configurationHandler?(headerView)
        default:
            headerView.textLabel?.font = .systemFont(ofSize: 14)
        }
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        switch sections[section].header {
        case .title(_, let configurationHandler, _):
            configurationHandler?(footerView)
        default:
            footerView.textLabel?.font = .systemFont(ofSize: 13)
        }
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? EasyTableCell)?.delegate = nil
    }
}

extension EasyTableView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section].header {
        case .view(let view, let insets):
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EasyTableHeaderFooterHostView") as? EasyTableHeaderFooterHostView else {
                fatalError("Did not register `EasyTableHeaderFooterHostView`.")
            }
            headerView.setView(view, insets: insets)
            return headerView
        default:
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section].header {
        case .title(let title, _, _):
            return title
        default:
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch sections[section].footer {
        case .view(let view, let insets):
            guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EasyTableHeaderFooterHostView") as? EasyTableHeaderFooterHostView else {
                fatalError("Did not register `EasyTableHeaderFooterHostView`.")
            }
            footerView.setView(view, insets: insets)
            return footerView
        default:
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch sections[section].footer {
        case .title(let title, _, _):
            return title
        default:
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        switch row.style {
        case .view(let view, let insets):
            guard let cellView = tableView.dequeueReusableCell(withIdentifier: "EasyTableHostCell", for: indexPath) as? EasyTableHostCell else {
                fatalError("Did not register `EasyTableHostCell`.")
            }
            cellView.setView(view, insets: insets)
            return cellView
        default:
            guard let cellView = tableView.dequeueReusableCell(withIdentifier: "EasyTableCell", for: indexPath) as? EasyTableCell else {
                fatalError("Did not register `EasyTableCell`.")
            }
            cellView.delegate = self
            cellView.setRow(row)
            return cellView
        }
    }
}
