Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.name         = "sheets"
  spec.version      = "0.7.0"
  spec.summary      = "A standard-looking sheet controller with fluid animation."
  spec.description  = "sheets provides an API similar to that of UINavigationController, with push and pop functionality. It has customizable anchor points and positioning behavior."

  spec.homepage     = "https://github.com/apstygo/sheets.git"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "Artyom Pstygo" => "apstygo.dev@icloud.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.platform     = :ios, "11.0"
  spec.swift_version = "5.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.source       = { :git => "https://github.com/apstygo/sheets.git", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.source_files  = "Sources/sheets/**/*"
  spec.exclude_files = "Sources/sheets/Info.plist"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

end
