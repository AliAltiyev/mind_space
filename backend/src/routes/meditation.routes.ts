import { Router, Request, Response } from 'express';
import { meditationService } from '../services/meditation.service';
import { authenticateToken } from '../middleware/auth';
import { validate } from '../utils/validation';
import { meditationStartSchema, meditationEndSchema } from '../utils/validation';
import { getPaginationParams, createPaginatedResponse } from '../utils/pagination';
import { checkUserRateLimit } from '../middleware/rateLimiter';

const router = Router();

// All routes require authentication
router.use(authenticateToken);

/**
 * POST /api/meditation/start
 * Start a meditation session
 */
router.post(
    '/start',
    checkUserRateLimit,
    validate(meditationStartSchema),
    async (req: any, res: Response) => {
        try {
            const session = await meditationService.startSession({
                userId: req.user.id,
                ...req.body,
            });
            res.status(201).json(session);
        } catch (error: any) {
            res.status(500).json({ error: error.message || 'Failed to start session' });
        }
    }
);

/**
 * POST /api/meditation/end
 * End a meditation session
 */
router.post(
    '/end',
    checkUserRateLimit,
    validate(meditationEndSchema),
    async (req: any, res: Response) => {
        try {
            const session = await meditationService.endSession({
                ...req.body,
                userId: req.user.id,
            });
            res.json(session);
        } catch (error: any) {
            if (error.message === 'Session not found' || error.message === 'Unauthorized') {
                res.status(404).json({ error: error.message });
                return;
            }
            res.status(500).json({ error: error.message || 'Failed to end session' });
        }
    }
);

/**
 * GET /api/sessions
 * Get user's meditation sessions with pagination
 */
router.get('/sessions', checkUserRateLimit, async (req: any, res: Response) => {
    try {
        const { page, limit } = getPaginationParams(req);
        const { sessions, total } = await meditationService.getSessions(
            req.user.id,
            page,
            limit
        );

        const response = createPaginatedResponse(sessions, total, page, limit);
        res.json(response);
    } catch (error: any) {
        res.status(500).json({ error: error.message || 'Failed to get sessions' });
    }
});

export default router;


