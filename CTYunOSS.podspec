

Pod::Spec.new do |s|

  s.name         = "CTYunOSS"
  s.version      = "1.2"
  s.summary      = "CTYunOSS"
  s.description  = <<-DESC
                    CTYunOSS
                   DESC

  s.homepage     = "https://github.com/boyssimple/CTYunOSS.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "罗伟" => "luowei@cqyanyu.com" }
  s.platform     = :ios
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/boyssimple/CTYunOSS.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{h,m}"

end
