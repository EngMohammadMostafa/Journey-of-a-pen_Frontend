import React, { useState, useEffect } from 'react';
import DataTable from '../components/common/DataTable';
import Modal from '../components/common/Modal';
import '../styles/global.css';
import '../styles/BooksManagement.css';
import '../services/booksService';

const BooksManagement = () => {
  const [activeSection, setActiveSection] = useState(null);
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);
  //لاضافه البحث والفلترة سواء ككتاب او مؤلف لقسم الكتب
  const [searchTerm, setSearchTerm] = useState('');
  const [filteredBooks, setFilteredBooks] = useState([]);
  const [searchType, setSearchType] = useState('title');

//لاضافه احصائيات لادارة كتب
const bookStats = {
  total: books.length,
  free: books.filter(b => b.is_free === 1).length,
  paid: books.filter(b => b.is_free === 0).length
};


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


// فلترة الأسئلة حسب الكتاب أو نص السؤال
const [searchTypeQuestion, setSearchTypeQuestion] = useState('text'); // نوع البحث: 'text' أو 'book'
const [searchQuestionTerm, setSearchQuestionTerm] = useState(''); // النص المراد البحث عنه
const [searchBookId, setSearchBookId] = useState(''); // الكتاب المحدد عند البحث بالكتاب
const [filteredQuestions, setFilteredQuestions] = useState([]);


  //لاضافه احصائيات لقسم ادارة الاسءله والاجوبة
  // حساب الإحصائيات للأسئلة
const questionStats = {
  totalQuestions: questions.length,
  correctAnswers: questions.filter(q => q.is_correct === 1).length, // نفترض أن لديك is_correct
  totalPoints: questions.reduce((sum, q) => sum + (q.points || 0), 0) // نقاط كل إجابة صحيحة
};


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

