//
//  CustomWebView.swift
//  Search by Photo - Reverse Image Search
//
//  Created by Sukov on 8/11/17.
//  Copyright © 2017 Sukov. All rights reserved.
//

import UIKit
import WebKit

public protocol WebViewControllerDelegate: class {
    func webViewController(_ webViewController: WebViewController, setupAppearanceForMain view: UIView)
    func webViewControllerDidStartLoad(_ webViewController: WebViewController)
    func webViewControllerDidFinishLoad(_ webViewController: WebViewController)
    func webViewController(_ webViewController: WebViewController, disabledTintColorFor button: UIButton) -> UIColor
    func webViewController(_ webViewController: WebViewController, enabledTintColorFor button: UIButton) -> UIColor
}

public extension WebViewControllerDelegate {
    func webViewController(_ webViewController: WebViewController, setupAppearanceForMain view: UIView) {}
    
    func webViewControllerDidStartLoad(_ webViewController: WebViewController) {}
    
    func webViewControllerDidFinishLoad(_ webViewController: WebViewController) {}
    
    func webViewController(_ webViewController: WebViewController, disabledTintColorFor button: UIButton) -> UIColor {
        return .gray
    }
    
    func webViewController(_ webViewController: WebViewController, enabledTintColorFor button: UIButton) -> UIColor {
        return .blue
    }
}

