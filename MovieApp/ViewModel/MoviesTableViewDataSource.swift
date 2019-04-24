//
//  MoviesTableViewDataSource.swift
//  MovieApp
//
//  Created by Sunil Kumar on 10/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import UIKit

class MoviesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var movies: [Movie] = []

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieTableCell", for: indexPath) as? MovieTableCell else { return UITableViewCell() }
        let movie = movies[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.overViewLabel.text = movie.overview
        cell.releaseYearLabel.text = movie.releaseDate
        cell.averageVoteLabel.text = String(format: "%.1f", movie.avgRating ?? 0)
        if let posterImageURL = movie.posterImageURLMedium {
            cell.posterImageView.downloadedFrom(url: posterImageURL)
        } else {
            cell.posterImageView.image = #imageLiteral(resourceName: "placeholderImage")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
}

/*extension MoviesTableViewDataSource: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
} */
