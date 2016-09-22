Pod::Spec.new do |s|
  s.name                = "PayUIndia-PG-SDK"
  s.version             = "3.7.4"
  s.license             = "MIT"
  s.homepage            = "https://github.com/payu-intrepos/iOS-SDK"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "PG SDK for iOS by PayUbiz"
  s.description         = "iOS PG SDK provides easy payment flow."

  s.source              = { :git => "https://github.com/payu-intrepos/iOS-SDK.git", 
                            :tag => "v3.7.4" }
  s.documentation_url   = "https://github.com/payu-intrepos/Documentations/wiki/8.-iOS-SDK-integration"
  s.platform            = :ios , "6.0"
  s.source_files        = "PayU_iOS_CoreSDK/*.h"
  s.public_header_files = "PayU_iOS_CoreSDK/*.h"
  s.preserve_paths      = "*.a"
  s.resources           = "PayU_iOS_CoreSDK/*.plist"
  s.vendored_libraries  = "libPayU_iOS_CoreSDK.a"

  #Run time config
  #s.weak_frameworks = "Foundation", "UIKit"
  s.requires_arc     = true
end