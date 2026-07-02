
### skills/flutter-frontend.md

```markdown
# Skill: Flutter Frontend

## What you can do
- Create screens and widgets
- Implement BLoC pattern
- Work with API via repository
- Write unit tests and widget tests
- Integrate Apple Health / Google Fit

## Project Structure
frontend/
├── lib/
│ ├── main.dart
│ ├── app/
│ │ ├── app.dart
│ │ └── router.dart
│ ├── core/
│ │ ├── api/ # API client
│ │ ├── config/ # Configuration
│ │ ├── theme/ # Theme
│ │ └── utils/ # Utilities
│ ├── features/
│ │ ├── onboarding/ # Onboarding flow
│ │ ├── labs/ # Lab upload
│ │ ├── axes/ # Axes dashboard
│ │ ├── profile/ # Profile result
│ │ ├── cart/ # Grocery cart
│ │ ├── purchases/ # Actual purchases (Step 4)
│ │ └── drift/ # Drift dashboard
│ └── shared/
│ ├── models/ # Data models
│ ├── widgets/ # Shared widgets
│ └── blocs/ # Shared BLoCs
├── test/
│ ├── unit/
│ ├── widget/
│ └── integration/
└── assets/


## Patterns
- **BLoC**: events → state → UI
- **Repository**: API calls → return models
- **Model**: immutable (freezed)
- **Widget**: stateless where possible

## BLoC Example
```dart
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  
  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }
  
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile(event.userId);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}

Screen Example
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return CircularProgressIndicator();
        }
        if (state is ProfileLoaded) {
          return ProfileView(profile: state.profile);
        }
        if (state is ProfileError) {
          return ErrorView(message: state.message);
        }
        return SizedBox();
      },
    );
  }
}

Apple Health / Google Fit Integration
Use health package (Flutter)
Request read permissions: HRV, blood glucose, sleep, steps
Handle refusals gracefully
What NOT to do
❌ Do not write business logic in UI
❌ Do not hardcode strings (use localization)
❌ Do not use setState for complex logic (only BLoC)
❌ Do not forget about accessibility (semantics, contrast)