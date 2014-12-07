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
    ss.source_files         = "PLPlayerKit/libs/ffmpeg/include/**/*.h"
    ss.public_header_files  = "PLPlayerKit/libs/ffmpeg/include/**/*.h"
    ss.header_mappings_dir  = "PLPlayerKit/libs/ffmpeg/include"
    ss.vendored_libraries   = "PLPlayerKit/libs/ffmpeg/lib/libavcodec.a", "PLPlayerKit/libs/ffmpeg/lib/libavformat.a", "PLPlayerKit/libs/ffmpeg/lib/libavutil.a", "PLPlayerKit/libs/ffmpeg/lib/libswresample.a", "PLPlayerKit/libs/ffmpeg/lib/libswscale.a"
    ss.libraries = "avcodec", "avformat", "avutil", "swresample", "swscale"
  end

end
