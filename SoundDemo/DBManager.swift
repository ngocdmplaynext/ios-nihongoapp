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
            try database.executeUpdate("create table if not exists theme(id integer primary key autoincrement, name text)", values: nil)
            try database.executeUpdate("create table if not exists deck(id integer primary key autoincrement, name text, themeid integer, foreign key(themeid) references theme(id))", values: nil)
            try database.executeUpdate("create table if not exists card(id integer primary key autoincrement, name text, deckid integer, foreign key(deckid) references deck(id))", values: nil)
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func createDumyData() {
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
            try database.executeUpdate("insert into theme (name) values (?)", values: ["挨拶"])
            try database.executeUpdate("insert into theme (name) values (?)", values: ["おしゃべり"])
            try database.executeUpdate("insert into theme (name) values (?)", values: ["気持ち"])
            try database.executeUpdate("insert into theme (name) values (?)", values: ["お出かけ"])
            
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["おはようございます", 1])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["こんにちは", 1])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["こんばんは", 1])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["おやすみなさい", 1])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["さようなら", 1])
            
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["いい天気ですね", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["風が強いですね", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["道が混んでいますね", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["運動はお好きですか", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["好きな食べ物はなんですか", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["出身はどちらですか", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["昨日は何をしていましたか", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["お元気そうですね", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["顔色が優れませんね", 2])
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["ご一緒しませんか", 2])
            
            try database.executeUpdate("insert into deck (name, themeid) values (?)", values: ["", 3])
            
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
}
