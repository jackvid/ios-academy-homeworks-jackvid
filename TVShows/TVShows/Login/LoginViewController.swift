import UIKit
import SVProgressHUD
import Alamofire
import CodableAlamofire
import PromiseKit
import KeychainAccess

//MARK: - Structs -

struct LoginData: Codable {
    let token: String
}

public let keychain : Keychain = Keychain(service: "TVShows")

class LoginViewController: UIViewController {
    
    //MARK: - Private -

    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var loginScreenBottomConstraint: NSLayoutConstraint!
    
    private var boolean = true
    
    private var orientation = false
    
    private var loginData : LoginData?
    
    
    //MARK: - System -
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.layer.cornerRadius = 5
        logInButton.titleLabel?.textAlignment = NSTextAlignment.center
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        
        keyboardNotifications()
        
        if keychain.allKeys().count != 0 {
            for key in keychain.allKeys() {
                emailTextField.text = key
                passwordTextField.text = keychain["\(key)"]
            }
            _login(user: emailTextField.text!, password: passwordTextField.text!)
        }
        
        emailTextField.text = "jakov.vidak@gmail.com"
        passwordTextField.text = "infinum1"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - Navigation -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
                orientation = true
            } else {
                orientation = false
        }
    }
    
    private func keyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardShow(notification: NSNotification) {
        if orientation {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        } else {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                loginScreenBottomConstraint.constant = keyboardSize.height
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        } else {
            loginScreenBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction private func rememberMeClick(_ sender: Any) {
        if boolean {
            rememberMeButton.setImage(UIImage(named: "ic-checkbox-filled"), for: .normal)
            boolean = false
        } else {
            rememberMeButton.setImage(UIImage(named: "ic-checkbox-empty"), for: .normal)
            boolean = true
        }
    }
    
    @IBAction private func logInClick(_ sender: Any) {
        
        if !boolean {
    
            guard let emailText = emailTextField.text else {
                print("Problem to convert emailTextField to emailText")
                return
            }
            
            guard let password = passwordTextField.text else {
                print("Problem to convert passwordTextField to passwordText")
                return
            }

            keychain["\(emailText)"] = password
            
        }
        
        _login(user: emailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction private func createAnAccountClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let createViewController = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        
        createViewController.delegate = self
        
        let nc = UINavigationController(rootViewController: createViewController)
        navigationController?.present(nc, animated: true, completion: nil)
    }

    private func _login(user: String, password: String) {
        let parameters: [String: String] = [
            "email": user,
            "password": password
        ]
        
        SVProgressHUD.show()
        
        Alamofire
            .request("https://api.infinum.academy/api/users/sessions",
                     method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) { [weak self] (response: DataResponse<LoginData>) in
                
                guard let `self` = self else { return }
                
                switch response.result {
                case .success(let loginData):
                    self.loginData = loginData
                    SVProgressHUD.setStatus("Success")
        
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    
                    homeViewController.token = loginData.token
                    homeViewController.email = self.emailTextField.text
                    self.navigationController?.pushViewController(homeViewController, animated: true)
                
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print("API \(error)")
                    self.emailTextField.shake(horizantaly: 3, Verticaly: 3)
                    self.passwordTextField.shake(horizantaly: 3, Verticaly: 3)
                    self.logInButton.pulsating()
                }
        }
    }
    
}

//MARK: - Extensions -

extension LoginViewController: LoginDelegate {
    func didCreateAccount(username: String, password: String) {
        _login(user: username, password: password)
    }
}
