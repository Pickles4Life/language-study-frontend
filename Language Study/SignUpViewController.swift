//
//  SignUpViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/18/22.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var phoneNumberField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var usernameErrorLabel: UILabel!
    @IBOutlet var phoneNumberErrorLabel: UILabel!
    @IBOutlet var passwordErrorLabel: UILabel!
    @IBOutlet var signUpErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func signUpClicked() {
        var empty = false
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        phoneNumberErrorLabel.isHidden = true
        signUpErrorLabel.isHidden = true
        
        if usernameField.text == nil || usernameField.text!.isEmpty {
            usernameErrorLabel.isHidden = false
            empty = true
        }
        if passwordField.text == nil || passwordField.text!.isEmpty {
            passwordErrorLabel.isHidden = false
            empty = true
        }
        if phoneNumberField.text == nil || phoneNumberField.text!.isEmpty {
            phoneNumberErrorLabel.isHidden = false
            empty = true
        }
        if empty { return }
        
        let username = usernameField.text!
        let password = passwordField.text!
        let phoneNumber = phoneNumberField.text!
        
        Task {
            do {
                try await registerUser(username: username, phoneNumber: phoneNumber, password:  password)
                performSegue(withIdentifier: "SignedUp", sender: nil)
            } catch ServerError.badRequest(let msg) {
                let i = msg.firstIndex(of: "(")!
                let field = String(msg[msg.index(after: i)..<msg.firstIndex(of: ")")!])
                
                if field == "username" {
                    usernameErrorLabel.text = "Username is already taken."
                    usernameErrorLabel.isHidden = false
                    
                } else if field == "phone_number" {
                    phoneNumberErrorLabel.text = "Phone number is already taken."
                    phoneNumberErrorLabel.isHidden = false
                }
                return
            } catch ServerError.internalServer {
                phoneNumberErrorLabel.text = "Not a valid phone number."
                phoneNumberErrorLabel.isHidden = false
                return
            }
        }
    }
    
    func registerUser(username: String, phoneNumber: String, password: String) async throws {
        let body = ["username": username, "phoneNumber": phoneNumber, "password": password]
        let _ = try await sendRequest(url: "user/register", body: body, type: .post)
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
