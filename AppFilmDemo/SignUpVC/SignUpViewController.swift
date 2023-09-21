//
//  SignUpViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 07/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore

class SignUpViewController: UIViewController{

    @IBOutlet weak var labelFullname: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelPassword: UILabel!
    @IBOutlet weak var labelRepeatPassword: UILabel!
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnCancel: UIButton!

    @IBOutlet weak var tfFullname: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfRepeatPassword: UITextField!
    
    //var authManager = FirebaseAuthManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    @IBAction func confirmSignUp(_ sender: Any) {
        let username = tfUsername.text
        let fullname = tfFullname.text
        let repeatPassword = tfRepeatPassword.text
        let email = tfEmail.text
        let password = tfPassword.text
        
        guard let email = email, let password = password, let username = username, let fullname = fullname, let repeatPassword = repeatPassword else {return}
        
        if email.isEmpty || password.isEmpty || username.isEmpty || fullname.isEmpty || repeatPassword.isEmpty {
            let alertController = UIAlertController(title: "Đăng ký thất bại", message: "Hãy điền các trường còn thiếu.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if password != repeatPassword {
            let alertController = UIAlertController(title: "Đăng ký thất bại", message: "Password và repeat password không khớp.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let error = error{
                let alertController = UIAlertController(title: "Đăng ký thất bại", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                
                let alertController = UIAlertController(title: "Đăng ký thành công", message: "Bạn đã đăng ký thành công tài khoản.", preferredStyle: .alert)

                // Thêm một action cho UIAlertController (ví dụ: Đóng)
                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                    // Xử lý khi người dùng nhấn nút "Đóng"
                    // Bạn có thể thực hiện các tác vụ sau khi thông báo đóng
                }

                // Thêm action vào UIAlertController
                alertController.addAction(okAction)

                // Hiển thị UIAlertController
                self.present(alertController, animated: true, completion: nil)
                print("Success sign up")
                
                let ref = Database.database().reference()
                if let currentUser = Auth.auth().currentUser {
                    print(currentUser.uid)
                    // Tạo một dictionary chứa thông tin bạn muốn thêm
                    let userInformation = [
                        "fullname" : fullname,
                        "username" : username,
                        "email" : email,
                    ]
                    // Sử dụng UID của người dùng làm đường dẫn và đẩy thông tin lên Database
                    ref.child("users").child(currentUser.uid).setValue(userInformation) { (error, _) in
                        if let error = error {
                            print("Không thể thêm thông tin người dùng: \(error.localizedDescription)")
                        } else {
                            print("Thêm thông tin người dùng thành công.")
                        }
                    }
                }
                let vc  = HomePageViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                self.setRootView()
            }
        }
    }
    
    func setRootView(){
        let mainTabBarController  = MainTabBarController()
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            scene.window?.rootViewController = mainTabBarController
        }
        
    }
    
    @IBAction func cancelSignUp(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupUI(){
        labelEmail.text = "Email"
        labelPassword.text = "Password"
        labelUsername.text = "Username"
        labelRepeatPassword.text = "Repeat password"
        labelFullname.text = "Full name"
        
        btnConfirm.setTitle("Confirm", for: .normal)
        btnCancel.setTitle("Cancel", for: .normal)
    }
}
