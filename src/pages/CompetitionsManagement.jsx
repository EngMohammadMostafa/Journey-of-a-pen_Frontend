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

// لحفظ بيانات اللايكات للكتاب المختار
const [selectedBookId, setSelectedBookId] = useState(null);
const [bookLikes, setBookLikes] = useState(null);
const [filteredLikes, setFilteredLikes] = useState([]);
const [likesSearchTerm, setLikesSearchTerm] = useState('');
const [likesLoading, setLikesLoading] = useState(false);

const [categories, setCategories] = useState([]);
const [categoriesLoading, setCategoriesLoading] = useState(false);

const [addToPlatformModalOpen, setAddToPlatformModalOpen] = useState(false);
const [selectedCompetitionBook, setSelectedCompetitionBook] = useState(null);
const [platformFormData, setPlatformFormData] = useState({
  category_id: '',
  price: 0,
  book_type: 'free',
  description: ''
});

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
    },
    {
      key: 'status',
      title: 'Status',
      render: (_, book) => (
        <span>
          {book.status === 'pending' ? 'Pending' : 'Accepted'}
        </span>
      )
    },
    
    {
      key: 'actions',
      title: 'Actions',
      render: (_, book) => (
        <>
       
         {/* أزرار القبول والرفض فقط للحالة pending */}
      {book.status === 'pending' && (
        <>
          <button
            className="btn-success"
            onClick={() =>
              handleApproveOrReject(book.competition_book_id, 'accepted')
            }
          >
            Accept
          </button>

          <button
            className="btn-warning"
            onClick={() =>
              handleApproveOrReject(book.competition_book_id, 'rejected')
            }
          >
            Reject
          </button>
        </>
      )}
      <button
  className="btn-info"
  onClick={() => handleDownloadBook(book.competition_book_id, book.title)}
>
  Download
</button>

          <button
            className="btn-danger"
            onClick={() => handleDeleteCompetitionBook(book.competition_book_id)}
          >
            Delete Book
          </button>
   {/* ✅ زر إضافة للمنصة فقط للكتب المقبولة */}
    {book.status === 'accepted' && (
        <button
          className="btn-primary"
          onClick={() => openAddToPlatformModal(book)}
        >
          Add to Platform
        </button>
      )}

        </>
      )
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
const fetchBookLikes = async (bookId) => {
  setLikesLoading(true);
  try {
    const response = await competitionsService.getBookLikes(bookId, token);
    setBookLikes(response); // تخزين البيانات في الحالة
  } catch (error) {
    console.error("Error fetching book likes:", error);
    alert("حدث خطأ في جلب بيانات اللايكات");
  } finally {
    setLikesLoading(false);
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

//حذف مشترك اي كتابه من المشابقه وجميع تفاصيله بعد
  const handleDeleteCompetitionBook = async (competition_book_id) => {
    if (!window.confirm('هل أنت متأكد من حذف هذا الكتاب من المسابقة؟')) return;
  
    try {
      const response = await competitionsService.deleteCompetitionBook(competition_book_id, token);
      alert(response.message);
  
      // تحديث الجدول مباشرة بعد الحذف
      setCompetitionDetails(prev => ({
        ...prev,
        books: prev.books.filter(b => b.competition_book_id !== competition_book_id)
      }));
    } catch (error) {
      console.error(error);
      alert('حدث خطأ أثناء حذف الكتاب من المسابقة');
    }
  };
  

  const handleApproveOrReject = async (competition_book_id, status) => {
    const confirmMessage =
      status === 'accepted'
        ? 'هل أنت متأكد من قبول هذا الكتاب؟'
        : 'هل أنت متأكد من رفض الكتاب؟ سيتم حذفه نهائيًا';
  
    if (!window.confirm(confirmMessage)) return;
  
    try {
      const response = await competitionsService.approveOrRejectBook(
        competition_book_id,
        { status },
        token
      );
  
      alert(response.message);
  
      if (status === 'rejected') {
        // حذف من الجدول لأن الباك حذف السجل
        setCompetitionDetails(prev => ({
          ...prev,
          books: prev.books.filter(
            b => b.competition_book_id !== competition_book_id
          )
        }));
      } else {
        // تحديث الحالة إلى accepted
        setCompetitionDetails(prev => ({
          ...prev,
          books: prev.books.map(b =>
            b.competition_book_id === competition_book_id
              ? { ...b, status: 'accepted' }
              : b
          )
        }));
      }
    } catch (error) {
      console.error(error);
      alert('حدث خطأ أثناء تنفيذ العملية');
    }
  };
  
  const handleDownloadBook = async (competition_book_id, title) => {
    try {
      const blob = await competitionsService.downloadCompetitionBook(competition_book_id);
   // فحص نوع الملف
   if (!blob || blob.type === 'application/json') {
    alert('الكتاب غير متاح للتحميل أو حدث خطأ');
    return;
  }
      const url = window.URL.createObjectURL(new Blob([blob]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `${title}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error(error);
      alert('حدث خطأ أثناء تحميل الكتاب');
    }
  };
  const openAddToPlatformModal = async (book) => {
    setSelectedCompetitionBook(book);
    setCategoriesLoading(true);
  
    try {
      const categoriesData = await competitionsService.getAllCategories(); // ← بيانات جاهزة
      setCategories(categoriesData);  // حفظ الأقسام
      setAddToPlatformModalOpen(true); // فتح المودال بعد التحميل
    } catch (error) {
      console.error('Error fetching categories:', error);
      alert('حدث خطأ في جلب الأقسام');
    } finally {
      setCategoriesLoading(false);
    }
  
    setPlatformFormData({
      category_id: '',
      price: 0,
      book_type: 'free',
      description: ''
    });
  };
  
  
  
  const handleAddToPlatform = async () => {
    try {
      if (!selectedCompetitionBook) return;
  
      const token = localStorage.getItem("token");
  
      const response = await competitionsService.addCompetitionBookToPlatform(
        selectedCompetitionBook.competition_book_id,
        platformFormData,
        token
      );
  
      console.log("Added to platform:", response);
  
      // تحديث جدول المسابقة: إزالة الكتاب من قائمة الكتب
      setCompetitionDetails(prev => ({
        ...prev,
        books: prev.books.filter(
          book => book.competition_book_id !== selectedCompetitionBook.competition_book_id
        )
      }));
  
      setAddToPlatformModalOpen(false);
      alert("تم إضافة الكتاب إلى المنصة بنجاح ✅");
    } catch (error) {
      console.error(error);
      alert("حدث خطأ أثناء إضافة الكتاب");
    }
  };
  
  
  
  
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


useEffect(() => {
  if (bookLikes?.liked_users) {
    let filtered = bookLikes.liked_users;

    if (likesSearchTerm) {
      filtered = filtered.filter(user =>
        user.username?.toLowerCase().includes(likesSearchTerm.toLowerCase())
      );
    }

    setFilteredLikes(filtered);
  } else {
    setFilteredLikes([]);
  }
}, [bookLikes, likesSearchTerm]);





return (
  <div className="competitions-management">

    <div className="page-header">
      <h1>Competitions Management</h1>

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
        onClick={() => {
          setShowCompetitionsTable(true)
          setShowParticipantsTable(false)
        }}
      >
        Competitions Management
      </button>

      <button
        className={`btn ${showParticipantsTable ? 'btn-primary' : 'btn-outline'}`}
        onClick={() => {
          setShowCompetitionsTable(false)
          setShowParticipantsTable(true)
          setSelectedCompetitionId(null)
          setCompetitionDetails(null)
        }}
      >
        Participant & Book Management
      </button>
    </div>

    {/* ================= PARTICIPANTS SECTION ================= */}
    {showParticipantsTable && (
      <div className="participants-section">

        <div className="users-filters">
          <div className="filter-section">
            <select
              value={selectedCompetitionId || ''}
              onChange={(e) => {
                const compId = e.target.value
                setSelectedCompetitionId(compId)
                fetchCompetitionDetails(compId)
              }}
              className="filter-select"
            >
              <option value="" disabled>Select Competition</option>
              {competitions.map(c => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
          </div>

          {competitionDetails?.books?.length > 0 && (
            <div className="filter-section">
              <select
                value={selectedBookId || ''}
                onChange={(e) => {
                  const bookId = e.target.value
                  setSelectedBookId(bookId)
                  fetchBookLikes(bookId)
                }}
                className="filter-select"
              >
                <option value="" disabled>-- Select Book --</option>
                {competitionDetails.books.map(book => (
                  <option key={book.competition_book_id} value={book.competition_book_id}>
                    {book.title}
                  </option>
                ))}
              </select>
            </div>
          )}

          {bookLikes && (
            <div className="search-section">
              <input
                type="text"
                placeholder="Search liked users..."
                value={likesSearchTerm}
                onChange={(e) => setLikesSearchTerm(e.target.value)}
                className="search-input"
              />
              <div className="results-count">
                Showing {filteredLikes.length} users
              </div>
            </div>
          )}
        </div>

        {bookLikes && (
          <div className="book-details-section">
            <h3>Likes for: {bookLikes.title} (Total: {bookLikes.likes_count})</h3>
            <ul>
              {filteredLikes.map(user => (
                <li key={user.id}>
                  {user.username} (Liked at: {new Date(user.pivot.created_at).toLocaleString()})
                </li>
              ))}
            </ul>
            {likesLoading && <p>Loading likes...</p>}
          </div>
        )}

        {selectedCompetitionId && competitionDetails && (
          <DataTable
            columns={participantColumns}
            data={competitionDetails.books}
            loading={participantsLoading}
          />
        )}
      </div>
    )}

    {/* ================= COMPETITIONS TABLE ================= */}
    {showCompetitionsTable && (
      <>
        <div className="user-stats">
          <div className="stat-card">
            <h3>Total Number Of Competitions</h3>
            <span className="stat-number">{competitionStats.total}</span>
          </div>
        </div>

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

        <DataTable
          columns={columns}
          data={filteredCompetitions}
          loading={loading}
          onEdit={handleEdit}
          onDelete={handleDelete}
          actions={['edit', 'delete']}
        />

        {/* MODAL ADD / EDIT COMPETITION */}
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
              <label>Competition Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
              />
            </div>

            <div className="form-group">
              <label>Status</label>
              <select
                value={formData.status}
                onChange={(e) =>
                  setFormData({ ...formData, status: e.target.value })
                }
              >
                <option value="active">نشطة</option>
                <option value="inactive">غير نشطة</option>
                <option value="finished">منتهية</option>
              </select>
            </div>

            <div className="form-group">
              <label>Start Date</label>
              <input
                type="date"
                value={formData.startdate}
                onChange={(e) =>
                  setFormData({ ...formData, startdate: e.target.value })
                }
              />
            </div>

            <div className="form-group">
              <label>End Date</label>
              <input
                type="date"
                value={formData.enddate}
                onChange={(e) =>
                  setFormData({ ...formData, enddate: e.target.value })
                }
              />
            </div>

            <div className="form-group">
              <label>Max Users</label>
              <input
                type="number"
                min="1"
                value={formData.max_user}
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
                {editingCompetition ? 'حفظ التغييرات' : 'Add Competition'}
              </button>
            </div>
          </div>
        </Modal>
      </>
    )}

    {/* ================= ADD TO PLATFORM MODAL ================= */}
    {addToPlatformModalOpen && (
      <Modal
        isOpen={addToPlatformModalOpen}
        onClose={() => setAddToPlatformModalOpen(false)}
        title="Add Competition Book to Platform"
      >
        <div className="platform-form">

          <div className="form-group">
            <label>Category</label>
            <select
  value={platformFormData.category_id}
  onChange={(e) =>
    setPlatformFormData({ ...platformFormData, category_id: e.target.value })
  }
  disabled={categoriesLoading}
>
  <option value="">-- Select Category --</option>
  {categories.map(cat => (
    <option key={cat.id} value={cat.id}>{cat.name}</option>
  ))}
</select>

{categoriesLoading && <p>Loading categories...</p>}


{categoriesLoading && <p>Loading categories...</p>}




          </div>

          <div className="form-group">
            <label>Price</label>
            <input
              type="number"
              min="0"
              value={platformFormData.price}
              onChange={(e) =>
                setPlatformFormData({
                  ...platformFormData,
                  price: Number(e.target.value)
                })
              }
            />
          </div>

          <div className="form-group">
            <label>Book Type</label>
            <select
              value={platformFormData.book_type}
              onChange={(e) =>
                setPlatformFormData({
                  ...platformFormData,
                  book_type: e.target.value
                })
              }
            >
              <option value="free">Free</option>
              <option value="paid">Paid</option>
            </select>
          </div>

          <div className="form-group">
            <label>Description</label>
            <textarea
              value={platformFormData.description}
              onChange={(e) =>
                setPlatformFormData({
                  ...platformFormData,
                  description: e.target.value
                })
              }
            />
          </div>

          <div className="form-actions">
            <button
              className="btn-secondary"
              onClick={() => setAddToPlatformModalOpen(false)}
            >
              Cancel
            </button>

            <button
              className="btn-primary"
              onClick={handleAddToPlatform}
            >
              Add to Platform
            </button>
          </div>
        </div>
      </Modal>
    )}

  </div>
)

}

export default CompetitionsManagement
