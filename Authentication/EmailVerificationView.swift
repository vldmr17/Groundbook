//
//  EmailVerificationView.swift
//  Groundbook
//
//  Created by admin on 17.11.2020.
//

import SwiftUI
import Firebase

struct EmailVerificationView: View {
    @ObservedObject var viewModel = EmailVerificationViewModel()
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Image(systemName: "envelope.badge.fill")
                .foregroundColor(.gray)
                .font(.system(size: 90))
                .padding(.bottom, 15)
            Text("We sent a confirmation email to")
            Text("\(Auth.auth().currentUser?.email ?? "")")
                .bold()
                .padding(.bottom,5)
            Text("Check your email and click on the")
            Text("confirmation link to continue")
                .padding(.bottom,10)
            Button(action: viewModel.checkVerification){
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 90)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
            }.padding(.bottom,20)
            Button(action: viewModel.sendVerificationMail){
                Text("Resend Email")
            }
            Spacer(minLength: 0)
            HStack{
                Text("Wrong email?")
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
                Button(action: {session.signOut()}){
                    Text("Change it")
                }
            }.padding(.bottom, 22)
        }.onAppear(perform: {
            viewModel.sendVerificationMail()
            viewModel.createUserDocument()
            
            viewModel.session = session
        })
        .alert(isPresented: $viewModel.showAlert){
            Alert(title: Text("Email is not verified!"))
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView()
    }
}
