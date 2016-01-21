//
//  ETHPaginationManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 20/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

protocol ETHPaginationManagerDelegate: NSObjectProtocol {
  func paginationManagerDidStartLoading(controller: ETHPaginationManager, onCompletion: CompletionHandler)
}

class ETHPaginationManager: NSObject {
  
  weak var delegate: ETHPaginationManagerDelegate?
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  
  init(scrollView: UIScrollView, delegate: ETHPaginationManagerDelegate, stateConfig: ETHStateConfiguration = ETHStateConfiguration(thresholdInitiateLoading: 0, loaderFrame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64), thresholdStartLoading: 64)) {
    
    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self, showDefaultLoader: stateConfig.showDefaultLoader)
  }
  
  private func calculateDelta(offset: CGFloat) -> CGFloat {
    let calculatedOffset = max(0, scrollView.contentSize.height - scrollView.frame.size.height)
    let delta = offset - calculatedOffset
    return delta
  }
  
}

extension ETHPaginationManager: ETHScrollViewStateControllerDataSource {
  
  func stateControllerWillObserveVerticalScrolling() -> Bool {
    return true
  }
  
  func stateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.calculateDelta(offset) > self.stateConfig.thresholdInitiateLoading
    return shouldStart
  }
  
  func stateControllerDidReleaseToStartLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.calculateDelta(offset) > self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  func stateControllerDidReleaseToCancelLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.calculateDelta(offset) < self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  func stateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = scrollView?.contentInset
    newInset?.bottom += startAnimation ? self.stateConfig.loaderFrame.size.height : -self.stateConfig.loaderFrame.size.height
    return newInset!
  }
  
  func stateControllerLoaderFrame() -> CGRect {
    var frame = self.stateConfig.loaderFrame
    frame.origin.y = self.scrollView.contentSize.height
    self.stateConfig.loaderFrame = frame
    return frame
  }
 
}

extension ETHPaginationManager: ETHScrollViewStateControllerDelegate {
  
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.paginationManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}
