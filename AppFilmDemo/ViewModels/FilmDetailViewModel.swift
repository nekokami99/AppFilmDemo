//
//  FilmDetailViewModel.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 12/09/2023.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import RxSwift

typealias Completion2 = (Bool, String) -> Void
class FilmDetailViewModel {
    var genres : [Genres] = []
    let isFav = BehaviorSubject(value: false)
    
    func loadAPI(completion: @escaping Completion2) {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=dbabc380a9ff4e96bb15fcddfe1801f1"
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    if let data = data {
                        let json = data.toJSON()
    
                        let results = json["genres"] as! [JSON]
                        for item in results {
                            let genre = Genres(json: item)
                            self?.genres.append(genre)
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
    
    func downloadImage(fromURL urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Kiểm tra URL hợp lệ
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        // Sử dụng URLSession để tải dữ liệu
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Xử lý lỗi nếu có
            if let error = error {
                print("Lỗi tải hình ảnh: \(error.localizedDescription)")
                completion(nil)
                return
            }
            // Kiểm tra dữ liệu hình ảnh và tạo hình ảnh từ nó
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func getGenreString(genre: [Int]) -> String {
        var genreString: String = "Genres: "
        for item in genre{
            for item2 in genres{
                if item == item2.id {
                    if item != genre.last {
                        genreString += "\(item2.genre), "
                    } else  {
                        genreString += "\(item2.genre)"
                    }
                }
            }
        }
        return genreString
    }
    
    func checkIdFavorite(idFilm: Int){
        let ref = Database.database().reference()
        if let currentUser = Auth.auth().currentUser {
            print(currentUser.uid)
           
            // Sử dụng UID của người dùng làm đường dẫn và đẩy thông tin lên Database
            let idFilmFavRef = ref.child("users").child(currentUser.uid).child("idsFilmFav")
            idFilmFavRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                    print("No data")
                    return
                }
                for child in dataSnapshot {
                    if let item = child.value as? Int{
                        if idFilm == item {
                            self?.isFav.onNext(true)
                        }
                    }
                }
            }
    
        }
    }
    
    func deleteFromFavList(idFilm: Int){
        
        let ref = Database.database().reference()
        if let currentUser = Auth.auth().currentUser {
            print(currentUser.uid)
            
            // Sử dụng UID của người dùng làm đường dẫn và đẩy thông tin lên Database
            let idFilmFavRef = ref.child("users").child(currentUser.uid).child("idsFilmFav")
            idFilmFavRef.observeSingleEvent(of: .value) { (snapshot) in
                guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                    print("No data")
                    return
                }
                for child in dataSnapshot {
                    if let item = child.value as? Int{
                        if item == idFilm{
                            idFilmFavRef.child(child.key).removeValue()
                            print("\(idFilm) is deleted from favorite list")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func addToFavList(idFilm: Int){
        
        let ref = Database.database().reference()
        if let currentUser = Auth.auth().currentUser {
            print(currentUser.uid)
            
            // Sử dụng UID của người dùng làm đường dẫn và đẩy thông tin lên Database
            let idFilmFavRef = ref.child("users").child(currentUser.uid).child("idsFilmFav")
            idFilmFavRef.observeSingleEvent(of: .value) { (snapshot) in
                let newIdFilm = idFilmFavRef.childByAutoId()
                newIdFilm.setValue(idFilm){ (error, _) in
                    if let error = error {
                        print("Lỗi khi thêm dữ liệu: \(error.localizedDescription)")
                        return
                    } else {
                        print("Dữ liệu đã được thêm vào mảng.")
                    }
                }
            }
        }
    }
}

