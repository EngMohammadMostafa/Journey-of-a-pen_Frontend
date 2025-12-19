
import axios from 'axios'

const API_BASE_URL = 'http://localhost:8000/api'

export const authService = {
  login: async (email, password) => {
    try {


      const url = `${API_BASE_URL}/auth/login`;
      
      //const url = `http://localhost:8000/api/auth/login`;
      let lastError = null;

print
      const response = await axios.post(url, {
        email,
        password
      }, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      });

      console.log('استجابة تسجيل الدخول:', response.data);
      return response.data;
    } catch (error) {
      console.log('dddddddddddddddddddddddddddddddddd')
      console.error(' خطأ في تسجيل الدخول:', error);
    }

  
  },

  logout: async (token) => {
    try {
      const response = await axios.post(`${API_BASE_URL}/logout`, {}, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'حدث خطأ في الاتصال' };
    }
  }
};






