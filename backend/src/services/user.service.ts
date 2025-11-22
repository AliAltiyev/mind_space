import { getPrimaryPool, getReadReplicaPool } from '../config/database';
import { cacheService } from '../utils/cache';
import { logger } from '../config/logger';
import { dbQueryDuration } from '../config/metrics';

export interface UserProfile {
    id: string;
    email: string;
    name: string;
    timezone?: string;
    preferences?: Record<string, any>;
    created_at: Date;
    last_login?: Date;
}

export interface UpdateProfileData {
    name?: string;
    timezone?: string;
    preferences?: Record<string, any>;
}

export interface UserStats {
    totalSessions: number;
    totalMinutes: number;
    currentStreak: number;
    longestStreak: number;
    averageSessionDuration: number;
    favoriteType: string;
}

export class UserService {
    /**
     * Get user profile
     */
    async getProfile(userId: string): Promise<UserProfile> {
        // Try cache first
        const cacheKey = `user:${userId}:profile`;
        const cached = await cacheService.get<UserProfile>(cacheKey);
        if (cached) {
            return cached;
        }

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'users' });

        try {
            const result = await pool.query(
                `SELECT id, email, name, timezone, preferences, created_at, last_login
         FROM users WHERE id = $1`,
                [userId]
            );

            timer();

            if (result.rows.length === 0) {
                throw new Error('User not found');
            }

            const user = result.rows[0];

            // Cache for 1 hour
            await cacheService.set(cacheKey, user, 3600);

            return user;
        } catch (error) {
            timer();
            logger.error('Get profile error:', error);
            throw error;
        }
    }

    /**
     * Update user profile
     */
    async updateProfile(userId: string, data: UpdateProfileData): Promise<UserProfile> {
        const pool = getPrimaryPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'update', table: 'users' });

        try {
            const updates: string[] = [];
            const values: any[] = [];
            let paramIndex = 1;

            if (data.name !== undefined) {
                updates.push(`name = $${paramIndex++}`);
                values.push(data.name);
            }

            if (data.timezone !== undefined) {
                updates.push(`timezone = $${paramIndex++}`);
                values.push(data.timezone);
            }

            if (data.preferences !== undefined) {
                updates.push(`preferences = $${paramIndex++}`);
                values.push(JSON.stringify(data.preferences));
            }

            if (updates.length === 0) {
                return this.getProfile(userId);
            }

            values.push(userId);

            const result = await pool.query(
                `UPDATE users 
         SET ${updates.join(', ')}, updated_at = NOW()
         WHERE id = $${paramIndex}
         RETURNING id, email, name, timezone, preferences, created_at, last_login`,
                values
            );

            timer();

            const user = result.rows[0];

            // Invalidate cache
            await cacheService.invalidateUserCache(userId);

            return user;
        } catch (error) {
            timer();
            logger.error('Update profile error:', error);
            throw error;
        }
    }

    /**
     * Get user statistics (with caching and pre-aggregation)
     */
    async getStats(userId: string): Promise<UserStats> {
        // Try cache first (cache for 5 minutes)
        const cacheKey = `stats:${userId}:summary`;
        const cached = await cacheService.get<UserStats>(cacheKey);
        if (cached) {
            return cached;
        }

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'meditation_sessions' });

        try {
            // Get aggregated stats
            const statsResult = await pool.query(
                `SELECT 
          COUNT(*) as total_sessions,
          COALESCE(SUM(actual_duration), 0) as total_minutes,
          COALESCE(AVG(actual_duration), 0) as avg_duration,
          mode() WITHIN GROUP (ORDER BY type) as favorite_type
         FROM meditation_sessions
         WHERE user_id = $1 AND completed = true`,
                [userId]
            );

            // Get streak information
            const streakResult = await pool.query(
                `WITH daily_sessions AS (
          SELECT DISTINCT DATE(completed_at) as session_date
          FROM meditation_sessions
          WHERE user_id = $1 AND completed = true
          ORDER BY session_date DESC
        ),
        streaks AS (
          SELECT 
            session_date,
            ROW_NUMBER() OVER (ORDER BY session_date DESC) as rn,
            session_date - (ROW_NUMBER() OVER (ORDER BY session_date DESC) || ' days')::interval as streak_group
          FROM daily_sessions
        )
        SELECT 
          COUNT(*) as streak_length,
          MIN(session_date) as streak_start,
          MAX(session_date) as streak_end
        FROM streaks
        GROUP BY streak_group
        ORDER BY streak_length DESC
        LIMIT 1`,
                [userId]
            );

            timer();

            const stats = statsResult.rows[0];
            const streak = streakResult.rows[0] || { streak_length: 0 };

            // Calculate current streak
            const currentStreakResult = await pool.query(
                `WITH recent_sessions AS (
          SELECT DISTINCT DATE(completed_at) as session_date
          FROM meditation_sessions
          WHERE user_id = $1 AND completed = true
          ORDER BY session_date DESC
          LIMIT 30
        )
        SELECT COUNT(*) as current_streak
        FROM (
          SELECT 
            session_date,
            ROW_NUMBER() OVER (ORDER BY session_date DESC) as rn,
            session_date - (ROW_NUMBER() OVER (ORDER BY session_date DESC) || ' days')::interval as expected_date
          FROM recent_sessions
        ) t
        WHERE session_date = expected_date
        AND rn = 1 OR (rn > 1 AND session_date = expected_date)`,
                [userId]
            );

            const currentStreak = currentStreakResult.rows[0]?.current_streak || 0;

            const userStats: UserStats = {
                totalSessions: parseInt(stats.total_sessions) || 0,
                totalMinutes: parseInt(stats.total_minutes) || 0,
                currentStreak: currentStreak,
                longestStreak: parseInt(streak.streak_length) || 0,
                averageSessionDuration: parseFloat(stats.avg_duration) || 0,
                favoriteType: stats.favorite_type || 'guided',
            };

            // Cache for 5 minutes
            await cacheService.set(cacheKey, userStats, 300);

            return userStats;
        } catch (error) {
            timer();
            logger.error('Get stats error:', error);
            throw error;
        }
    }
}

export const userService = new UserService();


