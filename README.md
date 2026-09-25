<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0F2027,50:203A43,100:2C5364&height=220&section=header&text=AI%20HustleOS&fontSize=60&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=The%20Business%20Brain%20Behind%20Every%20Hustle&descAlignY=58&descSize=18" width="100%"/>

<a href="https://github.com/LungstarDaKing/AI-Hustle_OS">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=24&pause=1000&color=2FF3E0&center=true&vCenter=true&width=650&lines=Intelligent+Business+OS+for+Micro-Businesses;Built+in+Flutter+%2B+Supabase;Offline-First.+AI-Powered.+South+African+Built.;Manage+Customers.+Track+Stock.+Grow+Smarter." alt="Typing SVG" />
</a>

<br/>

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white"/>
<img src="https://img.shields.io/badge/Hive-FFC300?style=for-the-badge&logo=hive&logoColor=black"/>
<img src="https://img.shields.io/badge/Made%20in-South%20Africa-007A4D?style=for-the-badge&logo=googlemaps&logoColor=white"/>

<br/>

![GitHub last commit](https://img.shields.io/github/last-commit/LungstarDaKing/AI-Hustle_OS?style=flat-square&color=2FF3E0)
![GitHub repo size](https://img.shields.io/github/repo-size/LungstarDaKing/AI-Hustle_OS?style=flat-square&color=2FF3E0)
![GitHub stars](https://img.shields.io/github/stars/LungstarDaKing/AI-Hustle_OS?style=flat-square&color=2FF3E0)
![License](https://img.shields.io/badge/license-Private-red?style=flat-square)

</div>

<br/>

<p align="center">
  <img src="https://raw.githubusercontent.com/blackcater/blackcater/main/images/Group%20imag2e.gif" width="100%">
</p>

## 🧠 About The Project

**AI HustleOS** is an intelligent, offline-first business operating system built for **South African micro-businesses** — the spaza shops, freelancers, stylists, and side-hustlers who need enterprise-grade tools without enterprise-grade complexity.

It combines real-time cloud sync, local-first offline storage, and AI-driven insights into one clean mobile experience — so a business owner can manage customers, products, and services from a taxi rank with no signal, and have everything sync the moment they're back online.

> 💡 *Built solo, from the ground up — architecture, backend, and UI — as part of a five-year plan to turn this into a real product.*

<br/>

## ✨ Features

<table>
<tr>
<td width="50%">

### 📊 Smart Dashboard
Live business metrics, AI-generated insights, and recent activity — all in one glanceable home screen.

### 👥 Customer Management
Full customer lifecycle — add, view, edit, and track relationships without a spreadsheet in sight.

### 📦 Products & Services
Manage stock and offerings side by side, with dedicated flows for physical products vs. bookable services.

</td>
<td width="50%">

### 🌐 Offline-First Sync
Powered by **Hive** local storage + an offline action queue, so the app works with zero signal and syncs automatically on reconnect.

### 🔐 Secure Auth
Supabase-backed authentication with email/social login and a guided onboarding flow.

### 🔔 Smart Notifications
Local alerts for low stock, overdue invoices, upcoming appointments, and AI insights — right when they matter.

</td>
</tr>
</table>

<br/>

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **Backend** | Supabase (Auth + Database) |
| **State Management** | Provider |
| **Navigation** | go_router |
| **Offline Storage** | Hive |
| **Dependency Injection** | get_it |
| **Charts & Insights** | fl_chart |
| **AI Layer** | Claude (Anthropic) |
| **Currency** | ZAR (South African Rand) |

</div>

<br/>

## 🏗️ Architecture

```
lib/
├── core/
│   ├── config/        → app constants & theming
│   └── di/             → auth, network, offline & preferences services
├── features/
│   ├── auth/           → login, register, splash
│   ├── customers/      → customer CRUD (data + domain + UI)
│   ├── products_services/  → products & services (data + domain + UI)
│   ├── home/            → dashboard
│   └── onboarding/     → first-run experience
└── shared/
    └── widgets/          → reusable UI (metric cards, AI insight cards, nav bar...)
```

Clean, feature-first architecture — each module owns its **data**, **domain**, and **presentation** layers, keeping the codebase scalable as features grow.

<br/>

## 🚀 Getting Started

```bash
# clone the repo
git clone https://github.com/LungstarDaKing/AI-Hustle_OS.git
cd AI-Hustle_OS

# install dependencies
flutter pub get

# run the app
flutter run
```

### Requirements
- Flutter SDK `^3.13.3`
- A Supabase project (URL + anon key) configured in `lib/core/config/app_constants.dart`

<br/>

## 🗺️ Roadmap

- [x] Core auth & onboarding flow
- [x] Customer management module
- [x] Products & services module
- [x] Offline-first sync engine
- [ ] AI-powered financial insights dashboard
- [ ] Invoicing & payments
- [ ] Multi-language support (isiZulu, Afrikaans)
- [ ] Public beta launch

<br/>

<div align="center">

## 👨🏾‍💻 Author

**Lungelo** — a.k.a. **LungstarDaKing**
Solo Developer · Entrepreneur · Music Producer

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=500&size=16&pause=1500&color=7C4DFF&center=true&vCenter=true&width=500&lines=Building+one+system+at+a+time.;From+Durban+to+the+world+%F0%9F%87%BF%F0%9F%87%A6" alt="footer typing" />

<br/><br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:2C5364,50:203A43,100:0F2027&height=100&section=footer" width="100%"/>

</div>
