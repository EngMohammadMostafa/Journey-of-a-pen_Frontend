import api from './api';

export const quotesService = {
  // جلب جميع الاقتباسات
  getAllQuotes: async () => {
    try{
    const response = await api.get('/quotes');
    return response.data;
    }
    catch (error) {
      throw error;
    }
  },

  // حذف اقتباس
  deleteQuote: async (quoteId) => {
    const response = await api.delete(`/admin/quotes/${quoteId}`);
    return response.data;
  }
};