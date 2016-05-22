Pod::Spec.new do |s|

  s.name         = "SimpleFutures"
  s.version      = "0.1.0"
  s.summary      = "A Swift implementation of Scala Futures with a few extras."

  s.homepage     = "https://github.com/troystribling/SimpleFutures"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Troy Stribling" => "me@troystribling.com" }
  s.social_media_url   = "http://twitter.com/troystribling"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/troystribling/SimpleFutures.git", :tag => "#{s.version}" }
  s.source_files  = "SimpleFutures/**/*.swift"

end
