# EasyTipView

[![Version](https://img.shields.io/cocoapods/v/EasyTipView.svg?style=flat)](http://cocoapods.org/pods/EasyTipView)
[![License](https://img.shields.io/cocoapods/l/EasyTipView.svg?style=flat)](http://cocoapods.org/pods/EasyTipView)
[![Platform](https://img.shields.io/cocoapods/p/EasyTipView.svg?style=flat)](http://cocoapods.org/pods/EasyTipView)

Purpose
--------------

EasyTipView is a custom tooltip view written in Swift that can be used as a call to action or informative tip. It can be presented for
any ``UIBarButtonItem`` or ``UIView`` subclass. In addition it handles automatically orientation changes and will always point to the correct view or item.

![Example](/../master/images/preview.gif)

Installation
--------------

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate EasyTipView into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'EasyTipView', '~> 0.1.3'
```

Then, run the following command:

```bash
$ pod install
```

In case Xcode complains (<i>"Cannot load underlying module for EasyTipView"</i>) go to Product and choose Clean (or simply press <kbd>⇧</kbd><kbd>⌘</kbd><kbd>K</kbd>).

Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 8.0 (Xcode 6.x)

Usage
--------------

1) First you should customize the preferences:
```swift

  var preferences = EasyTipView.Preferences()
  preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
  preferences.drawing.foregroundColor = UIColor.whiteColor()
  preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
  preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.Top

  /*
   * Optionally you can make these preferences global for all EasyTipViews
   */
  EasyTipView.globalPreferences = preferences

```

2) Secondly you call the ``showAnimated:forView:withinSuperview:text:preferences:delegate:`` method:
```swift
  EasyTipView.show(forView: self.buttonB,
  withinSuperview: self.navigationController?.view,
  text: "Tip view inside the navigation controller's view. Tap to dismiss!",
  preferences: preferences,
  delegate: self)
```

**Note that if you set the ```EasyTipView.globalPreferences```, you can ommit the ```preferences``` parameter.**

Custom types
--------------

```swift

public protocol EasyTipViewDelegate : class {
    func easyTipViewDidDismiss(tipView : EasyTipView)
}

```

Custom protocol which defines one method to be called on the delegate after the ``EasyTipView`` has been dismissed.

```swift
public struct Preferences {

      public struct Drawing {
          public var cornerRadius        = CGFloat(5)
          public var arrowHeight         = CGFloat(5)
          public var arrowWidth          = CGFloat(10)
          public var foregroundColor     = UIColor.whiteColor()
          public var backgroundColor     = UIColor.redColor()
          public var arrowPosition       = ArrowPosition.Bottom
          public var textAlignment       = NSTextAlignment.Center
          public var borderWidth         = CGFloat(0)
          public var borderColor         = UIColor.clearColor()
          public var font                = UIFont.systemFontOfSize(15)
      }

      public struct Positioning {
          public var bubbleHInset         = CGFloat(10)
          public var bubbleVInset         = CGFloat(1)
          public var textHInset           = CGFloat(10)
          public var textVInset           = CGFloat(10)
          public var maxWidth             = CGFloat(200)
      }

      public var drawing      = Drawing()
      public var positioning  = Positioning()
  }
```
Custom structure which encapsulates all the customizable properties of the ``EasyTipView``. These preferences have been split into two structures:
* ```Drawing``` - encapsulates customizable properties specifying how ```EastTipView``` will be drawn on screen.
* ```Positioning``` - encapsulates customizable properties specifying where ```EasyTipView``` will be drawn within its own bounds.

```swift
enum ArrowPosition {
  case Top
  case Bottom
}
```
Custom enumeration which defines the supported arrow positions.

Methods
--------------

```swift
// MARK:- Class methods -

  /**
    Presents an EasyTipView pointing to a particular UIBarButtonItem instance within the specified superview

    - parameter animated:    Pass true to animate the presentation.
    - parameter item:        The UIBarButtonItem instance which the EasyTipView will be pointing to.
    - parameter superview:   A view which is part of the UIBarButtonItem instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
    - parameter text:        The text to be displayed.
    - parameter preferences: The preferences which will configure the EasyTipView.
    - parameter delegate:    The delegate.
    */
    public class func show(animated animated : Bool = true, forItem item : UIBarButtonItem, withinSuperview superview : UIView? = nil, text : String, preferences: Preferences = EasyTipView.globalPreferences, delegate : EasyTipViewDelegate? = nil)

    /**
     Presents an EasyTipView pointing to a particular UIView instance within the specified superview

     - parameter animated:    Pass true to animate the presentation.
     - parameter view:        The UIView instance which the EasyTipView will be pointing to.
     - parameter superview:   A view which is part of the UIView instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     - parameter text:        The text to be displayed.
     - parameter preferences: The preferences which will configure the EasyTipView.
     - parameter delegate:    The delegate.
    */
    public class func show(animated animated : Bool = true, forView view : UIView, withinSuperview superview : UIView? = nil, text :  String, preferences: Preferences = EasyTipView.globalPreferences, delegate : EasyTipViewDelegate? = nil)

// MARK:- Instance methods -

    /**
    Presents an EasyTipView pointing to a particular UIBarButtonItem instance within the specified superview

    - parameter animated:  Pass true to animate the presentation.
    - parameter item:      The UIBarButtonItem instance which the EasyTipView will be pointing to.
    - parameter superview: A view which is part of the UIBarButtonItem instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
    */
    public func show(animated animated : Bool = true, forItem item : UIBarButtonItem, withinSuperView superview : UIView? = nil)

    /**
     Presents an EasyTipView pointing to a particular UIView instance within the specified superview

     - parameter animated:  Pass true to animate the presentation.
     - parameter view:      The UIView instance which the EasyTipView will be pointing to.
     - parameter superview: A view which is part of the UIView instances superview hierarchy. Ignore this parameter in order to display the EasyTipView within the main window.
     */
    public func show(animated animated : Bool = true, forView view : UIView, withinSuperview superview : UIView? = nil)

    /**
     Dismisses the EasyTipView

     - parameter completion: Completion block to be executed after the EasyTipView is dismissed.
     */
    public func dismiss(withCompletion completion : (() -> ())? = nil)
```

License
--------------

```EasyTipView``` is released under the MIT license. See the ```LICENSE``` file for details.

Contact
--------------

You can follow or drop me a line on [my Twitter account](https://twitter.com/teodorpatras). If you find any issues on the project, you can open a ticket. Pull requests are also welcome.
