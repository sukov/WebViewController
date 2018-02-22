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
    fileprivate let bundle = Bundle(for: WebViewController.self)
    fileprivate let estimatedProgressKeyPath = "estimatedProgress"
    fileprivate let titleKeyPath = "title"
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
    fileprivate lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = UIColor(white: 1, alpha: 0)
        progressView.progressTintColor = .blue
        return progressView
    }()
    public var progressTintColor: UIColor {
        get {
            return progressView.progressTintColor ?? .blue
        }
        
        set {
            progressView.progressTintColor = newValue
        }
    }
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
        removeObservers()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        setupNavigationBar()
        loadUrl()
        delegate?.webViewController(self, setupAppearanceForMain: view)
        setupObservers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.addSubview(progressView)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        progressView.removeFromSuperview()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = (size.width - 200) / 5
        for leftOffsetConstraint in buttonLeftOffsetConstraints {
            leftOffsetConstraint.constant = offset
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let navigationController = navigationController else { return }
        progressView.frame = CGRect(x: 0, y: navigationController.navigationBar.frame.size.height - progressView.frame.size.height, width: navigationController.navigationBar.frame.size.width, height: progressView.frame.size.height)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case estimatedProgressKeyPath?:
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        case titleKeyPath?:
            navigationItem.title = webView.title
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        webView = WKWebView()
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        
        let imageEdgeInsets = UIEdgeInsetsMake(12, 0, 12, 0)
        
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
        guard let navigationController = navigationController else { return }
        
        var titleUrl = urlToLoad.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
        
        if let firstSlashIndex = titleUrl.index(of: "/") {
            titleUrl = String(titleUrl[firstSlashIndex...])
        }
        navigationItem.title = titleUrl
        
        if navigationController.childViewControllers.count == 1 {
            let closeBarButton = UIBarButtonItem(image: UIImage(named: "closeX", in: bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(closeButtonTapped))
            navigationItem.leftBarButtonItem = closeBarButton
        }
    }
    
    fileprivate func setupObservers() {
        webView.addObserver(self, forKeyPath: estimatedProgressKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: titleKeyPath, options: .new, context: nil)
    }
    
    fileprivate func removeObservers() {
        webView.removeObserver(self, forKeyPath: estimatedProgressKeyPath)
        webView.removeObserver(self, forKeyPath: titleKeyPath)
    }
    
    @objc fileprivate func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
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
        alert.popoverPresentationController?.permittedArrowDirections = []
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = view.bounds
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
    @objc public func injectJavascriptFrom(resource: String, complete: @escaping (_ resultString: String?) -> Void) {
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
    @objc public func injectJavascriptFrom(string: String, complete: @escaping (_ resultString: String?) -> Void) {
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
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
}

extension WebViewController: WKUIDelegate {
    // Fix for `target=_blank` links that open in new tab
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
