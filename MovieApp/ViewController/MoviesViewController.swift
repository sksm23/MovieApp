//
//  ViewController.swift
//  MovieApp
//
//  Created by Sunil Kumar on 03/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import UIKit

enum LayoutType {
    case list
    case grid
}

class MoviesViewController: BaseVC {
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Stored Properties
    
    private var collectionView: UICollectionView!
    private var changeLayoutBarButtonItem: UIBarButtonItem!
    private var tableViewRefreshControl: UIRefreshControl!
    private var collectionViewRefreshControl: UIRefreshControl!
    private var tableViewDataSource = MoviesTableViewDataSource()
    private var collectionViewDataSource = MoviesCollectionViewDataSource()
    private var errorBannerView: UIView!
    var endpoint = ""
    private var movieAPI: MovieDBApiManager!
    private var movies: [Movie] = []
    
    // MARK: - Property Observers
    
    private var filteredMovies: [Movie] = [] {
        didSet {
            tableViewDataSource.movies = filteredMovies
            collectionViewDataSource.movies = filteredMovies
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    private var displayType: LayoutType = .list {
        didSet {
            switch displayType {
            case .list:
                self.tableView.isHidden = false
                self.collectionView.isHidden = true
            case .grid:
                self.tableView.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }
    
    private var isErrorBannerDisplayed: Bool! {
        didSet {
            errorBannerView.isHidden = !isErrorBannerDisplayed
        }
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieAPI = MovieDBApiManager(endpoint: endpoint)
        movieAPI.delegate = self
        setupViews()
        fetchDataFromWeb()
        isErrorBannerDisplayed = false
        displayType = .list
        searchBar.delegate = self
        //tableView.rowHeight = UITableView.automaticDimension
        //tableView.estimatedRowHeight = UITableView.automaticDimension
        //tableView.prefetchDataSource = self
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "wall") )
        collectionView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "wall") )
        
    }
    
    // MARK: - Target Action
    
    @objc private func switchLayout() {
        switch displayType {
        case .grid:
            changeLayoutBarButtonItem.image = #imageLiteral(resourceName: "Grid")
            displayType = .list
        case .list:
            changeLayoutBarButtonItem.image = #imageLiteral(resourceName: "List")
            displayType = .grid
        }
    }
    
    @objc private func refreshData() {
        fetchDataFromWeb()
    }
}

// MARK: - TheMovieDbApi Delegate

extension MoviesViewController: MovieDBApiDelegate {
    
    func movieDBApi(didFinishUpdatingMovies movies: [Movie]) {
        hideHud()
        self.movies = movies
        self.filteredMovies = movies
        DispatchQueue.main.async {
            self.tableViewRefreshControl.endRefreshing()
            self.collectionViewRefreshControl.endRefreshing()
        }
        isErrorBannerDisplayed = false
    }
    
    func movieDBApi(didFailWithError error: Error) {
        hideHud()
        DispatchQueue.main.async {
            self.tableViewRefreshControl.endRefreshing()
            self.collectionViewRefreshControl.endRefreshing()
        }
        isErrorBannerDisplayed = true
    }
}

// MARK: - Network Requests

extension MoviesViewController {
    
    private func fetchDataFromWeb() {
        showHud()
        movieAPI.startUpdatingMovies()
    }
}

// MARK: - SearchBar Delegate

extension MoviesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies :  movies.filter {($0.title ?? "").range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        filteredMovies = movies
        searchBar.resignFirstResponder()
    }
}

// MARK: - Navigation

extension MoviesViewController {
    
    private func pushToDetailVC(with indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "movieDetailVC") as? MovieDetailViewController else { return }
        detailVC.movie = filteredMovies[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TableView Delegate

extension MoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        pushToDetailVC(with: indexPath)
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
}

// MARK: - CollectionView Delegate

extension MoviesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushToDetailVC(with: indexPath)
    }
}

// MARK: - Helpers

extension MoviesViewController {
    
    private func setupViews() {
        setupErrorBannerView()
        setupCollectionView()
        setupTableView()
        setupRefreshControls()
        setupChangeLayoutBarButton()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: GridLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(MovieCollectionCell.self, forCellWithReuseIdentifier: "movieCollectionCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = collectionViewDataSource
        self.view.addSubview(collectionView)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
    }
    
    private func setupRefreshControls() {
        collectionViewRefreshControl = UIRefreshControl()
        collectionViewRefreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView.insertSubview(collectionViewRefreshControl, at: 0)
        
        tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        tableView.insertSubview(tableViewRefreshControl, at: 0)
    }
    
    private func setupChangeLayoutBarButton() {
        changeLayoutBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Grid"), style: .plain, target: self, action: #selector(self.switchLayout))
        navigationItem.rightBarButtonItem = changeLayoutBarButtonItem
    }
    
    private func setupErrorBannerView() {
        let errorView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        errorView.backgroundColor = .darkGray
        let errorLabel = UILabel(frame: CGRect(x: errorView.bounds.origin.x + 8, y: errorView.bounds.origin.y + 8, width: errorView.bounds.width - 8, height: errorView.bounds.height - 8))
        errorLabel.textColor = .white
        let mutableString = NSMutableAttributedString(attributedString: NSAttributedString(string: "   ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        mutableString.append(NSAttributedString(string: "Network Error", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.white]))
        errorLabel.attributedText = mutableString
        errorLabel.textAlignment = .center
        errorView.addSubview(errorLabel)
        errorBannerView = errorView
        self.view.addSubview(errorBannerView)
    }
}
