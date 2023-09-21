//
//  Movie.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import Foundation


struct Movie {
    var id:Int
    var nameMovies:String
    var posterPath:String
    var overview:String
    var rating: Double
    var genre_ids: [Int]
        
    init(json: JSON) {
        self.id = json["id"] as! Int
        self.nameMovies = json["title"] as! String
        self.posterPath = json["poster_path"] as! String
        self.overview = json["overview"] as! String
        self.rating = json["vote_average"] as! Double
        self.genre_ids = json["genre_ids"] as! [Int]
    }
}
