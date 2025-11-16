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
  const [editingCompetition, setEditingCompetition] = useState(null)
  const [showCompetitionsTable, setShowCompetitionsTable] = useState(false) // لإظهار جدول المسابقات
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

// إحصائيات المسابقات
const competitionStats = {
  total: competitions.length,
  completed: competitions.filter(c => c.status === 'completed').length,
  stopped: competitions.filter(c => {
    const ended = new Date(c.end_date) < new Date();
    return ended && c.status !== 'completed';
  }).length
};



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
    if (showCompetitionsTable) {
      fetchCompetitions()
    }
  }, [showCompetitionsTable])

  // فتح مودال الإضافة
  const handleAddCompetition = () => {
    setEditingCompetition(null)
    setFormData({
      name: '',
      status: 'ongoing',
      start_date: '',
      end_date: '',
      max_users: ''
    })
    setIsModalOpen(true)
  }

  // فتح مودال التعديل
  const handleEdit = (competition) => {
    setEditingCompetition(competition)
    setFormData({
      name: competition.name || '',
      status: competition.status || 'ongoing',
      start_date: competition.start_date || '',
      end_date: competition.end_date || '',
      max_users: competition.max_users || ''
    })
    setIsModalOpen(true)
  }

  // حفظ الإضافة أو التعديل
  const handleSave = async () => {
    try {
      if (editingCompetition) {
        await competitionsService.updateCompetition(editingCompetition.id, formData, token)
        alert('تم تعديل المسابقة بنجاح')
      } else {
        await competitionsService.addCompetition(formData, token)
        alert('تم إضافة المسابقة بنجاح')
      }
      setIsModalOpen(false)
      setEditingCompetition(null)
      setFormData({
        name: '',
        status: 'ongoing',
        start_date: '',
        end_date: '',
        max_users: ''
      })
      fetchCompetitions()
    } catch (error) {
      console.error('Error saving competition:', error)
      alert('حدث خطأ في حفظ البيانات')
    }
  }

  // حذف مسابقة
  const handleDelete = async (competition) => {
    if (window.confirm(`هل أنت متأكد من حذف المسابقة "${competition.name}"؟`)) {
      try {
        await competitionsService.deleteCompetition(competition.id, token)
        alert('تم حذف المسابقة بنجاح')
        fetchCompetitions()
      } catch (error) {
        console.error('Error deleting competition:', error)
        alert('حدث خطأ في حذف المسابقة')
      }
    }
  }

  const modalTitle = editingCompetition ? 'تعديل المسابقة' : 'إضافة مسابقة جديدة'

  return (

    <div className="competitions-management">


      <div className="page-header">
  <h1>لوحة الإدارة</h1>

  {/* زر إضافة مسابقة يظهر فقط في حالة عرض قسم المسابقات */}
  {showCompetitionsTable && (
    <button
      className="btn-primary add-book-btn"
      onClick={handleAddCompetition}
    >
      + إضافة مسابقة
    </button>
  )}
</div>

      <div className="buttons-container">
  <button
    className={`btn ${showCompetitionsTable ? 'btn-primary' : 'btn-outline'}`}
    onClick={() => setShowCompetitionsTable(true)}
  >
    إدارة المسابقات
  </button>

  <button
    className={`btn ${!showCompetitionsTable ? 'btn-primary' : 'btn-outline'}`}
    onClick={() => setShowCompetitionsTable(false)}
  >
    إدارة المشاركين والكتب
  </button>
</div>

      {showCompetitionsTable && (
        <>
          <div className="user-stats">
  <div className="stat-card">
    <h3>إجمالي عدد المسابقات</h3>
    <span className="stat-number">{competitionStats.total}</span>
  </div>

  <div className="stat-card">
    <h3>عدد المسابقات المكتملة</h3>
    <span className="stat-number">{competitionStats.completed}</span>
  </div>

  <div className="stat-card">
    <h3>عدد المسابقات المتوقفة / غير المكتملة</h3>
    <span className="stat-number">{competitionStats.stopped}</span>
  </div>
</div>


          {/* جدول المسابقات */}
          <DataTable
            columns={columns}
            data={competitions}
            loading={loading}
            onEdit={handleEdit}
            onDelete={handleDelete}
            actions={['edit', 'delete']}
          />

          {/* مودال إضافة/تعديل مسابقة */}
          <Modal
            isOpen={isModalOpen}
            onClose={() => {
              setIsModalOpen(false)
              setEditingCompetition(null)
            }}
            title={modalTitle}
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
                  {editingCompetition ? 'حفظ التغييرات' : 'إضافة مسابقة'}
                </button>
              </div>
            </div>
          </Modal>
        </>
      )}
    </div>
  )
}

export default CompetitionsManagement
