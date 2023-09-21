//
//  ProfileViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import RxSwift

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var btnSignOut: UIButton!
    @IBOutlet weak var btnChangeIn4: UIButton!
    @IBOutlet weak var labelEmailData: UILabel!
    @IBOutlet weak var labelFullnameData: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelFullname: UILabel!
    var vcTo = ChangeInforViewController()
    var profileVM = ProfileViewModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getUserData()
    }
    
    func getUserData(){
        profileVM.getUserData()
        profileVM.subject.subscribe { [unowned self] userInfo in
            labelEmailData.text = userInfo.element?.email
            labelFullnameData.text = userInfo.element?.fullname
            title = userInfo.element?.username
        }.disposed(by: bag)
    }
    
    func setupUI(){
        labelEmail.text = "Your Email"
        labelFullname.text = "Your fullname"
        btnSignOut.setTitle("Sign out", for: .normal)
        btnChangeIn4.setTitle("Change profile", for: .normal)
    }
    
    @IBAction func signOutToLogin(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let vc = LoginViewController()
            let loginNav = UINavigationController(rootViewController: vc)
            //self.navigationController?.pushViewController(loginNav, animated: true)
            
            if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                scene.window?.rootViewController = loginNav
            }
        } catch let signOutError as NSError {
            print("Lỗi đăng xuất: \(signOutError.localizedDescription)")
        }
    }
    
    @IBAction func toChangeIn4VC(_ sender: Any) {
        vcTo.delegate = self
        self.navigationController?.pushViewController(vcTo, animated: true)
        vcTo.getUserData()
    }
}

protocol changeUIAfterUpdate: NSObject {
    func getUserEmailAfterUpdate(email: String)
    func getUsernameAfterUpdate(username: String)
    func getUserFullnameAfterUpdate(fullname: String)
}

extension ProfileViewController: changeUIAfterUpdate{
    func getUserEmailAfterUpdate(email: String){
        self.labelEmailData.text = email
    }
    
    func getUsernameAfterUpdate(username: String){
        self.title = username
    }
    
    func getUserFullnameAfterUpdate(fullname: String){
        self.labelFullnameData.text = fullname
    }
}
