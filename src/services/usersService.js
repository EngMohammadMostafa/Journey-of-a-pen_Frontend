// src/services/usersService.js
import api from './api'; // ✅ سيستخدم baseURL تلقائياً + يضيف التوكن

export const usersService = {
  // الحصول على جميع المستخدمين
  getAllUsers: async () => {
    try {
      // ✅ لا حاجة لإضافة التوكن يدوياً - الـ interceptor يتكفل بذلك
      const response = await api.get('/admin/users');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // تحديث مستخدم
  updateUser: async (id, userData) => {
    try {
      // ✅ لا حاجة للتوكن أو headers
      const response = await api.put(`/admin/users/${id}`, userData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // حذف مستخدم
  deleteUser: async (id) => {
    try {
      // ✅ لا حاجة للتوكن أو headers
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
    const response = await api.get('/admin/request-books'); // ✅ جلب جميع طلبات الكتب مع التصنيفات
    return response.data; // يحتوي على { requests: [...], categories: [...] }
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
    return response.data; // { message: "...", book: { ... } }
  } catch (error) {
    throw error;
  }
},

// رفض طلب كتاب
rejectRequest: async (requestId) => {
  try {
    const response = await api.post(`/admin/request-books/${requestId}/reject`);
    return response.data; // { message: "تم رفض الطلب." }
  } catch (error) {
    throw error;
  }
},

  // TODO: إضافة مستخدم - سيتم إضافتها لاحقاً بعد الاتفاق على API
  // addUser: async (userData) => {
  //   try {
  //     const response = await api.post('/api/admin/users', userData);
  //     return response.data;
  //   } catch (error) {
  //     throw error;
  //   }
  // },

  // TODO: الحصول على مستخدم معين - سيتم إضافتها لاحقاً بعد الاتفاق على API
  // getUserById: async (id) => {
  //   try {
  //     const response = await api.get(`/api/admin/users/${id}`);
  //     return response.data;
  //   } catch (error) {
  //     throw error;
  //   }
  // }
};