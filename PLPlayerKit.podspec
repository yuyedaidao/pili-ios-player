Pod::Spec.new do |s|
  s.name         = "PLPlayerKit"
  s.version      = "1.0.1"
  s.summary      = "Pili-io iOS video player SDK, RTMP, HLS video streaming supported."
  s.homepage     = "https://github.com/pili-io/pili-ios-player"
  s.license      = {  :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "0dayZh" => "0day.zh@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/pili-io/pili-ios-player.git", :tag => "#{s.version}" }
  s.requires_arc = true

  s.public_header_files = "PLPlayerKit/PLPlayerKit/PLPlayerKit.h", "PLPlayerKit/PLPlayerKit/PLVideoPlayerViewController.h"
  s.source_files  = "PLPlayerKit/PLPlayerKit/*.{h,m}"

  s.resources = "PLPlayerKit/PLPlayerKit/PLPlayerKit.bundle/*.png"

  s.frameworks = "UIKit", "Foundation", "CoreGraphics", "MediaPlayer", "CoreAudio", "AudioToolbox", "Accelerate", "QuartzCore", "OpenGLES"
  s.libraries = "iconv", "z"

  s.default_subspec = "precompiled"

  s.subspec "precompiled" do |ss|
    ss.preserve_paths         = "PLPlayerKit/libs/ffmpeg/include/**/*.h"
    ss.vendored_libraries   = 'PLPlayerKit/libs/ffmpeg/lib/*.a'
    ss.libraries = "avcodec", "avformat", "avutil", "swresample", "swscale"
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/PLPlayerKit/libs/ffmpeg/include/**" }
  end

end
