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

  //عن مسابقه معينه البحث
const [searchTerm, setSearchTerm] = useState('');
const [filteredCompetitions, setFilteredCompetitions] = useState([]);
 //تكمله م قبل البحث
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
    { key: 'name', title: 'Competition Name' },
    { key: 'status', title: 'Status' },
    { key: 'start_date', title: 'Start Date' },
    { key: 'end_date', title: 'End Date' },
    { key: 'max_users', title: 'Max Users ' }
  ]

// إحصائيات المسابقات
const competitionStats = {
  total: competitions.length
};

  // جلب المسابقات
  const fetchCompetitions = async () => {
    setLoading(true)
    try {
      const response = await competitionsService.getAllCompetitions(token)
      setCompetitions(response.competitions || [])
      setFilteredCompetitions(response.competitions || [])  // ←  هذا السطر المهم للبحث عن مسباقة معينه

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


  // فلترة حسب اسم المسابقة
useEffect(() => {
  let filtered = competitions;

  if (searchTerm) {
    filtered = filtered.filter(c =>
      c.name?.toLowerCase().includes(searchTerm.toLowerCase())
    );
  }

  setFilteredCompetitions(filtered);
}, [searchTerm, competitions]);


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

  const modalTitle = editingCompetition ? 'تعديل المسابقة' : 'Add New Competation  '

  return (

    <div className="competitions-management">


      <div className="page-header">
  <h1>Competitions Management</h1>

  {/* زر إضافة مسابقة يظهر فقط في حالة عرض قسم المسابقات */}
  {showCompetitionsTable && (
    <button
      className="btn-primary add-book-btn"
      onClick={handleAddCompetition}
    >
      + Add New Competitions
    </button>
  )}
</div>

      <div className="buttons-container">
  <button
    className={`btn ${showCompetitionsTable ? 'btn-primary' : 'btn-outline'}`}
    onClick={() => setShowCompetitionsTable(true)}
  >
    Competitions Management
  </button>

  <button
    className={`btn ${!showCompetitionsTable ? 'btn-primary' : 'btn-outline'}`}
    onClick={() => setShowCompetitionsTable(false)}
  >
    Pareicipant & Book Managemnt
  </button>
</div>

      {showCompetitionsTable && (
        <>
          <div className="user-stats">
  <div className="stat-card">
    <h3>Total Number Of Competitions</h3>
    <span className="stat-number">{competitionStats.total}</span>
  </div>
</div>


{/* شريط البحث */}
<div className="competitions-filters">
  <div className="competition-search-section">
    <input
      type="text"
      placeholder="Search For A Competition..."
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      className="competition-search-input"
    />
  </div>
</div>



          {/* جدول المسابقات */}
          <DataTable
            columns={columns}
            data={filteredCompetitions}

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
                <label> :Competition Name *</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  required
                />
              </div>

              <div className="form-group">
                <label>Statu:</label>
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
                <label>Start Date:</label>
                <input
                  type="date"
                  value={formData.start_date}
                  onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>End Date :</label>
                <input
                  type="date"
                  value={formData.end_date}
                  onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Maximum Number Of Usres :</label>
                <input
                  type="number"
                  value={formData.max_users}
                  onChange={(e) => setFormData({ ...formData, max_users: e.target.value })}
                  min="1"
                />
              </div>

              <div className="form-actions">
                <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </button>
                <button className="btn-primary" onClick={handleSave}>
                  {editingCompetition ? 'حفظ التغييرات' : 'Add Competation'}
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
