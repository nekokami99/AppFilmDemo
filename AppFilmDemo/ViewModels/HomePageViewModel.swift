//
//  HomePageViewModel.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import Foundation

typealias Completion = (Bool, String) -> Void
class HomePageViewModel {
    var movies : [Movie] = []
    
    func loadAPI(completion: @escaping Completion) {
        
        let headers = [
          "accept": "application/json",
          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYmFiYzM4MGE5ZmY0ZTk2YmIxNWZjZGRmZTE4MDFmMSIsInN1YiI6IjY0NmRlMGFmNTRhMDk4MDBmZWFkODFjZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.RWu1TYG1B4R_H5NjuNLU2jp6DRV5MHD_FoyK4rQgolo"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&year=2022")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    if let data = data {
                        let json = data.toJSON()
    
                        let results = json["results"] as! [JSON]
                        for item in results {
                            let movie = Movie(json: item)
                            self.movies.append(movie)
                            
                        }
                        completion(true, "")
                    } else {
                        completion(false, "Data format is error.")
                    }
                }
            }
        }
        task.resume()
    }
}
