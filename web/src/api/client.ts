import { API_BASE_URL } from '@/lib/apiBase';

// Generic fetch function with error handling
async function fetchAPI(endpoint: string, options: RequestInit = {}) {
  const url = `${API_BASE_URL}${endpoint}`;
  
  const config = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  };

  try {
    const response = await fetch(url, config);
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.message || 'API Error');
    }
    
    return data;
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
}

// API Functions
export const api = {
  // Requests
  requests: {
    // Get all requests for an employee
    getMyRequests: (employeeId: string) =>
      fetchAPI(`/requests/my-requests/${employeeId}`),
    
    // Get single request details (for modal)
    getRequestDetails: (requestId: string) =>
      fetchAPI(`/requests/request/${requestId}`),
    
    // Validate request with PDF
    validateWithPDF: (requestId: string, data: {
      status: 'completed' | 'rejected';
      documentStatus: string;
      comment?: string;
      employeeId: string;
    }) => fetchAPI(`/requests/validate-with-pdf/${requestId}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
    
    // Download PDF - returns URL string directly
    downloadPDF: (requestId: string) =>
      `${API_BASE_URL}/requests/download-pdf/${requestId}`,
    
    // Submit new request (citizen)
    submit: (data: any) =>
      fetchAPI('/requests/submit', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
  },
  
  // Employees
  employees: {
    login: (email: string, password: string) =>
      fetchAPI('/requests/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      }),
    
    getAll: () =>
      fetchAPI('/employees'),
  },
};

export default api;