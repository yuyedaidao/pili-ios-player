Pod::Spec.new do |s|
  s.name         = "PLPlayerKit"
  s.version      = "1.0.0"
  s.summary      = "Pili-io iOS video player SDK, RTMP, HLS video streaming supported."
  s.homepage     = "https://github.com/pili-io/pili-ios-player"
  s.license      = "MIT"
  s.author             = { "0dayZh" => "0day.zh@gmail.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/pili-io/pili-ios-player.git", :tag => "1.0.", :submodules => false }
  s.requires_arc = true

  s.public_header_files = "Classes/**/*.h"
  s.source_files  = "Classes", "Classes/**/*.{h,m}"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  s.frameworks = "UIKit", "Foundation", "CoreGraphics", "MediaPlayer", "CoreAudio", "AudioToolbox", "Accelerate", "QuartzCore", "OpenGLES"

  s.libraries = "libiconv", "libz"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
