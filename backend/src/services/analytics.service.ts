import { getReadReplicaPool } from '../config/database';
import { cacheService } from '../utils/cache';
import { logger } from '../config/logger';
import { dbQueryDuration } from '../config/metrics';
import cron from 'node-cron';

export interface DailyAnalytics {
    date: string;
    totalSessions: number;
    totalMinutes: number;
    averageDuration: number;
    completedSessions: number;
    byType: {
        guided: number;
        unguided: number;
        sleep: number;
    };
}

export interface WeeklyAnalytics {
    week: string;
    totalSessions: number;
    totalMinutes: number;
    averageDuration: number;
    streak: number;
    days: DailyAnalytics[];
}

export interface MonthlyAnalytics {
    month: string;
    totalSessions: number;
    totalMinutes: number;
    averageDuration: number;
    bestDay: string;
    bestDaySessions: number;
}

export class AnalyticsService {
    /**
     * Get daily analytics for user
     */
    async getDailyAnalytics(userId: string, date?: string): Promise<DailyAnalytics> {
        const targetDate = date || new Date().toISOString().split('T')[0];
        const cacheKey = `analytics:${userId}:daily:${targetDate}`;

        // Try cache first
        const cached = await cacheService.get<DailyAnalytics>(cacheKey);
        if (cached) {
            return cached;
        }

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'meditation_sessions' });

        try {
            const result = await pool.query(
                `SELECT 
          COUNT(*) as total_sessions,
          COUNT(*) FILTER (WHERE completed = true) as completed_sessions,
          COALESCE(SUM(actual_duration), 0) as total_minutes,
          COALESCE(AVG(actual_duration), 0) as avg_duration,
          COUNT(*) FILTER (WHERE type = 'guided') as guided_count,
          COUNT(*) FILTER (WHERE type = 'unguided') as unguided_count,
          COUNT(*) FILTER (WHERE type = 'sleep') as sleep_count
         FROM meditation_sessions
         WHERE user_id = $1 
         AND DATE(started_at) = $2`,
                [userId, targetDate]
            );

            timer();

            const row = result.rows[0];
            const analytics: DailyAnalytics = {
                date: targetDate,
                totalSessions: parseInt(row.total_sessions) || 0,
                totalMinutes: parseInt(row.total_minutes) || 0,
                averageDuration: parseFloat(row.avg_duration) || 0,
                completedSessions: parseInt(row.completed_sessions) || 0,
                byType: {
                    guided: parseInt(row.guided_count) || 0,
                    unguided: parseInt(row.unguided_count) || 0,
                    sleep: parseInt(row.sleep_count) || 0,
                },
            };

            // Cache for 1 hour
            await cacheService.set(cacheKey, analytics, 3600);

            return analytics;
        } catch (error) {
            timer();
            logger.error('Get daily analytics error:', error);
            throw error;
        }
    }

    /**
     * Get weekly analytics for user
     */
    async getWeeklyAnalytics(userId: string, weekStart?: string): Promise<WeeklyAnalytics> {
        const startDate = weekStart || this.getWeekStart();
        const cacheKey = `analytics:${userId}:weekly:${startDate}`;

        // Try cache first
        const cached = await cacheService.get<WeeklyAnalytics>(cacheKey);
        if (cached) {
            return cached;
        }

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'meditation_sessions' });

        try {
            const endDate = new Date(startDate);
            endDate.setDate(endDate.getDate() + 6);

            // Get daily breakdown
            const dailyResult = await pool.query(
                `SELECT 
          DATE(started_at) as date,
          COUNT(*) as total_sessions,
          COALESCE(SUM(actual_duration), 0) as total_minutes,
          COALESCE(AVG(actual_duration), 0) as avg_duration,
          COUNT(*) FILTER (WHERE completed = true) as completed_sessions,
          COUNT(*) FILTER (WHERE type = 'guided') as guided_count,
          COUNT(*) FILTER (WHERE type = 'unguided') as unguided_count,
          COUNT(*) FILTER (WHERE type = 'sleep') as sleep_count
         FROM meditation_sessions
         WHERE user_id = $1 
         AND DATE(started_at) BETWEEN $2 AND $3
         GROUP BY DATE(started_at)
         ORDER BY DATE(started_at)`,
                [userId, startDate, endDate.toISOString().split('T')[0]]
            );

            // Get total stats
            const totalResult = await pool.query(
                `SELECT 
          COUNT(*) as total_sessions,
          COALESCE(SUM(actual_duration), 0) as total_minutes,
          COALESCE(AVG(actual_duration), 0) as avg_duration
         FROM meditation_sessions
         WHERE user_id = $1 
         AND DATE(started_at) BETWEEN $2 AND $3
         AND completed = true`,
                [userId, startDate, endDate.toISOString().split('T')[0]]
            );

            // Calculate streak
            const streakResult = await pool.query(
                `WITH daily_sessions AS (
          SELECT DISTINCT DATE(completed_at) as session_date
          FROM meditation_sessions
          WHERE user_id = $1 
          AND completed = true
          AND DATE(completed_at) BETWEEN $2 AND $3
          ORDER BY session_date DESC
        )
        SELECT COUNT(*) as streak
        FROM (
          SELECT 
            session_date,
            ROW_NUMBER() OVER (ORDER BY session_date DESC) as rn,
            session_date - (ROW_NUMBER() OVER (ORDER BY session_date DESC) || ' days')::interval as expected_date
          FROM daily_sessions
        ) t
        WHERE session_date = expected_date`,
                [userId, startDate, endDate.toISOString().split('T')[0]]
            );

            timer();

            const totalRow = totalResult.rows[0];
            const days: DailyAnalytics[] = dailyResult.rows.map((row) => ({
                date: row.date,
                totalSessions: parseInt(row.total_sessions) || 0,
                totalMinutes: parseInt(row.total_minutes) || 0,
                averageDuration: parseFloat(row.avg_duration) || 0,
                completedSessions: parseInt(row.completed_sessions) || 0,
                byType: {
                    guided: parseInt(row.guided_count) || 0,
                    unguided: parseInt(row.unguided_count) || 0,
                    sleep: parseInt(row.sleep_count) || 0,
                },
            }));

            const analytics: WeeklyAnalytics = {
                week: startDate,
                totalSessions: parseInt(totalRow.total_sessions) || 0,
                totalMinutes: parseInt(totalRow.total_minutes) || 0,
                averageDuration: parseFloat(totalRow.avg_duration) || 0,
                streak: parseInt(streakResult.rows[0]?.streak) || 0,
                days,
            };

            // Cache for 1 hour
            await cacheService.set(cacheKey, analytics, 3600);

            return analytics;
        } catch (error) {
            timer();
            logger.error('Get weekly analytics error:', error);
            throw error;
        }
    }

    /**
     * Get monthly analytics for user
     */
    async getMonthlyAnalytics(userId: string, month?: string): Promise<MonthlyAnalytics> {
        const targetMonth = month || new Date().toISOString().slice(0, 7); // YYYY-MM
        const cacheKey = `analytics:${userId}:monthly:${targetMonth}`;

        // Try cache first
        const cached = await cacheService.get<MonthlyAnalytics>(cacheKey);
        if (cached) {
            return cached;
        }

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'meditation_sessions' });

        try {
            const result = await pool.query(
                `SELECT 
          COUNT(*) as total_sessions,
          COALESCE(SUM(actual_duration), 0) as total_minutes,
          COALESCE(AVG(actual_duration), 0) as avg_duration,
          DATE(started_at) as best_day,
          COUNT(*) as best_day_sessions
         FROM meditation_sessions
         WHERE user_id = $1 
         AND DATE_TRUNC('month', started_at) = $2
         AND completed = true
         GROUP BY DATE(started_at)
         ORDER BY COUNT(*) DESC
         LIMIT 1`,
                [userId, `${targetMonth}-01`]
            );

            const totalResult = await pool.query(
                `SELECT 
          COUNT(*) as total_sessions,
          COALESCE(SUM(actual_duration), 0) as total_minutes,
          COALESCE(AVG(actual_duration), 0) as avg_duration
         FROM meditation_sessions
         WHERE user_id = $1 
         AND DATE_TRUNC('month', started_at) = $2
         AND completed = true`,
                [userId, `${targetMonth}-01`]
            );

            timer();

            const row = result.rows[0] || {};
            const totalRow = totalResult.rows[0] || {};

            const analytics: MonthlyAnalytics = {
                month: targetMonth,
                totalSessions: parseInt(totalRow.total_sessions) || 0,
                totalMinutes: parseInt(totalRow.total_minutes) || 0,
                averageDuration: parseFloat(totalRow.avg_duration) || 0,
                bestDay: row.best_day || '',
                bestDaySessions: parseInt(row.best_day_sessions) || 0,
            };

            // Cache for 6 hours
            await cacheService.set(cacheKey, analytics, 21600);

            return analytics;
        } catch (error) {
            timer();
            logger.error('Get monthly analytics error:', error);
            throw error;
        }
    }

    /**
     * Pre-aggregate analytics (batch processing)
     * This runs as a scheduled job
     */
    async preAggregateAnalytics(): Promise<void> {
        logger.info('Starting analytics pre-aggregation...');

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'users' });

        try {
            // Get all active users
            const usersResult = await pool.query(
                `SELECT id FROM users 
         WHERE last_login > NOW() - INTERVAL '30 days'`
            );

            timer();

            const userIds = usersResult.rows.map((row) => row.id);
            let processed = 0;

            for (const userId of userIds) {
                try {
                    // Pre-aggregate daily analytics for today
                    await this.getDailyAnalytics(userId);

                    // Pre-aggregate weekly analytics
                    await this.getWeeklyAnalytics(userId);

                    // Pre-aggregate monthly analytics
                    await this.getMonthlyAnalytics(userId);

                    processed++;
                } catch (error) {
                    logger.error(`Error pre-aggregating analytics for user ${userId}:`, error);
                }
            }

            logger.info(`Analytics pre-aggregation completed. Processed ${processed} users.`);
        } catch (error) {
            timer();
            logger.error('Pre-aggregate analytics error:', error);
        }
    }

    /**
     * Get week start date (Monday)
     */
    private getWeekStart(): string {
        const date = new Date();
        const day = date.getDay();
        const diff = date.getDate() - day + (day === 0 ? -6 : 1); // Adjust when day is Sunday
        const monday = new Date(date.setDate(diff));
        return monday.toISOString().split('T')[0];
    }
}

export const analyticsService = new AnalyticsService();

// Schedule pre-aggregation job (runs daily at 2 AM)
if (process.env.NODE_ENV === 'production') {
    cron.schedule('0 2 * * *', () => {
        analyticsService.preAggregateAnalytics();
    });
}


