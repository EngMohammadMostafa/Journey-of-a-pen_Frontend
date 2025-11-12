import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'

import { useAuth } from '../context/AuthContext'
import '../styles/global.css'
import '../styles/NotificationsManagement.css'

const NotificationsManagement = () => {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(false)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    type: 'competition',
    status: 0
  })
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

  const handleAddNotification = () => {
    setFormData({
      title: '',
      content: '',
      type: 'competition',
      status: 0
    })
    setIsModalOpen(true)
  }

  const handleSendNotification = async () => {
    if (!formData.title || !formData.content) {
      alert('الرجاء ملء جميع الحقول المطلوبة')
      return
    }

    try {
      await notificationsService.addNotification(formData, token)
      alert('تم إرسال الإشعار بنجاح')
      setIsModalOpen(false)
      fetchNotifications()
    } catch (error) {
      console.error('Error sending notification:', error)
      alert('حدث خطأ أثناء إرسال الإشعار')
    }
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

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="إضافة إشعار جديد"
      >
        <div className="notification-form">
          <div className="form-group">
            <label>عنوان الإشعار: *</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>المحتوى: *</label>
            <textarea
              value={formData.content}
              onChange={(e) => setFormData({ ...formData, content: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>النوع:</label>
            <select
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
            >
              <option value="competition">مسابقة</option>
              <option value="general">عام</option>
            </select>
          </div>

          <div className="form-group">
            <label>الحالة:</label>
            <select
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: parseInt(e.target.value) })}
            >
              <option value={0}>نشط</option>
              <option value={1}>غير نشط</option>
            </select>
          </div>

          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>
              إلغاء
            </button>
            <button className="btn-primary" onClick={handleSendNotification}>
              إرسال
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}

export default NotificationsManagement
