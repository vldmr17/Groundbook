//
//  SignInView.swift
//  Groundbook
//
//  Created by admin on 15.11.2020.
//

import SwiftUI
import Firebase

struct SignInView : View {
    @ObservedObject var viewModel = SignInViewModel()
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Text("Welcome")
                .fontWeight(.heavy)
                .font(.system(size: 60))
                .padding(.bottom,20)
            HStack(alignment: .center){
                Image(systemName: "envelope.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 55))
                    .padding(.bottom, 20)
                TextField("mail@example.com", text: $viewModel.email)
                    .padding()
                    .background(Color("Gainsboro"))
                    .frame(width: UIScreen.main.bounds.width - 90)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
            }
            HStack{
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 55))
                    .padding(.bottom, 15)
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color("Gainsboro"))
                    .frame(width: UIScreen.main.bounds.width - 90)
                    .cornerRadius(5.0)
                    .padding(.bottom, 10)
            }
            Text("\(viewModel.errorMessage)")
                .foregroundColor(.gray)
                .frame(width: UIScreen.main.bounds.width - 30)
            Button(action: viewModel.signIn) {
                Text("SIGN IN")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 30)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
            }
            HStack{
                Text("Don't have an account?")
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 15)
                Button(action: {viewModel.isSignUp.toggle()}){
                    Text("Sign Up")
                }
                .fullScreenCover(isPresented: $viewModel.isSignUp) {
                    SignUpView()
                }
            }.padding(.top, 10)
            Spacer(minLength: 0)
            Button(action: viewModel.resetPassword){
                Text("Forgot password?")
            }
        }//алерт для уведомления о результате отправки ссылки для сброса пароля
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertMsg)
            )
        }
        .padding(.vertical,22)
        .onAppear{
          viewModel.session = session
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
