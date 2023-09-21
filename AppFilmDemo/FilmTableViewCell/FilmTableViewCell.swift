//
//  FilmTableViewCell.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 10/09/2023.
//

import UIKit



class FilmTableViewCell: UITableViewCell {

    @IBOutlet weak var labelFilmName: UILabel!
    @IBOutlet weak var imgFilmPoster: UIImageView!
    var imageLoadTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        labelFilmName.numberOfLines = 5
        
    }

    func setupUI(){
        labelFilmName.text = "Film name"
        imgFilmPoster.image = UIImage(named: "movie_icon")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelFilmName.text = "Film name"
        imgFilmPoster.image = UIImage(named: "movie_icon")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func cancelImageLoad() {
//        imageLoadTask?.cancel()
//    }
}
