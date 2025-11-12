import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'

import { useAuth } from '../context/AuthContext'
import '../styles/global.css'
import '../styles/NotificationsManagement.css'

const NotificationsManagement = () => {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(false)
  const { token } = useAuth()

  const columns = [
    { key: 'notification_id', title: 'ID' },
    { key: 'title', title: 'عنوان الإشعار' },
    { key: 'content', title: 'المحتوى' },
    { key: 'type', title: 'النوع' },
    { key: 'status', title: 'الحالة', render: (value) => value === 0 ? 'نشط' : 'غير نشط' },
    { key: 'created_at', title: 'تاريخ الإنشاء' }
  ]

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

  // زر فتح إضافة إشعار
  const handleAddNotification = () => {
    alert('زر إضافة إشعار جديد جاهز، سيتم إضافة المودال لاحقاً')
  }

  return (
    <div className="notifications-management">
      <div className="page-header">
        <h1>إدارة الإشعارات</h1>
        <button className="btn-primary" onClick={handleAddNotification}>
          + إضافة إشعار جديد
        </button>
      </div>

      <DataTable
        columns={columns}
        data={notifications}
        loading={loading}
        actions={[]}
      />
    </div>
  )
}

export default NotificationsManagement
