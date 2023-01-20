//
//  FriendsViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/19/22.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var notificationButton: BadgeButton!
    
    
    var friends: Friends = Friends(friends: [], requests: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                try await reloadData()
            } catch {
                print(error)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        cell.usernameLabel.text = friends.friends[indexPath.item].username
        cell.streakLabel.text = String(friends.friends[indexPath.item].streak)
        return cell
    }
    
    @IBAction func notificationClicked() {
        performSegue(withIdentifier: "ViewRequests", sender: friends.requests)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewRequests") {
            let viewRequests = segue.destination as! FriendRequestsViewController
            viewRequests.requests = sender as? [User]
        }
    }
    
    @IBAction func backToFriends(_ segue: UIStoryboardSegue) {
        Task {
            do {
                try await reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    func reloadData() async throws {
        friends = try await Friends.fetchFriends()
        notificationButton.setBadgeValue(friends.requests.count)
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class FriendCell: UITableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var streakLabel: UILabel!
}
