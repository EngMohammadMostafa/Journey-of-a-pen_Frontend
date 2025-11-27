import React, { useState, useEffect } from 'react';
import DataTable from '../components/common/DataTable';
import Modal from '../components/common/Modal';
import { booksService } from '../services/booksService';
import '../styles/global.css';
import '../styles/BooksManagement.css';

const BooksManagement = () => {
  const [activeSection, setActiveSection] = useState(null);

  // --- حالات الكتب ---
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filteredBooks, setFilteredBooks] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchType, setSearchType] = useState('title');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBook, setEditingBook] = useState(null);
  const [formData, setFormData] = useState({
    author: '',
    title: '',
    description: '',
    price: '',
    //is_free: 0,
    book_type: 'paid', 
    discount_rate: '',
    sectionid: ''
  });

  const [selectedFile, setSelectedFile] = useState(null);

  const bookStats = {
    total: books.length,
    free: books.filter(b => b.is_free === 1).length,
    paid: books.filter(b => b.is_free === 0).length
  };

  // --- حالات الأقسام ---
  const [categories, setCategories] = useState([]);
  const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [formCategoryData, setFormCategoryData] = useState({ name: '' });

  // --- حالات الأسئلة ---
  const [questions, setQuestions] = useState([]);
  const [filteredQuestions, setFilteredQuestions] = useState([]);
  const [searchTypeQuestion, setSearchTypeQuestion] = useState('text');
  const [searchQuestionTerm, setSearchQuestionTerm] = useState('');
  const [searchBookId, setSearchBookId] = useState('');
  const [isQuestionModalOpen, setIsQuestionModalOpen] = useState(false);
  const [newQuestionText, setNewQuestionText] = useState('');
  const [selectedBookId, setSelectedBookId] = useState('');
  const [isEditQuestionModalOpen, setIsEditQuestionModalOpen] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState(null);
  const [editingQuestionText, setEditingQuestionText] = useState('');

  const questionStats = {
    totalQuestions: questions.length,
    correctAnswers: questions.filter(q => q.is_correct === 1).length,
    totalPoints: questions.reduce((sum, q) => sum + (q.points || 0), 0)
  };
