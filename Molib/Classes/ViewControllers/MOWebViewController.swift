
import Foundation
import UIKit
import MessageUI

public class MOWebViewController: UIViewController, MFMailComposeViewControllerDelegate, UIWebViewDelegate {
    
    var request: URLRequest!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var failureMessageContainer: UILabel!
    
    
    public init(request: URLRequest) {
        
        self.request = request
       
        let bundle = Bundle(for: MOWebViewController.self)
        
        super.init(nibName: "MOWebViewController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public convenience init(request: URLRequest, title: String) {
        
        self.init(request: request)
        self.title = title

    }
    
    override public func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.webView.delegate = self

        refreshButtonPressed(sender: self)
    }
    
    
    //MARK: UIWebViewDelegate protocol implementation
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        
        self.activityIndicatorView.startAnimating()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
    
        self.activityIndicatorView.stopAnimating()
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        self.activityIndicatorView.stopAnimating()
        self.failureMessageContainer.isHidden = false

    }
    
    
    //MARK: pragma mark Action callbacks
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
    
        self.webView.loadRequest(self.request)

        self.failureMessageContainer.isHidden = true
        
    }
}
