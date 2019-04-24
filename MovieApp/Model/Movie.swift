//
//  Movie.swift
//  MovieApp
//
//  Created by Sunil Kumar on 10/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import Foundation
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
struct Movie {
    //Details
    private(set)var avgRating: Double? // ratingScore
    private(set)var title: String?
    private(set)var overview: String? // synopsis
    private(set)var releaseDate: String? // releaseDate
    private(set)var originalLanguages: String? //original_language
    private(set)var noOfVotes: Int? // vote_count
    //
    /*private(set)var runningTime: String?//
    private(set)var genres: String?
    private(set)var listOfCast: String?*/
    
    //Images
    private(set)var posterImageURLMedium: URL?
    private(set)var posterImageURLHigh: URL?
    private(set)var posterImageURLLow: URL?
    private(set)var backdropImageURLMedium: URL?
    private(set)var backdropImageURLHigh: URL?
    private(set)var backdropImageURLLow: URL?
    
    init(dictionary: [String: Any]) {
        let posterImagePath = dictionary["poster_path"] as? String
        let backdropImagePath = dictionary["backdrop_path"] as? String
        let title = dictionary["title"] as? String
        let overview = dictionary["overview"] as? String
        let releaseDate = dictionary["release_date"] as? String
        let avgRating = dictionary["vote_average"] as? Double
        let originalLanguages = dictionary["original_language"] as? String
        let noOfVotes = dictionary["vote_count"] as? Int

        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.avgRating = avgRating
        self.originalLanguages = originalLanguages
        self.noOfVotes = noOfVotes
        
        if let backdropPath = backdropImagePath {
            self.backdropImageURLMedium = URL(string: MovieDBApiManager.imageBaseStr + "w500" + backdropPath)
            self.backdropImageURLHigh = URL(string: MovieDBApiManager.imageBaseStr + "original" + backdropPath)
            self.backdropImageURLLow = URL(string: MovieDBApiManager.imageBaseStr + "w45" + backdropPath)
        }
        
        if let posterImagePath = posterImagePath {
            self.posterImageURLMedium = URL(string: MovieDBApiManager.imageBaseStr + "w500" + posterImagePath)
            self.posterImageURLHigh = URL(string: MovieDBApiManager.imageBaseStr + "original" + posterImagePath)
            self.posterImageURLLow = URL(string: MovieDBApiManager.imageBaseStr + "w45" + posterImagePath)
        }
        
    }
    
    static func movies(with dictionaries: [[String: Any]]) -> [Movie] {
        return dictionaries.map { Movie(dictionary: $0) }
    }
}
