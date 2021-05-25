# EasyTable

Easy static tables, written in Swift.

## Getting Started

``` swift
final class ViewController: UIViewController {

    private lazy var easyTable = EasyTableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add easyTable to view
        
        easyTable.sections = [
            .init(
                header: .title("Section 1"),
                rows: [
                    .init(style: .text("Row 1"), accessory: .disclosure) { [weak self] in
                        self?.navigationController?.pushViewController(ViewController(), animated: true)
                    }
                ]
            ),
            .init(
                header: .view(UILabel()),
                rows: [
                    .init(style: .text("Support")),
                    .init(style: .text("Follow Us")),
                    .init(style: .text("Acknowledgements"))
                ],
                footer: .title("Version 1.0")
            )
        ]
    }
}
```
