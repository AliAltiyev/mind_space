import { getRedisClient } from '../config/database';
import { cacheHits, cacheMisses, redisOperationDuration } from '../config/metrics';
import { logger } from '../config/logger';

const DEFAULT_TTL = 3600; // 1 hour in seconds

export class CacheService {
    private redis = getRedisClient();

    /**
     * Get value from cache
     */
    async get<T>(key: string): Promise<T | null> {
        const timer = redisOperationDuration.startTimer({ operation: 'get' });

        try {
            const value = await this.redis.get(key);
            timer();

            if (value) {
                cacheHits.inc({ cache_type: 'redis' });
                return JSON.parse(value) as T;
            }

            cacheMisses.inc({ cache_type: 'redis' });
            return null;
        } catch (error) {
            timer();
            logger.error(`Cache get error for key ${key}:`, error);
            return null;
        }
    }

    /**
     * Set value in cache
     */
    async set(key: string, value: any, ttl: number = DEFAULT_TTL): Promise<void> {
        const timer = redisOperationDuration.startTimer({ operation: 'set' });

        try {
            const serialized = JSON.stringify(value);
            await this.redis.setex(key, ttl, serialized);
            timer();
        } catch (error) {
            timer();
            logger.error(`Cache set error for key ${key}:`, error);
        }
    }

    /**
     * Delete value from cache
     */
    async delete(key: string): Promise<void> {
        const timer = redisOperationDuration.startTimer({ operation: 'delete' });

        try {
            await this.redis.del(key);
            timer();
        } catch (error) {
            timer();
            logger.error(`Cache delete error for key ${key}:`, error);
        }
    }

    /**
     * Delete multiple keys matching pattern
     */
    async deletePattern(pattern: string): Promise<void> {
        const timer = redisOperationDuration.startTimer({ operation: 'delete_pattern' });

        try {
            const keys = await this.redis.keys(pattern);
            if (keys.length > 0) {
                await this.redis.del(...keys);
            }
            timer();
        } catch (error) {
            timer();
            logger.error(`Cache delete pattern error for pattern ${pattern}:`, error);
        }
    }

    /**
     * Get or set pattern (cache-aside)
     */
    async getOrSet<T>(
        key: string,
        fetchFn: () => Promise<T>,
        ttl: number = DEFAULT_TTL
    ): Promise<T> {
        // Try to get from cache
        const cached = await this.get<T>(key);
        if (cached !== null) {
            return cached;
        }

        // Fetch from source
        const value = await fetchFn();

        // Store in cache
        await this.set(key, value, ttl);

        return value;
    }

    /**
     * Invalidate cache for user-related data
     */
    async invalidateUserCache(userId: string): Promise<void> {
        await this.deletePattern(`user:${userId}:*`);
        await this.deletePattern(`stats:${userId}:*`);
    }
}

// Singleton instance
export const cacheService = new CacheService();


