import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import meditationRoutes from './meditation.routes';
import analyticsRoutes from './analytics.routes';

const router = Router();

// Health check
router.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
router.use('/auth', authRoutes);
router.use('/user', userRoutes);
router.use('/meditation', meditationRoutes);
router.use('/sessions', meditationRoutes); // Alias for backward compatibility
router.use('/analytics', analyticsRoutes);

export default router;

