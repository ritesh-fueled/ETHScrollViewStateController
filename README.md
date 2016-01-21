#ETHScrollViewStateController
##About

ETHScrollViewStateController allows you to have **Refresh** (pull-to-refresh) & **Pagination** (load-more) functionality with just few lines of code. It can used with ```UIScrollView``` or its subclasses like ```UITableView``` & ```UICollectionView```. There are 2 ways you can use it:

- #### Default
It provides default refresh & pagination-managers (vertical & horizontal) which allows you to have a quick plug-n-play support to handle your network calls.

- #### Custom
Abitlity to quickly write your own custom refresh & pagination-manager. One can define the ```ETHScrollViewStateControllerDataSource``` methods to defines their custom functionality.


##Installation

To integrate ETHScrollViewStateController into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ETHScrollViewStateController', :git => 'https://github.com/ritesh-fueled/ETHScrollViewStateController.git', :branch => 'develop'
```


##Usage

There are 2 ways of using it:

###Default Managers
Default managers allows to have the following functionalities with few lines of code and they provide their delegate methods to make the api call or animate your custom loader.

- ETHRefreshManager

```
let refreshManager = ETHRefreshManager(scrollView: self.scrollView, delegate: self)

// delegate method
func refreshManagerDidStartLoading(controller: ETHRefreshManager, onCompletion: CompletionHandler)

```

- ETHPaginationManager

```
let paginatioManager = ETHPaginationManager(scrollView: self.scrollView, delegate: self)

// delegate method
func paginationManagerDidStartLoading(controller: ETHPaginationManager, onCompletion: CompletionHandler)
```

- ETHHorizontalPaginationManager

```
let horizontalPaginationManager = ETHHorizontalPaginationManager(scrollView: self.scrollView, delegate: self)

// delegate method
func horizontalPaginationManagerDidStartLoading(controller: ETHHorizontalPaginationManager, onCompletion: CompletionHandler)
```

###Custom Manager

Other than the default managers if you feel you need more customizations then you can directly implement ```ETHScrollViewStateControllerDataSource``` methods to define your various custom conditions in your controller or any manager class.


```
  // it defines the condition whether to use y or x point for content offset
  func stateControllerWillObserveVerticalScrolling() -> Bool
  
  // it defines the condition when to enter the loading zone
  func stateControllerShouldInitiateLoading(offset: CGFloat) -> Bool
  
  // it defines the condition when the loader stablises (after releasing) and loading can start
  func stateControllerDidReleaseToStartLoading(offset: CGFloat) -> Bool
  
  // it defines the condition when to cancel loading
  func stateControllerDidReleaseToCancelLoading(offset: CGFloat) -> Bool
  
  // it will return the loader frame
  func stateControllerLoaderFrame() -> CGRect
  
  // it will return the loader inset
  func stateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets
```

It provide following ```ETHScrollViewStateControllerDelegate``` methods to handle your api calls & custom loader animations.

```
// it gets called continously till your loading starts 
func stateControllerWillStartLoading(controller: ETHScrollViewStateController, loadingView: UIActivityIndicatorView)

// it allows you to decide if you want loading action 
func stateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool

// it gets called once when loading actually starts
func stateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler)

//it gets called when loading is finished
func stateControllerDidFinishLoading(controller: ETHScrollViewStateController)
```


## Contributing

Open an issue or send pull request [here](https://github.com/ritesh-fueled/ETHScrollViewStateController/issues/new).
