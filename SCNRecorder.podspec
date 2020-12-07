Pod::Spec.new do |s|
  s.name                  = 'SCNRecorder'
  s.version               = '2.4.0'
  s.summary               = 'A lags-free recorder of ARKit and SceneKit for iOS in Swift'
  s.homepage              = 'https://github.com/gorastudio/SCNRecorder'
  s.license               = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author                = { 'Vladislav Grigoryev' => 'dev.grigoriev@gmail.com' }
  s.platform              = :ios, '12.0'
  s.source                = { :git => 'https://github.com/gorastudio/SCNRecorder.git', :tag => s.version.to_s }
  s.module_name           = 'SCNRecorder'
  s.module_map            = 'SCNRecorder.modulemap'
  s.swift_version         = '5.2'
  s.source_files          = 'SCNRecorder.h', 'Sources/**/*.{h,m,swift}'
  s.public_header_files   = 'SCNRecorder.h', 'Sources/**/*.h'
  s.private_header_files  = 'Sources/**/*.h'

  s.app_spec 'Example' do |app_spec|
    app_spec.name                = "Example"
    app_spec.platform            = :ios, '13.0'
    app_spec.source_files        = 'Example/Source/**/*.{m,swift,metal}', 'Example/Source/Content/**/*.{h}'
    app_spec.preserve_path       = 'Example/Source/Example-Bridging-Header.h'
    app_spec.resources           = 'Example/Source/Resources/**/*.{rcproject,scnassets,xcassets}'
    app_spec.pod_target_xcconfig = {
      "SWIFT_OBJC_BRIDGING_HEADER" => "SCNRecorder/Example/Source/Example-Bridging-Header.h"
    }

    app_spec.dependency 'SnapKit', '~> 5.0.0'
  end

  s.test_spec 'Tests' do |test_spec|
    test_spec.platform            = :ios, '13.0'
    test_spec.requires_app_host   = true
    test_spec.app_host_name       = 'SCNRecorder/Example'
    test_spec.source_files        = 'SCNRecorderTests/**/*.{m,swift,metal}', 'SCNRecorderTests/Metal/**/*.h'
    test_spec.preserve_path       = 'SCNRecorderTests/SCNRecorderTests-Bridging-Header.h'
    test_spec.pod_target_xcconfig = {
      "SWIFT_OBJC_BRIDGING_HEADER" => "SCNRecorder/SCNRecorderTests/SCNRecorderTests-Bridging-Header.h"
    }


    test_spec.dependency 'SCNRecorder/Example'
  end
end


