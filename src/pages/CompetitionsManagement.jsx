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
    status: 'active',
    startdate: '',
    enddate: '',
    max_user: 1
  })
  
// للمشاركة وعرض الكتب
const [showParticipantsTable, setShowParticipantsTable] = useState(false);
const [competitionDetails, setCompetitionDetails] = useState(null); // لتخزين البيانات من API
const [participantsLoading, setParticipantsLoading] = useState(false);
const [selectedCompetitionId, setSelectedCompetitionId] = useState(null);


//احصاء عدد مسابقات من الباكند 
const [competitionStats, setCompetitionStats] = useState({ total: 0 });

// أعمدة الجدول
  const columns = [
    { key: 'id', title: 'ID' },
    { key: 'name', title: 'Competition Name' },
    { key: 'status', title: 'Status' },
    { key: 'startdate', title: 'Start Date' },
    { key: 'enddate', title: 'End Date' },
    { key: 'max_user', title: 'Max Users' },
    { 
      key: 'actions', 
      title: 'Actions',
      render: (_, comp) => (
        <div>
          <button className="btn-primary" onClick={() => handleEdit(comp)}>Edit</button>
          <button className="btn-danger" onClick={() => handleDelete(comp)}>Delete</button>
        </div>
      )
    }
  
  
  ];
  // أعمدة جدول المشاركين والكتب (مطابقة للـ API)
  const participantColumns = [
    { key: 'competition_book_id', title: 'ID' },
    { key: 'title', title: 'Book Title' },
    { 
      key: 'owner',
      title: 'Owner',
      render: (_, book) => book.owner?.username || '-'
    },
    { key: 'likes_count', title: 'Likes Count' },
    { key: 'file_type', title: 'File Type' },
    {
      key: 'file_size',
      title: 'File Size (KB)',
      render: (_, book) => ((book.file_size || 0) / 1024).toFixed(2)
    }
  ];
  


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
  };

const fetchCompetitionDetails = async (competitionId) => {
  setParticipantsLoading(true);
  try {
    const response = await competitionsService.getCompetitionDetails(competitionId, token);
    setCompetitionDetails(response); // تحتوي على competition + books
  } catch (error) {
    console.error("Error fetching competition details:", error);
    alert("حدث خطأ في جلب بيانات المسابقة");
  } finally {
    setParticipantsLoading(false);
  }
};

const fetchCompetitionStats = async () => {
  try {
    const data = await competitionsService.getTotalCompetitions(token);
    setCompetitionStats({ total: data.total_competitions || 0 });
  } catch (error) {
    console.error('Error fetching competition stats:', error);
    setCompetitionStats({ total: 0 });
  }
};



  // فتح مودال الإضافة
  const handleAddCompetition = () => {
    setEditingCompetition(null)
    setFormData({
      name: '',
      status: 'active',
      startdate: '',
      enddate: '',
      max_user: 1
    })
    
    setIsModalOpen(true)
  }

  // فتح مودال التعديل
  const handleEdit = (competition) => {
    setEditingCompetition(competition)
    setFormData({
      name: competition.name || '',
      status: competition.status || 'active',
      startdate: competition.startdate || '',
      enddate: competition.enddate || '',
      max_user: competition.max_user || 1
    })
    
    setIsModalOpen(true)
  }

  // حفظ الإضافة أو التعديل
  const handleSave = async () => {
    try {
      if (editingCompetition) {

        await competitionsService.updateCompetition(
          editingCompetition.id,
          {
            name: formData.name,
            status: formData.status,
            startdate: formData.startdate,
            enddate: formData.enddate,
            max_user: formData.max_user
          }
        )
        
          alert('تم تعديل المسابقة بنجاح')
      } else {
        await competitionsService.addCompetition(formData, token)
        alert('تم إضافة المسابقة بنجاح')
      }
      setIsModalOpen(false)
      setEditingCompetition(null)
      setFormData({
        name: '',
        status: 'active',
        startdate: '',
        enddate: '',
        max_user: 1
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
        await competitionsService.deleteCompetition(competition.id, token);
        alert('تم حذف المسابقة بنجاح');
        fetchCompetitions(); // تحديث الجدول بعد الحذف
      } catch (error) {
        console.error('Error deleting competition:', error);
        alert('حدث خطأ في حذف المسابقة');
      }
    }
  }
  

  const modalTitle = editingCompetition ? 'تعديل المسابقة' : 'Add New Competation  '



  
  useEffect(() => {
    if (showCompetitionsTable || showParticipantsTable) {
      fetchCompetitions();
    }
  }, [showCompetitionsTable, showParticipantsTable]);
  

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

useEffect(() => {
  if (showCompetitionsTable) {
    fetchCompetitions();
    fetchCompetitionStats(); // ← هنا نجيب الإحصاء من الباكند
  }
}, [showCompetitionsTable]);

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
  {/* زر عرض جدول المسابقات */}
  <button
    className={`btn ${showCompetitionsTable ? 'btn-primary' : 'btn-outline'}`}
    onClick={() => {
      setShowCompetitionsTable(true);      // عرض جدول المسابقات
      setShowParticipantsTable(false);     // إخفاء جدول المشاركين إذا كان ظاهر
    }}
  >
    Competitions Management
  </button>

  {/* زر عرض جدول المشاركين والكتب */}
  <button
    className={`btn ${showParticipantsTable ? 'btn-primary' : 'btn-outline'}`}
    onClick={() => {
      setShowCompetitionsTable(false);     // إخفاء جدول المسابقات
      setShowParticipantsTable(true);      // عرض جدول المشاركين/الكتب
      setSelectedCompetitionId(null);      // إعادة تعيين المسابقة المختارة
      setCompetitionDetails(null);         // مسح البيانات السابقة
    }}
  >
    Participant & Book Management
  </button>
</div>

{showParticipantsTable && (
  <div className="participants-section">
    <h2>Participant & Book Management</h2>

    {/* اختيار المسابقة */}
    <select
      value={selectedCompetitionId || ''}
      onChange={(e) => {
        const compId = e.target.value;
        setSelectedCompetitionId(compId);
        fetchCompetitionDetails(compId);
      }}
    >
      <option value="" disabled>Select Competition</option>
      {competitions.map(c => (
        <option key={c.id} value={c.id}>{c.name}</option>
      ))}
    </select>

    {/* عرض جدول الكتب إذا تم اختيار مسابقة */}
    {selectedCompetitionId && competitionDetails && (
      <DataTable
        columns={participantColumns}        // الأعمدة معرفة أعلى الكومبوننت
        data={competitionDetails.books}     // البيانات من API
        loading={participantsLoading}       // حالة التحميل
      />
    )}
  </div>
)}

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
                    <option value="active">نشطة</option>
                    <option value="inactive">غير نشطة</option>
                    <option value="finished">منتهية</option>
                </select>

              </div>

              <div className="form-group">
                <label>Start Date:</label>
                <input
                  type="date"
                  value={formData.startdate}
                  onChange={(e) => setFormData({ ...formData, startdate: e.target.value })}
                  
                />
              </div>

              <div className="form-group">
                <label>End Date :</label>
                <input
                  type="date"
                  value={formData.enddate}
                  onChange={(e) => setFormData({ ...formData, enddate: e.target.value })}                  
                />
              </div>

              <div className="form-group">
                <label>Maximum Number Of Usres :</label>
                <input
                  type="number"
                  value={formData.max_user}
                    min="1"
                  onChange={(e) =>
                    setFormData({ ...formData, max_user: Number(e.target.value) })
                  }
                  
                
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
