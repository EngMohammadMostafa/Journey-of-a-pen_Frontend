import React, { useState, useEffect } from 'react'
import DataTable from '../components/common/DataTable'
import Modal from '../components/common/Modal'
import { competitionsService } from '../services/competitionsService'
import { useAuth } from '../context/AuthContext'
import '../styles/global.css'
import '../styles/CompetitionsManagement.css'

const CompetitionsManagement = () => {
  const [competitions, setCompetitions] = useState([])
  const [loading, setLoading] = useState(false)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const { token } = useAuth()

  const [formData, setFormData] = useState({
    name: '',
    status: 'ongoing',
    start_date: '',
    end_date: '',
    max_users: ''
  })

  // أعمدة الجدول
  const columns = [
    { key: 'id', title: 'ID' },
    { key: 'name', title: 'اسم المسابقة' },
    { key: 'status', title: 'الحالة' },
    { key: 'start_date', title: 'تاريخ البداية' },
    { key: 'end_date', title: 'تاريخ النهاية' },
    { key: 'max_users', title: 'الحد الأقصى للمستخدمين' }
  ]

  // جلب المسابقات
  const fetchCompetitions = async () => {
    setLoading(true)
    try {
      const response = await competitionsService.getAllCompetitions(token)
      setCompetitions(response.competitions || [])
    } catch (error) {
      console.error('Error fetching competitions:', error)
      alert('حدث خطأ في جلب بيانات المسابقات')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchCompetitions()
  }, [])

  // فتح مودال إضافة مسابقة
  const handleAddCompetition = () => {
    setFormData({
      name: '',
      status: 'ongoing',
      start_date: '',
      end_date: '',
      max_users: ''
    })
    setIsModalOpen(true)
  }

  // حفظ مسابقة جديدة
  const handleSave = async () => {
    try {
      await competitionsService.addCompetition(formData, token)
      alert('تم إضافة المسابقة بنجاح')
      setIsModalOpen(false)
      setFormData({
        name: '',
        status: 'ongoing',
        start_date: '',
        end_date: '',
        max_users: ''
      })
      fetchCompetitions()
    } catch (error) {
      console.error('Error adding competition:', error)
      alert('حدث خطأ في إضافة المسابقة')
    }
  }

  return (
    <div className="competitions-management">
      <div className="page-header">
        <h1>إدارة المسابقات</h1>
        <button className="btn-primary" onClick={handleAddCompetition}>
          + إضافة مسابقة
        </button>
      </div>

      {/* جدول المسابقات */}
      <DataTable
        columns={columns}
        data={competitions}
        loading={loading}
        actions={[]} // لا يوجد تعديل أو حذف في هذه الدفعة
      />

      {/* مودال إضافة مسابقة */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title="إضافة مسابقة جديدة"
      >
        <div className="competition-form">
          <div className="form-group">
            <label>اسم المسابقة: *</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>الحالة:</label>
            <select
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
            >
              <option value="ongoing">جارية</option>
              <option value="active">نشطة</option>
              <option value="completed">منتهية</option>
            </select>
          </div>

          <div className="form-group">
            <label>تاريخ البداية:</label>
            <input
              type="date"
              value={formData.start_date}
              onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
            />
          </div>

          <div className="form-group">
            <label>تاريخ النهاية:</label>
            <input
              type="date"
              value={formData.end_date}
              onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
            />
          </div>

          <div className="form-group">
            <label>الحد الأقصى للمستخدمين:</label>
            <input
              type="number"
              value={formData.max_users}
              onChange={(e) => setFormData({ ...formData, max_users: e.target.value })}
              min="1"
            />
          </div>

          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>
              إلغاء
            </button>
            <button className="btn-primary" onClick={handleSave}>
              إضافة مسابقة
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}

export default CompetitionsManagement
