//
//  LoginViewController.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/12/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import UIKit


class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
   // @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        configureUI()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
//            setUIEnabled(false)
            
            /*
             Steps for Authentication...
             https://www.themoviedb.org/documentation/api/sessions
             
             Step 1: Create a request token
             Step 2: Ask the user for permission via the API ("login")
             Step 3: Create a session ID
             
             Extra Steps...
             Step 4: Get the user id ;)
             Step 5: Go to the next view!
             */
            getRequestToken()
        }
    }
    
    private func completeLogin() {
//        performUIUpdatesOnMain {
//            self.debugTextLabel.text = ""
//            self.setUIEnabled(true)
//            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MoviesTabBarController") as! UITabBarController
//            self.present(controller, animated: true, completion: nil)
//        }
    }
    
    // MARK: TheMovieDB
    
    private func getRequestToken() {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Your URL: \(request)")
        
        request.httpBody = "{\"udacity\": {\"username\": \"\(Constants.TMDB.username)\", \"password\": \"\(Constants.TMDB.password)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        
        /* 4. Make the request */
        //let task = session.dataTask(with: request as URLRequest)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed."
                }
            }
            
            let range = Range(5 ..< data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard newData != nil else {
                displayError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            /* GUARD: Did Udacity Authentication return an error? */
            if let _ = parsedResult[Constants.TMDBResponseKeys.StatusCode] as? Int {
                displayError("TheMovieDB returned an error. See the '\(Constants.TMDBResponseKeys.StatusCode)' and '\(Constants.TMDBResponseKeys.StatusMessage)' in \(parsedResult)")
                return
            }
            
            
            if let jsonResult = parsedResult["account"] as? [String: AnyObject] {
                print(" ")
                print("HERE IS MY PARSED KEY + ID ONLY:--------------------------------------------------------------------")
                let userID = jsonResult["key"]
                self.appDelegate.sessionID = userID! as! String
                print("Account: \(self.appDelegate.sessionID)")
                
                let justId = jsonResult["id"]
                print("Account: \(userID)")
                print("justId: \(justId)")
            }
            
            if let jsonResult = parsedResult["session"] as? [String: AnyObject] {
                print(" ")
                print("HERE IS MY PARSED KEY + ID ONLY:--------------------------------------------------------------------")
                let expiration = jsonResult["expiration"]
                let sessionID = jsonResult["id"]
                print("Account: \(expiration)")
                print("session: \(sessionID)")
            }
            
            
            /* GUARD: Is the "sessionID" key in parsedResult? */
            guard let sessionID = parsedResult["session"] as? [String: AnyObject] else {
                displayError("Cannot find key '\(Constants.TMDBResponseKeys.SessionID)' in \(parsedResult)")
                return
            }
            
            
            print("sessionID: \(sessionID)")
            performUIUpdatesOnMain {
//                self.setUIEnabled(true)
                self.debugTextLabel.text = "Login Successful."
            }
        }
        
        
        
        task.resume()
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
            movieImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.isHidden = false
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
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}
// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
//    func setUIEnabled(_ enabled: Bool) {
//        usernameTextField.isEnabled = enabled
//        passwordTextField.isEnabled = enabled
//        loginButton.isEnabled = enabled
//        debugTextLabel.text = ""
//        debugTextLabel.isEnabled = enabled
//    
//        // adjust login button alpha
//        if enabled {
////            loginButton.alpha = 1.0
//        } else {
////            loginButton.alpha = 0.5
//        }
//    }
   
    func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
//       backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
       // configureTextField(usernameTextField)
        //configureTextField(passwordTextField)
    }
//
//    func configureTextField(_ textField: UITextField) {
//        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
//        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
//        textField.leftView = textFieldPaddingView
//        textField.leftViewMode = .always
////        textField.backgroundColor = Constants.UI.GreyColor
////        textField.textColor = Constants.UI.BlueColor
//        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
////        textField.tintColor = Constants.UI.BlueColor
//        textField.delegate = self
//    }
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
