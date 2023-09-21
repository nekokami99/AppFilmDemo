//
//  HomePageViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 08/09/2023.
//

import UIKit
import RxSwift
import RxCocoa

class HomePageViewController: UIViewController {
    

    @IBOutlet weak var tableListFilm: UITableView!
    var homePageViewModel = HomePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewRegister()
        cellRegister()
        loadAPI()
    }
    
    func setupUI(){
        title = "Film list"
    }
    
    func cellRegister(){
        let nib = UINib(nibName: "FilmTableViewCell", bundle: .main)
        tableListFilm.register(nib, forCellReuseIdentifier: "cell")
    }
    
    func tableViewRegister(){
        tableListFilm.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableListFilm.dataSource = self
        tableListFilm.delegate = self
    }
    
    func updateUI(){
        tableListFilm.reloadData()
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
}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homePageViewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FilmTableViewCell
        
        let item = homePageViewModel.movies[indexPath.row]
        cell.labelFilmName.text = item.nameMovies
        let urlString = "https://image.tmdb.org/t/p/w500\(item.posterPath)"
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
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell: \(indexPath)")
        let item = homePageViewModel.movies[indexPath.row]
        let vc = FilmDetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        vc.movieDetail = item
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
