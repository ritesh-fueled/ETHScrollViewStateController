//
//  ETHHorizontalPaginationManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 21/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

protocol ETHHorizontalPaginationManagerDelegate: NSObjectProtocol {
  func horizontalPaginationManagerDidStartLoading(controller: ETHHorizontalPaginationManager, onCompletion: CompletionHandler)
}

class ETHHorizontalPaginationManager: NSObject {
  
  weak var delegate: ETHHorizontalPaginationManagerDelegate?
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  
  init(scrollView: UIScrollView, delegate: ETHHorizontalPaginationManagerDelegate, stateConfig: ETHStateConfiguration = ETHStateConfiguration(thresholdInitiateLoading: 0, loaderFrame: CGRectMake(0, 0, kDefaultLoaderHeight, UIScreen.mainScreen().bounds.size.height), thresholdStartLoading: 0)) {
    
    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self, showDefaultLoader: stateConfig.showDefaultLoader)
  }
  
  private func calculateDelta(offset: CGFloat) -> CGFloat {
    let calculatedOffset = max(0, scrollView.contentSize.width - scrollView.frame.size.width)
    let delta = offset - calculatedOffset
    return delta
  }
  
}

extension ETHHorizontalPaginationManager: ETHScrollViewStateControllerDataSource {
  
  func stateControllerWillObserveVerticalScrolling() -> Bool {
    return false
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
    newInset?.right += startAnimation ? self.stateConfig.loaderFrame.size.width : -self.stateConfig.loaderFrame.size.width
    return newInset!
  }
  
  func stateControllerLoaderFrame() -> CGRect {
    var frame = self.stateConfig.loaderFrame
    frame.origin.x = self.scrollView.contentSize.width
    self.stateConfig.loaderFrame = frame
    return frame
  }
  
}

extension ETHHorizontalPaginationManager: ETHScrollViewStateControllerDelegate {
  
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.horizontalPaginationManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}
