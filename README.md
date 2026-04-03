# Climate Cover

**AI-Powered Parametric Insurance for India's Delivery Workers**

> Guidewire DEVTrails 2026 · Flutter + Django + Postgresql

---

## Problem Statement

India's platform-based delivery partners — working for Zomato, Swiggy, Zepto, Amazon, and Blinkit — lose 20–30% of their monthly income when external disruptions like heavy rain, floods, or severe pollution make deliveries impossible. They have no safety net. Climate Cover fixes that.

---

## How It Works

Climate Cover monitors weather and environmental conditions continuously. When a disruption threshold is crossed (rainfall > 50 mm/hr, AQI > 300, etc.), it:

1. Detects the disruption automatically via public APIs
2. Finds all active policy holders in the affected zone
3. Calculates each worker's lost income from their **2-hour slot earning averages**
4. Runs a fraud check (GPS validation + ML anomaly detection)
5. Credits the payout to the worker's UPI — zero paperwork, zero waiting

---

## Fraud Prevention & Data Reliability

To prevent fraudulent activities such as a single individual creating and operating multiple accounts, Climate Cover integrates Aadhaar-based verification to ensure each user’s identity is unique and authentic. Additionally, to maintain high data reliability and eliminate the risk of user-manipulated inputs, all critical operational data is sourced directly from trusted third-party APIs (such as Zomato and similar platforms) rather than relying on manual entry. This approach ensures accuracy, transparency, and integrity in both user verification and data collection processes.

---

## The Slot-Based Payout Model

The System Calculates earnings at the end of each 2-hour block. Over 2 weeks(so the users cannot get benefited for the first 2 weeks), the system builds a personal earning average per slot. When a disruption covers a time window, the payout = sum of slot averages for the disrupted hours. If the disruption happens for less than two hours then the amount to be credited is calulated via, the payout = (amount for that particular 2 hours) * (disruption time(in min)/120). If the disruption time is less than a threshold value then no payout is credited but it gets stacked for a day. If the amount stacked is more than a threshold value then again payout is triggered.

| Slot | Avg Earning |
|---|---|
| 12:00–14:00 | ₹ 320 |
| 14:00–16:00 | ₹ 158 |
| 16:00–18:00 | ₹ 192 |
| 18:00–20:00 | ₹ 278 |

**Example:** Heavy rain 14:00–20:00 → disrupts 3 slots → ₹158 + ₹192 + ₹278 = **₹628 credited automatically**

---

### Coverage Tiers
 
| Tier | Coverage | Premium Rate | Example (₹4,000/week earner) |
|---|---|---|---|
| Basic | 50% of slot earnings | 0.5% of avg weekly earnings | ₹ 20/week |
| Standard | 70% of slot earnings | 1.0% of avg weekly earnings | ₹ 40/week |
| Premium | 100% of slot earnings | 1.5% of avg weekly earnings | ₹ 60/week |
 
The premium rate is calculated via the previous weeks earnings. The rupee amount varies per worker.

---


## Parametric Triggers and Risk Level

| Trigger | Source | Threshold |
|---|---|---|
| Heavy Rain | OpenWeatherMap | > 50 mm/hr |
| Flood Alert | IMD / State API | Official warning |
| Extreme Heat | OpenWeatherMap | > 45°C |
| Severe Pollution | CPCB AQI API | AQI > 300 |
| Curfew / Strike | Admin panel | Verified flag |

A risk level is introduced and it gets increased by the above factors. Evaluation runs if the risk level increases beyond a certain limit.

---


## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) + Riverpod + go_router |
| Backend API | Django 4.2 + Django REST Framework |
| Database | PostgreSQL 15 |
| Task Queue | Celery 5 + Redis 7 |
| AI/ML | XGBoost (pricing) + Isolation Forest (fraud) |
| Payments | Razorpay (or mock API for time being) |
| Weather | OpenWeatherMap + CPCB AQI |

---

## Flutter Project Structure

```
lib/
├── main.dart                        # App entry point
├── core/
│   ├── theme.dart                   # AppColors, AppTheme, AppText
│   ├── router.dart                  # go_router route definitions
│   └── mock_data.dart               # Mock data — replace with API calls
├── models/                          # Worker, Policy, EarningSlot, Claim, Disruption
├── providers/
│   └── app_providers.dart           # All Riverpod StateNotifier providers
├── screens/
│   ├── auth/                        # Splash, Login, Register
│   ├── home/                        # Home dashboard + bottom nav shell
│   ├── slots/                       # 2-hour earning slot entry
│   ├── claims/                      # Claim history + slot-by-slot detail
│   └── policy/                      # Plan selection + policy detail
└── widgets/                         # GsButton, GsTextField, GsShimmer
```

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device or emulator
flutter run
```

The app runs fully on mock data — no backend required for the frontend demo. All API integration points are marked with `// TODO: real API` in `lib/providers/app_providers.dart`.

---

## AI Models

**Model 1 — XGBoost Regressor (Dynamic Pricing)**
Inputs: `Each 2 hour slots earning(12 slots)`, `disruption timings`
Output: predicted payout in ₹

**Model 2 — Isolation Forest (Fraud Detection)**
Trained on normal claim patterns. Scores 0.0 (clean) → 1.0 (anomalous). Threshold: 0.5 = flag, 0.8+ = block.

**Activity Consistency Score (ACS)**
```
score = (active_days/14 × 50) + (day_pattern_match × 30) + (has_earnings × 20)
```
Used as eligibility proof to check if the user is  active consistently. It Affects the risk score.

---


## Fraud Detection System
 
Climate Cover uses a multi-layer fraud detection pipeline combining deterministic rules with ML anomaly detection. Every claim passes through all layers before payout is initiated.
 
### Layer 1 — GPS Zone Validation
 
The worker's last GPS ping (captured by the Flutter app every 30 minutes while active) must fall within the disruption event's geographic radius.
 
- If GPS shows the worker is far away from the disruption center → claim rejected
- If no GPS ping exists within the last 2 hours → claim flagged for manual review
 
### Layer 2 — GPS Spoofing Detection (Velocity Check)
 
A worker cannot physically travel faster than a motorcycle (~80 km/h in city traffic). If consecutive GPS pings show movement that would require faster travel, the location data is fabricated.
 
```
speed = distance_between_pings_km / time_between_pings_hours
 
if speed > 80 km/h → GPS_SPOOF flag raised
if speed > 120 km/h → claim auto-blocked (impossible without aircraft)
```



## Coverage Scope

Climate Cover covers **income loss only**. Strictly excluded per DEVTrails rules:
- Vehicle repairs or maintenance
- Health insurance or medical expenses
- Accident liability or injury compensation

---


*Built for Guidewire DEVTrails 2026 · Academic and innovation purposes only*