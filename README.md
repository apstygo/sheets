# sheets

You always wanted to have that card-like controller similar to that in Maps or Shortcuts, didn't you? Well, now you can have it for free with sheets! sheets provides an easy to use container controller, that has API similar to that of UINavigationController. 

## Installation

### Swift Package Manager

_Requires XCode 11_. In project menu under Swift Packages add sheets via URL. 

### Cocoapods

Add `pod sheets` to your Podfile.

## Usage

The idea behind sheets is simple. sheets provides `SheetController` container view controller. It contains one _main view controller_ and one or more _view controllers_, presented inside the sheet. Main view controller is what is behind the sheet. This controller cannot be changed after initialization (at least for now). View controllers inside the sheet are dynamic, meaning they can be pushed and popped as needed, though there always has to be at least one VC in the stack (having no view controllers inside the card doesn't really make that much sense).

To start using sheets in your project, initialize `SheetController` via `init(mainViewController:rootViewController:anchors:)` initializer, then present it as you would any other view controller.

## Customization

### Options

SheetController can be customized via a number of convenient options. Those options include:

| Option | Description | Default value |
| --- | --- | --- |
| `isExpandGestureEnabled` | Controls whether or not taps on the card's header make it expand. | `true` |
| `isCollapseGestureEnabled` | Controls whether or not taps on main view controller make the card collapse while it is fully expanded. | `true` |
| `cancelsTouchesInCollapsedState` | Controls whether or not taps on the card are blocked while it is collapsed. **When enabled messes up content dragging, will be resolved in future updates.** | `false` |
| `hidesTabBarUponExpansion` | Controls whether or not `SheetController` tries to hide tab bar (if present) upon the card's expansion. | `true` |
| `bounces` | Controls spring damping of card's animation. If set to `false`, sets damping to 1.0, which disables bounce. | `true` |
| `animatesCorners` | Controls whether or not card's corner radius is set to 0.0 when it is collapsed. This behavior is similar to that of Music's card UI. | `false` |
| `closeButtonImage` | Set this property to your custom close button image. | `nil` |
| `hasChevron` | Controls whether or not a chevron indicator is present at the top of each sheet. | `false` |

### Anchors

Another point of customization is anchors. Anchors define heights, to which sheet automatically snaps when the user stops dragging. Anchors themselves are defined in `Anchor` enum. Its cases are:

| Case | Description |
| --- | --- |
| `ratio(CGFloat)` | Associated value is a ratio between 0.0 and 1.0, where 0.0 means the very top and 1.0 the very bottom of the screen. |
| `pointsFromTop(CGFloat)` | Associated value defines how far from the top anchor point is going to be. |
| `pointsFromBottom(CGFloat)` | Associated value defines how far from the bottom anchor point is going to be. |
| `defaultExpanded` | Puts anchor point near the top of the screen. |
| `defaultCollapsed` | Puts anchor point near the bottom of the screen. |

Anchors can be set during initialization or via `setAnchors(_:animated:snapTo:)` method.

**Notes**: 
* Heights derived from `anchors` are computed relative to the view's safe area, so you don't have to worry about navigation bars, tab bars and toolbars.
* You don't have to order anchors in any particular way.
* The default anchors for each `SheetController` are `defaultExpanded` and `defaultCollapsed`.
* The exact constants for `defaultExpanded` and `defaultCollapsed` anchors are 20 points from top and 44 points from bottom respectively. The former constant replicates the expanded state of sheet-like UI in Apple's Shortcuts app. The latter constant is nice for a number of reasons: it's just enough to let the user drag on it, and when a navigation controller is presented inside thу sheet, navigation bar just barely touches the bottom in collapsed state. 
