//
//  MoreTableViewController.swift
//  Recall
//
//  Created by Tiago Alves on 16/03/2019.
//  Copyright © 2019 Recall. All rights reserved.
//

import UIKit
import Blockstack

class MoreTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Know more about Blockstack"
        case 1:
            cell.textLabel?.text = "Logout"
        default:
            cell.textLabel?.text = ""
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let url = URL(string: "https://blockstack.org/")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        case 1:
            Blockstack.shared.signUserOut()
            AppDelegate.shared.rootViewController.switchToAuthScreen()
        default:
            print("No option")
        }
    }

}
