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
  func refreshManagerDidStartLoading(controller: ETHRefreshManager, onCompletion: CompletionHandler)
}

class ETHRefreshManager: NSObject {
  
  weak var delegate: ETHRefreshManagerDelegate?
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  
  init(scrollView: UIScrollView, delegate: ETHRefreshManagerDelegate, stateConfig: ETHStateConfiguration = ETHStateConfiguration(thresholdInitiateLoading: 0, loaderFrame: CGRectMake(0, -kDefaultLoaderHeight, UIScreen.mainScreen().bounds.size.width, kDefaultLoaderHeight), thresholdStartLoading: -kDefaultLoaderHeight)) {

    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self, showDefaultLoader: stateConfig.showDefaultLoader)
  }
  
}

extension ETHRefreshManager: ETHScrollViewStateControllerDataSource {
  
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
  
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.refreshManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}
