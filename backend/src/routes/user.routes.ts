import { Router, Request, Response } from 'express';
import { userService } from '../services/user.service';
import { authenticateToken } from '../middleware/auth';
import { validate } from '../utils/validation';
import { updateProfileSchema } from '../utils/validation';
import { checkUserRateLimit } from '../middleware/rateLimiter';

const router = Router();

// All routes require authentication
router.use(authenticateToken);

/**
 * GET /api/user/profile
 * Get user profile
 */
router.get('/profile', checkUserRateLimit, async (req: any, res: Response) => {
    try {
        const profile = await userService.getProfile(req.user.id);
        res.json(profile);
    } catch (error: any) {
        res.status(500).json({ error: error.message || 'Failed to get profile' });
    }
});

/**
 * PUT /api/user/profile
 * Update user profile
 */
router.put(
    '/profile',
    checkUserRateLimit,
    validate(updateProfileSchema),
    async (req: any, res: Response) => {
        try {
            const profile = await userService.updateProfile(req.user.id, req.body);
            res.json(profile);
        } catch (error: any) {
            res.status(500).json({ error: error.message || 'Failed to update profile' });
        }
    }
);

/**
 * GET /api/user/stats
 * Get user statistics (cached, pre-aggregated)
 */
router.get('/stats', checkUserRateLimit, async (req: any, res: Response) => {
    try {
        const stats = await userService.getStats(req.user.id);
        res.json(stats);
    } catch (error: any) {
        res.status(500).json({ error: error.message || 'Failed to get stats' });
    }
});

export default router;


