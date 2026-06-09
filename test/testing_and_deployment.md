# Testing and Deployment Flow

## 1. Testing Strategy
### 1.1 Automated Testing
- **Unit Tests:** Logic for billing cycle calculations and installment date generation.
- **Widget Tests:** Verification of UI components (e.g., `AuthWrapper` navigation).
- **Analyzer:** Strict linting via `flutter_lints` and `analysis_options.yaml`.

### 1.2 Manual Testing Checklist
- **Localization:** Verify layout flipping (RTL) when switching to Hebrew.
- **Concurrency:** Test real-time updates by having two devices open the same grocery list.
- **Security:** Use Firebase Rules Playground to attempt unauthorized access to workspaces.

## 2. CI/CD Pipeline
The project uses **GitHub Actions** for automated builds and deployment.

### 2.1 Pull Request Workflow
- Triggered on any PR to `main`.
- Runs `flutter pub get` and `flutter analyze`.
- Builds a Web Release and deploys a **Firebase Hosting Preview** for stakeholders.

### 2.2 Production Deployment
- Triggered on merge to `main`.
- Increments version numbers in `pubspec.yaml`.
- Deploys the production build to Firebase Hosting.

## 3. Mobile Distribution
- **Android:** Build App Bundle (`.aab`) for Google Play Internal Testing.
- **iOS:** Archive via Xcode for TestFlight distribution.

## 4. Environment Management
- Current environment: **Production** (Firebase).
- Future: Implement a `Staging` Firebase project for pre-production testing of security rules.