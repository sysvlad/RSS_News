
import UIKit
import SnapKit
import RealmSwift

final class NewsListViewController: UIViewController {
    // MARK: - Properties
    
    var output: NewsListViewOutput!
    var repeatedRequestsService: RepeatedRequestsServiceProtocol!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        output.viewIsReady()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        repeatedRequestsService.addLifeCycleObservers(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)

        repeatedRequestsService.removeLifeCycleObservers()
   }
    
    // MARK: - Private Methods
    
    // MARK: - Constants
    
    private enum Constants {
    }
    
    // MARK: - Variables

    private lazy var tableView = UITableView()
    private lazy var settingsButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "settings"), for: .normal)
        button.addTarget(
            self,
            action: #selector(touchButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private var models: Results<RealmRSSFeedMo>?
}

// MARK: - NewsListViewInput

extension NewsListViewController: NewsListViewInput {
// MARK: - Methods

    func initial(_ models: Results<RealmRSSFeedMo>?) {
        self.models = models
        tableView.reloadData()
    }

    func update(_ models: NewsListModel) {
        self.models = models.models
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: models.insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        self.tableView.deleteRows(at: models.deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        self.tableView.reloadRows(at: models.modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        self.tableView.endUpdates()
    }
}

// MARK: - ViewConfigurable

extension NewsListViewController: ViewConfigurable {

    public func configureViews() {
        view.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(NewsListCell.self, forCellReuseIdentifier: NewsListCell.identifier)
        view.addSubview(tableView)
        view.addSubview(settingsButton)
    }

    public func configureConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints {
            $0.size.equalTo(80)
            $0.trailing.equalToSuperview().inset(40)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
}

// MARK: - UITableViewDelegate

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow,
           let currentCell = tableView.cellForRow(at: indexPath) as? NewsListCell,
           let cellId = currentCell.cellId {
            output.setItemSelected(id: cellId)
        }
    }
}

// MARK: - UITableViewDataSource

extension NewsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsListCell.identifier) as? NewsListCell,
           let model = models?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.updateCell(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

}

fileprivate extension NewsListViewController {
    @objc
    func touchButton() {
        output.prepareSettings()
    }
}
