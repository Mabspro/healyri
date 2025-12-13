# Firebase CLI Setup for Windows

## Issue

On Windows, after installing Firebase CLI globally with `npm install -g firebase-tools`, PowerShell may not immediately recognize the `firebase` command due to PATH caching.

## Solutions

### Option 1: Use `npx` (Recommended - Works Immediately)

Instead of `firebase`, use `npx firebase-tools`:

```powershell
# Check version
npx firebase-tools --version

# Login
npx firebase-tools login

# Deploy
npx firebase-tools deploy --only hosting
```

### Option 2: Refresh PowerShell PATH

Close and reopen PowerShell, or run:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

Then use `firebase` normally.

### Option 3: Use Full Path

Find where npm installs global packages:

```powershell
npm config get prefix
```

Then add that path + `\node_modules\.bin` to your PATH, or use the full path directly.

## Quick Deployment Commands (Using npx)

```powershell
# Build web app
flutter build web --release

# Login to Firebase (first time only)
npx firebase-tools login

# Select your project
npx firebase-tools use healyri-af36a

# Deploy hosting
npx firebase-tools deploy --only hosting

# Deploy functions
npx firebase-tools deploy --only functions

# Deploy everything
npx firebase-tools deploy
```

## Verify Installation

```powershell
npx firebase-tools --version
```

Should show: `15.0.0` (or similar)

## Troubleshooting

**If `npx` doesn't work:**
- Make sure Node.js and npm are installed: `node --version` and `npm --version`
- Try restarting your terminal/IDE

**If login fails:**
- Use `npx firebase-tools login --no-localhost` for remote environments
- Or use `npx firebase-tools login:ci` for CI/CD

