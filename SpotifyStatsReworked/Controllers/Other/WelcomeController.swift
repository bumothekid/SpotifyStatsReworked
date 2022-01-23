//
//  WelcomeController.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 18.01.22.
//

import UIKit

class WelcomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome!"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 48, weight: .bold)
        return label
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Please log in with your Spotify\naccount to continue"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 19.5, weight: .semibold)
        return label
    }()
    
    var logInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.backgroundColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .greenColor
        button.layer.cornerRadius = 15
        
        button.addTarget(self, action: #selector(logInBtn), for: .touchUpInside)
        return button
    }()
    
    // MARK: -- ObjC Functions
    
    @objc func logInBtn() {
        handleLogIn()
    }
    
    // MARK: -- Functions
    
    func handleLogIn() {
        let vc = AuthController()
        
        navigationController?.pushViewController(vc, animated: true)
        
        vc.completionHandler = { [weak self] success in
            guard success else {
                let alert = UIAlertController(title: "", message: "Something went wrong when signing in.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.navigationController?.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(welcomeLabel)
        welcomeLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -35).isActive = true
        welcomeLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 10, paddingRight: -10)
        
        view.addSubview(infoLabel)
        infoLabel.anchor(top: welcomeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 2.5, paddingLeft: 10, paddingRight: -10)
        
        view.addSubview(logInButton)
        logInButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 30, paddingBottom: -41, paddingRight: -30, height: 60)
    }
    
    /*
     let vc = AuthController()
     vc.completionHandler = { [weak self] success in
         DispatchQueue.main.async {
             print("abcdefu")
         }
     }
     navigationController?.pushViewController(vc, animated: true)
     */
}
