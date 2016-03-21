#
# Be sure to run `pod lib lint Molib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Molib"
  s.version          = "0.1.0"
  s.summary          = "A common set of components for building iOS apps"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Unlike most libraries which focus on a specific task, like networking or image processing, Molib addresses developer productivity in general. As an iOS developer, you namely face the same issues on each project you work on. Molib gives a nice set of reusable components and design patterns for doing everyday iOS tasks
                       DESC

  s.homepage         = "http://git.jigabox.com/imobilize/Molib-ios"
  s.license          = 'MIT'
  s.author           = { "Andre Barrett" => "andre@imobilize.co.uk" }
  s.source           = { :git => "http://jigabox.com/imobilize/Molib-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Molib' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit'
	s.dependency 'SDWebImage'
	s.dependency 'Alamofire'
	s.dependency 'SVProgressHUD'

end
