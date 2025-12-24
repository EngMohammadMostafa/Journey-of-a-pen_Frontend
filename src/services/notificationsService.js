import axios from 'axios'

const API_BASE_URL = 'http://localhost:8000/api'

export const notificationsService = {

  // إضافة إشعار
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
      throw error.response?.data || { message: 'حدث خطأ أثناء إضافة الإشعار' }
    }
  },

  // عرض الإشعارات
  getAllNotifications: async (token) => {
    try {
      const response = await axios.get(
        `${API_BASE_URL}/notifications`,
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
  },

  // حذف إشعار (Admin فقط)
  deleteNotification: async (id, token) => {
    const response = await axios.delete(`${API_BASE_URL}/admin/notifications/${id}`, { // ← هنا التغيير
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
      }
    })
    return response.data
  }
  
  
}
