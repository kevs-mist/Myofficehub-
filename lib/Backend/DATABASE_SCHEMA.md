# Database Schema for OfficeHub

## Overview
This document defines the database schema for the OfficeHub application using Supabase PostgreSQL database.

## Tables

### 1. Tenants
Stores tenant information and user profiles.

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

### 2. Events
Stores office events and announcements.

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

### 3. Complaints
Stores tenant complaints and issues.

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

### 4. Payments
Stores payment records and transactions.

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

## Indexes

```sql
-- Tenants indexes
CREATE INDEX idx_tenants_email ON tenants(email);
CREATE INDEX idx_tenants_role ON tenants(role);
CREATE INDEX idx_tenants_active ON tenants(is_active);

-- Events indexes
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_tenant ON events(tenant_id);
CREATE INDEX idx_events_type ON events(event_type);
CREATE INDEX idx_events_active ON events(is_active);

-- Complaints indexes
CREATE INDEX idx_complaints_tenant ON complaints(tenant_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_priority ON complaints(priority);
CREATE INDEX idx_complaints_category ON complaints(category);
CREATE INDEX idx_complaints_assigned ON complaints(assigned_to);
CREATE INDEX idx_complaints_created ON complaints(created_at);

-- Payments indexes
CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_type ON payments(payment_type);
CREATE INDEX idx_payments_due_date ON payments(due_date);
CREATE INDEX idx_payments_paid_date ON payments(paid_date);
```

## Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Tenants policies
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

-- Events policies
CREATE POLICY "Users can view events" ON events
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage events" ON events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Complaints policies
CREATE POLICY "Users can view their own complaints" ON complaints
    FOR SELECT USING (tenant_id = auth.uid());

CREATE POLICY "Users can create their own complaints" ON complaints
    FOR INSERT WITH CHECK (tenant_id = auth.uid());

CREATE POLICY "Admins can manage all complaints" ON complaints
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM tenants 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Payments policies
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

## Triggers

```sql
-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

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
```

## Sample Data

```sql
-- Sample tenant
INSERT INTO tenants (id, email, display_name, office_number, phone, role) VALUES
('123e4567-e89b-12d3-a456-426614174000', 'admin@skyline.com', 'Admin User', 'A-101', '+1234567890', 'admin'),
('123e4567-e89b-12d3-a456-426614174001', 'tenant1@example.com', 'John Doe', 'B-201', '+1234567891', 'tenant');

-- Sample event
INSERT INTO events (title, description, event_date, location, organizer_id, tenant_id, event_type) VALUES
('Monthly Meeting', 'Monthly office meeting to discuss upcoming events', '2026-02-15 10:00:00', 'Conference Room', '123e4567-e89b-12d3-a456-426614174000', '123e4567-e89b-12d3-a456-426614174000', 'meeting');

-- Sample complaint
INSERT INTO complaints (title, description, category, priority, tenant_id) VALUES
('Air Conditioning Issue', 'The air conditioning in my office is not working properly', 'maintenance', 'high', '123e4567-e89b-12d3-a456-426614174001');

-- Sample payment
INSERT INTO payments (amount, payment_type, due_date, tenant_id, description) VALUES
(1500.00, 'rent', '2026-02-01', '123e4567-e89b-12d3-a456-426614174001', 'Monthly rent for February 2026');
```

## API Endpoints

### Tenants
- `GET /api/v1/tenants` - List all tenants (admin only)
- `GET /api/v1/tenants/{id}` - Get specific tenant
- `POST /api/v1/tenants` - Create new tenant
- `PUT /api/v1/tenants/{id}` - Update tenant
- `DELETE /api/v1/tenants/{id}` - Delete tenant

### Events
- `GET /api/v1/events` - List all events
- `GET /api/v1/events/{id}` - Get specific event
- `POST /api/v1/events` - Create new event (admin only)
- `PUT /api/v1/events/{id}` - Update event (admin only)
- `DELETE /api/v1/events/{id}` - Delete event (admin only)
- `GET /api/v1/tenant/events` - Get tenant's events

### Complaints
- `GET /api/v1/complaints` - List all complaints (admin only)
- `GET /api/v1/complaints/{id}` - Get specific complaint
- `POST /api/v1/complaints` - Create new complaint
- `PUT /api/v1/complaints/{id}` - Update complaint (admin only)
- `DELETE /api/v1/complaints/{id}` - Delete complaint (admin only)
- `GET /api/v1/tenant/complaints` - Get tenant's complaints

### Payments
- `GET /api/v1/payments` - List all payments (admin only)
- `GET /api/v1/payments/{id}` - Get specific payment
- `POST /api/v1/payments` - Create new payment (admin only)
- `PUT /api/v1/payments/{id}` - Update payment (admin only)
- `DELETE /api/v1/payments/{id}` - Delete payment (admin only)
- `GET /api/v1/tenant/payments` - Get tenant's payments

## Authentication

All CRUD endpoints (except `/tenant/*`) require Firebase authentication. The middleware extracts the Firebase ID token from the `Authorization: Bearer {token}` header and verifies it with Firebase Auth.

Tenant-specific endpoints (`/tenant/*`) use the authenticated user's ID to filter data appropriately.

## Next Steps

1. Create these tables in your Supabase project
2. Set up Row Level Security policies
3. Test the CRUD endpoints with proper authentication
4. Add data validation and error handling
5. Implement real-time subscriptions for live updates
