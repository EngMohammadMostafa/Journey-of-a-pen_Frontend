import React, { useState, useEffect } from 'react';
import DataTable from '../components/common/DataTable';
import Modal from '../components/common/Modal';
import LoadingSpinner from '../components/common/LoadingSpinner';
import SearchBar from '../components/common/SearchBar';
import { quotesService } from '../services/quotesService';
import '../styles/QuotesManagement.css';

const QuotesManagement = () => {
  const [quotes, setQuotes] = useState([]);
  const [filteredQuotes, setFilteredQuotes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [deleteModal, setDeleteModal] = useState({ isOpen: false, quote: null });

  //للفلترة
  const [searchTerm, setSearchTerm] = useState(''); // لتخزين النص الذي يكتبه المستخدم
const [filterType, setFilterType] = useState('all'); // نوع الفلترة: الكل / نص الاقتباس / اسم الكتاب

  // أعمدة الجدول
  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'text', label: 'نص الاقتباس' },
    { key: 'book_name', label: 'اسم الكتاب' },
    { key: 'user_id', label: 'معرف المستخدم' },
    { key: 'created_at', label: 'تاريخ الإنشاء' },
    { key: 'actions', label: 'الإجراءات' }
  ];

  // جلب البيانات من API
  const fetchQuotes = async () => {
    try {
      setLoading(true);
      const response = await quotesService.getAllQuotes();
      
      if (response.success) {
        setQuotes(response.quotes);
        setFilteredQuotes(response.quotes);
      } else {
        setError('فشل في جلب البيانات');
      }
    } catch (err) {
      setError('حدث خطأ في الاتصال بالخادم');
      console.error('Error fetching quotes:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchQuotes();
  }, []);

//هذا يجلب البينات من الباك بينما اللي بعده للفلترة
  useEffect(() => {
    fetchQuotes(); // جلب البيانات عند تحميل الصفحة
  }, []);
  
  //  هنا ضع useEffect الجديد للتصفية والبحث
  useEffect(() => {
    let filtered = quotes; // نبدأ بالبيانات كلها
  
    if (searchTerm) { // إذا كتب المستخدم شيء
      filtered = filtered.filter(quote => {
        const term = searchTerm.toLowerCase(); // نحول كل شيء لصغير لتسهيل البحث
        if (filterType === 'text') return quote.text.toLowerCase().includes(term);
        if (filterType === 'book') return quote.book_name.toLowerCase().includes(term);
        // إذا كان الاختيار "الكل"
        return quote.text.toLowerCase().includes(term) || quote.book_name.toLowerCase().includes(term);
      });
    }
  
    setFilteredQuotes(filtered); // نعرض النتائج بعد التصفية
  }, [quotes, searchTerm, filterType]);
  
  // البحث والتصفية
  const handleSearch = (searchTerm) => {
    if (!searchTerm) {
      setFilteredQuotes(quotes);
      return;
    }

    const filtered = quotes.filter(quote =>
      quote.text.toLowerCase().includes(searchTerm.toLowerCase()) ||
      quote.book_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      quote.id.toString().includes(searchTerm)
    );
    
    setFilteredQuotes(filtered);
  };

  // فتح نافذة حذف الاقتباس
  const handleDeleteClick = (quote) => {
    setDeleteModal({ isOpen: true, quote });
  };

  // تأكيد الحذف
  const confirmDelete = async () => {
    try {
      const response = await quotesService.deleteQuote(deleteModal.quote.id);
      
      if (response.success) {
        // إعادة تحميل البيانات بعد الحذف
        await fetchQuotes();
        setDeleteModal({ isOpen: false, quote: null });
      } else {
        setError('فشل في حذف الاقتباس');
      }
    } catch (err) {
      setError('حدث خطأ أثناء الحذف');
      console.error('Error deleting quote:', err);
    }
  };

  // تنسيق البيانات للجدول
  const formatTableData = () => {

    return filteredQuotes.map(quote => ({
      id: quote.id,
      text: quote.text,
      book_name: quote.book_name,
      user_id: quote.user_id,
      created_at: new Date(quote.created_at).toLocaleDateString('ar-SA'),
      actions: (
        <div className="actions-buttons">
          <button 
            className="btn btn-danger btn-sm"
            onClick={() => handleDeleteClick(quote)}
          >
            حذف
          </button>
        </div>
      )
    }));
  };

  if (loading) return <LoadingSpinner />;

  return (
    <div className="quotes-management">
      <div className="page-header">
        <h1>Quotes Management </h1>
    
      </div>


{/* قسم الإحصائيات مثل صفحة المستخدمين */}
<div className="quotes-stats">
  <div className="stat-card">
    <h3>Total Number Of Quotes</h3>
    <span className="stat-number">{quotes.length}</span>
  </div>

  <div className="stat-card">
    <h3>أكثر كتاب يحتوي على اقتباسات تاكد من مشكلهربط </h3>
    <span className="stat-number">
      {(() => {
        if (quotes.length === 0) return "لا يوجد بيانات";
        const countMap = {};
        quotes.forEach(q => {
          countMap[q.book_name] = (countMap[q.book_name] || 0) + 1;
        });
        const topBook = Object.entries(countMap).sort((a, b) => b[1] - a[1])[0];
        return `${topBook[0]} (${topBook[1]} اقتباسات)`;
      })()}
    </span>
  </div>
</div>

    



{/*للفلترة والبحث */}
<div className="quotes-filters">
  <div className="search-section">
    <input
      type="text"
      placeholder=" Search For A Quote ..."
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      className="search-input"
    />
  </div>

  <div className="filter-section">
    <select
      value={filterType}
      onChange={(e) => setFilterType(e.target.value)}
      className="filter-select"
    >
      <option value="all">All Quotes</option>
      <option value="text">Search For The Quote Title</option>
      <option value="book">حسب اسم الكتاب</option>
    </select>
  </div>

  <div className="results-count">
    <span>Show {filteredQuotes.length} Out Of  {quotes.length} Quotes</span>
  </div>
</div>

      <DataTable
        columns={columns}
        data={formatTableData()}
        emptyMessage="لا توجد اقتباسات لعرضها"
      />

      {/* نافذة تأكيد الحذف */}
      <Modal
        isOpen={deleteModal.isOpen}
        onClose={() => setDeleteModal({ isOpen: false, quote: null })}
        title="تأكيد الحذف"
      >
        <div className="delete-confirmation">
          <p>هل أنت متأكد من أنك تريد حذف هذا الاقتباس؟</p>
          <div className="quote-preview">
            <strong>الاقتباس:</strong> 
            <p>"{deleteModal.quote?.text}"</p>
            <small>الكتاب: {deleteModal.quote?.book_name}</small>
          </div>
          <div className="modal-actions">
            <button 
              className="btn btn-secondary"
              onClick={() => setDeleteModal({ isOpen: false, quote: null })}
            >
              إلغاء
            </button>
            <button 
              className="btn btn-danger"
              onClick={confirmDelete}
            >
              تأكيد الحذف
            </button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default QuotesManagement;