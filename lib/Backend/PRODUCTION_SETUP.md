# Production-Ready Supabase Setup Guide

## 🚀 Overview
This guide will help you set up a production-ready Supabase database with proper security, performance, and reliability for the OfficeHub application.

## 📋 Prerequisites

1. **Supabase Project** created and running
2. **Environment variables** configured in `.env` file
3. **Backend server** running and connected to Supabase

## 🗄️ Step 1: Create Database Tables

Execute these SQL commands in your Supabase SQL Editor:

### Core Tables
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Tenants Table
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    office_number VARCHAR(50),
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    role VARCHAR(20) DEFAULT 'tenant' CHECK (role IN ('admin', 'tenant'))
);

-- Create Events Table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    location VARCHAR(255),
    organizer_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    event_type VARCHAR(50) DEFAULT 'general' CHECK (event_type IN ('meeting', 'announcement', 'maintenance', 'social', 'general'))
);

-- Create Complaints Table
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'general' CHECK (category IN ('maintenance', 'noise', 'security', 'cleanliness', 'parking', 'general')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES tenants(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Create Payments Table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_type VARCHAR(50) DEFAULT 'rent' CHECK (payment_type IN ('rent', 'maintenance', 'utilities', 'other')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
    due_date DATE,
    paid_date DATE,
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    payment_method VARCHAR(50) CHECK (payment_method IN ('cash', 'card', 'bank_transfer', 'online', 'check'))
);
```

## 🔐 Step 2: Enable Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
```

## 🛡️ Step 3: Create RLS Policies

```sql
-- Tenants Table Policies
CREATE POLICY "Users can view their own profile" ON tenants
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update their own profile" ON tenants
    FOR UPDATE USING (auth.uid()::text = id::text);

CREATE POLICY "Admins can view all tenants" ON tenants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can manage all tenants" ON tenants
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Events Table Policies
CREATE POLICY "Anyone can view active events" ON events
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage all events" ON events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Tenants can view their own events" ON events
    FOR SELECT USING (
        tenant_id = auth.uid() OR 
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Complaints Table Policies
CREATE POLICY "Users can view their own complaints" ON complaints
    FOR SELECT USING (tenant_id = auth.uid());

CREATE POLICY "Users can create their own complaints" ON complaints
    FOR INSERT WITH CHECK (tenant_id = auth.uid());

CREATE POLICY "Users can update their own complaints" ON complaints
    FOR UPDATE USING (tenant_id = auth.uid());

CREATE POLICY "Admins can manage all complaints" ON complaints
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Payments Table Policies
CREATE POLICY "Users can view their own payments" ON payments
    FOR SELECT USING (tenant_id = auth.uid());

CREATE POLICY "Admins can manage all payments" ON payments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );
```

## 📊 Step 4: Add Performance Indexes

```sql
-- Tenants Table Indexes
CREATE INDEX idx_tenants_email ON tenants(email);
CREATE INDEX idx_tenants_role ON tenants(role);
CREATE INDEX idx_tenants_active ON tenants(is_active);
CREATE INDEX idx_tenants_created_at ON tenants(created_at);

-- Events Table Indexes
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_tenant ON events(tenant_id);
CREATE INDEX idx_events_type ON events(event_type);
CREATE INDEX idx_events_active ON events(is_active);
CREATE INDEX idx_events_created_at ON events(created_at);

-- Complaints Table Indexes
CREATE INDEX idx_complaints_tenant ON complaints(tenant_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_priority ON complaints(priority);
CREATE INDEX idx_complaints_category ON complaints(category);
CREATE INDEX idx_complaints_assigned ON complaints(assigned_to);
CREATE INDEX idx_complaints_created_at ON complaints(created_at);

-- Payments Table Indexes
CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_type ON payments(payment_type);
CREATE INDEX idx_payments_due_date ON payments(due_date);
CREATE INDEX idx_payments_paid_date ON payments(paid_date);
CREATE INDEX idx_payments_created_at ON payments(created_at);
```

## ⚡ Step 5: Create Database Functions & Triggers

```sql
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for all tables
CREATE TRIGGER update_tenants_updated_at 
    BEFORE UPDATE ON tenants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at 
    BEFORE UPDATE ON events 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_complaints_updated_at 
    BEFORE UPDATE ON complaints 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at 
    BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically set resolved_at
CREATE OR REPLACE FUNCTION set_resolved_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
        NEW.resolved_at = NOW();
    ELSIF NEW.status != 'resolved' THEN
        NEW.resolved_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_complaint_resolved_at 
    BEFORE UPDATE ON complaints 
    FOR EACH ROW EXECUTE FUNCTION set_resolved_at();

-- Function for tenant statistics
CREATE OR REPLACE FUNCTION get_tenant_stats(tenant_uuid UUID)
RETURNS TABLE(
    total_events BIGINT,
    total_complaints BIGINT,
    open_complaints BIGINT,
    total_payments DECIMAL,
    pending_payments DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM events WHERE tenant_id = tenant_uuid),
        (SELECT COUNT(*) FROM complaints WHERE tenant_id = tenant_uuid),
        (SELECT COUNT(*) FROM complaints WHERE tenant_id = tenant_uuid AND status = 'open'),
        COALESCE((SELECT SUM(amount) FROM payments WHERE tenant_id = tenant_uuid), 0),
        COALESCE((SELECT SUM(amount) FROM payments WHERE tenant_id = tenant_uuid AND status = 'pending'), 0);
END;
$$ LANGUAGE plpgsql;
```

## 🔧 Step 6: Update Backend Services

Replace the current services with production-ready versions:

### Update main.dart
```dart
// Replace imports
import 'services/realtime_service_production.dart';
import 'services/supabase_crud_service_production.dart';

// Update initialization
await ProductionRealtimeService.instance.initialize();
await ProductionSupabaseCrudService.instance.initialize();
```

### Update routes to use production services
```dart
// In crud.dart, replace SupabaseCrudService with ProductionSupabaseCrudService
// In realtime.dart, replace RealtimeService with ProductionRealtimeService
```

## 🧪 Step 7: Test Production Setup

### Test Database Connectivity
```bash
curl -X GET http://localhost:8081/api/v1/supabase/db/ping
```

### Test CRUD Operations
```bash
# Get authentication token
curl -X POST http://localhost:8081/api/v1/auth/verify \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "idToken=mock_token_admin123_admin@skyline.com"

# Test tenant creation
curl -X POST http://localhost:8081/api/v1/tenants \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "display_name": "Test User",
    "office_number": "A-101",
    "phone": "+1234567890"
  }'

# List tenants
curl -X GET http://localhost:8081/api/v1/tenants \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com"
```

### Test Real-time Subscriptions
```bash
curl -X GET http://localhost:8081/api/v1/realtime/test/events \
  -H "Authorization: Bearer mock_token_admin123_admin@skyline.com"
```

## 🔒 Step 8: Security Configuration

### Environment Variables
Ensure your `.env` file has production-ready values:
```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
```

### API Keys Security
- **Never expose SERVICE_KEY** in client-side code
- **Use ANON_KEY** only for client-side operations
- **Rotate keys regularly** for security

## 📈 Step 9: Performance Optimization

### Connection Pooling
Supabase automatically handles connection pooling, but you can:
- Monitor connection usage in Supabase dashboard
- Set up read replicas for high-traffic applications
- Use edge functions for global distribution

### Caching Strategy
- Implement Redis caching for frequently accessed data
- Use Supabase's built-in caching
- Cache real-time subscriptions appropriately

## 🔍 Step 10: Monitoring & Logging

### Health Checks
```bash
# Basic health
curl -X GET http://localhost:8081/api/v1/health

# Detailed health with database status
curl -X GET http://localhost:8081/api/v1/health/detailed

# Real-time service status
curl -X GET http://localhost:8081/api/v1/realtime/status
```

### Error Monitoring
- All Supabase errors are logged with detailed information
- Monitor the backend console for error messages
- Set up alerts for database connection failures

## 🚀 Step 11: Deployment Checklist

### Before Production
- [ ] All database tables created
- [ ] RLS policies implemented and tested
- [ ] Indexes created for performance
- [ ] Triggers and functions working
- [ ] Environment variables configured
- [ ] Real-time subscriptions tested
- [ ] CRUD operations tested
- [ ] Error handling verified

### Production Deployment
1. **Backup current database**
2. **Run migration scripts**
3. **Update environment variables**
4. **Deploy backend with production services**
5. **Test all endpoints**
6. **Monitor performance and errors**

## 📞 Support

### Common Issues
1. **RLS Policy Errors**: Check that policies match your authentication flow
2. **Connection Issues**: Verify Supabase URL and keys
3. **Real-time Not Working**: Ensure WebSocket connections are allowed
4. **Performance Issues**: Check indexes and query optimization

### Debug Commands
```bash
# Check Supabase connection
curl -X GET http://localhost:8081/api/v1/supabase/ping

# Check database health
curl -X GET http://localhost:8081/api/v1/supabase/db/ping

# Test authentication
curl -X POST http://localhost:8081/api/v1/auth/verify \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "idToken=mock_token_admin123_admin@skyline.com"
```

## ✅ Production Ready Checklist

- [x] **Database Schema**: Complete with proper relationships
- [x] **Security**: RLS policies implemented
- [x] **Performance**: Indexes and optimized queries
- [x] **Reliability**: Error handling and logging
- [x] **Real-time**: Production-ready subscriptions
- [x] **Monitoring**: Health checks and status endpoints
- [x] **Validation**: Input validation and sanitization
- [x] **Documentation**: Complete setup guide

**🎉 Your Supabase integration is now production-ready!**
