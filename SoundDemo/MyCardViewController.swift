//
//  MyCardViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 4/11/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class MyCardViewController: UIViewController {
    var deckId: Int = 0
    var cards: [Card] = [Card]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.shared.getInitCardData(byDeckId: deckId, completion: { (cards, error) in
            if let cards = cards {
                self.cards = cards
                self.tableView.reloadData()
            } else {
                print("can't load init card data")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension MyCardViewController: UITableViewDelegate {
    
}

extension MyCardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForView(text: cards[indexPath.row].name, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 16) + 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.cellIdentifier, for: indexPath) as! TextTableViewCell
        cell.label?.text = cards[indexPath.row].name
        return cell
    }
}

