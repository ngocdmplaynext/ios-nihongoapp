//
//  DBManager.swift
//  SoundDemo
//
//  Created by ngocdm on 3/2/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    static let shared = DBManager()
    
    let fileUrl = try? FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("database.sqlite")
    
    func createTable() {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return
        }
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("create table if not exists theme(id integer primary key, name text)", values: nil)
            try database.executeUpdate("create table if not exists deck(id integer primary key, name text, theme_id integer)", values: nil)
            try database.executeUpdate("create table if not exists card(id integer primary key, name text, deck_id integer, audio_url text, best_score integer)", values: nil)
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func saveThemeData(theme: Theme) {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return
        }
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("insert into theme (name, id) values (?,?)", values: [theme.name, theme.themeId])
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func saveDeckData(deck: Deck) {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return
        }
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("insert into deck (name, id, theme_id) values (?,?,?)", values: [deck.name, deck.deckId, deck.themeId])
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func saveCardData(card: Card) {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return
        }
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("insert into card (name, id, audio_url, deck_id, best_score) values (?,?,?,?,?)", values: [card.name, card.cardId, card.audioUrl, card.deckId, card.bestScore])
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func hasThemeData() -> Bool {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return false
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return false
        }
        
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        var returnValue: Bool = false
        
        if let rs = database.executeQuery("select count(*) from theme", withArgumentsIn:nil) {
            if rs.next() {
                returnValue = rs.int(forColumnIndex: 0) != 0
            }
        }
        
        database.close()
        
        return returnValue
    }
    
    func hasDeckData(byThemeId themeId: Int) -> Bool {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return false
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return false
        }
        
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        var returnValue: Bool = false
        
        if let rs = database.executeQuery("select count(*) from deck where theme_id = ?", withArgumentsIn:[themeId]) {
            if rs.next() {
                returnValue = rs.int(forColumnIndex: 0) != 0
            }
        }
        
        database.close()
        
        return returnValue
    }
    
    func hasCardData(byDeckId deckId: Int) -> Bool {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return false
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return false
        }
        
        guard database.open() else {
            print("Unable to open database")
            return false
        }
        
        var returnValue: Bool = false
        
        if let rs = database.executeQuery("select count(*) from card where deck_id = ?", withArgumentsIn:[deckId]) {
            if rs.next() {
                returnValue = rs.int(forColumnIndex: 0) != 0
            }
        }
        
        database.close()
        
        return returnValue
    }
    
    func loadThemesData() -> [Theme] {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return [Theme]()
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return [Theme]()
        }
        
        guard database.open() else {
            print("Unable to open database")
            return [Theme]()
        }
        
        var themes: [Theme] = [Theme]()
        
        if let rs = database.executeQuery("select * from theme", withArgumentsIn:nil) {
            while rs.next() {
                let themeId: Int = Int(rs.int(forColumnIndex: 0))
                let name: String = rs.string(forColumnIndex: 1) ?? ""
                let theme = Theme(name: name, themeId: themeId)
                themes.append(theme)
            }
        }
        
        database.close()
        
        return themes
    }
    
    func loadDecksData(byThemeId themeId: Int) -> [Deck] {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return [Deck]()
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return [Deck]()
        }
        
        guard database.open() else {
            print("Unable to open database")
            return [Deck]()
        }
        
        var decks: [Deck] = [Deck]()
        
        if let rs = database.executeQuery("select * from deck where theme_id = ?", withArgumentsIn:[themeId]) {
            while rs.next() {
                let deckId: Int = Int(rs.int(forColumnIndex: 0))
                let name: String = rs.string(forColumnIndex: 1) ?? ""
                let themeId: Int = Int(rs.int(forColumnIndex: 2))
                let deck = Deck(name: name, deckId: deckId, themeId: themeId)
                decks.append(deck)
            }
        }
        
        database.close()
        
        return decks
    }
    
    func loadCardsData(byDeckId deckId: Int) -> [Card] {
        guard let filePath = fileUrl?.path else {
            print("can't find database")
            return [Card]()
        }
        
        guard let database = FMDatabase(path: filePath) else {
            print("unable to create database")
            return [Card]()
        }
        
        guard database.open() else {
            print("Unable to open database")
            return [Card]()
        }
        
        var cards: [Card] = [Card]()
        
        if let rs = database.executeQuery("select * from card where deck_id = ?", withArgumentsIn:[deckId]) {
            while rs.next() {
                let cardId: Int = Int(rs.int(forColumnIndex: 0))
                let name: String = rs.string(forColumnIndex: 1) ?? ""
                let deckId: Int = Int(rs.int(forColumnIndex: 2))
                let audioUrl: String = rs.string(forColumnIndex: 3) ?? ""
                let bestScore: Int = Int(rs.int(forColumnIndex: 4))
                
                let card = Card(name: name, cardId: cardId, deckId: deckId, audioUrl: audioUrl, bestScore: bestScore)
                cards.append(card)
            }
        }
        
        database.close()
        
        return cards
    }

}
