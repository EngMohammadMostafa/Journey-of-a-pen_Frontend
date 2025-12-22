// src/services/booksService.js
import api from './api'; 

export const booksService = {

  // ============================================================
  //  الأقسام (Categories)
  // ============================================================


// جلب كل الأقسام
getAllCategories: async () => {
  try {
    const response = await api.get('/categories');

    // Backend returns: { success: true, data: [...] }
    return response.data.data || [];
  } catch (error) {
    throw error;
  }
},

  // جلب قسم واحد
  getCategoryById: async (categoryId) => {
    try {
      const response = await api.get(`/categories/${categoryId}`);
      return response.data; // { success:true, category:{...} }
    } catch (error) {
      throw error;
    }
  },

  // إنشاء قسم جديد (Admin)
  addCategory: async (categoryData) => {
    try {
      const response = await api.post('/admin/categories', categoryData);
      return response.data; // { success:true, category:{...} }
    } catch (error) {
      throw error;
    }
  },
  // حذف قسم (Admin)
deleteCategory: async (categoryId) => {
  try {
    const response = await api.delete(`/admin/categories/${categoryId}`);
    return response.data;
  } catch (error) {
    throw error;
  }},

  // ============================================================
  // 🟦 الكتب (Books)
  // ============================================================

  // جلب كل الكتب
  getAllBooks: async () => {
    try {
      const response = await api.get('/books');
      return response.data; // { success:true, books:[...] }
    } catch (error) {
      throw error;
    }
  },

  // جلب الكتب حسب قسم
  getBooksByCategory: async (categoryId) => {
    try {
      const response = await api.get(`/categories/${categoryId}/books`);
      return response.data; // { success:true, books:[...] }
    } catch (error) {
      throw error;
    }
  },

  // جلب كتاب واحد بالتفاصيل
  getBookById: async (bookId) => {
    try {
      const response = await api.get(`/books/${bookId}`);
      return response.data; // { success:true, book:{...} }
    } catch (error) {
      throw error;
    }
  },


  // إضافة كتاب داخل قسم (Admin)

  addBookToCategory: async (categoryId, bookData) => {
    try {
      const response = await api.post(
        `/admin/categories/${categoryId}/books`,
        bookData,
        {
          headers: {
            "Content-Type": "multipart/form-data"
          }
        }
      );
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  
  // تعديل كتاب (Admin)
  updateBook: async (bookId, bookData) => {
    try {
      const response = await api.put(`/admin/books/${bookId}`, bookData);
      return response.data; // { success:true, book:{...} }
    } catch (error) {
      throw error;
    }
  },

  // حذف كتاب (Admin)
  deleteBook: async (bookId) => {
    try {
      const response = await api.delete(`/admin/books/${bookId}`);
      return response.data; // { success:true }
    } catch (error) {
      throw error;
    }
  },

  // تحميل كتاب للمستخدم
  downloadBook: async (bookId) => {
    try {
      const response = await api.post(`/books/${bookId}/download`);
      return response.data; // { success:true, download_url:"..." }
    } catch (error) {
      throw error;
    }
  },

  // جلب الكتب المملوكة للمستخدم
  getMyBooks: async () => {
    try {
      const response = await api.get('/me/books');
      return response.data; // { success:true, books:[...] }
    } catch (error) {
      throw error;
    }
  },
// جلب عدد الكتب الكلي
getTotalBooks: async () => {
  try {
    const response = await api.get('/admin/stats/total-books');
    return response.data; // ← سيحتوي على { total_books: 25 }
  } catch (error) {
    throw error;
  }
},

  // ============================================================
  // 🟦 الأسئلة (Questions)
  // ============================================================

  
  // إضافة سؤال لكتاب (Admin)
  addQuestion: async (bookId, questionText) => {
    try {
      const response = await api.post(`/admin/books/${bookId}/questions`, {
        question_text: questionText,
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // تعديل سؤال
  updateQuestion: async (questionId, questionText) => {
    try {
      const response = await api.put(`/admin/questions/${questionId}`, {
        question_text: questionText,
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // حذف سؤال
  deleteQuestion: async (questionId) => {
    try {
      const response = await api.delete(`/admin/questions/${questionId}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  getPaginatedQuestions: async (page = 1, perPage = 10) => {
    try {
      const response = await api.get(`/admin/questions?page=${page}&per_page=${perPage}`);
      
      return {
        list: response.data.data.data,      // ← قائمة الأسئلة
        current_page: response.data.data.current_page,
        last_page: response.data.data.last_page,
        total: response.data.data.total
      };
    } catch (error) {
      throw error;
    }
  },
  // جلب كل الأسئلة لكتاب معيّن (بدون إجابات)
getQuestionsByBook: async (bookId) => {
  try {
    const response = await api.get(`/admin/books/${bookId}/questions`);
    // الباكند يرسل: { success: true, book: {...}, questions: [...] }
    return response.data;
  } catch (error) {
    throw error;
  }
},

  // جلب سؤال واحد مع جميع الإجابات
getQuestionWithAnswers: async (questionId) => {
  try {
    const response = await api.get(`/admin/questions/${questionId}`);
    return response.data; // ← سيحتوي على question + answers
  } catch (error) {
    throw error;
  }
},

  // ============================================================
  // 🟦 الإجابات (Answers)
  // ============================================================

  // إضافة جواب
  addAnswer: async (questionId, answerData) => {
    try {
      const response = await api.post(`/admin/questions/${questionId}/answers`, answerData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // تعديل جواب
  updateAnswer: async (answerId, answerData) => {
    try {
      const response = await api.put(`/admin/answers/${answerId}`, answerData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },


  // حذف جواب
  deleteAnswer: async (answerId) => {
    try {
      const response = await api.delete(`/admin/answers/${answerId}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  
 // داخل booksService
    getPaginatedAnswers: async (page = 1, perPage = 10) => {
  try {
    const response = await api.get('/admin/answers', {
      params: { page, per_page: perPage }  // ← مهم: params هنا
    });
    return response.data; // ← هذا يعيد data و meta من الباكند
  } catch (error) {
    throw error;
  }
},


};


