//
//  FavFilmViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 10/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import Firebase

class FavFilmViewController: UIViewController {

    var favMovieId : [Int] = []
    @IBOutlet weak var tableFavFilm: UITableView!
    var homePageViewModel = HomePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserFavFilm()
        tableViewRegister()
        cellRegister()
        loadAPI()
        
    }
    
    func setupUI(){
        title = "Favorite list"
    }
    
    func cellRegister(){
        let nib = UINib(nibName: "FilmTableViewCell", bundle: .main)
        tableFavFilm.register(nib, forCellReuseIdentifier: "cell")
    }
    
    func tableViewRegister(){
        tableFavFilm.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableFavFilm.dataSource = self
        tableFavFilm.delegate = self
    }
    
    func updateUI(){
        tableFavFilm.reloadData()
    }
    
    @objc func loadAPI(){
        print("LOAD API")
        homePageViewModel.loadAPI { (done, msg) in
            if done {
                self.updateUI()
            } else {
                print("API ERROR: \(msg)")
            }
        }
    }
    
    
    func getUserFavFilm(){
        let ref = Database.database().reference()
        if let currentUser = Auth.auth().currentUser {
            let idFilmFavRef = ref.child("users").child(currentUser.uid).child("idsFilmFav")
            idFilmFavRef.observe(.value) { (snapshot) in
                guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                    print("No data")
                    return
                }
                self.favMovieId.removeAll()
                
                for child in dataSnapshot {
                    if let item = child.value as? Int{
                        for item2 in self.homePageViewModel.movies{
                            if item == item2.id{
                                self.favMovieId.append(item)
                            }
                        }
                    }
                }
                print(self.favMovieId)
                self.updateUI()
            }
        }
    }
}

extension FavFilmViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favMovieId.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell: \(indexPath.row)")
        
        let vc = FilmDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
        for movie in homePageViewModel.movies {
            if favMovieId[indexPath.row] == movie.id{
                
                vc.movieDetail = movie
                return
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FilmTableViewCell
        
        for movie in homePageViewModel.movies{
            if favMovieId[indexPath.row] == movie.id{
                cell.labelFilmName.text = movie.nameMovies
                let urlString = "https://image.tmdb.org/t/p/w500\(movie.posterPath)"
                
                let url = URL(string: urlString)
                cell.imageLoadTask = URLSession.shared.dataTask(with: url!) { [weak cell] (data, response, error) in
                    DispatchQueue.main.async{
                        if let data = data, let image = UIImage(data: data) {
                            cell?.imgFilmPoster.image = image
                        }
                    }
                    // Dọn dẹp tác vụ tải hình ảnh khi hoàn thành
                    cell?.imageLoadTask = nil
                }
                // Bắt đầu tác vụ tải hình ảnh
                cell.imageLoadTask?.resume()
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
