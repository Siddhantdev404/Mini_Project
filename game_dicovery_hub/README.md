🎮 Game Discovery Hub (ITH-241 Mini Project)
## Mini Project (Experiment 14) Details

* **App Title:** Game Discovery Hub
* **Tech Used:** Flutter, Firebase Auth, Cloud Firestore, IGDB REST API
* **Features:** Admin Panel, VIP/Premium Gating, Google/Phone/Email/Guest Auth, Search History, Game Backlog.
* **APK Release Link:** [Link to your GitHub Release from Step 5]

### Test Credentials

* **Admin (Developer):** `sidhkkr10@gmail.com`
* **Admin (Professor):** `vpg@gmail.com` (Password: `123456`)
* **Test User (Normal):** (Create one, e.g., `testuser@gmail.com`)
A submission for the ITH-241: App Development course in fulfillment of Experiment 14.

👤 Student Details
Field	Value
Name	[Sidddhant kerkar ]
Roll No.	[24B-IT-061]
📌 1. Project Aim & Objective

Game Discovery Hub is a feature-rich mobile application built using Flutter and Firebase.
It combines modern UI/UX, multi-method authentication, real-time cloud data, and live IGDB game discovery into a polished, production-style mobile experience.

The app acts as a personal gaming companion, allowing users to:

Discover popular, trending, and genre-specific games

Search across 500K+ titles

Save games into a personal backlog synced with Firebase

Unlock premium features for expanded access

Use an exclusive Admin Panel for management

✨ 2. Key Features Implemented

This application meets and exceeds all requirements across Units 1–4.

🖥️ A. UI / UX & Design
Feature	Details
Samsung Hub-Inspired UI	A modern vertically-scrolling page with 14+ aesthetic carousels.
Professional Authentication Flow	Supports 5 login methods with clean UI transitions.
Global Dark Mode	Consistent, sleek dark theme across the app.
Search History	Saves past searches via shared_preferences and allows clearing.
🔐 B. Authentication & Security (Firebase)
✔ Authentication Methods Implemented

Email & Password Login

Google Sign-In

Phone Number (OTP) Authentication

Anonymous Guest Login

Secure Sign-Out

👑 Admin System

The app contains built-in admin accounts:

Admin Email	Password	Role
sidhkkr10@gmail.com	(Your actual password)	Permanent Admin
vpg@gmail.com	123456	Admin

Admin users can:

View all registered users

Grant or revoke Premium status

Access the Admin Panel via the amber icon

🔥 Security Highlights

Uses idTokenChanges() for reliable authentication updates

Firestore rules prevent self-escalation to admin:
– Users cannot grant themselves isAdmin
– Only admin accounts can update premium status

Anonymous users restricted from premium actions

🎮 C. REST API Integration (IGDB / Twitch)
Feature	Details
14+ Dynamic Carousels	Trending, Popular, Top Rated, Shooter, Racing, Multiplayer, Indie, etc.
Search Engine	Queries the entire IGDB database of 500,000+ games.
Token Refresh Handling	Automatically renews expired Twitch access tokens.
High Performance	Fetches optimized fields for faster loading.
☁️ D. Data Handling / Cloud Firestore
✅ Backlog Features

Save/remove games to personal backlog

Real-time sync across devices

Firestore-backed storage

🎯 Backlog Limits
User Type	Max Backlog Size
Guest	0–5 games
Normal User	10 games
Premium User	Unlimited
🛡️ Firestore Security

Custom rules block unauthorized writes

Admin-only privileges for critical updates

Users may update isPremium but not isAdmin

Safe update merging implemented

🛠️ 3. Technical Stack
Component	Technology
Framework	Flutter (Dart)
Backend	Firebase Authentication & Cloud Firestore
External API	IGDB (via Twitch Client ID/Secret)
Local Storage	shared_preferences
State Management	Provider, StreamBuilder, FutureBuilder
🚀 4. How to Run & Test the Project
Step 1 — Clone the Project
git clone https://github.com/Siddhantdev404/Project
cd game-discovery-hub
flutter pub get

Step 2 — Configure Firebase

Add your google-services.json (Android)

Ensure firebase_options.dart matches your Firebase app

The project must be linked to Firebase project:

game-hub-project-6d540

Step 3 — Add IGDB/Twitch API Keys

Paste your:

Client ID
tyzgl71sh2wu0r8cxsln03061bg720

Client Secret

xb8u5bqb02ftgod3q74eapvqmdvp4q


in:

lib/services/api_service.dart

Step 4 — Test Admin Access

Run the app:

flutter run


Login using:

Email	Password	Role
sidhkkr10@gmail.com	your actual password	Admin
vpg@gmail.com	123456	Admin

Admin Panel opens via the amber badge icon on the Explore screen.

🎯 5. Project Outcome

This app demonstrates mastery of:

Flutter UI/UX

Firebase Authentication

Cloud Firestore

REST APIs

State Management

Secure rule design

Real-world mobile app architecture