import { Server as HTTPServer } from 'http';
import { Server as SocketIOServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { websocketConnections, websocketMessages } from '../config/metrics';
import { logger } from '../config/logger';
import { meditationService } from './meditation.service';

interface AuthenticatedSocket extends Socket {
    userId?: string;
    email?: string;
}

export class WebSocketService {
    private io: SocketIOServer;
    private groupSessions: Map<string, Set<string>> = new Map(); // groupId -> Set of userIds

    constructor(server: HTTPServer) {
        this.io = new SocketIOServer(server, {
            path: process.env.WS_PATH || '/meditation/group',
            cors: {
                origin: (process.env.ALLOWED_ORIGINS || 'http://localhost:3000').split(','),
                credentials: true,
            },
            transports: ['websocket', 'polling'],
        });

        this.setupMiddleware();
        this.setupEventHandlers();
    }

    /**
     * Setup authentication middleware
     */
    private setupMiddleware(): void {
        this.io.use(async (socket: AuthenticatedSocket, next) => {
            try {
                const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];

                if (!token) {
                    return next(new Error('Authentication error: Token required'));
                }

                // Verify token using JWT
                const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

                try {
                    const decoded = jwt.verify(token, JWT_SECRET) as {
                        userId: string;
                        email: string;
                    };

                    if (!decoded.userId || !decoded.email) {
                        return next(new Error('Authentication error: Invalid token payload'));
                    }

                    socket.userId = decoded.userId;
                    socket.email = decoded.email;
                    next();
                } catch (error) {
                    logger.error('JWT verification error:', error);
                    return next(new Error('Authentication error: Invalid token'));
                }

                socket.userId = decoded.userId;
                socket.email = decoded.email;

                next();
            } catch (error) {
                logger.error('WebSocket authentication error:', error);
                next(new Error('Authentication error'));
            }
        });
    }

    /**
     * Setup event handlers
     */
    private setupEventHandlers(): void {
        this.io.on('connection', (socket: AuthenticatedSocket) => {
            const userId = socket.userId!;
            logger.info(`WebSocket client connected: ${userId}`);

            // Increment connection metric
            websocketConnections.inc();

            // Join group meditation
            socket.on('join_group', async (groupId: string) => {
                try {
                    socket.join(groupId);

                    // Track group members
                    if (!this.groupSessions.has(groupId)) {
                        this.groupSessions.set(groupId, new Set());
                    }
                    this.groupSessions.get(groupId)!.add(userId);

                    // Get active sessions in group
                    const activeSessions = await meditationService.getActiveGroupSessions(groupId);

                    // Notify user of current group state
                    socket.emit('group_state', {
                        groupId,
                        activeMembers: this.groupSessions.get(groupId)!.size,
                        activeSessions: activeSessions.length,
                    });

                    // Notify others in group
                    socket.to(groupId).emit('member_joined', {
                        userId,
                        activeMembers: this.groupSessions.get(groupId)!.size,
                    });

                    websocketMessages.inc({ type: 'join_group' });
                    logger.info(`User ${userId} joined group ${groupId}`);
                } catch (error) {
                    logger.error('Error joining group:', error);
                    socket.emit('error', { message: 'Failed to join group' });
                }
            });

            // Leave group meditation
            socket.on('leave_group', (groupId: string) => {
                socket.leave(groupId);

                if (this.groupSessions.has(groupId)) {
                    this.groupSessions.get(groupId)!.delete(userId);
                    if (this.groupSessions.get(groupId)!.size === 0) {
                        this.groupSessions.delete(groupId);
                    }
                }

                socket.to(groupId).emit('member_left', {
                    userId,
                    activeMembers: this.groupSessions.get(groupId)?.size || 0,
                });

                websocketMessages.inc({ type: 'leave_group' });
                logger.info(`User ${userId} left group ${groupId}`);
            });

            // Start meditation in group
            socket.on('start_meditation', async (data: { groupId: string; type: string; duration: number }) => {
                try {
                    const session = await meditationService.startSession({
                        userId,
                        type: data.type as any,
                        duration: data.duration,
                        groupId: data.groupId,
                    });

                    // Broadcast to group
                    this.io.to(data.groupId).emit('meditation_started', {
                        userId,
                        sessionId: session.id,
                        type: session.type,
                        duration: session.planned_duration,
                        startedAt: session.started_at,
                    });

                    websocketMessages.inc({ type: 'start_meditation' });
                    logger.info(`User ${userId} started meditation in group ${data.groupId}`);
                } catch (error) {
                    logger.error('Error starting meditation:', error);
                    socket.emit('error', { message: 'Failed to start meditation' });
                }
            });

            // End meditation in group
            socket.on('end_meditation', async (data: { sessionId: string; actualDuration: number; completed: boolean }) => {
                try {
                    const session = await meditationService.endSession({
                        sessionId: data.sessionId,
                        userId,
                        actualDuration: data.actualDuration,
                        completed: data.completed,
                    });

                    // Broadcast to group
                    socket.broadcast.emit('meditation_ended', {
                        userId,
                        sessionId: session.id,
                        completed: session.completed,
                        duration: session.actual_duration,
                    });

                    websocketMessages.inc({ type: 'end_meditation' });
                    logger.info(`User ${userId} ended meditation ${data.sessionId}`);
                } catch (error) {
                    logger.error('Error ending meditation:', error);
                    socket.emit('error', { message: 'Failed to end meditation' });
                }
            });

            // Heartbeat to keep connection alive
            socket.on('ping', () => {
                socket.emit('pong');
            });

            // Handle disconnect
            socket.on('disconnect', () => {
                logger.info(`WebSocket client disconnected: ${userId}`);

                // Remove from all groups
                this.groupSessions.forEach((members, groupId) => {
                    if (members.has(userId)) {
                        members.delete(userId);
                        socket.to(groupId).emit('member_left', {
                            userId,
                            activeMembers: members.size,
                        });

                        if (members.size === 0) {
                            this.groupSessions.delete(groupId);
                        }
                    }
                });

                // Decrement connection metric
                websocketConnections.dec();
            });
        });
    }

    /**
     * Get active connections count
     */
    getActiveConnections(): number {
        return this.io.sockets.sockets.size;
    }

    /**
     * Get active group members count
     */
    getGroupMembersCount(groupId: string): number {
        return this.groupSessions.get(groupId)?.size || 0;
    }
}

