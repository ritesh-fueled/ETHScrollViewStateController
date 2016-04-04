//
//  ETHPaginationManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 20/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

public protocol ETHPaginationManagerDelegate: NSObjectProtocol {
	func paginationManagerShouldStartLoading(controller: ETHPaginationManager) -> Bool
	func paginationManagerDidStartLoading(controller: ETHPaginationManager, onCompletion: CompletionHandler)
}

public class ETHPaginationManager: NSObject {
  
  weak var delegate: ETHPaginationManagerDelegate?
  var scrollView: UIScrollView!
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  
  public init(scrollView: UIScrollView?, delegate: ETHPaginationManagerDelegate?, stateConfig: ETHStateConfiguration = ETHStateConfiguration(thresholdInitiateLoading: 0, loaderFrame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, kDefaultLoaderHeight), thresholdStartLoading: kDefaultLoaderHeight)) {
    
    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self, showDefaultLoader: stateConfig.showDefaultLoader)
  }
  
  convenience override init() {
    self.init(scrollView: nil, delegate: nil)
  }
  
  private func calculateDelta(offset: CGFloat) -> CGFloat {
    let calculatedOffset = max(0, scrollView.contentSize.height - scrollView.frame.size.height)
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

extension ETHPaginationManager: ETHScrollViewStateControllerDataSource {
  
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
    newInset?.bottom += startAnimation ? self.stateConfig.loaderFrame.size.height : -self.stateConfig.loaderFrame.size.height
    return newInset!
  }
  
  public func stateControllerLoaderFrame() -> CGRect {
    var frame = self.stateConfig.loaderFrame
    frame.origin.y = self.scrollView.contentSize.height
    self.stateConfig.loaderFrame = frame
    return frame
  }
 
}

extension ETHPaginationManager: ETHScrollViewStateControllerDelegate {
  
  public func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.paginationManagerDidStartLoading(self, onCompletion: onCompletion)
  }
	
	public func stateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool {
		return self.delegate?.paginationManagerShouldStartLoading(self) ?? true
	}
	
}
