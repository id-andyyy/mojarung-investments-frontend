import { API_BASE_URL } from './config';

interface FetchOptions extends RequestInit {
    params?: Record<string, string>;
}

class ApiError extends Error {
    constructor(public status: number, message: string) {
        super(message);
        this.name = 'ApiError';
    }
}

async function handleResponse<T>(response: Response): Promise<T> {
    if (!response.ok) {
        const error = await response.json().catch(() => ({ message: 'An error occurred' }));
        throw new ApiError(response.status, error.message);
    }
    return response.json();
}

export async function fetchApi<T>(
    endpoint: string,
    options: FetchOptions = {}
): Promise<T> {
    const { params, ...fetchOptions } = options;
    
    let url = `${API_BASE_URL}${endpoint}`;
    
    if (params) {
        const searchParams = new URLSearchParams(params);
        url += `?${searchParams.toString()}`;
    }

    const response = await fetch(url, {
        ...fetchOptions,
        headers: {
            'Content-Type': 'application/json',
            ...fetchOptions.headers,
        },
    });

    return handleResponse<T>(response);
}

// Методы для работы с API
export const api = {
    get: <T>(endpoint: string, options?: FetchOptions) => 
        fetchApi<T>(endpoint, { ...options, method: 'GET' }),
    
    post: <T>(endpoint: string, data?: unknown, options?: FetchOptions) =>
        fetchApi<T>(endpoint, {
            ...options,
            method: 'POST',
            body: data ? JSON.stringify(data) : undefined,
        }),
    
    put: <T>(endpoint: string, data?: unknown, options?: FetchOptions) =>
        fetchApi<T>(endpoint, {
            ...options,
            method: 'PUT',
            body: data ? JSON.stringify(data) : undefined,
        }),
    
    delete: <T>(endpoint: string, options?: FetchOptions) =>
        fetchApi<T>(endpoint, { ...options, method: 'DELETE' }),
};