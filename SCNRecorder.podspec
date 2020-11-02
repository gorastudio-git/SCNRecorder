Pod::Spec.new do |s|
  s.name                  = 'SCNRecorder'
  s.version               = '2.1.3'
  s.summary               = 'A lags-free recorder of ARKit and SceneKit for iOS in Swift'
  s.homepage              = 'https://github.com/gorastudio/SCNRecorder'
  s.license               = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author                = { 'Vladislav Grigoryev' => 'dev.grigoriev@gmail.com' }
  s.source                = { :git => 'https://github.com/gorastudio/SCNRecorder.git', :tag => s.version.to_s }
  s.module_name           = 'SCNRecorder'
  s.module_map            = 'SCNRecorder.modulemap'
  s.swift_version         = '5.2'
  s.ios.deployment_target = '12.0'
  s.source_files          = 'SCNRecorder.h', 'Sources/**/*.{h,m,swift}'
  s.public_header_files   = 'SCNRecorder.h', 'Sources/**/*.h'
  s.private_header_files  = 'Sources/**/*.h'
  s.pod_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "GLES_SILENCE_DEPRECATION CI_SILENCE_GL_DEPRECATION" }
end


