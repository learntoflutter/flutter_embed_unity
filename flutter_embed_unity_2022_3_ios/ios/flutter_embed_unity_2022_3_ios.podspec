#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_embed_unity_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_embed_unity_2022_3_ios'
  s.version          = '0.0.1'
  s.summary          = 'iOS platform implementation of flutter_embed_unity plugin'
  s.description      = <<-DESC
Embed Unity into an iOS Flutter app
                       DESC
  s.homepage         = 'https://github.com/learntoflutter/flutter_embed_unity'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Learn To Flutter' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  # Add UnityFramework
  s.vendored_frameworks = 'UnityFramework.framework'
end
