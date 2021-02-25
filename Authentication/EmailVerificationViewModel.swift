//
//  EmailVerificationViewModel.swift
//  Groundbook
//
//  Created by admin on 19.02.2021.
//

import SwiftUI
import Firebase

class EmailVerificationViewModel: ObservableObject{
    @Published var showAlert = false
    
    var session: SessionStore?
    
    func checkVerification (){
        Auth.auth().currentUser?.reload(completion: {_ in
            self.session!.listen(){}
            //если почта еще не верифицирована, уведомляем пользователя
            if(!(Auth.auth().currentUser?.isEmailVerified)!){
                self.showAlert.toggle()
            }
        })
    }
    
    func sendVerificationMail () {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
          // ...
        }
    }
    
    //создаем новый документ пользователя для хранения его информации (матчи и тд)
    func createUserDocument () {
        let docRef = session!.db.collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if document!.exists {
                //документ существует, создавать не надо
            } else {
                //создаем новый документ в коллекции users
                self.session!.db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                    "email": Auth.auth().currentUser!.email
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
        }
    }
}
