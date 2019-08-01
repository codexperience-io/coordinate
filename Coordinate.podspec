Pod::Spec.new do |spec|
  spec.name         = "Coordinate"
  spec.version      = "1.0.0"
  spec.summary      = "A small iOS library to help you use the Coordinator Pattern with your App"
  spec.description  = <<-DESC
  This library helps you use the Coordinator Pattern in iOS. The Coordinator Pattern helps you manage the Navigation of your App and keep your code scalable, reusable and mantainable.
                   DESC
  spec.homepage     = "https://coordinate.codexperience.io/"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "Anderson" => "anderson@codexperience.io" }
  spec.social_media_url   = "https://twitter.com/imanderson_com"
  spec.ios.deployment_target     = "9"
  spec.tvos.deployment_target    = "10.0"
  spec.source       = { :git => "https://github.com/codexperience-io/coordinate.git", :tag => "#{spec.version}" }
  spec.source_files = "Coordinate/*.swift"
  spec.swift_version  = "5.0"
end
