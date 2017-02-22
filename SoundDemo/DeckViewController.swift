//
//  DeckViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 2/22/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class DeckViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var decks = [Deck]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension DeckViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kCardViewController") as? CardViewController {
            controller.card = decks[indexPath.row].card
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

extension DeckViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForView(text: decks[indexPath.row].name, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 16) + 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DeckTableViewCell = tableView.dequeueReusableCell(withIdentifier: DeckTableViewCell.cellIdentifier, for: indexPath) as! DeckTableViewCell
        cell.label?.text = decks[indexPath.row].name
        return cell
    }

}
