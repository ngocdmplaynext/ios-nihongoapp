//
//  NetworkManager.swift
//  SoundDemo
//
//  Created by ngocdm on 3/8/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit
import Alamofire

let baseApi = "https://japaneselearning.herokuapp.com/api/v1/"
let themePath = "themes"
let deckPath = "themes/%d/decks"
let cardPath = "decks/%d/cards"

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
        guard let url = URL(string: path) else {
            print("error when load init deck data")
            let error = NSError(domain: "sounddemo", code: -1, userInfo: ["msg" : "error when load init deck data"])
            completion?(nil, error)
            return
        }
        Alamofire.request(url).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    var decks = [Deck]()
                    if let arrDic = value as? [[String: AnyObject]] {
                        for deckDic in arrDic {
                            if let name = deckDic["name"] as? String, let deckId = deckDic["id"] as? Int, let themeId = deckDic["theme_id"] as? Int {
                                let deck = Deck(name: name, deckId: deckId, themeId: themeId)
                                //DBManager.shared.saveDeckData(deck: deck)
                                decks.append(deck)
                            }
                        }
                    }
                    completion?(decks, nil)
                case .failure(let error):
                    print(error)
                    completion?(nil, error as NSError?)
                }
        }
        
    }
    
    func getInitCardData(byDeckId deckId: Int, completion: ((_ cards: [Card]?, _ error: NSError?) -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: cardPath), deckId)
        guard let url = URL(string: path) else {
            print("error when load init card data")
            let error = NSError(domain: "sounddemo", code: -1, userInfo: ["msg" : "error when load init deck data"])
            completion?(nil, error)
            return
        }
        Alamofire.request(url).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    var cards = [Card]()
                    if let arrDic = value as? [[String: AnyObject]] {
                        for cardDic in arrDic {
                            if let name = cardDic["name"] as? String, let cardId = cardDic["id"] as? Int, let deckId = cardDic["deck_id"] as? Int, let audioUrl = cardDic["audio_url"] as? String {
                                let card = Card(name: name, cardId: cardId, deckId: deckId, audioUrl: audioUrl, bestScore: 0)
                               // DBManager.shared.saveCardData(card: card)
                                cards.append(card)
                            }
                        }
                    }
                    completion?(cards, nil)
                case .failure(let error):
                    print(error)
                    completion?(nil, error as NSError?)
                }
        }
        
    }
    
    func createDeck(themeId:Int, topic: String, sentences: [RecordSentence], completion: (() -> Void)? = nil) {
        let path: String = String(format: urlWithPath(path: deckPath), themeId)
        
        guard let url = try? URLRequest(url: path, method: .post, headers: nil) else {
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
                    completion?()
                }
                
            case .failure(_):
                completion?()
                break
            }
            
        })
    }
    
    func downLoadFile(card: Card, completion: ((_ filePath: URL?) -> Void)? = nil) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("card\(card.cardId).m4a")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(card.audioUrl, to: destination).response { response in
            print("\(response.error)")
            completion?(response.destinationURL)
        }
    }
    
}


