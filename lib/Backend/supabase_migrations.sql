-- OfficeHub Supabase schema for Shelf backend
-- Run this in your Supabase SQL editor to add/extend tables required by the new backend endpoints.

-- 1) Extend tenants table with Firebase UID and onboarding fields
ALTER TABLE tenants
ADD COLUMN IF NOT EXISTS firebase_uid TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'tenant' CHECK (role IN ('admin', 'tenant')),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS company_name TEXT,
ADD COLUMN IF NOT EXISTS account_holder_name TEXT,
ADD COLUMN IF NOT EXISTS unit_or_office TEXT,
ADD COLUMN IF NOT EXISTS car_license_plate_number TEXT,
ADD COLUMN IF NOT EXISTS parking_number TEXT,
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 2) Add minutes_of_meeting to events
ALTER TABLE events
ADD COLUMN IF NOT EXISTS minutes_of_meeting TEXT DEFAULT '';

-- 3) Add type column to complaints (general vs personal)
ALTER TABLE complaints
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'personal' CHECK (type IN ('general', 'personal'));

-- 4) Admin settings table (per admin/complex)
CREATE TABLE IF NOT EXISTS admin_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    office_complex_name TEXT NOT NULL DEFAULT 'Office Complex',
    maintenance_fee NUMERIC NOT NULL DEFAULT 0,
    parking_fee NUMERIC NOT NULL DEFAULT 0,
    late_fee NUMERIC NOT NULL DEFAULT 0,
    upi_id TEXT DEFAULT '',
    whatsapp_group_number TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Optional: enforce one admin_settings per admin
CREATE UNIQUE INDEX IF NOT EXISTS admin_settings_admin_id_idx ON admin_settings(admin_id);

-- 5) Cars table
CREATE TABLE IF NOT EXISTS cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    license_plate_number TEXT NOT NULL,
    parking_number TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS cars_tenant_id_idx ON cars(tenant_id);

-- 6) Staff table
CREATE TABLE IF NOT EXISTS staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('security', 'help')),
    photo_url TEXT DEFAULT '',
    assigned_offices TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert a default admin row (optional, for first-run)
-- Replace the email with your actual admin email if needed
INSERT INTO tenants (
    id,
    email,
    firebase_uid,
    display_name,
    role,
    is_active,
    created_at,
    updated_at
) SELECT
    gen_random_uuid(),
    'admin@skyline.com',
    'admin_uid_demo',
    'Admin User',
    'admin',
    true,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM tenants WHERE email = 'admin@skyline.com'
);

-- Seed default admin_settings for the demo admin (optional)
INSERT INTO admin_settings (
    admin_id,
    office_complex_name,
    maintenance_fee,
    parking_fee,
    late_fee,
    upi_id,
    whatsapp_group_number,
    created_at,
    updated_at
) SELECT
    t.id,
    'Skyline Business Park',
    5000,
    1500,
    250,
    'skyline@upi',
    '+91 9000000000',
    NOW(),
    NOW()
FROM tenants t
WHERE
    t.email = 'admin@skyline.com'
    AND NOT EXISTS (
        SELECT 1 FROM admin_settings WHERE admin_id = t.id
    );

COMMIT;
