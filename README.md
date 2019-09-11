# sheets

You always wanted to have that card-like controller similar to that in Maps or Shortcuts, didn't you? Well, now you can have it for free with sheets! sheets provides an easy to use container controller, that has API similar to that of UINavigationController. 

# Installation

## Swift Package Manager

_Requires XCode 11_. In project menu under Swift Packages add sheets via URL. 

## Cocoapods

Add `pod sheets` to your Podfile.

# Usage

The idea behind sheets is simple. sheets provides `SheetController` container view controller. It contains one _main view controller_ and one or more _view controllers_, presented inside the card. Main view controller is what is behind the card. This controller cannot be changed after initialization (at least for now). View controllers inside the card are dynamic, meaning they can be pushed and popped as needed, though there always has to be one VC in the stack (having no view controllers inside the card doesn't really make that much sense).

SheetController can be customized via a number of convenient options. Those options include:
* `isExpandGestureEnabled` - controls whether or not taps on the card's header make it expand. `true` by default.
* `isCollapseGestureEnabled` - controls whether or not taps on main view controller make the card collapse while it is fully expanded. `true` by default.
* `cancelsTouchesInCollapsedState` - controls whether or not taps on the card are blocked while it is collapsed. _When enabled messes up content dragging, will be resolved in future updates_. `false` by default.
* `hidesTabBarUponExpansion` - controls whether or not `SheetController` tries to hide tab bar (if present) upon the card's expansion. `true` by default.
* `bounces` - controls spring damping of card's animation. If set to `false`, sets damping to 1.0, which disables bounce. `true` by default.
* `animatesCorners` - controls whether or not card's corner radius is set to 0.0 when it is collapsed. This behavior is rather similar to that of Music app's card. `false` by default.
* `closeButtonImage` - set this property to your custom close button image. `nil` by default.
