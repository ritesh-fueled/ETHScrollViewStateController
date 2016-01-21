//
//  ViewController.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var refreshManager: ETHRefreshManager!
  var paginatiohManager: ETHPaginationManager!
  var count = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    // assign the config to refresh manager
    self.refreshManager = ETHRefreshManager(scrollView: self.tableView, delegate: self)
    self.paginatiohManager = ETHPaginationManager(scrollView: self.tableView, delegate: self)
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    cell.textLabel?.text = "ETHScrollViewController"
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.count += 10
    return count
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
      self.tableView.reloadData()
      onCompletion()
    }
  }
}

