//
//  NewsTableViewCell.swift
//  News
//
//  Created by Юрий Филатов on 05.02.2022.
//

import UIKit

protocol NewsTableViewCellViewModelProtocol: AnyObject{
    var title: String {get}
    var subtitle: String {get}
    var imageURL: URL? {get}
    var url: String? {get}
    var imageData: Data? {get set}
    var counter: Int {get set}
    func getImage(completion: @escaping (UIImage)->())
}

class NewsTableViewCellViewModel: NewsTableViewCellViewModelProtocol {
    private var article: Article
    
    var title: String {
        article.title
    }
    var subtitle: String {
        article.description ?? "No Description"
    }
    var imageURL: URL? {
        URL(string: article.urlToImage ?? "")
    }
    var url: String? {
        article.url
    }
    var imageData: Data? = nil
    
    private enum SettingsKey: String {
        case counter
    }
    
    
    var counter: Int {
        set {
            UserDefaults.standard.setValue(newValue, forKey: SettingsKey.counter.rawValue)
        }
        get {
            let key = SettingsKey.counter.rawValue
            return UserDefaults.standard.integer(forKey: key)
        }
    }
    
    func getImage(completion: @escaping (UIImage)->()){
        if let imageData = imageData {
            completion(UIImage(data: imageData) ?? UIImage())
        } else if let url = imageURL{
            APICaller.shared.getImage(url: url) {[weak self] data in
                guard let self = self else {return}
                self.imageData = data
                completion(UIImage(data: data) ?? UIImage())
            }
        }
    }
    
    init(article: Article) {
        self.article = article
    }
}

class NewsTableViewCell: UITableViewCell {
    static let identifier = "NewsTableViewCell"
    
    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let newsSubtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var tupCounterLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 10, weight: .light)
        return label
    }()
    
    weak var viewModel: NewsTableViewCellViewModelProtocol? {
        didSet{
            guard let viewModel = viewModel else {
                return
            }
            configure(with: viewModel)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsImageView)
        contentView.addSubview(newsSubtitleLabel)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(tupCounterLabel)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTitleLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: contentView.frame.size.width - 170 ,
            height: contentView.frame.size.height/2
        )
        
        newsSubtitleLabel.frame = CGRect(
            x: 10,
            y: 70,
            width: contentView.frame.size.width - 170 ,
            height: 70
        )
        
        newsImageView.frame = CGRect(
            x: contentView.frame.size.width - 150,
            y: 5,
            width: 140,
            height: contentView.frame.size.height - 10
        )
        
        tupCounterLabel.frame = CGRect(
            x: 10,
            y: 105,
            width: contentView.frame.size.width - 170 ,
            height: contentView.frame.size.height/2
        )
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        newsSubtitleLabel.text = nil
        newsImageView.image = nil
        tupCounterLabel.text = nil
    }
    
    func configure(with viewModel: NewsTableViewCellViewModelProtocol) {
        newsTitleLabel.text = viewModel.title
        newsSubtitleLabel.text = viewModel.subtitle
        tupCounterLabel.text = "People viewed: \(viewModel.counter)"
        
        viewModel.getImage {[weak self] image in
            DispatchQueue.main.async {
                self?.newsImageView.image = image
            }
        }
    }
    
    func addCount(){
        viewModel?.counter += 1
        tupCounterLabel.text = "People viewed: \(viewModel?.counter ?? 0)"
    }
}
