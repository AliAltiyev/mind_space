import { Pool, PoolConfig } from 'pg';
import { Redis } from 'ioredis';

// PostgreSQL Connection Pool (Primary)
let primaryPool: Pool | null = null;
let readReplicaPool: Pool | null = null;

// Redis Client
let redisClient: Redis | null = null;

export const getPrimaryPool = (): Pool => {
    if (!primaryPool) {
        const config: PoolConfig = {
            host: process.env.POSTGRES_HOST || 'localhost',
            port: parseInt(process.env.POSTGRES_PORT || '5432'),
            database: process.env.POSTGRES_DB || 'mind_space',
            user: process.env.POSTGRES_USER || 'postgres',
            password: process.env.POSTGRES_PASSWORD || 'postgres',
            max: parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '100'),
            idleTimeoutMillis: 30000,
            connectionTimeoutMillis: 2000,
        };

        primaryPool = new Pool(config);

        primaryPool.on('error', (err) => {
            console.error('Unexpected error on idle primary database client', err);
        });
    }

    return primaryPool;
};

export const getReadReplicaPool = (): Pool | null => {
    // In production, use read replica for read queries
    if (process.env.NODE_ENV === 'production' && !readReplicaPool) {
        const config: PoolConfig = {
            host: process.env.POSTGRES_READ_REPLICA_HOST || process.env.POSTGRES_HOST || 'localhost',
            port: parseInt(process.env.POSTGRES_READ_REPLICA_PORT || process.env.POSTGRES_PORT || '5432'),
            database: process.env.POSTGRES_DB || 'mind_space',
            user: process.env.POSTGRES_USER || 'postgres',
            password: process.env.POSTGRES_PASSWORD || 'postgres',
            max: parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '100'),
            idleTimeoutMillis: 30000,
            connectionTimeoutMillis: 2000,
        };

        readReplicaPool = new Pool(config);

        readReplicaPool.on('error', (err) => {
            console.error('Unexpected error on idle read replica database client', err);
        });
    }

    return readReplicaPool || getPrimaryPool();
};

export const getRedisClient = (): Redis => {
    if (!redisClient) {
        const isClusterMode = process.env.REDIS_CLUSTER_MODE === 'true';

        if (isClusterMode) {
            const nodes = (process.env.REDIS_CLUSTER_NODES || 'localhost:6379')
                .split(',')
                .map((node) => {
                    const [host, port] = node.trim().split(':');
                    return { host, port: parseInt(port || '6379') };
                });

            redisClient = new Redis.Cluster(nodes, {
                redisOptions: {
                    password: process.env.REDIS_PASSWORD,
                },
            });
        } else {
            redisClient = new Redis({
                host: process.env.REDIS_HOST || 'localhost',
                port: parseInt(process.env.REDIS_PORT || '6379'),
                password: process.env.REDIS_PASSWORD || undefined,
                retryStrategy: (times) => {
                    const delay = Math.min(times * 50, 2000);
                    return delay;
                },
                maxRetriesPerRequest: 3,
            });
        }

        redisClient.on('error', (err) => {
            console.error('Redis Client Error', err);
        });

        redisClient.on('connect', () => {
            console.log('Redis Client Connected');
        });
    }

    return redisClient;
};

export const closeConnections = async (): Promise<void> => {
    if (primaryPool) {
        await primaryPool.end();
        primaryPool = null;
    }

    if (readReplicaPool) {
        await readReplicaPool.end();
        readReplicaPool = null;
    }

    if (redisClient) {
        await redisClient.quit();
        redisClient = null;
    }
};


