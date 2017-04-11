//
//  MyDeckViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 4/4/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class MyDeckViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var decks: [Deck] = [Deck]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Topics"
        
        if revealViewController() != nil {
            let menuBtn = UIBarButtonItem(image: UIImage(named: "reveal-icon"), style: .plain, target: revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
                
            self.navigationItem.leftBarButtonItem = menuBtn
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        NetworkManager.shared.myDeck { [weak self] (decks, error) in
            if let decks = decks {
                self?.decks = decks
                self?.tableView.reloadData()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension MyDeckViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deck = self.decks[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kMyCardViewController") as? MyCardViewController {
            controller.deckId = deck.deckId
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

extension MyDeckViewController: UITableViewDataSource {
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
