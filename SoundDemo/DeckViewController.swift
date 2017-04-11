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
    var themeId: Int = 0
    
    var decks = [Deck]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isTeacher = (UserDefault.shared.getUserType() ?? student) == teacher
        if isTeacher {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createDeck))
        }
        
        
//        if !DBManager.shared.hasDeckData(byThemeId: themeId) {
//            NetworkManager.shared.getInitDeckData(byThemeId: themeId, completion: { (decks, error) in
//                if let decks = decks {
//                    self.decks = decks
//                    self.tableView.reloadData()
//                } else {
//                    print("can't load init deck data")
//                }
//            })
//        } else {
//            self.decks = DBManager.shared.loadDecksData(byThemeId: themeId)
//            self.tableView.reloadData()
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkManager.shared.getInitDeckData(byThemeId: themeId, completion: { [weak self] (decks, error) in
            if let decks = decks {
                self?.decks = decks
                self?.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Alert", message: "Session invalid", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func createDeck() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kCreateDeckViewController") as? CreateDeckViewController {
            controller.themeId = self.themeId
            self.present(controller, animated: true, completion: nil)
        }
    }
}

extension DeckViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deck = self.decks[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kSentenceViewController") as? SentenceViewController {
            controller.deckId = deck.deckId
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