/* // --- أعمدة الجداول ---
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
  ];*/
  const bookColumns = [
    { key: 'id', title: 'ID' },
    { key: 'author', title: 'المؤلف' },
    { key: 'title', title: 'عنوان الكتاب' },
    { key: 'description', title: 'الوصف' },
    { key: 'price', title: 'السعر' },
    { 
      key: 'book_type', 
      title: 'نوع الكتاب', 
      render: (value) => value === 'paid' ? 'مدفوع' : 'مجاني' 
    },
    { key: 'discount_rate', title: 'نسبة الخصم' },
    { key: 'number_of_likes', title: 'عدد الإعجابات' },
    { 
      key: 'category_id', 
      title: 'القسم',
      render: (value) => {
        const category = categories.find(cat => cat.id === value);
        return category ? category.name : value;
      }
    },
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

  const categoryColumns = [
    { key: 'id', title: 'ID' },
    { key: 'name', title: 'اسم القسم' },
    {
      key: 'actions',
      title: 'الإجراءات',
      render: (_, category) => (
        <div>
          <button className="btn-danger" onClick={() => handleDeleteCategory(category)}>حذف</button>
        </div>
      )
    }
  ];

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
  const handleCategories = () => setActiveSection('categories');

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

  const handleDeleteBook = async (book) => {
    const confirmDelete = window.confirm(
      `هل أنت متأكد من حذف الكتاب "${book.title}"؟`
    );
    if (!confirmDelete) return;
  
    try {
      await booksService.deleteBook(book.id);
  
      setBooks(prev => prev.filter(b => b.id !== book.id));
  
      alert("تم حذف الكتاب بنجاح");
    } catch (error) {
      console.error("خطأ أثناء حذف الكتاب:", error);
      alert("حدث خطأ أثناء حذف الكتاب");
    }
  };
  

  const handleSaveBook = async () => {
    if (!formData.author || !formData.title || !formData.description || !formData.price || !formData.sectionid) {
      alert('يرجى ملء جميع الحقول المطلوبة');
      return;
  }
  
    try {
      // إنشاء FormData لرفع الملف
      const formDataToSend = new FormData();
      formDataToSend.append('title', formData.title);
      formDataToSend.append('author', formData.author);
      formDataToSend.append('description', formData.description);
      formDataToSend.append('price', Number(formData.price));
      formDataToSend.append('book_type', formData.book_type);
      formDataToSend.append('discount_rate', Number(formData.discount_rate) || 0);
      formDataToSend.append('category_id', formData.sectionid); // ← هنا التعديل
if (selectedFile) {
  formDataToSend.append('file', selectedFile);
}
      console.log("بيانات الكتاب المرسلة:", {
        title: formData.title,
        author: formData.author,
        price: formData.price,
        book_type: formData.book_type,
        file: selectedFile.name
      });
  
      if (editingBook) {
        // تعديل كتاب موجود
        await booksService.updateBook(editingBook.id, formDataToSend);
        alert('تم تعديل الكتاب بنجاح');
      } else {
        // إضافة كتاب جديد
        await booksService.addBookToCategory(formData.sectionid, formDataToSend);
        alert('تم إضافة الكتاب بنجاح');
      }
  
      // إعادة تحميل الكتب
      const updatedBooks = await booksService.getAllBooks();
      setBooks(updatedBooks.books || updatedBooks);
  
      setIsModalOpen(false);
      setEditingBook(null);
      setSelectedFile(null);
  
    } catch (error) {
      console.error('خطأ في حفظ الكتاب:', error);
      alert('حدث خطأ أثناء حفظ الكتاب: ' + (error.message || 'خطأ غير معروف'));
    }
  };
  
  // --- دوال إدارة الأقسام ---
  const handleAddCategory = () => {
    setEditingCategory(null);
    setFormCategoryData({ name: '' });
    setIsCategoryModalOpen(true);
  };
  const handleSaveCategory = async () => {
    if (!formCategoryData.name) {
      alert('يرجى كتابة اسم القسم');
      return;
    }
    try {
      await booksService.addCategory({ name: formCategoryData.name });
  
      // بعد عملية الإضافة يجب جلب الأقسام من جديد
      const updated = await booksService.getAllCategories();
      setCategories(updated.categories || []);
  
      alert('تم إضافة القسم الجديد بنجاح');
      setIsCategoryModalOpen(false);
      setFormCategoryData({ name: '' });
    } catch (error) {
      console.error('Error adding category:', error);
      alert('حدث خطأ أثناء إضافة القسم');
    }
  };
  

  const handleDeleteCategory = (category) => {
    if (window.confirm(`هل أنت متأكد من حذف القسم "${category.name}"؟`)) {
      setCategories(categories.filter(c => c.id !== category.id));
      alert('تم حذف القسم (محاكاة)');
    }
  };

  // --- دوال إدارة الأسئلة ---
  const handleAddQuestion = () => {
    if (!newQuestionText || !selectedBookId) {
      alert('يرجى كتابة السؤال واختيار الكتاب');
      return;
    }
    const book = books.find(b => b.id === parseInt(selectedBookId));
    const newQuestion = { id: Date.now(), text: newQuestionText, book_title: book?.title || 'غير محدد', book_id: parseInt(selectedBookId) };
    setQuestions([...questions, newQuestion]);
    alert('تم إضافة السؤال (محاكاة)');
    setNewQuestionText('');
    setSelectedBookId('');
    setIsQuestionModalOpen(false);
  };

  const openEditQuestionModal = (question) => {
    setEditingQuestion(question);
    setEditingQuestionText(question.text);
    setIsEditQuestionModalOpen(true);
  };

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

  const handleDeleteQuestion = (question) => {
    if (window.confirm(`هل أنت متأكد من حذف السؤال "${question.text}"؟`)) {
      setQuestions(questions.filter(q => q.id !== question.id));
      alert('تم حذف السؤال (محاكاة)');
    }
  };

  // --- useEffect ---
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const categoriesData = await booksService.getAllCategories();
        setCategories(categoriesData);
      } catch (error) {
        console.error("Error fetching categories:", error);
      }
    };
  
    fetchCategories();
  }, []);
  
  // --- جلب الكتب عند فتح قسم Book Management ---
