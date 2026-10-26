# GasKurir

A native iOS app for LPG gas couriers to record deliveries, track unreturned cylinders, and follow up on unpaid balances.

![Platform](https://img.shields.io/badge/platform-iOS%2026%2B-blue)
![Language](https://img.shields.io/badge/language-Swift-orange)
![UI](https://img.shields.io/badge/UI-SwiftUI-informational)
![Status](https://img.shields.io/badge/status-in%20development-yellow)

## Table of Contents

- [About](#about)
- [Project Status](#project-status)
- [Features](#features)
- [Terminology](#terminology)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## About

Gas couriers deliver filled cylinders to small neighborhood shops and collect the empty ones. Most still keep records on paper or from memory, which causes three recurring problems:

1. Deliveries are forgotten or recorded late.
2. Empty cylinders stay behind at shops and go unnoticed.
3. Unpaid balances are hard to track over days and weeks.

GasKurir replaces manual bookkeeping with a fast app that works offline and surfaces what needs attention on the home screen.

The project is an undergraduate final project in Informatics Engineering. It is developed by someone who also works as a gas courier, so the requirements come from real field work.

## Project Status

The project is under active development.

| Module                                                           | Status                       |
| ---------------------------------------------------------------- | ---------------------------- |
| Navigation (tab bar and quick-add action)                        | Done                         |
| Home dashboard (UI)                                              | Done, using placeholder data |
| SwiftData persistence layer                                      | Designed, not yet integrated |
| Add transaction                                                  | Not started                  |
| Transaction history and details                                  | Not started                  |
| Reports (periodic summaries, supplier purchases, charts, export) | Not started                  |
| Settings (profile, shops, reminders, backup)                     | Not started                  |
| Import of historical records from CSV                            | Not started                  |
| Order-pattern prediction and notifications                       | Not started                  |

## Features

Planned features, grouped by tab.

**Home**

- Filled and empty cylinder stock
- Cylinders still held by shops
- Today's sales and a sales chart
- Reminders for shops that are late returning cylinders

**Transactions**

- Record a delivery: shop, filled cylinders delivered, empty cylinders received, and payment
- Browse history with filters by shop, date, and payment status
- Edit or delete entries, and record payments made later

**Reports**

- Daily, weekly, and monthly summaries
- Supplier purchase history
- Profit charts
- Export to PDF and CSV

**Settings**

- Agent profile and default price
- Shop management
- Reminder thresholds
- Backup and restore

**Order-pattern prediction**

- Learns each shop's ordering habits, for example usually ordering on Thursdays in a typical quantity
- Sends a local notification the day before the predicted order
- Works as decision support only. The app informs, and the courier decides.

## Terminology

| Term        | Meaning                                                                |
| ----------- | ---------------------------------------------------------------------- |
| Warung      | A small neighborhood shop or stall, the courier's customer             |
| Tabung      | A gas cylinder, filled or empty                                        |
| Outstanding | Cylinders delivered to a shop whose empties have not been returned yet |
| Utang       | An unpaid or partially paid balance                                    |

## Tech Stack

| Concern       | Technology                                                        |
| ------------- | ----------------------------------------------------------------- |
| Language      | Swift                                                             |
| UI            | SwiftUI                                                           |
| Charts        | Swift Charts                                                      |
| Local storage | SwiftData (integration in progress)                               |
| Prediction    | Create ML for training, Core ML for on-device inference (planned) |
| Notifications | UserNotifications, local only (planned)                           |
| Export        | PDFKit and CSV (planned)                                          |

The app runs entirely on the device. There is no server, no account, and no API key, so it keeps working where reception is poor.

## Architecture

The app follows MVVM with a repository layer.

```
View  ->  ViewModel  ->  Repository  ->  SwiftData
```

Key design decisions:

- **Derived, not stored.** Cylinder stock and outstanding counts are recomputed from the transaction history, so they cannot drift out of sync.
- **Automatic payment status.** Paid, partial, and unpaid states are computed from the amount paid versus the total, never chosen by hand.
- **Price snapshots.** Each transaction stores the unit price at the time it was recorded, so later price changes never rewrite history.
- **Local-first.** All data stays on the device.

## Getting Started

### Prerequisites

- A Mac with Xcode that supports the iOS 26 SDK
- A simulator or device running iOS 26 or later (the app uses the newer `Tab` API and tab bar accessory)

### Clone and run

```bash
git clone https://github.com/USERNAME/GasKurir.git
cd GasKurir
open GasKurir.xcodeproj
```

Select an iPhone simulator or your device, then press Run (`Cmd + R`). No additional setup is needed. The Home screen currently shows placeholder data from `BerandaViewModel`.

## Project Structure

```
GasKurir/
├── GasKurir.xcodeproj
└── GasKurir/
    ├── GasKurirApp.swift
    ├── Assets
    ├── Models/
    ├── ViewModels/
    │   └── BerandaViewModel.swift
    └── Views/
        ├── RootTabView.swift
        ├── Beranda/        Home
        ├── Transaksi/      Transactions
        ├── Laporan/        Reports
        └── Pengaturan/     Settings
```

The `Repositories/` and `Preview/` folders will be added together with the SwiftData layer.

## Roadmap

- [x] Navigation and Home dashboard UI
- [ ] SwiftData models and repositories
- [ ] Add transaction flow
- [ ] Transaction history, details, and payment settlement
- [ ] Reports with PDF and CSV export
- [ ] Settings, backup and restore, CSV import of historical data
- [ ] Order-pattern prediction with Core ML and day-before notifications
- [ ] Testing and evaluation

## Contributing

Bug reports, suggestions, and pull requests are welcome. Please open an [issue](https://github.com/USERNAME/GasKurir/issues) first for larger changes.

1. Fork the repository using the Fork button on GitHub.
2. Clone your fork:
   ```bash
   git clone https://github.com/<your-username>/GasKurir.git
   cd GasKurir
   ```
3. Add the original repository as `upstream`:
   ```bash
   git remote add upstream https://github.com/USERNAME/GasKurir.git
   ```
4. Create a branch for your change:
   ```bash
   git checkout -b feature/short-description
   ```
5. Commit and push to your fork:
   ```bash
   git add .
   git commit -m "Describe your change"
   git push origin feature/short-description
   ```
6. Open a pull request against `main` and describe what changed and why.

To keep your fork up to date:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

## License

No license has been selected yet. Until one is added, all rights are reserved by the author.

## Author

Rafli Ramadhan
