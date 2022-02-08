//
//  ViewController.swift
//  News
//
//  Created by Юрий Филатов on 04.02.2022.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self,
                       forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    private var viewModels = [NewsTableViewCellViewModelProtocol]()
    
    
    //MARK: Жест обновить страницу
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        title = "Russian News"
        navigationController?.navigationBar.barTintColor = .red
        
        //MARK: кнопка обновить страницу
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(handleRefresh))
        self.navigationItem.rightBarButtonItem = refreshButton
        navigationController?.navigationBar.tintColor = .black
        
        //MARK: Кнопка добавить в список для чтения
        let bookmarkButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.bookmarks, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = bookmarkButton
        
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        APICaller.shared.getTopStories{ [weak self] result in
            switch result {
            case .success(let articles):
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        article: $0
                    )
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
        }
        
        //MARK: проверка сети
        
        if !NetworkMonitor.shared.isConnected { disconectingAlert() }
        
    }
    
    override func  viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: Таблица
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath
        ) as? NewsTableViewCell else {
            fatalError()
        }
        cell.viewModel = viewModels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell else {return}
        cell.addCount()
        
        let articleUrl = cell.viewModel?.url ?? ""
        
        guard let url = URL(string: articleUrl) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    @objc func handleRefresh() {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func disconectingAlert(){
        let alert = UIAlertController(title: "Нет подключения к интернету", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: { action in
            print("Нажато переподключиться")
        }))
        present(alert, animated: true)
    }
}

