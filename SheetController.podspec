Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.name         = "SheetController"
  spec.version      = "0.3.1"
  spec.summary      = "A standard-looking sheet controller with fluid animation."
  spec.description  = "SheetController provides an API similar to that of UINavigationController, with push and pop functionality. It has customizable anchor points and positioning behavior."

  spec.homepage     = "https://github.com/apstygo/SheetController.git"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "Artyom Pstygo" => "apstygo.dev@icloud.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.platform     = :ios, "13.0"
  spec.swift_version = "5.1"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.source       = { :git => "https://github.com/apstygo/SheetController.git", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.source_files  = "SheetController/**/*"
  spec.exclude_files = "SheetController/Info.plist"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.dependency 'SteviaLayout', '~> 4'

end
