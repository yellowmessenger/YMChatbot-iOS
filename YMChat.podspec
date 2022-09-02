Pod::Spec.new do |spec|
  spec.name = "YMChat"
  spec.version = "1.8.1"
  spec.summary = "The World’s Leading CX Automation Platform"
  spec.homepage = "https://yellow.ai"

  spec.license = { :type => "Commercial", :text => "See https://yellow.ai"}

  spec.author = "Yellow.ai"
  spec.platform = :ios, "12.0"

  spec.source = { :git => "https://github.com/yellowmessenger/YMChatbot-iOS.git", :tag => "#{spec.version}" }

  spec.resource_bundles = {
      'YMImages' => ['YMChat/Assets.xcassets', 'YMChat/index.html', 'YMChat/index-lite.html', 'YMChat/widget-min-style.css', 'YMChat/yellowLoader.gif']
  }

  spec.source_files = "YMChat/*.swift"
  spec.swift_version = '5.0'
end
