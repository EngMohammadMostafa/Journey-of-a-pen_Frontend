// src/services/usersService.js
import api from './api'; 

export const usersService = {
  // الحصول على جميع المستخدمين
  getAllUsers: async () => {
    try {
      const response = await api.get('/admin/users');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // تحديث مستخدم
  updateUser: async (id, userData) => {
    try {
      const response = await api.put(`/admin/users/${id}`, userData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // حذف مستخدم
  deleteUser: async (id) => {
    try {
      const response = await api.delete(`/admin/users/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // إضافة مستخدم جديد (عندما تصبح جاهزة)
  addUser: async (userData) => {
    try {
      const response = await api.post('/admin/users', userData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  // --- طلبات الكتب (عرض فقط) ---
getAllRequests: async () => {
  try {
    const response = await api.get('/admin/request-books'); 
    return response.data; 
  } catch (error) {
    throw error;
  }
},

// قبول طلب كتاب
acceptRequest: async (requestId, category_id) => {
  try {
    const response = await api.post(`/admin/request-books/${requestId}/accept`, {
      category_id
    });
    return response.data; 
  } catch (error) {
    throw error;
  }
},

// رفض طلب كتاب
rejectRequest: async (requestId) => {
  try {
    const response = await api.post(`/admin/request-books/${requestId}/reject`);
    return response.data; 
  } catch (error) {
    throw error;
  }
},


 //  تحميل ملف الطلب (للأدمن)
downloadRequestFile: async (requestId) => {
  const response = await api.get(
    `/admin/request-books/${requestId}/download`,
    {
      responseType: 'blob', 
    }
  );
  return response;
},

};