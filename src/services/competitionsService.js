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
},
// حذف كتاب مشارك من مسابقة (Admin)
deleteCompetitionBook: async (competition_book_id, token) => {
  try {
    const response = await api.delete(`/admin/competition-books/${competition_book_id}`, {
      headers: {
        Authorization: `Bearer ${token}`,
      }
    });
    return response.data; // { message: "Competition book deleted successfully", deleted_book_id: ... }
  } catch (error) {
    throw error;
  }
},


// قبول أو رفض كتاب مشارك في مسابقة (Admin)
approveOrRejectBook: async (competition_book_id, data, token) => {
  try {
    const response = await api.post(
      `/admin/competition-books/${competition_book_id}/approve-or-reject`,
      data, // { status: 'accepted' | 'rejected' }
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );
    return response.data;
  } catch (error) {
    throw error;
  }
},
// تحميل كتاب مسابقة (Admin أو حسب الصلاحية)
downloadCompetitionBook: async (competitionbookid, token) => {
  const response = await api.get(
    `/competition-books/${competitionbookid}/download`, // هنا {id} = competitionBookId
    {
      responseType: 'blob',
      headers: { Authorization: `Bearer ${token}` },
    }
  );
  return response.data;
},


// جلب عدد اللايكات ومعلومات المستخدمين الذين أعجبوا بالكتاب (Admin)
getBookLikes: async (bookId, token) => {
  try {
    const response = await api.get(`/admin/competition-books/${bookId}/likes`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
    return response.data; // سترجع { book_id, title, likes_count, liked_users: [...] }
  } catch (error) {
    throw error;
  }
},

// إضافة كتاب من مسابقة إلى المنصة (Admin)
addCompetitionBookToPlatform: async (competitionBookId, data, token) => {
  try {
    const response = await api.post(
      `/admin/competition-books/${competitionBookId}/add-to-platform`,
      data,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );
    return response.data;
  } catch (error) {
    throw error;
  }
},
getAllCategories: async () => {
  try {
    const response = await api.get('/categories');
    // Backend returns: { success: true, data: [...] }
    return response.data.data || [];
  } catch (error) {
    throw error;
  }
},




};
