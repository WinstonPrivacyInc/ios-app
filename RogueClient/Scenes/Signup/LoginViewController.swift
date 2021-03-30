//
//  LoginViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-07-12.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import JGProgressHUD
import Amplify

class LoginViewController: UIViewController {

    // MARK: - @IBOutlets -
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    
    @IBOutlet weak var scannerButton: UIButton! {
        didSet {
            scannerButton.isHidden = !UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    @IBOutlet weak var passwordResetButton: UIButton! {
        didSet {
            
        }
    }
    
    // MARK: - Properties -
    
    private lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.delegate = self
        return sessionManager
    }()
    
    private var loginProcessStarted = false
    private let hud = JGProgressHUD(style: .dark)
    private var actionType: ActionType = .login
    
    // MARK: - @IBActions -
    
    @IBAction func handleEmailInput(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func loginToAccount(_ sender: AnyObject) {
        guard UserDefaults.shared.hasUserConsent else {
            actionType = .login
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return
        }
        
        view.endEditing(true)
        startLoginProcess()
    }
    
    @IBAction func passwordReset(_ sender: Any) {
    }
    
    @IBAction func createAccount(_ sender: AnyObject) {
        guard UserDefaults.shared.hasUserConsent else {
            actionType = .signup
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return
        }
        
        startSignupProcess()
    }
    
    @IBAction func presentForgotPasswordView(_ sender: Any) {
        present(NavigationManager.getForgotPasswordViewController(), animated: true)
    }
    @IBAction func openScanner(_ sender: AnyObject) {
        present(NavigationManager.getScannerViewController(delegate: self), animated: true)
    }
    
    @IBAction func restorePurchases(_ sender: AnyObject) {
        guard deviceCanMakePurchases() else { return }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Restoring purchases..."
        hud.show(in: (navigationController?.view)!)
        
        IAPManager.shared.restorePurchases { account, error in
            self.hud.dismiss()
            
            if let error = error {
                self.showErrorAlert(title: "Restore failed", message: error.message)
                return
            }
            
            if account != nil {
                self.emailTextField.text = account?.accountId
                self.sessionManager.createSession()
            }
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "loginScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        emailTextField.becomeFirstResponder()
        
        addObservers()
        hideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(termsOfServiceAgreed), name: Notification.Name.TermsOfServiceAgreed, object: nil)
    }
    
    @objc func newSession() {
        startLoginProcess()
    }
    
    @objc func forceNewSession() {
        startLoginProcess(force: true)
    }
    
    @objc func termsOfServiceAgreed() {
        switch actionType {
        case .login:
            loginToAccount(self)
        case .signup:
            createAccount(self)
        }
    }
    
    // MARK: - Methods -
    
    private func startLoginProcess(force: Bool = false, confirmation: String? = nil, captcha: String? = nil, captchaId: String? = nil) {
        guard !loginProcessStarted else { return }
        
        let username = (self.emailTextField.text ?? "").trim()
        let password = (self.passwordTextField.text ?? "").trim()
        
        loginProcessStarted = true
        
        guard ServiceStatus.isValidEmail(email: username) else {
            loginProcessStarted = false
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        guard ServiceStatus.isValidPassword(password: password) else {
            loginProcessStarted = false
            showAlert(title: "Invalid Password", message: "Please enter your password.")
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Signin in..."
        hud.show(in: (navigationController?.view)!)
        
        Amplify.Auth.signIn(username: username, password: password) { result in
           switch result {
               case .success:
                    DispatchQueue.main.async {
                        self.signInSuccess()
                    }
               case .failure(let error):
                    DispatchQueue.main.async {
                        self.signInFailure(authError: error)
                    }
               }
           }
    }
    
    private func signInSuccess() -> Void {
        // sessionManager.createSession(force: force, username: username, confirmation: confirmation, captcha: captcha, captchaId: captchaId)
        print("Sign in success")
        self.createSessionSuccess()
        self.hud.dismiss()
        self.loginProcessStarted = false
    }
    
    private func signInFailure(authError: AuthError) -> Void {
        print("Sign in failure \(authError.errorDescription)")
        self.hud.dismiss()
        showAlert(title: "Sign in failed", message: authError.errorDescription)
        loginProcessStarted = false
    }
    
    
    private func startSignupProcess() {
        if KeyChain.tempUsername != nil {
            present(NavigationManager.getCreateAccountViewController(), animated: true, completion: nil)
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new account..."
        hud.show(in: (navigationController?.view)!)
        
        let request = ApiRequestDI(method: .post, endpoint: Config.apiAccountNew, params: [URLQueryItem(name: "product_name", value: "IVPN Standard")])
        
        ApiService.shared.requestCustomError(request) { [weak self] (result: ResultCustomError<Account, ErrorResult>) in
            guard let self = self else { return }
            
            self.hud.dismiss()
            
            switch result {
            case .success(let account):
                KeyChain.tempUsername = account.accountId
                self.present(NavigationManager.getCreateAccountViewController(), animated: true, completion: nil)
            case .failure(let error):
                self.showErrorAlert(title: "Error", message: error?.message ?? "There was a problem with creating a new account.")
            }
        }
    }
    
    
    private func showUsernameError() {
        showErrorAlert(
            title: "You entered an invalid account ID",
            message: "Your account ID has to be in 'i-XXXX-XXXX-XXXX' or 'ivpnXXXXXXXX' format. You can find it on other devices where you are logged in and in the client area of the IVPN website."
        )
    }
    
    @objc private func subscriptionDismissed() {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
    @objc private func subscriptionActivated() {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
        })
    }
    
}

// MARK: - SessionManagerDelegate -

extension LoginViewController {
    
    override func createSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func createSessionSuccess() {
        hud.dismiss()
        loginProcessStarted = false
        
        KeyChain.username = (self.emailTextField.text ?? "").trim()
        
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
            NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        })
    }
    
    override func createSessionServiceNotActive() {
        hud.dismiss()
        loginProcessStarted = false
        
        KeyChain.username = (self.emailTextField.text ?? "").trim()
        
        let viewController = NavigationManager.getSubscriptionViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionAccountNotActivated(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        
        KeyChain.tempUsername = (self.emailTextField.text ?? "").trim()
        Application.shared.authentication.removeStoredCredentials()
        
        let viewController = NavigationManager.getSelectPlanViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionTooManySessions(error: Any?) {
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        
        if let error = error as? ErrorResultSessionNew, let data = error.data {
            if data.upgradable {
                NotificationCenter.default.addObserver(self, selector: #selector(newSession), name: Notification.Name.NewSession, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(forceNewSession), name: Notification.Name.ForceNewSession, object: nil)
                UserDefaults.shared.set(data.limit, forKey: UserDefaults.Key.sessionsLimit)
                UserDefaults.shared.set(data.upgradeToUrl, forKey: UserDefaults.Key.upgradeToUrl)
                present(NavigationManager.getUpgradePlanViewController(), animated: true, completion: nil)
                return
            }
        }
        
        showCreateSessionAlert(message: "You've reached the maximum number of connected devices")
    }
    
    override func createSessionAuthenticationError() {
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        showErrorAlert(title: "Error", message: "Account ID is incorrect")
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        showErrorAlert(title: "Error", message: message)
    }
    
    override func twoFactorRequired(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        present(NavigationManager.getTwoFactorViewController(delegate: self), animated: true)
    }
    
    override func twoFactorIncorrect(error: Any?) {
        var message = "Unknown error occurred"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        loginProcessStarted = false
        showErrorAlert(title: "Error", message: message)
    }
    
    override func captchaRequired(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        presentCaptchaScreen(error: error)
    }
    
    override func captchaIncorrect(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        presentCaptchaScreen(error: error)
    }
    
    private func showCreateSessionAlert(message: String) {
        showActionSheet(title: message, actions: ["Log out from all other devices", "Try again"], sourceView: self.emailTextField) { index in
            switch index {
            case 0:
                self.startLoginProcess(force: true)
            case 1:
                self.startLoginProcess()
            default:
                break
            }
        }
    }
    
    private func presentCaptchaScreen(error: Any?) {
        if let error = error as? ErrorResultSessionNew, let imageData = error.captchaImage, let captchaId = error.captchaId {
            present(NavigationManager.getCaptchaViewController(delegate: self, imageData: imageData, captchaId: captchaId), animated: true)
        }
    }
    
}

// MARK: - UITextFieldDelegate -

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            emailTextField.resignFirstResponder()
            startLoginProcess()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension LoginViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
}

// MARK: - ScannerViewControllerDelegate -

extension LoginViewController: ScannerViewControllerDelegate {
    
    func qrCodeFound(code: String) {
        emailTextField.text = code
        
        guard UserDefaults.shared.hasUserConsent else {
            DispatchQueue.async {
                self.actionType = .login
                self.present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            }
            
            return
        }
        
        startLoginProcess()
    }
    
}

// MARK: - TwoFactorViewControllerDelegate -

extension LoginViewController: TwoFactorViewControllerDelegate {
    
    func codeSubmitted(code: String) {
        startLoginProcess(force: false, confirmation: code)
    }
    
}

// MARK: - CaptchaViewControllerDelegate -

extension LoginViewController: CaptchaViewControllerDelegate {
    
    func captchaSubmitted(code: String, captchaId: String) {
        startLoginProcess(force: false, captcha: code, captchaId: captchaId)
    }
    
}

extension LoginViewController {
    
    enum ActionType {
        case login
        case signup
    }
    
}
