//
//  MoviesCollectionViewDataSource.swift
//  MovieApp
//
//  Created by Sunil Kumar on 10/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import UIKit

class MoviesCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var movies: [Movie] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionCell", for: indexPath) as? MovieCollectionCell else { return UICollectionViewCell() }
        if let posterImageURL = movies[indexPath.row].posterImageURLMedium {
            cell.posterImageView.downloadedFrom(url: posterImageURL)
        } else {
            cell.posterImageView.image = #imageLiteral(resourceName: "placeholderImage")
        }
        return cell
    }
}

/* extension MoviesCollectionViewDataSource: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
} */
