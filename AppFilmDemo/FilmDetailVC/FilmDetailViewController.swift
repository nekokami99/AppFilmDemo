//
//  FilmDetailViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 08/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import RxSwift

class FilmDetailViewController: UIViewController {
    
    //var isFav : Bool = false
    let bag = DisposeBag()
    @IBOutlet weak var btnToFavorite: UIButton!
    var movieDetail: Movie!
    var filmDetailViewModel = FilmDetailViewModel()
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var labelFilmRating: UILabel!
    @IBOutlet weak var labelFilmGenre: UILabel!
    @IBOutlet weak var labelFilmDesc: UILabel!
    @IBOutlet weak var labelFilmName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAPI()
        filmDetailViewModel.checkIdFavorite(idFilm: movieDetail.id)
        updateBtnTitle()
    }
    
    func setupUI(){
        imgPoster.image = UIImage(named: "movie_icon")
        labelFilmName.text = "Movie: "
        labelFilmDesc.text = "Overview: "
        labelFilmRating.text = "Rating: "
    }
    
    @objc func loadAPI(){
        print("LOAD API")
        filmDetailViewModel.loadAPI { (done, msg) in
            if done {
                self.updateUI()
            } else {
                print("API ERROR: \(msg)")
            }
        }
    }
    
    @IBAction func addToFavorite(_ sender: Any) {
        let idFilm = movieDetail.id
        
        filmDetailViewModel.isFav.subscribe { [unowned self] value in
            if value {
                filmDetailViewModel.deleteFromFavList(idFilm: idFilm)
                let alertController = UIAlertController(title: "Xoá thành công", message: "\(movieDetail.nameMovies) đã xoá khỏi danh sách yêu thích.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
                // Thêm action vào UIAlertController
                alertController.addAction(okAction)
                // Hiển thị UIAlertController
                present(alertController, animated: true, completion: nil)
                btnToFavorite.setTitle("Add to favorite", for: .normal)
            } else {
                filmDetailViewModel.addToFavList(idFilm: idFilm)
                let alertController = UIAlertController(title: "Thêm thành công", message: "Bạn đã thêm \(movieDetail.nameMovies) vào danh sách yêu thích.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
                // Thêm action vào UIAlertController
                alertController.addAction(okAction)
                // Hiển thị UIAlertController
                present(alertController, animated: true, completion: nil)
                btnToFavorite.setTitle("Remove from favorite", for: .normal)
            }
        }.disposed(by: bag)
    }
    
    func updateBtnTitle(){
        filmDetailViewModel.isFav.subscribe { [unowned self] value in
            print(value)
            if value {
                self.btnToFavorite.setTitle("Remove from favorite", for: .normal)
            } else {
                self.btnToFavorite.setTitle("Add to favorite", for: .normal)
            }
        }.disposed(by: bag)
    }
    
    func updateUI(){
        labelFilmName.text = "Movie: \(movieDetail.nameMovies)"
        labelFilmName.numberOfLines = 5
        labelFilmDesc.text = "Overview: \(movieDetail.overview)"
        labelFilmDesc.numberOfLines = 100
        labelFilmRating.text = "Rating: \(String(format: "%.1f",movieDetail.rating))"
        updateBtnTitle()
        
        let urlString = "https://image.tmdb.org/t/p/w500\(movieDetail.posterPath)"
        
        filmDetailViewModel.downloadImage(fromURL: urlString) { (image) in
            DispatchQueue.main.async { [unowned self] in
                    if let image = image {
                        // Gán hình ảnh vào UIImageView
                        imgPoster.image = image
                    } else {
                        let alertController = UIAlertController(title: "Lỗi", message: "Không thể tải hình ảnh.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in }
                        // Thêm action vào UIAlertController
                        alertController.addAction(okAction)
                        // Hiển thị UIAlertController
                        self.present(alertController, animated: true, completion: nil)
                        // Xử lý khi không thể tải hình ảnh
                        print("Không thể tải hình ảnh")
                    }
                }
            }
        
        labelFilmGenre.numberOfLines = 3
        labelFilmGenre.text = filmDetailViewModel.getGenreString(genre: movieDetail.genre_ids)
    }
}