//هذا من اجل اضافه الفلترة والبحث لقسم الكتب
useEffect(() => {
  let filtered = books;

  if (searchTerm) {
    if (searchType === 'title') {
      filtered = books.filter(book =>
        book.title?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    } else if (searchType === 'author') {
      filtered = books.filter(book =>
        book.author?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
  }

  setFilteredBooks(filtered);
}, [books, searchTerm, searchType]);


//هذا من اجل اضافه الفلترة والبحث لقسم الاسئله والاجوبة
useEffect(() => {
  let filtered = questions;

  if (searchTypeQuestion === 'text' && searchQuestionTerm) {
    filtered = questions.filter(q =>
      q.text.toLowerCase().includes(searchQuestionTerm.toLowerCase())
    );
  } else if (searchTypeQuestion === 'book' && searchBookId) {
    filtered = questions.filter(q => q.book_id === parseInt(searchBookId));
  }

  setFilteredQuestions(filtered);
}, [questions, searchTypeQuestion, searchQuestionTerm, searchBookId]);



return (
    <div className="books-management">
      <div className="page-header">
  <h1>Books Management</h1>

  {/* زر الإضافة يظهر فقط إذا كان القسم مفعل */}
  {activeSection === 'books' && (
    <button className="btn-primary add-book-btn" onClick={handleAddBook}>+  Add New Book</button>
  )}

  {activeSection === 'questions' && (
    <button className="btn-primary add-book-btn" onClick={() => setIsQuestionModalOpen(true)}>+ Add New Question</button>
  )}

  {/* يمكنك إضافة أي زر إضافي لبقية الأقسام هنا */}
</div>


      {/* الأزرار الرئيسية */}
      <div className="buttons-container">
        <button className={`btn ${activeSection === 'requests' ? 'btn-primary' : 'btn-outline'}`} onClick={handleRequests}>
          Book Order Content Management
        </button>
        <button className={`btn ${activeSection === 'books' ? 'btn-primary' : 'btn-outline'}`} onClick={handleBooks}>
          Book Management
        </button>
        <button className={`btn ${activeSection === 'questions' ? 'btn-primary' : 'btn-outline'}`} onClick={handleQuestions}>
          Questions And Answers
        </button>
      </div>

      {/* قسم إدارة الكتب */}
      {activeSection === 'books' && (
        <div className="books-section">
          <div className="section-header">
            <h2>Book Management Section</h2>
            
          </div>
          

           {/* --- مربعات الإحصائيات --- */}
    <div className="book-stats">
      <div className="stat-card">
        <h3>Total Number Of Books</h3>
        <span className="stat-number">{bookStats.total}</span>
      </div>
      <div className="stat-card">
        <h3>Numper Of Free Books </h3>
        <span className="stat-number">{bookStats.free}</span>
      </div>
      <div className="stat-card">
      <h3>Numper Of Non-Free Books </h3>
        <span className="stat-number">{bookStats.paid}</span>
      </div>
    </div>

      {/*بحث وفلترة لقسم الكتب*/}
      <div className="books-filters">
  <div className="search-section">
    <input
      type="text"
      placeholder="Search For The Book Title  Or Auther's Name "
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      className="search-input"
    />
  </div>

  <div className="filter-section">
    <select
      value={searchType}
      onChange={(e) => setSearchType(e.target.value)}
      className="filter-select"
    >
      <option value="title">Search For The Book Title  </option>
      <option value="author">Search For The Auther's Name</option>
    </select>
  </div>

  <div className="filter-section">
    <button className="btn-secondary" onClick={() => setSearchTerm('')}>
                  View All Books  
    </button>
  </div>

  <div className="results-count">
  Show {filteredBooks.length} Out Of  {books.length} Books
  </div>
</div>

{/*هذا يضمن ان عند البحث بكون فارغ 
        يعرض كل الكتب
      وعندما يكتب بحث معين كتاب
    يظهر فقط الكتاب اللي يبحث عنه*/}
<DataTable 
  columns={bookColumns} 
  data={searchTerm ? filteredBooks : books} 
  loading={loading} 
/>

        </div>
      )}

      {/* قسم إدارة الأسئلة */}
      {activeSection === 'questions' && (
        <div className="questions-section">
          <div className="section-header">
            <h2>Questions and Answers Section  </h2>
            
          </div>

 {/* --- مربعات الإحصائيات --- */}
 <div className="question-stats">
      <div className="stat-card">
        <h3>Total Number Of Questions </h3>
        <span className="stat-number">{questionStats.totalQuestions}</span>
      </div>
      <div className="stat-card">
        <h3>Number Of Correct Answers</h3>
        <span className="stat-number">{questionStats.correctAnswers}</span>
      </div>
      <div className="stat-card">
        <h3>Total Numer Of Points Earned</h3>
        <span className="stat-number">{questionStats.totalPoints}</span>
      </div>
    </div>

      {/*بحث وفلترة لقسم الاسءله والاجوبة*/}
      <div className="questions-filters">
  <div className="filter-section">
    <select
      value={searchTypeQuestion}
      onChange={(e) => setSearchTypeQuestion(e.target.value)}
      className="filter-select"
    >
      <option value="text">Search For A Question </option>
      <option value="book"> Search For An Auther</option>
    </select>
  </div>

  {searchTypeQuestion === 'text' && (
    <div className="filter-section">
      <input
        type="text"
        placeholder=" Search For A Question "
        value={searchQuestionTerm}
        onChange={(e) => setSearchQuestionTerm(e.target.value)}
        className="search-input"
      />
      <button className="btn-secondary" onClick={() => setSearchQuestionTerm('')}>View All Questions</button>
    </div>
  )}

  {searchTypeQuestion === 'book' && (
    <div className="filter-section">
      <select
        value={searchBookId}
        onChange={(e) => setSearchBookId(e.target.value)}
        className="filter-select"
      >
        <option value="">-- كل الكتب --</option>
        {books.map(book => (
          <option key={book.id} value={book.id}>{book.title}</option>
        ))}
      </select>
      <button className="btn-secondary" onClick={() => setSearchBookId('')}>عرض كل الأسئلة</button>
    </div>
  )}
</div>


{/*هذا يضمن ان عند البحث بكون فارغ 
        يعرض كل اللاسئله
        وعندما يكتب بحث  عن اسئله كتاب معين
  يظهر فقط الاسئله الخاصه بهذا الكتاب */}
<DataTable 
  columns={questionColumns} 
  data={filteredQuestions} 
  loading={loading} 
/>


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
