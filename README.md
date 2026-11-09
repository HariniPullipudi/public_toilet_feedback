# 🚽 CleanSpot – Public Toilet Feedback & Monitoring System

> **"Cleaner Toilets, Healthier Communities"**  
> A production-ready, civic Flutter mobile application empowering citizens to locate public restrooms, rate hygiene conditions, report sanitation issues with photographic evidence, and leverage AI vision analysis to promote transparency and accountability under **UN Sustainable Development Goal 6: Clean Water and Sanitation**.

---

## 📌 1. Project Overview & Problem Statement

### 1.1 Problem Statement
In many urban centers and public transit hubs, public restrooms suffer from neglected maintenance, irregular cleaning schedules, water supply interruptions, depleted hand soap, and broken fixtures. When citizens encounter unsanitary conditions, there is rarely an accessible, real-time channel to notify facility managers. Consequently:
- Commuters and pedestrians struggle to find clean, functioning public amenities.
- Sanitation supervisors lack real-time visibility into hygiene issues across municipal facilities.
- Public hygiene accountability remains fragmented and reactive.

### 1.2 Project Objectives
**CleanSpot** bridges the gap between citizens and municipal authorities by delivering a comprehensive digital civic platform:
1. **Public Hygiene Discovery:** Discover verified public toilets nearby with real-time GPS distance calculation and clear amenity tags (Running Water, Soap Available, Wheelchair Accessible).
2. **Citizen Participation:** Enable citizens to submit multi-criteria hygiene ratings and geo-tagged complaints with camera/gallery photographic evidence.
3. **AI Vision Sanitation Audit:** Perform server-side computer vision analysis via Supabase Edge Functions and Google Gemini Vision to screen images for standing water, overflowing bins, dirty surfaces, and damaged fixtures.
4. **Administrative Accountability:** Provide a dedicated administrative portal enforcing Row Level Security (RLS) for supervisors to inspect complaints, review photographs, and dispatch maintenance crews with recorded public responses.
5. **UN SDG 6 Realization:** Directly support UN SDG Goal 6 Target 6.2 (access to adequate sanitation and hygiene for all) by empowering communities and ensuring maintenance accountability.

---

## ✨ 2. Key Application Features

- 📍 **Nearby Toilet Discovery:** Search toilets by location, landmark, or name with real-time distance sorting via device GPS.
- 🚰 **Sanitation Amenities Filters:** Instantly filter facilities by Running Water, Soap Available, Wheelchair Accessibility, and High Ratings (4.0+ ★).
- ⭐ **Multi-Dimensional Rating System:** Rate toilets across 5 dimensions: Overall Experience, Cleanliness & Odour, Water Availability, Fixture Maintenance, and Accessibility.
- 📸 **Photographic Issue Reporting:** Capture or upload photo evidence under 8 issue categories (*Dirty Surfaces, Bad Odour, Lack of Water, Lack of Soap, Overflowing Bins, Damaged Facilities, Poor Accessibility, Other*).
- 🤖 **AI-Powered Visual Sanitation Audit:** Automatically detects visual hygiene issues and suggests categories and rating baselines before submission with safety disclaimers.
- 📊 **Citizen Report Tracking:** "My Reports" tab allows users to monitor complaint lifecycles in real time (*Pending 🟡, In Progress 🔵, Resolved 🟢, Rejected 🔴*) along with municipal responses.
- 🛡️ **Municipal Authority Dashboard:** Live analytics counters, alerts for facilities with average ratings below 3.2 ★, photo inspection, and status management.
- 🔒 **Enterprise-Grade Security:** Row Level Security (RLS) policies, password hashing, and role separation between citizens and administrators.
- 🌐 **Offline / Demo Resilience:** Built-in verified sample facilities allow seamless exploration even prior to database configuration.

---

## 🛠️ 3. Technologies Used

| Layer | Technology | Purpose |
|---|---|---|
| **Mobile Client** | **Flutter 3.29+ & Dart 3.7+** | Cross-platform mobile framework (Android, iOS, Web) |
| **Design System** | **Material 3 & Google Fonts** | Palette: Teal Green (`#00897B`), Dark Teal (`#00695C`), Off-White (`#F5F8F7`), Plus Jakarta Sans font |
| **Backend & Database** | **Supabase (PostgreSQL)** | Relational database, automated profile triggers, and Row Level Security (RLS) |
| **Authentication** | **Supabase Auth** | Email and password authentication with role-based access control |
| **Cloud Storage** | **Supabase Storage** | `toilet-photos` bucket for citizen-submitted photographic evidence |
| **Serverless Backend** | **Supabase Edge Functions (Deno)** | Secure serverless API layer keeping AI secrets off the client |
| **Computer Vision AI** | **Google Gemini 1.5 Flash Vision** | Multimodal AI detecting litter, standing water, and dirty surfaces |
| **Geolocation** | **geolocator** | GPS coordinate acquisition and real-time distance computation |
| **Media Handling** | **image_picker** | Native camera capture and photo gallery selection |
| **Version Control** | **Git & GitHub** | Distributed version control and collaboration workflow |

