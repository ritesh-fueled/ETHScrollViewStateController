//
//  ViewController.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var listView: UIScrollView!

  var refreshManager: ETHRefreshManager!
  var paginatioManager: ETHPaginationManager!
  var horizontalPaginationManager: ETHHorizontalPaginationManager!
  var count = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    self.refreshManager = ETHRefreshManager(scrollView: self.listView, delegate: self)
    self.paginatioManager = ETHPaginationManager(scrollView: self.listView, delegate: self)
    self.horizontalPaginationManager = ETHHorizontalPaginationManager(scrollView: self.listView, delegate: self)
  }
}

extension ViewController: ETHRefreshManagerDelegate {
  
  func refreshManagerDidStartLoading(controller: ETHRefreshManager, onCompletion: CompletionHandler) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
      onCompletion()
    }
  }
  
}

extension ViewController: ETHPaginationManagerDelegate {
  func paginationManagerDidStartLoading(controller: ETHPaginationManager, onCompletion: CompletionHandler) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
      onCompletion()
    }
  }
}

extension ViewController: ETHHorizontalPaginationManagerDelegate {
  
  func horizontalPaginationManagerDidStartLoading(controller: ETHHorizontalPaginationManager, onCompletion: CompletionHandler) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
      onCompletion()
    }
  }
  
}
