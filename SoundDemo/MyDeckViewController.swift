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
            } else if let error = error {
                var message = ""
                if error.code == 1000 {
                    message = "Session invalid"
                } else {
                    message = error.localizedDescription
                }
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension MyDeckViewController: UITableViewDelegate {
    
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