---

## 🏗️ 4. Application Architecture

```
+-------------------------------------------------------------------------+
|                        FLUTTER CLIENT (Material 3)                      |
|  - Auth: Login, Register, Session Persistence                           |
|  - Citizen Home Dashboard: Search, Featured Toilets, SDG 6 Banner       |
|  - Facility Directory: Geolocator GPS Distance, Filter Chips            |
|  - Report Flow: Multi-Criteria Ratings, ImagePicker, Feedback History   |
|  - Admin Portal: Real-time Stats, Low-Rating Alerts, Status Management  |
+--------------------+--------------------------------+-------------------+
                     |                                |
                     | (REST / Realtime)              | (Base64 Image Payload)
                     v                                v
+------------------------------------+   +------------------------------------+
|          SUPABASE BACKEND          |   |       SUPABASE EDGE FUNCTION       |
|  - PostgreSQL with RLS:            |   |     ('analyze-toilet-image')       |
|    * profiles (id, full_name, role)|   |  - Deno TypeScript Runtime         |
|    * toilets (coords, amenities)   |   |  - Secret: GEMINI_API_KEY          |
|    * feedback (ratings, status)    |   |  - Server-side Vision Analysis     |
|  - Storage: 'toilet-photos' bucket |   +-----------------+------------------+
|  - Automatic Profile Trigger       |                     |
+------------------------------------+                     v
                                         +------------------------------------+
                                         |      GOOGLE GEMINI VISION API      |
                                         |  - Analyzes litter, standing water,|
                                         |    surface grime & bin overflow    |
                                         +------------------------------------+
```

---

## 📁 5. Project Folder Structure

```
cleanspot/
├── .env.example                         # Safe configuration template with placeholder keys
├── .gitignore                           # Comprehensive Flutter, Dart, and secrets exclusion
├── pubspec.yaml                         # Dependencies and package configurations
├── pubspec.lock                         # Pinned dependency versions
├── analysis_options.yaml                # Static analysis and linting rules
├── PROJECT_REPORT.md                    # Academic project report outline
├── README.md                            # Complete technical documentation
├── android/                             # Android native configuration & permissions
├── ios/                                 # iOS native configuration & camera/location descriptions
├── web/                                 # Web platform runner files
├── lib/
│   ├── main.dart                        # Entry point, Supabase initialization & light theme
│   ├── config/
│   │   ├── app_constants.dart           # Categories, statuses, SDG 6 info, display helpers
│   │   ├── app_theme.dart               # Material 3 Teal palette, typography & card shadows
│   │   └── supabase_config.dart         # Supabase client config & connection validator
│   ├── models/
│   │   ├── feedback_model.dart          # Feedback entity with multi-ratings & AI findings
│   │   ├── profile_model.dart           # Citizen & administrator profile entity
│   │   └── toilet_model.dart            # Facility coordinates, amenities & distance model
│   ├── services/
│   │   ├── ai_service.dart              # Secure Edge Function caller with graceful fallback
│   │   ├── location_service.dart        # Geolocator permission & distance calculation
│   │   └── supabase_service.dart        # Live Auth, Toilets CRUD, Feedback & Storage
│   ├── widgets/
│   │   ├── cleanliness_indicator.dart   # Color-coded condition badges (Clean, Moderate, Maintenance)
│   │   ├── custom_text_field.dart       # Material 3 inputs with validation
│   │   ├── feedback_card.dart           # Complaint cards with status pills & admin response
│   │   ├── sdg_banner.dart              # UN SDG 6 interactive modal & impact card
│   │   ├── star_rating_bar.dart         # Interactive 1-5 star selector and display bar
│   │   └── toilet_card.dart             # Facility card with amenities and walking distance
│   └── screens/
│       ├── admin/
│       │   └── admin_dashboard_screen.dart # Metrics, low-rating alerts, status updates
│       ├── auth/
│       │   ├── login_screen.dart        # Supabase Auth sign-in & guest explore option
│       │   ├── register_screen.dart     # Citizen registration (strictly prevents self-admin grant)
│       │   └── splash_screen.dart       # Logo animation, SDG 6 tagline & session router
│       ├── feedback/
│       │   ├── ai_analysis_screen.dart  # Photo capture, Edge Function vision audit
│       │   ├── my_feedback_screen.dart  # Citizen's private report tracker with status badges
│       │   └── submit_feedback_screen.dart # Form with star ratings, category chips, photo attachment
│       ├── home/
│       │   ├── home_dashboard_screen.dart # Greeting, quick search, featured toilets, SDG 6 banner
│       │   └── main_nav_scaffold.dart   # Bottom navigation bar with role-aware admin tab
│       ├── profile/
│       │   └── profile_screen.dart      # Citizen profile, SDG score, backend status, logout
│       └── toilets/
│           ├── toilet_details_screen.dart # Cleanliness scores, amenity cards, reviews list
│           └── toilet_list_screen.dart  # Search, filter chips (water, soap, 4★, wheelchair), GPS sort
├── supabase/
│   ├── schema.sql                       # Complete PostgreSQL schema, RLS, triggers & sample data
│   └── functions/analyze-toilet-image/  # Supabase Edge Function in Deno/TypeScript for Vision AI
│       └── index.ts
└── test/
    └── widget_test.dart                 # Automated widget smoke test
```

