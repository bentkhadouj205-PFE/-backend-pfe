import { useState, useEffect, useCallback } from 'react';
import { toast } from 'sonner';
import { API_BASE_URL } from '@/lib/apiBase';

export interface Request {
  _id: string;
  citizen: {
    firstName: string;
    lastName: string;
    email: string;
    nin: string;
    phone: string;
    address: string;
    wilaya?: string;
    commune?: string;
    actYear?: string;
    actNumber?: string;
  };
  subject: string;
  description: string;
  status: 'pending' | 'in-progress' | 'completed' | 'rejected';
  documentStatus: string;
  serviceType: string;
  createdAt: string;
  assignedTo: string;
}

export function useRealRequests(employeeId: string) {
  const [requests, setRequests] = useState<Request[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchRequests = useCallback(async () => {
    if (!employeeId) {
      setRequests([]);
      setLoading(false);
      return;
    }
    
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/requests/my-requests/${employeeId}`);
      const data = await response.json();
      
      if (response.ok) {
        const transformedRequests = data.requests?.map((req: any) => {
          const st = req.status === 'in_progress' ? 'in-progress' : req.status;
          return {
            id: req._id,
            _id: req._id,
            citizen: req.citizen,
            subject: req.subject,
            description: req.description,
            status: st,
            documentStatus:
              req.documentStatus === 'valid'
                ? 'verified'
                : req.documentStatus === 'missing'
                  ? 'missing'
                  : req.documentStatus || 'pending',
            serviceType: req.serviceType || req.subject,
            createdAt: req.createdAt,
            assignedTo: req.assignedTo,
            title: req.subject,
            requestType: req.serviceType || req.subject,
          };
        }) || [];
        
        setRequests(transformedRequests);
      }
    } catch (error) {
      toast.error('Erreur de connexion au serveur');
    } finally {
      setLoading(false);
    }
  }, [employeeId]);

  useEffect(() => {
    fetchRequests();
  }, [fetchRequests]);

  const getTasksByEmployee = (id: string) => requests.filter(r => r.assignedTo === id);

  return {
    requests,
    loading,
    fetchRequests,
    getTasksByEmployee,
  };
}

export default useRealRequests;