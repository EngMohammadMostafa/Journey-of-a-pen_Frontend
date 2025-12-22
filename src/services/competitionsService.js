// src/services/competitionsService.js
import api from './api'; // نفس api المستخدم في usersService

export const competitionsService = {
  // إنشاء مسابقة جديدة فقط
  addCompetition: async (competitionData) => {
    try {
      const response = await api.post('/admin/competitions', competitionData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  getAllCompetitions: async () => {
    try {
      const response = await api.get('/admin/competitions');
      return response.data; // { success: true, competitions: [...] }
    } catch (error) {
      throw error;
    }
  },
  updateCompetition: async (id, competitionData) => {
    try {
      const response = await api.put(`/admin/competitions/${id}`, competitionData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

// حذف مسابقة
deleteCompetition: async (id) => {
  try {
    const response = await api.delete(`/admin/competitions/${id}`);
    return response.data; // { message: "تم الحذف" }
  } catch (error) {
    throw error;
  }
},

// جلب تفاصيل مسابقة كاملة (المسابقة + الكتب + المشاركين + اللايكات)
getCompetitionDetails: async (competitionId, token) => {
  try {
    const response = await api.get(`/admin/competitions/${competitionId}/details`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    return response.data; // سترجع { competition: {...}, books: [...] }
  } catch (error) {
    throw error;
  }
},
// جلب العدد الكلي للمسابقات
getTotalCompetitions: async (token) => {
  try {
    const response = await api.get('/admin/stats/total-competitions', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    return response.data; // { total_competitions: 10 }
  } catch (error) {
    throw error;
  }
}





};
