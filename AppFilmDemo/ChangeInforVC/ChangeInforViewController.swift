//
//  ChangeInforViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import Firebase
import Security
import RxSwift

class ChangeInforViewController: UIViewController {
    
    weak var delegate : changeUIAfterUpdate?
    let disposeBag = DisposeBag()
    let profileVM = ProfileViewModel()
    var user : User!
    @IBOutlet weak var btnConfirmChange: UIButton!
    @IBOutlet weak var tfChangeEmail: UITextField!
    @IBOutlet weak var tfChangeFullname: UITextField!
    @IBOutlet weak var tfChangeUsername: UITextField!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelFullname: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        profileVM.getUserData()
        getUserData()
    }
    
    func setupUI(){
        labelEmail.text = "Email"
        labelFullname.text = "Fullname"
        labelUsername.text = "Username"
        btnConfirmChange.setTitle("Update", for: .normal)
        title = "Change profile"
    }
    
    func getUserData(){
        profileVM.subject.subscribe { [unowned self] user in
            if let email = user.element?.email,
               let fullname = user.element?.fullname,
               let username = user.element?.username {
                print(email, fullname, username)
                tfChangeFullname.text = fullname
                tfChangeEmail.text = email
                tfChangeUsername.text = username
            }
        }.disposed(by: disposeBag)
    }
    
    //sua lai
    func changeEmail(email: String){
        if let currentUser = Auth.auth().currentUser {
            let currentPassword = profileVM.getPasswordFromKeychain(service: "com.BachNguyen.AppFilmDemo", email: currentUser.email!)
            
            let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: currentPassword!)

            let uid = currentUser.uid
            let ref = Database.database().reference().child("users").child(uid)
            
            currentUser.reauthenticate(with: credential) { (authResult, error) in
                    if let error = error {
                        // Handle reauthentication error
                        print("Reauthentication error: \(error.localizedDescription)")
                    } else {
                        // User has been successfully reauthenticated
                        print(currentUser.isEmailVerified)
                        print("User reauthenticated successfully.")
                        if email != currentUser.email{
                            currentUser.sendEmailVerification(beforeUpdatingEmail: email) { (error) in
                                if let error = error {
                                    print("Email verify sent error: \(error.localizedDescription)")
                                    return
                                }
                                let alertController = UIAlertController(title: "Verify email", message: "Hãy kiểm tra hòm thư để verify email", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Đã kiểm tra", style: .default) { (action) in
                                    currentUser.updateEmail(to: email ) { (error) in
                                        if let error = error {
                                            print("Email update error: \(error.localizedDescription)")
                                            return
                                        }
                                        // Email has been successfully updated
                                        print("Email updated to: \(email)")
                                        
                                        let data = ["email" : email]
                                        ref.updateChildValues(data) { (error, _) in
                                            if let error = error {
                                                // Xử lý lỗi nếu có
                                                print("Cập nhật dữ liệu thất bại: \(error.localizedDescription)")
                                            } else {
                                                print("Cập nhật dữ liệu thành công.")
                                                self.delegate?.getUserEmailAfterUpdate(email: email)
                                                let alertController = UIAlertController(title: "Verified email", message: "Hãy đăng nhập lại", preferredStyle: .alert)
                                                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
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
                                                alertController.addAction(okAction)
                                            }
                                        }
                                    }
                                    
                                }
                                let cancelAction = UIAlertAction(title: "Huỷ", style: .default)
                                alertController.addAction(okAction)
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
        }
    }

    @IBAction func confirmUpdateUser(_ sender: Any) {
        let inputFullname = tfChangeFullname.text
        let inputUsername = tfChangeUsername.text
        let inputEmail = tfChangeEmail.text
        
        guard let inputEmail = inputEmail, let inputFullname = inputFullname, let inputUsername = inputUsername else { return }
        guard let currentUser = Auth.auth().currentUser else { return }
        let uid = currentUser.uid
        let ref = Database.database().reference().child("users").child(uid)
        
        if inputFullname.isEmpty == false , inputEmail.isEmpty == false , inputUsername.isEmpty == false{
            let data = [
                "fullname" : inputFullname,
                "username" : inputUsername]
            
            ref.updateChildValues(data) { (error, _) in
                if let error = error {
                    // Xử lý lỗi nếu có
                    print("Cập nhật dữ liệu thất bại: \(error.localizedDescription)")
                } else {
                    print("Cập nhật dữ liệu thành công.")
                    self.delegate?.getUsernameAfterUpdate(username: inputUsername)
                    self.delegate?.getUserFullnameAfterUpdate(fullname: inputFullname)
                    
                }
            }
            changeEmail(email: inputEmail)
            //self.navigationController?.popViewController(animated: true)
        } else {
            let alertController = UIAlertController(title: "Thất bại", message: "Hãy nhập đủ thông tin", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
