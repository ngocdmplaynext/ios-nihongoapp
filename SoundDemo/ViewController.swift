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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let text = "挨拶"
        
        let mecab = MeCabUtil()
        let arr = mecab.parseToNode(with: text)
        
        for item in arr! {
            print("\((item as! Node).pronunciation())")
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
        let card = Card(name: "あ！久しぶり！", bestScore: 0)
        let card1 = Card(name: "おはよう", bestScore: 0)
        let card2 = Card(name: "良い一日を", bestScore: 0)
        let card3 = Card(name: "調子どう", bestScore: 0)
        let card4 = Card(name: "やっと会えて嬉しいわ", bestScore: 0)
        let card5 = Card(name: "もう行くね", bestScore: 0)
        
        decks.append(Deck(name: "あ！久しぶり！", card: card))
        decks.append(Deck(name: "おはよう", card: card1))
        decks.append(Deck(name: "良い一日を", card: card2))
        decks.append(Deck(name: "調子どう", card: card3))
        decks.append(Deck(name: "やっと会えて嬉しいわ", card: card4))
        decks.append(Deck(name: "もう行くね", card: card5))
        
        themes.append(Theme(name: "挨拶", decks: decks))
        
        
        var decks1 = [Deck]()
        let card01 = Card(name: "ドシャ降りだ", bestScore: 0)
        let card11 = Card(name: "人の好みはそれぞれだ", bestScore: 0)
        let card21 = Card(name: "聞いていますよ", bestScore: 0)
        let card31 = Card(name: "今日はもう終わりにしよう", bestScore: 0)
        let card41 = Card(name: "家に帰って寝なさい", bestScore: 0)
        let card51 = Card(name: "絶対にありえない", bestScore: 0)
        
        decks1.append(Deck(name: "ドシャ降りだ", card: card01))
        decks1.append(Deck(name: "人の好みはそれぞれだ", card: card11))
        decks1.append(Deck(name: "聞いていますよ", card: card21))
        decks1.append(Deck(name: "今日はもう終わりにしよう", card: card31))
        decks1.append(Deck(name: "家に帰って寝なさい", card: card41))
        decks1.append(Deck(name: "絶対にありえない", card: card51))
        
        themes.append(Theme(name: "おしゃべり", decks: decks1))
        
        var decks2 = [Deck]()
        let card02 = Card(name: "石のように凍りついてしまった", bestScore: 0)
        let card12 = Card(name: "まあなんてこと", bestScore: 0)
        let card22 = Card(name: "感動して涙が出ました", bestScore: 0)
        let card32 = Card(name: "とても楽しい時間を過ごした", bestScore: 0)
        let card42 = Card(name: "正気を失う寸前だ", bestScore: 0)
        let card52 = Card(name: "この感覚を振り切れないんだ", bestScore: 0)
        
        decks2.append(Deck(name: "石のように凍りついてしまった", card: card02))
        decks2.append(Deck(name: "まあなんてこと", card: card12))
        decks2.append(Deck(name: "感動して涙が出ました", card: card22))
        decks2.append(Deck(name: "とても楽しい時間を過ごした", card: card32))
        decks2.append(Deck(name: "正気を失う寸前だ", card: card42))
        decks2.append(Deck(name: "この感覚を振り切れないんだ", card: card52))
        
        themes.append(Theme(name: "気持ち", decks: decks2))
        
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
