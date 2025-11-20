import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { getRedisClient } from '../config/database';
import { logger } from '../config/logger';

export interface AuthRequest extends Request {
    user?: {
        id: string;
        email: string;
        role?: string;
    };
    headers: Request['headers'] & {
        authorization?: string;
    };
}

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'your-refresh-secret-key';

// Token verification middleware
export const authenticateToken = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

        if (!token) {
            res.status(401).json({ error: 'Access token required' });
            return;
        }

        // Check if token is blacklisted (logout)
        const redis = getRedisClient();
        const isBlacklisted = await redis.get(`blacklist:${token}`);
        if (isBlacklisted) {
            res.status(401).json({ error: 'Token has been revoked' });
            return;
        }

        // Verify token
        const decoded = jwt.verify(token, JWT_SECRET) as {
            userId: string;
            email: string;
            role?: string;
        };

        req.user = {
            id: decoded.userId,
            email: decoded.email,
            role: decoded.role,
        };

        next();
    } catch (error) {
        if (error instanceof jwt.TokenExpiredError) {
            res.status(401).json({ error: 'Token expired' });
            return;
        }

        if (error instanceof jwt.JsonWebTokenError) {
            res.status(401).json({ error: 'Invalid token' });
            return;
        }

        logger.error('Authentication error:', error);
        res.status(500).json({ error: 'Authentication failed' });
    }
};

// Generate access token (short-lived)
export const generateAccessToken = (userId: string, email: string, role?: string): string => {
    const expiresIn = process.env.JWT_ACCESS_EXPIRY || '15m';
    return jwt.sign(
        { userId, email, role },
        JWT_SECRET,
        { expiresIn }
    );
};

// Generate refresh token (long-lived)
export const generateRefreshToken = (userId: string, email: string): string => {
    const expiresIn = process.env.JWT_REFRESH_EXPIRY || '7d';
    return jwt.sign(
        { userId, email, type: 'refresh' },
        JWT_REFRESH_SECRET,
        { expiresIn }
    );
};

// Verify refresh token
export const verifyRefreshToken = (token: string): { userId: string; email: string } | null => {
    try {
        const decoded = jwt.verify(token, JWT_REFRESH_SECRET) as {
            userId: string;
            email: string;
            type?: string;
        };

        if (decoded.type !== 'refresh') {
            return null;
        }

        return {
            userId: decoded.userId,
            email: decoded.email,
        };
    } catch (error) {
        logger.error('Refresh token verification error:', error);
        return null;
    }
};

// Store refresh token in Redis with rotation
export const storeRefreshToken = async (
    userId: string,
    refreshToken: string,
    oldToken?: string
): Promise<void> => {
    const redis = getRedisClient();
    const expiresIn = 7 * 24 * 60 * 60; // 7 days in seconds

    // Store new token
    await redis.setex(`refresh_token:${userId}`, expiresIn, refreshToken);

    // Revoke old token if provided (token rotation)
    if (oldToken) {
        await redis.setex(`blacklist:${oldToken}`, expiresIn, '1');
    }
};

// Revoke refresh token (logout)
export const revokeRefreshToken = async (userId: string, token: string): Promise<void> => {
    const redis = getRedisClient();
    const expiresIn = 7 * 24 * 60 * 60; // 7 days in seconds

    // Remove refresh token
    await redis.del(`refresh_token:${userId}`);

    // Blacklist the token
    await redis.setex(`blacklist:${token}`, expiresIn, '1');
};

// Optional role-based authorization
export const requireRole = (...roles: string[]) => {
    return (req: AuthRequest, res: Response, next: NextFunction): void => {
        if (!req.user) {
            res.status(401).json({ error: 'Authentication required' });
            return;
        }

        if (!req.user.role || !roles.includes(req.user.role)) {
            res.status(403).json({ error: 'Insufficient permissions' });
            return;
        }

        next();
    };
};

