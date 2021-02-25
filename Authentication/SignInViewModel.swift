//
//  SignInViewModel.swift
//  Groundbook
//
//  Created by admin on 19.02.2021.
//

import SwiftUI
import Firebase

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage = ""
    
    @Published var isSignUp = false
    
    @Published var showAlert = false
    @Published var alertMsg = ""
    
    var session: SessionStore?
    
    func signIn () {
        
        session!.signIn(email: email, password: password) { (result, error) in
            if error != nil {
                self.errorMessage = "*" + (error?.localizedDescription ?? "")
            } else {
                if(!(Auth.auth().currentUser?.isEmailVerified)!){
                    
                }
                
                self.email = ""
                self.password = ""
            }
        }
    }
    
    func resetPassword(){
        let alert = UIAlertController(title: "Password reset", message: "Enter your email to reset password", preferredStyle: .alert)
        
        alert.addTextField { (password) in
            password.placeholder = "email@example.com"
        }
        
        //кнопка для отправки ссылки для сброса пароля
        let proceed = UIAlertAction(title: "Send", style: .default) { (_) in
            
            if alert.textFields![0].text! != ""{
                
                Auth.auth().sendPasswordReset(withEmail: alert.textFields![0].text!) { (err) in
                    
                    if err != nil{
                        self.alertMsg = err!.localizedDescription
                        self.showAlert.toggle()
                        return
                    }
                    
                    // Alerting user...
                    self.alertMsg = "Password reset link has been sent. Please, check your email."
                    self.showAlert.toggle()
                }
            }
        }
        
        //cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(proceed)
        
        //выводим алерт
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}
