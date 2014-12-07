Pod::Spec.new do |s|
  s.name         = "PLPlayerKit"
  s.version      = "1.0.0"
  s.summary      = "Pili-io iOS video player SDK, RTMP, HLS video streaming supported."
  s.homepage     = "https://github.com/pili-io/pili-ios-player"
  s.license      = {  :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "0dayZh" => "0day.zh@gmail.com" }

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/pili-io/pili-ios-player.git", :tag => "#{s.version}" }
  s.requires_arc = true

  s.public_header_files = "PLPlayerKit/PLPlayerKit/PLPlayerKit.h", "PLPlayerKit/PLPlayerKit/PLVideoPlayerViewController.h", "PLPlayerKit/libs/ffmpeg/include/**/*.h"

  s.header_dir = "PLPlayerKit/libs/ffmpeg/include"

  s.source_files  = "PLPlayerKit/PLPlayerKit/PLAudioManager.{h,m}", "PLPlayerKit/PLPlayerKit/PLLogger.h", "PLPlayerKit/PLPlayerKit/PLMovieDecoder.{h,m}", "PLPlayerKit/PLPlayerKit/PLMovieGLView.{h,m}", "PLPlayerKit/PLPlayerKit/PLVideoPlayerViewController.{h,m}", "PLPlayerKit/libs/ffmpeg/include/**/*.h"

  s.resources = "PLPlayerKit/PLPlayerKit/PLPlayerKit.bundle/*.png"

  s.frameworks = "UIKit", "Foundation", "CoreGraphics", "MediaPlayer", "CoreAudio", "AudioToolbox", "Accelerate", "QuartzCore", "OpenGLES"

  s.libraries = "iconv", "z", "avcodec", "avformat", "avutil", "swresample", "swscale"

  s.preserve_paths = "PLPlayerKit/libs/ffmpeg/lib/libavcodec.a"

  s.xcconfig = { "LIBRARY_SEARCH_PATHS" => "${PODS_ROOT}/#{s.name}/libs/ffmpeg/include/**" }

end
