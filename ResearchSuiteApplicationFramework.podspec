#
# Be sure to run `pod lib lint ResearchSuiteApplicationFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ResearchSuiteApplicationFramework'
  s.version          = '0.27.0'
  s.summary          = 'The ResearchSuite Application Framework is the easiest way to build mobile health research studies.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  The ResearchSuite Application Framework is the easiest way to build mobile health research studies.
  NOTE: VERY EXPERIMENTAL!!
                       DESC

  s.homepage         = 'https://github.com/jdkizer9/ResearchSuiteApplicationFramework-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.author           = { 'jdkizer9' => 'jdkizer9@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/jdkizer9/ResearchSuiteApplicationFramework-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/Classes/**/*'
    core.resources = 'Source/Core/Storyboards/**/*', 'source/Core/Assets/Media.xcassets'
    core.dependency 'ResearchKit', '~> 1.4'
    core.dependency 'ReSwift', '~> 3.0'
    core.dependency 'ResearchSuiteTaskBuilder', '~> 0.13'
    core.dependency 'ResearchSuiteResultsProcessor', '~> 0.9'
    core.dependency 'ResearchSuiteExtensions', '~> 0.25'
    core.dependency 'Gloss', '~> 2'
    core.dependency 'SimplePDF', '~> 3'
    core.dependency 'GRMustache.swift', '~> 4'
    core.dependency 'FSCalendar'
    core.dependency 'SnapKit'
    core.dependency 'LS2SDK/Common', '~> 0.11'
  end

  s.subspec 'Development' do |dev|
    dev.source_files = 'Source/Development/Classes/**/*'
    dev.dependency 'ResearchSuiteApplicationFramework/Core'
    dev.dependency 'Starscream', '~> 3.0'
    dev.dependency 'ReSwift', '~> 3.0'
    dev.dependency 'Gloss', '~> 2'
  end

  s.subspec 'Database' do |db|
    db.source_files = 'Source/Database/**/*'
    db.dependency 'ResearchSuiteApplicationFramework/Core'
    db.dependency 'RealmSwift'
    db.dependency 'LS2SDK/Common', '~> 0.11'
    db.dependency 'LS2SDK/Database', '~> 0.11'
  end

  s.subspec 'ConfigCaching' do |config|
    config.source_files = 'Source/ConfigCache/**/*'
    config.dependency 'ResearchSuiteApplicationFramework/Core'
    config.dependency 'Zip', '~> 1.1'
    config.dependency 'Alamofire', '~> 4'
  end

  s.default_subspec = 'Core'
end
