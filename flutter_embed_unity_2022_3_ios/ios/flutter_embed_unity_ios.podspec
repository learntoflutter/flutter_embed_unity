#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_embed_unity_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_embed_unity_ios'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  # Add UnityFramework
  s.vendored_frameworks = 'UnityFramework.framework'
  
  # Add bridging header for Swift / objective C interop
  # See https://stackoverflow.com/questions/52932436/how-to-add-bridging-header-to-flutter-plugin
#  s.public_header_files = 'Classes/**/*.h'
  s.xcconfig = { 'SWIFT_OBJC_BRIDGING_HEADER' => '../../../ios/Classes/flutter_embed_unity_ios-Bridging-Header.h' }
end
