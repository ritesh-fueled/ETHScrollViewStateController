//
//  ETHScrollViewStateController.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

/*
-ETHScrollViewStateController manages the state of your scrollView irrespective of whether its used as a pull-to-refresh or paginator (load more) or something else.

-One can design their own pull-to-refresh or paginator by implementing ETHScrollViewStateController's datasource methods
*/

enum ETHScrollViewStateControllerState: Int {
  case Normal         // when user is simply scrolling to see data
  case Ready          // when user has pulled the scrollView enough i.e. beyond a threshold and loading could begin if released at this stage
  case WillBeLoading  // when user has released the scrollView (beyond a threshold) and it is about to get stablise at a threshold
  case Loading        // when user has started loading
}

typealias CompletionHandler = () -> Void

protocol ETHScrollViewStateControllerDataSource: NSObjectProtocol {
  // it defines the condition whether to use y or x point for content offset
  func stateControllerWillObserveVerticalScrolling() -> Bool
  
  // it defines the condition when to enter the loading zone
  func stateControllerShouldInitiateLoading(offset: CGFloat) -> Bool
  
  // it defines the condition when the loader stablises (after releasing) and loading can start
  func stateControllerDidReleaseToStartLoading(offset: CGFloat) -> Bool
  
  // it defines the condition when to cancel loading
  func stateControllerDidReleaseToCancelLoading(offset: CGFloat) -> Bool
  
  // it will return the Y position of loader
  func stateControllerLoaderFrame() -> CGRect
  
  // it will return the loader inset
  func stateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets
}

extension ETHScrollViewStateControllerDataSource {
  
  func stateControllerWillObserveVerticalScrolling() -> Bool {
    // default implementation
    return true
  }
  
}

protocol ETHScrollViewStateControllerDelegate: NSObjectProtocol {
  func stateControllerWillStartLoading(controller: ETHScrollViewStateController, loadingView: UIView)
  func stateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: () -> Void)
  func stateControllerDidFinishLoading(controller: ETHScrollViewStateController)
}

extension ETHScrollViewStateControllerDelegate {
  func stateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool {
    // default implementation
    return true
  }

  func scrollViewStateControllerWillStartLoading(controller: ETHScrollViewStateController, loadView: UIView) {
    // default imlpementation
  }
  
  func scrollViewStateControllerDidFinishLoading(controller: ETHScrollViewStateController) {
    // default imlpementation
  }
}

class ETHScrollViewStateController: NSObject {
  
  let kDefaultLoadingHeight: CGFloat = 64.0
  let kInsetInsertAnimationDuration: NSTimeInterval = 0.7
  let kInsetRemoveAnimationDuration: NSTimeInterval = 0.3
  
  weak var dataSource: ETHScrollViewStateControllerDataSource!
  weak var delegate: ETHScrollViewStateControllerDelegate!
  
  private var scrollView: UIScrollView?
  private var state: ETHScrollViewStateControllerState = .Normal
  private var loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  init(scrollView: UIScrollView, dataSource: ETHScrollViewStateControllerDataSource!, delegate: ETHScrollViewStateControllerDelegate!, showDefaultLoader: Bool = true) {
    super.init()
    
    self.scrollView = scrollView
    self.dataSource = dataSource
    self.delegate = delegate
    self.state = .Normal

    self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    if showDefaultLoader {
      addDefaultLoadView()
    }
  }
  
  private func addDefaultLoadView() {
    self.loadingView.frame = self.dataSource.stateControllerLoaderFrame()
    self.scrollView?.addSubview(self.loadingView)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentOffset" {
      var newOffset: CGFloat = 0
      if dataSource.stateControllerWillObserveVerticalScrolling() {
        newOffset = (change?[NSKeyValueChangeNewKey]?.CGPointValue?.y)!

      } else {
        newOffset = (change?[NSKeyValueChangeNewKey]?.CGPointValue?.x)!
      }
    }
  }
  
}