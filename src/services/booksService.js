// src/services/booksService.js
import api from './api'; // ✅ سيستخدم baseURL تلقائياً + يضيف التوكن

export const booksService = {
  
  // الحصول على جميع الكتب
  getAllBooks: async () => {
    try {
      const response = await api.get('/admin/books'); // افترضنا أن المسار هو /admin/books
      return response.data; // { books: [...] }
    } catch (error) {
      throw error;
    }
  },

  // إضافة كتاب جديد
  addBook: async (bookData) => {
    try {
      const response = await api.post('/admin/books', bookData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // تعديل كتاب موجود
  updateBook: async (bookId, bookData) => {
    try {
      const response = await api.put(`/admin/books/${bookId}`, bookData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // حذف كتاب
  deleteBook: async (bookId) => {
    try {
      const response = await api.delete(`/admin/books/${bookId}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  }

};
