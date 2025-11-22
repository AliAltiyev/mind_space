-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    timezone VARCHAR(50) DEFAULT 'UTC',
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Meditation sessions table
CREATE TABLE IF NOT EXISTS meditation_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('guided', 'unguided', 'sleep')),
    planned_duration INTEGER NOT NULL CHECK (planned_duration > 0 AND planned_duration <= 120),
    actual_duration INTEGER,
    completed BOOLEAN DEFAULT false,
    group_id UUID,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON meditation_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_started_at ON meditation_sessions(started_at);
CREATE INDEX IF NOT EXISTS idx_sessions_completed_at ON meditation_sessions(completed_at) WHERE completed_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sessions_group_id ON meditation_sessions(group_id) WHERE group_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sessions_user_completed ON meditation_sessions(user_id, completed, completed_at);

-- Composite index for analytics queries
CREATE INDEX IF NOT EXISTS idx_sessions_analytics ON meditation_sessions(user_id, completed, started_at, type);

-- Partitioning for large tables (optional, for production with millions of records)
-- Uncomment if needed:
-- CREATE TABLE meditation_sessions_2024_01 PARTITION OF meditation_sessions
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Materialized view for user statistics (pre-aggregated)
CREATE MATERIALIZED VIEW IF NOT EXISTS user_stats_mv AS
SELECT 
    u.id as user_id,
    COUNT(ms.id) FILTER (WHERE ms.completed = true) as total_sessions,
    COALESCE(SUM(ms.actual_duration) FILTER (WHERE ms.completed = true), 0) as total_minutes,
    COALESCE(AVG(ms.actual_duration) FILTER (WHERE ms.completed = true), 0) as avg_duration,
    mode() WITHIN GROUP (ORDER BY ms.type) FILTER (WHERE ms.completed = true) as favorite_type,
    MAX(ms.completed_at) as last_session_at
FROM users u
LEFT JOIN meditation_sessions ms ON u.id = ms.user_id
GROUP BY u.id;

-- Index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_stats_mv_user_id ON user_stats_mv(user_id);

-- Function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_user_stats()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY user_stats_mv;
END;
$$ LANGUAGE plpgsql;

-- Schedule materialized view refresh (runs via cron job in application)
-- This can be called periodically to keep stats up to date


