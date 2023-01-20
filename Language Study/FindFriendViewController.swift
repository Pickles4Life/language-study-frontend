//
//  AddFriendViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/19/22.
//

import UIKit

class FindFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var searchedUsers = [User]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendCell", for: indexPath) as! FindFriendCell
        cell.usernameLabel.text = searchedUsers[indexPath.item].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchedUserId = searchedUsers[indexPath.item].id
        Task {
            do {
                let user = try await UserWithRelationship.getUser(id: searchedUserId)
                performSegue(withIdentifier: "AddFriend", sender: user)
            } catch {
                print(error)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            do {
                searchedUsers = try await User.searchUsers(username: searchText)
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddFriend") {
            let addFriend = segue.destination as! AddFriendViewController
            addFriend.user = sender as? UserWithRelationship
        }
    }
    
    @IBAction func backToFindFriend(_ segue: UIStoryboardSegue) {}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class FindFriendCell: UITableViewCell {
    @IBOutlet var usernameLabel: UILabel!
}
