Pod::Spec.new do |s|
    s.name             = 'Request.swift'
    s.version          = '2.2.1'
    s.summary          = 'A (sync/async) tiny http client written in swift.'
    s.homepage         = 'https://github.com/BiAtoms/Request.swift'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Orkhan Alikhanov' => 'orkhan.alikhanov@gmail.com' }
    s.source           = { :git => 'https://github.com/BiAtoms/Request.swift.git', :tag => s.version.to_s }
    s.module_name      = 'RequestSwift'

    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.9'
    s.tvos.deployment_target = '9.0'
    s.source_files = 'Sources/*.swift'
    s.dependency 'Socket.swift', '~> 2.2'
end
