Pod::Spec.new do |s|
  s.name         = "ZWSCountdown"
  s.version      = "0.1"
  s.summary      = "Countdown,验证码倒计时，退出app也可生效."

  s.homepage     = "https://github.com/zhaowensky/ZWSCountdownUtils.git"
  s.license      = { :type => "MIT", :file => "ZWSCountdown/LICENSE" }
  s.author       = { "zhaowensky" => "zhaowensky@gmail.com" }
 
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/zhaowensky/ZWSCountdownUtils.git", :tag => s.version.to_s }

  s.source_files  = "ZWSCountdown/Classes/*.{h,m}"

  s.requires_arc = true

end
