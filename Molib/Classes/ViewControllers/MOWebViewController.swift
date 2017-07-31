
import Foundation
import UIKit
import MessageUI

public class MOWebViewController: UIViewController, MFMailComposeViewControllerDelegate, UIWebViewDelegate {
    
    var request: NSURLRequest!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var failureMessageContainer: UILabel!
    
    
    public init(request: NSURLRequest) {
        
        self.request = request
       
        let bundle = NSBundle(forClass: MOWebViewController.self)
        
        super.init(nibName: "MOWebViewController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public convenience init(request: NSURLRequest, title: String) {
        
        self.init(request: request)
        self.title = title

    }
    
    override public func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.webView.delegate = self

        refreshButtonPressed(self)
    }
    
    
    //MARK: UIWebViewDelegate protocol implementation
    
    public func webViewDidStartLoad(webView: UIWebView) {
        
        self.activityIndicatorView.startAnimating()
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
    
        self.activityIndicatorView.stopAnimating()
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        self.activityIndicatorView.stopAnimating()
        self.failureMessageContainer.hidden = false

    }
    
    
    //MARK: pragma mark Action callbacks
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
    
        self.webView.loadRequest(self.request)

        self.failureMessageContainer.hidden = true
        
    }
}
