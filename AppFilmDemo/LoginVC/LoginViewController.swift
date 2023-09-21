//
//  LoginViewController.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 07/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import Security

class LoginViewController: UIViewController {

    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var labelPassword: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var labelForgetPass: UILabel!
    @IBOutlet weak var labelSignUp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.addGestureToSignUpLabel()
        self.addGestureToForgotPassLabel()
        checkCurUser()
    }
    
    func checkCurUser(){
        if let currentUser = Auth.auth().currentUser{
            print(currentUser.uid)
            print(currentUser.isEmailVerified)
            let vc = HomePageViewController()
            self.navigationController?.pushViewController(vc, animated: true)
                
            self.setRootView()
        } else{
            print("No uid")
        }
    }

    private func setupUI(){
        labelUsername.text = "Email"
        labelPassword.text = "Password"
        labelSignUp.text = "Sign up here"
        labelForgetPass.text = "Forgot password? Click here"
        labelSignUp.textAlignment = .center
        labelForgetPass.textAlignment = .center
        btnLogin.setTitle("Log in", for: .normal)
    }

    func addGestureToForgotPassLabel(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTappedForgotPassLabel(_:)))
        tap.numberOfTapsRequired = 1
        self.labelForgetPass.isUserInteractionEnabled = true
        self.labelForgetPass.addGestureRecognizer(tap)
    }

    func addGestureToSignUpLabel(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTappedSignUpLabel(_:)))
        tap.numberOfTapsRequired = 1
        self.labelSignUp.isUserInteractionEnabled = true
        self.labelSignUp.addGestureRecognizer(tap)
    }
    
    @objc
    func labelTappedForgotPassLabel(_ tap: UIGestureRecognizer){
        let vc = ForgotPassViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func labelTappedSignUpLabel(_ tap: UIGestureRecognizer){
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func goToHomePage(_ sender: Any) {
        let service = "com.BachNguyen.AppFilmDemo"
        let email = tfUsername.text
        let password = tfPassword.text
        guard let email = email, let password = password else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Sign-in error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Đăng nhập thất bại", message: "Tài khoản hoặc mật khẩu không đúng.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in }
                // Thêm action vào UIAlertController
                alertController.addAction(okAction)
                // Hiển thị UIAlertController
                self.present(alertController, animated: true, completion: nil)
            } else {
                print("Sign-in successful!")
                self.savePasswordToKeychain(service: service, email: email, password: password)
                let alertController = UIAlertController(title: "Đăng nhập thành công", message: "Bạn đã đăng nhập thành công.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Đóng", style: .default) { (action) in }
                // Thêm action vào UIAlertController
                alertController.addAction(okAction)
                // Hiển thị UIAlertController
                self.present(alertController, animated: true, completion: nil)
                let vc = HomePageViewController()
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
    
    func savePasswordToKeychain(service: String, email: String, password: String) {
        // Convert password to Data
        if let passwordData = password.data(using: .utf8) {
            // Define query parameters
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: email,
                kSecValueData as String: passwordData
            ]
            // Try to delete any existing item with the same service and account
            SecItemDelete(query as CFDictionary)
            // Add the new item to Keychain
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving password to Keychain")
            }
        }
    }
}
