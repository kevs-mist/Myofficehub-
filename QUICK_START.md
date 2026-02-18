# Quick Start Guide - MyOfficeHub

## 🚀 Run the App (3 Steps)

### 1. Navigate to Project
```bash
cd c:/Mysociaty/myofficehub
```

### 2. Get Dependencies (if not already done)
```bash
flutter pub get
```

### 3. Run on Your Device

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**Chrome (for quick testing):**
```bash
flutter run -d chrome
```

**Windows (requires Developer Mode):**
```bash
# Enable Developer Mode first:
start ms-settings:developers

# Then run:
flutter run -d windows
```

## 📱 Testing the App

### Default Flow
1. App opens → **Splash Screen** (2 seconds)
2. Auto-navigates to → **Admin Dashboard**
3. Explore the dashboard with mock data

### Testing Login
1. From splash, navigate to → **Login Screen**
2. Click **"Demo Login (Skip)"** to bypass OTP
3. Lands on → **Admin Dashboard**

### Testing Onboarding
1. Navigate to → **Onboarding Screen**
2. Select **Admin** or **Tenant** role
3. Fill in the form
4. Click **"Complete Onboarding"**
5. Navigates to respective dashboard

### Testing Admin Features
From Admin Dashboard:
- Click **"Add Tenant"** → Opens tenant management
- Click **"New Event"** → Opens events screen
- Tap notification icon → (Placeholder)
- Tap profile icon → Opens profile screen

### Testing Tenant Features
1. Complete onboarding as **Tenant**
2. View payment status on dashboard
3. Click **"Pay Now"** → Opens payments screen
4. Click **"Complaint"** → Opens complaints screen

## 🔍 What to Look For

### Mobile-First Design
✅ Touch-friendly buttons (large, easy to tap)
✅ Smooth scrolling
✅ Collapsible app bar
✅ Glass cards on dashboard
✅ Responsive layout
✅ Loading states
✅ Smooth animations

### Features Working
✅ Navigation between screens
✅ Mock data loading (200ms delay)
✅ Forms with validation
✅ Dialogs (Add Tenant, Create Event)
✅ Snackbar notifications
✅ Role-based routing

## 🐛 Troubleshooting

### "No devices found"
```bash
# Check connected devices
flutter devices

# For Android emulator
flutter emulators
flutter emulators --launch <emulator_id>

# For Chrome
flutter run -d chrome
```

### "Symlink support required" (Windows)
```bash
# Enable Developer Mode
start ms-settings:developers

# Then retry
flutter run -d windows
```

### "Package not found"
```bash
flutter pub get
flutter clean
flutter pub get
```

### App stuck on loading
- Check console for errors
- Restart the app
- The admin dashboard loads data on mount (200ms delay)

## 📊 Mock Data Overview

### Admin Profile
- Name: Rajesh Kumar
- Office: Skyline Business Park
- Email: admin@skyline.com

### Tenants (3)
1. TechFlow Solutions - Office A-101
2. GreenLeaf Marketing - Office B-205
3. InnovateX - Office C-304

### Payments
- Mix of Paid, Pending, and Overdue
- Total Collected: ₹1,500
- Total Pending: ₹10,000

### Events (2)
1. Fire Safety Drill - Jan 27, 2026
2. Networking High Tea - Jan 30, 2026

### Complaints (2)
1. AC not cooling - TechFlow (Open)
2. Water leakage - GreenLeaf (Resolved)

## 🎯 Key Screens to Test

1. **Splash Screen** → Auto-navigation
2. **Admin Dashboard** → Glass cards, stats, animations
3. **Tenants Screen** → List + Add dialog
4. **Events Screen** → List + Create dialog
5. **Complaints Screen** → List + Resolve action
6. **Tenant Dashboard** → Payment status, events
7. **Login Screen** → OTP flow + Demo login
8. **Onboarding Screen** → Role selection + Forms

## 💡 Pro Tips

1. **Hot Reload**: Press `r` in terminal for hot reload
2. **Hot Restart**: Press `R` for full restart
3. **Quit**: Press `q` to quit
4. **DevTools**: Press `d` to open DevTools

## 📱 Recommended Test Devices

- **Android**: Pixel 6 or newer (API 33+)
- **iOS**: iPhone 12 or newer (iOS 15+)
- **Chrome**: Latest version
- **Screen Size**: 375px - 428px width (mobile)

## ✅ Success Checklist

After running, verify:
- [ ] App launches without errors
- [ ] Splash screen shows for 2 seconds
- [ ] Admin dashboard loads with data
- [ ] Glass cards visible on dashboard
- [ ] Navigation works (tap buttons)
- [ ] Dialogs open (Add Tenant, Create Event)
- [ ] Animations are smooth
- [ ] No console errors

## 🎉 You're Ready!

The app is fully functional with mock data. Explore all screens and features!

**Next**: Integrate with Supabase/Firebase for real backend.

---

**Need Help?** Check the console for error messages or review `README.md` for detailed documentation.
