# Users Module - DDD Implementation

This module implements the user management functionality following Domain Driven Design principles, providing a clean separation between business logic and infrastructure concerns.

## Structure

```
lib/modules/users/
├── domain/
│   ├── entities/
│   │   └── app_user.dart              # Main user entity
│   ├── value_objects/
│   │   ├── user_id.dart               # User identifier
│   │   ├── email_address.dart         # Email with validation
│   │   ├── phone_number.dart          # Phone with E.164 format
│   │   ├── person_name.dart           # First and last name
│   │   ├── cpf.dart                   # CPF with checksum validation
│   │   ├── rg.dart                    # RG with format validation
│   │   ├── oab.dart                   # OAB registration
│   │   ├── civil_status.dart          # Civil status enum
│   │   ├── gender.dart                # Gender enum
│   │   ├── address.dart               # Complete address
│   │   ├── postal_code.dart           # Brazilian CEP
│   │   ├── state_code.dart            # Brazilian states
│   │   └── user_type.dart             # User type enum
│   ├── repositories/
│   │   └── user_repository.dart       # User data access interface
│   ├── services/
│   │   └── auth_service.dart          # Authentication interface
│   ├── usecases/
│   │   ├── register_user.dart         # User registration
│   │   ├── login_user.dart            # User login
│   │   ├── logout_user.dart           # User logout
│   │   ├── reset_password.dart        # Password reset
│   │   ├── edit_user.dart             # User editing
│   │   ├── get_current_user.dart      # Get current user
│   │   └── fetch_all_users.dart       # Fetch all users
│   └── errors/
│       └── user_failures.dart         # Domain-specific errors
├── infra/
│   └── mappers/
│       └── app_user_mapper.dart       # Firestore conversion
├── presentation/
│   └── notifiers/
│       └── user_state_notifier.dart   # UI state management
└── examples/
    └── usage_example.dart             # Usage examples
```

## Key Features

### Strict Validation
- **CPF**: Full checksum validation with Brazilian algorithm
- **RG**: Format validation for Brazilian RG patterns
- **Email**: RFC5322-compliant validation
- **Phone**: E.164 format for Brazilian numbers
- **Postal Code**: Brazilian CEP format (NNNNN-NNN)

### Value Objects
All user data is encapsulated in value objects that:
- Validate input data
- Provide consistent formatting
- Ensure data integrity
- Are immutable

### Clean Architecture
- **Domain Layer**: Pure business logic, no external dependencies
- **Infrastructure Layer**: Handles external concerns (Firebase, APIs)
- **Presentation Layer**: UI state management

## Usage

### Creating a User
```dart
final user = AppUser.create(
  id: UserId.fromString('user123'),
  type: UserType.user,
  email: EmailAddress.parse('user@example.com'),
  phoneNumber: PhoneNumber.parse('11999999999'),
  name: PersonName.create('João', 'Silva'),
  profession: 'Desenvolvedor',
  // ... other required fields
);
```

### Using Value Objects
```dart
// CPF validation
final cpf = Cpf.parse('11144477735'); // Valid CPF
print(cpf.formatted); // 111.444.777-35

// Email validation
final email = EmailAddress.parse('user@example.com');

// Address creation
final address = Address.create(
  street: 'Rua das Flores',
  number: '123',
  neighborhood: 'Centro',
  city: 'São Paulo',
  state: StateCode.sp,
  country: 'Brasil',
  postalCode: PostalCode.parse('01234567'),
);
```

### State Management
```dart
// The UserStateNotifier replaces the old UserController
final notifier = UserStateNotifier(
  registerUser: registerUserUseCase,
  loginUser: loginUserUseCase,
  // ... other dependencies
);

// Listen to state changes
notifier.addListener(() {
  if (notifier.isLoggedIn) {
    print('User: ${notifier.currentUser?.name.fullName}');
  }
});
```

## Migration from Old Code

The old `UserController` and `AppUser` model have been replaced with:

1. **Domain Entity**: `AppUser` with pure domain types
2. **Value Objects**: Strict validation for all user data
3. **Use Cases**: Business logic separated from UI concerns
4. **State Notifier**: `UserStateNotifier` for UI state management
5. **Mappers**: Handle conversion to/from Firebase types

## Benefits

- **Type Safety**: Compile-time validation of user data
- **Business Rules**: Centralized validation logic
- **Testability**: Easy to unit test business logic
- **Maintainability**: Clear separation of concerns
- **Extensibility**: Easy to add new features without breaking existing code
