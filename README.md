# WebViewController

[![CI Status](http://img.shields.io/travis/sukov/WebViewController.svg?style=flat)](https://travis-ci.org/sukov/SHGWebViewController)
[![Version](https://img.shields.io/cocoapods/v/SHGWebViewController.svg?style=flat)](http://cocoapods.org/pods/SHGWebViewController)
[![License](https://img.shields.io/cocoapods/l/SHGWebViewController.svg?style=flat)](http://cocoapods.org/pods/SHGWebViewController)
[![Language Swift](https://img.shields.io/badge/Language-Swift%203.0-orange.svg?style=flat)](https://swift.org)
[![Platform](https://img.shields.io/cocoapods/p/SHGWebViewController.svg?style=flat)](http://cocoapods.org/pods/SHGWebViewController)

## Installation

SHGWebViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SHGWebViewController'
```

## Usage

### Import

```swift
import WebViewController
```

### WebViewControllerDelegate

```swift
func webViewController(_ webViewController: WebViewController, setupAppearanceForMain view: UIView)
func webViewControllerDidStartLoad(_ webViewController: WebViewController)
func webViewControllerDidFinishLoad(_ webViewController: WebViewController)
// default color .gray
func webViewController(_ webViewController: WebViewController, disabledTintColorFor button: UIButton) -> UIColor
// default color .blue
func webViewController(_ webViewController: WebViewController, enabledTintColorFor button: UIButton) -> UIColor
```

## Author

sukov, gorjan5@hotmail.com

## License

SHGWebViewController is available under the MIT license. See the LICENSE file for more info.
