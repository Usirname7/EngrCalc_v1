# Build EngrCalc_v1 from an Android phone

## What this repository does
GitHub Actions runs the Android build on a hosted Linux runner. You do not need
Android Studio, Flutter, Java, or the Android SDK installed on your phone.

## First repository setup
1. Sign in at https://github.com.
2. Create a new repository named `EngrCalc_v1`.
3. Set it to **Private** unless you intentionally want the source public.
4. Do not add a README, license, or .gitignore (the project already has files).
5. Upload the contents of this project folder to the repository root. The
   `.github/workflows/android-release.yml` file must remain at that exact path.
6. Commit the upload to the `main` branch.

## Run the build
The workflow starts automatically after a push to `main`. It can also be started
from the repository's **Actions** tab by choosing **EngrCalc_v1 Android release**
and selecting **Run workflow**.

## Download the APK
1. Open the completed workflow run in the **Actions** tab.
2. Scroll to **Artifacts**.
3. Download `EngrCalc_v1-release-apk`.
4. Extract the downloaded artifact ZIP; it contains `app-release.apk`.
5. Open the APK on Android and approve installation from that source if Android
   asks. Only install builds from your own repository.

## Important current scope
This is an early clean-room starter, not a feature-complete replacement for the
original app. The workflow generates missing Android platform files in the
cloud, analyzes the Dart code, runs the current formula tests, and creates a
release APK if all checks pass.

Remaining work includes implementing and validating additional calculators,
making the recovered materials and steel tables searchable, reviewing the
licensing/provenance of reference data, and adding broader formula test cases.
No signing key is configured yet; the resulting APK is suitable for private
testing. A production/distribution release should use a private signing key
stored as GitHub Actions secrets and a verified app identity.
