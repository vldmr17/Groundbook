//
//  StatisticsProvider.swift
//  Groundbook
//
//  Created by admin on 24.01.2021.
//

import Foundation
import Firebase

class StatisticsProvider: ObservableObject {
    // MARK: HomeView
    
    @Published var mostVisitedTeam = Team(id: .init(), documentID: "", name: "", logoURL: URL(string: "empty")!, venue: "", country: Country(id: .init(), documentID: "", name: "", code: ""))
    @Published var mostVisitedGround = Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "empty")!, latitude: 0.0, longitude: 0.0, tenants: [])
    
    func getMostVisitedTeam (period: String, db: DBService){
        var dict = [String:Int]()
        
        if (period == "Overall"){
            for match in db.matches {
                if(dict[match.home!.documentID] == nil){
                    dict[match.home!.documentID] = 1
                } else {
                    dict[match.home!.documentID]! += 1
                }
                
                if(dict[match.away!.documentID] == nil){
                    dict[match.away!.documentID] = 1
                } else {
                    dict[match.away!.documentID]! += 1
                }
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    if(dict[match.home!.documentID] == nil){
                        dict[match.home!.documentID] = 1
                    } else {
                        dict[match.home!.documentID]! += 1
                    }
                    
                    if(dict[match.away!.documentID] == nil){
                        dict[match.away!.documentID] = 1
                    } else {
                        dict[match.away!.documentID]! += 1
                    }
                }
            }
        }
        
        
        var mostVisitedTeams = [String]() //массив самых посещаемых команд (их может быть несколько с одинаковым колвом посещений)
        var visitCounter = 0
        //вычисляем id документа команды с наибольшим кол-вом посещений
        for element in dict{
            if(element.value > visitCounter){
                visitCounter = element.value
                mostVisitedTeams.removeAll() //найдена команда с большим кол-вом посещений, удаляем из массива другую/другие команды
                mostVisitedTeams.append(element.key)
                continue
            }
            if(element.value == visitCounter){
                mostVisitedTeams.append(element.key) //добавляем еще одну команды с самым большим кол-вом посещений
            }
        }
        
        var docID = "empty"
        
        //чтобы менялась команда на пустое значение (если период когда не было матчей), проверяем не пустой ли словарь после вычислений выше
        if(!dict.isEmpty){
            
            searchMostVisitedTeamLoop: for match in db.matches {
                for team in mostVisitedTeams {
                    if(match.home!.documentID == team){
                        mostVisitedTeam = match.home! //если матчи уже загружены (можно без этого, но тогда прога работает немного быстрее, не надо ждать загрузки в loadTeam)
                        docID = match.home!.documentID //ID документа передается в loadTeam, это нужно если приложение только запущено
                        break searchMostVisitedTeamLoop
                        
                    }
                    if(match.away!.documentID == team){
                        mostVisitedTeam = match.away! //если матчи уже загружены
                        docID = match.away!.documentID
                        break searchMostVisitedTeamLoop
                    }
                }
            }
        }else{
            mostVisitedTeam = Team(id: .init(), documentID: "", name: "", logoURL: URL(string: "empty")!, venue: "", country: Country(id: .init(), documentID: "", name: "", code: "")) //пустое значение команды когда нет матчей за период
        }
        loadTeam(id: docID, db: db) //если не все данные о матчах загружены (еще нет того, что подгружается асинхронно (имен, download url's), но есть id нужного нам документа), это нужно когда приложение только запустилось
    }
    
    func loadTeam (id: String, db: DBService){
        Firestore.firestore().collection("teams").document(id).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data!["name"] as? String ?? ""
                let countryDocID = data!["country"] as? String ?? ""
                let logoPath = data!["logo"] as? String ?? ""
                
                //получили ID докумнта страны, теперь получаем остальные свойства (имя и код)
                Firestore.firestore().collection("countries").document(countryDocID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data!["name"] as? String ?? ""
                        let code = data!["code"] as? String ?? ""
                        
                        self.mostVisitedTeam.country.name = name
                        self.mostVisitedTeam.country.code = code
                    } else {
                        print("Document does not exist")
                    }
                }
                
                db.downloadURL(imagePath: logoPath) { data in
                    //data is value return by test function
                    DispatchQueue.main.async {
                        //data - значение, которое возвращает ф-ция downloadURL
                        let logoURL = data
                        
                        //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                        self.mostVisitedTeam.logoURL = logoURL
                        self.mostVisitedTeam.name = name
                        
                        print(self.mostVisitedTeam.name)
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getMostVisitedGround (period: String, db: DBService){
        var dict = [String:Int]()
        
        if (period == "Overall"){
            for match in db.matches {
                if(dict[match.ground!.documentID] == nil){
                    dict[match.ground!.documentID] = 1
                } else {
                    dict[match.ground!.documentID]! += 1
                }
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    if(dict[match.ground!.documentID] == nil){
                        dict[match.ground!.documentID] = 1
                    } else {
                        dict[match.ground!.documentID]! += 1
                    }
                }
            }
        }
        
        var mostVisitedGrounds = [String]()
        var visitCounter = 0
        //вычисляем id документа команды с наибольшим кол-вом посещений
        for element in dict{
            if(element.value > visitCounter){
                visitCounter = element.value
                //docID = element.key
                mostVisitedGrounds.removeAll()
                mostVisitedGrounds.append(element.key)
            }
            if(element.value == visitCounter){
                mostVisitedGrounds.append(element.key)
            }
        }
        
        var docID = "empty"
        
        //чтобы менялась команда (если период когда не было матчей) проверяем не пустой ли словарь после вычислений выше
        if(!dict.isEmpty){
            
            searchMostVisitedGroundLoop: for match in db.matches {
                for ground in mostVisitedGrounds {
                    if(match.ground!.documentID == ground){
                        mostVisitedGround = match.ground! //если матчи уже загружены (можно без этого, но тогда прога работает немного быстрее)
                        docID = match.ground!.documentID
                        break searchMostVisitedGroundLoop
                    }
                }
            }
        }else{
            mostVisitedGround = Ground(id: .init(), documentID: "", name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "empty")!, latitude: 0.0, longitude: 0.0, tenants: []) //пустое значение стадиона когда нет матчей за период
        }
        
        loadGround(id: docID, db: db) //если не все данные о матчах загружены (еще нет того, что подгружается асинхронно (имен, download url's), но есть id нужного нам документа), это нужно когда приложение только запустилось
    }
    
    func loadGround (id: String, db: DBService){
        Firestore.firestore().collection("grounds").document(id).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data!["name"] as? String ?? ""
                let countryDocID = data!["country"] as? String ?? ""
                let photoPath = data!["photo"] as? String ?? ""
                
                //получили ID докумнта страны, теперь получаем остальные свойства (имя и код)
                Firestore.firestore().collection("countries").document(countryDocID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data!["name"] as? String ?? ""
                        let code = data!["code"] as? String ?? ""
                        
                        self.mostVisitedGround.country.name = name
                        self.mostVisitedGround.country.code = code
                    } else {
                        print("Document does not exist")
                    }
                }
                
                db.downloadURL(imagePath: photoPath) { data in
                    //data is value return by test function
                    DispatchQueue.main.async {
                        //data - значение, которое возвращает ф-ция downloadURL
                        let photoURL = data
                        
                        //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                        self.mostVisitedGround.photoURL = photoURL
                        self.mostVisitedGround.name = name
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func numberOfMatches (period: String, db: DBService) -> Int{
        var number = 0
        if (period == "Overall"){
            number = db.matches.count
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    number += 1
                }
            }
        }
        return number
    }
    
    func getMatchesForPeriod (period: String, db: DBService) -> [Match]{
        var matches = [Match]()
        
        if (period == "Overall"){
            for match in db.matches {
                    matches.append(match)
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                        matches.append(match)
                }
            }
        }
        
        return matches
    }
    
    func numberOfGrounds (period: String, db: DBService) -> Int{
        var grounds = Set<String>()
        
        if (period == "Overall"){
            for match in db.matches {
                grounds.insert((match.ground?.documentID)!)
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    grounds.insert((match.ground?.documentID)!)
                }
            }
        }
        
        return grounds.count
    }
    
    func getGroundsForPeriod (period: String, db: DBService) -> [Ground]{
        var groundsDocIDs = Set<String>()
        var grounds = [Ground]()
        
        if (period == "Overall"){
            for match in db.matches {
                if(groundsDocIDs.insert((match.ground?.documentID)!).inserted){ //если успешно
                    grounds.append(match.ground!)
                }
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    if(groundsDocIDs.insert((match.ground?.documentID)!).inserted){ //если успешно
                        grounds.append(match.ground!)
                    }
                }
            }
        }
        
        return grounds
    }
    
    func numberOfTeams (period: String, db: DBService) -> Int{
        var teams = Set<String>()
        
        if (period == "Overall"){
            for match in db.matches {
                teams.insert((match.home?.documentID)!)
                teams.insert((match.away?.documentID)!)
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    teams.insert((match.home?.documentID)!)
                    teams.insert((match.away?.documentID)!)
                }
            }
        }
        
        return teams.count
    }
    
    func getTeamsForPeriod (period: String, db: DBService) -> [Team]{
        var teamsDocIDs = Set<String>()
        var teams = [Team]()
        
        if (period == "Overall"){
            for match in db.matches {
                if(teamsDocIDs.insert((match.home?.documentID)!).inserted){ //если успешно
                    teams.append(match.home!)
                }
                if(teamsDocIDs.insert((match.away?.documentID)!).inserted){ //если успешно
                    teams.append(match.away!)
                }
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    if(teamsDocIDs.insert((match.home?.documentID)!).inserted){ //если успешно
                        teams.append(match.home!)
                    }
                    if(teamsDocIDs.insert((match.away?.documentID)!).inserted){ //если успешно
                        teams.append(match.away!)
                    }
                }
            }
        }
        
        return teams
    }
    
    func numberOfCountries (period: String, db: DBService) -> Int{
        var countries = Set<String>()
        
        if (period == "Overall"){
            for match in db.matches {
                countries.insert((match.ground?.country.documentID)!)
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    countries.insert((match.ground?.country.documentID)!)
                }
            }
        }
        
        return countries.count
    }
    
    func getCountriesForPeriod (period: String, db: DBService) -> [Country]{
        var countriesDocIDs = Set<String>()
        var countries = [Country]()
        
        if (period == "Overall"){
            for match in db.matches {
                if(countriesDocIDs.insert((match.ground?.country.documentID)!).inserted){ //если успешно
                    countries.append(match.ground!.country)
                }
            }
        } else {
            let calendar = Calendar.current
            
            for match in db.matches {
                if(calendar.component(.year, from: match.date) == Int(period)){
                    if(countriesDocIDs.insert((match.ground?.country.documentID)!).inserted){ //если успешно
                        countries.append(match.ground!.country)
                    }
                }
            }
        }
        
        return countries
    }
    
    // MARK: ChallengesView
    
    func numberOfVistedGrounds(grounds: [(id: UUID, ground: Ground,isVisited: Bool)]) -> String {
        let all = grounds.count
        var visited = 0
        for ground in grounds{
            if(ground.isVisited){
                visited += 1
            }
        }
        
        return "\(visited)/\(all)"
    }
    
    func isChallengeComplete(grounds: [(id: UUID, ground: Ground,isVisited: Bool)]) -> Bool {
        var isChallengeComplete = false
        
        let all = grounds.count
        var visited = 0
        for ground in grounds{
            if(ground.isVisited){
                visited += 1
            }
        }
        
        if(visited == all){
            isChallengeComplete = true
        }
        
        return isChallengeComplete
    }
}
