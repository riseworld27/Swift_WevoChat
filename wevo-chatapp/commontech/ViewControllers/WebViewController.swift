//
//  WebView.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 2/11/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import UIKit
import OAuthSwift


class WebViewController: OAuthWebViewController, UIWebViewDelegate {
    
    var targetURL : NSURL = NSURL()
    let webView : UIWebView = UIWebView()
    
    //Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.frame = UIScreen.mainScreen().bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func handle(url: NSURL) {
        targetURL = url
        super.handle(url)
    }
    
    //Private methods
    
    func loadAddressURL() {
        
        let req = NSURLRequest(URL: targetURL)
        self.webView.loadRequest(req)
    }
    
    //UIWebView Delegate methods
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.URL where (url.scheme == "igf9469d014dfb455d92910ae33b9111f5"){
            self.dismissWebViewController()
        }
        
        return true
    }
}
