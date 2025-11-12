import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'

import { useAuth } from '../context/AuthContext'
import '../styles/global.css'
import '../styles/NotificationsManagement.css'

const NotificationsManagement = () => {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(false)
  const { token } = useAuth()

  // أعمدة الجدول
  const columns = [
    { key: 'notification_id', title: 'ID' },
    { key: 'title', title: 'عنوان الإشعار' },
    { key: 'content', title: 'المحتوى' },
    { key: 'type', title: 'النوع' },
    { key: 'status', title: 'الحالة', render: (value) => value === 0 ? 'نشط' : 'غير نشط' },
    { key: 'created_at', title: 'تاريخ الإنشاء' }
  ]

  // جلب جميع الإشعارات من الباك
  const fetchNotifications = async () => {
    setLoading(true)
    try {
      const response = await notificationsService.getAllNotifications(token)
      setNotifications(response.notifications || [])
    } catch (error) {
      console.error('Error fetching notifications:', error)
      alert('حدث خطأ في جلب بيانات الإشعارات')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchNotifications()
  }, [])

  return (
    <div className="notifications-management">
      <div className="page-header">
        <h1>إدارة الإشعارات</h1>
      </div>

      {/* جدول الإشعارات */}
      <DataTable
        columns={columns}
        data={notifications}
        loading={loading}
        actions={[]} // لا يوجد تعديل أو حذف
      />
    </div>
  )
}

export default NotificationsManagement
