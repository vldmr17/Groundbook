//
//  SignUpViewModel.swift
//  Groundbook
//
//  Created by admin on 19.02.2021.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var reEnteredPassword: String = ""
    @Published var errorMessage = ""
    
    var session: SessionStore?
    
    func signUp () {
        
        if(isValidEmail(email)){
            if (password == reEnteredPassword){
                if (password.count >= 8){
                    //регистрируем пользователя
                    session!.signUp(email: email, password: password) { (result, error) in
                        if error != nil {
                            self.errorMessage = "*" + (error?.localizedDescription ?? "")
                        } else {
                            self.email = ""
                            self.password = ""
                            self.reEnteredPassword = ""
                        }
                    }
                } else {
                    self.errorMessage = "*Password must contain at least 8 characters"
                    self.password = ""
                    self.reEnteredPassword = ""
                }
            } else {
                self.errorMessage = "*The entered passwords do not match"
                self.password = ""
                self.reEnteredPassword = ""
            }
        } else {
            self.errorMessage = "*Please, enter a correct email"
            self.email = ""
        }
        
        
    }
}
