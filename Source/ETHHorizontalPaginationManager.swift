//
//  ETHHorizontalPaginationManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 21/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

public protocol ETHHorizontalPaginationManagerDelegate: NSObjectProtocol {
  func horizontalPaginationManagerDidStartLoading(controller: ETHHorizontalPaginationManager, onCompletion: CompletionHandler)
}

public class ETHHorizontalPaginationManager: NSObject {
  
  weak var delegate: ETHHorizontalPaginationManagerDelegate?
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  
  public init(scrollView: UIScrollView?, delegate: ETHHorizontalPaginationManagerDelegate?, stateConfig: ETHStateConfiguration = ETHStateConfiguration(thresholdInitiateLoading: 0, loaderFrame: CGRectMake(0, 0, kDefaultLoaderHeight, UIScreen.mainScreen().bounds.size.height), thresholdStartLoading: 0)) {
    
    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self, showDefaultLoader: stateConfig.showDefaultLoader)
  }
  
  override convenience init() {
    self.init(scrollView: nil, delegate: nil)
  }
  
  private func calculateDelta(offset: CGFloat) -> CGFloat {
    let calculatedOffset = max(0, scrollView.contentSize.width - scrollView.frame.size.width)
    let delta = offset - calculatedOffset
    return delta
  }
 
  public func updateActivityIndicatorStyle(newStyle: UIActivityIndicatorViewStyle) {
    self.scrollViewStateController.updateActivityIndicatorStyle(newStyle)
  }
  
  public func updateActivityIndicatorColor(color: UIColor) {
    self.scrollViewStateController.updateActivityIndicatorColor(color)
  }
  
}

extension ETHHorizontalPaginationManager: ETHScrollViewStateControllerDataSource {
  
  public func stateControllerWillObserveVerticalScrolling() -> Bool {
    return false
  }
  
  public func stateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.calculateDelta(offset) > self.stateConfig.thresholdInitiateLoading
    return shouldStart
  }
  
  public func stateControllerDidReleaseToStartLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.calculateDelta(offset) > self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  public func stateControllerDidReleaseToCancelLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.calculateDelta(offset) < self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  public func stateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = scrollView?.contentInset
    newInset?.right += startAnimation ? self.stateConfig.loaderFrame.size.width : -self.stateConfig.loaderFrame.size.width
    return newInset!
  }
  
  public func stateControllerLoaderFrame() -> CGRect {
    var frame = self.stateConfig.loaderFrame
    frame.origin.x = self.scrollView.contentSize.width
    self.stateConfig.loaderFrame = frame
    return frame
  }
  
}

extension ETHHorizontalPaginationManager: ETHScrollViewStateControllerDelegate {
  
  public func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.horizontalPaginationManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}
