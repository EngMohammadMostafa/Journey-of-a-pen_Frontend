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
  const [selectedBookId, setSelectedBookId] = useState(''); 

  // --- مودال تعديل سؤال ---
  const [isEditQuestionModalOpen, setIsEditQuestionModalOpen] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState(null);
  const [editingQuestionText, setEditingQuestionText] = useState('');

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

  // أعمدة جدول الأسئلة مع زر تعديل وحذف
  const questionColumns = [
    { key: 'id', title: 'ID' },
    { key: 'text', title: 'السؤال' },
    { key: 'book_title', title: 'الكتاب' },
    {
      key: 'actions',
      title: 'الإجراءات',
      render: (_, question) => (
        <div>
          <button className="btn-secondary" onClick={() => openEditQuestionModal(question)}>تعديل</button>
          <button className="btn-danger" onClick={() => handleDeleteQuestion(question)}>حذف</button>
        </div>
      )
    }
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
      setBooks(books.filter(b => b.id !== book.id));
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

  // --- فتح مودال تعديل سؤال ---
  const openEditQuestionModal = (question) => {
    setEditingQuestion(question);
    setEditingQuestionText(question.text);
    setIsEditQuestionModalOpen(true);
  };

  // --- حفظ تعديل السؤال ---
  const handleSaveEditQuestion = () => {
    if (!editingQuestionText) {
      alert('يرجى كتابة السؤال');
      return;
    }
    setQuestions(questions.map(q => q.id === editingQuestion.id ? { ...q, text: editingQuestionText } : q));
    alert('تم تعديل السؤال (محاكاة)');
    setIsEditQuestionModalOpen(false);
    setEditingQuestion(null);
    setEditingQuestionText('');
  };

  // --- حذف سؤال ---
  const handleDeleteQuestion = (question) => {
    if (window.confirm(`هل أنت متأكد من حذف السؤال "${question.text}"؟`)) {
      setQuestions(questions.filter(q => q.id !== question.id));
      alert('تم حذف السؤال (محاكاة)');
    }
  };

  return (
    <div className="books-management">
      <div className="page-header">
  <h1>الإدارة العامة</h1>

  {/* زر الإضافة يظهر فقط إذا كان القسم مفعل */}
  {activeSection === 'books' && (
    <button className="btn-primary add-book-btn" onClick={handleAddBook}>+ إضافة كتاب جديد</button>
  )}

  {activeSection === 'questions' && (
    <button className="btn-primary add-book-btn" onClick={() => setIsQuestionModalOpen(true)}>+ إضافة سؤال جديد</button>
  )}

  {/* يمكنك إضافة أي زر إضافي لبقية الأقسام هنا */}
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
            
          </div>
          <DataTable columns={bookColumns} data={books} loading={loading} />
        </div>
      )}

      {/* قسم إدارة الأسئلة */}
      {activeSection === 'questions' && (
        <div className="questions-section">
          <div className="section-header">
            <h2>قسم الأسئلة والأجوبة</h2>
            
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
      <input
        type="text"
        value={formData.author}
        onChange={(e) => setFormData({ ...formData, author: e.target.value })}
        required
      />
    </div>

    <div className="form-group">
      <label>عنوان الكتاب *</label>
      <input
        type="text"
        value={formData.title}
        onChange={(e) => setFormData({ ...formData, title: e.target.value })}
        required
      />
    </div>

    <div className="form-group">
      <label>الوصف *</label>
      <textarea
        value={formData.description}
        onChange={(e) => setFormData({ ...formData, description: e.target.value })}
        required
      />
    </div>

    <div className="form-group">
      <label>السعر *</label>
      <input
        type="number"
        value={formData.price}
        onChange={(e) => setFormData({ ...formData, price: e.target.value })}
        required
      />
    </div>

    <div className="form-group">
      <label>مجاني؟</label>
      <select
        value={formData.is_free}
        onChange={(e) => setFormData({ ...formData, is_free: parseInt(e.target.value) })}
      >
        <option value={0}>لا</option>
        <option value={1}>نعم</option>
      </select>
    </div>

    <div className="form-group">
      <label>نوع الكتاب</label>
      <input
        type="text"
        value={formData.book_type}
        onChange={(e) => setFormData({ ...formData, book_type: e.target.value })}
      />
    </div>

    <div className="form-group">
      <label>نسبة الخصم</label>
      <input
        type="number"
        value={formData.discount_rate}
        onChange={(e) => setFormData({ ...formData, discount_rate: e.target.value })}
      />
    </div>

    <div className="form-group">
      <label>القسم</label>
      <input
        type="text"
        value={formData.sectionid}
        onChange={(e) => setFormData({ ...formData, sectionid: e.target.value })}
      />
    </div>

    <div className="form-actions">
      <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>إلغاء</button>
      <button className="btn-primary" onClick={handleSaveBook}>
        {editingBook ? "حفظ التعديل" : "إضافة كتاب"}
      </button>
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

      {/* مودال تعديل سؤال */}
      <Modal
        isOpen={isEditQuestionModalOpen}
        onClose={() => setIsEditQuestionModalOpen(false)}
        title="تعديل السؤال"
      >
        <div className="question-form">
          <div className="form-group">
            <label>السؤال *</label>
            <textarea value={editingQuestionText} onChange={(e) => setEditingQuestionText(e.target.value)} required></textarea>
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsEditQuestionModalOpen(false)}>إلغاء</button>
            <button className="btn-primary" onClick={handleSaveEditQuestion}>حفظ</button>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default BooksManagement