useEffect(() => {
  if (activeSection === 'books') {
    const fetchBooks = async () => {
      try {
        setLoading(true);
        const booksData = await booksService.getAllBooks();
        setBooks(booksData.books || booksData);
      } catch (error) {
        console.error("Error fetching books:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchBooks();
  }
}, [activeSection]);

  useEffect(() => {
    let filtered = books;
    if (searchTerm) {
      if (searchType === 'title') filtered = books.filter(b => b.title?.toLowerCase().includes(searchTerm.toLowerCase()));
      else if (searchType === 'author') filtered = books.filter(b => b.author?.toLowerCase().includes(searchTerm.toLowerCase()));
    }
    setFilteredBooks(filtered);
  }, [books, searchTerm, searchType]);

  useEffect(() => {
    let filtered = questions;
    if (searchTypeQuestion === 'text' && searchQuestionTerm) filtered = questions.filter(q => q.text.toLowerCase().includes(searchQuestionTerm.toLowerCase()));
    else if (searchTypeQuestion === 'book' && searchBookId) filtered = questions.filter(q => q.book_id === parseInt(searchBookId));
    setFilteredQuestions(filtered);
  }, [questions, searchTypeQuestion, searchQuestionTerm, searchBookId]);


  return (
    <div className="books-management">
    <div className="page-header">
      <h1>Books Management</h1>

      {activeSection === 'books' && (
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="btn-primary add-book-btn" onClick={handleAddBook}>
            + Add New Book
          </button>

          <button className="btn-primary add-book-btn" onClick={handleAddCategory}>
            + add new category
          </button>
        </div>
      )}

      {activeSection === 'questions' && (
        <button className="btn-primary add-book-btn" onClick={() => setIsQuestionModalOpen(true)}>
          + Add New Question
        </button>
      )}

    </div>
  
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

      <div style={{ display: 'flex', gap: '10px' }}>
        
      </div>
    </div>

  
          <div className="book-stats">
            <div className="stat-card">
              <h3>Total Number Of Books</h3>
              <span className="stat-number">{bookStats.total}</span>
            </div>
            <div className="stat-card">
              <h3>Number Of Free Books</h3>
              <span className="stat-number">{bookStats.free}</span>
            </div>
            <div className="stat-card">
              <h3>Number Of Non-Free Books</h3>
              <span className="stat-number">{bookStats.paid}</span>
            </div>
          </div>
  
          <div className="books-filters">
            <div className="search-section">
              <input
                type="text"
                placeholder="Search For The Book Title Or Author's Name"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="search-input"
              />
            </div>
  
            <div className="filter-section">
              <select value={searchType} onChange={(e) => setSearchType(e.target.value)} className="filter-select">
                <option value="title">Search For The Book Title</option>
                <option value="author">Search For The Author's Name</option>
              </select>
            </div>
  
            <div className="filter-section">
              <button className="btn-secondary" onClick={() => setSearchTerm('')}>View All Books</button>
            </div>
  
            <div className="results-count">
              Show {filteredBooks.length} Out Of {books.length} Books
            </div>
          </div>
  
          <DataTable columns={bookColumns} data={searchTerm ? filteredBooks : books} loading={loading} />


          {/* جدول الأقسام */}
<div className="section-header" style={{ marginTop: '40px' }}>
  <h3>الأقسام المتوفرة</h3>
</div>

<DataTable
  columns={categoryColumns}
  data={categories}
  loading={false}
/>

        </div>
      )}
  
     
  
      {/* قسم إدارة الأسئلة */}
      {activeSection === 'questions' && (
        <div className="questions-section">
          <div className="section-header">
            <h2>Questions and Answers Section</h2>
          </div>
  
          <div className="question-stats">
            <div className="stat-card">
              <h3>Total Number Of Questions</h3>
              <span className="stat-number">{questionStats.totalQuestions}</span>
            </div>
            <div className="stat-card">
              <h3>Number Of Correct Answers</h3>
              <span className="stat-number">{questionStats.correctAnswers}</span>
            </div>
            <div className="stat-card">
              <h3>Total Number Of Points Earned</h3>
              <span className="stat-number">{questionStats.totalPoints}</span>
            </div>
          </div>
  
          <div className="questions-filters">
            <div className="filter-section">
              <select value={searchTypeQuestion} onChange={(e) => setSearchTypeQuestion(e.target.value)} className="filter-select">
                <option value="text">Search For A Question</option>
                <option value="book">Search By Book</option>
              </select>
            </div>
  
            {searchTypeQuestion === 'text' && (
              <div className="filter-section">
                <input
                  type="text"
                  placeholder="Search For A Question"
                  value={searchQuestionTerm}
                  onChange={(e) => setSearchQuestionTerm(e.target.value)}
                  className="search-input"
                />
                <button className="btn-secondary" onClick={() => setSearchQuestionTerm('')}>View All Questions</button>
              </div>
            )}
  
            {searchTypeQuestion === 'book' && (
              <div className="filter-section">
                <select value={searchBookId} onChange={(e) => setSearchBookId(e.target.value)} className="filter-select">
                  <option value="">-- كل الكتب --</option>
                  {books.map(book => (
                    <option key={book.id} value={book.id}>{book.title}</option>
                  ))}
                </select>
                <button className="btn-secondary" onClick={() => setSearchBookId('')}>عرض كل الأسئلة</button>
              </div>
            )}
          </div>
  
          <DataTable columns={questionColumns} data={filteredQuestions} loading={loading} />
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
            <textarea value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>السعر *</label>
            <input type="number" value={formData.price} onChange={(e) => setFormData({ ...formData, price: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>مجاني؟</label>
            <select value={formData.is_free} onChange={(e) => setFormData({ ...formData, is_free: parseInt(e.target.value) })}>
              <option value={0}>لا</option>
              <option value={1}>نعم</option>
            </select>
          </div>

          <div className="form-group">
  <label>نوع الكتاب</label>
  <select 
    value={formData.book_type} 
    onChange={(e) => setFormData({...formData, book_type: e.target.value})}
    className="form-input"
  >
    <option value="paid">مدفوع</option>
    <option value="free">مجاني</option>
  </select>
</div>

          <div className="form-group">
            <label>نسبة الخصم</label>
            <input type="number" value={formData.discount_rate} onChange={(e) => setFormData({ ...formData, discount_rate: e.target.value })} />
          </div>
          <div className="form-group">
            <label>القسم *</label>
            <select value={formData.sectionid} onChange={(e) => setFormData({ ...formData, sectionid: e.target.value })} required>
              <option value="">-- اختر قسم --</option>
              {categories.map(cat => (<option key={cat.id} value={cat.id}>{cat.name}</option>))}
            </select>
          </div>
          
          {/* حقل رفع الملف المضاف */}
          <div className="form-group">
            <label>رفع ملف الكتاب (PDF) *</label>
            <input 
              type="file" 
              accept=".pdf"
              onChange={(e) => setSelectedFile(e.target.files[0])}
              className="form-input"
              required
            />
            {selectedFile && <span style={{color: 'green'}}>✓ تم اختيار: {selectedFile.name}</span>}
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>إلغاء</button>
            <button className="btn-primary" onClick={handleSaveBook}>{editingBook ? "حفظ التعديل" : "إضافة كتاب"}</button>
          </div>
        </div>
      </Modal>
  
      {/* مودال إضافة / تعديل قسم */}
      <Modal
        isOpen={isCategoryModalOpen}
        onClose={() => { setIsCategoryModalOpen(false); setFormCategoryData({ name: '' }); }}
        title="إضافة قسم جديد"
      >
        <div className="category-form">
          <div className="form-group">
            <label>اسم القسم *</label>
            <input type="text" value={formCategoryData.name} onChange={(e) => setFormCategoryData({ ...formCategoryData, name: e.target.value })} required />
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsCategoryModalOpen(false)}>إلغاء</button>
            <button className="btn-primary" onClick={handleSaveCategory}>إضافة</button>
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
              {books.map(book => (<option key={book.id} value={book.id}>{book.title}</option>))}
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
