import { v4 as uuidv4 } from 'uuid';
import { getPrimaryPool, getReadReplicaPool } from '../config/database';
import { cacheService } from '../utils/cache';
import { logger } from '../config/logger';
import { dbQueryDuration } from '../config/metrics';
import { meditationSessionsStarted, meditationSessionsCompleted } from '../config/metrics';

export interface MeditationSession {
    id: string;
    user_id: string;
    type: 'guided' | 'unguided' | 'sleep';
    planned_duration: number;
    actual_duration?: number;
    completed: boolean;
    group_id?: string;
    started_at: Date;
    completed_at?: Date;
}

export interface StartSessionData {
    userId: string;
    type: 'guided' | 'unguided' | 'sleep';
    duration: number;
    groupId?: string;
}

export interface EndSessionData {
    sessionId: string;
    userId: string;
    actualDuration: number;
    completed: boolean;
}

export class MeditationService {
    /**
     * Start a meditation session
     */
    async startSession(data: StartSessionData): Promise<MeditationSession> {
        const pool = getPrimaryPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'insert', table: 'meditation_sessions' });

        try {
            const sessionId = uuidv4();
            const result = await pool.query(
                `INSERT INTO meditation_sessions 
         (id, user_id, type, planned_duration, group_id, started_at, completed)
         VALUES ($1, $2, $3, $4, $5, NOW(), false)
         RETURNING *`,
                [sessionId, data.userId, data.type, data.duration, data.groupId]
            );

            timer();

            const session = result.rows[0];

            // Increment metric
            meditationSessionsStarted.inc();

            // Invalidate user cache
            await cacheService.invalidateUserCache(data.userId);

            return session;
        } catch (error) {
            timer();
            logger.error('Start session error:', error);
            throw error;
        }
    }

    /**
     * End a meditation session
     */
    async endSession(data: EndSessionData): Promise<MeditationSession> {
        const pool = getPrimaryPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'update', table: 'meditation_sessions' });

        try {
            // Verify session belongs to user
            const verifyResult = await pool.query(
                'SELECT user_id FROM meditation_sessions WHERE id = $1',
                [data.sessionId]
            );

            if (verifyResult.rows.length === 0) {
                throw new Error('Session not found');
            }

            if (verifyResult.rows[0].user_id !== data.userId) {
                throw new Error('Unauthorized');
            }

            // Update session
            const result = await pool.query(
                `UPDATE meditation_sessions
         SET actual_duration = $1, completed = $2, completed_at = NOW()
         WHERE id = $3
         RETURNING *`,
                [data.actualDuration, data.completed, data.sessionId]
            );

            timer();

            const session = result.rows[0];

            // Increment metric if completed
            if (data.completed) {
                meditationSessionsCompleted.inc();
            }

            // Invalidate user cache
            await cacheService.invalidateUserCache(data.userId);

            return session;
        } catch (error) {
            timer();
            logger.error('End session error:', error);
            throw error;
        }
    }

    /**
     * Get user's meditation sessions with pagination
     */
    async getSessions(
        userId: string,
        page: number = 1,
        limit: number = 20
    ): Promise<{ sessions: MeditationSession[]; total: number }> {
        // Try cache for first page
        if (page === 1) {
            const cacheKey = `sessions:${userId}:page:1`;
            const cached = await cacheService.get<{ sessions: MeditationSession[]; total: number }>(cacheKey);
            if (cached) {
                return cached;
            }
        }

        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'meditation_sessions' });

        try {
            const offset = (page - 1) * limit;

            // Get sessions
            const sessionsResult = await pool.query(
                `SELECT * FROM meditation_sessions
         WHERE user_id = $1
         ORDER BY started_at DESC
         LIMIT $2 OFFSET $3`,
                [userId, limit, offset]
            );

            // Get total count
            const countResult = await pool.query(
                'SELECT COUNT(*) FROM meditation_sessions WHERE user_id = $1',
                [userId]
            );

            timer();

            const sessions = sessionsResult.rows;
            const total = parseInt(countResult.rows[0].count);

            // Cache first page for 5 minutes
            if (page === 1) {
                await cacheService.set(`sessions:${userId}:page:1`, { sessions, total }, 300);
            }

            return { sessions, total };
        } catch (error) {
            timer();
            logger.error('Get sessions error:', error);
            throw error;
        }
    }

    /**
     * Get active group meditation sessions
     */
    async getActiveGroupSessions(groupId: string): Promise<MeditationSession[]> {
        const pool = getReadReplicaPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'meditation_sessions' });

        try {
            const result = await pool.query(
                `SELECT * FROM meditation_sessions
         WHERE group_id = $1 AND completed = false
         ORDER BY started_at DESC`,
                [groupId]
            );

            timer();

            return result.rows;
        } catch (error) {
            timer();
            logger.error('Get active group sessions error:', error);
            throw error;
        }
    }
}

export const meditationService = new MeditationService();

