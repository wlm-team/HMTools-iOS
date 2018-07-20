Pod::Spec.new do |s|
s.name         = "HMTools"
s.version      = "1.0.3"
s.summary      = "HMTool Source ."
s.homepage     = 'https://github.com/shawn-tangsc/weex-plugin-ios-gesture.git'
s.license      = "MIT"
s.authors      = { "tangsicheng" => "tangscsh@icloud.com" }
s.platform     = :ios
s.ios.deployment_target = "8.0"
s.requires_arc = true
s.source = { :git => 'https://github.com/shawn-tangsc/HMTools.git', :tag => s.version.to_s }
s.source_files = "Source/*.{h,m,mm}","Source/*/*.{h,m,mm}"
s.prefix_header_file = 'Source/CommonMacro.pch'   #公开头文件地址
end
