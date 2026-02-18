# OfficeHub Backend

Dart backend server for OfficeHub app using Shelf framework.

## Setup

1. **Install dependencies**
   ```bash
   dart pub get
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Run the server**
   ```bash
   dart run lib/main.dart
   ```

## API Endpoints

### Health Check
- `GET /api/v1/health` - Basic health check
- `GET /api/v1/health/detailed` - Detailed health status

## Development

### Project Structure
```
lib/
├── config/          # Configuration files
├── middleware/      # Request middleware
├── routes/          # API routes
├── services/        # Business logic services
├── models/          # Data models
├── utils/           # Utility functions
└── main.dart        # Server entry point
```

### Environment Variables
See `.env.example` for all available configuration options.

## Testing

Run tests with:
```bash
dart test
```

## Deployment

Build for production:
```bash
dart compile exe lib/main.dart -o server
```
