# Testing CRUD Endpoints with Firebase Authentication

## Overview
This guide provides step-by-step instructions for testing the CRUD endpoints with Firebase authentication.

## Prerequisites

1. **Backend server running** on `http://localhost:8081`
2. **Firebase authentication** working (verified above)
3. **Supabase database tables** created (see DATABASE_SCHEMA.md)

## Authentication Test Results

✅ **Firebase Authentication Working**
```json
{
  "success": true,
  "message": "Token verified successfully",
  "data": {
    "uid": "token",
    "email": "admin123",
    "displayName": "admin123",
    "role": "admin",
    "emailVerified": true,
    "photoUrl": null
  }
}
```

## Current Issue

❌ **CRUD endpoints failing** because Supabase tables don't exist yet:
```
{"success":false,"message":"Exception: Failed to fetch tenants"}
```

## Step 1: Create Database Tables

Go to your Supabase project and run these SQL commands in the SQL Editor:

### Create Tenants Table
```sql
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    office_number VARCHAR(50),
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    role VARCHAR(20) DEFAULT 'tenant' CHECK (role IN ('admin', 'tenant'))
);
```

### Create Events Table
```sql
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    location VARCHAR(255),
    organizer_id UUID REFERENCES tenants(id),
    tenant_id UUID REFERENCES tenants(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    event_type VARCHAR(50) DEFAULT 'general' CHECK (event_type IN ('meeting', 'announcement', 'maintenance', 'social', 'general'))
);
```

### Create Complaints Table
```sql
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'general' CHECK (category IN ('maintenance', 'noise', 'security', 'cleanliness', 'parking', 'general')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    tenant_id UUID REFERENCES tenants(id) NOT NULL,
    assigned_to UUID REFERENCES tenants(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);
```

### Create Payments Table
```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount DECIMAL(10,2) NOT NULL,
    payment_type VARCHAR(50) DEFAULT 'rent' CHECK (payment_type IN ('rent', 'maintenance', 'utilities', 'other')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
    due_date DATE,
    paid_date DATE,
    tenant_id UUID REFERENCES tenants(id) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    payment_method VARCHAR(50) CHECK (payment_method IN ('cash', 'card', 'bank_transfer', 'online', 'check'))
);
```

## Step 2: Test CRUD Endpoints

### 1. Get Authentication Token
```bash
curl -X POST http://localhost:8081/api/v1/auth/verify \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "idToken=mock_token_admin123_admin@skyline.com"
```

### 2. Create a Tenant
```bash
curl -X POST http://localhost:8081/api/v1/tenants \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "display_name": "Test User",
    "office_number": "A-101",
    "phone": "+1234567890"
  }'
```

### 3. List All Tenants
```bash
curl -X GET http://localhost:8081/api/v1/tenants \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com"
```

### 4. Get Specific Tenant
```bash
curl -X GET http://localhost:8081/api/v1/tenants/{tenant_id} \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com"
```

### 5. Update Tenant
```bash
curl -X PUT http://localhost:8081/api/v1/tenants/{tenant_id} \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com" \
  -H "Content-Type: application/json" \
  -d '{
    "display_name": "Updated Name",
    "office_number": "B-202"
  }'
```

### 6. Delete Tenant
```bash
curl -X DELETE http://localhost:8081/api/v1/tenants/{tenant_id} \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com"
```

### 7. Create an Event
```bash
curl -X POST http://localhost:8081/api/v1/events \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Monthly Meeting",
    "description": "Monthly office meeting",
    "event_date": "2026-02-15T10:00:00Z",
    "location": "Conference Room",
    "event_type": "meeting"
  }'
```

### 8. List Events
```bash
curl -X GET http://localhost:8081/api/v1/events \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com"
```

### 9. Create a Complaint
```bash
curl -X POST http://localhost:8081/api/v1/complaints \
  -H "Authorization: Bearer mock_token_user123_user@example.com" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Air Conditioning Issue",
    "description": "AC not working properly",
    "category": "maintenance",
    "priority": "high"
  }'
```

### 10. Get Tenant's Complaints
```bash
curl -X GET http://localhost:8081/api/v1/tenant/complaints \
  -H "Authorization: Bearer mock_token_user123_user@example.com"
```

### 11. Create a Payment
```bash
curl -X POST http://localhost:8081/api/v1/payments \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1500.00,
    "payment_type": "rent",
    "due_date": "2026-02-01",
    "description": "Monthly rent for February 2026"
  }'
```

### 12. Get Tenant's Payments
```bash
curl -X GET http://localhost:8081/api/v1/tenant/payments \
  -H "Authorization: Bearer mock_token_user123_user@example.com"
```

## Expected Responses

### Success Response (200)
```json
{
  "success": true,
  "message": "Success",
  "data": { ... }
}
```

### Created Response (201)
```json
{
  "success": true,
  "message": "Created successfully",
  "data": { ... }
}
```

### Error Response (401)
```json
{
  "success": false,
  "message": "Missing or invalid authorization header"
}
```

### Error Response (404)
```json
{
  "success": false,
  "message": "Tenant not found"
}
```

### Error Response (500)
```json
{
  "success": false,
  "message": "Exception: Failed to fetch tenants"
}
```

## PowerShell Testing Commands

### Test with PowerShell (Windows)
```powershell
# Get authentication token
$authResponse = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/auth/verify" -Method POST -ContentType "application/x-www-form-urlencoded" -Body "idToken=mock_token_admin123_admin@skyline.com"
$token = "mock_token_admin123_admin@skyline.com"

# Create tenant
$tenantData = @{
  email = "test@example.com"
  display_name = "Test User"
  office_number = "A-101"
  phone = "+1234567890"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8081/api/v1/tenants" -Method POST -Headers @{
  Authorization = "Bearer $token"
  "Content-Type" = "application/json"
} -Body $tenantData

# List tenants
Invoke-RestMethod -Uri "http://localhost:8081/api/v1/tenants" -Method GET -Headers @{
  Authorization = "Bearer $token"
}
```

## Troubleshooting

### 1. Authentication Issues
- Check Firebase token is valid
- Verify token format: `mock_token_{uid}_{email}`
- Ensure Authorization header is correct

### 2. Database Issues
- Verify tables exist in Supabase
- Check Supabase connection: `GET /api/v1/supabase/db/ping`
- Review Supabase logs for errors

### 3. Permission Issues
- Check RLS policies in Supabase
- Verify user role in Firebase token
- Ensure proper authentication headers

## Next Steps

1. **Create database tables** in Supabase
2. **Test basic CRUD operations** with the commands above
3. **Add data validation** and error handling
4. **Implement real-time subscriptions** for live updates
5. **Add comprehensive error logging**

## Monitoring

Check the backend console for detailed error messages:
```bash
# Server logs will show detailed Supabase errors
✅ Firebase Admin SDK initialized successfully
✅ Supabase CRUD service initialized
❌ Failed to get tenants: {supabase_error_details}
```