---

## ⚡ 6. Installation & Execution Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.20.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (v3.7.0 or higher)
- Visual Studio Code or Android Studio with Flutter/Dart plugins
- An Android device / iOS simulator / Chrome browser

### Step 1: Clone the Repository
```bash
git clone https://github.com/HariniPullipudi/public_toilet_feedback.git
cd public_toilet_feedback
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Run the Application
```bash
# To run on a connected Android phone or emulator:
flutter run

# To run in Google Chrome:
flutter run -d chrome

# To run on Windows Desktop:
flutter run -d windows
```

### Step 4: Verify Code Quality & Tests
```bash
# Verify static analysis (0 errors, 0 warnings):
flutter analyze

# Run automated tests:
flutter test
```

---

## 🗄️ 7. Supabase Database Configuration

CleanSpot includes a production-grade database migration script in [`supabase/schema.sql`](supabase/schema.sql).

### Step 1: Create a Free Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a free project.
2. Note your **Project URL** and **anon public key** from `Project Settings -> API`.

### Step 2: Execute Database Migrations
1. Open the Supabase Dashboard and navigate to the **SQL Editor**.
2. Paste the full contents of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
3. This creates:
   - `profiles` table with automatic `on_auth_user_created` trigger.
   - `toilets` table with demonstration public restrooms.
   - `feedback` table with constraints, ratings validation, and audit timestamps.
   - `toilet-photos` storage bucket with public read and authenticated upload policies.
   - Strict **Row Level Security (RLS)** ensuring users only modify their own reports and only administrators can alter complaint statuses.

### Step 3: Configure Flutter Client
Open [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart) and insert your credentials:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_PUBLIC_KEY';
```

*(Note: If credentials are not yet configured, CleanSpot automatically runs in Demonstration Mode with verified sample data).*

### Step 4: Promoting an Administrator
For security, user signups default strictly to `citizen`. To promote an authorized municipal officer:
```sql
UPDATE public.profiles
SET role = 'admin'
WHERE id = '<AUTH_USER_UUID>';
```

---

## 🤖 8. AI Vision API & Edge Function Configuration

To prevent exposing Gemini API keys or Supabase service-role keys in client code, CleanSpot routes image analysis through a secure Supabase Edge Function.

### Step 1: Install Supabase CLI & Login
```bash
npm install -g supabase
supabase login
supabase link --project-ref your-project-id
```

### Step 2: Set Gemini API Secret in Supabase
```bash
supabase secrets set GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 3: Deploy the Edge Function
Deploy the function located at `supabase/functions/analyze-toilet-image`:
```bash
supabase functions deploy analyze-toilet-image --no-verify-jwt
```

The function accepts base64-encoded toilet photos, prompts Gemini 1.5 Flash Vision to inspect for litter, overflowing bins, dirty surfaces, or pooled water, and returns structured suggestions for user review before submission.

---

## 📸 9. Application Screenshots

| Splash Screen | Home Dashboard | Find Toilets |
|:---:|:---:|:---:|
| ![Splash Screen](https://via.placeholder.com/300x600/00897B/FFFFFF?text=CleanSpot+Splash) | ![Home Dashboard](https://via.placeholder.com/300x600/F5F8F7/00695C?text=Home+Dashboard) | ![Find Toilets](https://via.placeholder.com/300x600/FFFFFF/00897B?text=Find+Toilets+List) |

| Facility Details | Submit Feedback & AI | Admin Dashboard |
|:---:|:---:|:---:|
| ![Facility Details](https://via.placeholder.com/300x600/F5F8F7/004D40?text=Toilet+Details) | ![Submit Feedback](https://via.placeholder.com/300x600/FFFFFF/00897B?text=AI+Vision+Report) | ![Admin Portal](https://via.placeholder.com/300x600/00695C/FFFFFF?text=Admin+Dashboard) |

*(Replace placeholder images with actual device screenshots as your project progresses).*

---

## 🌐 10. GitHub Repository Information

- **Repository:** `https://github.com/HariniPullipudi/public_toilet_feedback.git`
- **Default Branch:** `main`
- **License:** MIT License
- **Version:** `1.0.0+1`
- **Maintained By:** Harini Pullipudi

---

## 🔮 11. Limitations & Future Enhancements

- **Offline Sync & Caching:** Implement local SQLite / Hive caching for offline complaint drafting when cellular signal is weak inside underground restrooms.
- **Turn-by-Turn Navigation:** Integrate OpenStreetMap or Google Maps SDK for direct walking directions to the nearest verified stall.
- **IoT Smart Restroom Integration:** Connect odor (VOC) and waste bin weight sensors via Supabase Realtime WebSocket subscriptions.
- **Civic Gamification & Badges:** Reward citizens with civic hygiene badges and community points for verified, resolved reports.

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
