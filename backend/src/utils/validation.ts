import { z } from 'zod';
import { Request, Response, NextFunction } from 'express';

// Validation schemas
export const registerSchema = z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    name: z.string().min(2, 'Name must be at least 2 characters'),
});

export const loginSchema = z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required'),
});

export const meditationStartSchema = z.object({
    type: z.enum(['guided', 'unguided', 'sleep']),
    duration: z.number().int().min(1).max(120), // 1-120 minutes
    groupId: z.string().uuid().optional(),
});

export const meditationEndSchema = z.object({
    sessionId: z.string().uuid(),
    actualDuration: z.number().int().min(0),
    completed: z.boolean(),
});

export const updateProfileSchema = z.object({
    name: z.string().min(2).optional(),
    timezone: z.string().optional(),
    preferences: z.record(z.any()).optional(),
});

// Validation middleware factory
export const validate = (schema: z.ZodSchema) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            schema.parse(req.body);
            next();
        } catch (error) {
            if (error instanceof z.ZodError) {
                res.status(400).json({
                    error: 'Validation error',
                    details: error.errors.map((err) => ({
                        path: err.path.join('.'),
                        message: err.message,
                    })),
                });
                return;
            }

            res.status(400).json({ error: 'Invalid request data' });
        }
    };
};

// Query parameter validation
export const validateQuery = (schema: z.ZodSchema) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        try {
            schema.parse(req.query);
            next();
        } catch (error) {
            if (error instanceof z.ZodError) {
                res.status(400).json({
                    error: 'Invalid query parameters',
                    details: error.errors.map((err) => ({
                        path: err.path.join('.'),
                        message: err.message,
                    })),
                });
                return;
            }

            res.status(400).json({ error: 'Invalid query parameters' });
        }
    };
};

// Pagination schema
export const paginationSchema = z.object({
    page: z.string().regex(/^\d+$/).transform(Number).pipe(z.number().int().min(1)).optional().default('1'),
    limit: z.string().regex(/^\d+$/).transform(Number).pipe(z.number().int().min(1).max(100)).optional().default('20'),
});


