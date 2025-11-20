export interface PaginationParams {
    page: number;
    limit: number;
}

export interface PaginatedResponse<T> {
    data: T[];
    pagination: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
        hasNext: boolean;
        hasPrev: boolean;
    };
}

export const getPaginationParams = (req: any): PaginationParams => {
    const page = parseInt(req.query.page || '1');
    const limit = parseInt(req.query.limit || '20');

    return {
        page: Math.max(1, page),
        limit: Math.min(100, Math.max(1, limit)), // Max 100 items per page
    };
};

export const createPaginatedResponse = <T>(
    data: T[],
    total: number,
    page: number,
    limit: number
): PaginatedResponse<T> => {
    const totalPages = Math.ceil(total / limit);

    return {
        data,
        pagination: {
            page,
            limit,
            total,
            totalPages,
            hasNext: page < totalPages,
            hasPrev: page > 1,
        },
    };
};

export const getOffset = (page: number, limit: number): number => {
    return (page - 1) * limit;
};

