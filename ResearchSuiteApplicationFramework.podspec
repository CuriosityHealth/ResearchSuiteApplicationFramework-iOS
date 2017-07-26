#
# Be sure to run `pod lib lint ResearchSuiteApplicationFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ResearchSuiteApplicationFramework'
  s.version          = '0.1.0'
  s.summary          = 'The ResearchSuiteAppFramework is the easiest way to build mobile health research studies.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  The ResearchSuiteAppFramework is the easiest way to build mobile health research studies.
  NOTE: VERY EXPERIMENTAL!!
                       DESC

  s.homepage         = 'https://github.com/jdkizer9/ResearchSuiteApplicationFramework-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jdkizer9' => 'jdkizer9@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/jdkizer9/ResearchSuiteApplicationFramework-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/Classes/**/*'
    core.resources = 'Source/Core/Storyboards/**/*'
    core.dependency 'ResearchKit', '1.4.1'
    core.dependency 'ReSwift', '~> 3.0'
    core.dependency 'ResearchSuiteTaskBuilder', '~> 0.5'
    core.dependency 'ResearchSuiteResultsProcessor', '~> 0.3'
    core.dependency 'ResearchSuiteExtensions'
    core.dependency 'Gloss', '~> 1.2'
  end

  s.default_subspec = 'Core'
end
