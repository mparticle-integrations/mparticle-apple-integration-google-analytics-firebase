VERSION="$1"
PREFIXED_VERSION="v$1"
NOTES="$2"

# Update version number
#

# Update Carthage release json file
jq --indent 3 '. += {'"\"$VERSION\""': "'"https://github.com/mparticle-integrations/mparticle-apple-integration-google-analytics-firebase/releases/download/$PREFIXED_VERSION/mParticle_Google_Analytics_Firebase.framework.zip?alt=https://github.com/mparticle-integrations/mparticle-apple-integration-google-analytics-firebase/releases/download/$PREFIXED_VERSION/mParticle_Google_Analytics_Firebase.xcframework.zip"'"}'
mParticle_Google_Analytics_Firebase.json > tmp.json
mv tmp.json mParticle_Google_Analytics_Firebase.json

# Update CocoaPods podspec file
sed -i '' 's/\(^    s.version[^=]*= \).*/\1"'"$VERSION"'"/' mParticle-Google-Analytics-Firebase.podspec

# Make the release commit in git
#

git add mParticle-Google-Analytics-Firebase.podspec
git add mParticle_Google_Analytics_Firebase.json
git add CHANGELOG.md
git commit -m "chore(release): $VERSION [skip ci]

$NOTES"
