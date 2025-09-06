# SynergySphere 🚀

Welcome to the **SynergySphere** project! This repository contains both the frontend and backend code for a modern, collaborative project management platform inspired by Trello. Below you'll find an overview of each part of the codebase.

---

## 🖥️ Frontend: `synergysphere/`

Built with **Flutter**, the frontend provides a beautiful, responsive UI for managing projects and tasks. Key features include:

- 📋 **Project & Task Boards**: Organize your work visually, Trello-style.
- 🎨 **Custom Themes**: Switch between light and dark modes.
- 🔍 **Search & Filter**: Quickly find projects and tasks.
- 🛠️ **Providers & Services**: State management and API integration for seamless user experience.
- 📱 **Multi-platform**: Runs on Android, iOS, Web, Windows, macOS, and Linux!

**Main folders:**
- `lib/` — Dart source code (screens, models, providers, services, theme)
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` — Platform-specific code

---

## 🛠️ Backend: `synergysphere_back/`

The backend is a **Python** project using AWS CDK, Lambda, and DynamoDB for a scalable, serverless architecture. It provides RESTful APIs for project and task management.

- 🗂️ **Project & Task Management**: CRUD operations for projects and tasks
- 🛡️ **Exception Handling**: Custom error classes for robust APIs
- 🗃️ **DynamoDB Models**: Fast, scalable NoSQL storage
- 🧩 **AWS CDK Constructs**: Infrastructure as code for easy deployment
- 🦾 **Lambda Handlers**: Serverless functions for business logic

**Main folders:**
- `Service/handlers/lambdas/project/` — Lambda functions for project/task APIs
- `db/` — Data models and repositories
- `cdk/` — AWS CDK infrastructure code

---

## 📦 How to Run

1. **Frontend**: Open `synergysphere/` in VS Code and run with Flutter (`flutter run`).
2. **Backend**: Open `synergysphere_back/` and deploy with AWS CDK (`cdk deploy`).

---

Made with ❤️ by the Jiya, Fena,  Bhakti and Zimmy.
