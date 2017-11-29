//
//  ViewController.swift
//  Example
//
//  Created by Sukov on 11/26/17.
//  Copyright © 2017 Sukov. All rights reserved.
//

import UIKit
import WebViewController

class ViewController: UIViewController {
    fileprivate let cellId = "NormalCellIdentifier"
    fileprivate var tableView: UITableView!
    fileprivate var tableHeaderView: UIView!
    fileprivate var tableHeaderTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        navigationItem.title = "Example"
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        tableHeaderView = UIView()
        tableHeaderView.backgroundColor = .white
        
        let tableHeaderTitleLabel = UILabel(frame: CGRect(x: 0, y: 15, width: view.frame.width, height: 30))
        tableHeaderTitleLabel.text = "Enter a valid URL"
        tableHeaderTitleLabel.textAlignment = .center
        tableHeaderView.addSubview(tableHeaderTitleLabel)
        
        tableHeaderTextField = UITextField(frame: CGRect(x: view.frame.midX - 125, y: 45, width: 250, height: 40))
        tableHeaderTextField.layer.borderWidth = 1
        tableHeaderTextField.layer.borderColor = UIColor.black.cgColor
        tableHeaderTextField.layer.cornerRadius = 4
        tableHeaderTextField.layer.masksToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: tableHeaderTextField.frame.height))
        tableHeaderTextField.leftView = paddingView
        tableHeaderTextField.leftViewMode = .always
        tableHeaderTextField.rightView = paddingView
        tableHeaderTextField.rightViewMode = .always
        tableHeaderTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        tableHeaderTextField.font = UIFont.systemFont(ofSize: 20)
        tableHeaderTextField.autocapitalizationType = .none
        tableHeaderTextField.returnKeyType = .default
        tableHeaderTextField.placeholder = "Website address"
        tableHeaderTextField.text = "www.google.com"
        tableHeaderTextField.autocorrectionType = .no
        tableHeaderTextField.autocapitalizationType = .none
        tableHeaderView.addSubview(tableHeaderTextField)
    }
}

extension ViewController: WebViewControllerDelegate {
    func webViewController(_ webViewController: WebViewController, disabledTintColorFor button: UIButton) -> UIColor {
        switch button.tag {
        case 0: return .brown // back button
        case 1: return .brown // forward button
        default: return .gray
        }
    }
    
    func webViewController(_ webViewController: WebViewController, enabledTintColorFor button: UIButton) -> UIColor {
        switch button.tag {
        case 0: return .red // back button
        case 1: return .purple // forward button
        case 2: return .yellow // refresh button
        case 3: return .green // more options button
        default: return .blue
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Push WebViewController"
        case 1:
            cell.accessoryType = .none
            cell.textLabel?.text = "Present WebViewController"
        default: break
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var urlToLoad: String
        if let textFieldString = tableHeaderTextField.text {
            if textFieldString.contains("https://") || textFieldString.contains("http://") {
                urlToLoad = textFieldString
            } else {
                urlToLoad = "http://" + textFieldString
            }
        } else {
            urlToLoad = "https://www.google.com"
        }

        let webVC = WebViewController(urlToLoad: urlToLoad)
        webVC.delegate = self
        webVC.toolBarTintColor = UIColor.gray.withAlphaComponent(0.5)
        
        switch indexPath.row {
        case 0: navigationController?.pushViewController(webVC, animated: true)
        case 1: present(webVC, animated: true, completion: nil)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView
    }
}
