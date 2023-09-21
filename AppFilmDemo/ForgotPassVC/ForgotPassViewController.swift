//
//  ForgotPassViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 11/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore


class ForgotPassViewController: UIViewController {

    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var tfEmailForNewPassword: UITextField!
    @IBOutlet weak var labelEmailForNewPassword: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelEmailForNewPassword.text = "Email for password change"
        // Do any additional setup after loading the view.
    }

    func sendResetEmail(email : String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                // Xử lý lỗi khi gửi email đặt lại mật khẩu
                print("Lỗi gửi email đặt lại mật khẩu: \(error.localizedDescription)")
            } else {
                // Gửi email đặt lại mật khẩu thành công
                print("Email đặt lại mật khẩu đã được gửi!")
                // Hiển thị thông báo cho người dùng rằng email đã được gửi.
                let alertController = UIAlertController(title: "Email đã được gửi", message: "Một email đặt lại mật khẩu đã được gửi đến hòm thư của bạn", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                // Thêm action vào UIAlertController
                alertController.addAction(okAction)
                // Hiển thị UIAlertController
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func toChangePasswordVC(_ sender: Any) {
        guard let email = tfEmailForNewPassword.text else {return}
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String : [String: Any]] {
                // Duyệt qua tất cả các dữ liệu người dùng
                for (_ , userData) in userDict {
                    if let emailData = userData["email"] as? String {
                        if email == emailData{
                            self.sendResetEmail(email: email)
                            return
                        }
                    }
                }
                if email.isEmpty {
                    let alertController = UIAlertController(title: "Thất bại", message: "Hãy nhập email", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                    }
                    // Thêm action vào UIAlertController
                    alertController.addAction(okAction)
                    // Hiển thị UIAlertController
                    self.present(alertController, animated: true, completion: nil)
                }
                let alertController = UIAlertController(title: "Thất bại", message: "Email chưa được đăng ký", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                // Thêm action vào UIAlertController
                alertController.addAction(okAction)
                // Hiển thị UIAlertController
                self.present(alertController, animated: true, completion: nil)
            } else {
                print("Không có thông tin người dùng")
            }
        })
    }
    
}
