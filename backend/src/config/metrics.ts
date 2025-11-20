import { Registry, Counter, Histogram, Gauge } from 'prom-client';

// Create a Registry to register the metrics
export const register = new Registry();

// Add default metrics (CPU, memory, etc.)
register.setDefaultLabels({
    app: 'mind-space-backend',
});

// HTTP Metrics
export const httpRequestDuration = new Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.1, 0.5, 1, 2, 5, 10],
    registers: [register],
});

export const httpRequestTotal = new Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code'],
    registers: [register],
});

// Database Metrics
export const dbQueryDuration = new Histogram({
    name: 'db_query_duration_seconds',
    help: 'Duration of database queries in seconds',
    labelNames: ['query_type', 'table'],
    buckets: [0.01, 0.05, 0.1, 0.5, 1, 2],
    registers: [register],
});

export const dbConnectionsActive = new Gauge({
    name: 'db_connections_active',
    help: 'Number of active database connections',
    registers: [register],
});

export const dbConnectionsIdle = new Gauge({
    name: 'db_connections_idle',
    help: 'Number of idle database connections',
    registers: [register],
});

// Redis Metrics
export const redisOperationDuration = new Histogram({
    name: 'redis_operation_duration_seconds',
    help: 'Duration of Redis operations in seconds',
    labelNames: ['operation'],
    buckets: [0.001, 0.005, 0.01, 0.05, 0.1],
    registers: [register],
});

export const cacheHits = new Counter({
    name: 'cache_hits_total',
    help: 'Total number of cache hits',
    labelNames: ['cache_type'],
    registers: [register],
});

export const cacheMisses = new Counter({
    name: 'cache_misses_total',
    help: 'Total number of cache misses',
    labelNames: ['cache_type'],
    registers: [register],
});

// WebSocket Metrics
export const websocketConnections = new Gauge({
    name: 'websocket_connections_active',
    help: 'Number of active WebSocket connections',
    registers: [register],
});

export const websocketMessages = new Counter({
    name: 'websocket_messages_total',
    help: 'Total number of WebSocket messages',
    labelNames: ['type'],
    registers: [register],
});

// Business Metrics
export const meditationSessionsStarted = new Counter({
    name: 'meditation_sessions_started_total',
    help: 'Total number of meditation sessions started',
    registers: [register],
});

export const meditationSessionsCompleted = new Counter({
    name: 'meditation_sessions_completed_total',
    help: 'Total number of meditation sessions completed',
    registers: [register],
});

export const activeUsers = new Gauge({
    name: 'active_users',
    help: 'Number of active users',
    registers: [register],
});

// Register all metrics
register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);
register.registerMetric(dbQueryDuration);
register.registerMetric(dbConnectionsActive);
register.registerMetric(dbConnectionsIdle);
register.registerMetric(redisOperationDuration);
register.registerMetric(cacheHits);
register.registerMetric(cacheMisses);
register.registerMetric(websocketConnections);
register.registerMetric(websocketMessages);
register.registerMetric(meditationSessionsStarted);
register.registerMetric(meditationSessionsCompleted);
register.registerMetric(activeUsers);

