# SynergySphere

A beautiful and modern collaborative project management and team communication platform built with Flutter. SynergySphere enables teams to create projects, manage tasks, and communicate effectively in one unified platform.

## Features

### 🔐 Authentication
- **Login/Signup**: Secure user authentication with email and password
- **Forgot Password**: Password reset functionality
- **User Profile**: Personal profile management

### 📋 Project Management
- **Create Projects**: Set up new projects with descriptions, colors, and due dates
- **Project Dashboard**: Beautiful overview of all your projects
- **Project Settings**: Comprehensive project configuration options
- **Team Management**: Invite and manage team members

### ✅ Task Management
- **Task Board**: Kanban-style board with To-Do, In Progress, and Done columns
- **Create Tasks**: Add new tasks with titles, descriptions, priorities, and due dates
- **Task Details**: Detailed task view with status updates and progress tracking
- **Priority Levels**: Low, Medium, High, and Urgent priority levels
- **Status Tracking**: Real-time task status updates

### 🎨 Beautiful UI/UX
- **Modern Design**: Clean, intuitive interface with Material Design 3
- **Responsive Layout**: Optimized for both mobile and desktop
- **Smooth Animations**: Delightful micro-interactions and transitions
- **Color Themes**: Customizable project colors and themes
- **Dark Mode Ready**: Theme system prepared for dark mode implementation

### 📱 Cross-Platform
- **Mobile**: Native iOS and Android apps
- **Desktop**: Windows, macOS, and Linux support
- **Web**: Progressive Web App capabilities

## Technology Stack

- **Framework**: Flutter 3.6.0+
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Typography**: Google Fonts (Inter)
- **Animations**: Flutter Staggered Animations
- **Responsive Design**: Flutter ScreenUtil
- **Local Storage**: SharedPreferences
- **HTTP**: Dart HTTP package

## Project Structure

```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models (User, Project, Task, Comment)
├── providers/         # State management providers
├── services/          # Business logic and API services
├── screens/           # UI screens and pages
│   ├── auth/         # Authentication screens
│   ├── home/         # Main app screens
│   └── project/      # Project and task management screens
├── theme/            # App theming and styling
└── main.dart         # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd synergysphere
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS App:**
```bash
flutter build ios --release
```

**Web App:**
```bash
flutter build web --release
```

## Features Overview

### Authentication Flow
1. **Login Screen**: Email and password authentication
2. **Signup Screen**: User registration with validation
3. **Forgot Password**: Password reset via email
4. **Profile Management**: User profile and settings

### Project Management
1. **Project List**: Overview of all user projects
2. **Create Project**: New project setup with customization
3. **Project Detail**: Detailed project view with task board
4. **Project Settings**: Team management and configuration

### Task Management
1. **Task Board**: Kanban-style task organization
2. **Create Task**: Add new tasks with full details
3. **Task Detail**: Comprehensive task information
4. **Status Updates**: Real-time task status changes

## Design Principles

- **User-Centric**: Intuitive and accessible interface
- **Performance**: Smooth animations and responsive interactions
- **Scalability**: Modular architecture for easy feature additions
- **Maintainability**: Clean code structure and documentation
- **Accessibility**: WCAG compliant design patterns

## Future Enhancements

- [ ] Real-time collaboration features
- [ ] Advanced notification system
- [ ] File sharing and attachments
- [ ] Time tracking and reporting
- [ ] Integration with external tools
- [ ] Advanced analytics and insights
- [ ] Mobile push notifications
- [ ] Offline support
- [ ] Team chat and messaging
- [ ] Calendar integration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**SynergySphere** - Where teams come together to achieve greatness! 🚀