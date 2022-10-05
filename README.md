> Google launched Google Analytics 4, a new way of analyzing iOS, Android, and Web data together.  Google encourages all customers to [upgrade their Firebase instances](https://support.google.com/analytics/answer/9379599) so that Firebase data flows to Google Analytics 4.  mParticle encourages all customers to also upgrade to the [new mParticle iOS Firebase GA4 kit](https://github.com/mparticle-integrations/mparticle-apple-integration-google-analytics-firebase-ga4). Please see the [mParticle GA4](https://docs.mparticle.com/integrations/google-analytics-4/event) docs for more information on upgrading.

## Google Analytics for Firebase Kit Integration

This repository contains the [Google Analytics for Firebase](https://firebase.google.com/) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Adding the integration

1. Add the kit dependency to your app's Podfile:

    ```
    pod 'mParticle-Google-Analytics-Firebase', '~> 8.0'
    ```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { Firebase Analytics }"` in your Xcode console 

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

### Documentation

[Google Analytics for Firebase integration](https://docs.mparticle.com/integrations/firebase/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
