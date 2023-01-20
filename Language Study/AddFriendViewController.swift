//
//  AddFriendViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/20/22.
//

import UIKit

class AddFriendViewController: UIViewController {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var friendButton: UIButton!
    
    
    var user: UserWithRelationship!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.text = user.username
        phoneNumberLabel.text = user.phoneNumber
        
        if user.relationship == "Friends" {
            friendButton.isEnabled = false
            friendButton.setTitle("Already Friends", for: .disabled)
        } else if user.relationship == "SentFriendRequest" {
            friendButton.isEnabled = false
            friendButton.setTitle("Already Sent Request", for: .disabled)
        } else if user.relationship == "RecievedFriendRequest" {
            friendButton.setTitle("Accept Friend Request", for: .normal)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func friendClicked() {
        if user.relationship == "NotFriends" {
            Task {
                do {
                    try await Friends.sendFriendRequest(id: user.id)
                    performSegue(withIdentifier: "Back", sender: nil)
                } catch {
                    print(error)
                }
            }
        } else if user.relationship == "RecievedFriendRequest" {
            Task {
                do {
                    try await Friends.acceptFriendRequest(id: user.id)
                    performSegue(withIdentifier: "Back", sender: nil)
                } catch {
                    print(error)
                }
            }
        }
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
