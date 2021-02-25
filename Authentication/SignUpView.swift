//
//  SignUpView.swift
//  Groundbook
//
//  Created by admin on 17.11.2020.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var session: SessionStore
    @ObservedObject var viewModel = SignUpViewModel()
    
    var body: some View {
        VStack{
            Spacer(minLength: 0)
            Text("Registration")
                .fontWeight(.heavy)
                .font(.system(size: 60))
                .padding(.bottom,20)
            HStack(alignment: .center){
                Image(systemName: "envelope.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 55))
                    .padding(.bottom, 10)
                TextField("email@example.com", text: $viewModel.email)
                    .padding()
                    .background(Color("Gainsboro"))
                    .frame(width: UIScreen.main.bounds.width - 90)
                    .cornerRadius(5.0)
                    .padding(.bottom, 10)
            }
            HStack{
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 55))
                    .padding(.bottom, 10)
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color("Gainsboro"))
                    .frame(width: UIScreen.main.bounds.width - 90)
                    .cornerRadius(5.0)
                    .padding(.bottom, 10)
            }
            HStack{
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 55))
                    .padding(.bottom, 5)
                SecureField("Confirm Password", text: $viewModel.reEnteredPassword)
                    .padding()
                    .background(Color("Gainsboro"))
                    .frame(width: UIScreen.main.bounds.width - 90)
                    .cornerRadius(5.0)
                    .padding(.bottom, 10)
            }
            Text("\(viewModel.errorMessage)")
                .foregroundColor(.gray)
                .frame(width: UIScreen.main.bounds.width - 30)
            Button(action: viewModel.signUp) {
                Text("SIGN UP")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
            }
            HStack{
                Text("Already have an account?")
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 15)
                Button(action: {self.presentationMode.wrappedValue.dismiss()}){
                    Text("Sign In")
                }
            }.padding(.top, 10)
            Spacer(minLength: 0)
            
        }.onAppear{
            viewModel.session = session
        }
    }
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
