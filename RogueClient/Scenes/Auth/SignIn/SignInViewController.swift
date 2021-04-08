//
//  SignInController.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Fedir Nepyyvoda on 2016-07-12.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the Rogue iOS app.
//
//  The Rogue iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Rogue iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the Rogue iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import JGProgressHUD
import Amplify

class SignInViewController: UIViewController {

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
    
    private lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.delegate = self
        return sessionManager
    }()
    
    private var signInStarted = false
    private let hud = JGProgressHUD(style: .dark)
    private var actionType: ActionType = .signin
    
    var passwordResetUserName: String = ""
    var passwordResetSuccess: Bool = false
    
    // MARK: - @IBActions -
    
    @IBAction func handleEmailInput(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func signInToAccount(_ sender: AnyObject) {
        guard UserDefaults.shared.hasUserConsent else {
            actionType = .signin
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return
        }
        
        view.endEditing(true)
        startSignInProcess()
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
          
    @IBAction func presentSignUpView(_ sender: Any) {
        present(NavigationManager.getSignUpViewController(), animated: true)
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
        view.accessibilityIdentifier = "signInScreen"
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(passwordWasReset), name: Notification.Name.PasswordResetSuccess, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(emailWasConfirmed), name: Notification.Name.EmailConfirmationSuccess, object: nil)
    }
    
    @objc private func emailWasConfirmed(notification: NSNotification) {
        
        if let data = notification.userInfo as? [String: String] {
            let email = data["email"]
            
            
            if email != nil {
                self.emailTextField.text = email
                self.passwordTextField.becomeFirstResponder()
            }
            
            showFlashNotification(message: "Your account was created", presentInView: (navigationController?.view)!)
        }
    }
    
    @objc private func passwordWasReset(notification: NSNotification) {
        
        if let data = notification.userInfo as? [String: String] {
            if let email = data["email"] {
                self.emailTextField.text = email
                self.passwordTextField.becomeFirstResponder()
            }
        }
        
        showFlashNotification(message: "Your password has been reset", presentInView: (navigationController?.view)!)
    }
    
    @objc func newSession() {
        startSignInProcess()
    }
    
    @objc func forceNewSession() {
        startSignInProcess()
    }
    
    @objc func termsOfServiceAgreed() {
        switch actionType {
        case .signin:
            signInToAccount(self)
        case .signup:
            createAccount(self)
        }
    }
    
    // MARK: - Methods -
    
    private func startSignInProcess() {
        guard !signInStarted else { return }
        
        let username = (self.emailTextField.text ?? "").trim()
        let password = (self.passwordTextField.text ?? "").trim()
        
        signInStarted = true
        
        guard ServiceStatus.isValidEmail(email: username) else {
            signInStarted = false
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        guard ServiceStatus.isValidPassword(password: password) else {
            signInStarted = false
            showAlert(title: "Invalid Password", message: "Please enter your password.")
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Signin in..."
        hud.show(in: (navigationController?.view)!)
        
        Amplify.Auth.signIn(username: username, password: password) { result in
           switch result {
           case .success:
                self.signInSuccess()
               
           case .failure(let error):
                self.signInFailure(authError: error)
           }
       }
    }
    
    private func signInSuccess() -> Void {
        print("Sign in success")
        self.signInStarted = false
        
        DispatchQueue.main.async {
            self.createSessionSuccess()
            self.hud.dismiss()
        }
    }
    
    private func signInFailure(authError: AuthError) -> Void {
        print("Sign in failure \(authError.errorDescription)")
        self.signInStarted = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Sign in failed", message: authError.errorDescription)
        }
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

extension SignInViewController {
    
    override func createSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func createSessionSuccess() {
        hud.dismiss()
        signInStarted = false
        
        KeyChain.username = (self.emailTextField.text ?? "").trim()
        
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
            NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
            NotificationCenter.default.post(name: Notification.Name.SignInSuccess, object: nil)
        })
    }
    
    override func createSessionServiceNotActive() {
        hud.dismiss()
        signInStarted = false
        
        KeyChain.username = (self.emailTextField.text ?? "").trim()
        
        let viewController = NavigationManager.getSubscriptionViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionAccountNotActivated(error: Any?) {
        hud.dismiss()
        signInStarted = false
        
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
        signInStarted = false
        
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
        signInStarted = false
        showErrorAlert(title: "Error", message: "Account ID is incorrect")
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        signInStarted = false
        showErrorAlert(title: "Error", message: message)
    }
    
    override func twoFactorRequired(error: Any?) {
        hud.dismiss()
        signInStarted = false
        present(NavigationManager.getTwoFactorViewController(delegate: self), animated: true)
    }
    
    override func twoFactorIncorrect(error: Any?) {
        var message = "Unknown error occurred"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        signInStarted = false
        showErrorAlert(title: "Error", message: message)
    }
    
    override func captchaRequired(error: Any?) {
        hud.dismiss()
        signInStarted = false
        presentCaptchaScreen(error: error)
    }
    
    override func captchaIncorrect(error: Any?) {
        hud.dismiss()
        signInStarted = false
        presentCaptchaScreen(error: error)
    }
    
    private func showCreateSessionAlert(message: String) {
        showActionSheet(title: message, actions: ["Log out from all other devices", "Try again"], sourceView: self.emailTextField) { index in
            switch index {
            case 0:
                self.startSignInProcess()
            case 1:
                self.startSignInProcess()
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

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            emailTextField.resignFirstResponder()
            startSignInProcess()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension SignInViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
}

// MARK: - ScannerViewControllerDelegate -

extension SignInViewController: ScannerViewControllerDelegate {
    
    func qrCodeFound(code: String) {
        emailTextField.text = code
        
        guard UserDefaults.shared.hasUserConsent else {
            DispatchQueue.async {
                self.actionType = .signin
                self.present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            }
            
            return
        }
        
        startSignInProcess()
    }
    
}

// MARK: - TwoFactorViewControllerDelegate -

extension SignInViewController: TwoFactorViewControllerDelegate {
    
    func codeSubmitted(code: String) {
        startSignInProcess()
    }
    
}

// MARK: - CaptchaViewControllerDelegate -

extension SignInViewController: CaptchaViewControllerDelegate {
    
    func captchaSubmitted(code: String, captchaId: String) {
        startSignInProcess()
    }
    
}

extension SignInViewController {
    
    enum ActionType {
        case signin
        case signup
    }
    
}
