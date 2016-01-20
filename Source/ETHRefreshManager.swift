//
//  ETHRefreshManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

protocol ETHRefreshManagerDelegate: NSObjectProtocol {
  func refreshManagerDidStartLoading(manager: ETHRefreshManager, onCompletion: () -> Void)
}

class ETHRefreshManager: NSObject {
  
  weak var delegate: ETHRefreshManagerDelegate!
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  
  init(scrollView: UIScrollView, delegate: ETHRefreshManagerDelegate, stateConfig: ETHStateConfiguration = ETHStateConfiguration(thresholdInitiateLoading: 0, loaderFrame: CGRectMake(0, -64, UIScreen.mainScreen().bounds.size.width, 64), thresholdStartLoading: -64)) {

    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self, showDefaultLoader: stateConfig.showDefaultLoader)
  }
  
}

extension ETHRefreshManager: ETHScrollViewStateControllerDataSource {
  
  func stateControllerWillObserveVerticalScrolling() -> Bool {
    return true
  }
  
  func stateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    return offset < self.stateConfig.thresholdInitiateLoading
  }
  
  func stateControllerDidReleaseToStartLoading(offset: CGFloat) -> Bool {
    return offset < self.stateConfig.thresholdStartLoading
  }
  
  func stateControllerDidReleaseToCancelLoading(offset: CGFloat) -> Bool {
    return offset > self.stateConfig.thresholdStartLoading
  }

  func stateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = scrollView.contentInset
    newInset.top += startAnimation ? self.stateConfig.loaderFrame.size.height : -self.stateConfig.loaderFrame.size.height
    return newInset
  }
  
  func stateControllerLoaderFrame() -> CGRect {
    return self.stateConfig.loaderFrame
  }
  
}

extension ETHRefreshManager: ETHScrollViewStateControllerDelegate {
  
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: () -> Void) {
    self.delegate.refreshManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}