import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'
import { notificationsService } from '../services/notificationsService'
import { useAuth } from '../context/AuthContext'
import '../styles/global.css'
import '../styles/NotificationsManagement.css'

const NotificationsManagement = () => {
  const [notifications, setNotifications] = useState([])
  const [loading, setLoading] = useState(false)
  const [isModalOpen, setIsModalOpen] = useState(false)

  // البحث عن إشعار الفلترة
const [searchTerm, setSearchTerm] = useState('')
const [filteredNotifications, setFilteredNotifications] = useState([])

  const [formData, setFormData] = useState({
    title: '',
    content: '',
  })
  const { token } = useAuth()


 //  إحصائيات الإشعارات
const notificationStats = {
  total: notifications.length,
  
}


const columns = [
  { key: 'notification_id', title: 'ID' },
  { key: 'title', title: 'Notification Title' },
  { key: 'content', title: 'Content' },
  { key: 'created_at', title: 'Created At' },
   // عمود زر الحذف
   {
    key: 'actions',
    title: 'Actions',
    render: (_, notification) => (
      <button
        className="btn-danger"
        onClick={() => handleDeleteNotification(notification)}
      >
        Delete
      </button>
    )
  }
  
]


  const fetchNotifications = async () => {
    setLoading(true)
    try {
      const response = await notificationsService.getAllNotifications(token)

      setNotifications(response)
      setFilteredNotifications(response)
      
    } catch (error) {
      console.error('Error fetching notifications:', error)
      alert('An error occurred while fetching notification data   ')
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteNotification = async (notification) => {
    console.log('Delete Notification:', notification)
    const confirmDelete = window.confirm('Are you sure you want to delete this notification?  ')
    if (!confirmDelete) return
  
    try {
      const response = await notificationsService.deleteNotification(notification.notification_id, token)
      console.log('Response:', response)
      alert(response.message || 'The notification has been successfully deleted')
      fetchNotifications()
    } catch (error) {
      console.error(error)
      alert(error.message || ' An error occurred while deleting')
    }
  }
  
//لجلب الاشعارات من الباك
  useEffect(() => {
    fetchNotifications()
  }, [])

//للفلتره عن اعشار معين
  useEffect(() => {
    let filtered = notifications
    if (searchTerm) {
      filtered = filtered.filter(n =>
        n.title?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }
    setFilteredNotifications(filtered)
  }, [searchTerm, notifications])
  
  const handleAddNotification = () => {
    setFormData({
      title: '',
      content: '',
    })
    setIsModalOpen(true)
  }

  const handleSendNotification = async () => {
    if (!formData.title || !formData.content) {
      alert('Please Fill In All Required Fields')
      return
    }

    try {
      await notificationsService.addNotification(
        {
          title: formData.title,
          content: formData.content
        },
        token
      )
            alert('The Notification Was Sent Successfully ')
      setIsModalOpen(false)
      fetchNotifications()
    } catch (error) {
      console.error('Error sending notification:', error)
      alert('An Error Occurred While Sending The Notification ')
    }
  }

  
  
  return (
    <div className="notifications-management">
      <div className="page-header">
        <h1>Notifications Management </h1>
        <button className="btn-primary" onClick={handleAddNotification}>
          +  Add New Notification
        </button>
      </div>


{/*  أزرار الإحصائيات */}
<div className="notification-stats">
  <div className="stat-card">
    <h3> Total  Number Of Notification</h3>
    <span className="stat-number">{notificationStats.total}</span>
  </div>
  
</div>


{/* شريط البحث */}
<div className="notifications-filters">
  <div className="notification-search-section">
    <input
      type="text"
      placeholder="Search For A Notification ..."
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      className="notification-search-input"
    />
  </div>
</div>



      <DataTable
        columns={columns}
        data={filteredNotifications} 
        loading={loading}
      />

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title=" Add New Notification"
      >
        <div className="notification-form">
          <div className="form-group">
            <label>Notification Title *</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>The Content *</label>
            <textarea
              value={formData.content}
              onChange={(e) => setFormData({ ...formData, content: e.target.value })}
              required
            />
          </div>

          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </button>
            <button className="btn-primary" onClick={handleSendNotification}>
              Add Notification
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}

export default NotificationsManagement  