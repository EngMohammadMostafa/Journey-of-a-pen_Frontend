import api from './api';

export const quotesService = {
  // جلب جميع الاقتباسات
  getAllQuotes: async () => {
    const response = await api.get('/api/quotes');
    return response.data;
  },

  // حذف اقتباس
  deleteQuote: async (quoteId) => {
    const response = await api.delete(`/api/admin/quotes/${quoteId}`);
    return response.data;
  }
};