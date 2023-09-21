//
//  MainTabBarController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }

    func setupUI(){
        
        let homePageVC = HomePageViewController()
        let homeNav = UINavigationController(rootViewController: homePageVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: nil, tag: 0)
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: nil, tag: 2)
        
        let favFilmVC = FavFilmViewController()
        let favNav = UINavigationController(rootViewController: favFilmVC)
        favNav.tabBarItem = UITabBarItem(title: "Favorite", image: nil, tag: 1)
        
        self.viewControllers = [homeNav,favNav,profileNav]
    }
}
