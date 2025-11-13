import React, { useState } from 'react';
import DataTable from '../components/common/DataTable';
import Modal from '../components/common/Modal';
import '../styles/global.css';
import '../styles/BooksManagement.css';
import '../services/booksService';

const BooksManagement = () => {
  const [activeSection, setActiveSection] = useState(null);
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);

  // --- مودال الكتب ---
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBook, setEditingBook] = useState(null);
  const [formData, setFormData] = useState({
    author: '',
    title: '',
    description: '',
    price: '',
    is_free: 0,
    book_type: '',
    discount_rate: '',
    sectionid: ''
  });

  // حالة الأسئلة
  const [questions, setQuestions] = useState([]); 

  // --- مودال إضافة سؤال جديد ---
  const [isQuestionModalOpen, setIsQuestionModalOpen] = useState(false);
  const [newQuestionText, setNewQuestionText] = useState('');
  const [selectedBookId, setSelectedBookId] = useState(''); // لاختيار الكتاب للسؤال الجديد

  // --- أعمدة جدول الكتب ---
  const bookColumns = [
    { key: 'id', title: 'ID' },
    { key: 'author', title: 'المؤلف' },
    { key: 'title', title: 'عنوان الكتاب' },
    { key: 'description', title: 'الوصف' },
    { key: 'price', title: 'السعر' },
    { key: 'is_free', title: 'مجاني؟', render: (value) => (value === 1 ? 'نعم' : 'لا') },
    { key: 'book_type', title: 'نوع الكتاب' },
    { key: 'discount_rate', title: 'نسبة الخصم' },
    { key: 'number_of_likes', title: 'عدد الإعجابات' },
    { key: 'sectionid', title: 'القسم' },
    {
      key: 'actions',
      title: 'الإجراءات',
      render: (_, book) => (
        <div>
          <button className="btn-secondary" onClick={() => handleEditBook(book)}>تعديل</button>
          <button className="btn-danger" onClick={() => handleDeleteBook(book)}>حذف</button>
        </div>
      )
    }
  ];

  // أعمدة جدول الأسئلة
  const questionColumns = [
    { key: 'id', title: 'ID' },
    { key: 'text', title: 'السؤال' },
    { key: 'book_title', title: 'الكتاب' },
    { key: 'actions', title: 'الإجراءات' } // فارغ مؤقتاً، سنضيف تعديل وحذف لاحقًا
  ];

  // --- التبديل بين الأقسام ---
  const handleRequests = () => setActiveSection('requests');
  const handleBooks = () => setActiveSection('books');
  const handleQuestions = () => setActiveSection('questions');

  // --- دوال إدارة الكتب ---
  const handleAddBook = () => {
    setEditingBook(null);
    setFormData({ author: '', title: '', description: '', price: '', is_free: 0, book_type: '', discount_rate: '', sectionid: '' });
    setIsModalOpen(true);
  };

  const handleEditBook = (book) => {
    setEditingBook(book);
    setFormData({
      author: book.author || '',
      title: book.title || '',
      description: book.description || '',
      price: book.price || '',
      is_free: book.is_free || 0,
      book_type: book.book_type || '',
      discount_rate: book.discount_rate || '',
      sectionid: book.sectionid || ''
    });
    setIsModalOpen(true);
  };

  const handleDeleteBook = (book) => {
    if (window.confirm(`هل أنت متأكد من حذف الكتاب "${book.title}"؟`)) {
      setBooks(books.filter(b => b.id !== book.id)); // محاكاة حذف الكتاب
      alert('تم حذف الكتاب (محاكاة)');
    }
  };

  const handleSaveBook = () => {
    if (!formData.author || !formData.title || !formData.description || !formData.price) {
      alert('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    if (editingBook) {
      setBooks(books.map(b => b.id === editingBook.id ? { ...b, ...formData } : b));
      alert('تم تعديل بيانات الكتاب (محاكاة)');
    } else {
      const newBook = { id: Date.now(), ...formData };
      setBooks([...books, newBook]);
      alert('تم إضافة الكتاب الجديد (محاكاة)');
    }

    setIsModalOpen(false);
    setEditingBook(null);
  };

  // --- إضافة سؤال جديد ---
  const handleAddQuestion = () => {
    if (!newQuestionText || !selectedBookId) {
      alert('يرجى كتابة السؤال واختيار الكتاب');
      return;
    }
    const book = books.find(b => b.id === parseInt(selectedBookId));
    const newQuestion = {
      id: Date.now(),
      text: newQuestionText,
      book_title: book?.title || 'غير محدد',
      book_id: parseInt(selectedBookId)
    };
    setQuestions([...questions, newQuestion]);
    alert('تم إضافة السؤال (محاكاة)');
    setNewQuestionText('');
    setSelectedBookId('');
    setIsQuestionModalOpen(false);
  };

  return (
    <div className="books-management">
      <div className="page-header">
        <h1>الإدارة العامة</h1>
      </div>

      {/* الأزرار الرئيسية */}
      <div className="buttons-container">
        <button className={`btn ${activeSection === 'requests' ? 'btn-primary' : 'btn-outline'}`} onClick={handleRequests}>
          إدارة محتوى طلبات الكتب
        </button>
        <button className={`btn ${activeSection === 'books' ? 'btn-primary' : 'btn-outline'}`} onClick={handleBooks}>
          إدارة الكتب
        </button>
        <button className={`btn ${activeSection === 'questions' ? 'btn-primary' : 'btn-outline'}`} onClick={handleQuestions}>
          الأسئلة والأجوبة
        </button>
      </div>

      {/* قسم إدارة الكتب */}
      {activeSection === 'books' && (
        <div className="books-section">
          <div className="section-header">
            <h2>قسم إدارة الكتب</h2>
            <button className="btn-primary" onClick={handleAddBook}>+ إضافة كتاب جديد</button>
          </div>
          <DataTable columns={bookColumns} data={books} loading={loading} />
        </div>
      )}

      {/* قسم إدارة الأسئلة (الدفعة الثانية: إضافة زر السؤال) */}
      {activeSection === 'questions' && (
        <div className="questions-section">
          <div className="section-header">
            <h2>قسم الأسئلة والأجوبة</h2>
            <button className="btn-primary" onClick={() => setIsQuestionModalOpen(true)}>+ إضافة سؤال جديد</button>
          </div>
          <DataTable columns={questionColumns} data={questions} loading={loading} />
        </div>
      )}

      {/* مودال إضافة / تعديل كتاب */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setEditingBook(null); }}
        title={editingBook ? "تعديل كتاب" : "إضافة كتاب جديد"}
      >
        <div className="book-form">
          <div className="form-group">
            <label>المؤلف *</label>
            <input type="text" value={formData.author} onChange={(e) => setFormData({ ...formData, author: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>عنوان الكتاب *</label>
            <input type="text" value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>الوصف *</label>
            <textarea value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} required></textarea>
          </div>
          <div className="form-group">
            <label>السعر *</label>
            <input type="number" value={formData.price} onChange={(e) => setFormData({ ...formData, price: e.target.value })} min="0" required />
          </div>
          <div className="form-group">
            <label>هل الكتاب مجاني؟</label>
            <select value={formData.is_free} onChange={(e) => setFormData({ ...formData, is_free: parseInt(e.target.value) })}>
              <option value={0}>لا</option>
              <option value={1}>نعم</option>
            </select>
          </div>
          <div className="form-group">
            <label>نوع الكتاب</label>
            <input type="number" value={formData.book_type} onChange={(e) => setFormData({ ...formData, book_type: e.target.value })} />
          </div>
          <div className="form-group">
            <label>نسبة الخصم (%)</label>
            <input type="number" value={formData.discount_rate} onChange={(e) => setFormData({ ...formData, discount_rate: e.target.value })} min="0" max="100" />
          </div>
          <div className="form-group">
            <label>رقم القسم (Section ID)</label>
            <input type="number" value={formData.sectionid} onChange={(e) => setFormData({ ...formData, sectionid: e.target.value })} />
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => { setIsModalOpen(false); setEditingBook(null); }}>إلغاء</button>
            <button className="btn-primary" onClick={handleSaveBook}>حفظ</button>
          </div>
        </div>
      </Modal>

      {/* مودال إضافة سؤال جديد */}
      <Modal
        isOpen={isQuestionModalOpen}
        onClose={() => setIsQuestionModalOpen(false)}
        title="إضافة سؤال جديد"
      >
        <div className="question-form">
          <div className="form-group">
            <label>السؤال *</label>
            <textarea value={newQuestionText} onChange={(e) => setNewQuestionText(e.target.value)} required></textarea>
          </div>
          <div className="form-group">
            <label>اختر الكتاب *</label>
            <select value={selectedBookId} onChange={(e) => setSelectedBookId(e.target.value)}>
              <option value="">-- اختر كتاب --</option>
              {books.map(book => (
                <option key={book.id} value={book.id}>{book.title}</option>
              ))}
            </select>
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsQuestionModalOpen(false)}>إلغاء</button>
            <button className="btn-primary" onClick={handleAddQuestion}>إضافة</button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default BooksManagement
