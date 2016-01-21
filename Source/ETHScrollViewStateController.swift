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
  func stateControllerWillStartLoading(controller: ETHScrollViewStateController, loadingView: UIActivityIndicatorView)
  func stateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool
  func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler)
  func stateControllerDidFinishLoading(controller: ETHScrollViewStateController)
}

extension ETHScrollViewStateControllerDelegate {
  func stateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool {
    // default implementation
    return true
  }

  func stateControllerWillStartLoading(controller: ETHScrollViewStateController, loadingView: UIActivityIndicatorView) {
    // default imlpementation
  }
  
  func stateControllerDidFinishLoading(controller: ETHScrollViewStateController) {
    // default imlpementation
  }
}

class ETHStateConfiguration: NSObject {
  var thresholdInitiateLoading: CGFloat = 0
  var loaderFrame: CGRect = CGRectZero
  var thresholdStartLoading: CGFloat = 0
  var showDefaultLoader = true
  
  init(thresholdInitiateLoading: CGFloat, loaderFrame: CGRect, thresholdStartLoading: CGFloat, showDefaultLoader: Bool = true) {
    self.loaderFrame = loaderFrame
    self.showDefaultLoader = showDefaultLoader
    self.thresholdInitiateLoading = thresholdInitiateLoading
    self.thresholdStartLoading = thresholdStartLoading
  }
}

class ETHScrollViewStateController: NSObject {
  
  let kDefaultLoadingHeight: CGFloat = 64.0
  let kInsetInsertAnimationDuration: NSTimeInterval = 0.7
  let kInsetRemoveAnimationDuration: NSTimeInterval = 0.3
  
  weak var dataSource: ETHScrollViewStateControllerDataSource!
  weak var delegate: ETHScrollViewStateControllerDelegate!
  
  private var scrollView: UIScrollView!
  private var state: ETHScrollViewStateControllerState = .Normal
  private var loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  init(scrollView: UIScrollView, dataSource: ETHScrollViewStateControllerDataSource!, delegate: ETHScrollViewStateControllerDelegate!, showDefaultLoader: Bool = true) {
    super.init()
    
    self.scrollView = scrollView
    self.dataSource = dataSource
    self.delegate = delegate
    self.state = .Normal

    self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    if showDefaultLoader {
      addDefaultLoadView()
    }
  }
  
  private func addDefaultLoadView() {
    self.loadingView.frame = self.dataSource.stateControllerLoaderFrame()
    self.scrollView.addSubview(self.loadingView)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentOffset" {
      var newOffset: CGFloat = 0
      if dataSource.stateControllerWillObserveVerticalScrolling() {
        newOffset = (change?[NSKeyValueChangeNewKey]?.CGPointValue?.y)!

      } else {
        newOffset = (change?[NSKeyValueChangeNewKey]?.CGPointValue?.x)!
      }
      
      handleLoadingCycle(newOffset)
    }
  }
  
  private func handleLoadingCycle(offset: CGFloat) {
    if (self.dataSource.stateControllerShouldInitiateLoading(offset)) {
      self.delegate.stateControllerWillStartLoading(self, loadingView: self.loadingView)
    }
    
    if self.scrollView.dragging {
      switch self.state {
      case .Normal:
        if self.dataSource.stateControllerDidReleaseToStartLoading(offset) {
          self.state = .Ready
        }
        
      case .Ready:
        if self.dataSource.stateControllerDidReleaseToCancelLoading(offset) {
          self.state = .Normal
        }
        
      default: break
      }
      
    } else if scrollView.decelerating {
      if self.state == .Ready {
        handleReadyState()
      }
    }
  }

  private func handleReadyState() {
    self.state = .WillBeLoading
    
    if self.delegate.stateControllerShouldStartLoading(self) {
      self.loadingView.frame = self.dataSource.stateControllerLoaderFrame()
      
      startUIAnimation({ [weak self] () -> Void in
        if let weakSelf = self {
          weakSelf.startLoading()
        }
      })
      
    } else {
      self.state = .Normal
    }
  }

  private func startLoading() {
    self.state = .Loading
    
    self.delegate.stateControllerDidStartLoading(self, onCompletion: {[weak self] () -> Void in
      if let weakSelf = self {
        weakSelf.stopLoading()
      }
    })
  }

  private func stopLoading() {
    self.state = .Normal
    
    self.stopUIAnimation({ [weak self] () -> Void in
      if let weakSelf = self {
        weakSelf.delegate.stateControllerDidFinishLoading(weakSelf)
      }
    })
  }
  
  private func startUIAnimation(onCompletion: CompletionHandler) {
    handleAnimation(startAnimation: true) { () -> Void in
      onCompletion()
    }
  }
  
  private func stopUIAnimation(onCompletion: CompletionHandler) {
    handleAnimation(startAnimation: false) { () -> Void in
      onCompletion()
    }
  }
  
  private func handleAnimation(startAnimation startAnimation: Bool, onCompletion: CompletionHandler) {
    if startAnimation {
      self.loadingView.startAnimating()
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        let oldContentOffset = self.scrollView.contentOffset
        self.scrollView.contentInset = self.dataSource.stateControllerInsertLoaderInsets(startAnimation)
        self.scrollView.contentOffset = oldContentOffset
        onCompletion()
      }

    } else {
      self.loadingView.stopAnimating()
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        UIView.animateWithDuration(self.kInsetRemoveAnimationDuration, animations: {[weak self] () -> Void in
          if let weakSelf = self {
            weakSelf.scrollView.contentInset = weakSelf.dataSource.stateControllerInsertLoaderInsets(startAnimation)
          }
        }, completion: { (finished: Bool) -> Void in
            onCompletion()
        })
      }
    }
  }
  
  deinit {
    self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
  }
  
}