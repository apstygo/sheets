# sheets-example

An example app that demonstrates capabilities of [sheets](https://github.com/apstygo/sheets).

# Structure

When customizing the behavior of container controllers, it is best to use composition instead of subclassing the container itself. That is the reason why this example app implements coordinators. You can learn more about coordinators [here](https://www.raywenderlich.com/158-coordinator-tutorial-for-ios-getting-started).

# How to use

This example app is best experienced on a device or in simulator. [Example one](sheets-example/Examples/ExampleOneCoordinator.swift) demonstrates library's basic functionality, as well as manual push/pop behavior. [Example two](sheets-example/Examples/ExampleTwoCoordinator.swift) is dedicated to showing off `setViewControllers(_:animated:)` behavior.
