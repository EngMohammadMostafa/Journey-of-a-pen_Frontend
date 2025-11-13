// src/services/booksService.js
import api from './api'; // ✅ سيستخدم baseURL تلقائياً + يضيف التوكن

export const booksService = {

  
  // --- خدمات الكتب ---
 

  // الحصول على جميع الكتب
  getAllBooks: async () => {
    try {
      const response = await api.get('/admin/books');
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
  },

 
  // --- خدمات الأسئلة والأجوبة ---


  // إضافة سؤال لكتاب (Admin)
  addQuestion: async (bookId, questionText) => {
    try {
      const response = await api.post(`/books/${bookId}/questions`, { text: questionText });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // تعديل سؤال (Admin)
  updateQuestion: async (questionId, questionText) => {
    try {
      const response = await api.put(`/questions/${questionId}`, { text: questionText });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // حذف سؤال (Admin)
  deleteQuestion: async (questionId) => {
    try {
      const response = await api.delete(`/questions/${questionId}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // إضافة إجابة على سؤال
  addAnswer: async (questionId, answerText) => {
    try {
      const response = await api.post(`/questions/${questionId}/answers`, { answer: answerText });
      return response.data;
    } catch (error) {
      throw error;
    }
  }

};
