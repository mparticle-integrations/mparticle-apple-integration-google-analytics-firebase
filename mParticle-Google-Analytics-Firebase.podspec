Pod::Spec.new do |s|
    s.name             = "mParticle-Google-Analytics-Firebase"
    s.version          = "8.3.0"
    s.summary          = "Google Analytics for Firebase integration for mParticle"

    s.description      = <<-DESC
                       This is the Google Analytics for Firebase integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-google-analytics-firebase.git", :tag => "v" + s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"
    s.static_framework = true

    s.ios.deployment_target = "10.0"
    s.ios.source_files      = 'mParticle-Google-Analytics-Firebase/*.{h,m,mm}'
    s.ios.resource_bundles  = { 'mParticle-Google-Analytics-Firebase-Privacy' => ['mParticle-Google-Analytics-Firebase/PrivacyInfo.xcprivacy'] }
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.19'
    s.ios.frameworks = 'CoreTelephony', 'SystemConfiguration'
    s.libraries = 'z'
    s.ios.dependency 'Firebase/Core', '~> 10.23'

end
