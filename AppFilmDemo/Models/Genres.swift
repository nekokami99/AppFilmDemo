//
//  Genres.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import Foundation


struct Genres {
    var id: Int
    var genre: String
    init(json: JSON){
        id = json["id"] as! Int
        genre = json["name"] as! String
    }
}
