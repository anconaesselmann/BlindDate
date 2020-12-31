Pod::Spec.new do |s|
  s.name             = 'BlindDate'
  s.version          = '0.1.1'
  s.summary          = 'Date utilities'
  s.swift_version = '5.0'
  s.description      = <<-DESC
Date utilities.
                       DESC
  s.homepage         = 'https://github.com/anconaesselmann/BlindDate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anconaesselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/BlindDate.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'BlindDate/Classes/**/*'
end
