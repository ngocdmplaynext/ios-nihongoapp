//
//  NetworkManager.swift
//  SoundDemo
//
//  Created by ngocdm on 3/8/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit
import Alamofire

let baseApi = "http://172.16.96.20:3000/api/v1/"
let themePath = "themes"
let deckPath = "themes/%d/decks"
let cardPath = "decks/%d/cards"
let loginPath = "sessions"
let registerPath = "users"
let myDeckPath = "mydecks"
let teachersPath = "teachers"
let bookmarkPath = "users/%d/bookmarks"
let practicePath = "cards/%d/practices"
let cardAudioUrlPath = "cards/%d/audio_url"

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    func urlWithPath(path: String) -> String {
        return baseApi + path
    }
    
    func getInitThemeData(completion: ((_ themes: [Theme]?, _ error: NSError?) -> Void)? = nil) {
        let path: String = urlWithPath(path: themePath)
        guard let url = URL(string: path) else {
            print("error when load init theme data")
            let error = NSError(domain: "sounddemo", code: -1, userInfo: ["msg" : "error when load init theme data"])
            completion?(nil, error)
            return
        }
        Alamofire.request(url).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    var themes = [Theme]()
                    if let arrDic = value as? [[String: AnyObject]] {
                        for themeDic in arrDic {
                            if let name = themeDic["name"] as? String, let themeId = themeDic["id"] as? Int {
                                let theme = Theme(name: name, themeId: themeId)
                                //DBManager.shared.saveThemeData(theme: theme)
                                themes.append(theme)
                            }
                        }
                    }
                    completion?(themes, nil)
                case .failure(let error):
                    print(error)
                    completion?(nil, error as NSError?)
                }
        }
    
    }
    
    func getInitDeckData(byThemeId themeId: Int, completion: ((_ decks: [Deck]?, _ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: deckPath), themeId)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .get, headers: headers) else {
            return
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                if let code = response.response?.statusCode, code != HTTP_OK {
                    let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                    completion?(nil, error)
                } else {
                    switch response.result {
                    case .success(let value):
                        if let dicArr = value as? [[String: AnyObject]] {
                            var decks = [Deck]()
                            for dic in dicArr {
                                if let name = dic["name"] as? String, let deckId = dic["id"] as? Int, let themeId = dic["theme_id"] as? Int {
                                    let deck = Deck(name: name, deckId: deckId, themeId: themeId)
                                    decks.append(deck)
                                }
                            }
                            completion?(decks, nil)
                        }
                    case .failure(let error):
                        completion?(nil, error as NSError?)
                    }
                }
        }        
    }
    
    func getInitCardData(byDeckId deckId: Int, completion: ((_ cards: [Card]?, _ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: cardPath), deckId)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .get, headers: headers) else {
            return
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                if let code = response.response?.statusCode, code != HTTP_OK {
                    let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                    completion?(nil, error)
                } else {
                    switch response.result {
                    case .success(let value):
                        if let dicArr = value as? [[String: AnyObject]] {
                            var cards = [Card]()
                            for cardDic in dicArr {
                                if let name = cardDic["name"] as? String, let cardId = cardDic["id"] as? Int, let deckId = cardDic["deck_id"] as? Int, let bestScore = cardDic["best_score"] as? Int {
                                    let card = Card(name: name, cardId: cardId, deckId: deckId, bestScore: bestScore)
                                    cards.append(card)
                                }
                            }
                            completion?(cards, nil)
                        }
                        
                    case .failure(let error):
                        print(error)
                        completion?(nil, error as NSError?)
                    }
                }
        }
        
    }
    
    func createDeck(themeId:Int, topic: String, sentences: [RecordSentence], completion: ((_ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: deckPath), themeId)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .post, headers: headers) else {
            return
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            let sentenceArr = sentences.map({ (s) -> String in
                return s.sentence
            })
            
            let sentenceStr = sentenceArr.joined(separator: ",")
            multipartFormData.append(sentenceStr.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "sentence")
            multipartFormData.append(topic.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "topic")
            
            var i = 0
            var fileNames: [String] = [String]()
            for sentence in sentences {
                i = i + 1
                let fileName = "file\(i)"
                multipartFormData.append(sentence.audioUrl, withName: fileName)
                fileNames.append(fileName)
            }
            
            let fileNamesStr = fileNames.joined(separator: ",")
            multipartFormData.append(fileNamesStr.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "file_name")
        }, with: url, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                
                upload.responseJSON { response in
                    //print response.result
                    if let code = response.response?.statusCode, code != HTTP_OK {
                        let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                        completion?(error)
                    } else {
                        completion?(nil)
                    }
                }
                
            case .failure(let error):
                completion?(error as NSError?)
                break
            }
            
        })
    }
    
    func myDeck(completion: ((_ decks: [Deck]?,_ error: NSError?) -> Void)? = nil) {
        let path: String = urlWithPath(path: myDeckPath)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .get, headers: headers) else {
            return
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                if let code = response.response?.statusCode, code != HTTP_OK {
                    let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                    completion?(nil, error)
                } else {
                    switch response.result {
                    case .success(let value):
                        if let dicArr = value as? [[String: AnyObject]] {
                            var decks = [Deck]()
                            for dic in dicArr {
                                if let name = dic["name"] as? String, let deckId = dic["id"] as? Int, let themeId = dic["theme_id"] as? Int {
                                    let deck = Deck(name: name, deckId: deckId, themeId: themeId)
                                    decks.append(deck)
                                }
                            }
                            completion?(decks, nil)
                        }
                    case .failure(let error):
                        completion?(nil, error as NSError?)
                    }
                }
        }
    }
    
    func downLoadCardAudio(card: Card, completion: ((_ filePath: URL?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: cardAudioUrlPath), card.cardId)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = filePath(withName: "card\(card.cardId).m4a")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(path, to: destination).response { response in
            completion?(response.destinationURL)
        }
    }
    
    func downloadListCardAudioUrl(cards: [Card], completion: ((_ error: NSError?) -> Void)? = nil) {
        let downloadGroup = DispatchGroup()
        var error: NSError?
        for card in cards {
            downloadGroup.enter()
            downLoadCardAudio(card: card, completion: { (path) in
                if path == nil {
                    error = NSError(domain: "sounddemo", code: -1, userInfo: nil)
                }
                downloadGroup.leave()
            })
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completion?(error)
        }
    }
    
    func login(email: String, password: String, completion: ((_ authToken: String?,_ name: String?,_ type: Int?,_ error: NSError?) -> Void)? = nil) {
        let path = urlWithPath(path: loginPath)
        
        let parameters = ["email": email, "password": password]
        
        Alamofire.request(path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            if let code = response.response?.statusCode, code != HTTP_OK {
                let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                completion?(nil, nil, nil, error)
            } else {
                switch response.result {
                case .success(let value):
                    if let result = value as? [String: AnyObject], let authToken =  result["auth_token"] as? String, let name = result["name"] as? String, let type = result["type"] as? Int {
                        completion?(authToken, name, type, nil)
                    }
                case .failure(let error):
                    completion?(nil, nil, nil, error as NSError?)
                }
            }

        }
    }
    
    func register(name: String, email: String, password: String, passwordConfirm: String, completion: ((_ error: NSError?) -> Void)? = nil) {
        let path = urlWithPath(path: registerPath)
        
        let parameters = ["name": name, "email": email, "password": password, "password_confirmation": passwordConfirm]
        
        Alamofire.request(path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            if let code = response.response?.statusCode, code != HTTP_OK {
                let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                completion?(error)
            } else {
                completion?(nil)
            }
        }
    }
    
    func teachers(completion: ((_ users: [User]?,_ error: NSError?) -> Void)? = nil) {
        let path: String = urlWithPath(path: teachersPath)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .get, headers: headers) else {
            return
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                if let code = response.response?.statusCode, code != HTTP_OK {
                    let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                    completion?(nil, error)
                } else {
                    switch response.result {
                    case .success(let value):
                        if let dicArr = value as? [[String: AnyObject]] {
                            var users = [User]()
                            for dic in dicArr {
                                if let userId = dic["user_id"] as? Int, let name = dic["name"] as?
                                    String, let bookmarked = dic["bookmarked"] as? Bool {
                                    let user = User(userId: userId, name: name, bookmark: bookmarked)
                                    users.append(user)
                                }
                            }
                            completion?(users, nil)
                        }

                    case .failure(let error):
                        completion?(nil, error as NSError?)
                    }
                }
        }
    }
    
    func bookmarks(user: User, completion: ((_ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: bookmarkPath), user.userId)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .post, headers: headers) else {
            return
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                if let code = response.response?.statusCode, code != HTTP_OK {
                    let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                    completion?(error)
                } else {
                    completion?(nil)
                }
        }

    }

    func unbookmarks(user: User, completion: ((_ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: bookmarkPath), user.userId)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        guard let url = try? URLRequest(url: path, method: .delete, headers: headers) else {
            return
        }
        
        Alamofire.request(url)
            .responseJSON { response in
                if let code = response.response?.statusCode, code != HTTP_OK {
                    let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                    completion?(error)
                } else {
                    completion?(nil)
                }
        }
        
    }
    
    func practices(card: Card, completion: ((_ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: practicePath), card.cardId)
        var headers: [String: String]? = nil
        if let authToken = UserDefault.shared.getToken() {
            headers = ["Auth-Token": authToken]
        }
        
        let parameters = ["best_score": card.bestScore]
        
        Alamofire.request(path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let code = response.response?.statusCode, code != HTTP_OK {
                let error = NSError(domain: "sounddemo", code: code, userInfo: nil)
                completion?(error)
            } else {
                completion?(nil)
            }
        }
        
    }
}


