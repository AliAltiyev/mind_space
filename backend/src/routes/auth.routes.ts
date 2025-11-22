import { Router, Request, Response } from 'express';
import { authService } from '../services/auth.service';
import { validate } from '../utils/validation';
import { registerSchema, loginSchema } from '../utils/validation';
import { authLimiter } from '../middleware/rateLimiter';
import { logger } from '../config/logger';

const router = Router();

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post(
    '/register',
    authLimiter,
    validate(registerSchema),
    async (req: Request, res: Response) => {
        try {
            const result = await authService.register(req.body);
            res.status(201).json(result);
        } catch (error: any) {
            logger.error('Registration error:', error);
            if (error.message === 'User with this email already exists') {
                res.status(409).json({ error: error.message });
                return;
            }
            res.status(500).json({ error: 'Registration failed' });
        }
    }
);

/**
 * POST /api/auth/login
 * Login user
 */
router.post(
    '/login',
    authLimiter,
    validate(loginSchema),
    async (req: Request, res: Response) => {
        try {
            const result = await authService.login(req.body);
            res.json(result);
        } catch (error: any) {
            logger.error('Login error:', error);
            if (error.message === 'Invalid email or password') {
                res.status(401).json({ error: error.message });
                return;
            }
            res.status(500).json({ error: 'Login failed' });
        }
    }
);

/**
 * POST /api/auth/refresh
 * Refresh access token
 */
router.post('/refresh', async (req: Request, res: Response) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) {
            res.status(400).json({ error: 'Refresh token required' });
            return;
        }

        const result = await authService.refreshToken(refreshToken);
        res.json(result);
    } catch (error: any) {
        logger.error('Refresh token error:', error);
        res.status(401).json({ error: error.message || 'Invalid refresh token' });
    }
});

/**
 * POST /api/auth/logout
 * Logout user (requires authentication)
 */
router.post('/logout', async (req: any, res: Response) => {
    try {
        const userId = req.user?.id;
        const { refreshToken } = req.body;

        if (!userId || !refreshToken) {
            res.status(400).json({ error: 'User ID and refresh token required' });
            return;
        }

        await authService.logout(userId, refreshToken);
        res.json({ message: 'Logged out successfully' });
    } catch (error: any) {
        logger.error('Logout error:', error);
        res.status(500).json({ error: 'Logout failed' });
    }
});

export default router;


