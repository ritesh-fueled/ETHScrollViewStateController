//
//  ETHRefreshManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

let kDefaultRefreshLoaderYPosition: CGFloat = -64
let kDefaultRefreshLoaderThreshold: CGFloat = -128
let kDefaultRefreshLoaderInset: CGFloat = 64

protocol ETHRefreshManagerDelegate: NSObjectProtocol {
  func refreshManagerDidStartLoading(manager: ETHRefreshManager, onCompletion: () -> Void)
}

class ETHRefreshManager: NSObject {
  
  weak var delegate: ETHRefreshManagerDelegate!
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  
  init(scrollView: UIScrollView, delegate: ETHRefreshManagerDelegate!) {
    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self)
  }
  
}

extension ETHRefreshManager: ETHScrollViewStateControllerDataSource {
  
  func stateControllerWillObserveVerticalScrolling() -> Bool {
    return true
  }
  
  func stateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    return offset < 0
  }
  
  func stateControllerDidReleaseToCancelLoading(offset: CGFloat) -> Bool {
    return offset > kDefaultRefreshLoaderThreshold
  }

  func stateControllerDidReleaseToStartLoading(offset: CGFloat) -> Bool {
    return offset < kDefaultRefreshLoaderThreshold
  }
  
  func stateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = scrollView?.contentInset
    newInset?.top += startAnimation ? kDefaultRefreshLoaderInset : -kDefaultRefreshLoaderInset
    return newInset!
  }
  
  func stateControllerLoaderFrame() -> CGRect {
    return CGRectMake(0, kDefaultRefreshLoaderYPosition, UIScreen.mainScreen().bounds.size.width, kDefaultRefreshLoaderInset)
  }
  
}

extension ETHRefreshManager: ETHScrollViewStateControllerDelegate {
  
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: () -> Void) {
    self.delegate.refreshManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}