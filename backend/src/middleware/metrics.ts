import { Request, Response, NextFunction } from 'express';
import { httpRequestDuration, httpRequestTotal } from '../config/metrics';

export const metricsMiddleware = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    const startTime = Date.now();

    // Override res.end to capture response time
    const originalEnd = res.end;
    res.end = function (chunk?: any, encoding?: any) {
        const duration = (Date.now() - startTime) / 1000;
        const route = req.route?.path || req.path;
        const method = req.method;
        const statusCode = res.statusCode;

        // Record metrics
        httpRequestDuration.observe(
            { method, route, status_code: statusCode.toString() },
            duration
        );

        httpRequestTotal.inc({ method, route, status_code: statusCode.toString() });

        // Call original end
        originalEnd.call(this, chunk, encoding);
    };

    next();
};

