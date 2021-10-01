import UIKit
import RxSwift
import ThemeKit
import SnapKit
import SectionsTableView
import ComponentKit

class MarketDiscoveryViewController: ThemeSearchViewController {
    private let viewModel: MarketDiscoveryViewModel
    private let disposeBag = DisposeBag()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let tableView = SectionsTableView(style: .grouped)

    private var discoveryViewItems = [MarketDiscoveryViewModel.DiscoveryViewItem]()
    private var searchViewItems = [MarketDiscoveryViewModel.SearchViewItem]()

    private var isLoaded = false

    init(viewModel: MarketDiscoveryViewModel) {
        self.viewModel = viewModel

        super.init(scrollViews: [collectionView, tableView])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "market_discovery.title".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "market_discovery.filters".localized, style: .plain, target: self, action: #selector(onTapFilters))

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        collectionView.backgroundColor = .clear

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MarketDiscoveryCell.self, forCellWithReuseIdentifier: String(describing: MarketDiscoveryCell.self))
        collectionView.register(MarketDiscoveryTitleCell.self, forCellWithReuseIdentifier: String(describing: MarketDiscoveryTitleCell.self))

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.registerCell(forClass: G4Cell.self)
        tableView.sectionDataSource = self

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive

        subscribe(disposeBag, viewModel.discoveryViewItemsDriver) { [weak self] in self?.sync(discoveryViewItems: $0) }
        subscribe(disposeBag, viewModel.searchViewItemsDriver) { [weak self] in self?.sync(searchViewItems: $0) }

        isLoaded = true
    }

    @objc private func onTapFilters() {
        // todo
    }

    private func sync(discoveryViewItems: [MarketDiscoveryViewModel.DiscoveryViewItem]?) {
        if let discoveryViewItems = discoveryViewItems {
            self.discoveryViewItems = discoveryViewItems
            collectionView.reloadData()
            collectionView.isHidden = false
        } else {
            collectionView.isHidden = true
        }
    }

    private func sync(searchViewItems: [MarketDiscoveryViewModel.SearchViewItem]?) {
        if let searchViewItems = searchViewItems {
            self.searchViewItems = searchViewItems
            reloadTable()
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }

    override func onUpdate(filter: String?) {
        viewModel.onUpdate(filter: filter ?? "")
    }

    private func reloadTable() {
        tableView.buildSections()

        if isLoaded {
            tableView.reload()
        }
    }

}

extension MarketDiscoveryViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 1 : discoveryViewItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: indexPath.section == 0 ? MarketDiscoveryTitleCell.self : MarketDiscoveryCell.self), for: indexPath)
    }

}

extension MarketDiscoveryViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MarketDiscoveryCell {
            cell.set(viewItem: discoveryViewItems[indexPath.item])
        }
    }

}

extension MarketDiscoveryViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        indexPath.section == 0 ?
                CGSize(width: collectionView.width, height: .heightSingleLineCell) :
                CGSize(width: (collectionView.width - .margin16 * 2 - .margin12) / 2, height: 128)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        section == 0 ?
                .zero :
                UIEdgeInsets(top: .margin12, left: .margin16, bottom: .margin32, right: .margin16)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        .margin12
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .margin12
    }

}

extension MarketDiscoveryViewController: SectionsDataSource {

    func buildSections() -> [SectionProtocol] {
        [
            Section(
                    id: "coins",
                    headerState: .margin(height: .margin12),
                    footerState: .margin(height: .margin32),
                    rows: searchViewItems.enumerated().map { index, viewItem in
                        let isLast = index == searchViewItems.count - 1

                        return Row<G4Cell>(
                                id: "coin_\(viewItem.uid)",
                                hash: "\(viewItem.favorite)",
                                height: .heightDoubleLineCell,
                                autoDeselect: true,
                                bind: { cell, _ in
                                    cell.set(backgroundStyle: .transparent, isLast: isLast)
                                    cell.setTitleImage(urlString: viewItem.imageUrl, placeholder: UIImage(named: viewItem.placeholderImageName))
                                    cell.title = viewItem.name
                                    cell.subtitle = viewItem.code
                                    cell.valueImage = UIImage(named: "star_20")
                                },
                                action: { [weak self] _ in
                                    // todo
                                }
                        )
                    }
            )
        ]
    }

}
