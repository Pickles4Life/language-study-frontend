//
//  FriendRequestsViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/20/22.
//

import UIKit

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var requests: [User]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestCell
        cell.usernameLabel.text = requests[indexPath.item].username
        cell.id = requests[indexPath.item].id
        cell.requestAccepted = self.requestAccepted
        return cell
    }
    
    func requestAccepted(_ id: UUID) {
        requests.remove(at: requests.firstIndex(where: {$0.id == id})!)
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

class FriendRequestCell: UITableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    
    var id: UUID!
    
    var requestAccepted: ((UUID) -> ())!
    
    @IBAction func acceptClicked(_ sender: UIButton) {
        Task {
            do {
                try await Friends.acceptFriendRequest(id: id)
                self.requestAccepted(id)
            } catch {
                print(error)
            }
        }
    }
}
