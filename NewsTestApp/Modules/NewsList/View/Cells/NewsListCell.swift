//
//  NewsListCell.swift
//  NewsTestApp
//
//  Created by Vlad Sys on 9.12.24.
//

import UIKit
import SnapKit
import SDWebImage

class NewsListCell: UITableViewCell {
    static let identifier: String = "NewsListCell"

    private lazy var label: UILabel = {
        let label = AutoLayoutLabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let image = UIImageView()
    private lazy var dateLabel: UILabel = {
        let label = AutoLayoutLabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = AutoLayoutLabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var resourseLabel: UILabel = {
        let label = AutoLayoutLabel()
        label.numberOfLines = 0
        return label
    }()
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    var cellId: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(with model: RealmRSSFeedMo) {
        cellId = model.id
        let transformer = SDImageResizingTransformer(size: CGSize(width: 40, height: 40), scaleMode: .fill)
        image.sd_setImage(with: URL(string: model.enclosure), placeholderImage: nil, context: [.imageTransformer: transformer])
        label.text = model.title
        descriptionLabel.isHidden = !model.isSelected
        descriptionLabel.text = model.descriptionValue
        dateLabel.text = model.pubDate.toString()
        resourseLabel.text = model.resource
        contentView.backgroundColor = model.isReaded ? .red : .white
    }
    
    override func prepareForReuse() {
        descriptionLabel.isHidden = true
    }
}

extension NewsListCell: ViewConfigurable {
    func configureViews() {
        self.contentView.addSubview(label)
        self.contentView.addSubview(image)
        self.contentView.addSubview(dateLabel)
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(resourseLabel)
        self.contentView.addSubview(descriptionStackView)
    }
    
    func configureConstraints() {
        image.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
            $0.centerY.equalToSuperview()
        }
        label.snp.makeConstraints {
            $0.leading.equalTo(image.snp.trailing).offset(20)
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(image.snp.trailing).offset(20)
            $0.top.equalTo(label.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        descriptionStackView.snp.makeConstraints {
            $0.leading.equalTo(image.snp.trailing).offset(20)
            $0.top.equalTo(dateLabel.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}
