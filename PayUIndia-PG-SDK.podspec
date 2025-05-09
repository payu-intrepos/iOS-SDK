Pod::Spec.new do |s|
  s.name                = "PayUIndia-PG-SDK"
  s.version             = "11.6.0"
  s.license             = "MIT"
  s.homepage            = "https://github.com/payu-intrepos/iOS-SDK"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "PG SDK for iOS by PayUbiz"
  s.description         = "iOS PG SDK provides easy payment flow."

  s.source              = { :git => "https://github.com/payu-intrepos/iOS-SDK.git", 
                            :tag => "#{s.version}"
                          }
  s.documentation_url   = "https://app.gitbook.com/@payumobile/s/sdk-integration/ios/core/core-sdk"
  s.platform            = :ios , "13.0"
  s.vendored_frameworks = 'PayUBizCoreKit.xcframework'

  s.dependency            'PayUIndia-PayUParams', '~> 6.6'
  s.dependency            'PayUIndia-NetworkReachability', '~> 2.1'
  s.dependency            'PayUIndia-CrashReporter', '~> 4.0'

end
