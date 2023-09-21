//
//  ProfileViewModel.swift
//  AppFilmDemo
//
//  Created by Nguyen Kien on 15/09/2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import RxSwift
import Security

final class ProfileViewModel {
    
    let subject = ReplaySubject<User>.create(bufferSize: 1)
    
    func getUserData(){
        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            let ref = Database.database().reference().child("users").child(uid)
            
            ref.observeSingleEvent(of: .value) {(snapshot) in
                if let userData = snapshot.value as? [String: Any] {
                    let fullname = userData["fullname"] as? String ?? ""
                    let email = userData["email"] as? String ?? ""
                    let username = userData["username"] as? String ?? ""
                    
                    
                    let userInfo = User(fullname: fullname, username: username, email: email)
                    self.subject.onNext(userInfo)
                }
            }
        }
    }
    
    // Hàm để lấy mật khẩu từ Keychain
    func getPasswordFromKeychain(service: String, email: String) -> String? {
        // Define query parameters
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: email,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let passwordData = result as? Data {
            if let password = String(data: passwordData, encoding: .utf8) {
                return password
            }
        }
        return nil
    }
    
}
