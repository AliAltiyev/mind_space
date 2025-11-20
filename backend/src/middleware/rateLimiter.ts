import rateLimit from 'express-rate-limit';
import { Request, Response, NextFunction } from 'express';
import { getRedisClient } from '../config/database';
import { logger } from '../config/logger';

// Redis store for distributed rate limiting
class RedisStore {
    private client = getRedisClient();

    async increment(key: string): Promise<{ total: number; resetTime: Date }> {
        const ttl = await this.client.ttl(key);
        const count = await this.client.incr(key);

        if (count === 1) {
            const windowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000');
            await this.client.expire(key, Math.ceil(windowMs / 1000));
        }

        const resetTime = new Date(Date.now() + (ttl > 0 ? ttl * 1000 : parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000')));

        return {
            total: count,
            resetTime,
        };
    }

    async decrement(key: string): Promise<void> {
        await this.client.decr(key);
    }

    async resetKey(key: string): Promise<void> {
        await this.client.del(key);
    }
}

// General API rate limiter
export const apiLimiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    message: 'Too many requests from this IP, please try again later.',
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: process.env.RATE_LIMIT_SKIP_SUCCESSFUL_REQUESTS === 'true',
    store: process.env.NODE_ENV === 'production' ? new RedisStore() : undefined,
    handler: (req: Request, res: Response) => {
        logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
        res.status(429).json({
            error: 'Too many requests',
            message: 'Rate limit exceeded. Please try again later.',
            retryAfter: Math.ceil(parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000') / 1000),
        });
    },
});

// Strict rate limiter for authentication endpoints
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 requests per window
    message: 'Too many authentication attempts, please try again later.',
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: false,
    store: process.env.NODE_ENV === 'production' ? new RedisStore() : undefined,
    handler: (req: Request, res: Response) => {
        logger.warn(`Auth rate limit exceeded for IP: ${req.ip}`);
        res.status(429).json({
            error: 'Too many authentication attempts',
            message: 'Please try again after 15 minutes.',
        });
    },
});

// User-specific rate limiter
export const userRateLimiter = (maxRequests: number = 100, windowMs: number = 15 * 60 * 1000) => {
    return rateLimit({
        windowMs,
        max: maxRequests,
        keyGenerator: (req: Request) => {
            // Use user ID if authenticated, otherwise fall back to IP
            return (req as any).user?.id || req.ip;
        },
        message: 'Too many requests, please try again later.',
        standardHeaders: true,
        legacyHeaders: false,
        store: process.env.NODE_ENV === 'production' ? new RedisStore() : undefined,
    });
};

// Middleware to check rate limit by user ID
export const checkUserRateLimit = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    const userId = (req as any).user?.id;
    if (!userId) {
        return next();
    }

    const redis = getRedisClient();
    const key = `rate_limit:user:${userId}`;
    const windowMs = 15 * 60 * 1000;
    const maxRequests = 100;

    try {
        const count = await redis.incr(key);
        if (count === 1) {
            await redis.expire(key, Math.ceil(windowMs / 1000));
        }

        if (count > maxRequests) {
            logger.warn(`User rate limit exceeded for user: ${userId}`);
            res.status(429).json({
                error: 'Rate limit exceeded',
                message: 'Too many requests. Please try again later.',
            });
            return;
        }

        // Add rate limit headers
        res.setHeader('X-RateLimit-Limit', maxRequests.toString());
        res.setHeader('X-RateLimit-Remaining', Math.max(0, maxRequests - count).toString());

        next();
    } catch (error) {
        logger.error('Error checking user rate limit:', error);
        next(); // Continue on error
    }
};

