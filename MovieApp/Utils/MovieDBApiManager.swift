//
//  MovieDBApi.swift
//  MovieApp
//
//  Created by Sunil Kumar on 03/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import UIKit

enum MovieDBErrors: Error {
    
    case networkFail(description: String)
    case jsonSerializationFail
    case dataNotReceived
    case castFail
    case internalError
    case unknown
}

extension MovieDBErrors: LocalizedError {
    
    public var errorDescription: String? {
        let defaultMessage = "Unknown error!"
        let internalErrorMessage = "Something's wrong! Please contact our support team."
        switch self {
        case .networkFail(let localizedDescription):
            print(localizedDescription)
            return localizedDescription
        case .jsonSerializationFail:
            return internalErrorMessage
        case .dataNotReceived:
            return internalErrorMessage
        case .castFail:
            return internalErrorMessage
        case .internalError:
            return internalErrorMessage
        case .unknown:
            return defaultMessage
        }
    }
}

protocol MovieDBApiDelegate: class {
    
    func movieDBApi(didFinishUpdatingMovies movies: [Movie])
    func movieDBApi(didFailWithError error: Error)
}

extension MovieDBApiDelegate {
    
    func movieDBApi(didFinishUpdatingMovies movies: [Movie]) {}
    func movieDBApi(didFailWithError error: Error) {}
}

struct MovieDBApiManager {
    
    static let baseUrlStr: String = "https://api.themoviedb.org/3/movie/"
    static let apiKey: String = "1baf3f7040c2495432839a081e54a0c1"
    static let imageBaseStr: String = "https://image.tmdb.org/t/p/"
    
    weak var delegate: MovieDBApiDelegate?
    var endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    func startUpdatingMovies() {
        let urlString = MovieDBApiManager.baseUrlStr + "\(endpoint)?api_key=\(MovieDBApiManager.apiKey)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task: URLSessionDataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                self.delegate?.movieDBApi(didFailWithError: MovieDBErrors.networkFail(description: error!.localizedDescription))
                print("MovieDBApi: \(error!.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                self.delegate?.movieDBApi(didFailWithError: MovieDBErrors.unknown)
                print("MovieDBApi: Unknown error. Could not get response!")
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.movieDBApi(didFailWithError: MovieDBErrors.internalError)
                print("MovieDBApi: Response code was either 401 or 404.")
                return
            }
            
            guard let data = data else {
                self.delegate?.movieDBApi(didFailWithError: MovieDBErrors.dataNotReceived)
                print("MovieDBApi: Could not get data!")
                return
            }
            
            do {
                let movies = try self.movieObjects(with: data)
                self.delegate?.movieDBApi(didFinishUpdatingMovies: movies)
            } catch let error {
                self.delegate?.movieDBApi(didFailWithError: error)
                print("MovieDBApi: Some problem occurred during JSON serialization.")
                return
            }
        })
        task.resume()
    }
    
    func movieObjects(with data: Data) throws -> [Movie] {
        do {
            guard let responseDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                throw MovieDBErrors.castFail
            }
            guard let movieDictionaries = responseDictionary["results"] as? [[String: Any]] else {
                print("MovieDBApi: Movie dictionary not found.")
                throw MovieDBErrors.unknown
            }
            return Movie.movies(with: movieDictionaries)
        } catch let error {
            print("MovieDBApi: \(error.localizedDescription)")
            throw error
        }
    }
}

//UIImageView
extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
