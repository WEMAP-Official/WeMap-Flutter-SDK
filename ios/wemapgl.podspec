#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'wemapgl'
  s.version          = '0.0.1'
  s.summary          = 'Add Turn By Turn Navigation to Your Flutter Application Using WeMap'
  s.description      = <<-DESC
Add Turn By Turn Navigation to Your Flutter Application Using WeMap
                       DESC
  s.homepage         = 'http://wemap.asia'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WeMap JSC' => 'dev@wemap.asia' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MapboxAnnotationExtension', '~> 0.0.1-beta.1'
  #s.dependency 'MapboxNavigation', '~> 0.38.3'
  s.dependency 'Mapbox-iOS-SDK', '~> 5.6.0'

  s.ios.deployment_target = '9.0'
end

