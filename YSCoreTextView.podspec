Pod::Spec.new do |s|
  s.name = 'YSCoreTextView'
  s.version = '0.0.40'
  s.summary = 'Simple drawing of the CoreText.'
  s.homepage = 'https://github.com/yusuga/YSCoreTextView'
  s.license = 'MIT'
  s.author = 'Yu Sugawara'
  s.source = { :git => 'https://github.com/yusuga/YSCoreTextView.git', :tag => s.version.to_s }
  s.platform = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.source_files = 'Classes/YSCoreTextView/*.{h,m}'
  s.requires_arc = true
  s.compiler_flags = '-fmodules'  
end