import bcrypt from 'bcryptjs';
import { getPrimaryPool } from '../config/database';
import { generateAccessToken, generateRefreshToken, storeRefreshToken, revokeRefreshToken } from '../middleware/auth';
import { cacheService } from '../utils/cache';
import { logger } from '../config/logger';
import { dbQueryDuration } from '../config/metrics';

const BCRYPT_ROUNDS = parseInt(process.env.BCRYPT_ROUNDS || '12');

export interface RegisterData {
    email: string;
    password: string;
    name: string;
}

export interface LoginData {
    email: string;
    password: string;
}

export interface AuthResult {
    user: {
        id: string;
        email: string;
        name: string;
    };
    accessToken: string;
    refreshToken: string;
}

export class AuthService {
    /**
     * Register a new user
     */
    async register(data: RegisterData): Promise<AuthResult> {
        const pool = getPrimaryPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'insert', table: 'users' });

        try {
            // Check if user already exists
            const existingUser = await pool.query(
                'SELECT id FROM users WHERE email = $1',
                [data.email]
            );

            if (existingUser.rows.length > 0) {
                throw new Error('User with this email already exists');
            }

            // Hash password
            const hashedPassword = await bcrypt.hash(data.password, BCRYPT_ROUNDS);

            // Create user
            const result = await pool.query(
                `INSERT INTO users (email, password_hash, name, created_at)
         VALUES ($1, $2, $3, NOW())
         RETURNING id, email, name`,
                [data.email, hashedPassword, data.name]
            );

            timer();

            const user = result.rows[0];

            // Generate tokens
            const accessToken = generateAccessToken(user.id, user.email);
            const refreshToken = generateRefreshToken(user.id, user.email);

            // Store refresh token
            await storeRefreshToken(user.id, refreshToken);

            // Invalidate cache
            await cacheService.invalidateUserCache(user.id);

            return {
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                },
                accessToken,
                refreshToken,
            };
        } catch (error) {
            timer();
            logger.error('Registration error:', error);
            throw error;
        }
    }

    /**
     * Login user
     */
    async login(data: LoginData): Promise<AuthResult> {
        const pool = getPrimaryPool();
        const timer = dbQueryDuration.startTimer({ query_type: 'select', table: 'users' });

        try {
            // Find user
            const result = await pool.query(
                'SELECT id, email, name, password_hash FROM users WHERE email = $1',
                [data.email]
            );

            timer();

            if (result.rows.length === 0) {
                throw new Error('Invalid email or password');
            }

            const user = result.rows[0];

            // Verify password
            const isValidPassword = await bcrypt.compare(data.password, user.password_hash);
            if (!isValidPassword) {
                throw new Error('Invalid email or password');
            }

            // Generate tokens
            const accessToken = generateAccessToken(user.id, user.email);
            const refreshToken = generateRefreshToken(user.id, user.email);

            // Store refresh token
            await storeRefreshToken(user.id, refreshToken);

            // Update last login
            await pool.query(
                'UPDATE users SET last_login = NOW() WHERE id = $1',
                [user.id]
            );

            return {
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                },
                accessToken,
                refreshToken,
            };
        } catch (error) {
            timer();
            logger.error('Login error:', error);
            throw error;
        }
    }

    /**
     * Refresh access token
     */
    async refreshToken(refreshToken: string): Promise<{ accessToken: string; refreshToken: string }> {
        const { verifyRefreshToken, generateAccessToken, generateRefreshToken, storeRefreshToken } = await import('../middleware/auth');
        const { getRedisClient } = await import('../config/database');
        const redis = getRedisClient();

        // Verify refresh token
        const decoded = verifyRefreshToken(refreshToken);
        if (!decoded) {
            throw new Error('Invalid refresh token');
        }

        // Check if token exists in Redis
        const storedToken = await redis.get(`refresh_token:${decoded.userId}`);
        if (storedToken !== refreshToken) {
            throw new Error('Refresh token not found or revoked');
        }

        // Generate new tokens
        const newAccessToken = generateAccessToken(decoded.userId, decoded.email);
        const newRefreshToken = generateRefreshToken(decoded.userId, decoded.email);

        // Store new refresh token and revoke old one (token rotation)
        await storeRefreshToken(decoded.userId, newRefreshToken, refreshToken);

        return {
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
        };
    }

    /**
     * Logout user
     */
    async logout(userId: string, refreshToken: string): Promise<void> {
        await revokeRefreshToken(userId, refreshToken);
        await cacheService.invalidateUserCache(userId);
    }
}

export const authService = new AuthService();

