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
  }
};
