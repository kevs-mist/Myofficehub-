# Supabase Integration Guide

## Overview
The OfficeHub backend now includes full Supabase integration with:
- **Service initialization** with health checks
- **Database connectivity** verification via PostgREST
- **Health endpoints** for monitoring
- **Production-ready error handling**

## Environment Variables

Add these to your `Backend/.env` file:

```env
# Supabase Configuration
SUPABASE_URL=https://xglgbihqaiuuknbhlwaj.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbGdiaWhxYWl1dWtuYmhsd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NTM3MTUsImV4cCI6MjA4NTQyOTcxNX0.8IlSMTIh-7Sfsfgd2a7vJ4JxsVWcTdWsN249WicMXbg
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbGdiaWhxYWl1dWtuYmhsd2FqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTg1MzcxNSwiZXhwIjoyMDg1NDI5NzE1fQ.ShI7fTB6H2e0fPL_9pMYdyPTa7kB-Y1v2XlSvyL2e3s
```

### Important Notes
- **SUPABASE_SERVICE_KEY** is for **backend-only** (server-side operations)
- **SUPABASE_ANON_KEY** can be used in Flutter if needed
- Never expose the service key in Flutter or client-side code

## API Endpoints

### Health Checks

#### Basic Health (for monitoring)
```bash
GET http://localhost:8081/api/v1/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-01T11:18:46.697348",
  "uptime": 0,
  "uptimeHuman": "0s",
  "server": "OfficeHub Backend",
  "version": "1.0.0",
  "environment": "development",
  "gitCommit": "unknown"
}
```

#### Detailed Health (with services)
```bash
GET http://localhost:8081/api/v1/health/detailed
```

Response:
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "status": "ok",
    "timestamp": "2026-02-01T11:18:53.222714",
    "server": "OfficeHub Backend",
    "version": "1.0.0",
    "services": {
      "database": "connected",
      "firebase": "connected",
      "supabase": "connected"
    }
  }
}
```

### Supabase-Specific Endpoints

#### Supabase Service Health
```bash
GET http://localhost:8081/api/v1/supabase/ping
```

#### Supabase Database Health (PostgREST)
```bash
GET http://localhost:8081/api/v1/supabase/db/ping
```

Response:
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "status": "connected"
  }
}
```

## Testing with Postman

### 1. Basic Health Check
```
GET http://localhost:8081/api/v1/health
```

### 2. Detailed Health Check
```
GET http://localhost:8081/api/v1/health/detailed
```

### 3. Supabase Database Ping
```
GET http://localhost:8081/api/v1/supabase/db/ping
```

### 4. Supabase Service Ping
```
GET http://localhost:8081/api/v1/supabase/ping
```

## Testing with Flutter

### HTTP Client Example
```dart
import 'package:http/http.dart' as http;

class SupabaseService {
  static Future<bool> checkDatabaseHealth() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8081/api/v1/supabase/db/ping'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### Using in Flutter App
```dart
// Check Supabase connectivity
bool isSupabaseConnected = await SupabaseService.checkDatabaseHealth();
print('Supabase connected: $isSupabaseConnected');
```

## Service Status Values

| Status | Meaning |
|--------|---------|
| `not_initialized` | Service not yet started |
| `connected` | Service is healthy and reachable |
| `error` | Service failed to connect |

## Troubleshooting

### Common Issues

1. **"No host specified in URI your_supabase_url"**
   - Update `SUPABASE_URL` in `.env` with real Supabase URL
   - Restart the backend server

2. **"PostgREST returned 401"**
   - Check your Supabase keys in `.env`
   - Ensure service role key is correct

3. **"database: error" in health check**
   - Check `/api/v1/supabase/db/ping` for detailed error
   - Verify Supabase project is active

### Debug Steps

1. Check backend logs for initialization messages
2. Test `/api/v1/supabase/ping` and `/api/v1/supabase/db/ping` separately
3. Verify `.env` values are correct
4. Ensure Supabase project is active and accessible

## Production Considerations

- Use **SUPABASE_SERVICE_KEY** for backend operations
- Implement proper Row Level Security (RLS) in Supabase
- Monitor the health endpoints for uptime tracking
- Set up alerts for service failures

## Next Steps

1. **Add database tables** to your Supabase project
2. **Implement CRUD operations** using the Supabase client
3. **Add authentication middleware** for protected routes
4. **Set up monitoring** using the health endpoints

## Support

For issues with Supabase integration:
1. Check the backend console output
2. Test the health endpoints
3. Verify environment variables
4. Ensure Supabase project is active
