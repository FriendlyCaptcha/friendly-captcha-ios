#
# Be sure to run `pod lib lint FriendlyCaptcha.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FriendlyCaptcha'
  s.version          = '1.0.0'
  s.summary          = 'An iOS SDK for FriendlyCaptcha, a privacy-first bot protection service.'

  s.description      = <<-DESC
Friendly Captcha is a service that protects websites from bots and abuse
in a privacy-friendly and accessible way. This SDK is the official
iOS integration for Friendly Captcha.
                       DESC

  s.homepage         = 'https://github.com/FriendlyCaptcha/friendly-captcha-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MPL 2.0', :file => 'FriendlyCaptcha/LICENSE' }
  s.author           = { 'friendlycaptcha' => 'dev@friendlycaptcha.com' }
  s.source           = { :git => 'https://github.com/FriendlyCaptcha/friendly-captcha-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.0'

  s.source_files = 'FriendlyCaptcha/Classes/**/*'

  s.frameworks = 'UIKit', 'WebKit'
end
