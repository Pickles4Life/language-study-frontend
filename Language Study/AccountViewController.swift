//
//  AccountViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/18/22.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var streakLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                let user = try await User.fetchMe()
                usernameLabel.text = "Username: \(user.username)"
                phoneNumberLabel.text = "Phone Number: \(user.phoneNumber)"
                streakLabel.text = "Streak: 🔥\(user.streak)"
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func logoutClicked() {
        Task {
            do {
                try await logout()
                performSegue(withIdentifier: "LoggedOut", sender: nil)
            } catch {
                print(error)
                return
            }
        }
    }
    @IBAction func testClicked() {
        Task {
            do {
                let _ = try await sendRequest(url: "test", body: nil, type: .get)
            } catch {
                print(error)
                return
            }
        }
    }
    
    func logout() async throws {
        let _ = try await sendRequest(url: "user/logout", body: nil, type: .post)
        WebSocket.instance.disconnect()
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
