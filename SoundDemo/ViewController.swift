//
//  ViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 2/7/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var themes = [Theme]()
    let mecab = MeCabUtil()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "カテゴリー"
        
        let text = "ドシャ降りだ"
        let arr = mecab.parseToNode(with: text)
        
        for item in arr! {
            print("\((item as! Node).feature)")
        }
        
        if revealViewController() != nil {
            menuBtn.target = revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        initData()
    }

    func initData() {
        var decks = [Deck]()
        let card = Card(name: "おはようございます", romaji: mecab.stringJapanese(toRomaji: "おはようございます"), bestScore: 0)
        let card1 = Card(name: "こんにちは", romaji: mecab.stringJapanese(toRomaji: "こんにちは"), bestScore: 0)
        let card2 = Card(name: "こんばんは", romaji: mecab.stringJapanese(toRomaji: "こんばんは"), bestScore: 0)
        let card3 = Card(name: "おやすみなさい", romaji: mecab.stringJapanese(toRomaji: "おやすみなさい"), bestScore: 0)
        let card4 = Card(name: "さようなら", romaji: mecab.stringJapanese(toRomaji: "さようなら"), bestScore: 0)
        
        decks.append(Deck(name: card.name, card: card))
        decks.append(Deck(name: card1.name, card: card1))
        decks.append(Deck(name: card2.name, card: card2))
        decks.append(Deck(name: card3.name, card: card3))
        decks.append(Deck(name: card4.name, card: card4))
        
        themes.append(Theme(name: "挨拶", decks: decks))
        
        
        var decks1 = [Deck]()
        let card01 = Card(name: "いい天気ですね", romaji: mecab.stringJapanese(toRomaji: "いい天気ですね"), bestScore: 0)
        let card11 = Card(name: "風が強いですね", romaji: mecab.stringJapanese(toRomaji: "風が強いですね"), bestScore: 0)
        let card21 = Card(name: "道が混んでいますね", romaji: mecab.stringJapanese(toRomaji: "道が混んでいますね"), bestScore: 0)
        let card31 = Card(name: "運動はお好きですか", romaji: mecab.stringJapanese(toRomaji: "運動はお好きですか"), bestScore: 0)
        let card41 = Card(name: "好きな食べ物はなんですか", romaji: mecab.stringJapanese(toRomaji: "好きな食べ物はなんですか"), bestScore: 0)
        let card51 = Card(name: "出身はどちらですか", romaji: mecab.stringJapanese(toRomaji: "出身はどちらですか"), bestScore: 0)
        let card61 = Card(name: "昨日は何をしていましたか", romaji: mecab.stringJapanese(toRomaji: "昨日は何をしていましたか"), bestScore: 0)
        
        let card71 = Card(name: "お元気そうですね", romaji: mecab.stringJapanese(toRomaji: "お元気そうですね"), bestScore: 0)
        let card81 = Card(name: "顔色が優れませんね", romaji: mecab.stringJapanese(toRomaji: "顔色が優れませんね"), bestScore: 0)
        
        let card91 = Card(name: "ご一緒しませんか", romaji: mecab.stringJapanese(toRomaji: "ご一緒しませんか"), bestScore: 0)
        
        
        decks1.append(Deck(name: card01.name, card: card01))
        decks1.append(Deck(name: card11.name, card: card11))
        decks1.append(Deck(name: card21.name, card: card21))
        decks1.append(Deck(name: card31.name, card: card31))
        decks1.append(Deck(name: card41.name, card: card41))
        decks1.append(Deck(name: card51.name, card: card51))
        decks1.append(Deck(name: card61.name, card: card61))
        decks1.append(Deck(name: card71.name, card: card71))
        decks1.append(Deck(name: card81.name, card: card81))
        decks1.append(Deck(name: card91.name, card: card91))
        
        themes.append(Theme(name: "おしゃべり", decks: decks1))
        
        var decks2 = [Deck]()
        let card02 = Card(name: "楽しい", romaji: mecab.stringJapanese(toRomaji: "楽しい"), bestScore: 0)
        let card12 = Card(name: "疲れた", romaji: mecab.stringJapanese(toRomaji: "疲れた"), bestScore: 0)
        let card22 = Card(name: "嬉しい", romaji: mecab.stringJapanese(toRomaji: "嬉しい"), bestScore: 0)
        let card32 = Card(name: "苦しい", romaji: mecab.stringJapanese(toRomaji: "苦しい"), bestScore: 0)
        let card42 = Card(name: "幸せ", romaji: mecab.stringJapanese(toRomaji: "幸せ"), bestScore: 0)
        
        decks2.append(Deck(name: card02.name, card: card02))
        decks2.append(Deck(name: card12.name, card: card12))
        decks2.append(Deck(name: card22.name, card: card22))
        decks2.append(Deck(name: card32.name, card: card32))
        decks2.append(Deck(name: card42.name, card: card42))
        
        themes.append(Theme(name: "気持ち", decks: decks2))
        
        var decks3 = [Deck]()
        let card03 = Card(name: "あれが浅草寺です", romaji: mecab.stringJapanese(toRomaji: "あれが浅草寺です"), bestScore: 0)
        let card13 = Card(name: "あそこに見えるのがスカイツリーです", romaji: mecab.stringJapanese(toRomaji: "あそこに見えるのがスカイツリーです"), bestScore: 0)
        let card23 = Card(name: "すみません、刺抜き地蔵はどちらですか", romaji: mecab.stringJapanese(toRomaji: "すみません、刺抜き地蔵はどちらですか"), bestScore: 0)
        let card33 = Card(name: "五反田駅はどちらでしょうか", romaji: mecab.stringJapanese(toRomaji: "五反田駅はどちらでしょうか"), bestScore: 0)
        let card43 = Card(name: "2丁目までお願いします", romaji: mecab.stringJapanese(toRomaji: "2丁目までお願いします"), bestScore: 0)
        
        decks3.append(Deck(name: card03.name, card: card03))
        decks3.append(Deck(name: card13.name, card: card13))
        decks3.append(Deck(name: card23.name, card: card23))
        decks3.append(Deck(name: card33.name, card: card33))
        decks3.append(Deck(name: card43.name, card: card43))
        
        themes.append(Theme(name: "お出かけ", decks: decks3))
        
    }
    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kDeckViewController") as? DeckViewController {
            controller.decks = themes[indexPath.row].decks
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForView(text: themes[indexPath.row].name, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 16) + 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.cellIdentifier, for: indexPath) as! TextTableViewCell
        cell.label?.text = themes[indexPath.row].name
        return cell
    }
}
