//
//  SentenceViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class SentenceViewController: UIViewController {
    var deckId: Int = 0
    var cards: [Card] = [Card]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !DBManager.shared.hasCardData(byDeckId: deckId) {
            NetworkManager.shared.getInitCardData(byDeckId: deckId, completion: { (cards, error) in
                if let cards = cards {
                    self.cards = cards
                    self.tableView.reloadData()
                } else {
                    print("can't load init card data")
                }
            })
        } else {
            self.cards = DBManager.shared.loadCardsData(byDeckId: deckId)
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SentenceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let card = cards[indexPath.row]
        return heightForView(text: card.name, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 91) + heightForView(text: card.romaji, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 91) + 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SentenceTableViewCell = tableView.dequeueReusableCell(withIdentifier: SentenceTableViewCell.cellIdentifier, for: indexPath) as! SentenceTableViewCell
        let card = cards[indexPath.row]
        cell.lbTitle.text = card.name
        cell.lbRomaji.text = card.romaji
        return cell
    }
}
