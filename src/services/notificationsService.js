import axios from 'axios'

const API_BASE_URL = 'http://localhost:8000/api'

export const notificationsService = {

  //  إضافة إشعار (Admin فقط)
  addNotification: async (data, token) => {
    try {
      const response = await axios.post(
        `${API_BASE_URL}/admin/notifications`,
        data,
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          }
        }
      )

      return response.data
    } catch (error) {
      console.error('خطأ أثناء إضافة الإشعار:', error)
      throw error.response?.data || { message: 'حدث خطأ أثناء إضافة الإشعار' }
    }
  },

  getAllNotifications: async (token) => {
    try {
      const response = await axios.get(
        'http://localhost:8000/api/notifications',
        {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Accept': 'application/json'
          }
        }
      )
  
      return response.data
    } catch (error) {
      throw error.response?.data || { message: 'حدث خطأ أثناء جلب الإشعارات' }
    }
  }
  

}
