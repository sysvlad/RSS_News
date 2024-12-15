
import UIKit
import SnapKit
import RealmSwift

final class SettingsViewController: UIViewController {
    // MARK: - Properties
    
    var output: SettingsViewOutput!
    var repeatedRequestsService: RepeatedRequestsServiceProtocol!
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        output.viewIsReady()
        
    }
    
    // MARK: - Private Methods
    
    // MARK: - Constants
    
    private enum Constants {
    }
    
    // MARK: - Variables
    
    private lazy var tf: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.delegate = self
        return tf
    }()
    
    private lazy var tfConfirmButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Submit interval", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(submitIntevalButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var repeatSwitch: UISwitch = {
       let switchItem = UISwitch()
        switchItem.addTarget(
            self,
            action: #selector(
                switchValueDidChange
            ),
            for: .valueChanged
        )
        return switchItem
    }()
    
    private lazy var repqatSwitchLabel: UILabel = {
        let label = AutoLayoutLabel()
        label.text = "repeat requets"
        return label
    }()

    private let tableView = UITableView()
    
    private lazy var cacheClearButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("Claer Cache", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(submitCacheClearButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private var model: SettingsModel?
}

// MARK: - SettingsViewInput

extension SettingsViewController: SettingsViewInput {
// MARK: - Methods
    
    func update(_ model: SettingsModel) {
        self.model = model
        tf.text = model.interval
        repeatSwitch.isOn = model.periodUpdateIsOn
        tableView.reloadData()
    }

}

// MARK: - ViewConfigurable

extension SettingsViewController: ViewConfigurable {

    public func configureViews() {
        view.backgroundColor = .white
        view.addSubview(tf)
        view.addSubview(tfConfirmButton)
        view.addSubview(repeatSwitch)
        view.addSubview(repqatSwitchLabel)
        view.addSubview(cacheClearButton)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
        view.addSubview(tableView)
    }

    public func configureConstraints() {
        tf.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().offset(30)
            $0.top.equalToSuperview().offset(120)
        }
        
        tfConfirmButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.height.equalTo(40)
            $0.leading.equalTo(tf.snp.trailing).offset(30)
            $0.top.equalToSuperview().offset(120)
        }
        
        repeatSwitch.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.top.equalTo(tf.snp.bottom).offset(20)
        }
        
        repqatSwitchLabel.snp.makeConstraints {
            $0.leading.equalTo(repeatSwitch.snp.trailing).offset(30)
            $0.top.equalTo(tf.snp.bottom).offset(20)
        }
        
        cacheClearButton.snp.makeConstraints {
            $0.top.equalTo(repqatSwitchLabel.snp.bottom).offset(20)
            $0.width.equalTo(200)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(cacheClearButton.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tf.becomeFirstResponder()
    }
}

fileprivate extension SettingsViewController {
    @objc
    func submitIntevalButton() {
        guard let text = tf.text,
              tf.text != "",
              tf.text != "0" else {
            debugPrint("enter normal value")
            return
        }
        tf.resignFirstResponder()
        output.prepareInterval(text)
    }
    
    @objc
    func switchValueDidChange(sender: UISwitch) {
        output.prepareRepeatedRequestEnable(sender.isOn)
    }
    
    @objc
    func submitCacheClearButton() {
        output.clearCache()
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            output.prepareSelectedRes(index: indexPath.row)
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  model?.resValues.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        if indexPath.row == model?.resSelected {   // item needed - display checkmark
            cell.accessoryType = .checkmark
        } else {   // not needed no checkmark
            cell.accessoryType = .none
        }
        cell.textLabel?.text = model?.resValues[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

}
