
Pod::Spec.new do |s|
  s.name          = "Chronos"
  s.version       = "0.1.3"
  s.summary       = "Grand Central Dispatch Utilities"
  s.homepage      = "https://github.com/Olympus-Library/Chronos"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Comyar Zaheri" => "" }
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.source        = { :git => "https://github.com/Olympus-Library/Chronos.git", :tag => s.version.to_s }
  s.source_files  = "Chronos/*.{h,m}", "Chronos/**/*.{h,m}"
  s.module_name   = "Chronos"
end
