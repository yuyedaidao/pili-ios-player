Pod::Spec.new do |s|
  s.name         = "PLPlayerKit"
  s.version      = "1.0.0"
  s.summary      = "Pili-io iOS video player SDK, RTMP, HLS video streaming supported."
  s.homepage     = "https://github.com/pili-io/pili-ios-player"
  s.license      = {  :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "0dayZh" => "0day.zh@gmail.com" }
  s.social_media_url = "http://twitter.com/0dayZh"

  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/pili-io/pili-ios-player.git", :tag => "1.0.0" }
  s.requires_arc = true

  s.public_header_files = "PLPlayerKit/PLPlayerKit/PLPlayerKit.h", "PLPlayerKit/PLPlayerKit/PLVideoPlayerViewController.h"
  s.source_files  = "PLPlayerKit/PLPlayerKit/PLPlayerKit.h"

  s.resources = "PLPlayerKit/PLPlayerKit/PLPlayerKit.bundle/*.png"

  s.frameworks = "UIKit", "Foundation", "CoreGraphics", "MediaPlayer", "CoreAudio", "AudioToolbox", "Accelerate", "QuartzCore", "OpenGLES"

  s.libraries = "iconv", "z"

  s.xcconfig = { "LIBRARY_SEARCH_PATHS" => "$(SRCROOT)/libs/ffmpeg/include" }

end
