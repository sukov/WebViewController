# WebViewController

[![CI Status](http://img.shields.io/travis/sukov/WebViewController.svg?style=flat)](https://travis-ci.org/sukov/SHGWebViewController)
[![Version](https://img.shields.io/cocoapods/v/SHGWebViewController.svg?style=flat)](http://cocoapods.org/pods/SHGWebViewController)
[![License](https://img.shields.io/cocoapods/l/SHGWebViewController.svg?style=flat)](http://cocoapods.org/pods/SHGWebViewController)
[![Language Swift](https://img.shields.io/badge/Language-Swift%204.0-orange.svg?style=flat)](https://swift.org)
[![Platform](https://img.shields.io/cocoapods/p/SHGWebViewController.svg?style=flat)](http://cocoapods.org/pods/SHGWebViewController)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate WebViewController into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
pod 'SHGWebViewController'
end
```

#### To use with Swift 3.x please ensure that you specify version 3.0.0

```ruby
pod 'SHGWebViewController', '~> 1.0.1'
```

Then, run the following command:

```bash
$ pod install
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
