-- ============================================================================
-- CleanSpot – Public Toilet Feedback System
-- Supabase Database Schema & Security Policies
-- Aligned with UN Sustainable Development Goal 6 (Clean Water & Sanitation)
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 2. TABLES DEFINITIONS
-- ============================================================================

-- PROFILES TABLE
-- Stores user details and role. Public signups are strictly 'citizen'.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'citizen' CHECK (role IN ('citizen', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- TOILETS TABLE
-- Stores registered public restroom facilities and amenities
CREATE TABLE IF NOT EXISTS public.toilets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    description TEXT,
    water_available BOOLEAN DEFAULT TRUE NOT NULL,
    soap_available BOOLEAN DEFAULT TRUE NOT NULL,
    wheelchair_accessible BOOLEAN DEFAULT FALSE NOT NULL,
    verification_status TEXT DEFAULT 'verified' NOT NULL CHECK (verification_status IN ('verified', 'unverified', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- FEEDBACK TABLE
-- Stores citizen evaluations, photo paths, AI vision analysis, and admin responses
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    toilet_id UUID NOT NULL REFERENCES public.toilets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    overall_rating INTEGER NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    cleanliness_rating INTEGER NOT NULL CHECK (cleanliness_rating BETWEEN 1 AND 5),
    water_rating INTEGER NOT NULL CHECK (water_rating BETWEEN 1 AND 5),
    maintenance_rating INTEGER NOT NULL CHECK (maintenance_rating BETWEEN 1 AND 5),
    facilities_rating INTEGER NOT NULL CHECK (facilities_rating BETWEEN 1 AND 5),
    issue_category TEXT NOT NULL,
    comments TEXT,
    photo_path TEXT,
    ai_analysis JSONB,
    status TEXT DEFAULT 'pending' NOT NULL CHECK (status IN ('pending', 'in_progress', 'resolved', 'rejected')),
    admin_response TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================================
-- 3. INDEXES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_toilets_coordinates ON public.toilets (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_feedback_toilet_id ON public.feedback (toilet_id);
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON public.feedback (user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON public.feedback (status);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON public.feedback (created_at DESC);

-- ============================================================================
-- 4. SECURITY & AUTOMATIC PROFILE CREATION TRIGGER
-- ============================================================================

-- Function to handle new user registration: assigns 'citizen' role automatically
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, role, created_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Citizen Member'),
        'citizen', -- Strictly enforces citizen; prevents self-elevation to admin
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger firing on auth.users creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Helper function: Check if current authenticated user is an administrator
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.toilets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------
-- PROFILES POLICIES
-- ----------------------------------------------------
-- Anyone can view profiles (needed for display names on community reviews)
CREATE POLICY "Profiles are viewable by all authenticated users"
    ON public.profiles FOR SELECT
    USING (true);

-- Users can update their own full_name only (never change role)
CREATE POLICY "Users can update own profile name"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id AND role = (SELECT role FROM public.profiles WHERE id = auth.uid()));

-- ----------------------------------------------------
-- TOILETS POLICIES
-- ----------------------------------------------------
-- Public & registered citizens can view all verified toilets
CREATE POLICY "Toilets are viewable by everyone"
    ON public.toilets FOR SELECT
    USING (true);

-- Only verified administrators can insert, modify, or delete toilets
CREATE POLICY "Admins can insert toilets"
    ON public.toilets FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update toilets"
    ON public.toilets FOR UPDATE
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete toilets"
    ON public.toilets FOR DELETE
    USING (public.is_admin());

-- ----------------------------------------------------
-- FEEDBACK POLICIES
-- ----------------------------------------------------
-- All users can view feedback and community ratings
CREATE POLICY "Feedback is viewable by all users"
    ON public.feedback FOR SELECT
    USING (true);

-- Citizens can only insert their own feedback with initial 'pending' status
CREATE POLICY "Citizens can insert their own feedback"
    ON public.feedback FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
        AND status = 'pending'
    );

-- Citizens CANNOT alter status or admin_response.
-- Only administrators may update complaint status and provide municipal response:
CREATE POLICY "Only administrators can update complaint status and response"
    ON public.feedback FOR UPDATE
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- Administrators can delete inappropriate feedback
CREATE POLICY "Only administrators can delete feedback"
    ON public.feedback FOR DELETE
    USING (public.is_admin());

-- ============================================================================
-- 6. STORAGE BUCKET CONFIGURATION & POLICIES
-- ============================================================================

-- Create storage bucket for toilet photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('toilet-photos', 'toilet-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Public can view uploaded toilet photographs
CREATE POLICY "Toilet photos are publicly accessible"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'toilet-photos');

-- Authenticated citizens can upload photographic evidence
CREATE POLICY "Authenticated users can upload photos"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'toilet-photos'
        AND auth.role() = 'authenticated'
    );

-- ============================================================================
-- 7. DEMONSTRATION DATA (Clearly Labelled Sample Data)
-- ============================================================================

INSERT INTO public.toilets (id, name, address, latitude, longitude, description, water_available, soap_available, wheelchair_accessible, verification_status)
VALUES
    (
        'a1111111-1111-1111-1111-111111111111',
        'Central Metro Station Public Restroom',
        'Concourse Level 2, Metro Gate B, City Center',
        17.4399,
        78.4983,
        'High-footfall transit hub facility featuring automated flush systems, touchless sanitizer dispensers, and accessible stalls.',
        TRUE,
        TRUE,
        TRUE,
        'verified'
    ),
    (
        'a2222222-2222-2222-2222-222222222222',
        'Gandhi Memorial Park Community Facility',
        'Sector 4 Garden Walk, Opposite Children Playground',
        17.4425,
        78.4950,
        'Eco-sanitation public facility equipped with dual water supply, baby care changing station, and solar lighting.',
        TRUE,
        TRUE,
        TRUE,
        'verified'
    ),
    (
        'a3333333-3333-3333-3333-333333333333',
        'Old Bazaar Municipal Sanitation Complex',
        'Lane 7, Vegetable Wholesale Market',
        17.4350,
        78.5020,
        'Heavy traffic marketplace sanitation block. Requires periodic pressure wash maintenance during morning peak hours.',
        TRUE,
        FALSE,
        FALSE,
        'verified'
    ),
    (
        'a4444444-4444-4444-4444-444444444444',
        'Civic Plaza Smart Toilet Pod',
        'Pedestrian Boulevard, Next to Tourist Helpdesk',
        17.4480,
        78.4910,
        'Self-cleaning automated smart toilet pod with voice guidance and emergency call button for senior citizens.',
        TRUE,
        TRUE,
        TRUE,
        'verified'
    )
ON CONFLICT (id) DO NOTHING;

-- Instruction to grant administrator privileges securely:
-- To promote a specific user to administrator after they register:
-- UPDATE public.profiles SET role = 'admin' WHERE id = '<AUTH_USER_UUID>';
