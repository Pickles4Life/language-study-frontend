//
//  LoginViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/17/22.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var usernameErrorLabel: UILabel!
    @IBOutlet var passwordErrorLabel: UILabel!
    @IBOutlet var loginErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let _ = try await User.fetchMe()
                performSegue(withIdentifier: "LoggedIn", sender: nil)
            } catch ServerError.unauthorized {
                return
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginClicked() {
        var empty = false
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        loginErrorLabel.isHidden = true
        
        if usernameField.text == nil || usernameField.text!.isEmpty {
            usernameErrorLabel.isHidden = false
            empty = true
        }
        if passwordField.text == nil || passwordField.text!.isEmpty {
            passwordErrorLabel.isHidden = false
            empty = true
        }
        if empty { return }
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        Task {
            do {
                try await login(username: username, password: password)
                performSegue(withIdentifier: "LoggedIn", sender: nil)
            } catch ServerError.unauthorized {
                loginErrorLabel.text = "Username or password is incorect."
                loginErrorLabel.isHidden = false
                return
            }
        }
    }
                    
    func login(username: String, password: String) async throws {
        let body = ["username": username, "password": password]
        let _ = try await sendRequest(url: "user/login", body: body, type: .post)
    }
}