public class WebViewController: UIViewController {
    fileprivate var webView: WKWebView!
    fileprivate lazy var toolBarView: UIView = {
        let toolBarView = UIView()
        toolBarView.backgroundColor = .white
        return toolBarView
    }()
    public var toolBarTintColor: UIColor {
        get {
            return toolBarView.backgroundColor ?? .white
        }
        
        set {
            toolBarView.backgroundColor = newValue
        }
    }
    fileprivate var backButton: UIButton!
    fileprivate var refreshButton: UIButton!
    fileprivate var moreOptionsButton: UIButton!
    fileprivate var forwardButton: UIButton!
    fileprivate var toolBarTopBorder: UIView!
    fileprivate var buttonLeftOffsetConstraints: [NSLayoutConstraint]!
    fileprivate var urlToLoad: String
    public weak var delegate: WebViewControllerDelegate?
    override public var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    public init(urlToLoad: String) {
        self.urlToLoad = urlToLoad
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        activityIndicatorOFF()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupNavigationBar()
        loadUrl()
        delegate?.webViewController(self, setupAppearanceForMain: view)
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = (size.width - 200) / 5
        for leftOffsetConstraint in buttonLeftOffsetConstraints {
            leftOffsetConstraint.constant = offset
        }
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        webView = UIWebView()
        webView.isOpaque = false
        webView.delegate = self
        view.addSubview(webView)
        
        toolBarView.backgroundColor = toolBarTintColor
        
        let imageEdgeInsets = UIEdgeInsetsMake(12, 0, 12, 0)
        let bundle = Bundle(for: type(of: self))
        
        backButton = UIButton()
        backButton.tag = 0
        backButton.setImage(UIImage(named: "leftArrow", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.imageEdgeInsets = imageEdgeInsets
        backButton.tintColor = delegate?.webViewController(self, disabledTintColorFor: backButton) ?? .gray
        backButton.isEnabled = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        toolBarView.addSubview(backButton)

        forwardButton = UIButton()
        forwardButton.tag = 1
        forwardButton.setImage(UIImage(named: "rightArrow", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardButton.imageView?.contentMode = .scaleAspectFit
        forwardButton.imageEdgeInsets = imageEdgeInsets
        forwardButton.tintColor = delegate?.webViewController(self, disabledTintColorFor: forwardButton) ?? .gray
        forwardButton.isEnabled = false
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        toolBarView.addSubview(forwardButton)
        
        refreshButton = UIButton()
        refreshButton.tag = 2
        refreshButton.setImage(UIImage(named: "refreshArrow", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        refreshButton.imageView?.contentMode = .scaleAspectFit
        refreshButton.imageEdgeInsets = imageEdgeInsets
        refreshButton.tintColor = delegate?.webViewController(self, enabledTintColorFor: refreshButton) ?? .blue
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        toolBarView.addSubview(refreshButton)
        
        moreOptionsButton = UIButton()
        moreOptionsButton.tag = 3
        moreOptionsButton.setImage(UIImage(named: "shareArrow", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        moreOptionsButton.imageView?.contentMode = .scaleAspectFit
        moreOptionsButton.imageEdgeInsets = imageEdgeInsets
        moreOptionsButton.tintColor = delegate?.webViewController(self, enabledTintColorFor: moreOptionsButton) ?? .blue
        moreOptionsButton.addTarget(self, action: #selector(moreOptionsButtonTapped), for: .touchUpInside)
        toolBarView.addSubview(moreOptionsButton)
        
        toolBarTopBorder = UIView()
        toolBarTopBorder.backgroundColor = .gray
        toolBarView.addSubview(toolBarTopBorder)
        
        view.addSubview(toolBarView)
    }
    
    fileprivate func setupConstraints() {
        make(toolBarView, layoutAttributes: [.left, .right, .bottom], equalToView: view, equalToAttributes: [.left, .right, .bottom], offset: 0)
        make(toolBarView, layoutAttributes: [.height], equalToView: nil, equalToAttributes: [.notAnAttribute], offset: 50, addConstraintToView: view)
    
        make(toolBarTopBorder, layoutAttributes: [.left, .top, .right], equalToView: toolBarView, equalToAttributes: [.left, .top, .right], offset: 0)
        make(toolBarTopBorder, layoutAttributes: [.height], equalToView: nil, equalToAttributes: [.notAnAttribute], offset: 1 / UIScreen.main.scale, addConstraintToView: toolBarView)
        
        make(webView, layoutAttributes: [.left, .top, .right], equalToView: view, equalToAttributes: [.left, .top, .right], offset: 0)
        make(webView, layoutAttributes: [.bottom], equalToView: toolBarView, equalToAttributes: [.top], offset: 0,  addConstraintToView: view)

        let offset = (view.frame.width - 200) / 5
        buttonLeftOffsetConstraints = []
        
        let backButtonLeftOffsetConstraint = make(backButton, layoutAttributes: [.left], equalToView: toolBarView, equalToAttributes: [.left], offset: offset)[0]
        buttonLeftOffsetConstraints.append(backButtonLeftOffsetConstraint)
        make(backButton, layoutAttributes: [.centerY], equalToView: toolBarView, equalToAttributes: [.centerY], offset: 0)
        make(backButton, layoutAttributes: [.width, .height], equalToView: nil, equalToAttributes: [.notAnAttribute, .notAnAttribute], offset: 50, addConstraintToView: toolBarView)
        
        let forwardButtonLeftOffsetConstraint = make(forwardButton, layoutAttributes: [.left], equalToView: backButton, equalToAttributes: [.right], offset: offset, addConstraintToView: toolBarView)[0]
        buttonLeftOffsetConstraints.append(forwardButtonLeftOffsetConstraint)
        make(forwardButton, layoutAttributes: [.centerY], equalToView: toolBarView, equalToAttributes: [.centerY], offset: 0)
        make(forwardButton, layoutAttributes: [.width, .height], equalToView: nil, equalToAttributes: [.notAnAttribute, .notAnAttribute], offset: 50, addConstraintToView: toolBarView)
        
        let refreshButtonLeftOffsetConstraint = make(refreshButton, layoutAttributes: [.left], equalToView: forwardButton, equalToAttributes: [.right], offset: offset, addConstraintToView: toolBarView)[0]
        buttonLeftOffsetConstraints.append(refreshButtonLeftOffsetConstraint)
        make(refreshButton, layoutAttributes: [.centerY], equalToView: toolBarView, equalToAttributes: [.centerY], offset: 0)
        make(refreshButton, layoutAttributes: [.width, .height], equalToView: nil, equalToAttributes: [.notAnAttribute, .notAnAttribute], offset: 50, addConstraintToView: toolBarView)
        
        let moreOptionsButtonLeftOffsetConstraint = make(moreOptionsButton, layoutAttributes: [.left], equalToView: refreshButton, equalToAttributes: [.right], offset: offset, addConstraintToView: toolBarView)[0]
        buttonLeftOffsetConstraints.append(moreOptionsButtonLeftOffsetConstraint)
        make(moreOptionsButton, layoutAttributes: [.centerY], equalToView: toolBarView, equalToAttributes: [.centerY], offset: 0)
        make(moreOptionsButton, layoutAttributes: [.width, .height], equalToView: nil, equalToAttributes: [.notAnAttribute, .notAnAttribute], offset: 50, addConstraintToView: toolBarView)
    }
    
    fileprivate func setupNavigationBar() {
        var titleUrl = urlToLoad.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
        if let firstSlashIndex = titleUrl.characters.index(of: "/") {
            titleUrl = titleUrl.substring(to: firstSlashIndex)
        }
        navigationItem.title = titleUrl
    }
    
    @objc fileprivate func backButtonTapped() {
        webView.goBack()
    }
    
    @objc fileprivate func refreshButtonTapped() {
        webView.reload()
    }
    
    @objc fileprivate func moreOptionsButtonTapped() {
        let alert = UIAlertController()
        let openInSafariAction = UIAlertAction(title: "Open in Safari", style: .default) {
            (alert) in
            if let url = URL(string: self.urlToLoad) {
                UIApplication.shared.openURL(url)
            }
        }
        alert.addAction(openInSafariAction)
        let copyLinkAction = UIAlertAction(title: "Copy Link", style: .default) {
            (alert) in
            UIPasteboard.general.string = self.urlToLoad
        }
        alert.addAction(copyLinkAction)
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(alertCancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func forwardButtonTapped() {
        webView.goForward()
    }
    
    fileprivate func loadUrl() {
        if let url = URL(string: urlToLoad) {
            webView.load(URLRequest(url: url))
        }
    }
    
    fileprivate func activityIndicatorON() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    fileprivate func activityIndicatorOFF() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @discardableResult fileprivate func make(_ view: UIView,
                          layoutAttributes: [NSLayoutAttribute],
                          equalToView: UIView?,
                          equalToAttributes: [NSLayoutAttribute],
                          offset: CGFloat,
                          addConstraintToView: UIView? = nil,
                          multiply: CGFloat = 1,
                          divide: CGFloat = 1) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        var layoutConstraints:[NSLayoutConstraint] = []
        for i in 0..<layoutAttributes.count {
            let constraint = NSLayoutConstraint(item: view, attribute: layoutAttributes[i], relatedBy: .equal, toItem: equalToView, attribute: equalToAttributes[i], multiplier: multiply / divide, constant: offset)
            layoutConstraints.append(constraint)
            addConstraintToView != nil ? addConstraintToView?.addConstraint(constraint) : equalToView?.addConstraint(constraint)
        }
        return layoutConstraints
    }
    
    /**
     Injects javascript from `resource` file name.
     
     - Parameter resource: The file name for the javascript
     
     - Returns: A new optional string from the execution of the javascript file
     */
    public func injectJavascriptFrom(resource: String, complete: @escaping (_ resultString: String?) -> Void) {
        let jsPath: String? = Bundle.main.path(forResource: resource, ofType: "js")
        if let jsPath = jsPath {
            let js = try? String(contentsOfFile: jsPath, encoding: String.Encoding.utf8)
            webView.evaluateJavaScript(js ?? "") { (result, error) in
                complete(result as? String)
            }
        }
        complete(nil)
    }
    
    /**
     Injects javascript from `string` script.
     
     - Parameter string: The javascript code
     
     - Returns: A new optional string from the execution of the javascript code
     */
    public func injectJavascriptFrom(string: String, complete: @escaping (_ resultString: String?) -> Void) {
        webView.evaluateJavaScript(string) { (result, error) in
            complete(result as? String)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webViewControllerDidStartLoad(self)
        activityIndicatorON()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webViewControllerDidFinishLoad(self)
        activityIndicatorOFF()
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        
        if let delegate = delegate {
            backButton.tintColor = backButton.isEnabled ? delegate.webViewController(self, enabledTintColorFor: backButton) : delegate.webViewController(self, disabledTintColorFor: backButton)
            forwardButton.tintColor = forwardButton.isEnabled ? delegate.webViewController(self, enabledTintColorFor: forwardButton) : delegate.webViewController(self, disabledTintColorFor: forwardButton)
        } else {
            backButton.tintColor = backButton.isEnabled ? .blue : .gray
            forwardButton.tintColor = forwardButton.isEnabled ? .blue : .gray
        }
    }
}
