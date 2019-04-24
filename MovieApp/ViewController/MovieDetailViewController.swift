//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Sunil Kumar on 10/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import UIKit
/*Movie title
 Movie poster
 Running time
 Release date
 Original Languages
 Genres
 Rating score and number of votes
 List of actor/actress (limit to 5 people) including the role name
 Synopsis
 */
class MovieDetailViewController: BaseVC {
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    // @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avgRatingLabel: UILabel!
    @IBOutlet var overViewLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var originalLanguagesLabel: UILabel!
    @IBOutlet var noOfVotesLabel: UILabel!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: contentView.frame.origin.y + contentView.frame.height)
        self.navigationItem.title = "Overview"//movie.title
        
        //set details
        overViewLabel.text = movie.overview
        titleLabel.text = movie.title
        avgRatingLabel.text = String(format: "Rating: %.1f", movie.avgRating ?? 0)
        releaseDateLabel.text = "Release Date: \(movie.releaseDate ?? "")"
        originalLanguagesLabel.text = "Language: \(movie.originalLanguages ?? "")"
        noOfVotesLabel.text = "Votes: \(movie.noOfVotes ?? 0)"

        if let smallImageURL = movie.backdropImageURLLow, let largeImageURL = movie.backdropImageURLHigh {
            setImage(with: smallImageURL, largeImageURL: largeImageURL)
        } else {
            backdropImageView.image = #imageLiteral(resourceName: "placeholderImage")
        }
    }
    
    func setImage(with smallImageURL: URL, largeImageURL: URL) {
        self.backdropImageView.alpha = 0.0
        self.backdropImageView.downloadedFrom(url: smallImageURL, contentMode: .scaleToFill)
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.backdropImageView.alpha = 1.0
        })  { _ in
            self.backdropImageView.downloadedFrom(url: largeImageURL, contentMode: .scaleToFill)
        }
    }
}
