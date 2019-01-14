Pod::Spec.new do |s|
  s.name             = 'Ferrari'
  s.version          = '1.0.0'
  s.summary          = 'A short description of Ferrari.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/CaydenK/Ferrari'
  #s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CaydenK' => 'caydenk@163.com' }
  s.source           = { :git => 'https://github.com/CaydenK/Ferrari.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC -lc++"}
  s.dependency 'YYModel'
  s.dependency 'YYCache'
  s.frameworks = 'UIKit', 'JavaScriptCore'
  s.default_subspec = 'Core'

  
  s.subspec 'Core' do |core|
    core.source_files = 'Ferrari/Classes/**/*'
    core.public_header_files = 'Ferrari/Classes/**/*.h'
    core.requires_arc   = true
    core.resource_bundles = {
      'Ferrari' => ['Ferrari/Assets/*.{lproj}','Ferrari/Assets/Media.xcassets','Ferrari/Assets/*.js']
    }
    core.preserve_path = 'Ferrari/translater.rb'
    core.script_phase = { :name => 'FerrariBridge',:execution_position => :after_compile, :script =>
<<-SCRIPT
if [ -n "${FERRARI_WORK_PATH}" ]; then
    app_name_dir=$(ls ${PODS_CONFIGURATION_BUILD_DIR} | grep .app$)
    echo $app_name_dir
    cd ${PODS_TARGET_SRCROOT}/Ferrari/
    touch ferrariExport.js
    ruby translater.rb ${FERRARI_WORK_PATH}
    mv ./ferrariExport.js ${PODS_CONFIGURATION_BUILD_DIR}/${app_name_dir}
fi
SCRIPT
    }

  end

  s.subspec 'WebP' do |webp|
    webp.xcconfig = {
        'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SD_WEBP=1',
    }
    webp.dependency 'SDWebImage/WebP'
    webp.dependency 'Ferrari/Core'
  end
end
