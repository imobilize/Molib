
import Foundation
import UIKit
import MessageUI
import WebKit

public class MOWebViewController: UINavigationController, MFMailComposeViewControllerDelegate {
    
    var request: URLRequest!
    let webView = WKWebView()
    let viewController = UIViewController()
    var isInitialLoad = true
    
    public init(request: URLRequest) {
        
        self.request = request
        viewController.view = webView

        super.init(rootViewController: viewController)
        
        webView.navigationDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public convenience init(request: URLRequest, title: String) {
        
        self.init(request: request)
        self.navigationBar.topItem?.title = title
    }
    
    override public func viewDidLoad() {
    
        super.viewDidLoad()
        
        refreshButtonPressed(sender: self)
    }
    
    //MARK: pragma mark Action callbacks
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
    
        self.webView.load(self.request)
    }
}

extension MOWebViewController: WKNavigationDelegate {
    
    @objc public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {

    }

    @objc public func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        
    }
    
    @objc public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

        if self.isInitialLoad {
            self.isInitialLoad = false
        } else {
            webView.stopLoading()
        }
    }
}
