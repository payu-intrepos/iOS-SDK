Pod::Spec.new do |s|
  s.name                = "PayUIndia-PG-SDK"
  s.version             = "5.0.0"
  s.license             = "MIT"
  s.homepage            = "https://github.com/payu-intrepos/iOS-SDK"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "PG SDK for iOS by PayUbiz"
  s.description         = "iOS PG SDK provides easy payment flow."

  s.source              = { :git => "https://github.com/payu-intrepos/iOS-SDK.git", 
                            :tag => "#{s.name}_#{s.version}"
                          }
  s.documentation_url   = "https://github.com/payu-intrepos/Documentations/wiki/8.-iOS-SDK-integration"
  s.platform            = :ios , "8.0"
  s.vendored_frameworks = 'PayUBizCoreKit.framework'

end