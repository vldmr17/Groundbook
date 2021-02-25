//
//  DBService.swift
//  Groundbook
//
//  Created by admin on 13.02.2021.
//

import Foundation
import Firebase
import Combine

class DBService : ObservableObject {
    @Published var countries = [Country]()
    @Published var matches = [Match]()
    @Published var challenges = [Challenge]()
    
    @Published var isAllDataLoaded = false //все ли данные загружены
    
    @Published var isAllCountriesOfMatchGroundsLoaded = (all: 0, loaded: 0) //для отслеживания все ли страны (стадионов) загружены. Важно знать дождаться загрузки для расчета статистики посещенных стран
    
    @Published var isAllTenantsOfMatchGroundsLoaded = (all: 0, loaded: 0)
    
    @Published var isAllMatchGroundsLoaded = (all: 0, loaded: 0) //для отслеживания вся ли инфа о стадионах загружена. Важно дождаться статус загрузки для получения startup locations на главной карте
    
    func getCountries() {
        Firestore.firestore().collection("countries").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            //очищаем массив тк старые элементы могут быть добавлены повторно (в случае изменения на сервере, тк прослушивается состояние, в массив будут добавлены все элементы коллекции, соотв. старые перед этим надо удалить из массива)
            self.countries.removeAll()
            
            for i in 0 ..< documents.count {
                let documentID = documents[i].documentID
                
                let data = documents[i].data()
                let name = data["name"] as? String ?? ""
                let code = data["code"] as? String ?? ""
                
                let country = Country(id: .init(), documentID: documentID, name: name, code: code)
                self.countries.append(country)
            }
        }
    }
    
    func getMatches () {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("matches").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            print("get matches before")
            
            //при добавлении/изменении данных на сервере, если в документе есть поле типа Timestamp, snapshot listener выполнится два раза, что может привести к дублированию данных (например tenants у ground). Поэтому проверяем есть ли данные, ожидающие записи
            if(!querySnapshot!.metadata.hasPendingWrites){
            
            //для отслеживания все ли страны (стадионов) загружены. Важно знать статус загрузки для расчета статистики посещенных стран
            self.isAllCountriesOfMatchGroundsLoaded.loaded = 0
            self.isAllCountriesOfMatchGroundsLoaded.all = documents.count
            
            //для отслеживания вся ли инфа о стадионах загружена. Важно знать статус загрузки для получения startup locations на карте
            self.isAllMatchGroundsLoaded.loaded = 0
            self.isAllMatchGroundsLoaded.all = documents.count
            
            self.isAllTenantsOfMatchGroundsLoaded.loaded = 0
            self.isAllTenantsOfMatchGroundsLoaded.all = documents.count
            
            //очищаем массив тк старые элементы могут быть добавлены повторно (в случае изменения на сервере, тк прослушивается состояние, в массив будут добавлены все элементы коллекции, соотв. старые перед этим надо удалить из массива)
            self.matches.removeAll()
            
            
            //если нет ни одного матча в БД
            if(documents.count == 0){
                self.isAllDataLoaded = true
            }
            
            for i in 0 ..< documents.count {
                let documentID = documents[i].documentID
                
                let data = documents[i].data()
                let homeDocID = data["home"] as? String ?? ""
                let awayDocID = data["away"] as? String ?? ""
                let homeScore = data["homeScore"] as? Int ?? 0
                let awayScore = data["awayScore"] as? Int ?? 0
                let groundDocID = data["ground"] as? String ?? ""
                let tournamentDocID = data["tournament"] as? String ?? ""
                let date = data["date"] as? Timestamp ?? Timestamp() //позже при инициализации обьекта Match конвертируем в тип Date
                
                let match = Match(id: .init(),
                                  documentID: documentID,
                                  home: Team(id: .init(), documentID: homeDocID, name: "", logoURL: URL(string: "empty")!, venue: "", country: Country(id: .init(), documentID: "", name: "", code: "")),
                                  away: Team(id: .init(), documentID: awayDocID, name: "", logoURL: URL(string: "empty")!, venue: "", country: Country(id: .init(), documentID: "", name: "", code: "")),
                                  homeScore: homeScore,
                                  awayScore: awayScore,
                                  ground: Ground(id: .init(), documentID: groundDocID, name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "empty")!, latitude: 0.0, longitude: 0.0, tenants: []),
                                  tournament: Tournament(id: .init(), documentID: tournamentDocID, name: "", logoURL: URL(string: "empty")!, country: Country(id: .init(), documentID: "", name: "", code: "")),
                                  date: date.dateValue())
                
                self.matches.append(match)
                
                //получаем название и URL лого домашней команды (лого нужно загрузить асинхронно)
                Firestore.firestore().collection("teams").document(homeDocID).getDocument { (document, error) in
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
                                
                                var index = 0
                                for match in self.matches {
                                    if (match.home?.documentID == homeDocID){
                                        self.matches[index].home?.country.documentID = countryDocID
                                        self.matches[index].home?.country.name = name
                                        self.matches[index].home?.country.code = code
                                    }
                                    index += 1
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                        
                        self.downloadURL(imagePath: logoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let logoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for match in self.matches {
                                    if (match.home?.documentID == homeDocID){
                                        self.matches[index].home?.logoURL = logoURL
                                        self.matches[index].home?.name = name
                                    }
                                    index += 1
                                }
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
                
                //получаем название и URL лого гостевой команды (лого нужно загрузить асинхронно)
                Firestore.firestore().collection("teams").document(awayDocID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data!["name"] as? String ?? ""
                        let countryDocID = data!["country"] as? String ?? ""
                        let logoPath = data!["logo"] as? String ?? ""
                        
                        //получили ID документа страны, теперь получаем остальные свойства (имя и код)
                        Firestore.firestore().collection("countries").document(countryDocID).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let name = data!["name"] as? String ?? ""
                                let code = data!["code"] as? String ?? ""
                                
                                var index = 0
                                for match in self.matches {
                                    if (match.away?.documentID == awayDocID){
                                        self.matches[index].away?.country.documentID = countryDocID
                                        self.matches[index].away?.country.name = name
                                        self.matches[index].away?.country.code = code
                                    }
                                    index += 1
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                        
                        self.downloadURL(imagePath: logoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let logoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for match in self.matches {
                                    if (match.away?.documentID == awayDocID){
                                        self.matches[index].away?.logoURL = logoURL
                                        self.matches[index].away?.name = name
                                    }
                                    index += 1
                                }
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
                
                //получаем название и URL фото стадиона (фото нужно загрузить асинхронно)
                Firestore.firestore().collection("grounds").document(groundDocID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data!["name"] as? String ?? ""
                        let countryDocID = data!["country"] as? String ?? ""
                        let opened = data!["opened"] as? Int ?? 0
                        let capacity = data!["capacity"] as? Int ?? 0
                        let isDemolished = data!["isDemolished"] as? Bool ?? false
                        let photoPath = data!["photo"] as? String ?? ""
                        let coordinates = data!["coordinates"] as? GeoPoint
                        let tenants = data!["tenants"] as? [String] ?? []
                        
                        //получили ID докумнта страны, теперь получаем остальные свойства (имя и код)
                        Firestore.firestore().collection("countries").document(countryDocID).getDocument { (document, error) in
                            if let document = document, document.exists {
                                
                                let data = document.data()
                                let name = data!["name"] as? String ?? ""
                                let code = data!["code"] as? String ?? ""
                                
                                var index = 0
                                for match in self.matches {
                                    if (match.documentID == documentID){
                                        self.matches[index].ground?.country.documentID = countryDocID
                                        self.matches[index].ground?.country.name = name
                                        self.matches[index].ground?.country.code = code
                                        
                                        print("\(self.isAllCountriesOfMatchGroundsLoaded.loaded) \(groundDocID)")
                                        
                                        self.isAllCountriesOfMatchGroundsLoaded.loaded += 1//для отслеживания все ли страны (стадионов) загружены. Важно знать статус загрузки для расчета статистики посещенных стран (т.к это данные третьей волны)
                                        
                                        if(self.isAllCountriesOfMatchGroundsLoaded.all == self.isAllCountriesOfMatchGroundsLoaded.loaded && self.isAllMatchGroundsLoaded.all == self.isAllMatchGroundsLoaded.loaded && self.isAllTenantsOfMatchGroundsLoaded.all == self.isAllTenantsOfMatchGroundsLoaded.loaded){
                                            self.isAllDataLoaded = true
                                        }
                                    }
                                    index += 1
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                        
                        self.downloadURL(imagePath: photoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let photoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for match in self.matches {
                                    if (match.documentID == documentID){
                                        self.matches[index].ground?.photoURL = photoURL
                                        self.matches[index].ground?.name = name
                                        self.matches[index].ground?.latitude = coordinates!.latitude
                                        self.matches[index].ground?.longitude = coordinates!.longitude
                                        self.matches[index].ground?.opened = opened
                                        self.matches[index].ground?.isDemolished = isDemolished
                                        self.matches[index].ground?.capacity = capacity
                                        print(self.matches.count)
                                        
                                        self.isAllMatchGroundsLoaded.loaded += 1 //для отслеживания вся ли инфа о стадионах загружена. Важно знать статус загрузки получения startup locations на карте
                                        
                                        if(self.isAllCountriesOfMatchGroundsLoaded.all == self.isAllCountriesOfMatchGroundsLoaded.loaded && self.isAllMatchGroundsLoaded.all == self.isAllMatchGroundsLoaded.loaded && self.isAllTenantsOfMatchGroundsLoaded.all == self.isAllTenantsOfMatchGroundsLoaded.loaded){
                                            self.isAllDataLoaded = true
                                        }
                                    }
                                    index += 1
                                }
                            }
                        }
                        
                        if(tenants.count > 1){
                            self.isAllTenantsOfMatchGroundsLoaded.all += (tenants.count - 1)
                        }
                        
                        //tenants стадиона
                        for tenant in tenants {
                            Firestore.firestore().collection("teams").document(tenant).getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let data = document.data()
                                    let name = data!["name"] as? String ?? ""
                                    let logoPath = data!["logo"] as? String ?? ""
                                    
                                    self.downloadURL(imagePath: logoPath) { data in
                                        //data is value return by test function
                                        DispatchQueue.main.async {
                                            //data - значение, которое возвращает ф-ция downloadURL
                                            let logoURL = data
                                            
                                            var index = 0
                                            for match in self.matches {
                                                if (match.documentID == documentID){
                                                    let newTenant = Team(id: .init(), documentID: tenant, name: name, logoURL: logoURL, venue: groundDocID, country: Country(id: .init(), documentID: "", name: "", code: ""))
                                                    self.matches[index].ground?.tenants.append(newTenant)
                                                    
                                                    self.isAllTenantsOfMatchGroundsLoaded.loaded += 1
                                                    if(self.isAllCountriesOfMatchGroundsLoaded.all == self.isAllCountriesOfMatchGroundsLoaded.loaded && self.isAllMatchGroundsLoaded.all == self.isAllMatchGroundsLoaded.loaded && self.isAllTenantsOfMatchGroundsLoaded.all == self.isAllTenantsOfMatchGroundsLoaded.loaded){
                                                        self.isAllDataLoaded = true
                                                    }
                                                }
                                                index += 1
                                            }
                                        }
                                    }
                                } else {
                                    print("Document does not exist")
                                }
                            }
                        }
                        
                    } else {
                        print("Document does not exist")
                    }
                }
                
                //получаем название и URL лого турнира (лого нужно загрузить асинхронно)
                Firestore.firestore().collection("tournaments").document(tournamentDocID).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data!["name"] as? String ?? ""
                        let logoPath = data!["logo"] as? String ?? ""
                        let countryDocID = data!["country"] as? String ?? ""
                        
                        //получили ID документа страны, теперь получаем остальные свойства (имя и код)
                        Firestore.firestore().collection("countries").document(countryDocID).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let data = document.data()
                                let name = data!["name"] as? String ?? ""
                                let code = data!["code"] as? String ?? ""
                                
                                var index = 0
                                for match in self.matches {
                                    if (match.documentID == documentID){
                                        self.matches[index].tournament?.country.name = name
                                        self.matches[index].tournament?.country.code = code
                                        break
                                    }
                                    index += 1
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                        
                        self.downloadURL(imagePath: logoPath) { data in
                            //data is value return by test function
                            DispatchQueue.main.async {
                                //data - значение, которое возвращает ф-ция downloadURL
                                let logoURL = data
                                
                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                var index = 0
                                for match in self.matches {
                                    if (match.documentID == documentID){
                                        self.matches[index].tournament?.logoURL = logoURL
                                        self.matches[index].tournament?.name = name
                                    }
                                    index += 1
                                }
                            }
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
    
            }
            }
        }
    }
    
    func getChallenges () {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("challenges").order(by: "name", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            print("getChallenges")
            
            //очищаем массив тк старые элементы могут быть добавлены повторно (в случае изменения на сервере, тк прослушивается состояние, в массив будут добавлены все элементы коллекции, соотв. старые перед этим надо удалить из массива)
            self.challenges.removeAll()
            
            for i in 0 ..< documents.count {
                let documentID = documents[i].documentID
                
                let data = documents[i].data()
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let groundsDict = data["grounds"] as? [[String:Any]] ?? []
                
                var groundsTuple:[(id: UUID,ground: Ground,isVisited: Bool)] = []
                
                for dict in groundsDict {
                    let tuple = (id: UUID(), ground: Ground(id: .init(), documentID: dict["ground"] as! String, name: "", capacity: 0, isDemolished: false, opened: 0, country: Country(id: .init(), documentID: "", name: "", code: ""), photoURL: URL(string: "emptyurl")!, latitude: 0.0, longitude: 0.0, tenants: []),isVisited: dict["isVisited"] as! Bool)
                    groundsTuple.append(tuple)
                    
                    //получаем название и URL фото стадиона (фото нужно загрузить асинхронно)
                    Firestore.firestore().collection("grounds").document(dict["ground"] as! String).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let data = document.data()
                            let name = data!["name"] as? String ?? ""
                            let countryDocID = data!["country"] as? String ?? ""
                            let photoPath = data!["photo"] as? String ?? ""
                            let coordinates = data!["coordinates"] as? GeoPoint
                            let tenants = data!["tenants"] as? [String] ?? []
                            let opened = data!["opened"] as? Int ?? 0
                            let capacity = data!["capacity"] as? Int ?? 0
                            
                            //получили ID докумнта страны, теперь получаем остальные свойства (имя и код)
                            Firestore.firestore().collection("countries").document(countryDocID).getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let data = document.data()
                                    let name = data!["name"] as? String ?? ""
                                    let code = data!["code"] as? String ?? ""
                                    
                                    var chlngIndex = 0
                                    for challenge in self.challenges {
                                        if (challenge.documentID == documentID){
                                            var grndIndex = 0
                                            for tuple in challenge.grounds{
                                                if(tuple.ground.documentID == dict["ground"] as! String){
                                                    self.challenges[chlngIndex].grounds[grndIndex].ground.country.name = name
                                                    self.challenges[chlngIndex].grounds[grndIndex].ground.country.code = code
                                                    break
                                                }
                                                grndIndex += 1
                                            }
                                            break
                                        }
                                        chlngIndex += 1
                                    }
                                } else {
                                    print("Document does not exist")
                                }
                            }
                            
                            self.downloadURL(imagePath: photoPath) { data in
                                //data is value return by test function
                                DispatchQueue.main.async {
                                    //data - значение, которое возвращает ф-ция downloadURL
                                    let photoURL = data
                                    
                                    //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                    var chlngIndex = 0
                                    for challenge in self.challenges {
                                        if (challenge.documentID == documentID){
                                                var grndIndex = 0
                                                for tuple in challenge.grounds{
                                                    if(tuple.ground.documentID == dict["ground"] as! String){
                                                        self.challenges[chlngIndex].grounds[grndIndex].ground.photoURL = photoURL
                                                        self.challenges[chlngIndex].grounds[grndIndex].ground.name = name
                                                        self.challenges[chlngIndex].grounds[grndIndex].ground.latitude = coordinates!.latitude
                                                        self.challenges[chlngIndex].grounds[grndIndex].ground.longitude = coordinates!.longitude
                                                        self.challenges[chlngIndex].grounds[grndIndex].ground.opened = opened
                                                        self.challenges[chlngIndex].grounds[grndIndex].ground.capacity = capacity
                                                        break
                                                    }
                                                    grndIndex += 1
                                                }
                                                break
                                        }
                                        chlngIndex += 1
                                    }
                                }
                            }
                            
                            //tenants стадиона
                            for tenant in tenants {
                                Firestore.firestore().collection("teams").document(tenant).getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        let data = document.data()
                                        let name = data!["name"] as? String ?? ""
                                        let logoPath = data!["logo"] as? String ?? ""
                                        
                                        self.downloadURL(imagePath: logoPath) { data in
                                            //data is value return by test function
                                            DispatchQueue.main.async {
                                                //data - значение, которое возвращает ф-ция downloadURL
                                                let logoURL = data
                                                
                                                //подгрузили URL, теперь ищем нужный элемент в массиве и изменяем поле logoURL, которое ранее было инициализировано "пустым" значением
                                                var chlngIndex = 0
                                                for challenge in self.challenges {
                                                    if (challenge.documentID == documentID){
                                                            var grndIndex = 0
                                                            for tuple in challenge.grounds{
                                                                if(tuple.ground.documentID == dict["ground"] as! String){
                                                                    
                                                                    let newTenant = Team(id: .init(), documentID: tenant, name: name, logoURL: logoURL, venue: dict["ground"] as! String, country: Country(id: .init(), documentID: "", name: "", code: ""))
                                                                    self.challenges[chlngIndex].grounds[grndIndex].ground.tenants.append(newTenant)
                                                                    break
                                                                }
                                                                grndIndex += 1
                                                            }
                                                            break
                                                    }
                                                    chlngIndex += 1
                                                }
                                            }
                                        }
                                    } else {
                                        print("Document does not exist")
                                    }
                                }
                            }
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
                
                let challenge = Challenge(id: .init(), documentID: documentID, name: name, description: description, grounds: groundsTuple)
                
                self.challenges.append(challenge)
    
            }
        }
    }
    
    func downloadURL (imagePath: String, completion: @escaping (URL) -> () ){
        let storage = Storage.storage()
        let imageRef = storage.reference(forURL: "gs://groundbook-6309d.appspot.com/"+imagePath)
        var imageURL = URL(string: "")
        
        imageRef.downloadURL { url, error in
            DispatchQueue.global(qos: .background).async {
                if let error = error {
                    print(error)
                } else {
                    imageURL = url
                }
                completion(imageURL ?? URL(string: "emptyurl")!)
            }
        }
    }
}
