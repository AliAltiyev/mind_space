import { Router, Request, Response } from 'express';
import { analyticsService } from '../services/analytics.service';
import { authenticateToken } from '../middleware/auth';
import { checkUserRateLimit } from '../middleware/rateLimiter';

const router = Router();

// All routes require authentication
router.use(authenticateToken);

/**
 * GET /api/analytics/daily
 * Get daily analytics
 */
router.get('/daily', checkUserRateLimit, async (req: any, res: Response) => {
    try {
        const date = req.query.date as string | undefined;
        const analytics = await analyticsService.getDailyAnalytics(req.user.id, date);
        res.json(analytics);
    } catch (error: any) {
        res.status(500).json({ error: error.message || 'Failed to get daily analytics' });
    }
});

/**
 * GET /api/analytics/weekly
 * Get weekly analytics
 */
router.get('/weekly', checkUserRateLimit, async (req: any, res: Response) => {
    try {
        const weekStart = req.query.weekStart as string | undefined;
        const analytics = await analyticsService.getWeeklyAnalytics(req.user.id, weekStart);
        res.json(analytics);
    } catch (error: any) {
        res.status(500).json({ error: error.message || 'Failed to get weekly analytics' });
    }
});

/**
 * GET /api/analytics/monthly
 * Get monthly analytics
 */
router.get('/monthly', checkUserRateLimit, async (req: any, res: Response) => {
    try {
        const month = req.query.month as string | undefined;
        const analytics = await analyticsService.getMonthlyAnalytics(req.user.id, month);
        res.json(analytics);
    } catch (error: any) {
        res.status(500).json({ error: error.message || 'Failed to get monthly analytics' });
    }
});

export default router;


