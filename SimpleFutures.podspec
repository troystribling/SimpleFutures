Pod::Spec.new do |spec|

  spec.name               = "SimpleFutures"
  spec.version            = "0.2.0"
  spec.summary            = "A Swift implementation of Scala Futures with a few extras."

  spec.homepage           = "https://github.com/troystribling/SimpleFutures"
  spec.documentation_url  = "https://github.com/troystribling/SimpleFutures"
  spec.license            = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Troy Stribling" => "me@troystribling.com" }
  spec.social_media_url   = "http://twitter.com/troystribling"

  spec.cocoapods_version  = '>= 1.1'

  spec.platform           = :ios, "9.0"

  spec.source             = { :git => "https://github.com/troystribling/SimpleFutures.git", :tag => "#{spec.version}" }
  spec.source_files       = "SimpleFutures/**/*.swift"

end
