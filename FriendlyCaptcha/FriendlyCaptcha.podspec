Pod::Spec.new do |s|
  s.name             = 'FriendlyCaptcha'
  s.version          = '0.0.0'
  s.summary          = 'Friendly Captcha for iOS'
  s.swift_version    = '6.0'
  s.authors          = 'aaron@friendlycaptcha.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.homepage          = 'https://github.com/FriendlyCaptcha/friendly-captcha-ios'
  s.source            = { :git => 'https://github.com/FriendlyCaptcha/friendly-captcha-ios.git', :tag => s.version.to_s }

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'FriendlyCaptcha/*'
    core.frameworks = 'WebKit'
  end
end