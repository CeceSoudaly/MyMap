//
//  LoginViewController.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/12/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var udacityImageView: UIImageView!

    
    // MARK: Life Cycle
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
               
        print("FBSDKAccessToken.currentAccessToken() ",FBSDKAccessToken.current() )
        
        if (FBSDKAccessToken.current() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            print("You are already log in....",FBSDKAccessToken.current() );
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            let newcenter =  CGPoint(x: self.view.center.x, y: 450)
            loginView.center = newcenter
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    @IBAction func loginFacebookAction(sender: AnyObject) {//action of the custom button in the storyboard
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print("Hello....log into facebook here")
                }
            })
        }
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            //todo: needs a popup message
            print("Username or Password Empty.")

            
        } else {
           setUIEnabled(false)
           logIntoUdacity()
        }
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
        if ((error) != nil) {
                    print("Failed Facebook login")
                    DispatchQueue.main.async(execute: {
                      //  Convenience.showAlert(self, error: error!)
                        print(">>>>>> ")
                    })
                } else if result.isCancelled {
                    print("Cancelled Facebook login")
                }
                else {
                    if result.grantedPermissions.contains("email")
                    {
                        Client.sharedInstance().authServiceUsed  = Client.AuthService.Facebook
                       completeLogin(Client.AuthService.Facebook)
                       print("Successful Facebook login token",result.token)
                    }
                }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    private func completeLogin(_ loginAs: Client.AuthService) {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            //Tab view controller
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func beginEditingUserName(_ sender: Any) {
        
        usernameTextField.text = ""
        self.usernameTextField.delegate = self
    }
    
    @IBAction func beginEditingPassword(_ sender: Any) {
        passwordTextField.text = ""
        self.passwordTextField.delegate = self
    }
    
    // MARK:    
    private func logIntoUdacity() {
        // use for testing
       usernameTextField.text = Client.OTM.username
        passwordTextField.text = Client.OTM.password
        
        print("Your usernameTextField.text: \(String(describing: usernameTextField.text))")
        print("Your passwordTextField.text): \(String(describing: passwordTextField.text)))")
        Client.sharedInstance().postSession(username: usernameTextField.text!, password: passwordTextField.text!) { (success, error) in
            if success == true {
                print("Logged in")
                DispatchQueue.main.async(execute: {
                    self.completeLogin(Client.AuthService.Udacity)
               })
            } else {
                DispatchQueue.main.async(execute: {
                    Client.showAlert(caller: self, error: error!)
                })
            }
        }
  
    }
    
   }


// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            udacityImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            udacityImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
   func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
   
}
// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
    
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
           loginButton.alpha = 0.5
        }
    }

}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
