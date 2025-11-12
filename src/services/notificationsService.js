// src/services/notificationsService.js
import axios from 'axios'

const API_BASE_URL = '/api/admin' // قاعدة الـ API للادمن

// جلب جميع الإشعارات
const getAllNotifications = async (token) => {
  try {
    const response = await axios.get(`${API_BASE_URL}/notifications`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    // نعيد فقط بيانات الإشعارات أو مصفوفة فارغة
    return response.data || { notifications: [] }
  } catch (error) {
    console.error('Error fetching notifications:', error)
    throw error
  }
}

// إضافة إشعار جديد لجميع المستخدمين
const addNotification = async (data, token) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/notifications`, data, {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    return response.data
  } catch (error) {
    console.error('Error adding notification:', error)
    throw error
  }
}

export const notificationsService = {
  getAllNotifications,
  addNotification
}
