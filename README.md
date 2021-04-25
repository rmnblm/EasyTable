# EasyTable

Easy static tables, written in Swift.

## Getting Started

``` swift
final class SettingsViewController: ViewController {

    private lazy var easyTable = EasyTableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add easyTable to view
        
        easyTable.sections = [
            .init(
                header: "Section 1",
                rows: [
                    .init(style: .title("Row 1"), accessory: .disclosure) { [weak self] in
                        self?.navigationController?.pushViewController(ViewController(), animated: true)
                    }
                ]
            ),
            .init(
                header: "About",
                rows: [
                    .init(style: .title("Support")),
                    .init(style: .title("Follow Us")),
                    .init(style: .title("Acknowledgements"))
                ],
                footer: "Version 1.0"
            )
        ]
    }
}
```
