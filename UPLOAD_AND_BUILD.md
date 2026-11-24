# Upload and build EngrCalc_v1

The repository is private. The starter source is supplied as the archive `EngrCalc_v1_cloud_build.zip`.

## Upload from Android

1. Download the archive from the ChatGPT conversation to your phone.
2. Open this repository on GitHub: https://github.com/Usirname7/EngrCalc_v1
3. Choose **Add file** → **Upload files**.
4. Select `EngrCalc_v1_cloud_build.zip` from Downloads and upload it to the repository root (do not rename it).
5. Commit the upload to the `main` branch.

The GitHub Actions workflow at `.github/workflows/android-release.yml` extracts the archive in its cloud runner, sets up Java and Flutter, generates Android platform files, runs `flutter analyze` and `flutter test`, builds a release APK, and stores the APK as a workflow artifact.

## Download the APK

After the upload commit:
1. Open the repository's **Actions** tab.
2. Open the **Android release build** run.
3. Wait for the build to finish.
4. Download the `EngrCalc_v1-release-apk` artifact and extract `app-release.apk`.

A successful build is not the same as a production-ready release. This starter is an early clean-room implementation; remaining calculator modules, searchable data integration, broader formula validation, licensing review, and release signing still need work. The workflow currently creates an unsigned-by-owner testing build; configure a private signing key in GitHub Actions secrets before public distribution.
