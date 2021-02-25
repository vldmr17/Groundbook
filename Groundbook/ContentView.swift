//
//  ContentView.swift
//  Groundbook
//
//  Created by admin on 14.11.2020.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var db: DBService
    @State var sessionStateLoading = true
    
    var body: some View {
        ZStack {
            //ждем окончания загрузки информации о юзере с сервера, и только потом проверяем ее
            if(!sessionStateLoading){
                if(session.session != nil && (Auth.auth().currentUser?.isEmailVerified)!){
                    if(db.isAllDataLoaded){
                        
                        TabView{
                            HomeView().tabItem{
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                            
                            MainMapView(/*filter: .all*/).tabItem{
                                Image(systemName: "map")
                                Text("Map")
                            }
                            
                            ChallengesView().tabItem{
                                Image(systemName: "flame.fill")
                                Text("Challenges")
                            }
                        }
                        
                    }else {
                        Text("")
                    }
                }
                
                if(self.session.session != nil && !(Auth.auth().currentUser?.isEmailVerified)!){
                    EmailVerificationView()
                }
                
                if(self.session.session == nil){
                    SignInView()
                }
            } else {
                //пока загружаются все данные показываем пустой экран (длится всего 1-2 секунды)
                Text("")
            }
        }.animation(.default)
        .onAppear(perform: {
            session.listen(){
                DispatchQueue.main.async {
                    sessionStateLoading = false
                    db.getMatches()
                    db.getChallenges()
                }
            }
            db.getCountries() //подгружаем страны сразу чтобы сократить кол-во запросов
        })
    }
}
